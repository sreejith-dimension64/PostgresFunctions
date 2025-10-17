CREATE OR REPLACE FUNCTION "dbo"."Feecard_Insert"(
    p_MI_Id bigint,
    p_AMST_Id bigint,
    p_ASMAY_Id bigint,
    p_FMH_Id bigint,
    p_FMG_Id bigint,
    p_Amount bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_Amountnew bigint;
    v_rowcount integer;
BEGIN
    SELECT "FSFM_Amount" INTO v_Amountnew
    FROM "Fee_Student_FeeMapping"
    WHERE "AMST_Id" = p_AMST_Id;
    
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    
    IF v_rowcount > 0 THEN
        INSERT INTO "Fee_Student_FeeMapping"(
            "MI_Id",
            "AMST_Id",
            "ASMAY_Id",
            "FMH_Id",
            "FMG_Id",
            "FTI_Id",
            "FSFM_Amount",
            "FSFM_PaidAmount",
            "CreatedDate",
            "UpdatedDate"
        )
        VALUES(
            p_MI_Id,
            p_AMST_Id,
            p_ASMAY_Id,
            p_FMH_Id,
            p_FMG_Id,
            5,
            p_Amount + v_Amountnew,
            p_Amount,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        );
    ELSE
        INSERT INTO "Fee_Student_FeeMapping"(
            "MI_Id",
            "AMST_Id",
            "ASMAY_Id",
            "FMH_Id",
            "FMG_Id",
            "FTI_Id",
            "FSFM_Amount",
            "FSFM_PaidAmount",
            "CreatedDate",
            "UpdatedDate"
        )
        VALUES(
            p_MI_Id,
            p_AMST_Id,
            p_ASMAY_Id,
            p_FMH_Id,
            p_FMG_Id,
            5,
            p_Amount,
            p_Amount,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        );
    END IF;
END;
$$;