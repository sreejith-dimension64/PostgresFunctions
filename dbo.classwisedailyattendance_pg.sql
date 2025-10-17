CREATE OR REPLACE FUNCTION "dbo"."classwisedailyattendance"(
    "year" bigint,
    "fromdate" timestamp,
    "class" int,
    "sec" int
)
RETURNS TABLE(
    "AMST_FirstName" VARCHAR,
    "AMST_RegistrationNo" VARCHAR,
    "AMST_AdmNo" VARCHAR,
    "ASA_Att_EntryType" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        "Adm_M_Student"."AMST_FirstName",
        "Adm_M_Student"."AMST_RegistrationNo",
        "Adm_M_Student"."AMST_AdmNo",
        "Adm_Student_Attendance"."ASA_Att_EntryType"
    FROM 
        "dbo"."Adm_School_Y_Student" AS "Adm_School_Y_Student"
    INNER JOIN "dbo"."Adm_Student_Attendance" 
        INNER JOIN "dbo"."Adm_Student_Attendance_Students" 
            ON "dbo"."Adm_Student_Attendance"."ASA_Id" = "dbo"."Adm_Student_Attendance_Students"."ASA_Id"
        INNER JOIN "dbo"."Adm_M_Student" 
            ON "dbo"."Adm_Student_Attendance_Students"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
        ON "Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" 
        ON "Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" 
        ON "Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
    WHERE 
        "Adm_School_M_Class"."ASMCL_Id" = "class"
        AND "Adm_School_M_Section"."ASMS_Id" = "sec"
        AND "Adm_School_Y_Student"."ASMAY_Id" = "year"
        AND CAST("Adm_Student_Attendance"."ASA_FromDate" AS date) = CAST("fromdate" AS date);

END;
$$;