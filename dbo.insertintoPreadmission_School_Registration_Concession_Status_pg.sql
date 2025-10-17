CREATE OR REPLACE FUNCTION "dbo"."insertintoPreadmission_School_Registration_Concession_Status"(
    "@PASR_ID" bigint,
    "@PASRS_Id" bigint,
    "@flag" boolean
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_row_count integer;
BEGIN
    SELECT COUNT(*) INTO v_row_count
    FROM "Preadmission_School_Registration_Concession_Status"
    WHERE "PASR_ID" = "@PASRS_Id" 
        AND "Flag" = "@flag" 
        AND "PASRS_Id" = "@PASRS_Id";

    IF v_row_count <= 0 THEN
        INSERT INTO "Preadmission_School_Registration_Concession_Status" 
            ("PASR_ID", "PASRS_Id", "Flag")
        VALUES 
            ("@PASR_ID", "@PASRS_Id", "@flag");
    END IF;

    RETURN;
END;
$$;