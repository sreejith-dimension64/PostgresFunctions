CREATE OR REPLACE FUNCTION "dbo"."Adm_Attendance_Deviation_Report"(
    p_year TEXT,
    p_classid TEXT,
    p_secid TEXT,
    p_mi_id TEXT,
    p_fromdate TEXT,
    p_todate TEXT,
    p_flag VARCHAR(10)
)
RETURNS TABLE(
    diff INTEGER,
    attendancedate VARCHAR(10),
    attendanceentrydate VARCHAR(10),
    classname TEXT,
    sectionname TEXT,
    staff TEXT,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    
    IF p_flag = '1' THEN
        RETURN QUERY
        SELECT 
            CAST(EXTRACT(DAY FROM (a."ASA_Entry_DateTime" - a."ASA_ToDate")) AS INTEGER) as diff,
            TO_CHAR(a."ASA_ToDate", 'DD/MM/YYYY') as attendancedate,
            TO_CHAR(a."ASA_Entry_DateTime", 'DD/MM/YYYY') as attendanceentrydate,
            f."asmcl_classname" as classname,
            g."asmc_sectionname" as sectionname,
            (COALESCE(c."hrme_employeefirstname", '') || ' ' || COALESCE(c."hrme_employeemiddlename", '') || ' ' || COALESCE(c."hrme_employeelastname", '')) as staff,
            f."ASMCL_Order",
            g."ASMC_Order"
        FROM "Adm_Student_Attendance" a 
        INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id" 
        INNER JOIN "HR_Master_Employee" c ON c."hrme_id" = a."hrme_id"
        INNER JOIN "adm_school_Y_student" d ON d."amst_id" = b."amst_id"
        INNER JOIN "Adm_M_Student" e ON e."amst_id" = d."amst_id"
        INNER JOIN "adm_school_M_class" f ON f."asmcl_id" = d."asmcl_id"
        INNER JOIN "adm_school_M_section" g ON g."asms_id" = d."asms_id"
        INNER JOIN "adm_school_M_academic_year" h ON h."ASMAY_Id" = d."ASMAY_Id"
        WHERE a."MI_Id" = p_mi_id 
            AND a."ASMAY_Id" = p_year 
            AND a."ASA_Activeflag" = 1 
            AND a."ASA_ToDate" BETWEEN p_fromdate::TIMESTAMP AND p_todate::TIMESTAMP
        GROUP BY a."ASA_ToDate", a."ASA_Entry_DateTime", f."asmcl_classname", g."asmc_sectionname", 
                 c."hrme_employeefirstname", c."hrme_employeemiddlename", c."hrme_employeelastname", 
                 f."ASMCL_Order", g."ASMC_Order"
        HAVING CAST(EXTRACT(DAY FROM (a."ASA_Entry_DateTime" - a."ASA_ToDate")) AS INTEGER) > 0
        ORDER BY f."ASMCL_Order", g."ASMC_Order";
    ELSE
        RETURN QUERY
        SELECT 
            CAST(EXTRACT(DAY FROM (a."ASA_Entry_DateTime" - a."ASA_ToDate")) AS INTEGER) as diff,
            TO_CHAR(a."ASA_ToDate", 'DD/MM/YYYY') as attendancedate,
            TO_CHAR(a."ASA_Entry_DateTime", 'DD/MM/YYYY') as attendanceentrydate,
            f."asmcl_classname" as classname,
            g."asmc_sectionname" as sectionname,
            (COALESCE(c."hrme_employeefirstname", '') || ' ' || COALESCE(c."hrme_employeemiddlename", '') || ' ' || COALESCE(c."hrme_employeelastname", '')) as staff,
            f."ASMCL_Order",
            g."ASMC_Order"
        FROM "Adm_Student_Attendance" a 
        INNER JOIN "Adm_Student_Attendance_Students" b ON a."ASA_Id" = b."ASA_Id" 
        INNER JOIN "HR_Master_Employee" c ON c."hrme_id" = a."hrme_id"
        INNER JOIN "adm_school_Y_student" d ON d."amst_id" = b."amst_id"
        INNER JOIN "Adm_M_Student" e ON e."amst_id" = d."amst_id"
        INNER JOIN "adm_school_M_class" f ON f."asmcl_id" = d."asmcl_id"
        INNER JOIN "adm_school_M_section" g ON g."asms_id" = d."asms_id"
        INNER JOIN "adm_school_M_academic_year" h ON h."ASMAY_Id" = d."ASMAY_Id"
        WHERE a."MI_Id" = p_mi_id 
            AND a."ASMAY_Id" = p_year 
            AND a."ASA_Activeflag" = 1 
            AND a."ASMCL_Id" = p_classid 
            AND a."ASMS_Id" = p_secid 
            AND a."ASA_ToDate" BETWEEN p_fromdate::TIMESTAMP AND p_todate::TIMESTAMP
        GROUP BY a."ASA_ToDate", a."ASA_Entry_DateTime", f."asmcl_classname", g."asmc_sectionname", 
                 c."hrme_employeefirstname", c."hrme_employeemiddlename", c."hrme_employeelastname", 
                 f."ASMCL_Order", g."ASMC_Order"
        HAVING CAST(EXTRACT(DAY FROM (a."ASA_Entry_DateTime" - a."ASA_ToDate")) AS INTEGER) > 0
        ORDER BY f."ASMCL_Order", g."ASMC_Order";
    END IF;
    
    RETURN;
END;
$$;