CREATE OR REPLACE FUNCTION "dbo"."GET_AVAILABLE_PERIODS"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_TTMC_Id bigint,
    p_ttfg_VersionNo bigint
)
RETURNS TABLE(
    "ASMAY_Id" bigint,
    "ASMCL_Id" bigint,
    "ASMS_Id" bigint,
    "HRME_Id" bigint,
    "TTAP_NoOfPeriods" numeric,
    "ASMCL_ClassName" varchar,
    "ASMC_SectionName" varchar,
    "ISMS_SubjectName" varchar,
    "EMPNAME" text
)
LANGUAGE plpgsql
AS $$
BEGIN

    PERFORM "dbo"."TT_Insert_All_Avail_periods_NEW_replace"(p_MI_Id, p_TTMC_Id, p_ASMAY_Id, p_ttfg_VersionNo);

    RETURN QUERY
    SELECT 
        A."ASMAY_Id",
        A."ASMCL_Id",
        A."ASMS_Id",
        A."HRME_Id",
        A."TTAP_NoOfPeriods",
        B."ASMCL_ClassName",
        C."ASMC_SectionName",
        D."ISMS_SubjectName",
        (COALESCE(E."HRME_EmployeeFirstName",'  ') || '  ' || COALESCE(E."HRME_EmployeeMiddleName",'  ') || '  ' || COALESCE(E."HRME_EmployeeLastName",'  '))::text AS "EMPNAME"
    FROM "dbo"."TT_AVAILABLE_PERIODS" AS A 
    INNER JOIN "dbo"."ADM_SCHOOL_M_CLASS" AS B ON B."ASMCL_Id" = A."ASMCL_Id"
    INNER JOIN "dbo"."ADM_SCHOOL_M_SECTION" AS C ON C."ASMS_Id" = A."ASMS_Id"
    INNER JOIN "dbo"."IVRM_MASTER_SUBJECTS" AS D ON D."ISMS_Id" = A."ISMS_Id"
    INNER JOIN "dbo"."HR_MASTER_EMPLOYEE" AS E ON E."HRME_Id" = A."HRME_Id"
    WHERE A."MI_Id" = p_MI_Id AND A."ASMAY_Id" = p_ASMAY_Id;

END;
$$;