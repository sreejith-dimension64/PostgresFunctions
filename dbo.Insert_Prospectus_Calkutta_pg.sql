CREATE OR REPLACE FUNCTION "dbo"."Insert_Prospectus_Calkutta"(
    "PASP_DateOfBirth" TIMESTAMP,
    "PASP_Id" BIGINT,
    "PASP_FatherName" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE "dbo"."Preadmission_School_Prospectus" 
    SET "PASP_FatherName" = "PASP_FatherName",
        "PASP_DateOfBirth" = "PASP_DateOfBirth" 
    WHERE "PASP_Id" = "PASP_Id";
    
    RETURN;
END;
$$;