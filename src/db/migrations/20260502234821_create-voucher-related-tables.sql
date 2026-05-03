-- migrate:up
CREATE TABLE base_voucher (
	redeemable_until TIMESTAMPTZ,
	CONSTRAINT disallow_insert CHECK (false) NO INHERIT
) INHERITS (base_entity);

COMMENT ON TABLE base_voucher IS '@introspeql-include';

CREATE TABLE single_use_voucher (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	reward_id UUID NOT NULL REFERENCES reward(id) ON DELETE CASCADE,
	CONSTRAINT validate_reward_voucher_type CHECK (
		reward_voucher_type_matches(reward_id, 'SINGLE_USE')
	)
) INHERITS (base_voucher);

COMMENT ON TABLE single_use_voucher IS '@introspeql-include';

CREATE TRIGGER single_use_voucher_update_trigger
BEFORE UPDATE ON single_use_voucher
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX single_use_voucher_reward_id_redeemable_until_idx
ON single_use_voucher(reward_id, redeemable_until);

CREATE TABLE multiple_use_voucher (
	id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	reward_id UUID UNIQUE NOT NULL REFERENCES reward(id) ON DELETE CASCADE,
	has_usage_cap BOOLEAN NOT NULL,
	CONSTRAINT validate_reward_voucher_type CHECK (
		reward_voucher_type_matches(reward_id, 'MULTIPLE_USE')
	)
) INHERITS (base_voucher);

COMMENT ON TABLE multiple_use_voucher IS '@introspeql-include';

CREATE TRIGGER multiple_use_voucher_update_trigger
BEFORE UPDATE ON multiple_use_voucher
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE code_based_voucher_value (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	single_use_voucher_id BIGINT UNIQUE NULLS DISTINCT REFERENCES single_use_voucher(id) ON DELETE CASCADE,
	multiple_use_voucher_id INT UNIQUE NULLS DISTINCT REFERENCES multiple_use_voucher(id) ON DELETE CASCADE,
	redemption_code TEXT NOT NULL,
	CONSTRAINT disallow_references_to_multiple_vouchers CHECK (num_nonnulls(
		multiple_use_voucher_id,
		single_use_voucher_id
	) = 1)
) INHERITS (base_entity);

COMMENT ON TABLE code_based_voucher_value IS '@introspeql-include';

CREATE TRIGGER code_based_voucher_value_update_trigger
BEFORE UPDATE ON code_based_voucher_value
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE code_based_voucher_value_details_translation (
	code_based_voucher_value_id BIGINT REFERENCES code_based_voucher_value(id) ON DELETE CASCADE,
	language_tag TEXT REFERENCES language(language_tag) ON DELETE RESTRICT,
	instructions TEXT NOT NULL,
	PRIMARY KEY (code_based_voucher_value_id, language_tag)
) INHERITS (base_entity);

COMMENT ON TABLE code_based_voucher_value_details_translation IS '@introspeql-include';

CREATE TRIGGER code_based_voucher_value_details_translation_update_trigger
BEFORE UPDATE ON code_based_voucher_value_details_translation
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE qr_code_based_voucher_value (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	single_use_voucher_id BIGINT UNIQUE NULLS DISTINCT REFERENCES single_use_voucher(id) ON DELETE CASCADE,
	multiple_use_voucher_id INT UNIQUE NULLS DISTINCT REFERENCES multiple_use_voucher(id) ON DELETE CASCADE,
	redemption_qr_code TEXT NOT NULL,
	CONSTRAINT disallow_references_to_multiple_vouchers CHECK (num_nonnulls(
		multiple_use_voucher_id,
		single_use_voucher_id
	) = 1)
) INHERITS (base_entity);

COMMENT ON TABLE qr_code_based_voucher_value IS '@introspeql-include';

CREATE TRIGGER qr_code_based_voucher_value_update_trigger
BEFORE UPDATE ON qr_code_based_voucher_value
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE qr_code_based_voucher_value_details_translation (
	qr_code_based_voucher_value_id BIGINT REFERENCES qr_code_based_voucher_value(id) ON DELETE CASCADE,
	language_tag TEXT REFERENCES language(language_tag) ON DELETE RESTRICT,
	instructions TEXT NOT NULL,
	PRIMARY KEY (qr_code_based_voucher_value_id, language_tag)
) INHERITS (base_entity);

