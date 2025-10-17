CREATE OR REPLACE FUNCTION "dbo"."Adm_Sourcewiseadmissioncount1"(
    p_MI_ID TEXT,
    p_ASMAY_ID TEXT,
    p_ASMCL_ID TEXT
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "PAMR_ReferenceName" VARCHAR,
    "Studentcount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dynamic TEXT;
BEGIN

    v_dynamic := 'SELECT "ASMAY"."ASMAY_Year", "ASMC"."ASMCL_ClassName", "PMR"."PAMR_ReferenceName", COALESCE(COUNT(DISTINCT "ASYS"."AMST_Id"), 0) AS "Studentcount"
    FROM "dbo"."Adm_M_Student" "AMS"
    INNER JOIN "dbo"."Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ASYS"."ASMAY_Id" AND "ASMAY"."MI_Id" = "AMS"."MI_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id" AND "ASMC"."MI_Id" = "AMS"."MI_Id"
    INNER JOIN "dbo"."Adm_M_Student_Reference" "AMSR" ON "AMSR"."AMST_Id" = "ASYS"."AMST_Id" AND "AMSR"."MI_Id" = "ASMAY"."MI_Id"
    INNER JOIN "dbo"."Preadmission_Master_Reference" "PMR" ON "PMR"."PAMR_Id" = "AMSR"."PAMR_Id"
    WHERE "ASYS"."ASMAY_ID" IN (' || p_ASMAY_ID || ') AND "AMS"."MI_Id" = ' || p_MI_ID || ' AND "ASYS"."ASMCL_ID" IN (' || p_ASMCL_ID || ')
    GROUP BY "ASMAY"."ASMAY_Year", "ASMC"."ASMCL_ClassName", "PMR"."PAMR_ReferenceName"';

    RETURN QUERY EXECUTE v_dynamic;

END;
$$;