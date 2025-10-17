CREATE OR REPLACE FUNCTION "dbo"."fillstafflistforconcessioncollege_term_all"(
    "p_hrme_id" TEXT,
    "p_asmay_id" TEXT,
    "p_mi_id" TEXT,
    "p_fmt_id" TEXT,
    "p_userid" TEXT,
    "p_configuration" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sql1head" TEXT;
    "v_sqlhead" TEXT;
    "v_sql1head1" TEXT;
    "v_sqlhead1" TEXT;
    "v_headname" TEXT;
    "v_installmentname" TEXT;
    "v_ftiid" BIGINT;
    "v_fmhid" BIGINT;
    "v_ftptobepaidamt" BIGINT;
    "v_fmaid" BIGINT;
    "v_fmgid" BIGINT;
    "v_concessnamount" BIGINT;
    "v_concessiontype" TEXT;
    "v_concessionreason" TEXT;
    "v_fscid" BIGINT;
    "v_rowcount" INTEGER;
    "rec" RECORD;
BEGIN

    DELETE FROM "v_studentPendingsavedconcession" WHERE "mi_id" = "p_mi_id";
    DELETE FROM "v_studentPendingconcession" WHERE "mi_id" = "p_mi_id";

    SELECT COUNT(*) INTO "v_rowcount"
    FROM "CLG"."Fee_Employee_Concession_College"
    WHERE "mi_id" = "p_mi_id" AND "hrme_id" = "p_hrme_id";

    IF "v_rowcount" > 0 THEN

        IF "p_configuration" = 'T' THEN

            FOR "rec" IN EXECUTE 
                'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_Staff"."FTI_Id", "CLG"."Fee_College_Student_Status_Staff"."fmh_id", ' ||
                '"CLG"."Fee_College_Student_Status_Staff"."FCSSST_ToBePaid" AS "FMA_Amount", "CLG"."Fee_College_Student_Status_Staff"."FMCAOST_Id" AS "FCMA_Id", ' ||
                '"CLG"."Fee_College_Student_Status_Staff"."FMG_Id", "FCSSST_ConcessionAmount", "FECC_ConcessionType", "FECC_ConcessionReason", "CLG"."Fee_Employee_Concession_College"."FECC_Id" ' ||
                'FROM "CLG"."Fee_Employee_Concession_College" ' ||
                'INNER JOIN "CLG"."Fee_Employee_Concession_Installments_College" ON "CLG"."Fee_Employee_Concession_College"."FECC_Id" = "CLG"."Fee_Employee_Concession_Installments_College"."FECC_Id" ' ||
                'INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id" = "CLG"."Fee_Employee_Concession_College"."fmh_id" ' ||
                'INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_Employee_Concession_Installments_College"."fti_id" ' ||
                'INNER JOIN "CLG"."Fee_College_Student_Status_Staff" ON "CLG"."Fee_College_Student_Status_Staff"."hrme_id" = "CLG"."Fee_Employee_Concession_College"."hrme_id" ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."fmh_id" = "CLG"."Fee_Employee_Concession_College"."fmh_id" ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."fti_id" = "CLG"."Fee_Employee_Concession_Installments_College"."fti_id" ' ||
                'INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "CLG"."Fee_College_Student_Status_Staff"."fmh_id" ' ||
                'AND "Fee_Master_Terms_FeeHeads"."fti_id" = "CLG"."Fee_College_Student_Status_Staff"."fti_id" ' ||
                'WHERE "CLG"."Fee_College_Student_Status_Staff"."hrme_id" = ' || quote_literal("p_hrme_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."mi_id" = ' || quote_literal("p_mi_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."asmay_id" = ' || quote_literal("p_asmay_id") || ' ' ||
                'AND "fmt_id" IN (' || "p_fmt_id" || ') ' ||
                'AND "CLG"."Fee_Employee_Concession_College"."ASMAY_Id" = ' || quote_literal("p_asmay_id") || ' ' ||
                'ORDER BY "CLG"."Fee_College_Student_Status_Staff"."fmh_id"'
            LOOP
                INSERT INTO "v_studentPendingsavedconcession" (
                    "FMH_FeeName", "FTI_Name", "FTI_Id", "fmh_id", "FMA_Amount", "fma_id", "FMG_Id",
                    "FSCI_ConcessionAmount", "FSC_ConcessionType", "FSC_ConcessionReason", "mi_id", "asmay_id", "fsc_id"
                )
                VALUES (
                    "rec"."FMH_FeeName", "rec"."FTI_Name", "rec"."FTI_Id", "rec"."fmh_id", "rec"."FMA_Amount",
                    "rec"."FCMA_Id", "rec"."FMG_Id", "rec"."FCSSST_ConcessionAmount", "rec"."FECC_ConcessionType",
                    "rec"."FECC_ConcessionReason", "p_mi_id", "p_asmay_id", "rec"."FECC_Id"
                );
            END LOOP;

            FOR "rec" IN EXECUTE
                'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_Staff"."fti_id", "CLG"."Fee_College_Student_Status_Staff"."fmh_id", ' ||
                '"FCSSST_ToBePaid" AS "FMA_Amount", "CLG"."Fee_College_Student_Status_Staff"."FMCAOST_Id" AS "FCMA_Id", "CLG"."Fee_College_Student_Status_Staff"."fmg_id" ' ||
                'FROM "CLG"."Fee_College_Student_Status_Staff" ' ||
                'INNER JOIN "fee_master_head" ON "CLG"."Fee_College_Student_Status_Staff"."fmh_id" = "fee_master_head"."fmh_id" ' ||
                'INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_College_Student_Status_Staff"."fti_id" ' ||
                'INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "CLG"."Fee_College_Student_Status_Staff"."fmh_id" ' ||
                'AND "Fee_Master_Terms_FeeHeads"."fti_id" = "CLG"."Fee_College_Student_Status_Staff"."fti_id" ' ||
                'WHERE "CLG"."Fee_College_Student_Status_Staff"."hrme_id" = ' || quote_literal("p_hrme_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."mi_id" = ' || quote_literal("p_mi_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."asmay_id" = ' || quote_literal("p_asmay_id") || ' ' ||
                'AND "fmt_id" IN (' || "p_fmt_id" || ') ' ||
                'ORDER BY "fmh_id"'
            LOOP
                INSERT INTO "v_studentPendingconcession" (
                    "FMH_FeeName", "FTI_Name", "fti_id", "fmh_id", "FMA_Amount", "fma_id", "fmg_id", "asmay_id", "mi_id"
                )
                VALUES (
                    "rec"."FMH_FeeName", "rec"."FTI_Name", "rec"."fti_id", "rec"."fmh_id",
                    "rec"."FMA_Amount", "rec"."FCMA_Id", "rec"."fmg_id", "p_asmay_id", "p_mi_id"
                );
            END LOOP;

        ELSE

            FOR "rec" IN EXECUTE
                'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_Staff"."FTI_Id", "CLG"."Fee_College_Student_Status_Staff"."fmh_id", ' ||
                '"CLG"."Fee_College_Student_Status_Staff"."FCSSST_ToBePaid" AS "FMA_Amount", "CLG"."Fee_College_Student_Status_Staff"."FMCAOST_Id" AS "FCMA_Id", ' ||
                '"CLG"."Fee_College_Student_Status_Staff"."FMG_Id", "FCSSST_ConcessionAmount", "FECC_ConcessionType", "FECC_ConcessionReason", "CLG"."Fee_Employee_Concession_College"."FECC_Id" ' ||
                'FROM "CLG"."Fee_Employee_Concession_College" ' ||
                'INNER JOIN "CLG"."Fee_Employee_Concession_Installments_College" ON "CLG"."Fee_Employee_Concession_College"."FECC_Id" = "CLG"."Fee_Employee_Concession_Installments_College"."FECC_Id" ' ||
                'INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id" = "CLG"."Fee_Employee_Concession_College"."fmh_id" ' ||
                'INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_Employee_Concession_Installments_College"."fti_id" ' ||
                'INNER JOIN "CLG"."Fee_College_Student_Status_Staff" ON "CLG"."Fee_College_Student_Status_Staff"."hrme_id" = "CLG"."Fee_Employee_Concession_College"."hrme_id" ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."fmh_id" = "CLG"."Fee_Employee_Concession_College"."fmh_id" ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."fti_id" = "CLG"."Fee_Employee_Concession_Installments_College"."fti_id" ' ||
                'WHERE "CLG"."Fee_College_Student_Status_Staff"."HRME_Id" = ' || quote_literal("p_hrme_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."mi_id" = ' || quote_literal("p_mi_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."asmay_id" = ' || quote_literal("p_asmay_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."FMG_Id" IN (' || "p_fmt_id" || ') ' ||
                'AND "CLG"."Fee_Employee_Concession_College"."ASMAY_Id" = ' || quote_literal("p_asmay_id") || ' ' ||
                'ORDER BY "CLG"."Fee_College_Student_Status_Staff"."fmh_id"'
            LOOP
                INSERT INTO "v_studentPendingsavedconcession" (
                    "FMH_FeeName", "FTI_Name", "FTI_Id", "fmh_id", "FMA_Amount", "fma_id", "FMG_Id",
                    "FSCI_ConcessionAmount", "FSC_ConcessionType", "FSC_ConcessionReason", "mi_id", "asmay_id", "fsc_id"
                )
                VALUES (
                    "rec"."FMH_FeeName", "rec"."FTI_Name", "rec"."FTI_Id", "rec"."fmh_id", "rec"."FMA_Amount",
                    "rec"."FCMA_Id", "rec"."FMG_Id", "rec"."FCSSST_ConcessionAmount", "rec"."FECC_ConcessionType",
                    "rec"."FECC_ConcessionReason", "p_mi_id", "p_asmay_id", "rec"."FECC_Id"
                );
            END LOOP;

            FOR "rec" IN EXECUTE
                'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_Staff"."fti_id", "CLG"."Fee_College_Student_Status_Staff"."fmh_id", ' ||
                '"FCSSST_ToBePaid" AS "FMA_Amount", "CLG"."Fee_College_Student_Status_Staff"."FMCAOST_Id" AS "FCMA_Id", "CLG"."Fee_College_Student_Status_Staff"."fmg_id" ' ||
                'FROM "CLG"."Fee_College_Student_Status_Staff" ' ||
                'INNER JOIN "fee_master_head" ON "CLG"."Fee_College_Student_Status_Staff"."fmh_id" = "fee_master_head"."fmh_id" ' ||
                'INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_College_Student_Status_Staff"."fti_id" ' ||
                'WHERE "CLG"."Fee_College_Student_Status_Staff"."hrme_id" = ' || quote_literal("p_hrme_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."mi_id" = ' || quote_literal("p_mi_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."asmay_id" = ' || quote_literal("p_asmay_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."FMG_Id" IN (' || "p_fmt_id" || ') ' ||
                'ORDER BY "fmh_id"'
            LOOP
                INSERT INTO "v_studentPendingconcession" (
                    "FMH_FeeName", "FTI_Name", "fti_id", "fmh_id", "FMA_Amount", "fma_id", "fmg_id", "asmay_id", "mi_id"
                )
                VALUES (
                    "rec"."FMH_FeeName", "rec"."FTI_Name", "rec"."fti_id", "rec"."fmh_id",
                    "rec"."FMA_Amount", "rec"."FCMA_Id", "rec"."fmg_id", "p_asmay_id", "p_mi_id"
                );
            END LOOP;

        END IF;

    ELSE

        IF "p_configuration" = 'T' THEN

            FOR "rec" IN EXECUTE
                'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_Staff"."fti_id", "CLG"."Fee_College_Student_Status_Staff"."fmh_id", ' ||
                '"FCSSST_ToBePaid" AS "FMA_Amount", "FMCAOST_Id" AS "FCMA_Id", "CLG"."Fee_College_Student_Status_Staff"."fmg_id" ' ||
                'FROM "CLG"."Fee_College_Student_Status_Staff" ' ||
                'INNER JOIN "fee_master_head" ON "CLG"."Fee_College_Student_Status_Staff"."fmh_id" = "fee_master_head"."fmh_id" ' ||
                'INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_College_Student_Status_Staff"."fti_id" ' ||
                'INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "CLG"."Fee_College_Student_Status_Staff"."fmh_id" ' ||
                'AND "Fee_Master_Terms_FeeHeads"."fti_id" = "CLG"."Fee_College_Student_Status_Staff"."fti_id" ' ||
                'WHERE "CLG"."Fee_College_Student_Status_Staff"."hrme_id" = ' || quote_literal("p_hrme_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."mi_id" = ' || quote_literal("p_mi_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."asmay_id" = ' || quote_literal("p_asmay_id") || ' ' ||
                'AND "fmt_id" IN (' || "p_fmt_id" || ') ' ||
                'ORDER BY "fmh_id"'
            LOOP
                INSERT INTO "v_studentPendingconcession" (
                    "FMH_FeeName", "FTI_Name", "fti_id", "fmh_id", "FMA_Amount", "fma_id", "fmg_id", "asmay_id", "mi_id"
                )
                VALUES (
                    "rec"."FMH_FeeName", "rec"."FTI_Name", "rec"."fti_id", "rec"."fmh_id",
                    "rec"."FMA_Amount", "rec"."FCMA_Id", "rec"."fmg_id", "p_asmay_id", "p_mi_id"
                );
            END LOOP;

        ELSE

            FOR "rec" IN EXECUTE
                'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_Staff"."fti_id", "CLG"."Fee_College_Student_Status_Staff"."fmh_id", ' ||
                '"FCSSST_ToBePaid" AS "FMA_Amount", "FMCAOST_Id" AS "FCMA_Id", "CLG"."Fee_College_Student_Status_Staff"."fmg_id" ' ||
                'FROM "CLG"."Fee_College_Student_Status_Staff" ' ||
                'INNER JOIN "fee_master_head" ON "CLG"."Fee_College_Student_Status_Staff"."fmh_id" = "fee_master_head"."fmh_id" ' ||
                'INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_College_Student_Status_Staff"."fti_id" ' ||
                'WHERE "CLG"."Fee_College_Student_Status_Staff"."hrme_id" = ' || quote_literal("p_hrme_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."mi_id" = ' || quote_literal("p_mi_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."asmay_id" = ' || quote_literal("p_asmay_id") || ' ' ||
                'AND "CLG"."Fee_College_Student_Status_Staff"."FMG_Id" IN (' || "p_fmt_id" || ') ' ||
                'ORDER BY "fmh_id"'
            LOOP
                INSERT INTO "v_studentPendingconcession" (
                    "FMH_FeeName", "FTI_Name", "fti_id", "fmh_id", "FMA_Amount", "fma_id", "fmg_id", "asmay_id", "mi_id"
                )
                VALUES (
                    "rec"."FMH_FeeName", "rec"."FTI_Name", "rec"."fti_id", "rec"."fmh_id",
                    "rec"."FMA_Amount", "rec"."FCMA_Id", "rec"."fmg_id", "p_asmay_id", "p_mi_id"
                );
            END LOOP;

        END IF;

    END IF;

END;
$$;