CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_CollegeStudent_Map"(
    p_FMG_Id bigint,
    p_AMCST_Id bigint,
    p_MI_Id bigint,
    p_FTI_Id_new bigint,
    p_FMH_Id_new bigint,
    p_userid bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_FCMSGH_Id bigint;
    v_FCMSGHI_Id bigint;
    v_FTI_Name varchar(100);
    v_FCMAS_Amount numeric;
    v_FMH_Name varchar(100);
    v_ASMAY_Id bigint;
    v_FMG_Id_new bigint;
    v_FYGHM_Id bigint;
    v_FSCI_ConcessionAmount bigint;
    v_FMH_Id bigint;
    v_FTI_Id bigint;
    v_FCMAS_Id bigint;
    v_AMSE_Id bigint;
    v_FCMA_Id bigint;
    v_rowcount int;
    yearly_fee_rec RECORD;
    fee_det_rec RECORD;
BEGIN
    v_FCMSGH_Id := 0;
    v_FCMSGHI_Id := 0;
    v_FTI_Name := '';
    v_FCMAS_Amount := 0;
    v_FMH_Name := '';
    v_ASMAY_Id := 0;
    v_FSCI_ConcessionAmount := 0;
    v_FCMAS_Id := 0;
    v_FCMA_Id := 0;

    v_ASMAY_Id := 11;

    PERFORM * FROM "CLG"."Fee_College_Master_Student_GroupHead" 
    WHERE "ASMAY_Id" = v_ASMAY_Id 
        AND "FMG_Id" = p_FMG_Id 
        AND "MI_Id" = p_MI_Id 
        AND "AMCST_Id" = p_AMCST_Id;
    
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;
    
    IF v_rowcount = 0 THEN
        RAISE NOTICE 'a';
        INSERT INTO "Clg"."Fee_College_Master_Student_GroupHead" 
            ("MI_Id", "AMCST_Id", "ASMAY_Id", "FMG_Id", "FCMSGH_ActiveFlag") 
        VALUES 
            (p_MI_Id, p_AMCST_Id, v_ASMAY_Id, p_FMG_Id, 'Y');
    END IF;

    BEGIN
        SELECT "FCMSGH_Id" INTO v_FCMSGH_Id 
        FROM "CLG"."Fee_College_Master_Student_GroupHead" 
        WHERE "ASMAY_Id" = v_ASMAY_Id 
            AND "FMG_Id" = p_FMG_Id 
            AND "MI_Id" = p_MI_Id 
            AND "AMCST_Id" = p_AMCST_Id;
        
        RAISE NOTICE '%', v_FCMSGH_Id;
        RAISE NOTICE 'e';
        RAISE NOTICE '% % %', v_FCMSGH_Id, p_FMH_Id_new, p_FTI_Id_new;
        
        INSERT INTO "Clg"."Fee_C_Master_Student_GroupHead_Installments" 
            ("FCMSGH_Id", "FMH_ID", "FTI_ID") 
        VALUES 
            (v_FCMSGH_Id, p_FMH_Id_new, p_FTI_Id_new);

        SELECT "FCMSGHI_Id" INTO v_FCMSGHI_Id 
        FROM "CLG"."Fee_C_Master_Student_GroupHead_Installment" 
        WHERE "FCMSGH_Id" = v_FCMSGH_Id;

        RAISE NOTICE '%', v_FCMSGHI_Id;
        RAISE NOTICE 'd';

        RAISE NOTICE 'b';

        FOR yearly_fee_rec IN
            SELECT "FYGHM_Id", "FMG_Id", "FMH_Id" 
            FROM "Fee_Yearly_Group_Head_Mapping" 
            WHERE "FMG_Id" = p_FMG_Id 
                AND "FYGHM_ActiveFlag" = 1 
                AND "ASMAY_Id" = v_ASMAY_Id 
                AND "FMH_Id" = p_FMH_Id_new 
                AND "FMI_Id" IN (
                    SELECT "FMI_Id" 
                    FROM "Fee_T_Installment" 
                    WHERE "FTI_Id" = p_FTI_Id_new
                )
        LOOP
            v_FYGHM_Id := yearly_fee_rec."FYGHM_Id";
            v_FMG_Id_new := yearly_fee_rec."FMG_Id";
            v_FMH_Id := yearly_fee_rec."FMH_Id";
            
            RAISE NOTICE 'c';

            FOR fee_det_rec IN
                SELECT "FCMAS"."FCMAS_Id", "FCMA"."FTI_Id", "FTI"."FTI_Name", "FCMAS"."FCMAS_Amount" 
                FROM "CLG"."Fee_College_Master_Amount" "FCMA" 
                INNER JOIN "Fee_Master_Group" "FMG" ON "FCMA"."FMG_Id" = "FMG"."FMG_Id"
                INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" "FCMAS" ON "FCMAS"."FCMA_Id" = "FCMA"."FCMA_Id"
                INNER JOIN "fee_t_installment" "FTI" ON "FCMA"."fti_id" = "FTI"."fti_id"
                WHERE "FCMA"."FMG_Id" = v_FMG_Id_new 
                    AND "FCMA"."FMH_Id" = p_FMH_Id_new 
                    AND "FCMA"."FTI_Id" = p_FTI_Id_new 
                    AND "FCMA"."ASMAY_Id" = v_ASMAY_Id 
                    AND "FCMA"."MI_Id" = p_MI_Id
            LOOP
                v_FCMAS_Id := fee_det_rec."FCMAS_Id";
                v_FTI_Id := fee_det_rec."FTI_Id";
                v_FTI_Name := fee_det_rec."FTI_Name";
                v_FCMAS_Amount := fee_det_rec."FCMAS_Amount";

                SELECT "FMH_FeeName" INTO v_FMH_Name 
                FROM "Fee_Master_Head" 
                WHERE "FMH_Id" = p_FMH_Id_new;

                PERFORM * FROM "CLG"."Fee_College_Student_Status" 
                WHERE "AMCST_Id" = p_AMCST_Id 
                    AND "FMG_Id" = v_FMG_Id_new 
                    AND "FMH_Id" = p_FMH_Id_new 
                    AND "FCMAS_Id" = v_FCMAS_Id;

                SELECT "FSCI"."FSCI_ConcessionAmount" INTO v_FSCI_ConcessionAmount 
                FROM "CLG"."Fee_College_Student_Concession" "FCSC" 
                INNER JOIN "CLG"."Fee_C_Student_Concession_Installments" "FSCI" ON "FCSC"."FCSC_Id" = "FSCI"."FCSC_Id" 
                WHERE "AMCST_Id" = p_AMCST_Id 
                    AND "FMH_Id" = p_FMH_Id_new 
                    AND "FTI_Id" = p_FTI_Id_new 
                    AND "FMG_Id" = p_FMG_Id 
                    AND "MI_Id" = p_MI_Id;

                IF NOT FOUND THEN
                    v_FSCI_ConcessionAmount := 0;
                END IF;

                RAISE NOTICE '%', v_FSCI_ConcessionAmount;

                PERFORM * FROM "CLG"."Fee_College_Student_Status" 
                WHERE "AMCST_Id" = p_AMCST_Id 
                    AND "FMG_Id" = v_FMG_Id_new 
                    AND "FMH_Id" = p_FMH_Id_new 
                    AND "FCMAS_Id" = v_FCMAS_Id;
                
                GET DIAGNOSTICS v_rowcount = ROW_COUNT;

                IF v_rowcount = 0 THEN
                    RAISE NOTICE 'b';
                    
                    INSERT INTO "CLG"."Fee_College_Student_Status"(
                        "MI_Id", "ASMAY_Id", "AMCST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FCMAS_Id", 
                        "FCSS_OBArrearAmount", "FCSS_OBExcessAmount", "FCSS_CurrentYrCharges", 
                        "FCSS_TotalCharges", "FCSS_ToBePaid", "FCSS_PaidAmount", "FCSS_ExcessPaidAmount", 
                        "FCSS_ExcessAmountAdjusted", "FCSS_RunningExcessAmount", "FCSS_ConcessionAmount", 
                        "FCSS_AdjustedAmount", "FCSS_WaivedAmount", "FCSS_RebateAmount", "FCSS_FineAmount", 
                        "FCSS_RefundAmount", "FCSS_RefundAmountAdjusted", "FCSS_NetAmount", 
                        "FCSS_ArrearFlag", "FCSS_RefundOverFlag", "FCSS_ActiveFlag", "User_Id", 
                        "FCSS_RefundableAmount"
                    ) 
                    VALUES(
                        p_MI_Id, v_ASMAY_Id, p_AMCST_Id, p_FMG_Id, p_FMH_Id_new, p_FTI_Id_new, v_FCMAS_Id, 
                        0, 0, v_FCMAS_Amount, v_FCMAS_Amount, v_FCMAS_Amount, 0, 0, 0, 0, 
                        v_FSCI_ConcessionAmount, 0, 0, 0, 0, 0, 0, v_FCMAS_Amount, 0, 0, 1, 
                        p_userid, 0
                    );

                    PERFORM "UpdateCollegeStudPaidAmt"(p_AMCST_Id, v_FCMAS_Id, p_MI_Id);
                ELSE
                    PERFORM "UpdateCollegeStudPaidAmt"(p_AMCST_Id, v_FCMAS_Id, p_MI_Id);
                END IF;
            END LOOP;
        END LOOP;

        COMMIT;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE NOTICE 'ErrorNumber: %', SQLSTATE;
            RAISE NOTICE 'ErrorMessage: %', SQLERRM;
            RAISE;
    END;

    RETURN;
END;
$$;