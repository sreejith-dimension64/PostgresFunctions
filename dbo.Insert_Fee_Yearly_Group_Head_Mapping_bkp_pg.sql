CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Yearly_Group_Head_Mapping_bkp"(
    "p_MI_Id" bigint,
    "p_ASMAY_Id" bigint,
    "p_FMG_Id" bigint,
    "p_FMH_Id" bigint,
    "p_FMI_Id" bigint,
    "p_FYGHM_FineApplicableFlag" varchar(50),
    "p_FYGHM_Common_AmountFlag" varchar(50),
    "p_FYGHM_ActiveFlag" varchar(10),
    "p_FYGHM_Id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_row_count integer;
BEGIN
    RAISE NOTICE 'sucess';
    
    IF "p_FYGHM_Id" = 0 THEN
        
        SELECT COUNT(*) INTO v_row_count
        FROM "Fee_Yearly_Group_Head_Mapping"
        WHERE "ASMAY_Id" = "p_ASMAY_Id"
            AND "FMG_Id" = "p_FMG_Id"
            AND "FMH_Id" = "p_FMH_Id"
            AND "FMI_Id" = "p_FMI_Id";
        
        IF v_row_count = 0 THEN
            INSERT INTO "Fee_Yearly_Group_Head_Mapping" (
                "MI_Id",
                "ASMAY_Id",
                "FMG_Id",
                "FMH_Id",
                "FMI_Id",
                "FYGHM_FineApplicableFlag",
                "FYGHM_Common_AmountFlag",
                "FYGHM_ActiveFlag"
            )
            VALUES (
                "p_MI_Id",
                "p_ASMAY_Id",
                "p_FMG_Id",
                "p_FMH_Id",
                "p_FMI_Id",
                "p_FYGHM_FineApplicableFlag",
                "p_FYGHM_Common_AmountFlag",
                "p_FYGHM_ActiveFlag"
            );
        END IF;
        
    ELSIF "p_FYGHM_Id" > 0 THEN
        
        UPDATE "Fee_Yearly_Group_Head_Mapping"
        SET "FMG_Id" = "p_FMG_Id",
            "FMH_Id" = "p_FMH_Id",
            "FMI_Id" = "p_FMI_Id",
            "FYGHM_ActiveFlag" = "p_FYGHM_ActiveFlag",
            "FYGHM_Common_AmountFlag" = "p_FYGHM_Common_AmountFlag",
            "FYGHM_FineApplicableFlag" = "p_FYGHM_FineApplicableFlag"
        WHERE "FYGHM_Id" = "p_FYGHM_Id";
        
    END IF;
    
END;
$$;