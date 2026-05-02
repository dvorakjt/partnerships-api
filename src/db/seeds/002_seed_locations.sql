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

-- Partner 1: Bloom & Vine Floral Design (metro delivery hubs)
INSERT INTO location (partner_id, coordinates)
VALUES
  (1, make_geographic_point(-122.4194, 37.7749)), -- San Francisco
  (1, make_geographic_point(-118.2437, 34.0522)), -- Los Angeles
  (1, make_geographic_point(-87.6298, 41.8781)),  -- Chicago
  (1, make_geographic_point(-73.9352, 40.7306));  -- New York City

-- Partner 2: Craft & Forge Furniture Co. (showrooms)
INSERT INTO location (partner_id, coordinates)
VALUES
  (2, make_geographic_point(-96.7970, 32.7767)),  -- Dallas
  (2, make_geographic_point(-104.9903, 39.7392)), -- Denver
  (2, make_geographic_point(-84.3880, 33.7490)),  -- Atlanta
  (2, make_geographic_point(-122.3321, 47.6062)); -- Seattle

-- Partner 3: Harbor View Cafe (dense coast-to-coast cafes)
-- Dense coverage target: location within ~100 miles across contiguous US.
INSERT INTO location (partner_id, coordinates)
SELECT 3, make_geographic_point(lon, lat)
FROM generate_series(-124.0, -68.0, 2.0) AS lon
CROSS JOIN generate_series(25.0, 49.0, 2.0) AS lat;

-- Partner 4: Luna Bliss Spa (premium urban centers)
INSERT INTO location (partner_id, coordinates)
VALUES
  (4, make_geographic_point(-118.2437, 34.0522)), -- Los Angeles
  (4, make_geographic_point(-112.0740, 33.4484)), -- Phoenix
  (4, make_geographic_point(-95.3698, 29.7604)),  -- Houston
  (4, make_geographic_point(-80.1918, 25.7617)),  -- Miami
  (4, make_geographic_point(-73.9857, 40.7484));  -- New York

-- Partner 5: Luxe Glow Cosmetics (flagship + mall stores)
INSERT INTO location (partner_id, coordinates)
VALUES
  (5, make_geographic_point(-122.4194, 37.7749)), -- San Francisco
  (5, make_geographic_point(-118.2437, 34.0522)), -- Los Angeles
  (5, make_geographic_point(-95.3698, 29.7604)),  -- Houston
  (5, make_geographic_point(-87.6298, 41.8781)),  -- Chicago
  (5, make_geographic_point(-73.9857, 40.7484));  -- New York

-- Partner 6: Nova Real Estate (nationwide advisory network)
-- Dense coverage target: location within ~100 miles across contiguous US.
INSERT INTO location (partner_id, coordinates)
SELECT 6, make_geographic_point(lon, lat)
FROM generate_series(-123.0, -67.0, 2.0) AS lon
CROSS JOIN generate_series(26.0, 48.0, 2.0) AS lat;

-- Partner 7: Paw Pals Pet Grooming (suburban clusters)
INSERT INTO location (partner_id, coordinates)
VALUES
  (7, make_geographic_point(-122.2711, 37.8044)), -- Oakland
  (7, make_geographic_point(-96.8005, 32.7801)),  -- Dallas area
  (7, make_geographic_point(-83.0458, 42.3314)),  -- Detroit
  (7, make_geographic_point(-75.1652, 39.9526)),  -- Philadelphia
  (7, make_geographic_point(-81.3792, 28.5383));  -- Orlando

-- Partner 8: Silverstream Media (studio offices)
INSERT INTO location (partner_id, coordinates)
VALUES
  (8, make_geographic_point(-118.2437, 34.0522)), -- Los Angeles
  (8, make_geographic_point(-122.4194, 37.7749)), -- San Francisco
  (8, make_geographic_point(-74.0060, 40.7128));  -- New York

-- Partner 9: Summit Peak Outdoors (regional outdoor hubs)
INSERT INTO location (partner_id, coordinates)
VALUES
  (9, make_geographic_point(-122.3321, 47.6062)), -- Seattle
  (9, make_geographic_point(-111.8910, 40.7608)), -- Salt Lake City
  (9, make_geographic_point(-104.9903, 39.7392)), -- Denver
  (9, make_geographic_point(-116.2023, 43.6150)), -- Boise
  (9, make_geographic_point(-106.6504, 35.0844)); -- Albuquerque

-- Partner 10: Taste & Thyme Catering (event markets)
INSERT INTO location (partner_id, coordinates)
VALUES
  (10, make_geographic_point(-87.6298, 41.8781)), -- Chicago
  (10, make_geographic_point(-96.7970, 32.7767)), -- Dallas
  (10, make_geographic_point(-84.3880, 33.7490)), -- Atlanta
  (10, make_geographic_point(-77.0369, 38.9072)), -- Washington, DC
  (10, make_geographic_point(-74.0060, 40.7128)); -- New York

-- Partner 11: Velocity Fitness (nationwide gym footprint)
INSERT INTO location (partner_id, coordinates)
VALUES
  (11, make_geographic_point(-122.3321, 47.6062)), -- Seattle
  (11, make_geographic_point(-122.4194, 37.7749)), -- San Francisco
  (11, make_geographic_point(-118.2437, 34.0522)), -- Los Angeles
  (11, make_geographic_point(-96.7970, 32.7767)),  -- Dallas
  (11, make_geographic_point(-95.3698, 29.7604)),  -- Houston
  (11, make_geographic_point(-87.6298, 41.8781)),  -- Chicago
  (11, make_geographic_point(-84.3880, 33.7490)),  -- Atlanta
  (11, make_geographic_point(-80.1918, 25.7617)),  -- Miami
  (11, make_geographic_point(-77.0369, 38.9072)),  -- Washington, DC
  (11, make_geographic_point(-74.0060, 40.7128));  -- New York

-- Partner 12: Voltix Tech (tech support centers)
INSERT INTO location (partner_id, coordinates)
VALUES
  (12, make_geographic_point(-122.4194, 37.7749)), -- San Francisco
  (12, make_geographic_point(-121.8863, 37.3382)), -- San Jose
  (12, make_geographic_point(-97.7431, 30.2672)),  -- Austin
  (12, make_geographic_point(-95.3698, 29.7604)),  -- Houston
  (12, make_geographic_point(-74.0060, 40.7128));  -- New York

COMMIT;
