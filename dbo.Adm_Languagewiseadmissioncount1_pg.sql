CREATE OR REPLACE FUNCTION "dbo"."Adm_Languagewiseadmissioncount1"(
    p_MI_ID TEXT,
    p_ASMAY_ID TEXT
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "AMST_MotherTongue" VARCHAR,
    "StudentCount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic TEXT;
BEGIN
    
    v_sqldynamic := 'SELECT ASMAY."ASMAY_Year", AMS."AMST_MotherTongue", COALESCE(Count(distinct ASYS."AMST_Id"), 0) AS "StudentCount"
FROM "dbo"."Adm_M_Student" AMS
INNER JOIN "dbo"."Adm_School_Y_Student" ASYS ON ASYS."AMST_Id" = AMS."AMST_Id" 
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ASMAY ON ASMAY."ASMAY_Id" = ASYS."ASMAY_Id" AND ASMAY."MI_Id" = AMS."MI_Id"
INNER JOIN "dbo"."Adm_School_M_Class" ASMC ON ASMC."ASMCL_Id" = ASYS."ASMCL_Id" AND ASMC."MI_Id" = ASMAY."MI_Id"
WHERE ASYS."ASMAY_ID" IN (' || p_ASMAY_ID || ') AND AMS."MI_Id" = ' || p_MI_ID || '  
GROUP BY ASMAY."ASMAY_Year", AMS."AMST_MotherTongue"';
    
    RETURN QUERY EXECUTE v_sqldynamic;
    
END;
$$;