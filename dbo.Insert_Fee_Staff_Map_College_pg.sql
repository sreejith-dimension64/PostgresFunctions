CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Staff_Map_College"(
    p_FMG_Id bigint,
    p_HRME_Id bigint,
    p_MI_Id bigint,
    p_FTI_Id_new bigint,
    p_FMH_Id_new bigint,
    p_userid bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_fyghm_id bigint;
    v_FCMA_Id bigint;
    v_FCMAS_Id bigint;
    v_FTI_Name varchar(100);
    v_FCMAS_Amount numeric;
    v_FMH_Name varchar(100);
    v_ASMAY_Id bigint;
    v_FMG_Id_new bigint;
    v_fmstghid bigint;
    v_ftp_concession_amt bigint;
    v_FMH_Id bigint;
    v_FTI_Id bigint;
    v_SSCRCount bigint;
    v_previousacademicyear bigint;
    v_SGRcount bigint;
    yearly_fee_rec RECORD;
    fee_det_rec RECORD;
BEGIN
    v_FTI_Name := '';
    v_FCMAS_Amount := 0;
    v_FMH_Name := '';
    v_ftp_concession_amt := 0;
    v_SGRcount := 0;

    SELECT "ASMAY_Id" INTO v_ASMAY_Id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE CURRENT_DATE BETWEEN "ASMAY_From_Date"::date AND "ASMAY_To_Date"::date 
    AND "MI_Id" = p_MI_Id;

    SELECT COUNT(*) INTO v_SGRcount 
    FROM "clg"."Fee_Master_College_Staff_GroupHead" 
    WHERE "MI_Id" = p_MI_Id 
    AND "ASMAY_Id" = v_ASMAY_Id 
    AND "HRME_Id" = p_HRME_Id 
    AND "FMG_Id" = p_FMG_Id;

    IF v_SGRcount = 0 THEN
        INSERT INTO "Fee_Master_Staff_GroupHead" ("MI_Id", "HRME_Id", "ASMAY_Id", "FMG_Id", "FMSTGH_ActiveFlag") 
        VALUES (p_MI_Id, p_HRME_Id, v_ASMAY_Id, p_FMG_Id, 'Y');
    END IF;

    BEGIN
        SELECT "FMCSTGH_Id" INTO v_fmstghid 
        FROM "CLG"."Fee_Master_College_Staff_GroupHead" 
        WHERE "ASMAY_Id" = v_ASMAY_Id 
        AND "FMG_Id" = p_FMG_Id 
        AND "MI_Id" = p_MI_Id 
        AND "HRME_Id" = p_HRME_Id;

        RAISE NOTICE '%', v_fmstghid;
        RAISE NOTICE '%', v_fmstghid;
        RAISE NOTICE '%', p_FMH_Id_new;
        RAISE NOTICE '%', p_FTI_Id_new;

        INSERT INTO "clg"."Fee_C_Master_Student_GroupHead_Installments" 
            ("FCMSGH_Id", "FMH_ID", "FTI_ID", "FCMSGHI_CreatedBy", "FCMSGHI_UpdatedBy") 
        VALUES (v_fmstghid, p_FMH_Id_new, p_FTI_Id_new, p_userid, p_userid);

        SELECT "FCMSGH_Id" INTO v_fmstghid 
        FROM "clg"."Fee_C_Master_Student_GroupHead_Installments" 
        WHERE "FCMSGH_Id" = v_fmstghid;
        
        RAISE NOTICE '%', v_fmstghid;
        RAISE NOTICE 'd';

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
                AND "MI_Id" = p_MI_Id
            )
        LOOP
            v_fyghm_id := yearly_fee_rec."FYGHM_Id";
            v_FMG_Id_new := yearly_fee_rec."FMG_Id";
            v_FMH_Id := yearly_fee_rec."FMH_Id";

            FOR fee_det_rec IN
                SELECT A."FCMA_Id", A."FTI_Id", "Fee_T_Installment"."FTI_Name", S."FCMAS_Amount", "FCMAS_Id" 
                FROM "clg"."Fee_College_Master_Amount" A
                INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" S ON S."FCMA_Id" = A."FCMA_Id"
                INNER JOIN "Fee_T_Installment" ON A."FTI_Id" = "Fee_T_Installment"."FTI_Id"
                WHERE "ASMAY_Id" = v_ASMAY_Id 
                AND "FMG_Id" = v_FMG_Id_new 
                AND "FMH_Id" = p_FMH_Id_new 
                AND A."FTI_Id" = p_FTI_Id_new
            LOOP
                v_FCMA_Id := fee_det_rec."FCMA_Id";
                v_FTI_Id := fee_det_rec."FTI_Id";
                v_FTI_Name := fee_det_rec."FTI_Name";
                v_FCMAS_Amount := fee_det_rec."FCMAS_Amount";
                v_FCMAS_Id := fee_det_rec."FCMAS_Id";

                SELECT "FMH_FeeName" INTO v_FMH_Name 
                FROM "Fee_Master_Head" 
                WHERE "FMH_Id" = p_FMH_Id_new 
                AND "MI_Id" = p_MI_Id;

                v_ftp_concession_amt := NULL;
                SELECT "FSCI_ConcessionAmount" INTO v_ftp_concession_amt
                FROM "clg"."Fee_College_Student_Concession"
                INNER JOIN "clg"."Fee_C_Student_Concession_Installments" 
                    ON "clg"."Fee_College_Student_Concession"."FCSC_Id" = "clg"."Fee_C_Student_Concession_Installments"."FCSC_Id"
                WHERE "AMCST_Id" = p_HRME_Id 
                AND "FMH_Id" = p_FMH_Id_new 
                AND "FTI_Id" = p_FTI_Id_new 
                AND "FMG_Id" = p_FMG_Id 
                AND "MI_Id" = p_MI_Id;

                v_ftp_concession_amt := COALESCE(v_ftp_concession_amt, 0);

                RAISE NOTICE '%', v_ftp_concession_amt;

                v_SSCRCount := 0;
                SELECT COUNT(*) INTO v_SSCRCount 
                FROM "CLG"."Fee_Staff_Status_College" 
                WHERE "HRME_Id" = p_HRME_Id 
                AND "FMG_Id" = v_FMG_Id_new 
                AND "FMH_Id" = p_FMH_Id_new 
                AND "FCMAS_Id" = v_FCMAS_Id 
                AND "ASMAY_Id" = v_ASMAY_Id;

                IF v_SSCRCount = 0 THEN
                    INSERT INTO "CLG"."Fee_Staff_Status_College"(
                        "MI_Id", "ASMAY_Id", "HRME_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FCMAS_Id", 
                        "FSTSC_OBArrearAmount", "FSTSC_OBExcessAmount", "FSTSC_CurrentYrCharges", 
                        "FSTSC_TotalToBePaid", "FSTSC_ToBePaid", "FSTSC_PaidAmount", "FSTSC_ExcessPaidAmount", 
                        "FSTSC_ExcessAdjustedAmount", "FSTSC_RunningExcessAmount", "FSTSC_ConcessionAmount", 
                        "FSTSC_AdjustedAmount", "FSTSC_WaivedAmount", "FSTSC_RebateAmount", "FSTSC_FineAmount", 
                        "FSTSC_RefundAmount", "FSTSC_RefundAmountAdjusted", "FSTSC_NetAmount", 
                        "FSTSC_ChequeBounceFlag", "FSTSC_ArrearFlag", "FSTSC_RefundOverFlag", 
                        "FSTSC_ActiveFlag", "User_Id"
                    ) 
                    VALUES(
                        p_MI_Id, v_ASMAY_Id, p_HRME_Id, p_FMG_Id, p_FMH_Id_new, p_FTI_Id_new, v_FCMAS_Id, 
                        0, 0, v_FCMAS_Amount, v_FCMAS_Amount, v_FCMAS_Amount, 0, 0, 0, 0, v_ftp_concession_amt, 
                        0, 0, 0, 0, 0, 0, v_FCMAS_Amount, 0, 0, 0, 1, p_userid
                    );

                    PERFORM "UpdateStudPaidAmt_College"(p_HRME_Id, v_FCMAS_Id, p_MI_Id);
                ELSE
                    PERFORM "UpdateStudPaidAmt_College"(p_HRME_Id, v_FCMAS_Id, p_MI_Id);
                END IF;
            END LOOP;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error Number: %', SQLSTATE;
            RAISE NOTICE 'Error Message: %', SQLERRM;
            RAISE;
    END;

    RETURN;
END;
$$;