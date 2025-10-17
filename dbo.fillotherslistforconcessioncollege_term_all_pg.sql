CREATE OR REPLACE FUNCTION "dbo"."fillotherslistforconcessioncollege_term_all"(
    "FMOST_Id" TEXT,
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
    "row_count_result" INTEGER;
    "cursor_rec" RECORD;
BEGIN
    DELETE FROM "v_studentPendingsavedconcession" WHERE "mi_id" = "fillotherslistforconcessioncollege_term_all"."mi_id";
    DELETE FROM "v_studentPendingconcession" WHERE "mi_id" = "fillotherslistforconcessioncollege_term_all"."mi_id";
    
    SELECT COUNT(*) INTO "row_count_result" 
    FROM "Fee_Others_Concession" 
    WHERE "mi_id" = "fillotherslistforconcessioncollege_term_all"."mi_id" 
    AND "FMOST_Id" = "fillotherslistforconcessioncollege_term_all"."FMOST_Id";
    
    IF "row_count_result" > 0 THEN
        IF "configuration" = 'T' THEN
            "sql1head" := 'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_OthStu"."FTI_Id", 
                "CLG"."Fee_College_Student_Status_OthStu"."fmh_id", 
                "CLG"."Fee_College_Student_Status_OthStu"."FCSSOST_ToBePaid", 
                "CLG"."Fee_College_Student_Status_OthStu"."FMCAOST_Id", 
                "CLG"."Fee_College_Student_Status_OthStu"."FMG_Id", 
                "FCSSOST_ConcessionAmount", "FOCC_ConcessionType", "FOCC_ConcessionReason", 
                "CLG"."Fee_Others_Concession_College"."FOCC_Id" 
            FROM "CLG"."Fee_Others_Concession_College" 
            INNER JOIN "CLG"."Fee_Others_Concession_Installments_College" 
                ON "CLG"."Fee_Others_Concession_College"."FOCC_Id" = "CLG"."Fee_Others_Concession_Installments_College"."FOCC_Id"
            INNER JOIN "fee_master_head" 
                ON "fee_master_head"."fmh_id" = "CLG"."Fee_Others_Concession_College"."fmh_id"
            INNER JOIN "Fee_T_Installment" 
                ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_Others_Concession_Installments_College"."fti_id"
            INNER JOIN "CLG"."Fee_College_Student_Status_OthStu" 
                ON "CLG"."Fee_College_Student_Status_OthStu"."FMCOST_Id" = "CLG"."Fee_Others_Concession_College"."FMCOST_Id"
                AND "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" = "CLG"."Fee_Others_Concession_College"."fmh_id"
                AND "CLG"."Fee_College_Student_Status_OthStu"."fti_id" = "CLG"."Fee_Others_Concession_Installments_College"."fti_id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" 
                ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "CLG"."Fee_College_Student_Status_OthStu"."fmh_id"
                AND "Fee_Master_Terms_FeeHeads"."fti_id" = "CLG"."Fee_College_Student_Status_OthStu"."fti_id"
            WHERE "CLG"."Fee_College_Student_Status_OthStu"."FMCOST_Id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."FMOST_Id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."mi_id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."mi_id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."asmay_id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."asmay_id") || '
                AND "fmt_id" IN (' || "fillotherslistforconcessioncollege_term_all"."fmt_id" || ')
                AND "CLG"."Fee_Others_Concession_College"."ASMAY_Id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."asmay_id") || '
            ORDER BY "CLG"."Fee_College_Student_Status_OthStu"."fmh_id"';
        ELSE
            "sql1head" := 'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_OthStu"."FTI_Id", 
                "CLG"."Fee_College_Student_Status_OthStu"."fmh_id", 
                "CLG"."Fee_College_Student_Status_OthStu"."FCSSOST_ToBePaid", 
                "CLG"."Fee_College_Student_Status_OthStu"."FMCAOST_Id", 
                "CLG"."Fee_College_Student_Status_OthStu"."FMG_Id", 
                "FCSSOST_ConcessionAmount", "FOCC_ConcessionType", "FOCC_ConcessionReason", 
                "CLG"."Fee_Others_Concession_College"."FOCC_Id" 
            FROM "CLG"."Fee_Others_Concession_College" 
            INNER JOIN "CLG"."Fee_Others_Concession_Installments_College" 
                ON "CLG"."Fee_Others_Concession_College"."FOCC_Id" = "CLG"."Fee_Others_Concession_Installments_College"."FOCC_Id"
            INNER JOIN "fee_master_head" 
                ON "fee_master_head"."fmh_id" = "CLG"."Fee_Others_Concession_College"."fmh_id"
            INNER JOIN "Fee_T_Installment" 
                ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_Others_Concession_Installments_College"."fti_id"
            INNER JOIN "CLG"."Fee_College_Student_Status_OthStu" 
                ON "CLG"."Fee_College_Student_Status_OthStu"."FMCOST_Id" = "CLG"."Fee_Others_Concession_College"."FMCOST_Id"
                AND "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" = "CLG"."Fee_Others_Concession_College"."fmh_id"
                AND "CLG"."Fee_College_Student_Status_OthStu"."fti_id" = "CLG"."Fee_Others_Concession_Installments_College"."fti_id"
            WHERE "CLG"."Fee_College_Student_Status_OthStu"."FMCOST_Id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."FMOST_Id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."mi_id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."mi_id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."asmay_id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."asmay_id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."FMG_Id" IN (' || "fillotherslistforconcessioncollege_term_all"."fmt_id" || ')
                AND "CLG"."Fee_Others_Concession_College"."ASMAY_Id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."asmay_id") || '
            ORDER BY "CLG"."Fee_College_Student_Status_OthStu"."fmh_id"';
        END IF;
        
        FOR "cursor_rec" IN EXECUTE "sql1head" LOOP
            "headname" := "cursor_rec"."FMH_FeeName";
            "installmentname" := "cursor_rec"."FTI_Name";
            "ftiid" := "cursor_rec"."FTI_Id";
            "fmhid" := "cursor_rec"."fmh_id";
            "ftptobepaidamt" := "cursor_rec"."FCSSOST_ToBePaid";
            "fmaid" := "cursor_rec"."FMCAOST_Id";
            "fmgid" := "cursor_rec"."FMG_Id";
            "concessnamount" := "cursor_rec"."FCSSOST_ConcessionAmount";
            "concessiontype" := "cursor_rec"."FOCC_ConcessionType";
            "concessionreason" := "cursor_rec"."FOCC_ConcessionReason";
            "fscid" := "cursor_rec"."FOCC_Id";
            
            INSERT INTO "v_studentPendingsavedconcession" (
                "FMH_FeeName", "FTI_Name", "FTI_Id", "fmh_id", "FMA_Amount", "fma_id", "FMG_Id", 
                "FSCI_ConcessionAmount", "FSC_ConcessionType", "FSC_ConcessionReason", "mi_id", "asmay_id", "fsc_id"
            ) VALUES (
                "headname", "installmentname", "ftiid", "fmhid", "ftptobepaidamt", 
                "fmaid", "fmgid", "concessnamount", "concessiontype", "concessionreason", 
                "fillotherslistforconcessioncollege_term_all"."mi_id", 
                "fillotherslistforconcessioncollege_term_all"."asmay_id", "fscid"
            );
        END LOOP;
        
        IF "configuration" = 'T' THEN
            "sql1head1" := 'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_OthStu"."fti_id", 
                "CLG"."Fee_College_Student_Status_OthStu"."fmh_id", "FCSSOST_ToBePaid", "FMCAOST_Id", 
                "CLG"."Fee_College_Student_Status_OthStu"."fmg_id"
            FROM "CLG"."Fee_College_Student_Status_OthStu"
            INNER JOIN "fee_master_head" 
                ON "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" = "fee_master_head"."fmh_id"
            INNER JOIN "Fee_T_Installment" 
                ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_College_Student_Status_OthStu"."fti_id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" 
                ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "CLG"."Fee_College_Student_Status_OthStu"."fmh_id"
                AND "Fee_Master_Terms_FeeHeads"."fti_id" = "CLG"."Fee_College_Student_Status_OthStu"."fti_id"
            WHERE "CLG"."Fee_College_Student_Status_OthStu"."FMCOST_Id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."FMOST_Id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."mi_id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."mi_id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."asmay_id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."asmay_id") || '
                AND "fmt_id" IN (' || "fillotherslistforconcessioncollege_term_all"."fmt_id" || ')
            ORDER BY "fmh_id"';
        ELSE
            "sql1head1" := 'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_OthStu"."fti_id", 
                "CLG"."Fee_College_Student_Status_OthStu"."fmh_id", "FCSSOST_ToBePaid", "FMCAOST_Id", 
                "CLG"."Fee_College_Student_Status_OthStu"."fmg_id"
            FROM "CLG"."Fee_College_Student_Status_OthStu"
            INNER JOIN "fee_master_head" 
                ON "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" = "fee_master_head"."fmh_id"
            INNER JOIN "Fee_T_Installment" 
                ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_College_Student_Status_OthStu"."fti_id"
            WHERE "CLG"."Fee_College_Student_Status_OthStu"."FMCOST_Id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."FMOST_Id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."mi_id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."mi_id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."asmay_id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."asmay_id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."FMG_Id" IN (' || "fillotherslistforconcessioncollege_term_all"."fmt_id" || ')
            ORDER BY "fmh_id"';
        END IF;
        
        FOR "cursor_rec" IN EXECUTE "sql1head1" LOOP
            "headname" := "cursor_rec"."FMH_FeeName";
            "installmentname" := "cursor_rec"."FTI_Name";
            "ftiid" := "cursor_rec"."fti_id";
            "fmhid" := "cursor_rec"."fmh_id";
            "ftptobepaidamt" := "cursor_rec"."FCSSOST_ToBePaid";
            "fmaid" := "cursor_rec"."FMCAOST_Id";
            "fmgid" := "cursor_rec"."fmg_id";
            
            INSERT INTO "v_studentPendingconcession" (
                "FMH_FeeName", "FTI_Name", "fti_id", "fmh_id", "FMA_Amount", "fma_id", "fmg_id", "asmay_id", "mi_id"
            ) VALUES (
                "headname", "installmentname", "ftiid", "fmhid", "ftptobepaidamt", 
                "fmaid", "fmgid", "fillotherslistforconcessioncollege_term_all"."asmay_id", 
                "fillotherslistforconcessioncollege_term_all"."mi_id"
            );
        END LOOP;
    ELSE
        IF "configuration" = 'T' THEN
            "sql1head" := 'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_OthStu"."fti_id", 
                "CLG"."Fee_College_Student_Status_OthStu"."fmh_id", "FCSSOST_ToBePaid", "FMCAOST_Id", 
                "CLG"."Fee_College_Student_Status_OthStu"."fmg_id"
            FROM "CLG"."Fee_College_Student_Status_OthStu"
            INNER JOIN "fee_master_head" 
                ON "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" = "fee_master_head"."fmh_id"
            INNER JOIN "Fee_T_Installment" 
                ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_College_Student_Status_OthStu"."fti_id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" 
                ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "CLG"."Fee_College_Student_Status_OthStu"."fmh_id"
                AND "Fee_Master_Terms_FeeHeads"."fti_id" = "CLG"."Fee_College_Student_Status_OthStu"."fti_id"
            WHERE "CLG"."Fee_College_Student_Status_OthStu"."FMOST_Id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."FMOST_Id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."mi_id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."mi_id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."asmay_id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."asmay_id") || '
                AND "fmt_id" IN (' || "fillotherslistforconcessioncollege_term_all"."fmt_id" || ')
            ORDER BY "fmh_id"';
        ELSE
            "sql1head" := 'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_OthStu"."fti_id", 
                "CLG"."Fee_College_Student_Status_OthStu"."fmh_id", "FCSSOST_ToBePaid", "FMCAOST_Id", 
                "CLG"."Fee_College_Student_Status_OthStu"."fmg_id"
            FROM "CLG"."Fee_College_Student_Status_OthStu"
            INNER JOIN "fee_master_head" 
                ON "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" = "fee_master_head"."fmh_id"
            INNER JOIN "Fee_T_Installment" 
                ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_College_Student_Status_OthStu"."fti_id"
            WHERE "CLG"."Fee_College_Student_Status_OthStu"."FMCOST_Id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."FMOST_Id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."mi_id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."mi_id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."asmay_id" = ' || quote_literal("fillotherslistforconcessioncollege_term_all"."asmay_id") || '
                AND "CLG"."Fee_College_Student_Status_OthStu"."FMG_Id" IN (' || "fillotherslistforconcessioncollege_term_all"."fmt_id" || ')
            ORDER BY "fmh_id"';
        END IF;
        
        FOR "cursor_rec" IN EXECUTE "sql1head" LOOP
            "headname" := "cursor_rec"."FMH_FeeName";
            "installmentname" := "cursor_rec"."FTI_Name";
            "ftiid" := "cursor_rec"."fti_id";
            "fmhid" := "cursor_rec"."fmh_id";
            "ftptobepaidamt" := "cursor_rec"."FCSSOST_ToBePaid";
            "fmaid" := "cursor_rec"."FMCAOST_Id";
            "fmgid" := "cursor_rec"."fmg_id";
            
            INSERT INTO "v_studentPendingconcession" (
                "FMH_FeeName", "FTI_Name", "fti_id", "fmh_id", "FMA_Amount", "fma_id", "fmg_id", "asmay_id", "mi_id"
            ) VALUES (
                "headname", "installmentname", "ftiid", "fmhid", "ftptobepaidamt", 
                "fmaid", "fmgid", "fillotherslistforconcessioncollege_term_all"."asmay_id", 
                "fillotherslistforconcessioncollege_term_all"."mi_id"
            );
        END LOOP;
    END IF;
    
    RETURN;
END;
$$;