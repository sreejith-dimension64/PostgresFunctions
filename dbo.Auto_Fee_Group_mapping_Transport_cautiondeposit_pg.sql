CREATE OR REPLACE FUNCTION "dbo"."Auto_Fee_Group_mapping_Transport_cautiondeposit"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMST_Id bigint,
    p_UserId bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_FYGHM_Id bigint;
    v_FMCC_Id bigint;
    v_AMCL_Id bigint;
    v_AMCL_Id1 bigint;
    v_FMA_Id bigint;
    v_FTI_Name varchar(100);
    v_FMA_Amount numeric(16,2);
    v_FMH_Name varchar(100);
    v_FMG_Id bigint;
    v_FTP_Concession_Amt bigint;
    v_FMH_Id bigint;
    v_FTI_Id bigint;
    v_FMSG_Id bigint;
    v_selectflag varchar(50);
    v_STP int;
    v_STD int;
    v_STB int;
    v_SFS int;
    v_previous_yearid varchar;
    v_orderid varchar;
    v_orderid_previous varchar;
    v_previousclasorder varchar;
    v_currentorderid varchar;
    v_classorderid_previous varchar;
    rec_yearly_fee RECORD;
    rec_feeinstallment RECORD;
BEGIN
    v_AMCL_Id := 0;
    v_AMCL_Id1 := 0;
    v_FMCC_Id := 0;
    v_FMA_Id := 0;
    v_FTI_Name := '';
    v_FMA_Amount := 0;
    v_FMH_Name := '';
    v_FTP_Concession_Amt := 0;
    v_previous_yearid := '2';

    BEGIN
        FOR rec_yearly_fee IN 
            SELECT "FMG_Id" FROM "Fee_Master_Group" WHERE "mi_id"=4 AND "fmg_id"=7
        LOOP
            v_FMG_Id := rec_yearly_fee."FMG_Id";

            INSERT INTO "Fee_Master_Student_Group" ("MI_Id","AMST_Id","ASMAY_Id","FMG_Id","FMSG_ActiveFlag") 
            VALUES (p_MI_Id,p_AMST_Id,p_ASMAY_ID,v_FMG_Id,'Y');

            SELECT "FMSG_Id" INTO v_FMSG_Id FROM "Fee_Master_Student_Group" 
            WHERE "AMST_Id"=p_AMST_Id AND "ASMAY_Id"=p_ASMAY_Id;

            SELECT a."ASMCL_Id" INTO v_AMCL_Id1 
            FROM "Adm_School_Y_Student" a 
            INNER JOIN "Adm_M_Student" b ON a."AMST_Id"=b."AMST_Id" 
            WHERE a."AMST_Id"=p_AMST_Id AND a."ASMAY_Id"=v_previous_yearid::bigint;

            IF COALESCE(v_AMCL_Id1,0) != 0 THEN
                SELECT "ASMCL_Order" INTO v_previousclasorder 
                FROM "Adm_School_M_Class" 
                WHERE "MI_Id"=p_MI_Id AND "ASMCL_Id"=v_AMCL_Id1;

                v_currentorderid := (v_previousclasorder::int + 1)::varchar;

                SELECT "ASMCL_Id" INTO v_AMCL_Id1 
                FROM "Adm_School_M_Class" 
                WHERE "MI_Id"=p_MI_Id AND "ASMCL_Order"=v_currentorderid::int;

                v_amcl_id := v_AMCL_Id1;
            ELSE
                SELECT "ASMCL_Id" INTO v_amcl_id 
                FROM "adm_m_student" 
                WHERE "amst_id" = p_amst_id AND "MI_Id"=p_MI_Id AND "ASMAY_Id"=p_ASMAY_Id;
            END IF;

            SELECT "FMCC_Id" INTO v_fmcc_id 
            FROM "Fee_Yearly_Class_Category" 
            WHERE "ASMAY_Id"=p_ASMAY_ID AND "MI_Id"=p_MI_Id 
            AND "FYCC_Id" IN (
                SELECT "FYCC_Id" FROM "Fee_Yearly_Class_Category_Classes" WHERE "ASMCL_Id"=v_amcl_id
            );

            FOR rec_feeinstallment IN
                SELECT "FMH_Id","FTI_Id","FMA_Id","FMA_Amount" 
                FROM "Fee_Master_Amount" 
                WHERE "FMG_Id"=v_FMG_Id AND "ASMAY_Id"=p_ASMAY_ID AND "MI_Id"=p_MI_Id AND "FMCC_Id"=v_FMCC_Id
            LOOP
                v_FMH_Id := rec_feeinstallment."FMH_Id";
                v_FTI_Id := rec_feeinstallment."FTI_Id";
                v_FMA_Id := rec_feeinstallment."FMA_Id";
                v_FMA_Amount := rec_feeinstallment."FMA_Amount";

                INSERT INTO "Fee_Master_Student_Group_Installment" ("FMSG_Id","FMH_ID","FTI_ID") 
                VALUES (v_FMSG_Id,v_FMH_Id,v_FTI_Id);

                INSERT INTO "Fee_Student_Status"(
                    "MI_Id","ASMAY_Id","AMST_Id","FMG_Id","FMH_Id","FTI_Id","FMA_Id","FSS_OBArrearAmount","FSS_OBExcessAmount","FSS_CurrentYrCharges",
                    "FSS_TotalToBePaid","FSS_ToBePaid","FSS_PaidAmount","FSS_ExcessPaidAmount","FSS_ExcessAdjustedAmount","FSS_RunningExcessAmount",
                    "FSS_ConcessionAmount","FSS_AdjustedAmount","FSS_WaivedAmount","FSS_RebateAmount","FSS_FineAmount","FSS_RefundAmount",
                    "FSS_RefundAmountAdjusted","FSS_NetAmount","FSS_ChequeBounceFlag","FSS_ArrearFlag","FSS_RefundOverFlag","FSS_ActiveFlag",
                    "User_Id","FSS_RefundableAmount"
                )
                VALUES(
                    p_MI_Id,p_ASMAY_ID,p_AMST_Id,v_FMG_Id,v_FMH_Id,v_FTI_Id,v_FMA_Id,0,0,v_FMA_Amount,
                    v_FMA_Amount,v_FMA_Amount,0,0,0,0,0,0,0,0,0,0,0,v_FMA_Amount,0,0,0,1,p_UserId,0
                );
            END LOOP;
        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;

    RETURN;
END;
$$;