CREATE OR REPLACE FUNCTION "dbo"."Fee_PaymentModeWiseTotalAmount"(
    "MI_Id" VARCHAR(50),
    "ASMAY_Id" VARCHAR(50),
    "FromDate" VARCHAR(10),
    "Todate" VARCHAR(10)
)
RETURNS TABLE(
    "Date" DATE,
    "HeadName" VARCHAR,
    payment_columns TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "PivotColumnNames" TEXT := '';
    "PivotSelectColumnNames" TEXT := '';
    "SqlDynamic" TEXT := '';
BEGIN

    SELECT STRING_AGG('"' || "IVRMMOD_ModeOfPayment" || '"', ',' ORDER BY "IVRMMOD_ModeOfPayment")
    INTO "PivotColumnNames"
    FROM (
        SELECT DISTINCT A."IVRMMOD_ModeOfPayment" AS "IVRMMOD_ModeOfPayment" 
        FROM "IVRM_ModeOfPayment" A
        INNER JOIN "Fee_Y_Payment_PaymentMode" B ON B."FYP_TransactionTypeFlag" = A."IVRMMOD_ModeOfPayment_Code"
        INNER JOIN "Fee_Y_Payment" C ON C."FYP_Id" = B."FYP_Id"
        WHERE A."MI_Id" = "MI_Id" 
        AND CAST(C."FYP_date" AS DATE) BETWEEN CAST("FromDate" AS DATE) AND CAST("Todate" AS DATE)
    ) AS PVColumns;

    SELECT STRING_AGG('COALESCE("' || "IVRMMOD_ModeOfPayment" || '", 0) AS "' || "IVRMMOD_ModeOfPayment" || '"', ',' ORDER BY "IVRMMOD_ModeOfPayment")
    INTO "PivotSelectColumnNames"
    FROM (
        SELECT DISTINCT A."IVRMMOD_ModeOfPayment" AS "IVRMMOD_ModeOfPayment"
        FROM "IVRM_ModeOfPayment" A
        INNER JOIN "Fee_Y_Payment_PaymentMode" B ON B."FYP_TransactionTypeFlag" = A."IVRMMOD_ModeOfPayment_Code"
        INNER JOIN "Fee_Y_Payment" C ON C."FYP_Id" = B."FYP_Id"
        WHERE A."MI_Id" = "MI_Id" 
        AND CAST(C."FYP_date" AS DATE) BETWEEN CAST("FromDate" AS DATE) AND CAST("Todate" AS DATE)
    ) AS PVSelctedColumns;

    DROP TABLE IF EXISTS "Fee_StuwiseRecPaymentwiseTotalAmount_Temp";
    DROP TABLE IF EXISTS "Fee_StuwiseRecPaymentmodewiseHeadWsieTotalAmount_Temp";

    CREATE TEMP TABLE "Fee_StuwiseRecPaymentwiseTotalAmount_Temp" AS
    SELECT DISTINCT CAST("FYP"."FYP_date" AS DATE) AS "Total_Date", 
           SUM("FTP"."FTP_Paid_Amt") AS "TotalPaidAmount"
    FROM "Fee_Y_Payment" "FYP"
    INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FYP"."FYP_Id"
    WHERE "FYP"."ASMAY_Id" = "ASMAY_Id" 
    AND "FYP"."MI_Id" = "MI_Id" 
    AND CAST("FYP"."FYP_date" AS DATE) BETWEEN CAST("FromDate" AS DATE) AND CAST("Todate" AS DATE)
    GROUP BY CAST("FYP"."FYP_date" AS DATE);

    "SqlDynamic" := '
    CREATE TEMP TABLE "Fee_StuwiseRecPaymentmodewiseHeadWsieTotalAmount_Temp" AS
    SELECT "FYP_date" AS "Date", "FMH_FeeName" AS "HeadName", ' || "PivotSelectColumnNames" || '
    FROM CROSSTAB(
        ''SELECT CAST(FYP.FYP_date AS DATE)::TEXT AS FYP_date, 
                 FMH.FMH_FeeName, 
                 IVRMM.IVRMMOD_ModeOfPayment,
                 SUM(FTP.FTP_Paid_Amt) AS HeadPaidAmount
          FROM "Fee_Y_Payment" FYP
          INNER JOIN "Fee_T_Payment" FTP ON FTP.FYP_Id = FYP.FYP_Id
          INNER JOIN "Fee_Y_payment_Paymentmode" FYPPM ON FYPPM.FYP_Id = FYP.FYP_Id
          INNER JOIN "IVRM_ModeOfPayment" IVRMM ON IVRMM.IVRMMOD_ModeOfPayment_Code = FYPPM.FYP_TransactionTypeFlag
          INNER JOIN "Fee_Master_Amount" FMA ON FMA.FMA_Id = FTP.FMA_Id AND FMA.ASMAY_Id = FYP.ASMAY_Id
          INNER JOIN "Fee_Master_Head" FMH ON FMH.FMH_Id = FMA.FMH_Id AND FMH.MI_Id = FMA.MI_Id
          WHERE FMA.MI_Id = ' || QUOTE_LITERAL("MI_Id") || '
          AND FMA.ASMAY_Id = ' || QUOTE_LITERAL("ASMAY_Id") || '
          AND FYP.ASMAY_Id = ' || QUOTE_LITERAL("ASMAY_Id") || '
          AND FYP.MI_Id = ' || QUOTE_LITERAL("MI_Id") || '
          AND CAST(FYP.FYP_date AS DATE) BETWEEN ' || QUOTE_LITERAL("FromDate") || '::DATE AND ' || QUOTE_LITERAL("Todate") || '::DATE
          GROUP BY CAST(FYP.FYP_date AS DATE), FMH.FMH_FeeName, IVRMM.IVRMMOD_ModeOfPayment
          ORDER BY 1, 2, 3''
    ) AS ct("FYP_date" TEXT, "FMH_FeeName" TEXT, ' || "PivotColumnNames" || ' NUMERIC)';

    EXECUTE "SqlDynamic";

    RETURN QUERY
    SELECT B."Date", B."HeadName", ROW_TO_JSON(B.*)::TEXT AS payment_columns
    FROM "Fee_StuwiseRecPaymentwiseTotalAmount_Temp" A
    INNER JOIN "Fee_StuwiseRecPaymentmodewiseHeadWsieTotalAmount_Temp" B ON A."Total_Date" = B."Date"
    ORDER BY B."Date";

    DROP TABLE IF EXISTS "Fee_StuwiseRecPaymentwiseTotalAmount_Temp";
    DROP TABLE IF EXISTS "Fee_StuwiseRecPaymentmodewiseHeadWsieTotalAmount_Temp";

    RETURN;
END;
$$;