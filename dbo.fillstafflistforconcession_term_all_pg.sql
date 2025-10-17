CREATE OR REPLACE FUNCTION "dbo"."fillstafflistforconcession_term_all"(
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
    "v_row_count" INTEGER;
    "rec" RECORD;
    "rec1" RECORD;
BEGIN

    DELETE FROM "v_studentPendingsavedconcession" WHERE "mi_id" = "p_mi_id";
    DELETE FROM "v_studentPendingconcession" WHERE "mi_id" = "p_mi_id";

    SELECT COUNT(*) INTO "v_row_count" 
    FROM "fee_employee_concession" 
    WHERE "mi_id" = "p_mi_id" AND "hrme_id" = "p_hrme_id";

    IF "v_row_count" > 0 THEN

        IF "p_configuration" = 'T' THEN

            "v_sql1head" := 'SELECT "FMH_FeeName", "FTI_Name", "Fee_Student_Status_Staff"."FTI_Id", "Fee_Student_Status_Staff"."fmh_id", "Fee_Student_Status_Staff"."FSSST_ToBePaid" as "FMA_Amount", "Fee_Student_Status_Staff"."FMA_Id", "Fee_Student_Status_Staff"."FMG_Id", "FSSST_ConcessionAmount", "FEC_ConcessionType", "FEC_ConcessionReason", "FEC_Id" 
            FROM "fee_employee_concession" 
            INNER JOIN "Fee_Employee_Concession_Installments" ON "fee_employee_concession"."FEC_Id" = "Fee_Employee_Concession_Installments"."FECI_FEC_Id" 
            INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id" = "fee_employee_concession"."fmh_id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "Fee_Employee_Concession_Installments"."fti_id" 
            INNER JOIN "Fee_Student_Status_Staff" ON "Fee_Student_Status_Staff"."hrme_id" = "fee_employee_concession"."hrme_id" AND "Fee_Student_Status_Staff"."fmh_id" = "fee_employee_concession"."fmh_id" AND "Fee_Student_Status_Staff"."fti_id" = "Fee_Employee_Concession_Installments"."fti_id" 
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "Fee_Student_Status_Staff"."fmh_id" AND "Fee_Master_Terms_FeeHeads"."fti_id" = "Fee_Student_Status_Staff"."fti_id" 
            WHERE "Fee_Student_Status_Staff"."hrme_id" = ' || quote_literal("p_hrme_id") || ' AND "Fee_Student_Status_Staff"."mi_id" = ' || quote_literal("p_mi_id") || ' AND "Fee_Student_Status_Staff"."asmay_id" = ' || quote_literal("p_asmay_id") || ' AND "fmt_id" IN (' || "p_fmt_id" || ') AND "fee_employee_concession"."ASMAY_Id" = ' || quote_literal("p_asmay_id") || ' ORDER BY "Fee_Student_Status_Staff"."fmh_id"';

        ELSE

            "v_sql1head" := 'SELECT "FMH_FeeName", "FTI_Name", "Fee_Student_Status_Staff"."FTI_Id", "Fee_Student_Status_Staff"."fmh_id", "Fee_Student_Status_Staff"."FSSST_ToBePaid" as "FMA_Amount", "Fee_Student_Status_Staff"."FMA_Id", "Fee_Student_Status_Staff"."FMG_Id", "FSSST_ConcessionAmount", "FEC_ConcessionType", "FEC_ConcessionReason", "FEC_Id" 
            FROM "fee_employee_concession" 
            INNER JOIN "fee_employee_concession_Installments" ON "fee_employee_concession"."FEC_Id" = "fee_employee_concession_Installments"."FECI_FEC_Id" 
            INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id" = "fee_employee_concession"."fmh_id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "fee_employee_concession_Installments"."fti_id" 
            INNER JOIN "Fee_Student_Status_Staff" ON "Fee_Student_Status_Staff"."hrme_id" = "fee_employee_concession"."hrme_id" AND "Fee_Student_Status_Staff"."fmh_id" = "fee_employee_concession"."fmh_id" AND "fee_student_status"."fti_id" = "fee_employee_concession_Installments"."fti_id" 
            WHERE "Fee_Student_Status_Staff"."amst_id" = ' || quote_literal("p_hrme_id") || ' AND "Fee_Student_Status_Staff"."mi_id" = ' || quote_literal("p_mi_id") || ' AND "Fee_Student_Status_Staff"."asmay_id" = ' || quote_literal("p_asmay_id") || ' AND "Fee_Student_Status_Staff"."FMG_Id" IN (' || "p_fmt_id" || ') AND "fee_employee_concession"."ASMAY_Id" = ' || quote_literal("p_asmay_id") || ' ORDER BY "Fee_Student_Status_Staff"."fmh_id"';

        END IF;

        FOR "rec" IN EXECUTE "v_sql1head"
        LOOP
            INSERT INTO "v_studentPendingsavedconcession" ("FMH_FeeName", "FTI_Name", "FTI_Id", "fmh_id", "FMA_Amount", "fma_id", "FMG_Id", "FSCI_ConcessionAmount", "FSC_ConcessionType", "FSC_ConcessionReason", "mi_id", "asmay_id", "fsc_id")
            VALUES ("rec"."FMH_FeeName", "rec"."FTI_Name", "rec"."FTI_Id", "rec"."fmh_id", "rec"."FMA_Amount", "rec"."FMA_Id", "rec"."FMG_Id", "rec"."FSSST_ConcessionAmount", "rec"."FEC_ConcessionType", "rec"."FEC_ConcessionReason", "p_mi_id", "p_asmay_id", "rec"."FEC_Id");
        END LOOP;

        IF "p_configuration" = 'T' THEN

            "v_sql1head1" := 'SELECT "FMH_FeeName", "FTI_Name", "Fee_Student_Status_Staff"."fti_id", "Fee_Student_Status_Staff"."fmh_id", "FSSST_ToBePaid" as "FMA_Amount", "FMA_Id", "Fee_Student_Status_Staff"."fmg_id" 
            FROM "Fee_Student_Status_Staff" 
            INNER JOIN "fee_master_head" ON "Fee_Student_Status_Staff"."fmh_id" = "fee_master_head"."fmh_id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "Fee_Student_Status_Staff"."fti_id" 
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "Fee_Student_Status_Staff"."fmh_id" AND "Fee_Master_Terms_FeeHeads"."fti_id" = "Fee_Student_Status_Staff"."fti_id" 
            WHERE "Fee_Student_Status_Staff"."hrme_id" = ' || quote_literal("p_hrme_id") || ' AND "Fee_Student_Status_Staff"."mi_id" = ' || quote_literal("p_mi_id") || ' AND "Fee_Student_Status_Staff"."asmay_id" = ' || quote_literal("p_asmay_id") || ' AND "fmt_id" IN (' || "p_fmt_id" || ') ORDER BY "fmh_id"';

        ELSE

            "v_sql1head1" := 'SELECT "FMH_FeeName", "FTI_Name", "Fee_Student_Status_Staff"."fti_id", "Fee_Student_Status_Staff"."fmh_id", "FSSST_ToBePaid" as "FMA_Amount", "FMA_Id", "Fee_Student_Status_Staff"."fmg_id" 
            FROM "Fee_Student_Status_Staff" 
            INNER JOIN "fee_master_head" ON "Fee_Student_Status_Staff"."fmh_id" = "fee_master_head"."fmh_id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "Fee_Student_Status_Staff"."fti_id" 
            WHERE "Fee_Student_Status_Staff"."hrme_id" = ' || quote_literal("p_hrme_id") || ' AND "Fee_Student_Status_Staff"."mi_id" = ' || quote_literal("p_mi_id") || ' AND "Fee_Student_Status_Staff"."asmay_id" = ' || quote_literal("p_asmay_id") || ' AND "Fee_Student_Status_Staff"."FMG_Id" IN (' || "p_fmt_id" || ') ORDER BY "fmh_id"';

        END IF;

        FOR "rec1" IN EXECUTE "v_sql1head1"
        LOOP
            INSERT INTO "v_studentPendingconcession" ("FMH_FeeName", "FTI_Name", "fti_id", "fmh_id", "FMA_Amount", "fma_id", "fmg_id", "asmay_id", "mi_id")
            VALUES ("rec1"."FMH_FeeName", "rec1"."FTI_Name", "rec1"."fti_id", "rec1"."fmh_id", "rec1"."FMA_Amount", "rec1"."FMA_Id", "rec1"."fmg_id", "p_asmay_id", "p_mi_id");
        END LOOP;

    ELSE

        IF "p_configuration" = 'T' THEN

            "v_sql1head" := 'SELECT "FMH_FeeName", "FTI_Name", "Fee_Student_Status_Staff"."fti_id", "Fee_Student_Status_Staff"."fmh_id", "FSSST_ToBePaid" as "FMA_Amount", "FMA_Id", "Fee_Student_Status_Staff"."fmg_id" 
            FROM "Fee_Student_Status_Staff" 
            INNER JOIN "fee_master_head" ON "Fee_Student_Status_Staff"."fmh_id" = "fee_master_head"."fmh_id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "Fee_Student_Status_Staff"."fti_id" 
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "Fee_Student_Status_Staff"."fmh_id" AND "Fee_Master_Terms_FeeHeads"."fti_id" = "Fee_Student_Status_Staff"."fti_id" 
            WHERE "Fee_Student_Status_Staff"."hrme_id" = ' || quote_literal("p_hrme_id") || ' AND "Fee_Student_Status_Staff"."mi_id" = ' || quote_literal("p_mi_id") || ' AND "Fee_Student_Status_Staff"."asmay_id" = ' || quote_literal("p_asmay_id") || ' AND "fmt_id" IN (' || "p_fmt_id" || ') ORDER BY "fmh_id"';

        ELSE

            "v_sql1head" := 'SELECT "FMH_FeeName", "FTI_Name", "Fee_Student_Status_Staff"."fti_id", "Fee_Student_Status_Staff"."fmh_id", "FSSST_ToBePaid" as "FMA_Amount", "FMA_Id", "Fee_Student_Status_Staff"."fmg_id" 
            FROM "Fee_Student_Status_Staff" 
            INNER JOIN "fee_master_head" ON "Fee_Student_Status_Staff"."fmh_id" = "fee_master_head"."fmh_id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "Fee_Student_Status_Staff"."fti_id" 
            WHERE "Fee_Student_Status_Staff"."hrme_id" = ' || quote_literal("p_hrme_id") || ' AND "Fee_Student_Status_Staff"."mi_id" = ' || quote_literal("p_mi_id") || ' AND "Fee_Student_Status_Staff"."asmay_id" = ' || quote_literal("p_asmay_id") || ' AND "Fee_Student_Status_Staff"."FMG_Id" IN (' || "p_fmt_id" || ') ORDER BY "fmh_id"';

        END IF;

        FOR "rec" IN EXECUTE "v_sql1head"
        LOOP
            INSERT INTO "v_studentPendingconcession" ("FMH_FeeName", "FTI_Name", "fti_id", "fmh_id", "FMA_Amount", "fma_id", "fmg_id", "asmay_id", "mi_id")
            VALUES ("rec"."FMH_FeeName", "rec"."FTI_Name", "rec"."fti_id", "rec"."fmh_id", "rec"."FMA_Amount", "rec"."FMA_Id", "rec"."fmg_id", "p_asmay_id", "p_mi_id");
        END LOOP;

    END IF;

END;
$$;