CREATE OR REPLACE FUNCTION "dbo"."Insert_Fee_Staff_Map_New"(
    "@fmg_id" bigint,
    "@hrme_id" bigint,
    "@MI_ID" bigint,
    "@fti_id_new" bigint,
    "@FMH_ID_new" bigint,
    "@userid" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "@fyghm_id" bigint;
    "@fmcc_id" bigint;
    "@amcl_id" bigint;
    "@fma_id" bigint;
    "@fti_name" varchar(100);
    "@fma_amount" numeric;
    "@fmh_name" varchar(100);
    "@asmay_id" bigint;
    "@fmg_id_new" bigint;
    "@fmstghid" bigint;
    "@ftp_concession_amt" bigint;
    "@fmh_id" bigint;
    "@fti_id" bigint;
    "@previousacademicyear" bigint;
    v_rowcount integer;
    v_temp_record RECORD;
BEGIN
    "@amcl_id" := 0;
    "@fmcc_id" := 0;
    "@fma_id" := 0;
    "@fti_name" := '';
    "@fma_amount" := 0;
    "@fmh_name" := '';
    "@asmay_id" := 0;
    "@ftp_concession_amt" := 0;

    SELECT "ASMAY_Id" INTO "@previousacademicyear" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE EXTRACT(YEAR FROM "ASMAY_From_Date") BETWEEN 
        (SELECT (EXTRACT(YEAR FROM "ASMAY_From_Date")-1) AS year 
         FROM "Adm_School_M_Academic_Year" 
         WHERE "ASMAY_From_Date" < CURRENT_TIMESTAMP 
         AND "ASMAY_To_Date" > CURRENT_TIMESTAMP 
         AND "MI_Id" = "@MI_ID") 
    AND 
        (SELECT (EXTRACT(YEAR FROM "ASMAY_From_Date")-1) AS year 
         FROM "Adm_School_M_Academic_Year" 
         WHERE "ASMAY_From_Date" < CURRENT_TIMESTAMP 
         AND "ASMAY_To_Date" > CURRENT_TIMESTAMP 
         AND "MI_Id" = "@MI_ID");

    RAISE NOTICE '%', "@previousacademicyear";

    SELECT "ASMAY_Id" INTO "@asmay_id" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_From_Date" < CURRENT_TIMESTAMP 
    AND "ASMAY_To_Date" > CURRENT_TIMESTAMP 
    AND "MI_Id" = "@MI_ID";
    
    RAISE NOTICE '%', "@asmay_id";

    PERFORM * 
    FROM "Fee_Master_Staff_GroupHead" 
    WHERE "ASMAY_Id" = "@asmay_id" 
    AND "FMG_Id" = "@fmg_id" 
    AND "MI_Id" = "@MI_ID" 
    AND "HRME_Id" = "@hrme_id";
    
    GET DIAGNOSTICS v_rowcount = ROW_COUNT;

    IF v_rowcount = 0 THEN
        RAISE NOTICE 'a';
        INSERT INTO "Fee_Master_Staff_GroupHead" ("MI_Id","HRME_Id","ASMAY_Id","FMG_Id","FMSTGH_ActiveFlag") 
        VALUES ("@mi_id","@hrme_id","@asmay_id","@fmg_id",'Y');
    END IF;

    BEGIN
        SELECT "FMSTGH_Id" INTO "@fmstghid" 
        FROM "Fee_Master_Staff_GroupHead" 
        WHERE "ASMAY_Id" = "@asmay_id" 
        AND "FMG_Id" = "@fmg_id" 
        AND "MI_Id" = "@MI_ID" 
        AND "HRME_Id" = "@hrme_id";
        
        RAISE NOTICE '%', "@fmstghid";
        RAISE NOTICE 'e';
        RAISE NOTICE '%; %; %', "@fmstghid", "@FMH_ID_new", "@fti_id_new";
        
        INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id","FMH_ID","FTI_ID") 
        VALUES ("@fmstghid","@FMH_ID_new","@fti_id_new");
        
        SELECT "FMSGI_Id" INTO "@fmstghid" 
        FROM "Fee_Master_Student_Group_Installment" 
        WHERE "FMSG_Id" = "@fmstghid";
        
        RAISE NOTICE '%', "@fmstghid";
        RAISE NOTICE 'd';

        FOR v_temp_record IN 
            SELECT "FYGHM_Id", "FMG_Id", "FMH_Id" 
            FROM "Fee_Yearly_Group_Head_Mapping" 
            WHERE "FMG_Id" = "@fmg_id" 
            AND "FYGHM_ActiveFlag" = 1 
            AND "ASMAY_Id" = "@asmay_id" 
            AND "FMH_Id" = "@FMH_ID_new" 
            AND "FMI_Id" IN (SELECT "FMI_Id" FROM "Fee_T_Installment" WHERE "FTI_Id" = "@fti_id_new")
        LOOP
            "@fyghm_id" := v_temp_record."FYGHM_Id";
            "@fmg_id_new" := v_temp_record."FMG_Id";
            "@fmh_id" := v_temp_record."FMH_Id";
            
            RAISE NOTICE 'b';
            RAISE NOTICE 'c';
            
            SELECT "HRMD_Id" INTO "@amcl_id" 
            FROM "HR_Master_Employee" 
            WHERE "HRME_Id" = "@hrme_id";
            
            RAISE NOTICE '%', "@amcl_id";
            
            IF "@amcl_id" > 0 THEN
                SELECT "FMCC_Id" INTO "@fmcc_id" 
                FROM "Fee_Yearly_Class_Category" 
                WHERE "ASMAY_Id" = "@ASMAY_ID" 
                AND "MI_Id" = "@mi_id" 
                AND "FYCC_Id" IN (SELECT "FYCC_Id" FROM "Fee_Yearly_Class_Category_Classes" WHERE "ASMCL_Id" = "@amcl_id");
                
                RAISE NOTICE '%', "@fmcc_id";
                
                IF "@fmcc_id" > 0 THEN
                    FOR v_temp_record IN 
                        SELECT "Fee_Master_Amount"."fma_id", "Fee_Master_Amount"."fti_id", "fee_t_installment"."fti_name", "Fee_Master_Amount"."fma_amount" 
                        FROM "Fee_Master_Amount" 
                        INNER JOIN "fee_t_installment" ON "Fee_Master_Amount"."fti_id" = "fee_t_installment"."fti_id" 
                        WHERE "FMCC_Id" = "@fmcc_id" 
                        AND "FMG_Id" = "@fmg_id_new" 
                        AND "FMH_Id" = "@FMH_ID_new" 
                        AND "Fee_Master_Amount"."FTI_Id" = "@fti_id_new"
                    LOOP
                        "@fma_id" := v_temp_record."fma_id";
                        "@fti_id" := v_temp_record."fti_id";
                        "@fti_name" := v_temp_record."fti_name";
                        "@fma_amount" := v_temp_record."fma_amount";
                        
                        SELECT "FMH_FeeName" INTO "@fmh_name" 
                        FROM "Fee_Master_Head" 
                        WHERE "fmh_id" = "@FMH_ID_new";
                        
                        PERFORM * 
                        FROM "Fee_Staff_Status" 
                        WHERE "HRME_Id" = "@hrme_id" 
                        AND "fmg_id" = "@fmg_id_new" 
                        AND "fmh_id" = "@FMH_ID_new" 
                        AND "fma_id" = "@fma_id";
                        
                        SELECT "FSCI_ConcessionAmount" INTO "@ftp_concession_amt" 
                        FROM "Fee_Student_Concession" 
                        INNER JOIN "Fee_Student_Concession_Installments" ON "Fee_Student_Concession"."FSC_Id" = "Fee_Student_Concession_Installments"."FSCI_FSC_Id" 
                        WHERE "AMST_Id" = "@hrme_id" 
                        AND "FMH_Id" = "@FMH_ID_new" 
                        AND "FTI_Id" = "@fti_id_new" 
                        AND "FMG_Id" = "@fmg_id" 
                        AND "MI_Id" = "@MI_ID";
                        
                        GET DIAGNOSTICS v_rowcount = ROW_COUNT;
                        RAISE NOTICE '%', "@ftp_concession_amt";
                        
                        IF v_rowcount = 0 THEN
                            RAISE NOTICE 'b';
                            PERFORM * 
                            FROM "Fee_Staff_Status" 
                            WHERE "HRME_Id" = "@hrme_id" 
                            AND "fmg_id" = "@fmg_id_new" 
                            AND "fmh_id" = "@FMH_ID_new" 
                            AND "fma_id" = "@fma_id";
                            
                            INSERT INTO "Fee_Staff_Status"("MI_Id","ASMAY_Id","HRME_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id","FSTS_OBArrearAmount","FSTS_OBExcessAmount","FSTS_CurrentYrCharges","FSTS_TotalToBePaid","FSTS_ToBePaid","FSTS_PaidAmount","FSTS_ExcessPaidAmount","FSTS_ExcessAdjustedAmount","FSTS_RunningExcessAmount","FSTS_ConcessionAmount","FSTS_AdjustedAmount","FSTS_WaivedAmount","FSTS_RebateAmount","FSTS_FineAmount","FSTS_RefundAmount","FSTS_RefundAmountAdjusted","FSTS_NetAmount","FSTS_ChequeBounceFlag","FSTS_ArrearFlag","FSTS_RefundOverFlag","FSTS_ActiveFlag","User_Id") 
                            VALUES("@MI_ID","@asmay_id","@hrme_id","@fmg_id","@FMH_ID_new","@fti_id_new","@fma_id",0,0,"@fma_amount","@fma_amount","@fma_amount",0,0,0,0,"@ftp_concession_amt",0,0,0,0,0,0,"@fma_amount",0,0,0,1,"@userid");
                            
                            PERFORM "UpdateStudPaidAmt"("@hrme_id","@fma_id","@MI_ID");
                        ELSE
                            PERFORM "UpdateStudPaidAmt"("@hrme_id","@fma_id","@MI_ID");
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