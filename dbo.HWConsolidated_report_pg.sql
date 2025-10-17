CREATE OR REPLACE FUNCTION "dbo"."HWConsolidated_report" (
    "@asmcl_id" TEXT,
    "@fromdate" VARCHAR(50),
    "@todate" VARCHAR(50),
    "@mi_id" TEXT,
    "@flag" VARCHAR(100)
)
RETURNS TABLE (
    "ASMCL_Id" BIGINT,
    "asmcL_ClassName" VARCHAR,
    "total_count" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@totalcount" BIGINT;
    "@sqlexec" TEXT;
BEGIN
    
    IF "@flag" = 'Homework' THEN
        "@sqlexec" := '
        SELECT DISTINCT a."ASMCL_Id", c."ASMCL_ClassName" AS "asmcL_ClassName", COUNT(*) AS "total_count"
        FROM "IVRM_HomeWork" a
        INNER JOIN "IVRM_HomeWork_Attatchment" b ON a."IHW_Id" = b."IHW_Id" 
        INNER JOIN "Adm_School_M_Class" c ON a."ASMCL_Id" = c."ASMCL_Id" AND c."MI_Id" = ' || "@mi_id" || '
        LEFT JOIN "Adm_School_M_Section" d ON a."ASMS_Id" = d."ASMS_Id" AND d."MI_Id" = ' || "@mi_id" || '
        LEFT JOIN "IVRM_Master_Subjects" e ON e."ISMS_Id" = a."ISMS_Id" AND e."MI_Id" = ' || "@mi_id" || '
        INNER JOIN "ApplicationUser" f ON f."Id" = a."IVRMUL_Id"
        LEFT JOIN "IVRM_Staff_User_Login" g ON g."Id" = f."Id"
        LEFT JOIN "HR_Master_Employee" h ON h."HRME_Id" = g."Emp_Code" AND h."MI_Id" = ' || "@mi_id" || '
        WHERE a."MI_Id" = ' || "@mi_id" || ' AND CAST(a."IHW_Date" AS DATE) BETWEEN ''' || "@fromdate" || ''' AND ''' || "@todate" || ''' 
        GROUP BY a."ASMCL_Id", c."ASMCL_ClassName"';
    END IF;
    
    IF "@flag" = 'Classwork' THEN
        "@sqlexec" := '
        SELECT DISTINCT a."ASMCL_Id", c."ASMCL_ClassName" AS "asmcL_ClassName", COUNT(*) AS "total_count" 
        FROM "IVRM_Assignment" a
        INNER JOIN "IVRM_ClassWork_Attatchment" b ON a."ICW_Id" = b."ICW_Id" 
        LEFT JOIN "Adm_School_M_Class" c ON a."ASMCL_Id" = c."ASMCL_Id" AND c."MI_Id" = ' || "@mi_id" || '
        LEFT JOIN "Adm_School_M_Section" d ON a."ASMS_Id" = d."ASMS_Id" AND d."MI_Id" = ' || "@mi_id" || '
        LEFT JOIN "IVRM_Master_Subjects" e ON e."ISMS_Id" = a."ISMS_Id" AND e."MI_Id" = ' || "@mi_id" || '
        INNER JOIN "ApplicationUser" f ON f."Id" = a."Login_Id"
        LEFT JOIN "IVRM_Staff_User_Login" g ON g."Id" = f."Id" AND c."MI_Id" = ' || "@mi_id" || '
        LEFT JOIN "HR_Master_Employee" h ON h."HRME_Id" = g."Emp_Code" AND h."MI_Id" = ' || "@mi_id" || '
        WHERE a."MI_Id" = ' || "@mi_id" || ' AND CAST(a."ICW_FromDate" AS DATE) BETWEEN ''' || "@fromdate" || ''' AND ''' || "@todate" || ''' 
        GROUP BY a."ASMCL_Id", c."ASMCL_ClassName"';
    END IF;
    
    RETURN QUERY EXECUTE "@sqlexec";
    
END;
$$;