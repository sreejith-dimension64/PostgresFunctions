CREATE OR REPLACE FUNCTION "dbo"."Auto_Fee_Group_mapping_Transport_Collage"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCST_Id bigint,
    p_UserId bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$

DECLARE
    v_FYGHM_Id bigint;
    v_AMSE_Id bigint;
    v_AMSE_Id1 bigint;
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
    v_FCMAS_Id bigint;
    v_previous_yearid varchar(max);
    v_orderid varchar(max);
    v_orderid_previous varchar(max);
    v_previoussemasorder varchar(max);
    v_currentorderid varchar(max);
    v_classorderid_previous varchar(max);
    v_rec RECORD;

BEGIN

    v_AMSE_Id := 0;
    v_AMSE_Id1 := 0;
    v_FMA_Id := 0;
    v_FTI_Name := '';
    v_FMA_Amount := 0;
    v_FMH_Name := '';
    v_FTP_Concession_Amt := 0;

    BEGIN
   
        SELECT "ASMAY_Order" INTO v_orderid 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = p_ASMAY_Id;
        
        v_orderid_previous := v_orderid::int - 1;

        SELECT "ASMAY_Id" INTO v_previous_yearid 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Order" = v_orderid_previous::int;

        SELECT COUNT(*) INTO v_STB 
        FROM "Adm_Student_Trans_Appl_College" 
        WHERE "AMCST_Id" = p_AMCST_Id 
            AND ("ASTACO_Drop_TRMR_Id" != 0 OR "ASTACO_Drop_TRML_Id" != 0) 
            AND ("ASTACO_PickUp_TRMR_Id" != 0 OR "ASTACO_PickUp_TRML_Id" != 0) 
            AND "MI_Id" = p_MI_Id;

        IF v_STB > 0 THEN
            v_selectflag := 'B';
        ELSIF v_STB = 0 THEN
            v_selectflag := 'P';
        END IF;

        SELECT COUNT(*) INTO v_SFS 
        FROM "CLG"."Fee_College_Student_Status" 
        WHERE "AMCST_Id" = p_AMCST_Id  
            AND "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = v_previous_yearid::bigint
            AND "fmg_id" IN (
                SELECT "fmg_id" 
                FROM "TRN"."TR_FeeGroupMapping" 
                WHERE "TRFGM_PickUpDropFlag" = v_selectflag
            ) 
            AND "FCSS_CurrentYrCharges" > 0;

        IF v_SFS = 0 OR v_SFS IS NULL THEN
            DROP TABLE IF EXISTS "TempGroup";

            CREATE TEMP TABLE "TempGroup" AS
            SELECT DISTINCT "fee_master_group"."fmg_id" 
            FROM "fee_master_group" 
            INNER JOIN "Fee_Yearly_Group_Head_Mapping" ON "Fee_Yearly_Group_Head_Mapping"."fmg_id" = "fee_master_group"."fmg_id"
            INNER JOIN "fee_master_head" ON "fee_master_head"."fmh_id" = "Fee_Yearly_Group_Head_Mapping"."fmh_id" 
            WHERE "Fee_Yearly_Group_Head_Mapping"."mi_id" = p_MI_Id 
                AND "asmay_id" = p_ASMAY_Id 
                AND "fmh_flag" = 'T' 
                AND "FMG_CompulsoryFlag" = 'N';
        ELSE
            DELETE FROM "TempGroup";
        END IF;

        FOR v_rec IN (
            SELECT "FMG_Id" FROM "TempGroup"
            UNION 
            SELECT "FMG_Id" FROM "TRN"."TR_FeeGroupMapping" WHERE "TRFGM_PickUpDropFlag" = v_selectflag
        )
        LOOP
            v_FMG_Id := v_rec."FMG_Id";

            INSERT INTO "CLG"."Fee_College_Master_Student_GroupHead" 
                ("MI_Id", "AMCST_Id", "ASMAY_Id", "FMG_Id", "FCMSGH_ActiveFlag") 
            VALUES 
                (p_MI_Id, p_AMCST_Id, p_ASMAY_ID, v_FMG_Id, 'Y');

            SELECT "FCMSGH_Id" INTO v_FMSG_Id 
            FROM "CLG"."Fee_College_Master_Student_GroupHead"  
            WHERE "AMCST_Id" = p_AMCST_Id AND "ASMAY_Id" = p_ASMAY_Id;

            SELECT a."AMSE_Id" INTO v_AMSE_Id1 
            FROM "CLG"."Adm_College_Yearly_Student" a 
            INNER JOIN "CLG"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id" 
            WHERE a."AMCST_Id" = p_AMCST_Id AND a."ASMAY_Id" = v_previous_yearid::bigint;

            IF v_AMSE_Id1 IS NOT NULL AND v_AMSE_Id1 != 0 THEN

                SELECT "AMSE_SEMOrder" INTO v_previoussemasorder 
                FROM "CLG"."Adm_Master_Semester" 
                WHERE "MI_Id" = p_MI_Id AND "AMSE_Id" = v_AMSE_Id1;
                
                v_currentorderid := v_previoussemasorder::int + 1;
                
                SELECT "AMSE_Id" INTO v_AMSE_Id1 
                FROM "CLG"."Adm_Master_Semester" 
                WHERE "MI_Id" = p_MI_Id AND "AMSE_SEMOrder" = v_currentorderid::int;
                
                v_amse_id := v_AMSE_Id1;

            ELSE
                SELECT "AMSE_Id" INTO v_AMSE_Id 
                FROM "CLG"."Adm_Master_College_Student" 
                WHERE "AMCST_Id" = p_AMCST_Id 
                    AND "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id;
            END IF;

            SELECT "FCMAS_Id" INTO v_FCMAS_Id 
            FROM "CLG"."Fee_College_Master_Amount_Semesterwise" 
            WHERE "AMSE_Id" = v_AMSE_Id 
                AND "MI_Id" = p_MI_Id 
                AND "FCMA_Id" IN (
                    SELECT "FCMA_Id"  
                    FROM "CLG"."Fee_College_Master_Amount"  
                    WHERE "ASMAY_Id" = p_ASMAY_ID AND "MI_Id" = p_MI_Id
                );

            FOR v_rec IN (
                SELECT "FMH_Id", "AMSE_Id", FAS."FCMA_Id", "FCMAS_Amount" 
                FROM "CLG"."Fee_College_Master_Amount_Semesterwise" FAS
                INNER JOIN "CLG"."Fee_College_Master_Amount" FA ON FA."FCMA_Id" = FAS."FCMA_Id"   
                WHERE FAS."MI_Id" = p_MI_Id AND FAS."FCMAS_Id" = v_FCMAS_Id
            )
            LOOP
                v_FMH_Id := v_rec."FMH_Id";
                v_FTI_Id := v_rec."AMSE_Id";
                v_FMA_Id := v_rec."FCMA_Id";
                v_FMA_Amount := v_rec."FCMAS_Amount";

                INSERT INTO "Fee_Master_Student_Group_Installment" 
                    ("FMSG_Id", "FMH_ID", "FTI_ID") 
                VALUES 
                    (v_FMSG_Id, v_FMH_Id, v_FTI_Id);

                INSERT INTO "CLG"."Fee_College_Student_Status"(
                    "MI_Id", "ASMAY_Id", "AMCST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FCMAS_Id", 
                    "FCSS_OBArrearAmount", "FCSS_OBExcessAmount", "FCSS_CurrentYrCharges", "FCSS_ToBePaid", 
                    "FCSS_PaidAmount", "FCSS_ExcessPaidAmount", "FCSS_ExcessAmountAdjusted",
                    "FCSS_RunningExcessAmount", "FCSS_ConcessionAmount", "FCSS_AdjustedAmount", "FCSS_WaivedAmount", 
                    "FCSS_RebateAmount", "FCSS_FineAmount", "FCSS_RefundAmount", "FCSS_RefundAmountAdjusted", 
                    "FCSS_NetAmount", "FCSS_ChequeBounceFlg", "FCSS_ArrearFlag", "FCSS_RefundOverFlag", 
                    "FCSS_ActiveFlag", "User_Id", "FCSS_RefundableAmount")
                VALUES(
                    p_MI_Id, p_ASMAY_ID, p_AMCST_Id, v_FMG_Id, v_FMH_Id, v_FTI_Id, v_FMA_Id, 
                    0, 0, v_FMA_Amount, v_FMA_Amount, v_FMA_Amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                    v_FMA_Amount, 0, 0, 0, 1, p_UserId, 0);

            END LOOP;

        END LOOP;

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;

END;
$$;