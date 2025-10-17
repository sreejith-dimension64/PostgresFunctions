CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Yearly_Group_Head_Mapping"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "FMG_Id" bigint,
    "FMH_Id" bigint,
    "FMI_Id" bigint,
    "FYGHM_FineApplicableFlag" varchar(50),
    "FYGHM_Common_AmountFlag" varchar(50),
    "FYGHM_ActiveFlag" varchar(10),
    "FYGHM_Id" bigint,
    "User_id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_rowcount integer;
BEGIN
    RAISE NOTICE 'sucess';

    IF ("FYGHM_Id" = 0) THEN
        
        SELECT COUNT(*) INTO v_rowcount
        FROM "Fee_Yearly_Group_Head_Mapping"
        WHERE "ASMAY_Id" = "ASMAY_Id" 
            AND "FMG_Id" = "FMG_Id" 
            AND "FMH_Id" = "FMH_Id" 
            AND "FMI_Id" = "FMI_Id";

        IF v_rowcount = 0 THEN
            INSERT INTO "Fee_Yearly_Group_Head_Mapping" (
                "MI_Id",
                "ASMAY_Id",
                "FMG_Id",
                "FMH_Id",
                "FMI_Id",
                "FYGHM_FineApplicableFlag",
                "FYGHM_Common_AmountFlag",
                "FYGHM_ActiveFlag",
                "FYGHM_CreatedBy",
                "FYGHM_UpdatedBy"
            )
            VALUES (
                "MI_Id",
                "ASMAY_Id",
                "FMG_Id",
                "FMH_Id",
                "FMI_Id",
                "FYGHM_FineApplicableFlag",
                "FYGHM_Common_AmountFlag",
                "FYGHM_ActiveFlag",
                "User_id",
                "User_id"
            );
        END IF;

    ELSIF ("FYGHM_Id" > 0) THEN

        UPDATE "Fee_Yearly_Group_Head_Mapping"
        SET "FMG_Id" = "FMG_Id",
            "FMH_Id" = "FMH_Id",
            "FMI_Id" = "FMI_Id",
            "FYGHM_ActiveFlag" = "FYGHM_ActiveFlag",
            "FYGHM_Common_AmountFlag" = "FYGHM_Common_AmountFlag",
            "FYGHM_FineApplicableFlag" = "FYGHM_FineApplicableFlag",
            "FYGHM_UpdatedBy" = "User_id"
        WHERE "FYGHM_Id" = "FYGHM_Id";

    END IF;

    RETURN;
END;
$$;