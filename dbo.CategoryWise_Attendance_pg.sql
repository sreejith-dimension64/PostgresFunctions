CREATE OR REPLACE FUNCTION "dbo"."CategoryWise_Attendance"(
    "p_ASMAY_ID" BIGINT,
    "p_fromdate" DATE,
    "p_mi_id" BIGINT
)
RETURNS TABLE(
    "AMC_Id" BIGINT,
    "AMC_Name" VARCHAR,
    "Total_Female" BIGINT,
    "Total_Male" BIGINT,
    "PreFemale" BIGINT,
    "Premale" BIGINT,
    "absFemale" BIGINT,
    "absmale" BIGINT,
    "half_day_Female" BIGINT,
    "half_day_Male" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        i."AMC_Id",
        i."AMC_Name",
        j."Total_Female",
        j."Total_Male",
        i."PreFemale",
        i."Premale",
        i."absFemale",
        i."absmale",
        i."half_day_Female",
        i."half_day_Male"
    FROM
    (
        SELECT 
            abc."AMC_Id",
            abc."AMC_Name",
            SUM(abc."pre_female") AS "PreFemale",
            SUM(abc."pre_male") AS "Premale",
            SUM(abc."abs_female") AS "absFemale",
            SUM(abc."abs_male") AS "absmale",
            SUM(abc."half_female") AS "half_day_Female",
            SUM(abc."half_male") AS "half_day_Male"
        FROM
        (
            SELECT  
                amc."AMC_Id",
                amc."AMC_Name",
                COUNT(CASE WHEN ams."AMST_Sex" = 'Female' AND asas."ASA_Class_Attended" = 1.00 THEN 1 ELSE NULL END) AS "pre_female",
                COUNT(CASE WHEN ams."AMST_Sex" = 'Male' AND asas."ASA_Class_Attended" = 1.00 THEN 1 ELSE NULL END) AS "pre_male",
                COUNT(CASE WHEN ams."AMST_Sex" = 'Female' AND asas."ASA_Class_Attended" = 0.00 THEN 1 ELSE NULL END) AS "abs_female",
                COUNT(CASE WHEN ams."AMST_Sex" = 'Male' AND asas."ASA_Class_Attended" = 0.00 THEN 1 ELSE NULL END) AS "abs_male",
                COUNT(CASE WHEN ams."AMST_Sex" = 'Female' AND asas."ASA_Class_Attended" = 0.50 THEN 1 ELSE NULL END) AS "half_female",
                COUNT(CASE WHEN ams."AMST_Sex" = 'Male' AND asas."ASA_Class_Attended" = 0.50 THEN 1 ELSE NULL END) AS "half_male"
            FROM 
                "Adm_Student_Attendance" asa,
                "Adm_Student_Attendance_Students" asas,
                "Adm_M_Student" ams,
                "Adm_School_M_Class_Category" asmcc,
                "Adm_M_Category" amc
            WHERE 
                asa."ASA_Id" = asas."ASA_Id" 
                AND asa."ASA_Activeflag" = 1 
                AND "p_fromdate" BETWEEN asa."ASA_FromDate"::DATE AND asa."ASA_ToDate"::DATE
                AND asa."ASMAY_Id" = "p_ASMAY_ID"
                AND asa."MI_Id" = "p_mi_id"
                AND asas."AMST_Id" = ams."AMST_Id"
                AND asmcc."MI_Id" = asa."MI_Id"
                AND asmcc."ASMAY_Id" = asa."ASMAY_Id"
                AND ams."ASMCL_Id" = asmcc."ASMCL_Id"
                AND amc."AMC_Id" = asmcc."AMC_Id"
                AND amc."MI_Id" = asa."MI_Id"
            GROUP BY ams."AMST_Sex", amc."AMC_Name", amc."AMC_Id"
        ) AS abc
        GROUP BY abc."AMC_Name", abc."AMC_Id"
    ) AS i,
    (
        SELECT
            abc."AMC_Id",
            abc."AMC_Name",
            COUNT(CASE WHEN a."AMST_Sex" = 'Female' THEN 1 ELSE NULL END) AS "Total_Female",
            COUNT(CASE WHEN a."AMST_Sex" = 'Male' THEN 1 ELSE NULL END) AS "Total_Male"
        FROM
        (
            SELECT DISTINCT 
                "Adm_School_M_Class_Category"."AMC_Id",
                "Adm_M_Category"."AMC_Name",
                "Adm_School_M_Class_Category"."ASMCL_Id"
            FROM 
                "Adm_School_M_Class_Category",
                "Adm_M_Category"
            WHERE 
                "Adm_M_Category"."MI_Id" = "p_mi_id" 
                AND "Adm_School_M_Class_Category"."ASMAY_Id" = "p_ASMAY_ID"
                AND "Adm_M_Category"."MI_Id" = "Adm_School_M_Class_Category"."MI_Id"
                AND "Adm_M_Category"."AMC_Id" = "Adm_School_M_Class_Category"."AMC_Id"
        ) abc,
        (
            SELECT DISTINCT 
                "Adm_Student_Attendance_Students"."AMST_Id",
                "Adm_Student_Attendance_Students"."ASMCL_Id",
                "Adm_Student_Attendance_Students"."ASMS_Id"
            FROM 
                "Adm_Student_Attendance_Students",
                "Adm_Student_Attendance"
            WHERE 
                "Adm_Student_Attendance"."MI_Id" = "p_mi_id"
                AND "Adm_Student_Attendance"."ASMAY_Id" = "p_ASMAY_ID"
                AND "Adm_Student_Attendance"."ASA_Id" = "Adm_Student_Attendance_Students"."ASA_Id" 
                AND "Adm_Student_Attendance"."ASA_Activeflag" = 1
        ) cba,
        "Adm_M_Student" a
        WHERE 
            abc."ASMCL_Id" IN (SELECT cba."ASMCL_Id" FROM (SELECT DISTINCT "Adm_Student_Attendance_Students"."ASMCL_Id" FROM "Adm_Student_Attendance_Students", "Adm_Student_Attendance" WHERE "Adm_Student_Attendance"."MI_Id" = "p_mi_id" AND "Adm_Student_Attendance"."ASMAY_Id" = "p_ASMAY_ID" AND "Adm_Student_Attendance"."ASA_Id" = "Adm_Student_Attendance_Students"."ASA_Id" AND "Adm_Student_Attendance"."ASA_Activeflag" = 1) cba)
            AND a."MI_Id" = "p_mi_id"
            AND a."ASMAY_Id" = "p_ASMAY_ID"
            AND a."ASMCL_Id" IN (SELECT cba."ASMCL_Id" FROM (SELECT DISTINCT "Adm_Student_Attendance_Students"."ASMCL_Id" FROM "Adm_Student_Attendance_Students", "Adm_Student_Attendance" WHERE "Adm_Student_Attendance"."MI_Id" = "p_mi_id" AND "Adm_Student_Attendance"."ASMAY_Id" = "p_ASMAY_ID" AND "Adm_Student_Attendance"."ASA_Id" = "Adm_Student_Attendance_Students"."ASA_Id" AND "Adm_Student_Attendance"."ASA_Activeflag" = 1) cba)
            AND a."AMST_Id" = cba."AMST_Id"
        GROUP BY abc."AMC_Id", abc."AMC_Name"
    ) AS j
    WHERE i."AMC_Id" = j."AMC_Id";

END;
$$;