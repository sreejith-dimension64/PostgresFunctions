CREATE OR REPLACE FUNCTION "dbo"."feesummary_report"(
    "yerid" BIGINT,
    "fypfromdate" VARCHAR(10),
    "groupids" VARCHAR,
    "fyptodate" VARCHAR(10),
    "flag" TEXT,
    "flagdate" TEXT
)
RETURNS TABLE(
    "FMH_FeeName" VARCHAR,
    "Amount" NUMERIC,
    "Fine" NUMERIC,
    "FMH_Id" BIGINT,
    "studcount" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "flag" = 'CollectionSummary' THEN
        IF "flagdate" = 'acyearwise' THEN
            RETURN QUERY
            SELECT 
                "Fee_Master_Head"."FMH_FeeName",
                SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "Amount",
                NULL::NUMERIC AS "Fine",
                "Fee_Master_Head"."FMH_Id",
                COUNT(DISTINCT "Fee_Y_Payment_School_Student"."AMST_Id") AS "studcount"
            FROM "dbo"."Fee_Master_Head" 
            INNER JOIN "dbo"."Fee_Master_Amount" ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Amount"."FMH_Id"
            INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Master_Amount"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
            INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_Master_Amount"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
            INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
            WHERE "Fee_Y_Payment"."ASMAY_ID" = "yerid"
            AND ("Fee_Master_Group"."FMG_Id"::VARCHAR IN (SELECT unnest(string_to_array("groupids", ','))))
            AND ("Fee_Master_Head"."FMH_Id" IN (SELECT DISTINCT "FMH_Id" FROM "dbo"."Fee_Master_Head" AS "Fee_Master_Head_1"))
            GROUP BY "Fee_Master_Head"."FMH_FeeName", "Fee_Master_Head"."FMH_Id"
            HAVING SUM("Fee_T_Payment"."FTP_Paid_Amt") > 0
            LIMIT 100;
        ELSE
            RETURN QUERY
            SELECT 
                "Fee_Master_Head"."FMH_FeeName",
                SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "Amount",
                NULL::NUMERIC AS "Fine",
                "Fee_Master_Head"."FMH_Id",
                COUNT(DISTINCT "Fee_Y_Payment_School_Student"."AMST_Id") AS "studcount"
            FROM "dbo"."Fee_Master_Head" 
            INNER JOIN "dbo"."Fee_Master_Amount" ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Amount"."FMH_Id"
            INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Master_Amount"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
            INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_Master_Amount"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
            INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
            WHERE (TO_DATE("Fee_Y_Payment"."FYP_Date"::TEXT, 'DD/MM/YYYY') >= TO_DATE("fypfromdate", 'DD/MM/YYYY'))
            AND ("Fee_Master_Group"."FMG_Id"::VARCHAR IN (SELECT unnest(string_to_array("groupids", ','))))
            AND ("Fee_Master_Head"."FMH_Id" IN (SELECT DISTINCT "FMH_Id" FROM "dbo"."Fee_Master_Head" AS "Fee_Master_Head_1"))
            AND (TO_DATE("Fee_Y_Payment"."FYP_Date"::TEXT, 'DD/MM/YYYY') <= TO_DATE("fyptodate", 'DD/MM/YYYY'))
            GROUP BY "Fee_Master_Head"."FMH_FeeName", "Fee_Master_Head"."FMH_Id"
            HAVING SUM("Fee_T_Payment"."FTP_Paid_Amt") > 0
            LIMIT 100;
        END IF;
    ELSIF "flag" = 'ReceiptSummary' THEN
        IF "flagdate" = 'acyearwise' THEN
            RETURN QUERY
            SELECT 
                "Fee_Master_Head"."FMH_FeeName",
                SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "Amount",
                SUM("Fee_T_Payment"."FTP_Fine_Amt") AS "Fine",
                "Fee_Master_Head"."FMH_Id",
                COUNT(DISTINCT "Fee_Y_Payment"."FYP_Id") AS "studcount"
            FROM "dbo"."Fee_Master_Head" 
            INNER JOIN "dbo"."Fee_Master_Amount" ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Amount"."FMH_Id"
            INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Master_Amount"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
            INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_Master_Amount"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
            INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
            WHERE "Fee_Y_Payment"."ASMAY_ID" = "yerid"
            AND ("Fee_Master_Group"."FMG_Id"::VARCHAR IN (SELECT unnest(string_to_array("groupids", ','))))
            AND ("Fee_Master_Head"."FMH_Id" IN (SELECT DISTINCT "FMH_Id" FROM "dbo"."Fee_Master_Head" AS "Fee_Master_Head_1"))
            GROUP BY "Fee_Master_Head"."FMH_FeeName", "Fee_Master_Head"."FMH_Id"
            HAVING SUM("Fee_T_Payment"."FTP_Paid_Amt") > 0
            LIMIT 100;
        ELSE
            RETURN QUERY
            SELECT 
                "Fee_Master_Head"."FMH_FeeName",
                SUM("Fee_T_Payment"."FTP_Paid_Amt") AS "Amount",
                SUM("Fee_T_Payment"."FTP_Fine_Amt") AS "Fine",
                "Fee_Master_Head"."FMH_Id",
                COUNT(DISTINCT "Fee_Y_Payment"."FYP_Id") AS "studcount"
            FROM "dbo"."Fee_Master_Head" 
            INNER JOIN "dbo"."Fee_Master_Amount" ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Amount"."FMH_Id"
            INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Master_Amount"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
            INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_Master_Amount"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
            INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
            WHERE (TO_DATE("Fee_Y_Payment"."FYP_Date"::TEXT, 'DD/MM/YYYY') >= TO_DATE("fypfromdate", 'DD/MM/YYYY'))
            AND ("Fee_Master_Group"."FMG_Id"::VARCHAR IN (SELECT unnest(string_to_array("groupids", ','))))
            AND ("Fee_Master_Head"."FMH_Id" IN (SELECT DISTINCT "FMH_Id" FROM "dbo"."Fee_Master_Head" AS "Fee_Master_Head_1"))
            AND (TO_DATE("Fee_Y_Payment"."FYP_Date"::TEXT, 'DD/MM/YYYY') <= TO_DATE("fyptodate", 'DD/MM/YYYY'))
            GROUP BY "Fee_Master_Head"."FMH_FeeName", "Fee_Master_Head"."FMH_Id"
            HAVING SUM("Fee_T_Payment"."FTP_Paid_Amt") > 0
            LIMIT 100;
        END IF;
    END IF;

    RETURN;
END;
$$;