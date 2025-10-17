CREATE OR REPLACE FUNCTION "dbo"."Adm_Absent_SMS_Email_Datewise_att_type"(
    "ASMAY_ID" VARCHAR,
    "mi_id" VARCHAR,
    "fromdate" VARCHAR(10),
    "att_type" VARCHAR(100),
    "AMC_id" VARCHAR(100)
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "studentname" TEXT,
    "classsection" TEXT,
    "FirstHalf" INTEGER,
    "SecondHalf" INTEGER,
    "ASA_Class_Attended" NUMERIC,
    "ASA_AttendanceFlag" VARCHAR,
    "ASA_Dailytwice_Flag" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
    "category" TEXT;
BEGIN
    IF "AMC_id"::INTEGER > 0 THEN
        "category" := ' and AMC."AMC_Id"=' || "AMC_id" || '';
    ELSE
        "category" := '';
    END IF;
    
    "query" := 'SELECT DISTINCT d."AMST_Id", 
        (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName"='''' THEN '' '' ELSE "AMST_FirstName" END ||
        CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '''' OR "AMST_MiddleName" = ''0'' THEN '' '' ELSE '' '' || "AMST_MiddleName" END ||
        CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = '''' OR "AMST_LastName" = ''0'' THEN '' '' ELSE '' '' || "AMST_LastName" END) AS studentname,
        e."ASMCL_ClassName" || ''-'' || f."ASMC_SectionName" as classsection,
        CASE WHEN a."ASA_Class_Attended"=0.50 AND a."ASA_Dailytwice_Flag"=''firsthalf'' 
        THEN 0 ELSE 0 END as "FirstHalf",
        CASE WHEN a."ASA_Class_Attended"=0.50 AND a."ASA_Dailytwice_Flag"=''Secondhalf'' THEN 0 ELSE 1 END as "SecondHalf",
        a."ASA_Class_Attended",
        a."ASA_AttendanceFlag",
        a."ASA_Dailytwice_Flag"
    FROM "Adm_Student_Attendance_Students" a 
    INNER JOIN "Adm_Student_Attendance" b ON a."ASA_Id"=b."ASA_Id"  
    INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id"=a."AMST_Id" AND c."asmay_id"=b."asmay_id"  
    INNER JOIN "Adm_M_Student" d ON d."AMST_Id"=c."AMST_Id" 
    INNER JOIN "Adm_School_Attendance_EntryType" ON "Adm_School_Attendance_EntryType"."ASMCL_Id"=b."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Attendance_EntryType"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
    INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id"=c."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id"=c."ASMS_Id"
    INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id"=c."ASMAY_Id"
    INNER JOIN "dbo"."Adm_School_M_Class_Category" ASMCC ON c."asmcl_id"=ASMCC."asmcl_id" AND ASMCC."ASMAY_Id"=c."ASMAY_Id"      
    INNER JOIN "dbo"."Adm_M_Category" AMC ON ASMCC."AMC_Id"=AMC."AMC_Id" 
    WHERE "amst_sol"=''S'' AND "AMST_ActiveFlag"=1 AND "AMAY_ActiveFlag"=1 
    AND TO_DATE(CAST("ASA_FromDate" AS TEXT), ''DD-MM-YYYY'')=''' || "fromdate" || '''
    AND "ASA_Class_Attended"!=1.00 AND b."MI_Id"=' || "mi_id" || ' AND c."ASMAY_Id"=' || "ASMAY_ID" || ' 
    AND ASMCC."asmay_id"=' || "ASMAY_id" || ' AND "ASA_Activeflag"=1 
    AND "Adm_School_Attendance_EntryType"."ASAET_Att_Type"=''' || "att_type" || ''' ' || "category" || '';
    
    RAISE NOTICE '%', "query";
    
    RETURN QUERY EXECUTE "query";
    
END;
$$;