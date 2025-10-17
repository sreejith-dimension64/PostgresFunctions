CREATE OR REPLACE FUNCTION "dbo"."HR_External_Training_stafftrainingreport"(
    p_MI_Id bigint,
    p_UserId bigint
)
RETURNS TABLE(
    "hrexttrN_TrainingTopic" VARCHAR,
    "hrexttrN_CertificateFileName" VARCHAR,
    "hrmetrceN_CenterAddress" VARCHAR,
    "hrexttrN_StartDate" TIMESTAMP,
    "hrexttrN_EndDate" TIMESTAMP,
    "hrexttrN_TotalHrs" NUMERIC,
    "HRMETRCEN_TrainingCenterName" VARCHAR,
    "hrmetrtY_ExternalTrainingType" VARCHAR,
    "hrexttrN_ApprovedFlg" BOOLEAN,
    "hrexttrN_EndTime" TIME,
    "hrexttrN_StartTime" TIME
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."HREXTTRN_TrainingTopic" as "hrexttrN_TrainingTopic",
        a."HREXTTRN_CertificateFileName" as "hrexttrN_CertificateFileName",
        b."HRMETRCEN_CenterAddress" as "hrmetrceN_CenterAddress",
        a."HREXTTRN_StartDate" as "hrexttrN_StartDate",
        a."HREXTTRN_EndDate" as "hrexttrN_EndDate",
        a."HREXTTRN_TotalHrs" as "hrexttrN_TotalHrs",
        b."HRMETRCEN_TrainingCenterName",
        e."HRMETRTY_ExternalTrainingType" as "hrmetrtY_ExternalTrainingType",
        a."HREXTTRN_ApprovedFlg" as "hrexttrN_ApprovedFlg",
        a."HREXTTRN_EndTime" as "hrexttrN_EndTime",
        a."HREXTTRN_StartTime" as "hrexttrN_StartTime"
    FROM "HR_External_Training" a
    INNER JOIN "HR_Master_External_TrainingCenters" b ON a."HRMETRCEN_Id" = b."HRMETRCEN_Id"
    INNER JOIN "HR_Master_External_TrainingType" e ON e."HRMETRTY_Id" = a."HRMETRTY_Id"
    INNER JOIN "IVRM_Staff_User_Login" f ON f."Emp_Code" = a."HRME_Id"
    WHERE f."Id" = p_UserId AND a."MI_Id" = p_MI_Id;
END;
$$;