COMMENT ON TABLE qr_code_based_voucher_value_details_translation IS '@introspeql-include';

CREATE TRIGGER qr_code_based_voucher_value_details_translation_update_trigger
BEFORE UPDATE ON qr_code_based_voucher_value_details_translation
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE link_based_voucher_value (
	id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
	single_use_voucher_id BIGINT UNIQUE NULLS DISTINCT REFERENCES single_use_voucher(id) ON DELETE CASCADE,
	multiple_use_voucher_id INT UNIQUE NULLS DISTINCT REFERENCES multiple_use_voucher(id) ON DELETE CASCADE,
	CONSTRAINT disallow_references_to_multiple_vouchers CHECK (num_nonnulls(
		multiple_use_voucher_id,
		single_use_voucher_id
	) = 1)
) INHERITS (base_entity);

COMMENT ON TABLE link_based_voucher_value IS '@introspeql-include';

CREATE TRIGGER link_based_voucher_value_update_trigger
BEFORE UPDATE ON link_based_voucher_value
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE link_based_voucher_value_details_translation (
	link_based_voucher_value_id BIGINT REFERENCES link_based_voucher_value(id) ON DELETE CASCADE,
	language_tag TEXT REFERENCES language(language_tag) ON DELETE RESTRICT,
	instructions TEXT NOT NULL,
	redemption_link_url TEXT NOT NULL,
	redemption_link_text TEXT,
	PRIMARY KEY (link_based_voucher_value_id, language_tag)
) INHERITS (base_entity);

COMMENT ON TABLE link_based_voucher_value_details_translation IS '@introspeql-include';

CREATE TRIGGER link_based_voucher_value_details_translation_update_trigger
BEFORE UPDATE ON link_based_voucher_value_details_translation
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE valid_single_use_voucher (
	LIKE single_use_voucher INCLUDING ALL
);

COMMENT ON TABLE valid_single_use_voucher IS '@introspeql-include';

CREATE TABLE valid_multiple_use_voucher (
	LIKE multiple_use_voucher INCLUDING ALL
);

COMMENT ON TABLE valid_multiple_use_voucher IS '@introspeql-include';

CREATE FUNCTION is_valid_single_use_voucher(single_use_voucher_id BIGINT)
RETURNS BOOLEAN AS $$
BEGIN
	RETURN EXISTS (
		SELECT 1
		FROM single_use_voucher v
		WHERE v.id = is_valid_single_use_voucher.single_use_voucher_id
			AND (
				EXISTS (
					SELECT 1 FROM code_based_voucher_value cv
					WHERE cv.single_use_voucher_id = v.id
				) OR EXISTS (
					SELECT 1 FROM qr_code_based_voucher_value qv
					WHERE qv.single_use_voucher_id = v.id
				) OR EXISTS (
					SELECT 1 FROM link_based_voucher_value lv
					WHERE lv.single_use_voucher_id = v.id
				)
			)
			AND (
				NOT EXISTS (
					SELECT 1 FROM code_based_voucher_value cv
					WHERE cv.single_use_voucher_id = v.id
				)
				OR EXISTS (
					SELECT cv.id
					FROM code_based_voucher_value cv
					WHERE cv.single_use_voucher_id = v.id
						AND NOT EXISTS (
							(
								SELECT l.language_tag
								FROM language l
							)
							EXCEPT
							(
								SELECT cvd.language_tag
								FROM code_based_voucher_value_details_translation cvd
								WHERE cvd.code_based_voucher_value_id = cv.id
							)
						)
				)
			)
			AND (
				NOT EXISTS (
					SELECT 1 FROM qr_code_based_voucher_value qv
					WHERE qv.single_use_voucher_id = v.id
				)
				OR EXISTS (
					SELECT qv.id
					FROM qr_code_based_voucher_value qv
					WHERE qv.single_use_voucher_id = v.id
						AND NOT EXISTS (
							(
								SELECT l.language_tag
								FROM language l
							)
							EXCEPT
							(
								SELECT qvd.language_tag
								FROM qr_code_based_voucher_value_details_translation qvd
								WHERE qvd.qr_code_based_voucher_value_id = qv.id
							)
						)
				)
			)
			AND (
				NOT EXISTS (
					SELECT 1 FROM link_based_voucher_value lv
					WHERE lv.single_use_voucher_id = v.id
				)
				OR EXISTS (
					SELECT lv.id
					FROM link_based_voucher_value lv
					WHERE lv.single_use_voucher_id = v.id
						AND NOT EXISTS (
							(
								SELECT l.language_tag
								FROM language l
							)
							EXCEPT
							(
								SELECT lvd.language_tag
								FROM link_based_voucher_value_details_translation lvd
								WHERE lvd.link_based_voucher_value_id = lv.id
							)
						)
				)
			)
	);
