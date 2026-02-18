# Athena + Grafana OSS (Local)

Local analytics stack for `frontend_event_reciever` data:

- Source: S3 events bucket (`veet-code-frontend-events-<ACCOUNT_ID>`)
- Query engine: Athena
- Visualization: Grafana OSS + Athena datasource plugin
- Dashboard: provisioned from this repo

## Integrations and Flow

1. Frontend sends events to API Gateway `/frontend_event_reciever`.
2. Lambda writes JSON objects to S3 under:
   - `analytics-events/anomesdia=YYYYMMDD/app=<app>/eventType=<eventtype>/...`
3. Athena external table maps those files.
4. Grafana queries Athena and renders dashboards.

## Files in This Folder

- `athena_grafana/.env.example`: environment template
- `athena_grafana/docker-compose.yml`: local Grafana runtime
- `athena_grafana/scripts/bootstrap_athena.sh`: CLI bootstrap for Athena
- `athena_grafana/sql/frontend_events_ddl.sql`: Athena DDL
- `athena_grafana/grafana/provisioning/datasources/athena.yaml`: Athena datasource provisioning
- `athena_grafana/grafana/provisioning/dashboards/dashboard_provider.yaml`: dashboard provider
- `athena_grafana/grafana/provisioning/dashboards/frontend_events_overview.json`: dashboard definition
- `athena_grafana/README_GRAFANA_VIEW.md`: deep-dive on panel/debug history

## 1) Configure Environment

Create `athena_grafana/.env`:

```env
AWS_REGION=sa-east-1
AWS_ACCOUNT_ID=149536475122
AWS_ACCESS_KEY_ID=<YOUR_ACCESS_KEY_ID>
AWS_SECRET_ACCESS_KEY=<YOUR_SECRET_ACCESS_KEY>
```

## 2) Bootstrap Athena (Recommended)

```bash
./athena_grafana/scripts/bootstrap_athena.sh
```

What this script does:

1. Verifies AWS auth (`sts get-caller-identity`)
2. Creates Athena result bucket if missing:
   - `aws-athena-query-results-<ACCOUNT_ID>-<REGION>`
3. Creates DB `frontend_events`
4. Recreates table `frontend_events.analytics_events`
5. Configures partition projection to match S3 `eventType=...` folder
6. Runs validation query and prints results

Manual alternative:

- Run `athena_grafana/sql/frontend_events_ddl.sql` in Athena.

## 3) Start Grafana

Preferred (compose plugin):

```bash
cd athena_grafana
docker compose up -d
```

If your Docker does not support `docker compose`, use `docker run` with:

- `--env-file athena_grafana/.env`
- mount `athena_grafana/grafana/provisioning` to `/etc/grafana/provisioning`
- plugin env: `GF_INSTALL_PLUGINS=grafana-athena-datasource`

Grafana URL:

- `http://localhost:3000`

## 4) Provisioned Data Source

Datasource file:

- `athena_grafana/grafana/provisioning/datasources/athena.yaml`

Configured values:

- Name: `Athena`
- UID: `athena`
- Region: `${AWS_REGION}`
- Catalog: `AwsDataCatalog`
- Database: `frontend_events`
- Workgroup: `primary`
- Output location:
  - `s3://aws-athena-query-results-${AWS_ACCOUNT_ID}-${AWS_REGION}/`

## 5) Provisioned Dashboard

Dashboard folder:

- `Frontend Analytics`

Dashboard:

- `Frontend Events Overview`

Panels included:

1. Total Events (Time Range)
2. Invalid `button_click` With API Fields
3. Events Per Day
4. Event Type Split
5. Top Pages
6. API Success/Error By API
7. Top Features
8. Invalid `button_click` Samples

## 6) Core Queries Used

Event type split:

```sql
SELECT eventtype, CAST(count(*) AS DOUBLE) AS total
FROM frontend_events.analytics_events
GROUP BY eventtype
ORDER BY total DESC;
```

Events per day:

```sql
SELECT anomesdia, CAST(count(*) AS DOUBLE) AS events
FROM frontend_events.analytics_events
GROUP BY anomesdia
ORDER BY anomesdia;
```

API success/error:

```sql
SELECT apiname, apioutcome, count(*) AS total
FROM frontend_events.analytics_events
WHERE eventtype = 'api_call'
GROUP BY apiname, apioutcome
ORDER BY total DESC;
```

Top pages:

```sql
SELECT page, count(*) AS total
FROM frontend_events.analytics_events
WHERE eventtype = 'page_access'
GROUP BY page
ORDER BY total DESC
LIMIT 20;
```

Contract regression (invalid button click carrying API fields):

```sql
SELECT count(*) AS invalid_button_click_with_api
FROM frontend_events.analytics_events
WHERE eventtype = 'button_click'
  AND (
    apiname IS NOT NULL OR
    apiendpoint IS NOT NULL OR
    apimethod IS NOT NULL OR
    apistatuscode IS NOT NULL OR
    apioutcome IS NOT NULL
  );
```

## 7) Validation Checklist

1. Athena returns counts:

```sql
SELECT eventtype, count(*) AS total
FROM frontend_events.analytics_events
GROUP BY 1
ORDER BY 2 DESC;
```

2. S3 has event objects:

```bash
aws s3 ls s3://veet-code-frontend-events-149536475122/analytics-events/ --recursive | head -50
```

3. Grafana datasource status:

- `Connections -> Data sources -> Athena -> Save & Test` should be green.

## 8) Troubleshooting

If panel shows no data:

1. Panel -> `Inspect` -> `Query` -> `Refresh`
2. Check `response.results.A.error`
3. Check container logs:

```bash
docker logs --tail 150 grafana-athena
```

Known issues already addressed in this repo:

- Athena partition path mapped to `eventType=` folders via projection
- Dashboard uses datasource UID (`athena`)
- Query `format` field removed (plugin unmarshal fix)
- Athena `connectionArgs` provided on each panel target
- Numeric casting added for bar charts

## 9) Security Notes

- Keep `athena_grafana/.env` local only (ignored by `.gitignore`).
- Rotate AWS keys if they were exposed.
