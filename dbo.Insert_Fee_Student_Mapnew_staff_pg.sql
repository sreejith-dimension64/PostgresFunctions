CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Student_Mapnew_staff"(
    p_fmg_id bigint,
    p_HRME_Id bigint,
    p_MI_ID bigint,
    p_fti_id_new bigint,
    p_FMH_ID_new bigint,
    p_userid bigint,
    p_asmay_id bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_fyghm_id bigint;
    v_fmcc_id bigint;
    v_amcl_id bigint;
    v_fma_id bigint;
    v_fti_name varchar(100);
    v_fma_amount numeric;
    v_fmh_name varchar(100);
    v_fmg_id_new bigint;
    v_fmsgid bigint;
    v_ftp_concession_amt bigint;
    v_fmh_id bigint;
    v_fti_id bigint;
    v_previousacademicyear bigint;
    v_rowcount integer;
    rec_yearly_fee RECORD;
    rec_fee_det RECORD;
BEGIN
    v_amcl_id := 0;
    v_fmcc_id := 0;
    v_fma_id := 0;
    v_fti_name := '';
    v_fma_amount := 0;
    v_fmh_name := '';
    v_ftp_concession_amt := 0;

    SELECT "ASMAY_Id" INTO v_previousacademicyear
    FROM "Adm_School_M_Academic_Year"
    WHERE EXTRACT(YEAR FROM "ASMAY_From_Date") BETWEEN 
        (SELECT (EXTRACT(YEAR FROM "ASMAY_From_Date") - 1) AS year 
         FROM "Adm_School_M_Academic_Year"
         WHERE "ASMAY_From_Date" < CURRENT_TIMESTAMP 
         AND "ASMAY_To_Date" > CURRENT_TIMESTAMP 
         AND "MI_Id" = p_MI_ID) 
        AND 
        (SELECT (EXTRACT(YEAR FROM "ASMAY_From_Date") - 1) AS year 
         FROM "Adm_School_M_Academic_Year"
         WHERE "ASMAY_From_Date" < CURRENT_TIMESTAMP 
         AND "ASMAY_To_Date" > CURRENT_TIMESTAMP 
         AND "MI_Id" = p_MI_ID);

    RAISE NOTICE '%', v_previousacademicyear;

    SELECT COUNT(*) INTO v_rowcount
    FROM "Fee_Master_Staff_GroupHead"
    WHERE "ASMAY_Id" = p_asmay_id 
    AND "FMG_Id" = p_fmg_id 
    AND "MI_Id" = p_MI_ID 
    AND "HRME_Id" = p_HRME_Id;

    IF v_rowcount = 0 THEN
        RAISE NOTICE 'a';
        INSERT INTO "Fee_Master_Staff_GroupHead" ("MI_Id", "HRME_Id", "ASMAY_Id", "FMG_Id", "FMSTGH_ActiveFlag")
        VALUES (p_mi_id, p_HRME_Id, p_asmay_id, p_fmg_id, 'Y');
    END IF;

    BEGIN
        SELECT "FMSTGH_Id" INTO v_fmsgid
        FROM "Fee_Master_Staff_GroupHead"
        WHERE "ASMAY_Id" = p_asmay_id 
        AND "FMG_Id" = p_fmg_id 
        AND "MI_Id" = p_MI_ID 
        AND "HRME_Id" = p_HRME_Id;

        RAISE NOTICE '%', v_fmsgid;
        RAISE NOTICE 'e';
        RAISE NOTICE '%; %; %', v_fmsgid, p_FMH_ID_new, p_fti_id_new;

        INSERT INTO "Fee_Master_Staff_GroupHead_Installments" ("FMSTGH_Id", "FMH_ID", "FTI_ID")
        VALUES (v_fmsgid, p_FMH_ID_new, p_fti_id_new);

        SELECT "FMSTGHI_Id" INTO v_fmsgid
        FROM "Fee_Master_Staff_GroupHead_Installments"
        WHERE "FMSTGH_Id" = v_fmsgid;

        RAISE NOTICE '%', v_fmsgid;
        RAISE NOTICE 'd';

        FOR rec_yearly_fee IN
            SELECT "FYGHM_Id", "FMG_Id", "FMH_Id"
            FROM "Fee_Yearly_Group_Head_Mapping"
            WHERE "FMG_Id" = p_fmg_id 
            AND "FYGHM_ActiveFlag" = 1 
            AND "ASMAY_Id" = p_asmay_id 
            AND "FMH_Id" = p_FMH_ID_new 
            AND "FMI_Id" IN (SELECT "FMI_Id" FROM "Fee_T_Installment" WHERE "FTI_Id" = p_fti_id_new)
        LOOP
            v_fyghm_id := rec_yearly_fee."FYGHM_Id";
            v_fmg_id_new := rec_yearly_fee."FMG_Id";
            v_fmh_id := rec_yearly_fee."FMH_Id";

            RAISE NOTICE 'b';

            FOR rec_fee_det IN
                SELECT "Fee_Master_Amount_OthStaffs"."FMAOST_Id", 
                       "Fee_Master_Amount_OthStaffs"."FTI_Id", 
                       "fee_t_installment"."fti_name", 
                       "Fee_Master_Amount_OthStaffs"."FMAOST_Amount"
                FROM "Fee_Master_Amount_OthStaffs"
                INNER JOIN "fee_t_installment" ON "Fee_Master_Amount_OthStaffs"."fti_id" = "fee_t_installment"."fti_id"
                WHERE "FMG_Id" = v_fmg_id_new 
                AND "FMH_Id" = p_FMH_ID_new 
                AND "Fee_Master_Amount_OthStaffs"."FTI_Id" = p_fti_id_new 
                AND "ASMAY_Id" = p_asmay_id 
                AND "FMAOST_OthStaffFlag" = 'S'
            LOOP
                v_fma_id := rec_fee_det."FMAOST_Id";
                v_fti_id := rec_fee_det."FTI_Id";
                v_fti_name := rec_fee_det."fti_name";
                v_fma_amount := rec_fee_det."FMAOST_Amount";

                SELECT "FMH_FeeName" INTO v_fmh_name
                FROM "Fee_Master_Head"
                WHERE "fmh_id" = p_FMH_ID_new;

                SELECT COUNT(*) INTO v_rowcount
                FROM "Fee_Student_Status_Staff"
                WHERE "HRME_Id" = p_HRME_Id 
                AND "fmg_id" = v_fmg_id_new 
                AND "fmh_id" = p_FMH_ID_new 
                AND "FMA_Id" = v_fma_id;

                SELECT COALESCE("FSCI_ConcessionAmount", 0) INTO v_ftp_concession_amt
                FROM "Fee_Employee_Concession"
                INNER JOIN "Fee_Employee_Concession_Installments" 
                    ON "Fee_Employee_Concession"."FEC_Id" = "Fee_Employee_Concession_Installments"."FECI_FEC_Id"
                WHERE "HRME_Id" = p_HRME_Id 
                AND "FMH_Id" = p_FMH_ID_new 
                AND "FTI_Id" = p_fti_id_new 
                AND "FMG_Id" = p_fmg_id 
                AND "MI_Id" = p_MI_ID
                LIMIT 1;

                v_ftp_concession_amt := COALESCE(v_ftp_concession_amt, 0);
                RAISE NOTICE '%', v_ftp_concession_amt;

                GET DIAGNOSTICS v_rowcount = ROW_COUNT;

                IF v_rowcount = 0 THEN
                    RAISE NOTICE 'b';

                    SELECT COUNT(*) INTO v_rowcount
                    FROM "Fee_Student_Status_Staff"
                    WHERE "HRME_Id" = p_HRME_Id 
                    AND "fmg_id" = v_fmg_id_new 
                    AND "fmh_id" = p_FMH_ID_new 
                    AND "fma_id" = v_fma_id;

                    INSERT INTO "Fee_Student_Status_Staff" (
                        "MI_Id", "ASMAY_Id", "HRME_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id",
                        "FSSST_OBArrearAmount", "FSSST_OBExcessAmount", "FSSST_CurrentYrCharges",
                        "FSSST_TotalCharges", "FSSST_ConcessionAmount", "FSSST_WaivedAmount",
                        "FSSST_ToBePaid", "FSSST_PaidAmount", "FSSST_ExcessPaidAmount",
                        "FSSST_ExcessAdjustedAmount", "FSSST_RunningExcessAmount", "FSSST_AdjustedAmount",
                        "FSSST_RebateAmount", "FSSST_FineAmount", "FSSST_RefundAmount",
                        "FSSST_RefundAmountAdjusted", "FSSST_NetAmount", "FSSST_ChequeBounceAmount",
                        "FSSST_ArrearFlag", "FSSST_RefundOverFlag", "FSSST_ActiveFlag",
                        "CreatedDate", "UpdatedDate"
                    )
                    VALUES (
                        p_MI_ID, p_asmay_id, p_HRME_Id, p_fmg_id, p_FMH_ID_new, p_fti_id_new, v_fma_id,
                        0, 0, v_fma_amount, v_fma_amount, 0, 0, v_fma_amount, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                        v_fma_amount, 0, 0, 0, 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                    );

                    PERFORM "UpdateStudPaidAmt"(p_HRME_Id, v_fma_id, p_MI_ID);
                ELSE
                    PERFORM "UpdateStudPaidAmt"(p_HRME_Id, v_fma_id, p_MI_ID);
                END IF;
            END LOOP;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error Number: %', SQLSTATE;
            RAISE NOTICE 'Error Message: %', SQLERRM;
            RAISE;
    END;

END;
$$;