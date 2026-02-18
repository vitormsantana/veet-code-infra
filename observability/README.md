# Local Observability Stack

This folder provides a local, open-source observability stack for development:

- OpenTelemetry Collector (OTLP ingest)
- Tempo (traces)
- Prometheus (metrics)
- Loki (logs)
- Grafana (dashboards)

## Start

```bash
docker compose up -d
```

Grafana:
- http://localhost:3000
- user: `admin`
- password: `admin`

Collector endpoints:
- OTLP gRPC: `localhost:4317`
- OTLP HTTP: `localhost:4318`

## What You Can See Today

In AWS Lambda right now we emit:
- `otel_span` events as JSON logs
- `otel_metric` events as JSON logs

Those are visible in CloudWatch Logs immediately and include correlation ids (`awsRequestId`, `requestId`, `traceId`).

## Next Step (When OTLP Export Is Enabled)

When the lambdas start exporting real OTLP traces/metrics, point them at the collector above. Then you can:
- query metrics in Prometheus (and Grafana)
- query traces in Tempo (and Grafana)

## Stop

```bash
docker compose down
```
