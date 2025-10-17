CREATE OR REPLACE FUNCTION "dbo"."Get_Student_Status_AdvanceDetailsApproval"(
    "p_MI_Id" VARCHAR(10),
    "p_ASMAY_Id" VARCHAR(10),
    "p_AMCST_Id" VARCHAR(10),
    "p_FMG_Id" VARCHAR(100)
)
RETURNS TABLE(
    "FMG_Id" BIGINT,
    "FCMAS_Id" BIGINT,
    "FMH_Id" BIGINT,
    "FTI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "FCSS_ToBePaid" NUMERIC,
    "FCSS_PaidAmount" NUMERIC,
    "FCSS_ConcessionAmount" NUMERIC,
    "FCSS_NetAmount" NUMERIC,
    "FCSS_FineAmount" NUMERIC,
    "FCSS_RefundAmount" NUMERIC,
    "FMH_FeeName" TEXT,
    "FTI_Name" TEXT,
    "FMG_GroupName" TEXT,
    "FCSS_CurrentYrCharges" NUMERIC,
    "FCSS_TotalCharges" NUMERIC,
    "FCSS_OBArrearAmount" NUMERIC,
    "FCSS_WaivedAmount" NUMERIC,
    "FMH_Order" INTEGER,
    "FMH_Flag" TEXT,
    "FCMAS_DueDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_query" TEXT;
    "v_AMCO_Id" VARCHAR(50);
    "v_AMB_Id" VARCHAR(50);
    "v_AMSE_Id" VARCHAR(20);
    "v_AMSE_Id_N" VARCHAR(20);
    "v_FTCP_PaidAmount" VARCHAR(100);
    "v_Rcount" INTEGER;
    "v_FMG_BatchwiseFeeApplFlg" BOOLEAN;
    "v_ASMAY_Id_J" BIGINT;
    "v_SqlFeegroupDynamic" TEXT;
    "v_ASMAY_Id" VARCHAR(10);
BEGIN
    "v_ASMAY_Id" := "p_ASMAY_Id";
    
    SELECT DISTINCT "AMCO_Id", "AMB_Id", "AMSE_Id" 
    INTO "v_AMCO_Id", "v_AMB_Id", "v_AMSE_Id"
    FROM "clg"."Adm_College_Yearly_Student" 
    WHERE "AMCST_Id" = "p_AMCST_Id"::BIGINT;
    
    SELECT "AMSE_Id" 
    INTO "v_AMSE_Id_N"
    FROM "clg"."Adm_Master_Semester" 
    WHERE "MI_Id" = "p_MI_Id"::BIGINT 
        AND "AMSE_SemOrder" = (
            SELECT "AMSE_SemOrder" + 1 
            FROM "clg"."Adm_Master_Semester" 
            WHERE "MI_Id" = "p_MI_Id"::BIGINT 
                AND "AMSE_Id" = "v_AMSE_Id"::BIGINT
        );

    DROP TABLE IF EXISTS "FeeBatchWise_Temp";

    "v_SqlFeegroupDynamic" := '   
    SELECT DISTINCT COALESCE("FMG_BatchwiseFeeApplFlg", false) AS "FMG_BatchwiseFeeApplFlg"
    FROM "Fee_Master_Group" "FMG"
    INNER JOIN "Fee_Yearly_Group" "FYG" ON "FMG"."FMG_Id" = "FYG"."FMG_Id"
    WHERE "FYG"."ASMAY_Id" = ' || "v_ASMAY_Id" || ' 
        AND "FMG"."MI_Id" = ' || "p_MI_Id" || ' 
        AND "FMG"."FMG_Id" IN (' || "p_FMG_Id" || ')';

    EXECUTE 'CREATE TEMP TABLE "FeeBatchWise_Temp" AS ' || "v_SqlFeegroupDynamic";

    SELECT "FMG_BatchwiseFeeApplFlg" 
    INTO "v_FMG_BatchwiseFeeApplFlg"
    FROM "FeeBatchWise_Temp" 
    LIMIT 1;

    IF ("v_FMG_BatchwiseFeeApplFlg" = true) THEN
        SELECT "ASMAY_Id" 
        INTO "v_ASMAY_Id_J"
        FROM "CLG"."Adm_Master_College_Student" 
        WHERE "MI_Id" = "p_MI_Id"::BIGINT 
            AND "AMCST_SOL" = 'S' 
            AND "AMCST_ActiveFlag" = 1 
            AND "AMCST_Id" = "p_AMCST_Id"::BIGINT;
        
        "v_ASMAY_Id" := "v_ASMAY_Id_J"::VARCHAR;
    END IF;

    "v_FTCP_PaidAmount" := '0';

    DROP TABLE IF EXISTS "Clg_StudentAdvancePaiddetails_temp";

    EXECUTE '
    CREATE TEMP TABLE "Clg_StudentAdvancePaiddetails_temp" AS
    SELECT "MA"."FMG_Id", "ASE"."FCMAS_Id", "MA"."FMH_Id", "MA"."FTI_Id", "MA"."ASMAY_Id", 
        COALESCE(SUM("FTCP_PaidAmount"), 0) AS "FTCP_PaidAmount"
    FROM "CLG"."Fee_T_College_Payment" "TP"
    INNER JOIN "CLG"."Fee_Y_Payment_College_Student" "CS" ON "TP"."FYP_Id" = "CS"."FYP_Id"
    INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" "ASE" ON "ASE"."FCMAS_Id" = "TP"."FCMAS_Id"
    INNER JOIN "CLG"."Fee_College_Master_Amount" "MA" ON "MA"."FCMA_Id" = "ASE"."FCMA_Id"
    WHERE "CS"."AMCST_Id" = ' || "p_AMCST_Id" || ' 
        AND "ASE"."AMSE_Id" = ' || "v_AMSE_Id_N" || '
    GROUP BY "MA"."FMG_Id", "ASE"."FCMAS_Id", "MA"."FMH_Id", "MA"."FTI_Id", "MA"."ASMAY_Id"';

    GET DIAGNOSTICS "v_Rcount" = ROW_COUNT;
    
    SELECT COUNT(*) INTO "v_Rcount" FROM "Clg_StudentAdvancePaiddetails_temp";

    IF ("v_Rcount" > 0) THEN
        "v_query" := '
        SELECT DISTINCT "FCMA"."FMG_Id", "FCMAS"."FCMAS_Id", "FCMA"."FMH_Id", "FCMA"."FTI_Id", "FCMA"."ASMAY_Id",
            ("FCMAS"."FCMAS_Amount" - "AT"."FTCP_PaidAmount") AS "FCSS_ToBePaid",
            "AT"."FTCP_PaidAmount" AS "FCSS_PaidAmount", 0 AS "FCSS_ConcessionAmount", 
            "FCMAS_Amount" AS "FCSS_NetAmount", 0 AS "FCSS_FineAmount", 0 AS "FCSS_RefundAmount",
            "FMH"."FMH_FeeName", "FTI"."FTI_Name", "FMG"."FMG_GroupName", 
            "FCMAS_Amount" AS "FCSS_CurrentYrCharges", "FCMAS_Amount" AS "FCSS_TotalCharges",
            0 AS "FCSS_OBArrearAmount", 0 AS "FCSS_WaivedAmount", "FMH_Order", "FMH_Flag", "FCMAS"."FCMAS_DueDate"
        FROM "CLG"."Fee_College_Master_Amount" "FCMA"
        INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" "FCMAS" 
            ON "FCMA"."FCMA_Id" = "FCMAS"."FCMA_Id" AND "FCMAS"."MI_Id" = ' || "p_MI_Id" || '
        INNER JOIN "CLG"."Fee_College_T_Due_Date" "TDD" ON "TDD"."FCMAS_Id" = "FCMAS"."FCMAS_Id"
        INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FCMA"."FMH_Id" AND "FMH"."MI_Id" = ' || "p_MI_Id" || '
        INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FCMA"."FTI_Id" AND "FTI"."MI_Id" = ' || "p_MI_Id" || '
        INNER JOIN "Fee_Master_Group" "FMG" ON "FMG"."FMG_Id" = "FCMA"."FMG_Id" AND "FMG"."MI_Id" = ' || "p_MI_Id" || '
        INNER JOIN "Fee_Group_Login_Previledge" "LP" ON "LP"."FMG_Id" = "FMG"."FMG_Id" AND "LP"."MI_Id" = ' || "p_MI_Id" || '
        INNER JOIN "Clg_StudentAdvancePaiddetails_temp" "AT" 
            ON "AT"."FMG_Id" = "FCMA"."FMG_Id" AND "AT"."FCMAS_Id" = "FCMAS"."FCMAS_Id" 
            AND "AT"."FMH_Id" = "FCMA"."FMH_Id" AND "AT"."FTI_Id" = "FCMA"."FTI_Id" 
            AND "AT"."ASMAY_Id" = "FCMA"."ASMAY_Id"
        WHERE "FCMA"."MI_Id" = ' || "p_MI_Id" || ' 
            AND "AMCO_Id" = ' || "v_AMCO_Id" || ' 
            AND "AMB_Id" = ' || "v_AMB_Id" || ' 
            AND "FCMA"."FMG_Id" IN (' || "p_FMG_Id" || ') 
            AND "FCMAS"."AMSE_Id" = ' || "v_AMSE_Id_N" || '
            AND "FCMA"."ASMAY_Id" = ' || "v_ASMAY_Id" || '
        ORDER BY "FMH_Order"';
    ELSE
        "v_query" := '
        SELECT DISTINCT "FCMA"."FMG_Id", "FCMAS"."FCMAS_Id", "FCMA"."FMH_Id", "FCMA"."FTI_Id", "FCMA"."ASMAY_Id",
            ("FCMAS"."FCMAS_Amount") AS "FCSS_ToBePaid",
            0 AS "FCSS_PaidAmount", 0 AS "FCSS_ConcessionAmount", 
            "FCMAS_Amount" AS "FCSS_NetAmount", 0 AS "FCSS_FineAmount", 0 AS "FCSS_RefundAmount",
            "FMH"."FMH_FeeName", "FTI"."FTI_Name", "FMG"."FMG_GroupName", 
            "FCMAS_Amount" AS "FCSS_CurrentYrCharges", "FCMAS_Amount" AS "FCSS_TotalCharges",
            0 AS "FCSS_OBArrearAmount", 0 AS "FCSS_WaivedAmount", "FMH_Order", "FMH_Flag", "FCMAS"."FCMAS_DueDate"
        FROM "CLG"."Fee_College_Master_Amount" "FCMA"
        INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" "FCMAS" 
            ON "FCMA"."FCMA_Id" = "FCMAS"."FCMA_Id" AND "FCMAS"."MI_Id" = ' || "p_MI_Id" || '
        INNER JOIN "CLG"."Fee_College_T_Due_Date" "TDD" ON "TDD"."FCMAS_Id" = "FCMAS"."FCMAS_Id"
        INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FCMA"."FMH_Id" AND "FMH"."MI_Id" = ' || "p_MI_Id" || '
        INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FCMA"."FTI_Id" AND "FTI"."MI_Id" = ' || "p_MI_Id" || '
        INNER JOIN "Fee_Master_Group" "FMG" ON "FMG"."FMG_Id" = "FCMA"."FMG_Id" AND "FMG"."MI_Id" = ' || "p_MI_Id" || '
        INNER JOIN "Fee_Group_Login_Previledge" "LP" ON "LP"."FMG_Id" = "FMG"."FMG_Id" AND "LP"."MI_Id" = ' || "p_MI_Id" || '
        WHERE "FCMA"."MI_Id" = ' || "p_MI_Id" || ' 
            AND "AMCO_Id" = ' || "v_AMCO_Id" || ' 
            AND "AMB_Id" = ' || "v_AMB_Id" || ' 
            AND "FCMA"."FMG_Id" IN (' || "p_FMG_Id" || ') 
            AND "FCMAS"."AMSE_Id" = ' || "v_AMSE_Id_N" || '
            AND "FCMA"."ASMAY_Id" = ' || "v_ASMAY_Id" || '
        ORDER BY "FMH_Order"';
    END IF;

    RETURN QUERY EXECUTE "v_query";
END;
$$;