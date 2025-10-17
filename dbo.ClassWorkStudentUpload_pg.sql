CREATE OR REPLACE FUNCTION "dbo"."ClassWorkStudentUpload"(
    p_MI_Id VARCHAR(100),
    p_ASMCL_Id VARCHAR(100),
    p_ASMS_Id TEXT,
    p_FromDate VARCHAR(10),
    p_ToDate VARCHAR(10)
)
RETURNS TABLE(
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ICWUPL_FileName" VARCHAR,
    "UpdatedBy" TEXT,
    "UpdatedDate" DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Sqldynamic TEXT;
BEGIN
    v_Sqldynamic := '
        SELECT DISTINCT "ASMCL_ClassName", "ASMC_SectionName", "ICWUPL_FileName", 
               COALESCE("AMST_FirstName", '''') || '' '' || COALESCE("AMST_MiddleName", '''') || '' '' || COALESCE("AMST_LastName", '''') AS "UpdatedBy",
               CAST("ICWUPL_Date" AS DATE) AS "UpdatedDate"
        FROM "IVRM_Assignment" AS "CW"
        INNER JOIN "IVRM_classwork_Upload" AS "CWU" ON "CW"."ICW_Id" = "CWU"."ICW_Id"
        INNER JOIN "Adm_M_Student" AS "AMS" ON "AMS"."AMST_Id" = "CWU"."AMST_Id" 
               AND "AMS"."AMST_ActiveFlag" = 1 AND "AMS"."AMST_SOL" = ''S''
        INNER JOIN "Adm_School_Y_Student" AS "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id" 
               AND "ASYS"."AMAY_ActiveFlag" = 1
        INNER JOIN "Adm_School_M_Class" AS "ASMCL" ON "ASMCL"."ASMCL_Id" = "CW"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" AS "ASMS" ON "ASMS"."ASMS_Id" = "CW"."ASMS_Id"
        WHERE "CW"."MI_Id" = ' || p_MI_Id || ' 
          AND "CW"."ASMCL_Id" = ' || p_ASMCL_Id || ' 
          AND "CW"."ASMS_Id" IN (' || p_ASMS_Id || ') 
          AND "CW"."ICW_ActiveFlag" = 1 
          AND "CWU"."ICWUPL_ActiveFlag" = 1
          AND CAST("CWU"."ICWUPL_Date" AS DATE) BETWEEN ''' || p_FromDate || ''' AND ''' || p_ToDate || '''';
    
    RETURN QUERY EXECUTE v_Sqldynamic;
END;
$$;