CREATE TABLE reviews_raw (line STRING);
LOAD DATA INPATH '/input/beauty/beauty_reviews.jsonl' OVERWRITE INTO TABLE reviews_raw;

CREATE TABLE meta_raw (line STRING);
LOAD DATA INPATH '/input/beauty/meta_Beauty.jsonl' OVERWRITE INTO TABLE meta_raw;

CREATE VIEW reviews_parsed AS
SELECT
  get_json_object(line, '$.parent_asin') AS product_id,
  get_json_object(line, '$.asin') AS og_asin,
  CAST(get_json_object(line, '$.rating') AS FLOAT) AS rating,
  get_json_object(line, '$.title') AS review_title,
  get_json_object(line, '$.text') AS review_text,
  get_json_object(line, '$.user_id') AS user_id
FROM reviews_raw;

CREATE VIEW meta_parsed AS
SELECT
  get_json_object(line, '$.parent_asin') AS product_id,
  get_json_object(line, '$.title') AS product_name,
  get_json_object(line, '$.brand') AS brand,
  CAST(get_json_object(line, '$.price') AS FLOAT) AS price
FROM meta_raw;

CREATE TABLE enriched_reviews AS
SELECT r.product_id, m.product_name, m.brand, r.rating, r.review_title, r.review_text
FROM reviews_parsed r
JOIN meta_parsed m ON r.product_id = m.product_id;