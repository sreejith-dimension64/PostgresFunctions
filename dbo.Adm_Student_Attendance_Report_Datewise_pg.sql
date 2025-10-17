CREATE OR REPLACE FUNCTION "dbo"."Adm_Student_Attendance_Report_Datewise"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT,
    "p_flag" TEXT,
    "p_Fromdate" TEXT
)
RETURNS TABLE(
    "studentname" TEXT,
    "admno" VARCHAR,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    "classname" VARCHAR,
    "sectionname" VARCHAR,
    "classteacher" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sql" TEXT;
BEGIN
    IF "p_flag" = 'indi' THEN
        "v_sql" := 'SELECT (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '''' THEN '''' ELSE "AMST_FirstName" END ||
                    CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '''' OR "AMST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMST_MiddleName" END ||
                    CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '''' OR "AMST_LastName" = ''0'' THEN '''' ELSE '' '' || "AMST_LastName" END) AS studentname,
                    "AMST_AdmNo" AS admno, "ASMCL_Order", "ASMC_Order", "ASMCL_Classname" AS classname, "ASMC_Sectionname" AS sectionname, '''' AS classteacher
                    FROM "Adm_Student_Attendance" a 
                    INNER JOIN "Adm_Student_Attendance_Students" b ON a."asa_id" = b."asa_id"
                    INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = b."AMST_Id"
                    INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
                    INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = c."ASMAY_Id" AND e."ASMAY_Id" = a."ASMAY_Id"
                    INNER JOIN "Adm_School_M_Class" f ON f."ASMCL_Id" = c."ASMCL_Id" AND f."ASMCL_Id" = a."ASMCL_Id"
                    INNER JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = c."ASMS_Id" AND g."ASMS_Id" = a."ASMS_Id"
                    WHERE d."AMST_SOL" = ''S'' AND d."AMST_ActiveFlag" = 1 AND "ASA_Activeflag" = 1 AND c."AMAY_ActiveFlag" = 1 
                    AND a."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND c."ASMAY_Id" = ' || "p_ASMAY_Id" || '
                    AND c."ASMCL_Id" = ' || "p_ASMCL_Id" || ' AND a."ASMCL_Id" = ' || "p_ASMCL_Id" || ' 
                    AND c."ASMS_Id" IN (' || "p_ASMS_Id" || ') AND a."ASMS_Id" IN (' || "p_ASMS_Id" || ') 
                    AND a."ASA_FromDate" = ''' || "p_Fromdate" || '''
                    AND b."ASA_Class_Attended" = 0.00 
                    ORDER BY "ASMCL_Order", "ASMC_Order", studentname';
    ELSE
        "v_sql" := 'SELECT (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '''' THEN '''' ELSE "AMST_FirstName" END ||
                    CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '''' OR "AMST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMST_MiddleName" END ||
                    CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '''' OR "AMST_LastName" = ''0'' THEN '''' ELSE '' '' || "AMST_LastName" END) AS studentname,
                    "AMST_AdmNo" AS admno, "ASMCL_Order", "ASMC_Order", "ASMCL_Classname" AS classname, "ASMC_Sectionname" AS sectionname, '''' AS classteacher
                    FROM "Adm_Student_Attendance" a 
                    INNER JOIN "Adm_Student_Attendance_Students" b ON a."asa_id" = b."asa_id"
                    INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = b."AMST_Id"
                    INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
                    INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = c."ASMAY_Id" AND e."ASMAY_Id" = a."ASMAY_Id"
                    INNER JOIN "Adm_School_M_Class" f ON f."ASMCL_Id" = c."ASMCL_Id" AND f."ASMCL_Id" = a."ASMCL_Id"
                    INNER JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = c."ASMS_Id" AND g."ASMS_Id" = a."ASMS_Id"
                    WHERE d."AMST_SOL" = ''S'' AND d."AMST_ActiveFlag" = 1 AND "ASA_Activeflag" = 1 AND c."AMAY_ActiveFlag" = 1 
                    AND a."ASMAY_Id" = ' || "p_ASMAY_Id" || ' AND c."ASMAY_Id" = ' || "p_ASMAY_Id" || '
                    AND a."ASA_FromDate" = ''' || "p_Fromdate" || ''' 
                    AND b."ASA_Class_Attended" = 0.00 
                    ORDER BY "ASMCL_Order", "ASMC_Order", studentname';
    END IF;

    RETURN QUERY EXECUTE "v_sql";
END;
$$;