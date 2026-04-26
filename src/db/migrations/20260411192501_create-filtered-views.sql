-- migrate:up
CREATE VIEW v_valid_single_use_voucher AS 
SELECT v.*
FROM single_use_voucher v
-- The voucher must at have at least one value
WHERE (
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
-- All values that exist must have translations in all supported languages
AND (
  -- Either no code-based voucher value exists...
  NOT EXISTS (
    SELECT 1 FROM code_based_voucher_value cv
    WHERE cv.single_use_voucher_id = v.id
  ) 
  -- ...or it must have translated details in all supported languages
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
  -- Either no qr-based voucher value exists...
  NOT EXISTS (
    SELECT 1 FROM qr_code_based_voucher_value qv
    WHERE qv.single_use_voucher_id = v.id
  ) 
  -- ...or it must have translated details in all supported languages
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
  -- Either no link-based voucher value exists...
  NOT EXISTS (
    SELECT 1 FROM link_based_voucher_value lv
    WHERE lv.single_use_voucher_id = v.id
  ) 
  -- ...or it must have translated details in all supported languages
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
);

COMMENT ON VIEW v_valid_single_use_voucher IS 
$$
@introspeql-include

A view that includes only single-use vouchers that meet the following 
conditions:

- The voucher must have at minimum one code-based-, qr-code-based-, or 
  link-based-value 
- All values for the voucher must have translated details in all supported languages
$$;

CREATE VIEW v_valid_multiple_use_voucher AS 
SELECT v.*
FROM multiple_use_voucher v
-- The voucher must at have at least one value
WHERE (
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
-- All values that exist must have translations in all supported languages
AND (
  -- Either no code-based voucher value exists...
  NOT EXISTS (
    SELECT 1 FROM code_based_voucher_value cv
    WHERE cv.multiple_use_voucher_id = v.id
  ) 
  -- ...or it must have translated details in all supported languages
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
  -- Either no qr-based voucher value exists...
  NOT EXISTS (
    SELECT 1 FROM qr_code_based_voucher_value qv
    WHERE qv.multiple_use_voucher_id = v.id
  ) 
  -- ...or it must have translated details in all supported languages
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
  -- Either no link-based voucher value exists...
  NOT EXISTS (
    SELECT 1 FROM link_based_voucher_value lv
    WHERE lv.multiple_use_voucher_id = v.id
  ) 
  -- ...or it must have translated details in all supported languages
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
);

COMMENT ON VIEW v_valid_multiple_use_voucher IS 
$$
@introspeql-include

A view that includes only multiple-use vouchers that meet the following 
conditions:

- The voucher must have at minimum one code-based-, qr-code-based-, or 
  link-based-value 
- All values for the voucher must have translated details in all supported languages
$$;

CREATE VIEW v_valid_manual_voucher_stub AS 
SELECT s.*
FROM manual_voucher_stub s 
WHERE NOT EXISTS (
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
);

COMMENT ON VIEW v_valid_manual_voucher_stub IS 
$$
@introspeql-include

A view that includes only manual voucher stubs that meet the following 
conditions:

- The voucher stub must have translated details in all supported languages
$$;

-- migrate:down
DROP VIEW v_valid_manual_voucher_stub;
DROP VIEW v_valid_multiple_use_voucher;
DROP VIEW v_valid_single_use_voucher;