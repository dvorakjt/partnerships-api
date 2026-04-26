-- migrate:up
CREATE TABLE location (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  partner_id INT NOT NULL REFERENCES partner(id) ON DELETE CASCADE,
  coordinates GEOGRAPHY(POINT, 4326) NOT NULL,
  UNIQUE (partner_id, coordinates)
) INHERITS (base_entity);

COMMENT ON TABLE location IS '@introspeql-include';

CREATE TRIGGER location_update_trigger 
BEFORE UPDATE ON location
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX location_partner_id_idx
ON location(partner_id);

CREATE TABLE active_partner_location (
  LIKE location INCLUDING ALL
);

COMMENT ON TABLE active_partner_location IS '@introspeql-include';

/*
  This index can be used by the query planner when geospatial functions 
  (like ST_DWithin) and operators (<->) are used to filter results (with or 
  without also filtering by partner id).

  Order matters here. When querying for locations belonging to a specific 
  partner (as is common in our API), specifying partner_id first here 
  contributes to faster queries when large numbers of locations are present 
  in the database.
*/
CREATE INDEX active_partner_location_partner_id_coordinates_idx 
ON active_partner_location USING GIST(partner_id, coordinates);

CREATE FUNCTION refresh_active_partner_location_table_for_location(
  location_id BIGINT
)
RETURNS VOID AS $$
BEGIN
  DELETE FROM active_partner_location apl
  WHERE apl.id = refresh_active_partner_location_table_for_location.location_id;

  INSERT INTO active_partner_location
  OVERRIDING SYSTEM VALUE
  SELECT l.*
  FROM location l
  INNER JOIN active_partner ap ON ap.id = l.partner_id
  WHERE l.id = refresh_active_partner_location_table_for_location.location_id;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION refresh_active_partner_location_table_for_partner(
  partner_id INT
)
RETURNS VOID AS $$
BEGIN
  DELETE FROM active_partner_location apl
  WHERE apl.partner_id = refresh_active_partner_location_table_for_partner.partner_id;

  INSERT INTO active_partner_location
  OVERRIDING SYSTEM VALUE
  SELECT l.*
  FROM location l
  INNER JOIN active_partner ap ON ap.id = l.partner_id
  WHERE l.partner_id = refresh_active_partner_location_table_for_partner.partner_id;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION refresh_active_partner_location_table()
RETURNS VOID AS $$
BEGIN
  DELETE FROM active_partner_location;

  INSERT INTO active_partner_location
  OVERRIDING SYSTEM VALUE
  SELECT l.*
  FROM location l
  INNER JOIN active_partner ap ON ap.id = l.partner_id;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_active_partner_location_table_from_location_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    DELETE FROM active_partner_location apl WHERE apl.id = OLD.id;
    RETURN OLD;
  END IF;

  IF TG_OP = 'UPDATE' THEN
    IF OLD.id <> NEW.id THEN
      DELETE FROM active_partner_location apl WHERE apl.id = OLD.id;
      PERFORM refresh_active_partner_location_table_for_location(NEW.id);
      RETURN NEW;
    END IF;

    IF OLD.partner_id <> NEW.partner_id THEN
      PERFORM refresh_active_partner_location_table_for_partner(OLD.partner_id);
      PERFORM refresh_active_partner_location_table_for_partner(NEW.partner_id);
      RETURN NEW;
    END IF;
  END IF;

  PERFORM refresh_active_partner_location_table_for_location(NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_active_partner_location_table_from_active_partner_trigger()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    DELETE FROM active_partner_location apl
    WHERE apl.partner_id = OLD.id;
    RETURN OLD;
  END IF;

  PERFORM refresh_active_partner_location_table_for_partner(NEW.id);

  IF TG_OP = 'UPDATE' AND OLD.id <> NEW.id THEN
    PERFORM refresh_active_partner_location_table_for_partner(OLD.id);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER location_active_partner_location_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON location
FOR EACH ROW EXECUTE FUNCTION sync_active_partner_location_table_from_location_trigger();

CREATE TRIGGER active_partner_active_partner_location_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON active_partner
FOR EACH ROW EXECUTE FUNCTION sync_active_partner_location_table_from_active_partner_trigger();

SELECT refresh_active_partner_location_table();

-- migrate:down
DROP TRIGGER active_partner_active_partner_location_table_trigger ON active_partner;
DROP TRIGGER location_active_partner_location_table_trigger ON location;

DROP FUNCTION sync_active_partner_location_table_from_active_partner_trigger;
DROP FUNCTION sync_active_partner_location_table_from_location_trigger;
DROP FUNCTION refresh_active_partner_location_table;
DROP FUNCTION refresh_active_partner_location_table_for_partner;
DROP FUNCTION refresh_active_partner_location_table_for_location;

DROP TABLE active_partner_location;

DROP INDEX location_partner_id_idx;
DROP TABLE location;
