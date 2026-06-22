-- Replace `project.dataset.events_*` with your GA4 BigQuery export table.
-- Use the first query for the Google Sheets tab named `notification`.
-- Use the second query for the Google Sheets tab named `special_offer`.

-- Sheet: notification
WITH events AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS date,
    event_name,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'notification_id') AS notification_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'purchase_source') AS purchase_source,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'offer_text_en') AS offer_text_en
  FROM `project.dataset.events_*`
  WHERE event_name IN ('special_offer_notification_open', 'special_offer_purchase_success')
)
SELECT
  date,
  notification_id,
  purchase_source,
  offer_text_en,
  COUNTIF(event_name = 'special_offer_notification_open') AS opened,
  COUNTIF(
    event_name = 'special_offer_purchase_success'
    AND STARTS_WITH(purchase_source, 'special_offer_push_notification')
  ) AS purchased,
  SAFE_DIVIDE(
    COUNTIF(
      event_name = 'special_offer_purchase_success'
      AND STARTS_WITH(purchase_source, 'special_offer_push_notification')
    ),
    COUNTIF(event_name = 'special_offer_notification_open')
  ) AS conversion
FROM events
WHERE STARTS_WITH(purchase_source, 'special_offer_push_notification')
GROUP BY date, notification_id, purchase_source, offer_text_en
ORDER BY date DESC, opened DESC, purchased DESC;

-- Sheet: special_offer
WITH events AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS date,
    event_name,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'offer_id') AS offer_id,
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'purchase_source') AS purchase_source
  FROM `project.dataset.events_*`
  WHERE event_name IN ('special_offer_open', 'special_offer_purchase_success')
)
SELECT
  date,
  offer_id,
  purchase_source,
  COUNTIF(event_name = 'special_offer_open') AS opened,
  COUNTIF(event_name = 'special_offer_purchase_success' AND COALESCE(offer_id, '') != '') AS purchased,
  SAFE_DIVIDE(
    COUNTIF(event_name = 'special_offer_purchase_success' AND COALESCE(offer_id, '') != ''),
    COUNTIF(event_name = 'special_offer_open')
  ) AS conversion
FROM events
WHERE COALESCE(offer_id, '') != ''
GROUP BY date, offer_id, purchase_source
ORDER BY date DESC, opened DESC, purchased DESC;
