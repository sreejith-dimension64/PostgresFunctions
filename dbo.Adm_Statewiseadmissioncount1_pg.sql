CREATE OR REPLACE FUNCTION "dbo"."Adm_Statewiseadmissioncount1"(
    p_MI_ID TEXT,
    p_ASMAY_ID TEXT,
    p_ASMCL_Id TEXT,
    p_IVRMMS_ID TEXT
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "IVRMMS_Name" VARCHAR,
    "Studentcount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic TEXT;
BEGIN

    v_sqldynamic := 'SELECT "ASMAY"."ASMAY_Year", "ASMC"."ASMCL_ClassName", "IMS"."IVRMMS_Name", COUNT(DISTINCT "ASYS"."AMST_Id") AS "Studentcount"
    FROM "dbo"."Adm_M_Student" "AMS"
    INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ASYS"."ASMAY_Id" AND "ASMAY"."MI_Id" = "AMS"."MI_Id"
    INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id" AND "ASMC"."MI_Id" = "ASMAY"."MI_Id"
    INNER JOIN "IVRM_Master_State" "IMS" ON "IMS"."IVRMMS_Id" = "AMS"."AMST_State"
    WHERE "ASYS"."ASMAY_ID" IN (' || p_ASMAY_ID || ') 
    AND "AMS"."MI_Id" = ' || p_MI_ID || ' 
    AND "ASYS"."ASMCL_ID" IN (' || p_ASMCL_Id || ') 
    AND "AMS"."AMST_State" IN (' || p_IVRMMS_ID || ')
    GROUP BY "ASMAY"."ASMAY_Year", "ASMC"."ASMCL_ClassName", "IMS"."IVRMMS_Name"
    ORDER BY "ASMAY"."ASMAY_Year"';

    RETURN QUERY EXECUTE v_sqldynamic;

END;
$$;