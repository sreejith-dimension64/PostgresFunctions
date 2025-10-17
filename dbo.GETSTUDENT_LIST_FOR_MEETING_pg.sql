CREATE OR REPLACE FUNCTION "dbo"."GETSTUDENT_LIST_FOR_MEETING"(p_meetingid bigint)
RETURNS TABLE(
    "AMST_Id" bigint,
    "student" text,
    "ISMS_SubjectName" varchar,
    "AMST_emailId" varchar,
    "AMST_MobileNo" varchar,
    "DeviceId" varchar,
    "AMST_FatherMobleNo" varchar,
    "AMST_FatheremailId" varchar,
    "EmpName" text,
    "LMSLMEET_MeetingTopic" varchar,
    "LMSLMEET_StartedTime" timestamp
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "YS"."AMST_Id",
        COALESCE("AM"."AMST_FirstName", '') || ' ' || COALESCE("AM"."AMST_MiddleName", '') || ' ' || COALESCE("AM"."AMST_LastName", '') AS "student",
        "SUB"."ISMS_SubjectName",
        "AM"."AMST_emailId",
        "AM"."AMST_MobileNo",
        "AM"."AMST_AppDownloadedDeviceId" AS "DeviceId",
        "AM"."AMST_FatherMobleNo",
        "AM"."AMST_FatheremailId",
        COALESCE("HME"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("HME"."HRME_EmployeeMiddleName", '') || ' ' || COALESCE("HME"."HRME_EmployeeLastName", '') AS "EmpName",
        "LM"."LMSLMEET_MeetingTopic",
        "LM"."LMSLMEET_StartedTime"
    FROM "LMS_Live_Meeting" "LM"
    INNER JOIN "HR_Master_Employee" "HME" ON "LM"."HRME_Id" = "HME"."HRME_Id" AND "LM"."MI_Id" = "HME"."MI_Id"
    INNER JOIN "LMS_Live_Meeting_Class" "LMC" ON "LMC"."LMSLMEET_Id" = "LM"."LMSLMEET_Id"
    INNER JOIN "Adm_School_Y_Student" "YS" ON "YS"."ASMAY_Id" = "LMC"."ASMAY_Id" AND "YS"."ASMCL_Id" = "LMC"."ASMCL_Id" AND "LMC"."ASMS_Id" = "YS"."ASMS_Id"
    INNER JOIN "Adm_M_Student" "AM" ON "AM"."AMST_Id" = "YS"."AMST_Id"
    INNER JOIN "IVRM_Master_Subjects" "SUB" ON "LMC"."ISMS_Id" = "SUB"."ISMS_Id"
    INNER JOIN "Exm"."Exm_Studentwise_Subjects" "ESUB" ON "LMC"."ISMS_Id" = "ESUB"."ISMS_Id" 
        AND "ESUB"."AMST_Id" = "AM"."AMST_Id" 
        AND "ESUB"."ASMAY_Id" = "YS"."ASMAY_Id"
        AND "ESUB"."ISMS_Id" = "LMC"."ISMS_Id"
        AND "YS"."ASMS_Id" = "LMC"."ASMS_Id"
    WHERE "YS"."AMAY_ActiveFlag" = 1 
        AND "LMC"."LMSLMEET_Id" = p_meetingid 
        AND "AM"."AMST_Id" NOT IN (
            SELECT "AMST_Id" 
            FROM "LMS_Live_Meeting_Student" 
            WHERE "LMSLMEET_Id" = p_meetingid
        );
END;
$$;