BEGIN;

-- Rerunnable reset for this stage.
TRUNCATE TABLE location RESTART IDENTITY;

-- Utility functions used by location seeding.
CREATE OR REPLACE FUNCTION seed_random_point_in_bounds(
  min_longitude DOUBLE PRECISION,
  max_longitude DOUBLE PRECISION,
  min_latitude DOUBLE PRECISION,
  max_latitude DOUBLE PRECISION
) RETURNS GEOGRAPHY(POINT, 4326) AS $$
BEGIN
  RETURN make_geographic_point(
    min_longitude + random() * (max_longitude - min_longitude),
    min_latitude + random() * (max_latitude - min_latitude)
  );
END;
$$ LANGUAGE plpgsql VOLATILE STRICT;

CREATE OR REPLACE FUNCTION seed_random_point_in_us()
RETURNS GEOGRAPHY(POINT, 4326) AS $$
BEGIN
  -- Approximate contiguous US bounds.
  RETURN seed_random_point_in_bounds(
    -124.848974,
    -66.885444,
    24.396308,
    49.384358
  );
END;
$$ LANGUAGE plpgsql VOLATILE;

CREATE OR REPLACE FUNCTION seed_random_point_in_us_region(region_key TEXT)
RETURNS GEOGRAPHY(POINT, 4326) AS $$
DECLARE normalized_key TEXT;
BEGIN
  normalized_key := UPPER(TRIM(region_key));

  IF normalized_key = 'PACIFIC_NORTHWEST' THEN
    RETURN seed_random_point_in_bounds(-124.9, -116.3, 44.0, 49.1);
  ELSIF normalized_key = 'NORTHEAST' THEN
    RETURN seed_random_point_in_bounds(-79.8, -66.9, 40.3, 47.6);
  ELSIF normalized_key = 'SOUTHEAST' THEN
    RETURN seed_random_point_in_bounds(-91.7, -75.0, 25.0, 36.9);
  ELSIF normalized_key = 'MIDWEST' THEN
    RETURN seed_random_point_in_bounds(-104.1, -80.5, 36.9, 49.1);
  ELSIF normalized_key = 'SOUTHWEST' THEN
    RETURN seed_random_point_in_bounds(-124.5, -102.0, 31.0, 41.8);
  ELSIF normalized_key = 'CALIFORNIA' THEN
    RETURN seed_random_point_in_bounds(-124.4, -114.1, 32.5, 41.9);
  ELSIF normalized_key = 'TEXAS_TRIANGLE' THEN
    RETURN seed_random_point_in_bounds(-99.9, -94.0, 29.0, 33.6);
  ELSIF normalized_key = 'FLORIDA' THEN
    RETURN seed_random_point_in_bounds(-87.7, -80.0, 25.0, 30.9);
  END IF;

  RETURN seed_random_point_in_us();
END;
$$ LANGUAGE plpgsql VOLATILE;

-- Partner 1: Northstar Marketplace (large nationwide omni-channel)
INSERT INTO location (partner_id, coordinates)
VALUES
  (1, make_geographic_point(-122.3321, 47.6062)), -- Seattle
  (1, make_geographic_point(-122.4194, 37.7749)), -- San Francisco
  (1, make_geographic_point(-118.2437, 34.0522)), -- Los Angeles
  (1, make_geographic_point(-95.3698, 29.7604)),  -- Houston
  (1, make_geographic_point(-87.6298, 41.8781)),  -- Chicago
  (1, make_geographic_point(-74.0060, 40.7128));  -- New York City

INSERT INTO location (partner_id, coordinates)
SELECT 1, seed_random_point_in_us_region(region_key)
FROM unnest(ARRAY[
  'NORTHEAST',
  'SOUTHEAST',
  'MIDWEST',
  'SOUTHWEST',
  'CALIFORNIA'
]) AS region_key
CROSS JOIN generate_series(1, 2);

-- Partner 2: Pine & Pixel Home (online-only)
-- Intentionally no physical locations.

-- Partner 3: HarborLine Grocers (Pacific Northwest regional)
INSERT INTO location (partner_id, coordinates)
VALUES
  (3, make_geographic_point(-122.6765, 45.5231)), -- Portland
  (3, make_geographic_point(-122.4443, 47.2529)), -- Tacoma
  (3, make_geographic_point(-117.4260, 47.6588)); -- Spokane

