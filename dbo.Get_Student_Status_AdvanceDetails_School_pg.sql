CREATE OR REPLACE FUNCTION "dbo"."Get_Student_Status_AdvanceDetails_School"(
    "MI_Id" VARCHAR(10),
    "ASMAY_Id" VARCHAR(10),
    "User_Id" VARCHAR(10),
    "AMST_Id" VARCHAR(10),
    "FMG_Id" VARCHAR(100)
)
RETURNS TABLE(
    "FMG_Id" INTEGER,
    "ASMCL_Id" INTEGER,
    "FMH_Id" INTEGER,
    "FTI_Id" INTEGER,
    "ASMAY_Id" INTEGER,
    "FSS_ToBePaid" NUMERIC,
    "FSS_PaidAmount" NUMERIC,
    "FSS_ConcessionAmount" NUMERIC,
    "FSS_NetAmount" NUMERIC,
    "FSS_FineAmount" NUMERIC,
    "FSS_RefundAmount" NUMERIC,
    "FMH_FeeName" VARCHAR,
    "FTI_Name" VARCHAR,
    "FMG_GroupName" VARCHAR,
    "FSS_CurrentYrCharges" NUMERIC,
    "FSS_TotalCharges" NUMERIC,
    "FSS_OBArrearAmount" NUMERIC,
    "FSS_WaivedAmount" NUMERIC,
    "FMH_Order" INTEGER,
    "FMH_Flag" VARCHAR,
    "FMA_DueDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_query" TEXT;
    "v_ASMCL_Id" VARCHAR(50);
    "v_ASMS_Id" VARCHAR(50);
    "v_ASMCL_Id_N" VARCHAR(20);
    "v_FTP_Paid_Amt" VARCHAR(100);
    "v_Rcount" INTEGER;
    "v_FMC_EnableAdvancePaymentFlg" BOOLEAN;
    "v_ASMAY_Id_N" VARCHAR(200);
    "v_ASMAY_Id" VARCHAR(10);
BEGIN
    "v_ASMAY_Id" := "ASMAY_Id";
    
    SELECT "FMC_EnableAdvancePaymentFlg" INTO "v_FMC_EnableAdvancePaymentFlg" 
    FROM "Fee_Master_Configuration" 
    WHERE "MI_Id" = "MI_Id";
    
    IF ("v_FMC_EnableAdvancePaymentFlg" = TRUE) THEN
        SELECT "ASMAY_Id" INTO "v_ASMAY_Id_N" 
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = "Get_Student_Status_AdvanceDetails_School"."MI_Id" 
        AND "ASMAY_Order" = (
            SELECT "ASMAY_Order" + 1 
            FROM "Adm_School_M_Academic_Year" 
            WHERE "MI_Id" = "Get_Student_Status_AdvanceDetails_School"."MI_Id" 
            AND "ASMAY_Id" = "Get_Student_Status_AdvanceDetails_School"."ASMAY_Id"::INTEGER
        );
        "v_ASMAY_Id" := "v_ASMAY_Id_N";
    END IF;
    
    SELECT DISTINCT "ASMCL_Id", "ASMS_Id" INTO "v_ASMCL_Id", "v_ASMS_Id" 
    FROM "Adm_School_Y_Student" 
    WHERE "AMST_Id" = "Get_Student_Status_AdvanceDetails_School"."AMST_Id"::INTEGER 
    AND "ASMAY_Id" = "v_ASMAY_Id"::INTEGER;
    
    SELECT "ASMCL_Id" INTO "v_ASMCL_Id_N" 
    FROM "Adm_School_M_Class" 
    WHERE "MI_Id" = "Get_Student_Status_AdvanceDetails_School"."MI_Id"::INTEGER 
    AND "ASMCL_Order" = (
        SELECT "ASMCL_Order" + 1 
        FROM "Adm_School_M_Class" 
        WHERE "MI_Id" = "Get_Student_Status_AdvanceDetails_School"."MI_Id"::INTEGER 
        AND "ASMCL_Id" = "v_ASMCL_Id"::INTEGER
    );
    
    "v_FTP_Paid_Amt" := '0';
    
    DROP TABLE IF EXISTS "School_StudentAdvancePaidA_temp";
    
    CREATE TEMP TABLE "School_StudentAdvancePaidA_temp" AS
    SELECT "MA"."FMG_Id", "FYCCC"."ASMCL_Id", "MA"."FMH_Id", "MA"."FTI_Id", "MA"."ASMAY_Id", 
           COALESCE(SUM("FTP_Paid_Amt"), 0) AS "FTP_PaidAmount"
    FROM "Fee_T_Payment" "TP"
    INNER JOIN "Fee_Y_Payment_School_Student" "SS" ON "TP"."FYP_Id" = "SS"."FYP_Id"
    INNER JOIN "Fee_Master_Amount" "MA" ON "MA"."FMA_Id" = "TP"."FMA_Id" 
        AND "MA"."ASMAY_Id" = "v_ASMAY_Id"::INTEGER
    INNER JOIN "Fee_Yearly_Class_Category" "FYCC" ON "FYCC"."FMCC_Id" = "MA"."FMCC_Id"
    INNER JOIN "Fee_Yearly_Class_Category_Classes" "FYCCC" ON "FYCCC"."FYCC_Id" = "FYCC"."FYCC_Id"
    WHERE "SS"."AMST_Id" = "Get_Student_Status_AdvanceDetails_School"."AMST_Id"::INTEGER 
    AND "FYCCC"."ASMCL_Id" = "v_ASMCL_Id_N"::INTEGER
    GROUP BY "MA"."FMG_Id", "FYCCC"."ASMCL_Id", "MA"."FMH_Id", "MA"."FTI_Id", "MA"."ASMAY_Id";
    
    SELECT COUNT(*) INTO "v_Rcount" FROM "School_StudentAdvancePaidA_temp";
    
    IF ("v_Rcount" > 0) THEN
        RETURN QUERY EXECUTE 
        'SELECT DISTINCT "FMA"."FMG_Id", "FYCCC"."ASMCL_Id", "FMA"."FMH_Id", "FMA"."FTI_Id", "FMA"."ASMAY_Id",
            ("FMA"."FMA_Amount" - "AT"."FTP_PaidAmount") AS "FSS_ToBePaid",
            "AT"."FTP_PaidAmount" AS "FSS_PaidAmount", 0 AS "FSS_ConcessionAmount", 
            "FMA_Amount" AS "FSS_NetAmount", 0 AS "FSS_FineAmount", 0 AS "FSS_RefundAmount",
            "FMH"."FMH_FeeName", "FTI"."FTI_Name", "FMG"."FMG_GroupName", 
            "FMA_Amount" AS "FSS_CurrentYrCharges", "FMA_Amount" AS "FSS_TotalCharges",
            0 AS "FSS_OBArrearAmount", 0 AS "FSS_WaivedAmount", "FMH_Order", "FMH_Flag", "FMA"."FMA_DueDate"
        FROM "Fee_Master_Amount" "FMA"
        INNER JOIN "Fee_Yearly_Class_Category" "FYCC" ON "FYCC"."FMCC_Id" = "FMA"."FMCC_Id" 
            AND "FYCC"."ASMAY_Id" = "FMA"."ASMAY_Id"
        INNER JOIN "Fee_Yearly_Class_Category_Classes" "FYCCC" ON "FYCCC"."FYCC_Id" = "FYCC"."FYCC_Id"
        INNER JOIN "Fee_T_Due_Date" "TDD" ON "TDD"."FMA_Id" = "FMA"."FMA_Id"
        INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FMA"."FMH_Id" 
            AND "FMH"."MI_Id" = $1
        INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FMA"."FTI_Id" 
            AND "FTI"."MI_Id" = $1
        INNER JOIN "Fee_Master_Group" "FMG" ON "FMG"."FMG_Id" = "FMA"."FMG_Id" 
            AND "FMG"."MI_Id" = $1
        INNER JOIN "Fee_Group_Login_Previledge" "LP" ON "LP"."FMG_Id" = "FMG"."FMG_Id" 
            AND "LP"."MI_Id" = $1
        LEFT JOIN "School_StudentAdvancePaidA_temp" "AT" ON "AT"."FMG_Id" = "FMA"."FMG_Id" 
            AND "AT"."ASMCL_Id" = "FYCCC"."ASMCL_Id" AND "AT"."FMH_Id" = "FMA"."FMH_Id" 
            AND "AT"."FTI_Id" = "FMA"."FTI_Id" AND "AT"."ASMAY_Id" = "FMA"."ASMAY_Id"
        WHERE "FMA"."MI_Id" = $1 AND "FYCCC"."ASMCL_Id" = $2 
            AND "FMA"."FMG_Id" = ANY(string_to_array($3, '','')::INTEGER[])
            AND "AT"."ASMCL_Id" = $2 AND "LP"."User_Id" = $4 
            AND "FMA"."ASMAY_Id" = $5 AND "FYCC"."ASMAY_Id" = $5
        ORDER BY "FMH_Order"'
        USING "Get_Student_Status_AdvanceDetails_School"."MI_Id"::INTEGER, 
              "v_ASMCL_Id_N"::INTEGER, 
              "Get_Student_Status_AdvanceDetails_School"."FMG_Id", 
              "Get_Student_Status_AdvanceDetails_School"."User_Id"::INTEGER, 
              "v_ASMAY_Id"::INTEGER;
    ELSE
        RETURN QUERY EXECUTE 
        'SELECT DISTINCT "FMA"."FMG_Id", "FYCCC"."ASMCL_Id", "FMA"."FMH_Id", "FMA"."FTI_Id", "FMA"."ASMAY_Id",
            ("FMA"."FMA_Amount") AS "FSS_ToBePaid",
            0 AS "FSS_PaidAmount", 0 AS "FSS_ConcessionAmount", 
            "FMA_Amount" AS "FSS_NetAmount", 0 AS "FSS_FineAmount", 0 AS "FSS_RefundAmount",
            "FMH"."FMH_FeeName", "FTI"."FTI_Name", "FMG"."FMG_GroupName", 
            "FMA_Amount" AS "FSS_CurrentYrCharges", "FMA_Amount" AS "FSS_TotalCharges",
            0 AS "FSS_OBArrearAmount", 0 AS "FSS_WaivedAmount", "FMH_Order", "FMH_Flag", "FMA"."FMA_DueDate"
        FROM "Fee_Master_Amount" "FMA"
        INNER JOIN "Fee_Yearly_Class_Category" "FYCC" ON "FYCC"."FMCC_Id" = "FMA"."FMCC_Id" 
            AND "FYCC"."ASMAY_Id" = "FMA"."ASMAY_Id"
        INNER JOIN "Fee_Yearly_Class_Category_Classes" "FYCCC" ON "FYCCC"."FYCC_Id" = "FYCC"."FYCC_Id"
        INNER JOIN "Fee_T_Due_Date" "TDD" ON "TDD"."FMA_Id" = "FMA"."FMA_Id"
        INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FMA"."FMH_Id" 
            AND "FMH"."MI_Id" = $1
        INNER JOIN "Fee_T_Installment" "FTI" ON "FTI"."FTI_Id" = "FMA"."FTI_Id" 
            AND "FTI"."MI_Id" = $1
        INNER JOIN "Fee_Master_Group" "FMG" ON "FMG"."FMG_Id" = "FMA"."FMG_Id" 
            AND "FMG"."MI_Id" = $1
        INNER JOIN "Fee_Group_Login_Previledge" "LP" ON "LP"."FMG_Id" = "FMG"."FMG_Id" 
            AND "LP"."MI_Id" = $1
        WHERE "FMA"."MI_Id" = $1 AND "FYCCC"."ASMCL_Id" = $2 
            AND "FMA"."FMG_Id" = ANY(string_to_array($3, '','')::INTEGER[])
            AND "LP"."User_Id" = $4 AND "FMA"."ASMAY_Id" = $5 
            AND "FYCC"."ASMAY_Id" = $5
        ORDER BY "FMH_Order"'
        USING "Get_Student_Status_AdvanceDetails_School"."MI_Id"::INTEGER, 
              "v_ASMCL_Id"::INTEGER, 
              "Get_Student_Status_AdvanceDetails_School"."FMG_Id", 
              "Get_Student_Status_AdvanceDetails_School"."User_Id"::INTEGER, 
              "v_ASMAY_Id"::INTEGER;
    END IF;
    
    RETURN;
END;
$$;