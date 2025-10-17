CREATE OR REPLACE FUNCTION "dbo"."coe_data"(
    p_year bigint,
    p_month bigint,
    p_MI_Id bigint
)
RETURNS TABLE(
    "eventName" VARCHAR,
    "eventDesc" VARCHAR,
    "coeE_EStartDate" TIMESTAMP,
    "coeE_EEndDate" TIMESTAMP,
    "COEE_ActiveFlag" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "a"."COEME_EventName" AS "eventName",
        "a"."COEME_EventDesc" AS "eventDesc",
        "b"."COEE_EStartDate" AS "coeE_EStartDate",
        "b"."COEE_EEndDate" AS "coeE_EEndDate",
        "b"."COEE_ActiveFlag"
    FROM "coe"."COE_Master_Events" "a"
    INNER JOIN "coe"."COE_Events" "b" ON "a"."COEME_Id" = "b"."COEME_Id"
    WHERE "a"."MI_Id" = p_MI_Id
        AND "b"."ASMAY_Id" = p_year
        AND EXTRACT(MONTH FROM "b"."COEE_EStartDate") = p_month
        AND "b"."COEE_ActiveFlag" = 1;
END;
$$;