INSERT INTO location (partner_id, coordinates)
SELECT 3, seed_random_point_in_us_region('PACIFIC_NORTHWEST')
FROM generate_series(1, 5);

-- Partner 4: TrailPeak Outdoors (major-city flagships + regional stores)
INSERT INTO location (partner_id, coordinates)
VALUES
  (4, make_geographic_point(-105.0000, 39.7392)), -- Denver
  (4, make_geographic_point(-111.8910, 40.7608)), -- Salt Lake City
  (4, make_geographic_point(-112.0740, 33.4484)), -- Phoenix
  (4, make_geographic_point(-106.6504, 35.0844)); -- Albuquerque

INSERT INTO location (partner_id, coordinates)
SELECT 4, seed_random_point_in_us_region(region_key)
FROM unnest(ARRAY[
  'PACIFIC_NORTHWEST',
  'CALIFORNIA',
  'SOUTHWEST'
]) AS region_key
CROSS JOIN generate_series(1, 2);

-- Partner 5: SunGrid Mobility (selected EV charging hubs)
INSERT INTO location (partner_id, coordinates)
VALUES
  (5, make_geographic_point(-96.7970, 32.7767)),  -- Dallas
  (5, make_geographic_point(-97.7431, 30.2672)),  -- Austin
  (5, make_geographic_point(-95.3698, 29.7604));  -- Houston

INSERT INTO location (partner_id, coordinates)
SELECT 5, seed_random_point_in_us_region(region_key)
FROM unnest(ARRAY[
  'TEXAS_TRIANGLE',
  'CALIFORNIA',
  'FLORIDA'
]) AS region_key
CROSS JOIN generate_series(1, 2);

-- Partner 6: Willow & Wheat Bakery Co. (few neighborhood storefronts)
INSERT INTO location (partner_id, coordinates)
VALUES
  (6, make_geographic_point(-87.6298, 41.8781)), -- Chicago
  (6, make_geographic_point(-87.6877, 42.0451)); -- Evanston

INSERT INTO location (partner_id, coordinates)
SELECT 6, seed_random_point_in_us_region('MIDWEST')
FROM generate_series(1, 1);

-- Partner 7: CloudCart Office Supply (online-only)
-- Intentionally no physical locations.

-- Partner 8: Blue Mesa Cinemas (regional, metro-centered)
INSERT INTO location (partner_id, coordinates)
VALUES
  (8, make_geographic_point(-112.0740, 33.4484)), -- Phoenix
  (8, make_geographic_point(-115.1398, 36.1699)), -- Las Vegas
  (8, make_geographic_point(-106.6504, 35.0844)); -- Albuquerque

INSERT INTO location (partner_id, coordinates)
SELECT 8, seed_random_point_in_us_region('SOUTHWEST')
FROM generate_series(1, 3);

-- Partner 9: Meridian Health Clubs (multi-region urban footprint)
INSERT INTO location (partner_id, coordinates)
VALUES
  (9, make_geographic_point(-73.9352, 40.7306)),  -- New York metro
  (9, make_geographic_point(-71.0589, 42.3601)),  -- Boston
  (9, make_geographic_point(-77.0369, 38.9072)),  -- Washington, DC
  (9, make_geographic_point(-84.3880, 33.7490));  -- Atlanta

INSERT INTO location (partner_id, coordinates)
SELECT 9, seed_random_point_in_us_region('NORTHEAST')
FROM generate_series(1, 2);

-- Partner 10: KettleForge Roastery (small café footprint + subscriptions)
INSERT INTO location (partner_id, coordinates)
VALUES
  (10, make_geographic_point(-122.3321, 47.6062)), -- Seattle
  (10, make_geographic_point(-122.6765, 45.5231)); -- Portland

INSERT INTO location (partner_id, coordinates)
SELECT 10, seed_random_point_in_us_region('PACIFIC_NORTHWEST')
FROM generate_series(1, 1);

-- Partner 11: Riverstone Department Stores (inactive partner, still has stores)
INSERT INTO location (partner_id, coordinates)
VALUES
  (11, make_geographic_point(-74.0060, 40.7128)), -- New York City
  (11, make_geographic_point(-80.1918, 25.7617)); -- Miami

INSERT INTO location (partner_id, coordinates)
SELECT 11, seed_random_point_in_us_region(region_key)
FROM unnest(ARRAY['MIDWEST', 'SOUTHEAST']) AS region_key;

COMMIT;
