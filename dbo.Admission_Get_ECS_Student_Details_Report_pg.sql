CREATE OR REPLACE FUNCTION "dbo"."Admission_Get_ECS_Student_Details_Report"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "STUDENTNAME" TEXT,
    "ADMNO" TEXT,
    "ACCOUNTHOLDERNAME" TEXT,
    "ACCOUNTNO" TEXT,
    "ACCOUNTTYPE" TEXT,
    "BANKNAME" TEXT,
    "BRANCH" TEXT,
    "MICRNO" TEXT,
    "CLASSNAME" TEXT,
    "SECTIONNAME" TEXT,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_QUERYASMCLID TEXT;
    v_QUERYASMSID TEXT;
    v_QUERY TEXT;
BEGIN
    
    DROP TABLE IF EXISTS "ECS_REPORT_DETAILS_Temp";
    
    IF p_ASMCL_Id = '0' THEN
        v_QUERYASMCLID := 'SELECT DISTINCT "ASMCL_Id" FROM "ADM_SCHOOL_M_CLASS" WHERE "MI_Id"=' || p_MI_Id || ' AND "ASMCL_ActiveFlag"=1';
    ELSE
        v_QUERYASMCLID := 'SELECT DISTINCT "ASMCL_Id" FROM "ADM_SCHOOL_M_CLASS" WHERE "MI_Id"=' || p_MI_Id || ' AND "ASMCL_Id"=' || p_ASMCL_Id || ' AND "ASMCL_ActiveFlag"=1';
    END IF;
    
    IF p_ASMS_Id = '0' THEN
        v_QUERYASMSID := 'SELECT DISTINCT "ASMS_Id" FROM "ADM_SCHOOL_M_SECTION" WHERE "MI_Id"=' || p_MI_Id || ' AND "ASMC_ActiveFlag"=1';
    ELSE
        v_QUERYASMSID := 'SELECT DISTINCT "ASMS_Id" FROM "ADM_SCHOOL_M_SECTION" WHERE "MI_Id"=' || p_MI_Id || ' AND "ASMS_Id"=' || p_ASMS_Id || ' AND "ASMC_ActiveFlag"=1';
    END IF;
    
    v_QUERY := '
    SELECT B."AMST_Id",
    (CASE WHEN A."AMST_FirstName" IS NULL OR A."AMST_FirstName"='''' THEN '''' ELSE A."AMST_FirstName" END ||
    CASE WHEN A."AMST_MiddleName" IS NULL OR A."AMST_MiddleName"='''' THEN '''' ELSE '' '' || A."AMST_MiddleName" END ||
    CASE WHEN A."AMST_LastName" IS NULL OR A."AMST_LastName"='''' THEN '''' ELSE '' '' || A."AMST_LastName" END)::TEXT AS "STUDENTNAME",
    A."AMST_AdmNo"::TEXT AS "ADMNO",
    C."ASECS_AccountHolderName"::TEXT AS "ACCOUNTHOLDERNAME",
    C."ASECS_AccountNo"::TEXT AS "ACCOUNTNO",
    C."ASECS_AccountType"::TEXT AS "ACCOUNTTYPE",
    C."ASECS_BankName"::TEXT AS "BANKNAME",
    C."ASECS_Branch"::TEXT AS "BRANCH",
    C."ASECS_MICRNo"::TEXT AS "MICRNO",
    E."ASMCL_ClassName"::TEXT AS "CLASSNAME",
    F."ASMC_SectionName"::TEXT AS "SECTIONNAME",
    E."ASMCL_Order"::INTEGER,
    F."ASMC_Order"::INTEGER
    FROM "Adm_M_Student" A
    INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
    INNER JOIN "Adm_Student_ECS" C ON C."AMST_Id" = A."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" D ON D."ASMAY_Id" = B."ASMAY_Id"
    INNER JOIN "Adm_School_M_Class" E ON E."ASMCL_Id" = B."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" F ON F."ASMS_Id" = B."ASMS_Id"
    WHERE B."ASMAY_Id" = ' || p_ASMAY_Id || ' AND A."MI_Id" = ' || p_MI_Id || ' 
    AND A."AMST_SOL" = ''S'' AND A."AMST_ActiveFlag" = 1 AND B."AMAY_ActiveFlag" = 1
    AND C."ASECS_ActiveFlg" = 1 
    AND B."ASMCL_Id" IN (' || v_QUERYASMCLID || ') 
    AND B."ASMS_Id" IN (' || v_QUERYASMSID || ') 
    AND A."AMST_ECSFlag" = 1
    ORDER BY E."ASMCL_Order", F."ASMC_Order", A."AMST_AdmNo", "STUDENTNAME"';
    
    RETURN QUERY EXECUTE v_QUERY;
    
END;
$$;