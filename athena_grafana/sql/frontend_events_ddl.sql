CREATE DATABASE IF NOT EXISTS frontend_events;

DROP TABLE IF EXISTS frontend_events.analytics_events;

CREATE EXTERNAL TABLE frontend_events.analytics_events (
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
LOCATION 's3://veet-code-frontend-events-<ACCOUNT_ID>/analytics-events/'
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
  'storage.location.template'='s3://veet-code-frontend-events-<ACCOUNT_ID>/analytics-events/anomesdia=${anomesdia}/app=${app}/eventType=${eventtype}/'
);

-- With partition projection enabled, MSCK REPAIR is not required.

-- Validation query:
-- SELECT eventtype, count(*)
-- FROM frontend_events.analytics_events
-- GROUP BY 1
-- ORDER BY 2 DESC;

-- Starter query: Events per day
-- SELECT anomesdia, count(*) AS events
-- FROM analytics_events
-- GROUP BY anomesdia
-- ORDER BY anomesdia;

-- Starter query: Event type split
-- SELECT eventtype, count(*) AS total
-- FROM analytics_events
-- GROUP BY eventtype
-- ORDER BY total DESC;

-- Starter query: API success/error
-- SELECT apiname, apioutcome, count(*) total
-- FROM analytics_events
-- WHERE eventtype = 'api_call'
-- GROUP BY apiname, apioutcome
-- ORDER BY total DESC;

-- Starter query: Top pages
-- SELECT page, count(*) total
-- FROM analytics_events
-- WHERE eventtype = 'page_access'
-- GROUP BY page
-- ORDER BY total DESC
-- LIMIT 20;
