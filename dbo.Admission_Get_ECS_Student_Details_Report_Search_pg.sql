CREATE OR REPLACE FUNCTION "dbo"."Admission_Get_ECS_Student_Details_Report_Search"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "EnteredData" TEXT,
    "SearchColumn" TEXT
)
RETURNS TABLE(
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
    v_SEARCHCOLUMNNEW TEXT;
BEGIN

    DROP TABLE IF EXISTS "ECS_REPORT_DETAILS_Temp";

    IF "ASMCL_Id" = '0' THEN
        v_QUERYASMCLID := 'SELECT DISTINCT "ASMCL_Id" FROM "ADM_SCHOOL_M_CLASS" WHERE "MI_Id"=' || "MI_Id" || ' AND "ASMCL_ActiveFlag"=1';
    ELSE
        v_QUERYASMCLID := 'SELECT DISTINCT "ASMCL_Id" FROM "ADM_SCHOOL_M_CLASS" WHERE "MI_Id"=' || "MI_Id" || ' AND "ASMCL_Id"=' || "ASMCL_Id" || ' AND "ASMCL_ActiveFlag"=1';
    END IF;

    IF "ASMS_Id" = '0' THEN
        v_QUERYASMSID := 'SELECT DISTINCT "ASMS_Id" FROM "ADM_SCHOOL_M_SECTION" WHERE "MI_Id"=' || "MI_Id" || ' AND "ASMC_ActiveFlag"=1';
    ELSE
        v_QUERYASMSID := 'SELECT DISTINCT "ASMS_Id" FROM "ADM_SCHOOL_M_SECTION" WHERE "MI_Id"=' || "MI_Id" || ' AND "ASMS_Id"=' || "ASMS_Id" || ' AND "ASMC_ActiveFlag"=1';
    END IF;

    IF "SearchColumn" = '1' THEN
        v_SEARCHCOLUMNNEW := '(A."AMST_FIRSTNAME" LIKE ''%' || "EnteredData" || '%'' OR A."AMST_MIDDLENAME" LIKE ''%' || "EnteredData" || '%'' OR A."AMST_LASTNAME" LIKE ''%' || "EnteredData" || '%'')';
    ELSIF "SearchColumn" = '2' THEN
        v_SEARCHCOLUMNNEW := '(A."AMST_ADMNO" LIKE ''%' || "EnteredData" || '%'')';
    ELSIF "SearchColumn" = '3' THEN
        v_SEARCHCOLUMNNEW := '(C."ASECS_AccountHolderName" LIKE ''%' || "EnteredData" || '%'')';
    ELSIF "SearchColumn" = '4' THEN
        v_SEARCHCOLUMNNEW := '(C."ASECS_AccountNo" LIKE ''%' || "EnteredData" || '%'')';
    ELSIF "SearchColumn" = '5' THEN
        v_SEARCHCOLUMNNEW := '(C."ASECS_AccountType" LIKE ''%' || "EnteredData" || '%'')';
    ELSIF "SearchColumn" = '6' THEN
        v_SEARCHCOLUMNNEW := '(C."ASECS_BankName" LIKE ''%' || "EnteredData" || '%'')';
    ELSIF "SearchColumn" = '7' THEN
        v_SEARCHCOLUMNNEW := '(C."ASECS_Branch" LIKE ''%' || "EnteredData" || '%'')';
    ELSIF "SearchColumn" = '8' THEN
        v_SEARCHCOLUMNNEW := '(C."ASECS_MICRNo" LIKE ''%' || "EnteredData" || '%'')';
    ELSE
        v_SEARCHCOLUMNNEW := '(A."MI_Id" =' || "MI_Id" || ')';
    END IF;

    v_QUERY := '
    SELECT B."AMST_Id",
           (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName"='''' THEN '''' ELSE "AMST_FirstName" END ||
            CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName"='''' THEN '''' ELSE '' '' || "AMST_MiddleName" END ||
            CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName"='''' THEN '''' ELSE '' '' || "AMST_LastName" END) AS STUDENTNAME,
           A."AMST_AdmNo" AS ADMNO,
           C."ASECS_AccountHolderName" AS ACCOUNTHOLDERNAME,
           C."ASECS_AccountNo" AS ACCOUNTNO,
           C."ASECS_AccountType" AS ACCOUNTTYPE,
           C."ASECS_BankName" AS BANKNAME,
           C."ASECS_Branch" AS BRANCH,
           C."ASECS_MICRNo" AS MICRNO,
           E."ASMCL_ClassName" AS CLASSNAME,
           F."ASMC_SectionName" AS SECTIONNAME,
           E."ASMCL_Order",
           F."ASMC_Order"
    FROM "Adm_M_Student" A
    INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
    INNER JOIN "Adm_Student_ECS" C ON C."AMST_Id" = A."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" D ON D."ASMAY_Id" = B."ASMAY_Id"
    INNER JOIN "Adm_School_M_Class" E ON E."ASMCL_Id" = B."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" F ON F."ASMS_Id" = B."ASMS_Id"
    WHERE B."ASMAY_Id" = ' || "ASMAY_Id" || ' 
      AND A."MI_Id" = ' || "MI_Id" || ' 
      AND A."AMST_SOL" = ''S'' 
      AND A."AMST_ActiveFlag" = 1 
      AND B."AMAY_ActiveFlag" = 1
      AND C."ASECS_ActiveFlg" = 1 
      AND B."ASMCL_Id" IN (' || v_QUERYASMCLID || ') 
      AND B."ASMS_Id" IN (' || v_QUERYASMSID || ') 
      AND "AMST_ECSFlag" = 1
      AND ' || v_SEARCHCOLUMNNEW || '
    ORDER BY E."ASMCL_Order", F."ASMC_Order", ADMNO, STUDENTNAME';

    RETURN QUERY EXECUTE v_QUERY;

END;
$$;