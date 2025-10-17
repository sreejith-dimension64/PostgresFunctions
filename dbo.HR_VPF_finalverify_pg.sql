CREATE OR REPLACE FUNCTION "HR_VPF_finalverify"(
    p_HRME_Id bigint,
    p_IMFY_Id bigint
)
RETURNS TABLE (
    "HRME_Id" bigint,
    "IMFY_Id" bigint,
    "HREVPFST_ManuallyCheckedFlg" integer,
    "HREVPFST_Id" bigint,
    "HREVPFST_CreatedDate" timestamp,
    "HREVPFST_UpdatedDate" timestamp,
    "HREVPFST_CreatedBy" bigint,
    "HREVPFST_UpdatedBy" bigint,
    "HREVPFST_ActiveFlg" boolean
)
LANGUAGE plpgsql
AS $$
BEGIN

    UPDATE "HR_Employee_VPF_Status" 
    SET "HREVPFST_ManuallyCheckedFlg" = 1 
    WHERE "IMFY_Id" = p_IMFY_Id 
    AND "HRME_Id" = p_HRME_Id;

    RETURN QUERY
    SELECT 
        hevs."HRME_Id",
        hevs."IMFY_Id",
        hevs."HREVPFST_ManuallyCheckedFlg",
        hevs."HREVPFST_Id",
        hevs."HREVPFST_CreatedDate",
        hevs."HREVPFST_UpdatedDate",
        hevs."HREVPFST_CreatedBy",
        hevs."HREVPFST_UpdatedBy",
        hevs."HREVPFST_ActiveFlg"
    FROM "HR_Employee_VPF_Status" hevs
    WHERE hevs."IMFY_Id" = p_IMFY_Id 
    AND hevs."HRME_Id" = p_HRME_Id 
    AND hevs."HREVPFST_ManuallyCheckedFlg" = 1;

END;
$$;