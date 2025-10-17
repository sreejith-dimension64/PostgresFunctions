CREATE OR REPLACE FUNCTION "dbo"."concessionapproval"(
    "@fmccid" BIGINT,
    "@pasrid" BIGINT,
    "@miid" BIGINT,
    "@asmayid" BIGINT,
    "@classid" VARCHAR(50),
    "@studname" VARCHAR(250),
    "@regno" VARCHAR(100),
    "@pasrsid" BIGINT,
    "@concessionstatus" VARCHAR(50)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_rowcount INTEGER;
BEGIN
    IF "@concessionstatus" = 'C' THEN
        SELECT * FROM "Adm_M_Student" WHERE "AMST_RegistrationNo" = "@regno";
        GET DIAGNOSTICS v_rowcount = ROW_COUNT;
        
        IF v_rowcount > 0 THEN
            INSERT INTO "Preadmission_School_Registration_Concession_Status" 
                ("PASR_ID", "PASRS_Id", "Flag") 
            VALUES 
                ("@pasrid", "@pasrsid", 'C');
            RAISE NOTICE 'sucess';
        END IF;
    END IF;
END;
$$;