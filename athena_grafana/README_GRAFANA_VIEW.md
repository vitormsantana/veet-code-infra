# Grafana Views and Data Source (Athena)

This document explains the Grafana dashboard created for frontend analytics, where data comes from, and how to maintain/debug it.

## Scope

- Grafana OSS running locally in Docker
- Athena as the query engine
- S3 as event storage
- Dashboard provisioned from files in this repo

## Architecture

1. Frontend events are stored in S3 by the `frontend_event_reciever` Lambda.
2. Athena exposes those files via external table `frontend_events.analytics_events`.
3. Grafana uses `grafana-athena-datasource` plugin to query Athena.
4. A provisioned dashboard renders panels from Athena SQL queries.

## Data Source Configuration

Provisioned file:

- `athena_grafana/grafana/provisioning/datasources/athena.yaml`

Current key settings:

- Name: `Athena`
- UID: `athena`
- Type: `grafana-athena-datasource`
- Region: `${AWS_REGION}` (default `sa-east-1`)
- Catalog: `AwsDataCatalog`
- Database: `frontend_events`
- Workgroup: `primary`
- Output location:
  - `s3://aws-athena-query-results-${AWS_ACCOUNT_ID}-${AWS_REGION}/`

Important:

- Dashboard panels reference datasource by UID (`athena`), not just name.

## Athena Table Source

DDL file:

- `athena_grafana/sql/frontend_events_ddl.sql`

Table:

- `frontend_events.analytics_events`

Storage path model (current S3 layout):

- `s3://veet-code-frontend-events-<ACCOUNT_ID>/analytics-events/anomesdia=YYYYMMDD/app=<app>/eventType=<eventtype>/...`

Athena mapping uses partition projection and location template to match `eventType=` in S3 folder names.

## Dashboard Provisioning

Provider file:

- `athena_grafana/grafana/provisioning/dashboards/dashboard_provider.yaml`

Dashboard file:

- `athena_grafana/grafana/provisioning/dashboards/frontend_events_overview.json`

Folder in Grafana:

- `Frontend Analytics`

Dashboard title:

- `Frontend Events Overview`

## Panels and Their Sources

1. `Total Events (Time Range)`
- SQL: count all rows in `frontend_events.analytics_events`

2. `Invalid button_click With API Fields`
- SQL: counts rows where `eventtype='button_click'` and any API field is present
- Purpose: contract regression detector

3. `Events Per Day`
- SQL groups by `anomesdia`
- Uses numeric cast for chart compatibility:
  - `CAST(count(*) AS DOUBLE) AS events`

4. `Event Type Split`
- SQL groups by `eventtype`
- Uses numeric cast:
  - `CAST(count(*) AS DOUBLE) AS total`

5. `Top Pages`
- SQL filters `eventtype='page_access'`, groups by `page`

6. `API Success/Error By API`
- SQL filters `eventtype='api_call'`, groups by `apiname, apioutcome`

7. `Top Features`
- SQL groups by `feature`

8. `Invalid button_click Samples`
- Table with sample violating rows for debugging payload classification

## Why "No Data" Happened and What Was Fixed

Issues encountered and fixes applied:

1. **Athena partition mismatch**
- S3 folder key used `eventType=...` (camel case)
- Athena partition column is `eventtype`
- Fix: partition projection + `storage.location.template` mapped to `eventType=${eventtype}`

2. **Grafana dashboard queries using invalid query field**
- Error:
  - `cannot unmarshal string into ... query.format ...`
- Cause: panel targets contained `"format": "table"` (unsupported format field type for plugin backend)
- Fix: removed `format` from all targets

3. **Datasource binding ambiguity**
- Dashboard initially referenced datasource as a plain name string
- Fix: set datasource UID in provisioning (`uid: athena`) and bind panels to that UID

4. **Missing per-target Athena connection args**
- Plugin expects `target.connectionArgs.*`
- Fix: added connection args (`region`, `catalog`, `database`, `workgroup`) to each panel target

5. **Chart field mapping/numeric typing**
- `Event Type Split` used wrong `xField`
- Counts not always recognized as numeric by chart panel
- Fix:
  - `xField` set to `eventtype`
  - explicit numeric casts with `CAST(count(*) AS DOUBLE)`

## Run and Verify

1. Start/restart Grafana:

```bash
docker restart grafana-athena
```

2. Open:

- `http://localhost:3000`

3. Navigate:

- `Dashboards` -> `Frontend Analytics` -> `Frontend Events Overview`

4. If changes were made recently:

- Hard refresh browser (`Ctrl+Shift+R`)

5. Verify datasource:

- `Connections` -> `Data sources` -> `Athena` -> `Save & Test`

## Troubleshooting Quick Checks

If panels are empty:

1. Validate Athena directly:

```sql
SELECT eventtype, count(*) AS total
FROM frontend_events.analytics_events
GROUP BY eventtype
ORDER BY total DESC;
```

2. Validate S3 data exists:

```bash
aws s3 ls s3://veet-code-frontend-events-149536475122/analytics-events/ --recursive | head -50
```

3. Inspect Grafana panel query error:

- Panel -> `Inspect` -> `Query` -> `Refresh`
- Check `response.results.A.error`

4. Check Grafana logs:

```bash
docker logs --tail 150 grafana-athena
```

## Security Note

Local `.env` contains AWS credentials. Keep it out of git:

- ignored via `.gitignore` (`athena_grafana/.env`)

Rotate keys if they were exposed in chat/history.
