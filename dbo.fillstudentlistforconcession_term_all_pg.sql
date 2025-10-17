CREATE OR REPLACE FUNCTION "dbo"."fillstudentlistforconcession_term_all"(
    "p_amst_id" TEXT,
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
    FROM "fee_student_concession" 
    WHERE "mi_id" = "p_mi_id" 
        AND "amst_id" = "p_amst_id" 
        AND "ASMAY_ID" = "p_asmay_id";

    IF "v_rowcount" > 0 THEN

        IF "p_configuration" = 'T' THEN

            "v_sql1head" := 'SELECT "FMH_FeeName","FTI_Name","fee_student_status"."FTI_Id","fee_student_status"."fmh_id","fee_student_status"."FSS_ToBePaid" as "FMA_Amount","fee_student_status"."FMA_Id","fee_student_status"."FMG_Id","FSCI_ConcessionAmount","FSC_ConcessionType","FSC_ConcessionReason","fsc_id" 
            FROM "fee_student_concession" 
            INNER JOIN "Fee_Student_Concession_Installments" ON "fee_student_concession"."fsc_id"="Fee_Student_Concession_Installments"."fsci_fsc_id" 
            INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id"="fee_student_concession"."fmh_id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id"="Fee_Student_Concession_Installments"."fti_id" 
            INNER JOIN "fee_student_status" ON "fee_student_status"."amst_id"="fee_student_concession"."amst_id" 
                AND "fee_student_status"."fmh_id"="fee_student_concession"."fmh_id" 
                AND "fee_student_status"."fti_id"="Fee_Student_Concession_Installments"."fti_id" 
                AND "fee_student_status"."ASMAY_Id"="fee_student_concession"."ASMAY_Id" 
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id"="fee_student_status"."fmh_id" 
                AND "Fee_Master_Terms_FeeHeads"."fti_id"="fee_student_status"."fti_id"
            WHERE "fee_student_status"."amst_id"=' || quote_literal("p_amst_id") || ' 
                AND "fee_student_status"."mi_id"=' || quote_literal("p_mi_id") || ' 
                AND "fee_student_status"."asmay_id"=' || quote_literal("p_asmay_id") || ' 
                AND "fmt_id" IN (' || "p_fmt_id" || ')';

        ELSE

            "v_sql1head" := 'SELECT "FMH_FeeName","FTI_Name","fee_student_status"."FTI_Id","fee_student_status"."fmh_id","fee_student_status"."FSS_ToBePaid" as "FMA_Amount","fee_student_status"."FMA_Id","fee_student_status"."FMG_Id","FSCI_ConcessionAmount","FSC_ConcessionType","FSC_ConcessionReason","fsc_id" 
            FROM "fee_student_concession" 
            INNER JOIN "Fee_Student_Concession_Installments" ON "fee_student_concession"."fsc_id"="Fee_Student_Concession_Installments"."fsci_fsc_id" 
            INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id"="fee_student_concession"."fmh_id" 
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id"="Fee_Student_Concession_Installments"."fti_id" 
            INNER JOIN "fee_student_status" ON "fee_student_status"."amst_id"="fee_student_concession"."amst_id" 
                AND "fee_student_status"."fmh_id"="fee_student_concession"."fmh_id" 
                AND "fee_student_status"."fti_id"="Fee_Student_Concession_Installments"."fti_id" 
            WHERE "fee_student_status"."amst_id"=' || quote_literal("p_amst_id") || ' 
                AND "fee_student_status"."mi_id"=' || quote_literal("p_mi_id") || ' 
                AND "fee_student_status"."asmay_id"=' || quote_literal("p_asmay_id") || ' 
                AND "fee_student_status"."FMG_Id" IN (' || "p_fmt_id" || ') 
            ORDER BY "fee_student_status"."fmh_id"';

        END IF;

        FOR "rec" IN EXECUTE "v_sql1head" LOOP
            "v_headname" := "rec"."FMH_FeeName";
            "v_installmentname" := "rec"."FTI_Name";
            "v_ftiid" := "rec"."FTI_Id";
            "v_fmhid" := "rec"."fmh_id";
            "v_ftptobepaidamt" := "rec"."FMA_Amount";
            "v_fmaid" := "rec"."FMA_Id";
            "v_fmgid" := "rec"."FMG_Id";
            "v_concessnamount" := "rec"."FSCI_ConcessionAmount";
            "v_concessiontype" := "rec"."FSC_ConcessionType";
            "v_concessionreason" := "rec"."FSC_ConcessionReason";
            "v_fscid" := "rec"."fsc_id";

            INSERT INTO "v_studentPendingsavedconcession" 
                ("FMH_FeeName","FTI_Name","FTI_Id","fmh_id","FMA_Amount","fma_id","FMG_Id","FSCI_ConcessionAmount","FSC_ConcessionType","FSC_ConcessionReason","mi_id","asmay_id","fsc_id") 
            VALUES 
                ("v_headname","v_installmentname","v_ftiid","v_fmhid","v_ftptobepaidamt","v_fmaid","v_fmgid","v_concessnamount","v_concessiontype","v_concessionreason","p_mi_id","p_asmay_id","v_fscid");
        END LOOP;

        IF "p_configuration" = 'T' THEN

            "v_sql1head1" := 'SELECT "FMH_FeeName","FTI_Name","fee_student_status"."fti_id","fee_student_status"."fmh_id","FSS_ToBePaid" as "FMA_Amount","FMA_Id","fee_student_status"."fmg_id" 
            FROM "fee_student_status" 
            INNER JOIN "fee_master_head" ON "fee_student_status"."fmh_id"="fee_master_head"."fmh_id"
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id"="fee_student_status"."fti_id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id"="fee_student_status"."fmh_id" 
                AND "Fee_Master_Terms_FeeHeads"."fti_id"="fee_student_status"."fti_id"
            WHERE "fee_student_status"."amst_id"=' || quote_literal("p_amst_id") || ' 
                AND "fee_student_status"."mi_id"=' || quote_literal("p_mi_id") || ' 
                AND "fee_student_status"."asmay_id"=' || quote_literal("p_asmay_id") || ' 
                AND "fmt_id" IN (' || "p_fmt_id" || ') 
            UNION ALL
            SELECT "FMH_FeeName","FTI_Name",a."FTI_Id",a."fmh_id",a."FSS_ToBePaid" as "FMA_Amount",a."FMA_Id",a."FMG_Id" 
            FROM "Fee_Student_Status" as a 
            INNER JOIN "Fee_Master_Head" as b ON a."FMH_Id"=b."FMH_Id"
            INNER JOIN "Fee_Master_Amount" as c ON a."FMA_Id"=c."FMA_Id" 
            INNER JOIN "Fee_Master_Terms_FeeHeads" as d ON d."fmh_id"=a."fmh_id" AND d."fti_id"=a."fti_id"
            INNER JOIN "Fee_T_Installment" as e ON e."FTI_Id"=a."FTI_Id"
            WHERE a."amst_id"=' || quote_literal("p_amst_id") || ' 
                AND a."mi_id"=' || quote_literal("p_mi_id") || ' 
                AND a."asmay_id"=' || quote_literal("p_asmay_id") || ' 
                AND "fmt_id" IN (' || "p_fmt_id" || ') 
                AND a."fss_tobepaid">0 
            UNION ALL
            SELECT "FMH_FeeName","FTI_Name",a."FTI_Id",a."fmh_id",a."FSS_ToBePaid" as "FMA_Amount",a."FMA_Id",a."FMG_Id" 
            FROM "Fee_Student_Status" as a 
            INNER JOIN "Fee_Master_Head" as b ON a."FMH_Id"=b."FMH_Id"
            INNER JOIN "Fee_Master_Amount" as c ON a."FMA_Id"=c."FMA_Id" 
            INNER JOIN "Fee_Master_SpecialFeeHead_FeeHead" as d ON d."fmh_id"=a."fmh_id" 
            INNER JOIN "Fee_T_Installment" as e ON e."FTI_Id"=a."FTI_Id"
            WHERE a."amst_id"=' || quote_literal("p_amst_id") || ' 
                AND a."mi_id"=' || quote_literal("p_mi_id") || ' 
                AND a."asmay_id"=' || quote_literal("p_asmay_id") || ' 
                AND a."fss_tobepaid">0';

        ELSE

            "v_sql1head1" := 'SELECT "FMH_FeeName","FTI_Name","fee_student_status"."fti_id","fee_student_status"."fmh_id","FSS_ToBePaid" as "FMA_Amount","FMA_Id","fee_student_status"."fmg_id" 
            FROM "fee_student_status" 
            INNER JOIN "fee_master_head" ON "fee_student_status"."fmh_id"="fee_master_head"."fmh_id"
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id"="fee_student_status"."fti_id"
            WHERE "fee_student_status"."amst_id"=' || quote_literal("p_amst_id") || ' 
                AND "fee_student_status"."mi_id"=' || quote_literal("p_mi_id") || ' 
                AND "fee_student_status"."asmay_id"=' || quote_literal("p_asmay_id") || ' 
                AND "fee_student_status"."FMG_Id" IN (' || "p_fmt_id" || ')  
            UNION ALL
            SELECT "FMH_FeeName","FTI_Name",a."FTI_Id",a."fmh_id",a."FSS_ToBePaid" as "FMA_Amount",a."FMA_Id",a."FMG_Id" 
            FROM "Fee_Student_Status" as a 
            INNER JOIN "Fee_Master_Head" as b ON a."FMH_Id"=b."FMH_Id"
            INNER JOIN "Fee_Master_Amount" as c ON a."FMA_Id"=c."FMA_Id" 
            INNER JOIN "Fee_Master_Terms_FeeHeads" as d ON d."fmh_id"=a."fmh_id" AND d."fti_id"=a."fti_id"
            INNER JOIN "Fee_T_Installment" as e ON e."FTI_Id"=a."FTI_Id"
            WHERE a."amst_id"=' || quote_literal("p_amst_id") || ' 
                AND a."mi_id"=' || quote_literal("p_mi_id") || ' 
                AND a."asmay_id"=' || quote_literal("p_asmay_id") || ' 
                AND "fmt_id" IN (' || "p_fmt_id" || ') 
                AND a."fss_tobepaid">0 
            UNION ALL
            SELECT "FMH_FeeName","FTI_Name",a."FTI_Id",a."fmh_id",a."FSS_ToBePaid" as "FMA_Amount",a."FMA_Id",a."FMG_Id" 
            FROM "Fee_Student_Status" as a 
            INNER JOIN "Fee_Master_Head" as b ON a."FMH_Id"=b."FMH_Id"
            INNER JOIN "Fee_Master_Amount" as c ON a."FMA_Id"=c."FMA_Id" 
            INNER JOIN "Fee_Master_SpecialFeeHead_FeeHead" as d ON d."fmh_id"=a."fmh_id" 
            INNER JOIN "Fee_T_Installment" as e ON e."FTI_Id"=a."FTI_Id"
            WHERE a."amst_id"=' || quote_literal("p_amst_id") || ' 
                AND a."mi_id"=' || quote_literal("p_mi_id") || ' 
                AND a."asmay_id"=' || quote_literal("p_asmay_id") || ' 
                AND a."fss_tobepaid">0';

        END IF;

        FOR "rec" IN EXECUTE "v_sql1head1" LOOP
            "v_headname" := "rec"."FMH_FeeName";
            "v_installmentname" := "rec"."FTI_Name";
            "v_ftiid" := "rec"."fti_id";
            "v_fmhid" := "rec"."fmh_id";
            "v_ftptobepaidamt" := "rec"."FMA_Amount";
            "v_fmaid" := "rec"."FMA_Id";
            "v_fmgid" := "rec"."fmg_id";

            INSERT INTO "v_studentPendingconcession" 
                ("FMH_FeeName","FTI_Name","fti_id","fmh_id","FMA_Amount","fma_id","fmg_id","asmay_id","mi_id") 
            VALUES 
                ("v_headname","v_installmentname","v_ftiid","v_fmhid","v_ftptobepaidamt","v_fmaid","v_fmgid","p_asmay_id","p_mi_id");
        END LOOP;

    ELSE

        IF "p_configuration" = 'T' THEN
            "v_sql1head" := 'SELECT "FMH_FeeName","FTI_Name","fee_student_status"."fti_id","fee_student_status"."fmh_id","FSS_ToBePaid" as "FMA_Amount","FMA_Id","fee_student_status"."fmg_id" 
            FROM "fee_student_status" 
            INNER JOIN "fee_master_head" ON "fee_student_status"."fmh_id"="fee_master_head"."fmh_id"
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id"="fee_student_status"."fti_id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."fmh_id"="fee_student_status"."fmh_id" 
                AND "Fee_Master_Terms_FeeHeads"."fti_id"="fee_student_status"."fti_id"
            WHERE "fee_student_status"."amst_id"=' || quote_literal("p_amst_id") || ' 
                AND "fee_student_status"."mi_id"=' || quote_literal("p_mi_id") || ' 
                AND "fee_student_status"."asmay_id"=' || quote_literal("p_asmay_id") || ' 
                AND "fmt_id" IN (' || "p_fmt_id" || ') 
            ORDER BY "fmh_id"';
        ELSE
            "v_sql1head" := 'SELECT "FMH_FeeName","FTI_Name","fee_student_status"."fti_id","fee_student_status"."fmh_id","FSS_ToBePaid" as "FMA_Amount","FMA_Id","fee_student_status"."fmg_id" 
            FROM "fee_student_status" 
            INNER JOIN "fee_master_head" ON "fee_student_status"."fmh_id"="fee_master_head"."fmh_id"
            INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."fti_id"="fee_student_status"."fti_id"
            WHERE "fee_student_status"."amst_id"=' || quote_literal("p_amst_id") || ' 
                AND "fee_student_status"."mi_id"=' || quote_literal("p_mi_id") || ' 
                AND "fee_student_status"."asmay_id"=' || quote_literal("p_asmay_id") || ' 
                AND "fee_student_status"."FMG_Id" IN (' || "p_fmt_id" || ') 
            ORDER BY "fmh_id"';
        END IF;

        FOR "rec" IN EXECUTE "v_sql1head" LOOP
            "v_headname" := "rec"."FMH_FeeName";
            "v_installmentname" := "rec"."FTI_Name";
            "v_ftiid" := "rec"."fti_id";
            "v_fmhid" := "rec"."fmh_id";
            "v_ftptobepaidamt" := "rec"."FMA_Amount";
            "v_fmaid" := "rec"."FMA_Id";
            "v_fmgid" := "rec"."fmg_id";

            INSERT INTO "v_studentPendingconcession" 
                ("FMH_FeeName","FTI_Name","fti_id","fmh_id","FMA_Amount","fma_id","fmg_id","asmay_id","mi_id") 
            VALUES 
                ("v_headname","v_installmentname","v_ftiid","v_fmhid","v_ftptobepaidamt","v_fmaid","v_fmgid","p_asmay_id","p_mi_id");
        END LOOP;

    END IF;

    RETURN;

END;
$$;