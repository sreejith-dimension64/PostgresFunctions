CREATE OR REPLACE FUNCTION "dbo"."FEE_STUDENTGROUP_NAME_SEARCH"(
    "Mi_Id" bigint,
    "searchtext" text,
    "ASMAY_ID" bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "AMST_FirstName" varchar,
    "AMST_MiddleName" varchar,
    "AMST_LastName" varchar,
    "StudentName" text,
    "AMST_AdmNo" varchar,
    "AMST_RegistrationNo" varchar,
    "AMAY_RollNo" varchar,
    "FMG_GroupName" varchar,
    "ASMCL_ClassName" varchar,
    "ASMC_SectionName" varchar,
    "AMST_MobileNo" varchar,
    "FMSG_Id" bigint,
    "FMG_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."AMST_Id",
        a."AMST_FirstName",
        a."AMST_MiddleName",
        a."AMST_LastName",
        a."StudentName",
        a."AMST_AdmNo",
        a."AMST_RegistrationNo",
        a."AMAY_RollNo",
        a."FMG_GroupName",
        a."ASMCL_ClassName",
        a."ASMC_SectionName",
        a."AMST_MobileNo",
        a."FMSG_Id",
        a."FMG_Id"
    FROM (
        SELECT DISTINCT 
            A."AMST_Id",
            COALESCE(A."AMST_FirstName", '') AS "AMST_FirstName",
            COALESCE(A."AMST_MiddleName", '') AS "AMST_MiddleName",
            COALESCE(A."AMST_LastName", '') AS "AMST_LastName",
            (COALESCE(A."AMST_FirstName", '') || ' ' || COALESCE(A."AMST_MiddleName", '') || '' || COALESCE(A."AMST_LastName", '')) AS "StudentName",
            A."AMST_AdmNo",
            A."AMST_RegistrationNo",
            D."AMAY_RollNo",
            B."FMG_GroupName",
            C."ASMCL_ClassName",
            G."ASMC_SectionName",
            A."AMST_MobileNo",
            A."FMSG_Id",
            B."FMG_Id"
        FROM "Fee_Master_Student_Group" AS A
        INNER JOIN "Fee_Master_Group" AS B ON B."FMG_Id" = A."FMG_Id" AND A."MI_Id" = B."MI_Id"
        INNER JOIN "Adm_School_Y_Student" AS D ON D."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_M_Student" AS E ON E."AMST_Id" = A."AMST_Id" AND E."AMST_SOL" = 'S'
        INNER JOIN "Fee_Student_Status" AS F ON F."AMST_Id" = A."AMST_Id" AND F."ASMAY_Id" = D."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" AS C ON C."ASMCL_Id" = D."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" AS G ON G."ASMS_Id" = D."ASMS_Id"
        WHERE A."MI_Id" = "Mi_Id" 
            AND A."ASMAY_ID" = "ASMAY_ID" 
            AND E."MI_Id" = "Mi_Id" 
            AND F."MI_Id" = "Mi_Id" 
            AND D."AMAY_ActiveFlag" = 1 
            AND E."AMST_ActiveFlag" = 1 
            AND D."ASMAY_ID" = "ASMAY_ID"
    ) a 
    WHERE (
        CASE 
            WHEN POSITION(' ' IN a."StudentName") > 0 
            THEN REPLACE(a."StudentName", ' ', '') 
        END
    ) LIKE '%' || (
        CASE 
            WHEN POSITION(' ' IN "searchtext") > 0 
            THEN REPLACE("searchtext", ' ', '') 
        END
    ) || '%'
    OR (
        a."AMST_FirstName" LIKE "searchtext" || '%' 
        OR a."AMST_MiddleName" LIKE "searchtext" || '%' 
        OR a."AMST_LastName" LIKE "searchtext" || '%'
    );
END;
$$;