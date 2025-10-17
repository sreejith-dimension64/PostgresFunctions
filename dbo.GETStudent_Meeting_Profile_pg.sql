CREATE OR REPLACE FUNCTION "dbo"."GETStudent_Meeting_Profile"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMST_Id bigint,
    p_MeetingDate varchar(10)
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "lmslmeeT_Id" bigint,
    "LMSLMEET_MeetingId" text,
    "EmpName" text,
    "PlannedDate" varchar,
    "lmslmeeT_PlannedDate" timestamp,
    "lmslmeeT_PlannedStartTime" varchar,
    "lmslmeeT_PlannedEndTime" varchar,
    "MeetingDate" varchar,
    "lmslmeeT_MeetingDate" timestamp,
    "lmslmeeT_EndTime" varchar,
    "lmslmeeT_StartedTime" varchar,
    "lmslmeeT_MeetingId" text,
    "lmslmeeT_MeetingTopic" text,
    "student" text,
    "ISMS_SubjectName" text,
    "lmslmeeT_CreatedDate" timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        "YS"."AMST_Id",
        "LM"."LMSLMEET_Id" as "lmslmeeT_Id",
        "LM"."LMSLMEET_MeetingId",
        COALESCE("HME"."HRME_EmployeeFirstName", '') || ' ' || COALESCE("HME"."HRME_EmployeeMiddleName", '') || ' ' ||
        COALESCE("HME"."HRME_EmployeeLastName", '') AS "EmpName",
        TO_CHAR("LM"."LMSLMEET_PlannedDate", 'DD-MM-YYYY') as "PlannedDate",
        "LM"."lmslmeeT_PlannedDate",
        "LM"."LMSLMEET_PlannedStartTime" as "lmslmeeT_PlannedStartTime",
        "LM"."LMSLMEET_PlannedEndTime" as "lmslmeeT_PlannedEndTime",
        TO_CHAR("LM"."lmslmeeT_MeetingDate", 'DD-MM-YYYY') as "MeetingDate",
        "LM"."lmslmeeT_MeetingDate",
        "LM"."LMSLMEET_EndTime" as "lmslmeeT_EndTime",
        "LM"."LMSLMEET_StartedTime" as "lmslmeeT_StartedTime",
        "LM"."LMSLMEET_MeetingId" as "lmslmeeT_MeetingId",
        "LM"."LMSLMEET_MeetingTopic" as "lmslmeeT_MeetingTopic",
        COALESCE("AM"."AMST_FirstName", '') || ' ' || COALESCE("AM"."AMST_MiddleName", '') || ' ' ||
        COALESCE("AM"."AMST_LastName", '') AS "student",
        "SUB"."ISMS_SubjectName",
        "LM"."lmslmeeT_CreatedDate"
    FROM "LMS_Live_Meeting" "LM"
    INNER JOIN "HR_Master_Employee" "HME" ON "LM"."HRME_Id" = "HME"."HRME_Id" AND "LM"."MI_Id" = "HME"."MI_Id"
    INNER JOIN "LMS_Live_Meeting_Class" "LMC" ON "LMC"."LMSLMEET_Id" = "LM"."LMSLMEET_Id"
    INNER JOIN "Adm_School_Y_Student" "YS" ON "YS"."ASMAY_Id" = "LMC"."ASMAY_Id" AND "YS"."ASMCL_Id" = "LMC"."ASMCL_Id"
    INNER JOIN "Adm_M_Student" "AM" ON "AM"."AMST_Id" = "YS"."AMST_Id"
    INNER JOIN "IVRM_Master_Subjects" "SUB" ON "LMC"."ISMS_Id" = "SUB"."ISMS_Id"
    INNER JOIN "Exm"."Exm_Studentwise_Subjects" "ESUB" ON "LMC"."ISMS_Id" = "ESUB"."ISMS_Id" 
        AND "ESUB"."AMST_Id" = "AM"."AMST_Id" 
        AND "ESUB"."ASMAY_Id" = "YS"."ASMAY_Id"
        AND "YS"."ASMS_Id" = "LMC"."ASMS_Id"
    WHERE "YS"."AMAY_ActiveFlag" = 1 
        AND "YS"."ASMAY_Id" = p_ASMAY_Id 
        AND "YS"."AMST_Id" = p_AMST_Id 
        AND "LM"."MI_Id" = p_MI_Id
        AND "LM"."LMSLMEET_Id" NOT IN (
            SELECT DISTINCT "LMSLMEET_Id" 
            FROM "LMS_Live_Meeting_Student" 
            WHERE "LMSLMEETSTD_LogoutTime" IS NOT NULL
                AND "AMST_Id" = p_AMST_Id
        ) 
        AND ("LM"."LMSLMEET_PlannedDate"::date = p_MeetingDate::date 
            OR "LM"."LMSLMEET_MeetingDate"::date = p_MeetingDate::date) 
        AND ("LM"."LMSLMEET_EndTime" = '' OR "LM"."LMSLMEET_EndTime" IS NULL) 
        AND "LM"."LMSLMEET_ActiveFlg" = 1
    ORDER BY "LM"."lmslmeeT_CreatedDate" DESC;

END;
$$;