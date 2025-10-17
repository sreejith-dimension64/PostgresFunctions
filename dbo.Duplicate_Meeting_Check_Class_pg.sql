CREATE OR REPLACE FUNCTION "dbo"."Duplicate_Meeting_Check_Class"(
    "p_MI_Id" bigint,
    "p_ASMAY_Id" bigint,
    "p_PLANNEDDATE" timestamp,
    "p_STARTTIME" varchar(30),
    "p_ENDTIME" varchar(30),
    "p_ASMCL_Id" bigint,
    "p_ASMS_Id" bigint
)
RETURNS TABLE(
    "lmslmeeT_Id" bigint,
    "lmslmeeT_MeetingId" text,
    "HRME_Id" bigint,
    "lmslmeeT_CreatedDate" timestamp,
    "lmslmeeT_EndTime" timestamp,
    "MeetingDate" varchar,
    "PlanDate" varchar,
    "lmslmeeT_MeetingDate" timestamp,
    "asmcL_ClassName" text,
    "asmC_SectionName" text,
    "ismS_IVRSSubjectName" text,
    "lmslmeeT_MeetingTopic" text,
    "lmslmeeT_StartedTime" timestamp,
    "lmslmeeT_RecordId" text,
    "lmslmeeT_ActiveFlg" boolean,
    "lmslmeeT_CreatedBy" bigint,
    "lmslmeeT_PlannedDate" timestamp,
    "lmslmeeT_PlannedEndTime" timestamp,
    "lmslmeeT_PlannedStartTime" timestamp,
    "lmslmeeT_UpdatedDate" timestamp,
    "EmpName" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_STARTTIME_N" bigint;
    "v_ENDTIME_N" bigint;
BEGIN
    "v_STARTTIME_N" := "dbo"."getonlymin"("p_STARTTIME");
    "v_ENDTIME_N" := "dbo"."getonlymin"("p_ENDTIME");

    RETURN QUERY
    SELECT 
        a."lmslmeeT_Id",
        a."lmslmeeT_MeetingId",
        a."HRME_Id",
        a."lmslmeeT_CreatedDate",
        a."lmslmeeT_EndTime",
        TO_CHAR(a."lmslmeeT_MeetingDate", 'DD-MM-YYYY') AS "MeetingDate",
        TO_CHAR(a."lmslmeeT_PlannedDate", 'DD-MM-YYYY') AS "PlanDate",
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
    FROM "dbo"."LMS_Live_Meeting" a
    INNER JOIN "dbo"."HR_Master_Employee" b ON a."HRME_Id" = b."HRME_Id"
    INNER JOIN "dbo"."LMS_Live_Meeting_Class" c ON a."lmslmeeT_Id" = c."lmslmeeT_Id"
    INNER JOIN "dbo"."Adm_School_M_Class" d ON c."ASMCL_Id" = d."ASMCL_Id"
    INNER JOIN "dbo"."Adm_School_M_Section" e ON c."ASMS_Id" = e."ASMS_Id"
    INNER JOIN "dbo"."IVRM_Master_Subjects" f ON c."ISMS_Id" = f."ISMS_Id"
    WHERE CAST(a."LMSLMEET_PlannedDate" AS date) = CAST("p_PLANNEDDATE" AS date)
    AND c."ASMCL_Id" = "p_ASMCL_Id"
    AND c."ASMS_Id" = "p_ASMS_Id"
    AND a."LMSLMEET_ActiveFlg" = true
    AND (
        (
            "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedStartTime" AS time)) >= "v_STARTTIME_N" 
            AND "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedStartTime" AS time)) <= "v_ENDTIME_N"
            OR "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedEndTime" AS time)) >= "v_STARTTIME_N" 
            AND "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedEndTime" AS time)) <= "v_ENDTIME_N"
        )
        OR (
            "v_STARTTIME_N" BETWEEN "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedStartTime" AS time)) 
            AND "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedEndTime" AS time))
            OR "v_ENDTIME_N" BETWEEN "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedStartTime" AS time)) 
            AND "dbo"."getonlymin"(CAST(a."LMSLMEET_PlannedEndTime" AS time))
        )
    );

    RETURN;
END;
$$;