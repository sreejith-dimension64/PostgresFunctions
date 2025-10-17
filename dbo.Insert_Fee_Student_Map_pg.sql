CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Student_Map"(
    "@fmg_id" BIGINT,
    "@amst_id" BIGINT,
    "@MI_ID" BIGINT,
    "@fti_id_new" BIGINT,
    "@FMSG_Id" BIGINT,
    "@FMH_ID_new" BIGINT,
    "@userid" BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "@fyghm_id" BIGINT;
    "@fmcc_id" BIGINT;
    "@amcl_id" BIGINT;
    "@fma_id" BIGINT;
    "@fti_name" VARCHAR(100);
    "@fma_amount" NUMERIC;
    "@fmh_name" VARCHAR(100);
    "@asmay_id" BIGINT;
    "@fmg_id_new" BIGINT;
    "@fmsgid" BIGINT;
    "@ftp_concession_amt" BIGINT;
    "@fmh_id" BIGINT;
    "@fti_id" BIGINT;
    "@previousacademicyear" BIGINT;
    "v_rowcount" INTEGER;
BEGIN
    "@amcl_id" := 0;
    "@fmcc_id" := 0;
    "@fma_id" := 0;
    "@fti_name" := '';
    "@fma_amount" := 0;
    "@fmh_name" := '';
    "@asmay_id" := 0;
    "@ftp_concession_amt" := 0;

    BEGIN
        SELECT "ASMAY_Id" INTO "@previousacademicyear"
        FROM "Adm_School_M_Academic_Year"
        WHERE EXTRACT(YEAR FROM "ASMAY_From_Date") BETWEEN 
            (SELECT (EXTRACT(YEAR FROM "ASMAY_From_Date") - 1) AS year 
             FROM "Adm_School_M_Academic_Year"
             WHERE "ASMAY_From_Date" < CURRENT_TIMESTAMP 
             AND "ASMAY_To_Date" > CURRENT_TIMESTAMP 
             AND "MI_Id" = "@MI_ID")
        AND (SELECT (EXTRACT(YEAR FROM "ASMAY_From_Date") - 1) AS year 
             FROM "Adm_School_M_Academic_Year"
             WHERE "ASMAY_From_Date" < CURRENT_TIMESTAMP 
             AND "ASMAY_To_Date" > CURRENT_TIMESTAMP 
             AND "MI_Id" = "@MI_ID");

        SELECT "ASMAY_Id" INTO "@asmay_id"
        FROM "Adm_School_M_Academic_Year"
        WHERE "ASMAY_From_Date" < CURRENT_TIMESTAMP 
        AND "ASMAY_To_Date" > CURRENT_TIMESTAMP 
        AND "MI_Id" = "@MI_ID";

        SELECT MAX("FMSG_Id") INTO "@fmsgid"
        FROM "Fee_Master_Student_Group";
        
        "@FMSG_Id" := "@fmsgid";

        INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id", "FMH_ID", "FTI_ID")
        VALUES ("@FMSG_Id", "@FMH_ID_new", "@fti_id_new");

        FOR "@fyghm_id", "@fmg_id_new", "@fmh_id" IN
            SELECT "FYGHM_Id", "FMG_Id", "FMH_Id"
            FROM "Fee_Yearly_Group_Head_Mapping"
            WHERE "FMG_Id" = "@fmg_id" 
            AND "FYGHM_ActiveFlag" = 1 
            AND "ASMAY_Id" = "@asmay_id" 
            AND "FMH_Id" = "@FMH_ID_new" 
            AND "FMI_Id" IN (SELECT "FMI_Id" FROM "Fee_T_Installment" WHERE "FTI_Id" = "@fti_id_new")
        LOOP
            SELECT "ASMCL_Id" INTO "@amcl_id"
            FROM "Adm_School_Y_Student"
            WHERE "amst_id" = "@amst_id" 
            AND "ASMAY_Id" = "@asmay_id";

            IF "@amcl_id" > 0 THEN
                SELECT "FMCC_Id" INTO "@fmcc_id"
                FROM "Fee_Yearly_Class_Category"
                WHERE "ASMAY_Id" = "@ASMAY_ID" 
                AND "MI_Id" = "@MI_ID" 
                AND "FYCC_Id" IN (SELECT "FYCC_Id" FROM "Fee_Yearly_Class_Category_Classes" WHERE "ASMCL_Id" = "@amcl_id");

                IF "@fmcc_id" > 0 THEN
                    FOR "@fma_id", "@fti_id", "@fti_name", "@fma_amount" IN
                        SELECT "Fee_Master_Amount"."fma_id", "Fee_Master_Amount"."fti_id", "fee_t_installment"."fti_name", "Fee_Master_Amount"."fma_amount"
                        FROM "Fee_Master_Amount"
                        INNER JOIN "fee_t_installment" ON "Fee_Master_Amount"."fti_id" = "fee_t_installment"."fti_id"
                        WHERE "FMCC_Id" = "@fmcc_id" 
                        AND "FMG_Id" = "@fmg_id_new" 
                        AND "FMH_Id" = "@FMH_ID_new" 
                        AND "Fee_Master_Amount"."FTI_Id" = "@fti_id_new"
                    LOOP
                        SELECT "FMH_FeeName" INTO "@fmh_name"
                        FROM "Fee_Master_Head"
                        WHERE "fmh_id" = "@FMH_ID_new";

                        PERFORM 1 FROM "Fee_Student_Status"
                        WHERE "Amst_Id" = "@amst_id" 
                        AND "fmg_id" = "@fmg_id_new" 
                        AND "fmh_id" = "@FMH_ID_new" 
                        AND "fma_id" = "@fma_id";

                        SELECT "FSCI_ConcessionAmount" INTO "@ftp_concession_amt"
                        FROM "Fee_Student_Concession"
                        INNER JOIN "Fee_Student_Concession_Installments" ON "Fee_Student_Concession"."FSC_Id" = "Fee_Student_Concession_Installments"."FSCI_FSC_Id"
                        WHERE "AMST_Id" = "@amst_id" 
                        AND "FMH_Id" = "@FMH_ID_new" 
                        AND "FTI_Id" = "@fti_id_new" 
                        AND "FMG_Id" = "@fmg_id" 
                        AND "MI_Id" = "@MI_ID";

                        GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;

                        IF "v_rowcount" = 0 THEN
                            PERFORM 1 FROM "Fee_Student_Status"
                            WHERE "Amst_Id" = "@amst_id" 
                            AND "fmg_id" = "@fmg_id_new" 
                            AND "fmh_id" = "@FMH_ID_new" 
                            AND "fma_id" = "@fma_id";

                            INSERT INTO "Fee_Student_Status"("MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", "User_Id")
                            VALUES("@MI_ID", "@asmay_id", "@amst_id", "@fmg_id", "@FMH_ID_new", "@fti_id_new", "@fma_id", 0, 0, "@fma_amount", "@fma_amount", "@fma_amount", 0, 0, 0, 0, COALESCE("@ftp_concession_amt", 0), 0, 0, 0, 0, 0, 0, "@fma_amount", 0, 0, 0, 1, "@userid");

                            PERFORM "UpdateStudPaidAmt"("@amst_id", "@fma_id", "@MI_ID");
                        ELSE
                            PERFORM "UpdateStudPaidAmt"("@amst_id", "@fma_id", "@MI_ID");
                        END IF;
                    END LOOP;
                END IF;
            END IF;
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