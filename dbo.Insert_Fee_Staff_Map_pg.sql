CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Staff_Map"(
    p_fmg_id bigint,
    p_hrme_id bigint,
    p_MI_ID bigint,
    p_fti_id_new bigint,
    p_FMSTGH_Id bigint,
    p_FMH_ID_new bigint,
    p_userid bigint
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
    v_asmay_id bigint;
    v_fmg_id_new bigint;
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
    v_asmay_id := 0;
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

    SELECT "ASMAY_Id" INTO v_asmay_id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_From_Date" < CURRENT_TIMESTAMP 
    AND "ASMAY_To_Date" > CURRENT_TIMESTAMP 
    AND "MI_Id" = p_MI_ID;

    SELECT MAX("FMSTGH_Id") INTO p_FMSTGH_Id 
    FROM "Fee_Master_Staff_GroupHead";

    INSERT INTO "Fee_Master_Staff_GroupHead_Installments" ("FMSTGH_Id", "FMH_ID", "FTI_ID") 
    VALUES (p_FMSTGH_Id, p_FMH_ID_new, p_fti_id_new);

    FOR rec_yearly_fee IN 
        SELECT "FYGHM_Id", "FMG_Id", "FMH_Id" 
        FROM "Fee_Yearly_Group_Head_Mapping" 
        WHERE "FMG_Id" = p_fmg_id 
        AND "FYGHM_ActiveFlag" = 1 
        AND "ASMAY_Id" = v_asmay_id 
        AND "FMH_Id" = p_FMH_ID_new 
        AND "FMI_Id" IN (SELECT "FMI_Id" FROM "Fee_T_Installment" WHERE "FTI_Id" = p_fti_id_new)
    LOOP
        v_fyghm_id := rec_yearly_fee."FYGHM_Id";
        v_fmg_id_new := rec_yearly_fee."FMG_Id";
        v_fmh_id := rec_yearly_fee."FMH_Id";

        SELECT "ASMCL_Id" INTO v_amcl_id 
        FROM "Adm_School_Y_Student" 
        WHERE "amst_id" = p_hrme_id 
        AND "ASMAY_Id" = v_asmay_id;

        IF v_amcl_id > 0 THEN
            SELECT "FMCC_Id" INTO v_fmcc_id 
            FROM "Fee_Yearly_Class_Category" 
            WHERE "ASMAY_Id" = v_asmay_id 
            AND "MI_Id" = p_mi_id 
            AND "FYCC_Id" IN (SELECT "FYCC_Id" FROM "Fee_Yearly_Class_Category_Classes" WHERE "ASMCL_Id" = v_amcl_id);

            IF v_fmcc_id > 0 THEN
                FOR rec_fee_det IN 
                    SELECT "Fee_Master_Amount"."fma_id", 
                           "Fee_Master_Amount"."fti_id", 
                           "fee_t_installment"."fti_name", 
                           "Fee_Master_Amount"."fma_amount" 
                    FROM "Fee_Master_Amount" 
                    INNER JOIN "fee_t_installment" ON "Fee_Master_Amount"."fti_id" = "fee_t_installment"."fti_id" 
                    WHERE "FMCC_Id" = v_fmcc_id 
                    AND "FMG_Id" = v_fmg_id_new 
                    AND "FMH_Id" = p_FMH_ID_new 
                    AND "Fee_Master_Amount"."FTI_Id" = p_fti_id_new
                LOOP
                    v_fma_id := rec_fee_det."fma_id";
                    v_fti_id := rec_fee_det."fti_id";
                    v_fti_name := rec_fee_det."fti_name";
                    v_fma_amount := rec_fee_det."fma_amount";

                    SELECT "FMH_FeeName" INTO v_fmh_name 
                    FROM "Fee_Master_Head" 
                    WHERE "fmh_id" = p_FMH_ID_new;

                    PERFORM * FROM "Fee_Staff_Status" 
                    WHERE "HRME_Id" = p_hrme_id 
                    AND "fmg_id" = v_fmg_id_new 
                    AND "fmh_id" = p_FMH_ID_new 
                    AND "fma_id" = v_fma_id;

                    SELECT "FSCI_ConcessionAmount" INTO v_ftp_concession_amt 
                    FROM "Fee_Student_Concession" 
                    INNER JOIN "Fee_Student_Concession_Installments" ON "Fee_Student_Concession"."FSC_Id" = "Fee_Student_Concession_Installments"."FSCI_FSC_Id" 
                    WHERE "AMST_Id" = p_hrme_id 
                    AND "FMH_Id" = p_FMH_ID_new 
                    AND "FTI_Id" = p_fti_id_new 
                    AND "FMG_Id" = p_fmg_id 
                    AND "MI_Id" = p_MI_ID;

                    GET DIAGNOSTICS v_rowcount = ROW_COUNT;

                    IF v_rowcount = 0 THEN
                        PERFORM * FROM "Fee_Staff_Status" 
                        WHERE "HRME_Id" = p_hrme_id 
                        AND "fmg_id" = v_fmg_id_new 
                        AND "fmh_id" = p_FMH_ID_new 
                        AND "fma_id" = v_fma_id;
                    ELSE
                        RAISE NOTICE 'A';
                    END IF;
                END LOOP;
            END IF;
        END IF;
    END LOOP;

    RETURN;
END;
$$;