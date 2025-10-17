CREATE OR REPLACE FUNCTION "dbo"."fillotherslistforconcessioncollegeterm_all"(
    "p_FMOST_Id" TEXT,
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
    "v_rec" RECORD;
    "v_rowcount" INTEGER;
BEGIN
    DELETE FROM "v_studentPendingsavedconcession" WHERE "mi_id" = "p_mi_id";
    DELETE FROM "v_studentPendingconcession" WHERE "mi_id" = "p_mi_id";
    
    SELECT COUNT(*) INTO "v_rowcount"
    FROM "CLG"."Fee_Others_Concession_College" 
    WHERE "mi_id" = "p_mi_id" AND "FMCOST_Id" = "p_FMOST_Id";
    
    IF "v_rowcount" > 0 THEN
        IF "p_configuration" = 'T' THEN
            "v_sql1head" := 'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_OthStu"."FTI_Id", "CLG"."Fee_College_Student_Status_OthStu"."fmh_id", "CLG"."Fee_College_Student_Status_OthStu"."FSSOST_ToBePaid" AS "FMA_Amount", "CLG"."Fee_College_Student_Status_OthStu"."FCMA_Id", "CLG"."Fee_College_Student_Status_OthStu"."FMG_Id", 
            "FCSSOST_ConcessionAmount", "FOC_ConcessionType", "FOC_ConcessionReason", 
            "Fee_Others_Concession"."FOC_Id" FROM "Fee_Others_Concession" 
            INNER JOIN "Fee_Others_Concession_Installments" ON "Fee_Others_Concession"."FOC_Id" = "Fee_Others_Concession_Installments"."FOC_Id" 
            INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id" = "Fee_Others_Concession"."fmh_id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "Fee_Others_Concession_Installments"."fti_id" 
            INNER JOIN "CLG"."Fee_College_Student_Status_OthStu" ON "CLG"."Fee_College_Student_Status_OthStu"."FMOST_Id" = "Fee_Others_Concession"."FMOST_Id" 
            AND "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" = "Fee_Others_Concession"."fmh_id" 
            AND "CLG"."Fee_College_Student_Status_OthStu"."fti_id" = "Fee_Others_Concession_Installments"."fti_id" 
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" 
            AND "Fee_Master_Terms_FeeHeads"."fti_id" = "CLG"."Fee_College_Student_Status_OthStu"."fti_id" 
            WHERE "CLG"."Fee_College_Student_Status_OthStu"."FMCOST_Id" = ' || "p_FMOST_Id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."mi_id" = ' || "p_mi_id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."asmay_id" = ' || "p_asmay_id" || ' 
            AND "fmt_id" IN (' || "p_fmt_id" || ') 
            AND "Fee_Others_Concession"."ASMAY_Id" = ' || "p_asmay_id" || ' 
            ORDER BY "CLG"."Fee_College_Student_Status_OthStu"."fmh_id"';
        ELSE
            "v_sql1head" := 'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_OthStu"."FTI_Id", "CLG"."Fee_College_Student_Status_OthStu"."fmh_id", "CLG"."Fee_College_Student_Status_OthStu"."FCSSOST_ToBePaid" AS "FMA_Amount", "CLG"."Fee_College_Student_Status_OthStu"."FCMA_Id", "CLG"."Fee_College_Student_Status_OthStu"."FMG_Id", "FCSSOST_ConcessionAmount", 
            "FOC_ConcessionType", "FOC_ConcessionReason", "Fee_Others_Concession"."FOC_Id" 
            FROM "Fee_Others_Concession" 
            INNER JOIN "Fee_Others_Concession_Installments" ON "Fee_Others_Concession"."FOC_Id" = "Fee_Others_Concession_Installments"."FOC_Id" 
            INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id" = "Fee_Others_Concession"."fmh_id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "Fee_Others_Concession_Installments"."fti_id" 
            INNER JOIN "CLG"."Fee_College_Student_Status_OthStu" ON "CLG"."Fee_College_Student_Status_OthStu"."FMOST_Id" = "Fee_Others_Concession"."FMOST_Id" 
            AND "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" = "Fee_Others_Concession"."fmh_id" 
            AND "CLG"."Fee_College_Student_Status_OthStu"."fti_id" = "Fee_Others_Concession_Installments"."fti_id" 
            WHERE "CLG"."Fee_College_Student_Status_OthStu"."FMCOST_Id" = ' || "p_FMOST_Id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."mi_id" = ' || "p_mi_id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."asmay_id" = ' || "p_asmay_id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."FMG_Id" IN (' || "p_fmt_id" || ') 
            AND "Fee_Others_Concession"."ASMAY_Id" = ' || "p_asmay_id" || ' 
            ORDER BY "CLG"."Fee_College_Student_Status_OthStu"."fmh_id"';
        END IF;
        
        FOR "v_rec" IN EXECUTE "v_sql1head" LOOP
            "v_headname" := "v_rec"."FMH_FeeName";
            "v_installmentname" := "v_rec"."FTI_Name";
            "v_ftiid" := "v_rec"."FTI_Id";
            "v_fmhid" := "v_rec"."fmh_id";
            "v_ftptobepaidamt" := "v_rec"."FMA_Amount";
            "v_fmaid" := "v_rec"."FCMA_Id";
            "v_fmgid" := "v_rec"."FMG_Id";
            "v_concessnamount" := "v_rec"."FCSSOST_ConcessionAmount";
            "v_concessiontype" := "v_rec"."FOC_ConcessionType";
            "v_concessionreason" := "v_rec"."FOC_ConcessionReason";
            "v_fscid" := "v_rec"."FOC_Id";
            
            INSERT INTO "v_studentPendingsavedconcession" (
                "FMH_FeeName", "FTI_Name", "FTI_Id", "fmh_id", "FMA_Amount", "fma_id", "FMG_Id", 
                "FSCI_ConcessionAmount", "FSC_ConcessionType", "FSC_ConcessionReason", "mi_id", "asmay_id", "fsc_id"
            ) VALUES (
                "v_headname", "v_installmentname", "v_ftiid", "v_fmhid", "v_ftptobepaidamt", 
                "v_fmaid", "v_fmgid", "v_concessnamount", "v_concessiontype", "v_concessionreason", 
                "p_mi_id", "p_asmay_id", "v_fscid"
            );
        END LOOP;
        
        IF "p_configuration" = 'T' THEN
            "v_sql1head1" := 'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_OthStu"."fti_id", "CLG"."Fee_College_Student_Status_OthStu"."fmh_id", "FCSSOST_ToBePaid" AS "FMA_Amount", "FCMA_Id", "CLG"."Fee_College_Student_Status_OthStu"."fmg_id" 
            FROM "CLG"."Fee_College_Student_Status_OthStu" 
            INNER JOIN "fee_master_head" ON "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" = "fee_master_head"."fmh_id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_College_Student_Status_OthStu"."fti_id" 
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" 
            AND "Fee_Master_Terms_FeeHeads"."fti_id" = "CLG"."Fee_College_Student_Status_OthStu"."fti_id" 
            WHERE "CLG"."Fee_College_Student_Status_OthStu"."FMCOST_Id" = ' || "p_FMOST_Id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."mi_id" = ' || "p_mi_id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."asmay_id" = ' || "p_asmay_id" || ' 
            AND "fmt_id" IN (' || "p_fmt_id" || ') 
            ORDER BY "fmh_id"';
        ELSE
            "v_sql1head1" := 'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_OthStu"."fti_id", "CLG"."Fee_College_Student_Status_OthStu"."fmh_id", "FCSSOST_ToBePaid" AS "FMA_Amount", "FCMA_Id", "CLG"."Fee_College_Student_Status_OthStu"."fmg_id" 
            FROM "CLG"."Fee_College_Student_Status_OthStu" 
            INNER JOIN "fee_master_head" ON "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" = "fee_master_head"."fmh_id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_College_Student_Status_OthStu"."fti_id" 
            WHERE "CLG"."Fee_College_Student_Status_OthStu"."FMCOST_Id" = ' || "p_FMOST_Id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."mi_id" = ' || "p_mi_id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."asmay_id" = ' || "p_asmay_id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."FMG_Id" IN (' || "p_fmt_id" || ') 
            ORDER BY "fmh_id"';
        END IF;
        
        FOR "v_rec" IN EXECUTE "v_sql1head1" LOOP
            "v_headname" := "v_rec"."FMH_FeeName";
            "v_installmentname" := "v_rec"."FTI_Name";
            "v_ftiid" := "v_rec"."fti_id";
            "v_fmhid" := "v_rec"."fmh_id";
            "v_ftptobepaidamt" := "v_rec"."FMA_Amount";
            "v_fmaid" := "v_rec"."FCMA_Id";
            "v_fmgid" := "v_rec"."fmg_id";
            
            INSERT INTO "v_studentPendingconcession" (
                "FMH_FeeName", "FTI_Name", "fti_id", "fmh_id", "FMA_Amount", "fma_id", "fmg_id", "asmay_id", "mi_id"
            ) VALUES (
                "v_headname", "v_installmentname", "v_ftiid", "v_fmhid", "v_ftptobepaidamt", "v_fmaid", "v_fmgid", "p_asmay_id", "p_mi_id"
            );
        END LOOP;
    ELSE
        IF "p_configuration" = 'T' THEN
            "v_sql1head" := 'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_OthStu"."fti_id", "CLG"."Fee_College_Student_Status_OthStu"."fmh_id", "FCSSOST_ToBePaid" AS "FMA_Amount", "FCMA_Id", "CLG"."Fee_College_Student_Status_OthStu"."fmg_id" 
            FROM "CLG"."Fee_College_Student_Status_OthStu" 
            INNER JOIN "fee_master_head" ON "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" = "fee_master_head"."fmh_id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_College_Student_Status_OthStu"."fti_id" 
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id" = "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" 
            AND "Fee_Master_Terms_FeeHeads"."fti_id" = "CLG"."Fee_College_Student_Status_OthStu"."fti_id" 
            WHERE "CLG"."Fee_College_Student_Status_OthStu"."FMCOST_Idd" = ' || "p_FMOST_Id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."mi_id" = ' || "p_mi_id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."asmay_id" = ' || "p_asmay_id" || ' 
            AND "fmt_id" IN (' || "p_fmt_id" || ') 
            ORDER BY "fmh_id"';
        ELSE
            "v_sql1head" := 'SELECT "FMH_FeeName", "FTI_Name", "CLG"."Fee_College_Student_Status_OthStu"."fti_id", "CLG"."Fee_College_Student_Status_OthStu"."fmh_id", "FCSSOST_ToBePaid" AS "FMA_Amount", "FCMA_Id", "CLG"."Fee_College_Student_Status_OthStu"."fmg_id" 
            FROM "CLG"."Fee_College_Student_Status_OthStu" 
            INNER JOIN "fee_master_head" ON "CLG"."Fee_College_Student_Status_OthStu"."fmh_id" = "fee_master_head"."fmh_id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id" = "CLG"."Fee_College_Student_Status_OthStu"."fti_id" 
            WHERE "CLG"."Fee_College_Student_Status_OthStu"."FMCOST_Id" = ' || "p_FMOST_Id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."mi_id" = ' || "p_mi_id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."asmay_id" = ' || "p_asmay_id" || ' 
            AND "CLG"."Fee_College_Student_Status_OthStu"."FMG_Id" IN (' || "p_fmt_id" || ') 
            ORDER BY "fmh_id"';
        END IF;
        
        FOR "v_rec" IN EXECUTE "v_sql1head" LOOP
            "v_headname" := "v_rec"."FMH_FeeName";
            "v_installmentname" := "v_rec"."FTI_Name";
            "v_ftiid" := "v_rec"."fti_id";
            "v_fmhid" := "v_rec"."fmh_id";
            "v_ftptobepaidamt" := "v_rec"."FMA_Amount";
            "v_fmaid" := "v_rec"."FCMA_Id";
            "v_fmgid" := "v_rec"."fmg_id";
            
            INSERT INTO "v_studentPendingconcession" (
                "FMH_FeeName", "FTI_Name", "fti_id", "fmh_id", "FMA_Amount", "fma_id", "fmg_id", "asmay_id", "mi_id"
            ) VALUES (
                "v_headname", "v_installmentname", "v_ftiid", "v_fmhid", "v_ftptobepaidamt", "v_fmaid", "v_fmgid", "p_asmay_id", "p_mi_id"
            );
        END LOOP;
    END IF;
END;
$$;