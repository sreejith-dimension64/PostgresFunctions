CREATE OR REPLACE FUNCTION "dbo"."Auto_Fee_Group_mapping_Date_of_admission"(
    "@mi_id" bigint,
    "@ASMAY_ID" bigint,
    "@AmST_ID" bigint,
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
    "@fmg_id" bigint;
    "@fmsgid" bigint;
    "@ftp_concession_amt" bigint;
    "@fmh_id" bigint;
    "@fti_id" bigint;
    "@FMSG_Id" bigint;
    "v_rowcount" integer;
    "rec_feeinstallment" record;
BEGIN
    "@amcl_id" := 0;
    "@fmcc_id" := 0;
    "@fma_id" := 0;
    "@fti_name" := '';
    "@fma_amount" := 0;
    "@fmh_name" := '';
    "@ftp_concession_amt" := 0;

    FOR "@fmg_id" IN (
        SELECT "FMG_Id" 
        FROM "Fee_Master_Group" 
        WHERE "FMG_CompulsoryFlag" IN ('N','R') 
        AND "MI_Id" = "@mi_id"
        
        UNION ALL
        
        SELECT "FMG_Id" 
        FROM "trn"."TR_Location_FeeGroup_Mapping" 
        INNER JOIN "PA_Student_Transport_Application" 
            ON "PA_Student_Transport_Application"."PASTA_PickUp_TRML_Id" = "trn"."TR_Location_FeeGroup_Mapping"."TRML_Id"
        WHERE "PASR_Id" IN (
            SELECT "PASR_Id" 
            FROM "Adm_Master_Student_PA" 
            WHERE "AMST_Id" = "@AmST_ID"
        ) 
        AND "trn"."TR_Location_FeeGroup_Mapping"."MI_Id" = "@mi_id"
    )
    LOOP
        SELECT * 
        FROM "Fee_Master_Student_Group" 
        WHERE "FMG_Id" = "@fmg_id" 
        AND "MI_Id" = "@mi_id" 
        AND "amst_id" = "@AmST_ID" 
        AND "ASMAY_Id" = "@ASMAY_ID"
        LIMIT 1;
        
        GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;
        
        IF "v_rowcount" = 0 THEN
            INSERT INTO "Fee_Master_Student_Group" (
                "MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag"
            ) 
            VALUES (
                "@mi_id", "@AmST_ID", "@ASMAY_ID", "@fmg_id", 'Y'
            );
            
            SELECT MAX("FMSG_Id") INTO "@FMSG_Id" 
            FROM "Fee_Master_Student_Group";
            
            SELECT "ASMCL_Id" INTO "@amcl_id" 
            FROM "Adm_M_Student" 
            WHERE "amst_id" = "@amst_id" 
            AND "ASMAY_Id" = "@asmay_id";
            
            SELECT "FMCC_Id" INTO "@fmcc_id" 
            FROM "Fee_Yearly_Class_Category" 
            WHERE "ASMAY_Id" = "@ASMAY_ID" 
            AND "MI_Id" = "@mi_id" 
            AND "FYCC_Id" IN (
                SELECT "FYCC_Id" 
                FROM "Fee_Yearly_Class_Category_Classes" 
                WHERE "ASMCL_Id" = "@amcl_id"
            );
            
            FOR "rec_feeinstallment" IN (
                SELECT "FMH_Id", "FTI_Id", "FMA_Id", "FMA_Amount" 
                FROM "Fee_Master_Amount" 
                WHERE "FMG_Id" = "@fmg_id" 
                AND "ASMAY_Id" = "@ASMAY_ID" 
                AND "MI_Id" = "@mi_id" 
                AND "FMCC_Id" = "@fmcc_id"
            )
            LOOP
                "@fmh_id" := "rec_feeinstallment"."FMH_Id";
                "@fti_id" := "rec_feeinstallment"."FTI_Id";
                "@fma_id" := "rec_feeinstallment"."FMA_Id";
                "@fma_amount" := "rec_feeinstallment"."FMA_Amount";
                
                INSERT INTO "Fee_Master_Student_Group_Installment" (
                    "FMSG_Id", "FMH_ID", "FTI_ID"
                ) 
                VALUES (
                    "@FMSG_Id", "@fmh_id", "@fti_id"
                );
                
                INSERT INTO "Fee_Student_Status" (
                    "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id",
                    "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges",
                    "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount",
                    "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount",
                    "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount",
                    "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount",
                    "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag",
                    "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount"
                ) 
                VALUES (
                    "@mi_id", "@ASMAY_ID", "@AmST_ID", "@fmg_id", "@fmh_id", "@fti_id", "@fma_id",
                    0, 0, "@fma_amount", "@fma_amount", "@fma_amount", 0, 0, 0, 0, 0, 0, 0, 0, 0,
                    0, 0, "@fma_amount", 0, 0, 0, 1, "@userid", 0
                );
            END LOOP;
        END IF;
    END LOOP;
    
    RETURN;
END;
$$;