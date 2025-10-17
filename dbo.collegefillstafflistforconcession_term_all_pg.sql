CREATE OR REPLACE FUNCTION "dbo"."collegefillstafflistforconcession_term_all"(
    "hrme_id" TEXT,
    "asmay_id" TEXT,
    "mi_id" TEXT,
    "fmt_id" TEXT,
    "userid" TEXT,
    "configuration" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "sql1head" TEXT;
    "sqlhead" TEXT;
    "sql1head1" TEXT;
    "sqlhead1" TEXT;
    "headname" TEXT;
    "installmentname" TEXT;
    "ftiid" BIGINT;
    "fmhid" BIGINT;
    "ftptobepaidamt" BIGINT;
    "fmaid" BIGINT;
    "fmgid" BIGINT;
    "concessnamount" BIGINT;
    "concessiontype" TEXT;
    "concessionreason" TEXT;
    "fscid" BIGINT;
    "rec" RECORD;
    "row_count_check" INTEGER;
BEGIN

    DELETE FROM "v_studentPendingsavedconcession" WHERE "mi_id" = "collegefillstafflistforconcession_term_all"."mi_id";
    DELETE FROM "v_studentPendingconcession" WHERE "mi_id" = "collegefillstafflistforconcession_term_all"."mi_id";

    SELECT COUNT(*) INTO "row_count_check"
    FROM "fee_employee_concession"
    WHERE "mi_id" = "collegefillstafflistforconcession_term_all"."mi_id" 
    AND "hrme_id" = "collegefillstafflistforconcession_term_all"."hrme_id";

    IF "row_count_check" > 0 THEN

        IF "configuration" = 'T' THEN

            "sql1head" := 'SELECT "FMH_FeeName","FTI_Name","Fee_Student_Status_Staff"."FTI_Id","Fee_Student_Status_Staff"."fmh_id","Fee_Student_Status_Staff"."FSSST_ToBePaid" as "FMA_Amount","Fee_Student_Status_Staff"."FCMAS_Id","Fee_Student_Status_Staff"."FMG_Id","FSSST_ConcessionAmount","FEC_ConcessionType","FEC_ConcessionReason","FEC_Id" FROM "fee_employee_concession" INNER JOIN "Fee_Employee_Concession_Installments" ON "fee_employee_concession"."FEC_Id"="Fee_Employee_Concession_Installments"."FECI_FEC_Id" INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id"="fee_employee_concession"."fmh_id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id"="Fee_Employee_Concession_Installments"."fti_id" INNER JOIN "Fee_Student_Status_Staff" ON "Fee_Student_Status_Staff"."hrme_id"="fee_employee_concession"."hrme_id" AND "Fee_Student_Status_Staff"."fmh_id"="fee_employee_concession"."fmh_id" AND "Fee_Student_Status_Staff"."fti_id"="Fee_Employee_Concession_Installments"."fti_id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id"="Fee_Student_Status_Staff"."fmh_id" AND "Fee_Master_Terms_FeeHeads"."fti_id"="Fee_Student_Status_Staff"."fti_id" WHERE "Fee_Student_Status_Staff"."hrme_id"=' || "collegefillstafflistforconcession_term_all"."hrme_id" || ' AND "Fee_Student_Status_Staff"."mi_id"=' || "collegefillstafflistforconcession_term_all"."mi_id" || ' AND "Fee_Student_Status_Staff"."asmay_id"=' || "collegefillstafflistforconcession_term_all"."asmay_id" || ' AND "fmt_id" IN (' || "collegefillstafflistforconcession_term_all"."fmt_id" || ') AND "fee_employee_concession"."ASMAY_Id"=' || "collegefillstafflistforconcession_term_all"."asmay_id" || ' ORDER BY "Fee_Student_Status_Staff"."fmh_id"';

        ELSE

            "sql1head" := 'SELECT "FMH_FeeName","FTI_Name","Fee_Student_Status_Staff"."FTI_Id","Fee_Student_Status_Staff"."fmh_id","Fee_Student_Status_Staff"."FSSST_ToBePaid" as "FMA_Amount","Fee_Student_Status_Staff"."FCMAS_Id","Fee_Student_Status_Staff"."FMG_Id","FSSST_ConcessionAmount","FEC_ConcessionType","FEC_ConcessionReason","FEC_Id" FROM "fee_employee_concession" INNER JOIN "fee_employee_concession_Installments" ON "fee_employee_concession"."FEC_Id"="fee_employee_concession_Installments"."FECI_FEC_Id" INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id"="fee_employee_concession"."fmh_id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id"="fee_employee_concession_Installments"."fti_id" INNER JOIN "Fee_Student_Status_Staff" ON "Fee_Student_Status_Staff"."hrme_id"="fee_employee_concession"."hrme_id" AND "Fee_Student_Status_Staff"."fmh_id"="fee_employee_concession"."fmh_id" AND "fee_student_status"."fti_id"="fee_employee_concession_Installments"."fti_id" WHERE "Fee_Student_Status_Staff"."amst_id"=' || "collegefillstafflistforconcession_term_all"."hrme_id" || ' AND "Fee_Student_Status_Staff"."mi_id"=' || "collegefillstafflistforconcession_term_all"."mi_id" || ' AND "Fee_Student_Status_Staff"."asmay_id"=' || "collegefillstafflistforconcession_term_all"."asmay_id" || ' AND "Fee_Student_Status_Staff"."FMG_Id" IN (' || "collegefillstafflistforconcession_term_all"."fmt_id" || ') AND "fee_employee_concession"."ASMAY_Id"=' || "collegefillstafflistforconcession_term_all"."asmay_id" || ' ORDER BY "Fee_Student_Status_Staff"."fmh_id"';

        END IF;

        FOR "rec" IN EXECUTE "sql1head" LOOP
            "headname" := "rec"."FMH_FeeName";
            "installmentname" := "rec"."FTI_Name";
            "ftiid" := "rec"."FTI_Id";
            "fmhid" := "rec"."fmh_id";
            "ftptobepaidamt" := "rec"."FMA_Amount";
            "fmaid" := "rec"."FCMAS_Id";
            "fmgid" := "rec"."FMG_Id";
            "concessnamount" := "rec"."FSSST_ConcessionAmount";
            "concessiontype" := "rec"."FEC_ConcessionType";
            "concessionreason" := "rec"."FEC_ConcessionReason";
            "fscid" := "rec"."FEC_Id";

            INSERT INTO "v_studentPendingsavedconcession" ("FMH_FeeName","FTI_Name","FTI_Id","fmh_id","FMA_Amount","fma_id","FMG_Id","FSCI_ConcessionAmount","FSC_ConcessionType","FSC_ConcessionReason","mi_id","asmay_id","fsc_id")
            VALUES ("headname","installmentname","ftiid","fmhid","ftptobepaidamt","fmaid","fmgid","concessnamount","concessiontype","concessionreason","collegefillstafflistforconcession_term_all"."mi_id","collegefillstafflistforconcession_term_all"."asmay_id","fscid");

        END LOOP;

        IF "configuration" = 'T' THEN

            "sql1head1" := 'SELECT "FMH_FeeName","FTI_Name","Fee_Student_Status_Staff"."fti_id","Fee_Student_Status_Staff"."fmh_id","FSSST_ToBePaid" as "FMA_Amount","FMA_Id","Fee_Student_Status_Staff"."fmg_id" FROM "Fee_Student_Status_Staff" INNER JOIN "fee_master_head" ON "Fee_Student_Status_Staff"."fmh_id"="fee_master_head"."fmh_id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id"="Fee_Student_Status_Staff"."fti_id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id"="Fee_Student_Status_Staff"."fmh_id" AND "Fee_Master_Terms_FeeHeads"."fti_id"="Fee_Student_Status_Staff"."fti_id" WHERE "Fee_Student_Status_Staff"."hrme_id"=' || "collegefillstafflistforconcession_term_all"."hrme_id" || ' AND "Fee_Student_Status_Staff"."mi_id"=' || "collegefillstafflistforconcession_term_all"."mi_id" || ' AND "Fee_Student_Status_Staff"."asmay_id"=' || "collegefillstafflistforconcession_term_all"."asmay_id" || ' AND "fmt_id" IN (' || "collegefillstafflistforconcession_term_all"."fmt_id" || ') ORDER BY "fmh_id"';

        ELSE

            "sql1head1" := 'SELECT "FMH_FeeName","FTI_Name","Fee_Student_Status_Staff"."fti_id","Fee_Student_Status_Staff"."fmh_id","FSSST_ToBePaid" as "FMA_Amount","FMA_Id","Fee_Student_Status_Staff"."fmg_id" FROM "Fee_Student_Status_Staff" INNER JOIN "fee_master_head" ON "Fee_Student_Status_Staff"."fmh_id"="fee_master_head"."fmh_id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id"="Fee_Student_Status_Staff"."fti_id" WHERE "Fee_Student_Status_Staff"."hrme_id"=' || "collegefillstafflistforconcession_term_all"."hrme_id" || ' AND "Fee_Student_Status_Staff"."mi_id"=' || "collegefillstafflistforconcession_term_all"."mi_id" || ' AND "Fee_Student_Status_Staff"."asmay_id"=' || "collegefillstafflistforconcession_term_all"."asmay_id" || ' AND "Fee_Student_Status_Staff"."FMG_Id" IN (' || "collegefillstafflistforconcession_term_all"."fmt_id" || ') ORDER BY "fmh_id"';

        END IF;

        FOR "rec" IN EXECUTE "sql1head1" LOOP
            "headname" := "rec"."FMH_FeeName";
            "installmentname" := "rec"."FTI_Name";
            "ftiid" := "rec"."fti_id";
            "fmhid" := "rec"."fmh_id";
            "ftptobepaidamt" := "rec"."FMA_Amount";
            "fmaid" := "rec"."FMA_Id";
            "fmgid" := "rec"."fmg_id";

            INSERT INTO "v_studentPendingconcession" ("FMH_FeeName","FTI_Name","fti_id","fmh_id","FMA_Amount","fma_id","fmg_id","asmay_id","mi_id")
            VALUES ("headname","installmentname","ftiid","fmhid","ftptobepaidamt","fmaid","fmgid","collegefillstafflistforconcession_term_all"."asmay_id","collegefillstafflistforconcession_term_all"."mi_id");

        END LOOP;

    ELSE

        IF "configuration" = 'T' THEN

            "sql1head" := 'SELECT "FMH_FeeName","FTI_Name","Fee_Student_Status_Staff"."fti_id","Fee_Student_Status_Staff"."fmh_id","FSSST_ToBePaid" as "FMA_Amount","FMA_Id","Fee_Student_Status_Staff"."fmg_id" FROM "Fee_Student_Status_Staff" INNER JOIN "fee_master_head" ON "Fee_Student_Status_Staff"."fmh_id"="fee_master_head"."fmh_id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id"="Fee_Student_Status_Staff"."fti_id" INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id"="Fee_Student_Status_Staff"."fmh_id" AND "Fee_Master_Terms_FeeHeads"."fti_id"="Fee_Student_Status_Staff"."fti_id" WHERE "Fee_Student_Status_Staff"."hrme_id"=' || "collegefillstafflistforconcession_term_all"."hrme_id" || ' AND "Fee_Student_Status_Staff"."mi_id"=' || "collegefillstafflistforconcession_term_all"."mi_id" || ' AND "Fee_Student_Status_Staff"."asmay_id"=' || "collegefillstafflistforconcession_term_all"."asmay_id" || ' AND "fmt_id" IN (' || "collegefillstafflistforconcession_term_all"."fmt_id" || ') ORDER BY "fmh_id"';

        ELSE

            "sql1head" := 'SELECT "FMH_FeeName","FTI_Name","Fee_Student_Status_Staff"."fti_id","Fee_Student_Status_Staff"."fmh_id","FSSST_ToBePaid" as "FMA_Amount","FMA_Id","Fee_Student_Status_Staff"."fmg_id" FROM "Fee_Student_Status_Staff" INNER JOIN "fee_master_head" ON "Fee_Student_Status_Staff"."fmh_id"="fee_master_head"."fmh_id" INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id"="Fee_Student_Status_Staff"."fti_id" WHERE "Fee_Student_Status_Staff"."hrme_id"=' || "collegefillstafflistforconcession_term_all"."hrme_id" || ' AND "Fee_Student_Status_Staff"."mi_id"=' || "collegefillstafflistforconcession_term_all"."mi_id" || ' AND "Fee_Student_Status_Staff"."asmay_id"=' || "collegefillstafflistforconcession_term_all"."asmay_id" || ' AND "Fee_Student_Status_Staff"."FMG_Id" IN (' || "collegefillstafflistforconcession_term_all"."fmt_id" || ') ORDER BY "fmh_id"';

        END IF;

        FOR "rec" IN EXECUTE "sql1head" LOOP
            "headname" := "rec"."FMH_FeeName";
            "installmentname" := "rec"."FTI_Name";
            "ftiid" := "rec"."fti_id";
            "fmhid" := "rec"."fmh_id";
            "ftptobepaidamt" := "rec"."FMA_Amount";
            "fmaid" := "rec"."FMA_Id";
            "fmgid" := "rec"."fmg_id";

            INSERT INTO "v_studentPendingconcession" ("FMH_FeeName","FTI_Name","fti_id","fmh_id","FMA_Amount","fma_id","fmg_id","asmay_id","mi_id")
            VALUES ("headname","installmentname","ftiid","fmhid","ftptobepaidamt","fmaid","fmgid","collegefillstafflistforconcession_term_all"."asmay_id","collegefillstafflistforconcession_term_all"."mi_id");

        END LOOP;

    END IF;

END;
$$;