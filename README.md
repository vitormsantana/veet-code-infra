# Frontend Event Capture Process

This repository provisions the infrastructure for capturing frontend analytics events through API Gateway, processing them in Lambda, and persisting them in S3 for analytics consumption.

Contract baseline date: `2026-02-15`.

## Goal

- Capture frontend telemetry in a consistent model.
- Separate UI interaction events from backend API execution events.
- Validate event semantics at ingestion.
- Store events in a partition-friendly S3 layout for Athena/QuickSight.

## High-Level Flow

1. Frontend sends events to API Gateway `POST /frontend_event_reciever`.
2. API Gateway invokes Lambda `frontend_event_reciever` using proxy integration.
3. Lambda validates schema + semantic rules.
4. Lambda writes one JSON object per event into S3.
5. Consumers query data from S3 partitions.

## Infrastructure Created

## API Gateway

- Existing REST API reused: `aws_api_gateway_rest_api.hammocker_api` (`hammocker-api`)
- New resource path: `/frontend_event_reciever`
- Methods:
  - `POST` -> Lambda proxy integration (`AWS_PROXY`)
  - `OPTIONS` -> mock integration, returns `204` with CORS headers
- Authorization: `NONE`
- Terraform location:
  - `apigateway_integrations/frontend_event_reciever/main.tf`
  - Deployment wiring in `apigateway.tf`

Endpoint format:

`https://{rest_api_id}.execute-api.sa-east-1.amazonaws.com/dev/frontend_event_reciever`

## Lambda

- Name: `frontend_event_reciever`
- Terraform module block: `module.lambda_frontend_event_reciever`
- Artifact path expected by Terraform:
  - `lambdas/frontend_event_reciever/frontend_event_reciever.zip`
- Runtime defaults from shared module:
  - `provided.al2`
  - `bootstrap`

## S3 Storage

- Dedicated bucket:
  - `aws_s3_bucket.frontend_events`
  - Name pattern: `veet-code-frontend-events-${account_id}`
- Public access blocked
- Versioning enabled
- IAM policy grants Lambda:
  - `s3:ListBucket` on bucket
  - `s3:PutObject` and `s3:GetObject` on configured prefix

## Event Contract

## Required Fields

- `eventId`
- `timestamp` (RFC3339)
- `app`
- `eventType`
- `phase`
- `source`
- `feature`
- `page`

## Allowed Values

- `eventType`: `page_access`, `button_click`, `api_call`
- `phase`: `start`, `response`
- `source`: `page_load`, `user_click`
- `api.method`: `GET`, `POST`, `PUT`, `DELETE`
- `api.outcome` (optional): `success`, `error`

## Semantic Rules

- `eventType=api_call`:
  - `api` object is required
- `eventType=button_click`:
  - `api` object is not allowed
- `eventType=page_access`:
  - `api` currently accepted for migration compatibility
  - target state is no `api` on `page_access`

Validation failure example:

- `button_click` carrying `api` should return:
  - `400` with message `api object is allowed only when eventType is api_call`

## HTTP Behavior

- `OPTIONS` -> `204` with CORS headers
- `POST` valid payload -> `202` with accepted status
- `POST` duplicate event key -> `202` with already processed status
- Invalid payload -> `400`
- Internal errors -> `500`

## CORS

- `ALLOWED_ORIGINS=*` wildcard is supported.
- Lambda also receives explicit allowlist via env var.

## Storage Format

Current partition path:

`analytics-events/anomesdia=YYYYMMDD/app=<app>/eventType=<eventType>/<eventId>.json`

Persisted payload shape:

- Flattened analytics fields only
- No `raw` payload copy

## Environment Variables (Lambda)

- `events_bucket_name` (required)
- `EVENTS_BUCKET` (compat fallback)
- `EVENTS_PREFIX` (default `analytics-events`)
- `ALLOWED_ORIGINS` (default `*`, configurable)
- `REQUIRE_AUTH` (default `false`, extension point)
- `METRICS_NAMESPACE` (default `Veet/AnalyticsEvents`)

Note:

- Do not configure `AWS_REGION` manually. It is Lambda-reserved.

## Frontend Integration Model (Required)

## On page load

- Emit `page_access` (preferably without `api`)
- If page load triggers a backend call, emit a separate `api_call` with `api`

## On user click

- Emit `button_click` without `api`
- If the click triggers backend call(s), emit separate `api_call` event(s)

## Practical Mapping

- `page_access` = page navigation/entry
- `button_click` = user UI action
- `api_call` = backend request execution

Known frontend bug to avoid:

- Do not send `button_click` on initial page load.
- Any event containing `api` must use `eventType=api_call`.

## Terraform Inputs Added

- `frontend_event_reciever_events_prefix` (default `analytics-events`)
- `frontend_event_reciever_allowed_origins` (default `*`)
- `frontend_event_reciever_require_auth` (default `false`)
- `frontend_event_reciever_metrics_namespace` (default `Veet/AnalyticsEvents`)
- `frontend_event_reciever_lambda_timeout` (default `30`)
- `frontend_event_reciever_lambda_memory_size` (default `256`)

## Terraform Outputs Added

- `frontend_event_reciever_events_bucket`
- `frontend_event_reciever_endpoint`

## Deploy Checklist

1. Build/package Lambda in application repo.
2. Replace artifact at `lambdas/frontend_event_reciever/frontend_event_reciever.zip`.
3. Run `terraform plan`.
4. Run `terraform apply`.
5. Confirm endpoint with:
   - `terraform output frontend_event_reciever_endpoint`

## Scope Boundary

This repository manages infrastructure only (API Gateway, Lambda resource wiring, IAM, S3).
Event schema validation, event classification, and storage JSON shape are implemented in Lambda application code.
