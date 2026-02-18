#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing ${ENV_FILE}. Copy .env.example to .env and fill credentials."
  exit 1
fi

set -a
source "${ENV_FILE}"
set +a

ACCOUNT_ID="${AWS_ACCOUNT_ID:-149536475122}"
REGION="${AWS_REGION:-sa-east-1}"
EVENTS_BUCKET="veet-code-frontend-events-${ACCOUNT_ID}"
RESULTS_BUCKET="aws-athena-query-results-${ACCOUNT_ID}-${REGION}"
RESULTS_S3="s3://${RESULTS_BUCKET}/"

echo "Using account: ${ACCOUNT_ID}"
echo "Using region: ${REGION}"
echo "Events bucket: ${EVENTS_BUCKET}"
echo "Athena results bucket: ${RESULTS_BUCKET}"

aws sts get-caller-identity >/dev/null

if ! aws s3api head-bucket --bucket "${RESULTS_BUCKET}" 2>/dev/null; then
  echo "Creating Athena results bucket: ${RESULTS_BUCKET}"
  if [[ "${REGION}" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "${RESULTS_BUCKET}"
  else
    aws s3api create-bucket \
      --bucket "${RESULTS_BUCKET}" \
      --create-bucket-configuration "LocationConstraint=${REGION}"
  fi
fi

run_query() {
  local query="$1"
  local qid state reason

  qid="$(aws athena start-query-execution \
    --region "${REGION}" \
    --query-string "${query}" \
    --result-configuration "OutputLocation=${RESULTS_S3}" \
    --query 'QueryExecutionId' \
    --output text)"

  while true; do
    state="$(aws athena get-query-execution \
      --region "${REGION}" \
      --query-execution-id "${qid}" \
      --query 'QueryExecution.Status.State' \
      --output text)"

    case "${state}" in
      SUCCEEDED)
        echo "${qid}"
        return 0
        ;;
      FAILED|CANCELLED)
        reason="$(aws athena get-query-execution \
          --region "${REGION}" \
          --query-execution-id "${qid}" \
          --query 'QueryExecution.Status.StateChangeReason' \
          --output text)"
        echo "Query ${qid} ${state}: ${reason}" >&2
        return 1
        ;;
      *)
        sleep 2
        ;;
    esac
  done
}

echo "Creating Athena database..."
run_query "CREATE DATABASE IF NOT EXISTS frontend_events;" >/dev/null

echo "Recreating Athena external table with partition projection..."
run_query "DROP TABLE IF EXISTS frontend_events.analytics_events;" >/dev/null
run_query "CREATE EXTERNAL TABLE frontend_events.analytics_events (
  eventid string,
  eventtimestamp string,
  ingestiontimestamp string,
  phase string,
  source string,
  feature string,
  page string,
  label string,
  usersub string,
  useremail string,
  apiname string,
  apiendpoint string,
  apimethod string,
  apistatuscode int,
  apioutcome string
)
PARTITIONED BY (
  anomesdia string,
  app string,
  eventtype string
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
LOCATION 's3://${EVENTS_BUCKET}/analytics-events/'
TBLPROPERTIES (
  'projection.enabled'='true',
  'projection.anomesdia.type'='date',
  'projection.anomesdia.format'='yyyyMMdd',
  'projection.anomesdia.range'='20200101,NOW',
  'projection.anomesdia.interval'='1',
  'projection.anomesdia.interval.unit'='DAYS',
  'projection.app.type'='enum',
  'projection.app.values'='veet-app-web',
  'projection.eventtype.type'='enum',
  'projection.eventtype.values'='page_access,button_click,api_call',
  'storage.location.template'='s3://${EVENTS_BUCKET}/analytics-events/anomesdia=\${anomesdia}/app=\${app}/eventType=\${eventtype}/'
);" >/dev/null

echo "Running validation query..."
VALIDATION_QID="$(run_query "SELECT eventtype, count(*) AS total
FROM frontend_events.analytics_events
GROUP BY eventtype
ORDER BY total DESC;")"

aws athena get-query-results \
  --region "${REGION}" \
  --query-execution-id "${VALIDATION_QID}" \
  --output table

echo "Bootstrap completed."
