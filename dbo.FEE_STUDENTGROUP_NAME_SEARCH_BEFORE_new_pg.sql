CREATE OR REPLACE FUNCTION "dbo"."FEE_STUDENTGROUP_NAME_SEARCH_BEFORE_new"(
    "Mi_Id" bigint,
    "searchtext" TEXT,
    "ASMAY_ID" bigint,
    "type" varchar(10),
    "trmr_id" varchar(20)
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "AMST_FirstName" TEXT,
    "AMST_MiddleName" TEXT,
    "AMST_LastName" TEXT,
    "AMST_AdmNo" TEXT,
    "AMST_RegistrationNo" TEXT,
    "AMAY_RollNo" TEXT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "AMST_MobileNo" TEXT,
    "ASMCL_Order" INTEGER,
    "FMG_GroupName" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "type" = '1' THEN
    
        RETURN QUERY
        SELECT DISTINCT 
            a."AMST_Id",
            a."AMST_FirstName",
            a."AMST_MiddleName",
            a."AMST_LastName",
            a."AMST_AdmNo",
            a."AMST_RegistrationNo",
            a."AMAY_RollNo",
            a."ASMCL_ClassName",
            a."ASMC_SectionName",
            a."AMST_MobileNo",
            a."ASMCL_Order",
            NULL::TEXT AS "FMG_GroupName"
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
                C."ASMCL_ClassName",
                G."ASMC_SectionName",
                A."AMST_MobileNo",
                C."ASMCL_Order"
            FROM "Adm_M_Student" AS A
            INNER JOIN "Adm_School_Y_Student" AS D ON D."AMST_Id" = A."AMST_Id"
            INNER JOIN "Adm_School_M_Class" AS C ON C."ASMCL_Id" = D."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" AS G ON G."ASMS_Id" = D."ASMS_Id"
            WHERE A."MI_Id" = "Mi_Id" 
                AND D."ASMAY_ID" = "ASMAY_ID" 
                AND C."MI_Id" = "Mi_Id" 
                AND G."MI_Id" = "Mi_Id" 
                AND D."AMAY_ActiveFlag" = 1 
                AND A."AMST_ActiveFlag" = 1 
                AND A."AMST_SOL" = 'S'
        ) a 
        WHERE (CASE WHEN POSITION(' ' IN a."StudentName") > 0 
                    THEN REPLACE(a."StudentName", ' ', '') 
                    ELSE a."StudentName" END) 
              LIKE '%' || (CASE WHEN POSITION(' ' IN "searchtext") > 0 
                                THEN REPLACE("searchtext", ' ', '') 
                                ELSE "searchtext" END) || '%'
           OR (a."AMST_FirstName" LIKE "searchtext" || '%' 
               OR a."AMST_MiddleName" LIKE "searchtext" || '%' 
               OR a."AMST_LastName" LIKE "searchtext" || '%')
        ORDER BY a."ASMCL_Order";
    
    ELSIF "type" = '2' THEN
    
        RETURN QUERY
        SELECT DISTINCT 
            a."AMST_Id",
            a."AMST_FirstName",
            a."AMST_MiddleName",
            a."AMST_LastName",
            a."AMST_AdmNo",
            a."AMST_RegistrationNo",
            a."AMAY_RollNo",
            a."ASMCL_ClassName",
            a."ASMC_SectionName",
            a."AMST_MobileNo",
            a."ASMCL_Order",
            NULL::TEXT AS "FMG_GroupName"
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
                C."ASMCL_ClassName",
                G."ASMC_SectionName",
                A."AMST_MobileNo",
                C."ASMCL_Order"
            FROM "Adm_M_Student" AS A
            INNER JOIN "Adm_School_Y_Student" AS D ON D."AMST_Id" = A."AMST_Id"
            INNER JOIN "Adm_School_M_Class" AS C ON C."ASMCL_Id" = D."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" AS G ON G."ASMS_Id" = D."ASMS_Id"
            INNER JOIN "trn"."TR_Student_Route" AS h ON h."AMST_Id" = D."AMST_Id"
            INNER JOIN "trn"."TR_Master_Route" AS i ON i."TRMR_Id" = h."TRMR_Id"
            WHERE A."MI_Id" = "Mi_Id" 
                AND D."ASMAY_ID" = "ASMAY_ID" 
                AND C."MI_Id" = "Mi_Id" 
                AND G."MI_Id" = "Mi_Id" 
                AND D."AMAY_ActiveFlag" = 1 
                AND A."AMST_ActiveFlag" = 1 
                AND A."AMST_SOL" = 'S' 
                AND h."TRMR_Id" = "trmr_id"::bigint
        ) a 
        WHERE (CASE WHEN POSITION(' ' IN a."StudentName") > 0 
                    THEN REPLACE(a."StudentName", ' ', '') 
                    ELSE a."StudentName" END) 
              LIKE '%' || (CASE WHEN POSITION(' ' IN "searchtext") > 0 
                                THEN REPLACE("searchtext", ' ', '') 
                                ELSE "searchtext" END) || '%'
           OR (a."AMST_FirstName" LIKE "searchtext" || '%' 
               OR a."AMST_MiddleName" LIKE "searchtext" || '%' 
               OR a."AMST_LastName" LIKE "searchtext" || '%')
        ORDER BY a."ASMCL_Order";
    
    ELSE
    
        RETURN QUERY
        SELECT DISTINCT 
            a."AMST_Id",
            a."AMST_FirstName",
            a."AMST_MiddleName",
            a."AMST_LastName",
            a."AMST_AdmNo",
            a."AMST_RegistrationNo",
            a."AMAY_RollNo",
            a."ASMCL_ClassName",
            a."ASMC_SectionName",
            a."AMST_MobileNo",
            a."ASMCL_Order",
            a."FMG_GroupName"
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
                C."ASMCL_ClassName",
                G."ASMC_SectionName",
                A."AMST_MobileNo",
                C."ASMCL_Order",
                i."FMG_GroupName"
            FROM "Adm_M_Student" AS A
            INNER JOIN "Adm_School_Y_Student" AS D ON D."AMST_Id" = A."AMST_Id"
            INNER JOIN "Adm_School_M_Class" AS C ON C."ASMCL_Id" = D."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" AS G ON G."ASMS_Id" = D."ASMS_Id"
            INNER JOIN "Fee_Master_Student_Group" AS h ON h."AMST_Id" = A."AMST_Id"
            INNER JOIN "Fee_Master_Group" AS i ON i."FMG_Id" = h."FMG_Id"
            WHERE A."MI_Id" = "Mi_Id" 
                AND D."ASMAY_ID" = "ASMAY_ID" 
                AND C."MI_Id" = "Mi_Id" 
                AND G."MI_Id" = "Mi_Id" 
                AND h."ASMAY_Id" = "ASMAY_ID"
                AND h."MI_Id" = "Mi_Id" 
                AND D."AMAY_ActiveFlag" = 1 
                AND A."AMST_ActiveFlag" = 1 
                AND A."AMST_SOL" = 'S'
        ) a 
        WHERE (CASE WHEN POSITION(' ' IN a."StudentName") > 0 
                    THEN REPLACE(a."StudentName", ' ', '') 
                    ELSE a."StudentName" END) 
              LIKE '%' || (CASE WHEN POSITION(' ' IN "searchtext") > 0 
                                THEN REPLACE("searchtext", ' ', '') 
                                ELSE "searchtext" END) || '%'
           OR (a."AMST_FirstName" LIKE "searchtext" || '%' 
               OR a."AMST_MiddleName" LIKE "searchtext" || '%' 
               OR a."AMST_LastName" LIKE "searchtext" || '%')
        ORDER BY a."ASMCL_Order";
    
    END IF;

END;
$$;