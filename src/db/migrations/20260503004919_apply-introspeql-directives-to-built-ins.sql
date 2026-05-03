-- migrate:up
COMMENT ON FUNCTION public.st_dwithin(
  GEOGRAPHY,
  GEOGRAPHY,
  DOUBLE PRECISION,
  BOOLEAN
) IS 
$$
@introspeql-include
@introspeql-disable-nullable-return-types
$$;

COMMENT ON FUNCTION jsonb_build_object(VARIADIC "any") IS
$$
@introspeql-include
@introspeql-disable-nullable-return-types
$$;

-- migrate:down
COMMENT ON FUNCTION jsonb_build_object(VARIADIC "any") IS NULL;

COMMENT ON FUNCTION public.st_dwithin(
  GEOGRAPHY,
  GEOGRAPHY,
  DOUBLE PRECISION,
  BOOLEAN
) IS NULL;