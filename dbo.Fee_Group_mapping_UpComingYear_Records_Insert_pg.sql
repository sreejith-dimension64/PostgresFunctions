CREATE OR REPLACE FUNCTION "dbo"."Fee_Group_mapping_UpComingYear_Records_Insert"(p_MI_Id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE 
    v_FYGHM_Id bigint;   
    v_FMCC_Id bigint;   
    v_AMCL_Id bigint;   
    v_FMA_Id bigint;   
    v_FTI_Name varchar(100);   
    v_FMA_Amount numeric(16,2);   
    v_FMH_Name varchar(100);   
    v_FMG_Id bigint;   
    v_FTP_Concession_Amt bigint;  
    v_FMH_Id bigint;  
    v_FTI_Id bigint;  
    v_FMSG_Id bigint;  
    v_compulflag varchar(100);  
    v_classid varchar(100); 
    v_AMST_Id bigint;
    v_ASMAY_Id_N bigint;
    v_Rcount bigint;
    v_UserId bigint;
    v_ASMCL_Id_N bigint;
    v_ASMCL_Order bigint;
    v_FssRcount bigint;
    v_GIRcount bigint;
    v_ASMAY_Id bigint;
    rec_student RECORD;
    rec_feeinstallment RECORD;
BEGIN  
  
    v_AMCL_Id := 0;   
    v_FMCC_Id := 0;   
    v_FMA_Id := 0;   
    v_FTI_Name := '';   
    v_FMA_Amount := 0;   
    v_FMH_Name := '';   
    v_FTP_Concession_Amt := 0;  
    v_compulflag := '1';  

    /* 

    SELECT "FMG_Id" INTO v_FMG_Id FROM "Fee_Master_Group" WHERE "MI_Id" = p_MI_Id AND "FMG_Id" = 16;
    SELECT "ASMAY_Id" INTO v_ASMAY_Id_N FROM "Adm_School_M_Academic_Year" WHERE "MI_Id" = p_MI_Id AND "ASMAY_Year" = '2022-2023';
    SELECT "ASMAY_Id" INTO v_ASMAY_Id FROM "Adm_School_M_Academic_Year" WHERE "MI_Id" = p_MI_Id AND "ASMAY_Year" = '2021-2022';
   
    FOR rec_student IN
        SELECT DISTINCT "AMST_Id" 
        FROM "Fee_Master_Student_Group" 
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = v_ASMAY_Id
            AND "AMST_Id" IN (
                SELECT "AMST_Id" 
                FROM "Adm_School_Y_Student" 
                WHERE "ASMAY_Id" = v_ASMAY_Id 
                    AND "ASMCL_Id" IN (5) 
                    AND "AMAY_ActiveFlag" = 1
            ) 
            AND "AMST_Id" NOT IN (3625)
    LOOP    
        v_AMST_Id := rec_student."AMST_Id";
  
        v_Rcount := 0;
        SELECT COUNT(*) INTO v_Rcount 
        FROM "Fee_Master_Student_Group" 
        WHERE "FMG_Id" = v_FMG_Id 
            AND "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = v_ASMAY_Id_N 
            AND "AMST_Id" = v_AMST_Id;
  
        IF v_Rcount = 0 THEN  
            v_ASMCL_Order := 0;
            v_ASMCL_Id_N := 0;
            v_AMCL_Id := 0;
            v_FMCC_Id := 0;

            SELECT "user_id" INTO v_UserId 
            FROM "Fee_Master_Group" 
            WHERE "FMG_Id" = v_FMG_Id 
                AND "MI_Id" = p_MI_Id;
  
            INSERT INTO "Fee_Master_Student_Group" ("MI_Id", "AMST_Id", "ASMAY_Id", "FMG_Id", "FMSG_ActiveFlag") 
            VALUES (p_MI_Id, v_AMST_Id, v_ASMAY_Id_N, v_FMG_Id, 'Y');  
        END IF;
  
        SELECT MAX("FMSG_Id") INTO v_FMSG_Id 
        FROM "Fee_Master_Student_Group" 
        WHERE "AMST_Id" = v_AMST_Id 
            AND "ASMAY_Id" = v_ASMAY_Id_N 
            AND "FMG_Id" = v_FMG_Id;
  
        SELECT "ASMCL_Id" INTO v_AMCL_Id 
        FROM "Adm_School_Y_Student" 
        WHERE "AMST_Id" = v_AMST_Id 
            AND "ASMAY_Id" = v_ASMAY_Id;

        SELECT "ASMCL_Order" INTO v_ASMCL_Order 
        FROM "Adm_School_M_Class" 
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMCL_Id" = v_AMCL_Id;
            
        SELECT "ASMCL_Id" INTO v_ASMCL_Id_N 
        FROM "Adm_School_M_Class" 
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMCL_Order" = v_ASMCL_Order + 1;
  
        SELECT "FMCC_Id" INTO v_FMCC_Id 
        FROM "Fee_Yearly_Class_Category" 
        WHERE "ASMAY_Id" = v_ASMAY_Id_N 
            AND "MI_Id" = p_MI_Id 
            AND "FYCC_Id" IN (
                SELECT "FYCC_Id" 
                FROM "Fee_Yearly_Class_Category_Classes" 
                WHERE "ASMCL_Id" = v_ASMCL_Id_N
            );

        FOR rec_feeinstallment IN  
            SELECT DISTINCT "FMH_Id", "FTI_Id", "FMA_Id", "FMA_Amount" 
            FROM "Fee_Master_Amount" 
            WHERE "FMG_Id" = v_FMG_Id 
                AND "ASMAY_Id" = v_ASMAY_Id_N 
                AND "MI_Id" = p_MI_Id 
                AND "FMCC_Id" = v_FMCC_Id 
                AND "FMH_Id" IN (29, 30)
        LOOP  
            v_FMH_Id := rec_feeinstallment."FMH_Id";
            v_FTI_Id := rec_feeinstallment."FTI_Id";
            v_FMA_Id := rec_feeinstallment."FMA_Id";
            v_FMA_Amount := rec_feeinstallment."FMA_Amount";
  
            v_GIRcount := 0;
            SELECT COUNT(*) INTO v_GIRcount 
            FROM "Fee_Master_Student_Group_Installment" 
            WHERE "FMSG_Id" = v_FMSG_Id 
                AND "FMH_ID" = v_FMH_Id 
                AND "FTI_ID" = v_FTI_Id;

            IF v_GIRcount = 0 THEN
                INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id", "FMH_ID", "FTI_ID") 
                VALUES (v_FMSG_Id, v_FMH_Id, v_FTI_Id);
            END IF;

            v_FssRcount := 0;
            SELECT COUNT(*) INTO v_FssRcount 
            FROM "Fee_Student_Status" 
            WHERE "MI_Id" = p_MI_Id 
                AND "ASMAY_Id" = v_ASMAY_Id_N 
                AND "AMST_Id" = v_AMST_Id 
                AND "FMG_Id" = v_FMG_Id 
                AND "FMH_Id" = v_FMH_Id 
                AND "FTI_Id" = v_FTI_Id 
                AND "FSS_CurrentYrCharges" = v_FMA_Amount;

            IF v_FssRcount = 0 THEN
                INSERT INTO "Fee_Student_Status"("MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id", "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges", "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount", "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount", "FSS_RunningExcessAmount", "FSS_ConcessionAmount", "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount", "FSS_FineAmount", "FSS_RefundAmount", "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag", "FSS_ArrearFlag", "FSS_RefundOverFlag", "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount", "FSS_ExcessTransferred", "FSS_OBTransferred") 
                VALUES(p_MI_Id, v_ASMAY_Id_N, v_AMST_Id, v_FMG_Id, v_FMH_Id, v_FTI_Id, v_FMA_Id, 0, 0, v_FMA_Amount, v_FMA_Amount, v_FMA_Amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, v_FMA_Amount, 0, 0, 0, 1, v_UserId, 0, 0, 0);
            END IF;
        END LOOP;
    END LOOP;

    */

    RETURN;
END;
$$;