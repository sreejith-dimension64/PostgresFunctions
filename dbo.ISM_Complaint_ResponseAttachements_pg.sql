CREATE OR REPLACE FUNCTION "dbo"."ISM_Complaint_ResponseAttachements"(
    "@MI_Id" BIGINT,
    "@ISMTCR_Id" BIGINT
)
RETURNS TABLE(
    "ISMTCRRES_Response" TEXT,
    "ISMTCRRES_ResponseAttachment" TEXT,
    "ISMTCR_Id" BIGINT,
    "ISMTCRRES_Id" BIGINT,
    "ISMTCRRES_Status" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "ISMTCRRES_Response",
        "ISMTCRRES_ResponseAttachment",
        "ISMTCR_Id",
        "ISMTCRRES_Id",
        "ISMTCRRES_Status"
    FROM "ISM_TaskCreation_Response"
    WHERE "ISMTCR_Id" = "@ISMTCR_Id";
END;
$$;