END;
$$ LANGUAGE plpgsql STABLE;

CREATE FUNCTION is_valid_multiple_use_voucher(multiple_use_voucher_id INT)
RETURNS BOOLEAN AS $$
BEGIN
	RETURN EXISTS (
		SELECT 1
		FROM multiple_use_voucher v
		WHERE v.id = is_valid_multiple_use_voucher.multiple_use_voucher_id
			AND (
				EXISTS (
					SELECT 1 FROM code_based_voucher_value cv
					WHERE cv.multiple_use_voucher_id = v.id
				) OR EXISTS (
					SELECT 1 FROM qr_code_based_voucher_value qv
					WHERE qv.multiple_use_voucher_id = v.id
				) OR EXISTS (
					SELECT 1 FROM link_based_voucher_value lv
					WHERE lv.multiple_use_voucher_id = v.id
				)
			)
			AND (
				NOT EXISTS (
					SELECT 1 FROM code_based_voucher_value cv
					WHERE cv.multiple_use_voucher_id = v.id
				)
				OR EXISTS (
					SELECT cv.id
					FROM code_based_voucher_value cv
					WHERE cv.multiple_use_voucher_id = v.id
						AND NOT EXISTS (
							(
								SELECT l.language_tag
								FROM language l
							)
							EXCEPT
							(
								SELECT cvd.language_tag
								FROM code_based_voucher_value_details_translation cvd
								WHERE cvd.code_based_voucher_value_id = cv.id
							)
						)
				)
			)
			AND (
				NOT EXISTS (
					SELECT 1 FROM qr_code_based_voucher_value qv
					WHERE qv.multiple_use_voucher_id = v.id
				)
				OR EXISTS (
					SELECT qv.id
					FROM qr_code_based_voucher_value qv
					WHERE qv.multiple_use_voucher_id = v.id
						AND NOT EXISTS (
							(
								SELECT l.language_tag
								FROM language l
							)
							EXCEPT
							(
								SELECT qvd.language_tag
								FROM qr_code_based_voucher_value_details_translation qvd
								WHERE qvd.qr_code_based_voucher_value_id = qv.id
							)
						)
				)
			)
			AND (
				NOT EXISTS (
					SELECT 1 FROM link_based_voucher_value lv
					WHERE lv.multiple_use_voucher_id = v.id
				)
				OR EXISTS (
					SELECT lv.id
					FROM link_based_voucher_value lv
					WHERE lv.multiple_use_voucher_id = v.id
						AND NOT EXISTS (
							(
								SELECT l.language_tag
								FROM language l
							)
							EXCEPT
							(
								SELECT lvd.language_tag
								FROM link_based_voucher_value_details_translation lvd
								WHERE lvd.link_based_voucher_value_id = lv.id
							)
						)
				)
			)
	);
END;
$$ LANGUAGE plpgsql STABLE;

CREATE FUNCTION refresh_valid_single_use_voucher_table_for_voucher(single_use_voucher_id BIGINT)
RETURNS VOID AS $$
BEGIN
	DELETE FROM valid_single_use_voucher vsv
	WHERE vsv.id = refresh_valid_single_use_voucher_table_for_voucher.single_use_voucher_id;

	INSERT INTO valid_single_use_voucher
	OVERRIDING SYSTEM VALUE
	SELECT v.*
	FROM single_use_voucher v
	WHERE v.id = refresh_valid_single_use_voucher_table_for_voucher.single_use_voucher_id
		AND is_valid_single_use_voucher(
			refresh_valid_single_use_voucher_table_for_voucher.single_use_voucher_id
		);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION refresh_valid_multiple_use_voucher_table_for_voucher(multiple_use_voucher_id INT)
