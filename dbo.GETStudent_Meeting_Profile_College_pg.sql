CREATE OR REPLACE FUNCTION "dbo"."GETStudent_Meeting_Profile_College"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "AMCST_Id" bigint,
    "MeetingDate" varchar(10)
)
RETURNS TABLE(
    "AMCST_Id" bigint,
    "lmslmeeT_Id" bigint,
    "LMSLMEET_MeetingId" varchar,
    "EmpName" text,
    "lmslmeeT_PlannedDate" varchar,
    "lmslmeeT_PlannedStartTime" varchar,
    "lmslmeeT_PlannedEndTime" varchar,
    "lmslmeeT_MeetingDate" varchar,
    "lmslmeeT_EndTime" varchar,
    "lmslmeeT_StartedTime" varchar,
    "lmslmeeT_MeetingId" varchar,
    "lmslmeeT_MeetingTopic" varchar,
    "student" text
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        "YS"."AMCST_Id",
        "LM"."LMSLMEET_Id" as "lmslmeeT_Id",
        "LM"."LMSLMEET_MeetingId",
        COALESCE("HME"."HRME_EmployeeFirstName",'')||' '||COALESCE("HME"."HRME_EmployeeMiddleName",'')||' '||COALESCE("HME"."HRME_EmployeeLastName",'') AS "EmpName",
        "LM"."LMSLMEET_PlannedDate" as "lmslmeeT_PlannedDate",
        "LM"."LMSLMEET_PlannedStartTime" as "lmslmeeT_PlannedStartTime",
        "LM"."LMSLMEET_PlannedEndTime" as "lmslmeeT_PlannedEndTime",
        "LM"."LMSLMEET_MeetingDate" as "lmslmeeT_MeetingDate",
        "LM"."LMSLMEET_EndTime" as "lmslmeeT_EndTime",
        "LM"."LMSLMEET_StartedTime" as "lmslmeeT_StartedTime",
        "LM"."LMSLMEET_MeetingId" as "lmslmeeT_MeetingId",
        "LM"."LMSLMEET_MeetingTopic" as "lmslmeeT_MeetingTopic",
        COALESCE("AM"."AMCST_FirstName",'')||' '||COALESCE("AM"."AMCST_MiddleName",'')||' '||COALESCE("AM"."AMCST_LastName",'') AS "student"
    FROM "LMS_Live_Meeting" "LM"
    INNER JOIN "HR_Master_Employee" "HME" ON "LM"."HRME_Id"="HME"."HRME_Id" AND "LM"."MI_Id"="HME"."MI_Id"
    INNER JOIN "LMS_Live_Meeting_CourseBranch" "LMC" ON "LMC"."LMSLMEET_Id"="LM"."LMSLMEET_Id"
    INNER JOIN "clg"."Adm_College_Yearly_Student" "YS" ON "YS"."ASMAY_Id"="LMC"."ASMAY_Id" 
        AND "YS"."AMCO_Id"="LMC"."AMCO_Id" 
        AND "YS"."AMB_Id"="LMC"."AMB_Id" 
        AND "YS"."AMSE_Id"="LMC"."AMSE_Id" 
        AND "YS"."ACMS_Id"="LMC"."ACMS_Id"
    INNER JOIN "CLG"."Adm_Master_College_Student" "AM" ON "AM"."AMCST_Id"="YS"."AMCST_Id"
    WHERE "YS"."ACYST_ActiveFlag"=1 
        AND "YS"."ASMAY_Id"="GETStudent_Meeting_Profile_College"."ASMAY_Id" 
        AND "YS"."AMCST_Id"="GETStudent_Meeting_Profile_College"."AMCST_Id" 
        AND "LM"."MI_Id"="GETStudent_Meeting_Profile_College"."MI_Id"
        AND "LM"."LMSLMEET_Id" NOT IN (
            SELECT DISTINCT "LMSLMEET_Id" 
            FROM "LMS_Live_Meeting_Student_College" 
            WHERE "LMSLMEETSTDCOL_LogoutTime" IS NOT NULL
                AND "AMCST_Id"="GETStudent_Meeting_Profile_College"."AMCST_Id"
        ) 
        AND ("LM"."LMSLMEET_PlannedDate"="GETStudent_Meeting_Profile_College"."MeetingDate" 
            OR "LM"."LMSLMEET_MeetingDate"="GETStudent_Meeting_Profile_College"."MeetingDate") 
        AND ("LM"."LMSLMEET_EndTime"='' OR "LM"."LMSLMEET_EndTime" IS NULL)
    ORDER BY "LM"."LMSLMEET_Id" DESC;

END;
$$;