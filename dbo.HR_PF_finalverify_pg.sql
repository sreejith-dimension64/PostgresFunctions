CREATE OR REPLACE FUNCTION "HR_PF_finalverify"(
    p_HRME_Id bigint,
    p_IMFY_Id bigint
)
RETURNS TABLE(
    "HRME_Id" bigint,
    "IMFY_Id" bigint,
    "HREPFST_ManuallyCheckedFlg" integer,
    "HREPFST_Id" bigint,
    "HREPFST_CreatedDate" timestamp,
    "HREPFST_UpdatedDate" timestamp,
    "HREPFST_CreatedBy" bigint,
    "HREPFST_UpdatedBy" bigint,
    "HREPFST_ActiveFlg" boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "HR_Employee_PF_Status" 
    SET "HREPFST_ManuallyCheckedFlg" = 1 
    WHERE "IMFY_Id" = p_IMFY_Id 
    AND "HRME_Id" = p_HRME_Id;

    RETURN QUERY
    SELECT 
        heps."HRME_Id",
        heps."IMFY_Id",
        heps."HREPFST_ManuallyCheckedFlg",
        heps."HREPFST_Id",
        heps."HREPFST_CreatedDate",
        heps."HREPFST_UpdatedDate",
        heps."HREPFST_CreatedBy",
        heps."HREPFST_UpdatedBy",
        heps."HREPFST_ActiveFlg"
    FROM "HR_Employee_PF_Status" heps
    WHERE heps."IMFY_Id" = p_IMFY_Id 
    AND heps."HRME_Id" = p_HRME_Id 
    AND heps."HREPFST_ManuallyCheckedFlg" = 1;
END;
$$;