RETURNS VOID AS $$
BEGIN
	DELETE FROM valid_multiple_use_voucher vmv
	WHERE vmv.id = refresh_valid_multiple_use_voucher_table_for_voucher.multiple_use_voucher_id;

	INSERT INTO valid_multiple_use_voucher
	OVERRIDING SYSTEM VALUE
	SELECT v.*
	FROM multiple_use_voucher v
	WHERE v.id = refresh_valid_multiple_use_voucher_table_for_voucher.multiple_use_voucher_id
		AND is_valid_multiple_use_voucher(
			refresh_valid_multiple_use_voucher_table_for_voucher.multiple_use_voucher_id
		);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION refresh_valid_single_use_voucher_table()
RETURNS VOID AS $$
BEGIN
	DELETE FROM valid_single_use_voucher;

	INSERT INTO valid_single_use_voucher
	OVERRIDING SYSTEM VALUE
	SELECT v.*
	FROM single_use_voucher v
	WHERE is_valid_single_use_voucher(v.id);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION refresh_valid_multiple_use_voucher_table()
RETURNS VOID AS $$
BEGIN
	DELETE FROM valid_multiple_use_voucher;

	INSERT INTO valid_multiple_use_voucher
	OVERRIDING SYSTEM VALUE
	SELECT v.*
	FROM multiple_use_voucher v
	WHERE is_valid_multiple_use_voucher(v.id);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_single_use_voucher_table_from_single_use_voucher_trigger()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'DELETE' THEN
		DELETE FROM valid_single_use_voucher vsv WHERE vsv.id = OLD.id;
		RETURN OLD;
	END IF;

	IF TG_OP = 'UPDATE' AND OLD.id <> NEW.id THEN
		DELETE FROM valid_single_use_voucher vsv WHERE vsv.id = OLD.id;
	END IF;

	PERFORM refresh_valid_single_use_voucher_table_for_voucher(NEW.id);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_multiple_use_voucher_table_from_multiple_use_voucher_trigger()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'DELETE' THEN
		DELETE FROM valid_multiple_use_voucher vmv WHERE vmv.id = OLD.id;
		RETURN OLD;
	END IF;

	IF TG_OP = 'UPDATE' AND OLD.id <> NEW.id THEN
		DELETE FROM valid_multiple_use_voucher vmv WHERE vmv.id = OLD.id;
	END IF;

	PERFORM refresh_valid_multiple_use_voucher_table_for_voucher(NEW.id);
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_voucher_tables_from_value_trigger()
RETURNS TRIGGER AS $$
BEGIN
	IF TG_OP = 'DELETE' THEN
		IF OLD.single_use_voucher_id IS NOT NULL THEN
			PERFORM refresh_valid_single_use_voucher_table_for_voucher(OLD.single_use_voucher_id);
		END IF;

		IF OLD.multiple_use_voucher_id IS NOT NULL THEN
			PERFORM refresh_valid_multiple_use_voucher_table_for_voucher(OLD.multiple_use_voucher_id);
		END IF;

		RETURN OLD;
	END IF;

	IF NEW.single_use_voucher_id IS NOT NULL THEN
		PERFORM refresh_valid_single_use_voucher_table_for_voucher(NEW.single_use_voucher_id);
	END IF;

	IF NEW.multiple_use_voucher_id IS NOT NULL THEN
		PERFORM refresh_valid_multiple_use_voucher_table_for_voucher(NEW.multiple_use_voucher_id);
	END IF;

	IF TG_OP = 'UPDATE' AND OLD.single_use_voucher_id IS DISTINCT FROM NEW.single_use_voucher_id AND OLD.single_use_voucher_id IS NOT NULL THEN
		PERFORM refresh_valid_single_use_voucher_table_for_voucher(OLD.single_use_voucher_id);
	END IF;

	IF TG_OP = 'UPDATE' AND OLD.multiple_use_voucher_id IS DISTINCT FROM NEW.multiple_use_voucher_id AND OLD.multiple_use_voucher_id IS NOT NULL THEN
		PERFORM refresh_valid_multiple_use_voucher_table_for_voucher(OLD.multiple_use_voucher_id);
	END IF;

	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_voucher_tables_from_code_based_voucher_value_details_translation_trigger()
