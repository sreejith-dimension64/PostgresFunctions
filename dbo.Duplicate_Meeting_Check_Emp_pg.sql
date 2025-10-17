CREATE OR REPLACE FUNCTION "dbo"."Duplicate_Meeting_Check_Emp"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "HRME_ID" bigint,
    "PLANNEDDATE" timestamp,
    "STARTTIME" varchar(30),
    "ENDTIME" varchar(30)
)
RETURNS TABLE(
    "lmslmeeT_Id" bigint,
    "lmslmeeT_MeetingId" varchar,
    "HRME_Id" bigint,
    "lmslmeeT_CreatedDate" timestamp,
    "lmslmeeT_EndTime" varchar,
    "MeetingDate" varchar,
    "PlanDate" varchar,
    "lmslmeeT_MeetingDate" timestamp,
    "asmcL_ClassName" varchar,
    "asmC_SectionName" varchar,
    "ismS_IVRSSubjectName" varchar,
    "lmslmeeT_MeetingTopic" text,
    "lmslmeeT_StartedTime" varchar,
    "lmslmeeT_RecordId" varchar,
    "lmslmeeT_ActiveFlg" boolean,
    "lmslmeeT_CreatedBy" bigint,
    "lmslmeeT_PlannedDate" timestamp,
    "lmslmeeT_PlannedEndTime" varchar,
    "lmslmeeT_PlannedStartTime" varchar,
    "lmslmeeT_UpdatedDate" timestamp,
    "EmpName" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    "STARTTIME_N" bigint;
    "ENDTIME_N" bigint;
BEGIN

    "STARTTIME_N" := "dbo"."getonlymin"("STARTTIME");
    "ENDTIME_N" := "dbo"."getonlymin"("ENDTIME");

    RETURN QUERY
    SELECT 
        a."lmslmeeT_Id",
        a."lmslmeeT_MeetingId",
        a."HRME_Id",
        a."lmslmeeT_CreatedDate",
        a."lmslmeeT_EndTime",
        TO_CHAR(a."lmslmeeT_MeetingDate", 'DD-MM-YYYY') as "MeetingDate",
        TO_CHAR(a."lmslmeeT_PlannedDate", 'DD-MM-YYYY') as "PlanDate",
        a."lmslmeeT_MeetingDate",
        d."asmcL_ClassName",
        e."asmC_SectionName",
        f."ismS_IVRSSubjectName",
        a."lmslmeeT_MeetingTopic",
        a."lmslmeeT_StartedTime",
        a."lmslmeeT_RecordId",
        a."lmslmeeT_ActiveFlg",
        a."lmslmeeT_CreatedBy",
        a."lmslmeeT_PlannedDate",
        a."lmslmeeT_PlannedEndTime",
        a."lmslmeeT_PlannedStartTime",
        a."lmslmeeT_UpdatedDate",
        COALESCE(b."HRME_EmployeeFirstName", '') || ' ' || COALESCE(b."HRME_EmployeeMiddleName", '') || ' ' || COALESCE(b."HRME_EmployeeLastName", '') AS "EmpName"
    FROM "LMS_Live_Meeting" a 
    INNER JOIN "HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id"
    INNER JOIN "LMS_Live_Meeting_Class" c ON a."lmslmeeT_Id" = c."lmslmeeT_Id"
    INNER JOIN "Adm_School_M_Class" d ON c."ASMCL_Id" = d."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" e ON c."ASMS_Id" = e."ASMS_Id"
    INNER JOIN "IVRM_Master_Subjects" f ON c."ISMS_Id" = f."ISMS_Id"
    WHERE a."MI_Id" = "MI_Id" 
        AND a."HRME_Id" = "HRME_ID" 
        AND CAST(a."LMSLMEET_PlannedDate" AS date) = CAST("PLANNEDDATE" AS date)
        AND a."LMSLMEET_ActiveFlg" = true
        AND ((
            "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedStartTime" AS time)) >= "STARTTIME_N" 
            AND "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedStartTime" AS time)) <= "ENDTIME_N"
            OR "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedEndTime" AS time)) >= "STARTTIME_N" 
            AND "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedEndTime" AS time)) <= "ENDTIME_N"
        )
        OR (
            "STARTTIME_N" BETWEEN "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedStartTime" AS time)) 
                AND "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedEndTime" AS time))
            OR "ENDTIME_N" BETWEEN "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedStartTime" AS time)) 
                AND "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedEndTime" AS time))
        ));

    RETURN;
END;
$$;