-- migrate:up
CREATE TABLE base_voucher_stub (
	redeemable_until_exact TIMESTAMPTZ,
	redeemable_until_local TIMESTAMP,
	redeemable_for INTERVAL,
	vouchers_remaining INT,
	CONSTRAINT voucher_stub_uses_a_single_redeemable_until_mode CHECK (
		redeemable_until_exact IS NULL
		OR redeemable_until_local IS NULL
	),
	CONSTRAINT disallow_insert CHECK (false) NO INHERIT
) INHERITS (base_entity);

COMMENT ON TABLE base_voucher_stub IS '@introspeql-include';

CREATE TABLE on_demand_voucher_stub (
	id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	reward_id UUID NOT NULL UNIQUE REFERENCES reward(id) ON DELETE CASCADE,
	CONSTRAINT validate_reward_voucher_type CHECK (
		reward_voucher_type_matches(reward_id, 'ON_DEMAND')
	)
) INHERITS (base_voucher_stub);

COMMENT ON TABLE on_demand_voucher_stub IS '@introspeql-include';

CREATE TRIGGER on_demand_voucher_stub_update_trigger
BEFORE UPDATE ON on_demand_voucher_stub
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE manual_voucher_stub (
	id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	reward_id UUID NOT NULL UNIQUE REFERENCES reward(id) ON DELETE CASCADE,
	CONSTRAINT validate_reward_voucher_type CHECK (
		reward_voucher_type_matches(reward_id, 'MANUAL')
	)
) INHERITS (base_voucher_stub);

COMMENT ON TABLE manual_voucher_stub IS '@introspeql-include';

CREATE TRIGGER manual_voucher_stub_update_trigger
BEFORE UPDATE ON manual_voucher_stub
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE manual_voucher_stub_details_translation (
	manual_voucher_stub_id INT REFERENCES manual_voucher_stub(id) ON DELETE CASCADE,
	language_tag TEXT REFERENCES language(language_tag) ON DELETE RESTRICT,
	instructions TEXT NOT NULL,
	PRIMARY KEY (manual_voucher_stub_id, language_tag)
) INHERITS (base_entity);

COMMENT ON TABLE manual_voucher_stub_details_translation IS '@introspeql-include';

CREATE TRIGGER manual_voucher_stub_details_translation_update_trigger
BEFORE UPDATE ON manual_voucher_stub_details_translation
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE valid_manual_voucher_stub (
	LIKE manual_voucher_stub INCLUDING ALL
);

COMMENT ON TABLE valid_manual_voucher_stub IS '@introspeql-include';

CREATE FUNCTION is_valid_manual_voucher_stub(manual_voucher_stub_id INT)
RETURNS BOOLEAN AS $$
BEGIN
	RETURN EXISTS (
		SELECT 1
		FROM manual_voucher_stub s
		WHERE s.id = is_valid_manual_voucher_stub.manual_voucher_stub_id
			AND NOT EXISTS (
				(
					SELECT l.language_tag
					FROM language l
				)
				EXCEPT
				(
					SELECT sd.language_tag
					FROM manual_voucher_stub_details_translation sd
					WHERE sd.manual_voucher_stub_id = s.id
				)
			)
	);
END;
$$ LANGUAGE plpgsql STABLE;

CREATE FUNCTION refresh_valid_manual_voucher_stub_table_for_stub(manual_voucher_stub_id INT)
RETURNS VOID AS $$
BEGIN
	DELETE FROM valid_manual_voucher_stub vms
	WHERE vms.id = refresh_valid_manual_voucher_stub_table_for_stub.manual_voucher_stub_id;

	INSERT INTO valid_manual_voucher_stub
	OVERRIDING SYSTEM VALUE
	SELECT s.*
	FROM manual_voucher_stub s
	WHERE s.id = refresh_valid_manual_voucher_stub_table_for_stub.manual_voucher_stub_id
		AND is_valid_manual_voucher_stub(
			refresh_valid_manual_voucher_stub_table_for_stub.manual_voucher_stub_id
		);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION refresh_valid_manual_voucher_stub_table()
