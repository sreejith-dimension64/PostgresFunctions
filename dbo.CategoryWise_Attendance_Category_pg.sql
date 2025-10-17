CREATE OR REPLACE FUNCTION "dbo"."CategoryWise_Attendance_Category" (
    "ASMAY_ID" bigint,
    "fromdate" date,
    "mi_id" bigint,
    "AMC_Id" varchar(10)
)
RETURNS TABLE (
    "AMC_Id" bigint,
    "AMC_Name" varchar,
    "Total_Female" bigint,
    "Total_Male" bigint,
    "PreFemale" bigint,
    "Premale" bigint,
    "absFemale" bigint,
    "absmale" bigint,
    "half_day_Female" bigint,
    "half_day_Male" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_category text;
    v_query text;
    v_fromdate_N varchar(10);
BEGIN
    IF ("AMC_Id" != '0' AND "AMC_Id" != '') THEN
        v_category := 'and "Adm_M_Student"."AMC_Id"=' || "AMC_Id" || '';
    ELSE
        v_category := '';
    END IF;

    v_fromdate_N := "fromdate"::varchar(10);

    v_query := 'SELECT i."AMC_Id", i."AMC_Name", "Total_Female", "Total_Male", "PreFemale", "Premale", "absFemale", "absmale", "half_day_Female", "half_day_Male" 
    FROM (
        SELECT abc."AMC_Id", abc."AMC_Name", 
            SUM(pre_female) "PreFemale", 
            SUM(pre_male) "Premale", 
            SUM(abs_female) "absFemale", 
            SUM(abs_male) "absmale", 
            SUM(half_female) "half_day_Female", 
            SUM(half_male) "half_day_Male"
        FROM (
            SELECT amc."AMC_Id", amc."AMC_Name",
                COUNT(CASE WHEN ams."AMST_Sex"=''Female'' AND asas."ASA_Class_Attended"=1.00 THEN 1 ELSE NULL END) as pre_female,
                COUNT(CASE WHEN ams."AMST_Sex"=''Male'' AND asas."ASA_Class_Attended"=1.00 THEN 1 ELSE NULL END) as pre_male,
                COUNT(CASE WHEN ams."AMST_Sex"=''Female'' AND asas."ASA_Class_Attended"=0.00 THEN 1 ELSE NULL END) as abs_female,
                COUNT(CASE WHEN ams."AMST_Sex"=''Male'' AND asas."ASA_Class_Attended"=0.00 THEN 1 ELSE NULL END) as abs_male,
                COUNT(CASE WHEN ams."AMST_Sex"=''Female'' AND (asas."ASA_Class_Attended"=0.50) THEN 1 ELSE NULL END) as half_female,
                COUNT(CASE WHEN ams."AMST_Sex"=''Male'' AND (asas."ASA_Class_Attended"=0.50) THEN 1 ELSE NULL END) as half_male
            FROM "Adm_Student_Attendance" asa, 
                 "Adm_Student_Attendance_Students" asas, 
                 "Adm_M_Student" ams, 
                 "Adm_School_M_Class_Category" asmcc, 
                 "Adm_M_Category" amc
            WHERE asa."ASA_Id"=asas."ASA_Id" 
                AND "ASA_Activeflag"=1 
                AND ''' || v_fromdate_N || '''::date BETWEEN asa."ASA_FromDate"::date AND asa."ASA_ToDate"::date 
                AND asa."ASMAY_Id"=' || "ASMAY_ID"::varchar(10) || '
                AND asa."MI_Id"=' || "mi_id"::varchar(10) || '
                AND asas."AMST_Id"=ams."AMST_Id" 
                AND asmcc."MI_Id"=asa."MI_Id"
                AND asmcc."ASMAY_Id"=asa."ASMAY_Id"
                AND ams."ASMCL_Id"=asmcc."ASMCL_Id"
                AND amc."AMC_Id"=asmcc."AMC_Id" 
                AND amc."MI_Id"=asa."MI_Id"
            GROUP BY ams."AMST_Sex", amc."AMC_Name", amc."AMC_Id"
        ) as abc
        GROUP BY abc."AMC_Name", abc."AMC_Id"
    ) as i,
    (
        SELECT abc."AMC_Id", "AMC_Name", 
            COUNT(CASE WHEN a."AMST_Sex"=''Female'' THEN 1 ELSE NULL END) "Total_Female",
            COUNT(CASE WHEN a."AMST_Sex"=''Male'' THEN 1 ELSE NULL END) "Total_Male"
        FROM (
            SELECT DISTINCT "Adm_School_M_Class_Category"."AMC_Id", "AMC_Name", "Adm_School_M_Class_Category"."ASMCL_Id"
            FROM "Adm_School_M_Class_Category", "Adm_M_Category"
            WHERE "Adm_M_Category"."MI_Id"=' || "mi_id"::varchar(10) || ' 
                AND "ASMAY_Id"=' || "ASMAY_ID"::varchar(10) || '
                AND "Adm_M_Category"."MI_Id"="Adm_School_M_Class_Category"."MI_Id" 
                AND "Adm_M_Category"."AMC_Id"="Adm_School_M_Class_Category"."AMC_Id"
        ) abc,
        (
            SELECT DISTINCT "AMST_Id", "ASMCL_Id", "ASMS_Id" 
            FROM "Adm_Student_Attendance_Students", "Adm_Student_Attendance" 
            WHERE "Adm_Student_Attendance"."MI_Id"=' || "mi_id"::varchar(10) || ' 
                AND "Adm_Student_Attendance"."ASMAY_Id"=' || "ASMAY_ID"::varchar(10) || ' 
                AND "Adm_Student_Attendance"."ASA_Id"="Adm_Student_Attendance_Students"."ASA_Id" 
                AND "ASA_Activeflag"=1
        ) cba, 
        "Adm_M_Student" a
        WHERE abc."ASMCL_Id" IN (cba."ASMCL_Id") 
            AND a."MI_Id"=' || "mi_id"::varchar(10) || '
            AND a."ASMAY_Id"=' || "ASMAY_ID"::varchar(10) || ' 
            AND a."ASMCL_Id" IN(cba."ASMCL_Id")
            AND a."AMST_Id"=cba."AMST_Id"
        GROUP BY abc."AMC_Id", "AMC_Name"
    ) as j
    WHERE i."AMC_Id"=j."AMC_Id"';

    RETURN QUERY EXECUTE v_query;
END;
$$;