RETURNS TRIGGER AS $$
DECLARE
	lookup_value_id BIGINT;
BEGIN
	lookup_value_id := COALESCE(NEW.code_based_voucher_value_id, OLD.code_based_voucher_value_id);

	IF lookup_value_id IS NOT NULL THEN
		PERFORM refresh_valid_single_use_voucher_table_for_voucher(cv.single_use_voucher_id)
		FROM code_based_voucher_value cv
		WHERE cv.id = lookup_value_id
			AND cv.single_use_voucher_id IS NOT NULL;

		PERFORM refresh_valid_multiple_use_voucher_table_for_voucher(cv.multiple_use_voucher_id)
		FROM code_based_voucher_value cv
		WHERE cv.id = lookup_value_id
			AND cv.multiple_use_voucher_id IS NOT NULL;
	END IF;

	IF TG_OP = 'UPDATE' AND OLD.code_based_voucher_value_id IS DISTINCT FROM NEW.code_based_voucher_value_id AND OLD.code_based_voucher_value_id IS NOT NULL THEN
		PERFORM refresh_valid_single_use_voucher_table_for_voucher(cv.single_use_voucher_id)
		FROM code_based_voucher_value cv
		WHERE cv.id = OLD.code_based_voucher_value_id
			AND cv.single_use_voucher_id IS NOT NULL;

		PERFORM refresh_valid_multiple_use_voucher_table_for_voucher(cv.multiple_use_voucher_id)
		FROM code_based_voucher_value cv
		WHERE cv.id = OLD.code_based_voucher_value_id
			AND cv.multiple_use_voucher_id IS NOT NULL;
	END IF;

	RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_voucher_tables_from_qr_code_based_voucher_value_details_translation_trigger()
RETURNS TRIGGER AS $$
DECLARE
	lookup_value_id BIGINT;
BEGIN
	lookup_value_id := COALESCE(NEW.qr_code_based_voucher_value_id, OLD.qr_code_based_voucher_value_id);

	IF lookup_value_id IS NOT NULL THEN
		PERFORM refresh_valid_single_use_voucher_table_for_voucher(qv.single_use_voucher_id)
		FROM qr_code_based_voucher_value qv
		WHERE qv.id = lookup_value_id
			AND qv.single_use_voucher_id IS NOT NULL;

		PERFORM refresh_valid_multiple_use_voucher_table_for_voucher(qv.multiple_use_voucher_id)
		FROM qr_code_based_voucher_value qv
		WHERE qv.id = lookup_value_id
			AND qv.multiple_use_voucher_id IS NOT NULL;
	END IF;

	IF TG_OP = 'UPDATE' AND OLD.qr_code_based_voucher_value_id IS DISTINCT FROM NEW.qr_code_based_voucher_value_id AND OLD.qr_code_based_voucher_value_id IS NOT NULL THEN
		PERFORM refresh_valid_single_use_voucher_table_for_voucher(qv.single_use_voucher_id)
		FROM qr_code_based_voucher_value qv
		WHERE qv.id = OLD.qr_code_based_voucher_value_id
			AND qv.single_use_voucher_id IS NOT NULL;

		PERFORM refresh_valid_multiple_use_voucher_table_for_voucher(qv.multiple_use_voucher_id)
		FROM qr_code_based_voucher_value qv
		WHERE qv.id = OLD.qr_code_based_voucher_value_id
			AND qv.multiple_use_voucher_id IS NOT NULL;
	END IF;

	RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_voucher_tables_from_link_based_voucher_value_details_translation_trigger()
RETURNS TRIGGER AS $$
DECLARE
	lookup_value_id BIGINT;