RETURNS VOID AS $$
BEGIN
	DELETE FROM valid_manual_voucher_stub;

	INSERT INTO valid_manual_voucher_stub
	OVERRIDING SYSTEM VALUE
	SELECT s.*
	FROM manual_voucher_stub s
	WHERE is_valid_manual_voucher_stub(s.id);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_manual_voucher_stub_table_from_manual_voucher_stub_trigger()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'DELETE' THEN
		DELETE FROM valid_manual_voucher_stub vms WHERE vms.id = OLD.id;
		RETURN OLD;
	END IF;

	IF TG_OP = 'UPDATE' AND OLD.id <> NEW.id THEN
		DELETE FROM valid_manual_voucher_stub vms WHERE vms.id = OLD.id;
	END IF;

	PERFORM refresh_valid_manual_voucher_stub_table_for_stub(NEW.id);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_manual_voucher_stub_table_from_details_translation_trigger()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'DELETE' THEN
		PERFORM refresh_valid_manual_voucher_stub_table_for_stub(OLD.manual_voucher_stub_id);
		RETURN OLD;
	END IF;

	PERFORM refresh_valid_manual_voucher_stub_table_for_stub(NEW.manual_voucher_stub_id);

	IF TG_OP = 'UPDATE' AND OLD.manual_voucher_stub_id <> NEW.manual_voucher_stub_id THEN
		PERFORM refresh_valid_manual_voucher_stub_table_for_stub(OLD.manual_voucher_stub_id);
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_manual_voucher_stub_table_from_language_trigger()
RETURNS TRIGGER AS $$
BEGIN
	PERFORM refresh_valid_manual_voucher_stub_table();
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER manual_voucher_stub_valid_manual_voucher_stub_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON manual_voucher_stub
FOR EACH ROW EXECUTE FUNCTION sync_valid_manual_voucher_stub_table_from_manual_voucher_stub_trigger();

CREATE TRIGGER manual_voucher_stub_details_translation_valid_manual_voucher_stub_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON manual_voucher_stub_details_translation
FOR EACH ROW EXECUTE FUNCTION sync_valid_manual_voucher_stub_table_from_details_translation_trigger();

CREATE TRIGGER language_valid_manual_voucher_stub_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON language
FOR EACH STATEMENT EXECUTE FUNCTION sync_valid_manual_voucher_stub_table_from_language_trigger();

SELECT refresh_valid_manual_voucher_stub_table();

-- migrate:down
DROP TRIGGER language_valid_manual_voucher_stub_table_trigger ON language;
DROP TRIGGER manual_voucher_stub_details_translation_valid_manual_voucher_stub_table_trigger ON manual_voucher_stub_details_translation;
DROP TRIGGER manual_voucher_stub_valid_manual_voucher_stub_table_trigger ON manual_voucher_stub;

DROP TRIGGER manual_voucher_stub_details_translation_update_trigger ON manual_voucher_stub_details_translation;
DROP TRIGGER manual_voucher_stub_update_trigger ON manual_voucher_stub;
DROP TRIGGER on_demand_voucher_stub_update_trigger ON on_demand_voucher_stub;

DROP FUNCTION sync_valid_manual_voucher_stub_table_from_language_trigger();
DROP FUNCTION sync_valid_manual_voucher_stub_table_from_details_translation_trigger();
DROP FUNCTION sync_valid_manual_voucher_stub_table_from_manual_voucher_stub_trigger();
DROP FUNCTION refresh_valid_manual_voucher_stub_table();
DROP FUNCTION refresh_valid_manual_voucher_stub_table_for_stub(INT);
DROP FUNCTION is_valid_manual_voucher_stub(INT);

DROP TABLE valid_manual_voucher_stub;
DROP TABLE manual_voucher_stub_details_translation;
DROP TABLE manual_voucher_stub;
DROP TABLE on_demand_voucher_stub;
DROP TABLE base_voucher_stub;

