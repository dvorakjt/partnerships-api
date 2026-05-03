-- migrate:up
-- Accepts longitude first for consistency with other PostGIS functions.
CREATE FUNCTION make_geographic_point(
  longitude DOUBLE PRECISION,
  latitude DOUBLE PRECISION
) RETURNS GEOGRAPHY (POINT, 4326) AS $$
  BEGIN
    RETURN ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)::geography;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION make_geographic_point IS 
$$
@introspeql-include
@introspeql-disable-nullable-return-types
$$;

CREATE FUNCTION convert_distance (
  distance DOUBLE PRECISION,
  from_units distance_units,
  to_units distance_units
) RETURNS DOUBLE PRECISION AS $$
DECLARE
  meters_per_mile CONSTANT DOUBLE PRECISION := 1609.344;
  meters_per_km CONSTANT DOUBLE PRECISION := 1000;
  km_per_mile CONSTANT DOUBLE PRECISION := meters_per_mile / meters_per_km;
BEGIN
  IF from_units = 'MILES' THEN
    If to_units = 'METERS' THEN 
	  RETURN distance * meters_per_mile;
	ELSIF to_units = 'KILOMETERS' THEN
	  RETURN distance * km_per_mile;
	END IF;
  ELSIF from_units = 'KILOMETERS' THEN
    IF to_units = 'MILES' THEN
	  RETURN distance / km_per_mile;
	ELSIF to_units = 'METERS' THEN
	  RETURN distance * meters_per_km;
	END IF;
  ELSIF from_units = 'METERS' THEN
    IF to_units = 'KILOMETERS' THEN
	  RETURN distance / meters_per_km;
	ELSIF to_units = 'MILES' THEN
	  RETURN distance / meters_per_mile;
	  END IF;
  END IF;

  RETURN distance;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION convert_distance IS
$$
@introspeql-include
@introspeql-disable-nullable-return-types
$$;

CREATE FUNCTION calc_distance_with_units (
  pointA GEOGRAPHY (POINT, 4326),
  pointB GEOGRAPHY (POINT, 4326),
  units distance_units
) RETURNS DOUBLE PRECISION AS $$
  DECLARE distance_in_meters DOUBLE PRECISION; converted_distance DOUBLE PRECISION;
  BEGIN
    SELECT ST_Distance(pointA, pointB, TRUE) INTO distance_in_meters;
	  converted_distance := convert_distance(distance_in_meters, 'METERS', units);
	  RETURN converted_distance;
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION calc_distance_with_units IS 
$$
@introspeql-include
@introspeql-disable-nullable-return-types
$$;

CREATE FUNCTION get_latitude (point GEOGRAPHY (POINT, 4326)) RETURNS DOUBLE PRECISION AS $$
  BEGIN
    RETURN ST_Y(point::geometry);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION get_latitude IS 
$$
@introspeql-include
@introspeql-disable-nullable-return-types
$$;

CREATE FUNCTION get_longitude (point GEOGRAPHY (POINT, 4326)) RETURNS DOUBLE PRECISION AS $$
  BEGIN 
    RETURN ST_X(point::geometry);
  END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION get_longitude IS
$$
@introspeql-include
@introspeql-disable-nullable-return-types
$$;

-- migrate:down
DROP FUNCTION get_longitude;
DROP FUNCTION get_latitude;
DROP FUNCTION calc_distance_with_units;
DROP FUNCTION convert_distance;
DROP FUNCTION make_geographic_point;