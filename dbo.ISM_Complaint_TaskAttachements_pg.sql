CREATE OR REPLACE FUNCTION "dbo"."ISM_Complaint_TaskAttachements"(
    "MI_Id" BIGINT,
    "ISMTCR_Id" BIGINT
)
RETURNS TABLE(
    "ISMTCRAT_Attatchment" TEXT,
    "ISMTCR_Id" BIGINT,
    "ISMTCRAT_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "ISM_TaskCreation_Attachment"."ISMTCRAT_Attatchment",
        "ISM_TaskCreation_Attachment"."ISMTCR_Id",
        "ISM_TaskCreation_Attachment"."ISMTCRAT_Id"
    FROM "ISM_TaskCreation_Attachment"
    WHERE "ISM_TaskCreation_Attachment"."ISMTCR_Id" = "ISM_Complaint_TaskAttachements"."ISMTCR_Id";
END;
$$;