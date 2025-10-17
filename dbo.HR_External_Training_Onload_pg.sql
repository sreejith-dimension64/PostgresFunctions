CREATE OR REPLACE FUNCTION "dbo"."HR_External_Training_Onload"(
    "MI_ID" TEXT
)
RETURNS TABLE(
    "HREXTTRN_TrainingTopic" TEXT,
    "HRMETRTY_ExternalTrainingType" TEXT,
    "HRMETRCEN_TrainingCenterName" TEXT,
    "HREXTTRN_StartDate" TIMESTAMP,
    "HREXTTRN_EndDate" TIMESTAMP,
    "HREXTTRN_StartTime" TIME,
    "HREXTTRN_EndTime" TIME,
    "HREXTTRN_ActiveFlag" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."HREXTTRN_TrainingTopic",
        b."HRMETRTY_ExternalTrainingType",
        c."HRMETRCEN_TrainingCenterName",
        a."HREXTTRN_StartDate",
        a."HREXTTRN_EndDate",
        a."HREXTTRN_StartTime",
        a."HREXTTRN_EndTime",
        a."HREXTTRN_ActiveFlag"
    FROM "HR_External_Training" a
    INNER JOIN "HR_Master_External_TrainingType" b ON a."HRMETRTY_Id" = b."HRMETRTY_Id"
    INNER JOIN "HR_Master_External_TrainingCenters" c ON a."HRMETRCEN_Id" = c."HRMETRCEN_Id"
    WHERE a."MI_Id" = "MI_ID";
END;
$$;