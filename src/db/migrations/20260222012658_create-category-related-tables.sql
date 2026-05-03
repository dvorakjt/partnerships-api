-- migrate:up
CREATE TABLE category (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY
) INHERITS (base_entity);

COMMENT ON TABLE category IS '@introspeql-include';

CREATE TRIGGER category_update_trigger
BEFORE UPDATE ON category
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE category_translation (
  category_id INT NOT NULL REFERENCES category(id) ON DELETE CASCADE,
  language_tag TEXT NOT NULL REFERENCES language(language_tag) ON DELETE RESTRICT,
  category_name TEXT NOT NULL,
  PRIMARY KEY(category_id, language_tag)
) INHERITS (base_entity);

/* 
  This can, in theory, speed up searching for rewards belonging to a category
  with a specific name.
*/
CREATE UNIQUE INDEX category_translation_language_tag_name_idx 
ON category_translation(language_tag, category_name);

COMMENT ON TABLE category_translation IS '@introspeql-include';

CREATE TRIGGER category_translation_update_trigger
BEFORE UPDATE ON category_translation
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- migrate:down
DROP TABLE category_translation;
DROP TABLE category;