BEGIN
	lookup_value_id := COALESCE(NEW.link_based_voucher_value_id, OLD.link_based_voucher_value_id);

	IF lookup_value_id IS NOT NULL THEN
		PERFORM refresh_valid_single_use_voucher_table_for_voucher(lv.single_use_voucher_id)
		FROM link_based_voucher_value lv
		WHERE lv.id = lookup_value_id
			AND lv.single_use_voucher_id IS NOT NULL;

		PERFORM refresh_valid_multiple_use_voucher_table_for_voucher(lv.multiple_use_voucher_id)
		FROM link_based_voucher_value lv
		WHERE lv.id = lookup_value_id
			AND lv.multiple_use_voucher_id IS NOT NULL;
	END IF;

	IF TG_OP = 'UPDATE' AND OLD.link_based_voucher_value_id IS DISTINCT FROM NEW.link_based_voucher_value_id AND OLD.link_based_voucher_value_id IS NOT NULL THEN
		PERFORM refresh_valid_single_use_voucher_table_for_voucher(lv.single_use_voucher_id)
		FROM link_based_voucher_value lv
		WHERE lv.id = OLD.link_based_voucher_value_id
			AND lv.single_use_voucher_id IS NOT NULL;

		PERFORM refresh_valid_multiple_use_voucher_table_for_voucher(lv.multiple_use_voucher_id)
		FROM link_based_voucher_value lv
		WHERE lv.id = OLD.link_based_voucher_value_id
			AND lv.multiple_use_voucher_id IS NOT NULL;
	END IF;

	RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION sync_valid_voucher_tables_from_language_trigger()
RETURNS TRIGGER AS $$
BEGIN
	PERFORM refresh_valid_single_use_voucher_table();
	PERFORM refresh_valid_multiple_use_voucher_table();
	RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER single_use_voucher_valid_single_use_voucher_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON single_use_voucher
FOR EACH ROW EXECUTE FUNCTION sync_valid_single_use_voucher_table_from_single_use_voucher_trigger();

CREATE TRIGGER multiple_use_voucher_valid_multiple_use_voucher_table_trigger
AFTER INSERT OR UPDATE OR DELETE ON multiple_use_voucher
FOR EACH ROW EXECUTE FUNCTION sync_valid_multiple_use_voucher_table_from_multiple_use_voucher_trigger();

CREATE TRIGGER code_based_voucher_value_valid_voucher_tables_trigger
AFTER INSERT OR UPDATE OR DELETE ON code_based_voucher_value
FOR EACH ROW EXECUTE FUNCTION sync_valid_voucher_tables_from_value_trigger();

CREATE TRIGGER qr_code_based_voucher_value_valid_voucher_tables_trigger
AFTER INSERT OR UPDATE OR DELETE ON qr_code_based_voucher_value
FOR EACH ROW EXECUTE FUNCTION sync_valid_voucher_tables_from_value_trigger();

CREATE TRIGGER link_based_voucher_value_valid_voucher_tables_trigger
AFTER INSERT OR UPDATE OR DELETE ON link_based_voucher_value
FOR EACH ROW EXECUTE FUNCTION sync_valid_voucher_tables_from_value_trigger();

CREATE TRIGGER code_based_voucher_value_details_translation_valid_voucher_tables_trigger
AFTER INSERT OR UPDATE OR DELETE ON code_based_voucher_value_details_translation
FOR EACH ROW EXECUTE FUNCTION sync_valid_voucher_tables_from_code_based_voucher_value_details_translation_trigger();

CREATE TRIGGER qr_code_based_voucher_value_details_translation_valid_voucher_tables_trigger
AFTER INSERT OR UPDATE OR DELETE ON qr_code_based_voucher_value_details_translation
FOR EACH ROW EXECUTE FUNCTION sync_valid_voucher_tables_from_qr_code_based_voucher_value_details_translation_trigger();

CREATE TRIGGER link_based_voucher_value_details_translation_valid_voucher_tables_trigger
AFTER INSERT OR UPDATE OR DELETE ON link_based_voucher_value_details_translation
FOR EACH ROW EXECUTE FUNCTION sync_valid_voucher_tables_from_link_based_voucher_value_details_translation_trigger();

