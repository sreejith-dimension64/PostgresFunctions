CREATE OR REPLACE FUNCTION "dbo"."DELETE_FEE_FOR_GENERAL_TC_TAKEN_STUDENTS"(
    p_MI_ID BIGINT,
    p_ASMAY_ID BIGINT,
    p_AMST_ID BIGINT,
    p_FLAG TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_FMA_ID BIGINT;
    v_FSS_ToBePaid BIGINT;
    v_FMH_ID BIGINT;
    v_FTI_ID BIGINT;
    v_FMG_ID BIGINT;
    v_FSS_ConcessionAmount BIGINT;
    yearly_fee_rec RECORD;
BEGIN

    FOR yearly_fee_rec IN 
        SELECT "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FSS_ToBePaid", "FSS_ConcessionAmount" 
        FROM "Fee_Student_Status" 
        WHERE "MI_Id" = p_MI_ID 
          AND "ASMAY_ID" = p_ASMAY_ID 
          AND "AMST_Id" = p_AMST_ID 
          AND "FSS_ToBePaid" > 0
    LOOP
        v_FMG_ID := yearly_fee_rec."FMG_Id";
        v_FMH_ID := yearly_fee_rec."FMH_Id";
        v_FTI_ID := yearly_fee_rec."FTI_Id";
        v_FMA_ID := yearly_fee_rec."FMA_Id";
        v_FSS_ToBePaid := yearly_fee_rec."FSS_ToBePaid";
        v_FSS_ConcessionAmount := yearly_fee_rec."FSS_ConcessionAmount";

        IF v_FSS_ConcessionAmount > 0 THEN

            DELETE FROM "Fee_Student_Concession_Installments" 
            WHERE "FTI_Id" = v_FTI_ID 
              AND "FSCI_FSC_Id" IN (
                  SELECT "FSC_ID" 
                  FROM "Fee_Student_Concession" 
                  WHERE "AMST_ID" = p_AMST_ID 
                    AND "MI_Id" = p_MI_ID 
                    AND "ASMAY_ID" = p_ASMAY_ID 
                    AND "FMG_Id" = v_FMG_ID 
                    AND "FMH_Id" = v_FMH_ID
              );

            DELETE FROM "FEE_STUDENT_CONCESSION" 
            WHERE "AMST_ID" = p_AMST_ID 
              AND "MI_Id" = p_MI_ID 
              AND "ASMAY_ID" = p_ASMAY_ID 
              AND "FMG_Id" = v_FMG_ID 
              AND "FMH_Id" = v_FMH_ID;

        END IF;

        DELETE FROM "Fee_Master_Student_Group_Installment" 
        WHERE "FMH_ID" = v_FMH_ID 
          AND "FTI_ID" = v_FTI_ID  
          AND "FMSG_Id" IN (
              SELECT "FMG_ID" 
              FROM "Fee_Master_Student_Group" 
              WHERE "FMG_Id" = v_FMG_ID 
                AND "AMST_Id" = p_AMST_ID
          );

        UPDATE "FEE_STUDENT_STATUS" 
        SET "FSS_TotalToBePaid" = 0,
            "FSS_ToBePaid" = 0,
            "FSS_ConcessionAmount" = 0 
        WHERE "MI_Id" = p_MI_ID 
          AND "ASMAY_Id" = p_ASMAY_ID 
          AND "AMST_Id" = p_AMST_ID 
          AND "FMA_Id" = v_FMA_ID 
          AND "FMH_Id" = v_FMH_ID 
          AND "FTI_Id" = v_FTI_ID 
          AND "FMG_Id" = v_FMG_ID;

    END LOOP;

    RETURN;

END;
$$;