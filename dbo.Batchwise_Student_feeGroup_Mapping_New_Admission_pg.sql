CREATE OR REPLACE FUNCTION "dbo"."Batchwise_Student_feeGroup_Mapping_New_Admission"(
    p_MI_Id TEXT,
    p_AMCST_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMSE_Id TEXT,
    p_FMGIds TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_DynamicSql1 TEXT;
    v_DynamicSql2 TEXT;
    v_AMCO_Id BIGINT;
    v_AMB_Id BIGINT;
    v_USER_Id BIGINT;
    v_FCMA_Id BIGINT;
    v_SAMSE_Id BIGINT;
    v_FCMAS_Amount DECIMAL(18,2);
    v_FMG_Id BIGINT;
    v_FMH_Id BIGINT;
    v_FTI_Id BIGINT;
    v_Rcount BIGINT;
    v_FCMSGH_Id BIGINT;
    v_FCMAS_Id BIGINT;
    v_CAMCST_Id BIGINT;
    v_JASMAY_Id BIGINT;
    v_FMG_BatchwiseFeeApplFlg BOOLEAN;
    v_ACQC_Id TEXT;
    v_GIRcount INTEGER;
    v_FCSSRcount INTEGER;
    v_SARcount INTEGER;
    v_FCSA_Amount DECIMAL(32,2);
    rec_feegroup RECORD;
    rec_student RECORD;
    rec_installment RECORD;
BEGIN
    v_FCMAS_Amount := 0;
    v_FMG_BatchwiseFeeApplFlg := FALSE;
    
    DROP TABLE IF EXISTS "Clg_Fee_GroupsUseridsNewAd_Temp";
    
    SELECT DISTINCT "ACQC_Id" INTO v_ACQC_Id 
    FROM "CLG"."Adm_Master_College_Student" 
    WHERE "AMCST_Id" = p_AMCST_Id::BIGINT AND "MI_Id" = p_MI_Id::BIGINT;
    
    v_DynamicSql1 := 'CREATE TEMP TABLE "Clg_Fee_GroupsUseridsNewAd_Temp" AS 
    SELECT DISTINCT QFG."FMG_Id", QFG."user_id"
    FROM "CLG"."Fee_College_Quota_FeeGroup" QFG
    INNER JOIN "Fee_Master_Group" FMG ON QFG."FMG_Id" = FMG."FMG_Id"
    WHERE QFG."MI_Id" = ' || p_MI_Id || ' AND QFG."ACQC_Id" = ' || v_ACQC_Id || '
    UNION
    SELECT DISTINCT FMG."FMG_Id", FMG."user_id"
    FROM "Fee_Master_Group" FMG 
    WHERE FMG."MI_Id" = ' || p_MI_Id || ' AND FMG."FMG_CompulsoryFlag" = ''N''';
    
    EXECUTE v_DynamicSql1;
    
    SELECT COUNT(*) INTO v_Rcount FROM "Clg_Fee_GroupsUseridsNewAd_Temp";
    
    IF (v_Rcount > 0) THEN
        FOR rec_feegroup IN 
            SELECT DISTINCT "FMG_Id", "user_id" FROM "Clg_Fee_GroupsUseridsNewAd_Temp"
        LOOP
            v_FMG_Id := rec_feegroup."FMG_Id";
            v_USER_Id := rec_feegroup."user_id";
            
            FOR rec_student IN 
                SELECT DISTINCT "AMCST_Id", "ASMAY_Id", "AMCO_Id", "AMB_Id" 
                FROM "CLG"."Adm_Master_College_Student" 
                WHERE "AMCST_Id" = p_AMCST_Id::BIGINT AND "MI_Id" = p_MI_Id::BIGINT
            LOOP
                v_CAMCST_Id := rec_student."AMCST_Id";
                v_JASMAY_Id := rec_student."ASMAY_Id";
                v_AMCO_Id := rec_student."AMCO_Id";
                v_AMB_Id := rec_student."AMB_Id";
                
                SELECT COUNT(*) INTO v_Rcount 
                FROM "CLG"."Fee_College_Master_Student_GroupHead" 
                WHERE "FMG_Id" = v_FMG_Id 
                    AND "MI_Id" = p_MI_Id::BIGINT 
                    AND "AMCST_Id" = v_CAMCST_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
                    AND "FCMSGH_ActiveFlag" = 1;
                
                IF v_Rcount = 0 THEN
                    INSERT INTO "CLG"."Fee_College_Master_Student_GroupHead" 
                        ("MI_Id", "AMCST_Id", "ASMAY_Id", "FMG_Id", "FCMSGH_ActiveFlag") 
                    VALUES 
                        (p_MI_Id::BIGINT, v_CAMCST_Id, p_ASMAY_Id::BIGINT, v_FMG_Id, 1);
                END IF;
                
                SELECT MAX("FCMSGH_Id") INTO v_FCMSGH_Id 
                FROM "CLG"."Fee_College_Master_Student_GroupHead" 
                WHERE "MI_Id" = p_MI_Id::BIGINT 
                    AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
                    AND "AMCST_Id" = v_CAMCST_Id 
                    AND "FMG_Id" = v_FMG_Id 
                    AND "FCMSGH_ActiveFlag" = 1;
                
                SELECT DISTINCT COALESCE("FMG_BatchwiseFeeApplFlg", FALSE) INTO v_FMG_BatchwiseFeeApplFlg 
                FROM "Fee_Master_Group" 
                WHERE "MI_Id" = p_MI_Id::BIGINT AND "FMG_Id" = v_FMG_Id;
                
                DROP TABLE IF EXISTS "Fee_CollegeSemesterWiseAmountNewAd_Temp";
                
                IF (v_FMG_BatchwiseFeeApplFlg = TRUE) THEN
                    CREATE TEMP TABLE "Fee_CollegeSemesterWiseAmountNewAd_Temp" AS
                    SELECT FA."FMH_Id", FA."FTI_Id", FS."FCMAS_Id", FS."FCMAS_Amount"
                    FROM "CLG"."Fee_College_Master_Amount" FA
                    INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" FS 
                        ON FA."FCMA_Id" = FS."FCMA_Id" 
                        AND FA."AMCO_Id" = v_AMCO_Id 
                        AND FA."AMB_Id" = v_AMB_Id 
                        AND FS."AMSE_Id" = p_AMSE_Id::BIGINT
                    WHERE FA."FMG_Id" = v_FMG_Id 
                        AND FA."ASMAY_Id" = v_JASMAY_Id 
                        AND FS."MI_Id" = p_MI_Id::BIGINT 
                        AND FA."MI_Id" = p_MI_Id::BIGINT;
                ELSE
                    CREATE TEMP TABLE "Fee_CollegeSemesterWiseAmountNewAd_Temp" AS
                    SELECT FA."FMH_Id", FA."FTI_Id", FS."FCMAS_Id", FS."FCMAS_Amount"
                    FROM "CLG"."Fee_College_Master_Amount" FA
                    INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" FS 
                        ON FA."FCMA_Id" = FS."FCMA_Id" 
                        AND FA."AMCO_Id" = v_AMCO_Id 
                        AND FA."AMB_Id" = v_AMB_Id 
                        AND FS."AMSE_Id" = p_AMSE_Id::BIGINT
                    WHERE FA."FMG_Id" = v_FMG_Id 
                        AND FA."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                        AND FS."MI_Id" = p_MI_Id::BIGINT 
                        AND FA."MI_Id" = p_MI_Id::BIGINT;
                END IF;
                
                FOR rec_installment IN 
                    SELECT "FMH_Id", "FTI_Id", "FCMAS_Id", "FCMAS_Amount" 
                    FROM "Fee_CollegeSemesterWiseAmountNewAd_Temp"
                LOOP
                    v_FMH_Id := rec_installment."FMH_Id";
                    v_FTI_Id := rec_installment."FTI_Id";
                    v_FCMAS_Id := rec_installment."FCMAS_Id";
                    v_FCMAS_Amount := rec_installment."FCMAS_Amount";
                    
                    v_SARcount := 0;
                    
                    SELECT COUNT(*) INTO v_SARcount 
                    FROM "CLG"."Fee_College_Studentwise_Amount" 
                    WHERE "MI_Id" = p_MI_Id::BIGINT 
                        AND "AMCO_Id" = v_AMCO_Id 
                        AND "AMB_Id" = v_AMB_Id 
                        AND "AMSE_Id" = p_AMSE_Id::BIGINT 
                        AND "FCMAS_Id" = v_FCMAS_Id 
                        AND "AMCST_Id" = p_AMCST_Id::BIGINT 
                        AND "FCSA_ActiveFlg" = 1;
                    
                    IF (v_SARcount <> 0) THEN
                        SELECT "FCSA_Amount" INTO v_FCSA_Amount 
                        FROM "CLG"."Fee_College_Studentwise_Amount" 
                        WHERE "MI_Id" = p_MI_Id::BIGINT 
                            AND "AMCO_Id" = v_AMCO_Id 
                            AND "AMB_Id" = v_AMB_Id 
                            AND "AMSE_Id" = p_AMSE_Id::BIGINT 
                            AND "FCMAS_Id" = v_FCMAS_Id 
                            AND "AMCST_Id" = p_AMCST_Id::BIGINT 
                            AND "FCSA_ActiveFlg" = 1;
                        v_FCMAS_Amount := v_FCSA_Amount;
                    END IF;
                    
                    v_GIRcount := 0;
                    
                    SELECT COUNT(*) INTO v_GIRcount 
                    FROM "CLG"."Fee_C_Master_Student_GroupHead_Installments" 
                    WHERE "FCMSGH_Id" = v_FCMSGH_Id 
                        AND "FMH_Id" = v_FMH_Id 
                        AND "FTI_Id" = v_FTI_Id;
                    
                    RAISE NOTICE '@@GIRcount: %', v_GIRcount;
                    
                    IF (v_GIRcount = 0) THEN
                        INSERT INTO "CLG"."Fee_C_Master_Student_GroupHead_Installments"
                            ("FCMSGH_Id", "FMH_ID", "FTI_ID") 
                        VALUES 
                            (v_FCMSGH_Id, v_FMH_Id, v_FTI_Id);
                    END IF;
                    
                    v_FCSSRcount := 0;
                    
                    SELECT COUNT(*) INTO v_FCSSRcount 
                    FROM "CLG"."Fee_College_Student_Status" 
                    WHERE "MI_Id" = p_MI_Id::BIGINT 
                        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
                        AND "AMCST_Id" = v_CAMCST_Id 
                        AND "FMG_Id" = v_FMG_Id 
                        AND "FMH_Id" = v_FMH_Id 
                        AND "FCMAS_Id" = v_FCMAS_Id 
                        AND "FCSS_CurrentYrCharges" = v_FCMAS_Amount 
                        AND "FCSS_NetAmount" = v_FCMAS_Amount;
                    
                    RAISE NOTICE '@FCSSRcount: %', v_FCSSRcount;
                    
                    IF (v_FCSSRcount = 0) THEN
                        INSERT INTO "CLG"."Fee_College_Student_Status"
                            ("MI_Id", "ASMAY_Id", "AMCST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FCMAS_Id", 
                             "FCSS_OBArrearAmount", "FCSS_OBExcessAmount", "FCSS_CurrentYrCharges", 
                             "FCSS_TotalCharges", "FCSS_ToBePaid", "FCSS_PaidAmount", "FCSS_ExcessPaidAmount", 
                             "FCSS_ExcessAmountAdjusted", "FCSS_RunningExcessAmount", "FCSS_ConcessionAmount", 
                             "FCSS_AdjustedAmount", "FCSS_WaivedAmount", "FCSS_RebateAmount", "FCSS_FineAmount", 
                             "FCSS_RefundAmount", "FCSS_RefundAmountAdjusted", "FCSS_NetAmount", 
                             "FCSS_ChequeBounceFlg", "FCSS_ArrearFlag", "FCSS_RefundOverFlag", 
                             "FCSS_ActiveFlag", "User_Id", "FCSS_RefundableAmount")
                        VALUES
                            (p_MI_Id::BIGINT, p_ASMAY_Id::BIGINT, v_CAMCST_Id, v_FMG_Id, v_FMH_Id, v_FTI_Id, v_FCMAS_Id, 
                             0, 0, v_FCMAS_Amount, v_FCMAS_Amount, v_FCMAS_Amount, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
                             v_FCMAS_Amount, 0, 0, 0, 1, v_USER_Id, 0);
                    END IF;
                END LOOP;
            END LOOP;
        END LOOP;
    ELSE
        RAISE NOTICE 'Group records not there for this quota category for new admission';
    END IF;
    
    RETURN;
END;
$$;