CREATE TRIGGER language_valid_voucher_tables_trigger
AFTER INSERT OR UPDATE OR DELETE ON language
FOR EACH STATEMENT EXECUTE FUNCTION sync_valid_voucher_tables_from_language_trigger();

SELECT refresh_valid_single_use_voucher_table();
SELECT refresh_valid_multiple_use_voucher_table();

-- migrate:down
DROP TRIGGER language_valid_voucher_tables_trigger ON language;
DROP TRIGGER link_based_voucher_value_details_translation_valid_voucher_tables_trigger ON link_based_voucher_value_details_translation;
DROP TRIGGER qr_code_based_voucher_value_details_translation_valid_voucher_tables_trigger ON qr_code_based_voucher_value_details_translation;
DROP TRIGGER code_based_voucher_value_details_translation_valid_voucher_tables_trigger ON code_based_voucher_value_details_translation;
DROP TRIGGER link_based_voucher_value_valid_voucher_tables_trigger ON link_based_voucher_value;
DROP TRIGGER qr_code_based_voucher_value_valid_voucher_tables_trigger ON qr_code_based_voucher_value;
DROP TRIGGER code_based_voucher_value_valid_voucher_tables_trigger ON code_based_voucher_value;
DROP TRIGGER multiple_use_voucher_valid_multiple_use_voucher_table_trigger ON multiple_use_voucher;
DROP TRIGGER single_use_voucher_valid_single_use_voucher_table_trigger ON single_use_voucher;

DROP TRIGGER link_based_voucher_value_details_translation_update_trigger ON link_based_voucher_value_details_translation;
DROP TRIGGER link_based_voucher_value_update_trigger ON link_based_voucher_value;
DROP TRIGGER qr_code_based_voucher_value_details_translation_update_trigger ON qr_code_based_voucher_value_details_translation;
DROP TRIGGER qr_code_based_voucher_value_update_trigger ON qr_code_based_voucher_value;
DROP TRIGGER code_based_voucher_value_details_translation_update_trigger ON code_based_voucher_value_details_translation;
DROP TRIGGER code_based_voucher_value_update_trigger ON code_based_voucher_value;
DROP TRIGGER multiple_use_voucher_update_trigger ON multiple_use_voucher;
DROP TRIGGER single_use_voucher_update_trigger ON single_use_voucher;

DROP FUNCTION sync_valid_voucher_tables_from_language_trigger();
DROP FUNCTION sync_valid_voucher_tables_from_link_based_voucher_value_details_translation_trigger();
DROP FUNCTION sync_valid_voucher_tables_from_qr_code_based_voucher_value_details_translation_trigger();
DROP FUNCTION sync_valid_voucher_tables_from_code_based_voucher_value_details_translation_trigger();
DROP FUNCTION sync_valid_voucher_tables_from_value_trigger();
DROP FUNCTION sync_valid_multiple_use_voucher_table_from_multiple_use_voucher_trigger();
DROP FUNCTION sync_valid_single_use_voucher_table_from_single_use_voucher_trigger();
DROP FUNCTION refresh_valid_multiple_use_voucher_table();
DROP FUNCTION refresh_valid_single_use_voucher_table();
DROP FUNCTION refresh_valid_multiple_use_voucher_table_for_voucher(INT);
DROP FUNCTION refresh_valid_single_use_voucher_table_for_voucher(BIGINT);
DROP FUNCTION is_valid_multiple_use_voucher(INT);
DROP FUNCTION is_valid_single_use_voucher(BIGINT);

DROP TABLE valid_multiple_use_voucher;
DROP TABLE valid_single_use_voucher;
DROP TABLE link_based_voucher_value_details_translation;
DROP TABLE link_based_voucher_value;
DROP TABLE qr_code_based_voucher_value_details_translation;
DROP TABLE qr_code_based_voucher_value;
DROP TABLE code_based_voucher_value_details_translation;
DROP TABLE code_based_voucher_value;
DROP TABLE multiple_use_voucher;
DROP TABLE single_use_voucher;
DROP TABLE base_voucher;

