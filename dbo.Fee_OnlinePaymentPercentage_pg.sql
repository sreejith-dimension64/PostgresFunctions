CREATE OR REPLACE FUNCTION "dbo"."Fee_OnlinePaymentPercentage"(p_MI_Id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_from_date varchar(50);
    v_to_date varchar(50);
    v_ASMAY_Id bigint;
    v_query1 text;
    v_query2 text;
    v_AllPaidAmount decimal(18,2);
    v_OnlinePaidAmount decimal(18,2);
    v_onlinePercentage decimal(18,2);
    v_AllPaidAmount1 decimal(18,2);
    v_AllPaidAmount2 decimal(18,2);
    v_AllPaidAmount3 decimal(18,2);
BEGIN

    DROP TABLE IF EXISTS "FeeOnlinePaymentTemp";
    DROP TABLE IF EXISTS "FeeOnlinePaymentTemp1";

    SELECT "ASMAY_Id", TO_CHAR("ASMAY_From_Date", 'DD/MM/YYYY')
    INTO v_ASMAY_Id, v_from_date
    FROM "Adm_School_M_Academic_Year"
    WHERE "MI_Id" = p_MI_Id 
    AND CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date";

    v_query2 := 'CREATE TEMP TABLE "FeeOnlinePaymentTemp" AS 
    SELECT * FROM (
        SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count",
               SUM("ByBank") AS "ByBank", SUM("ByOnline") AS "ByOnline", 
               SUM("ByCard") AS "ByCard", SUM("ByRTGS") AS "ByRTGS",
               SUM("ByBank" + "ByOnline" + "ByCard" + "ByRTGS") AS "Total"
        FROM (
            SELECT date, "FYP_Receipt_No",
                   COALESCE("B", 0) AS "ByBank",
                   COALESCE("O", 0) AS "ByOnline",
                   COALESCE("S", 0) AS "ByCard",
                   COALESCE("R", 0) AS "ByRTGS"
            FROM (
                SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash",
                       TO_CHAR("FYP_Date"::timestamp, ''DD/MM/YYYY'') AS date,
                       "FYP_Bank_Or_Cash" AS payment_type,
                       "FYP_Tot_Amount" AS amount
                FROM "Fee_Y_Payment", "Fee_T_Payment_OthStaff", "Fee_Y_Payment_Staff"
                WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id"
                AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_Staff"."FYP_Id"
                AND "Fee_Y_Payment"."ASMAY_ID" = ' || v_ASMAY_Id || '
                AND "MI_Id" = ' || p_MI_Id || '
                AND "Fee_Y_Payment"."fyp_date"::date BETWEEN TO_DATE(''' || v_from_date || ''', ''DD/MM/YYYY'') AND CURRENT_DATE
            ) AS s
            PIVOT (
                SUM(amount) FOR payment_type IN (''B'' AS "B", ''O'' AS "O", ''S'' AS "S", ''R'' AS "R")
            )
        ) AS a
        GROUP BY a."Date"
        
        UNION
        
        SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count",
               SUM("ByBank") AS "ByBank", SUM("ByOnline") AS "ByOnline",
               SUM("ByCard") AS "ByCard", SUM("ByRTGS") AS "ByRTGS",
               SUM("ByBank" + "ByOnline" + "ByCard" + "ByRTGS") AS "Total"
        FROM (
            SELECT date, "FYP_Receipt_No",
                   COALESCE("B", 0) AS "ByBank",
                   COALESCE("O", 0) AS "ByOnline",
                   COALESCE("S", 0) AS "ByCard",
                   COALESCE("R", 0) AS "ByRTGS"
            FROM (
                SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash",
                       TO_CHAR("FYP_Date"::timestamp, ''DD/MM/YYYY'') AS date,
                       "FYP_Bank_Or_Cash" AS payment_type,
                       "FYP_Tot_Amount" AS amount
                FROM "Fee_Y_Payment", "Fee_T_Payment"
                WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id"
                AND "Fee_Y_Payment"."ASMAY_ID" = ' || v_ASMAY_Id || '
                AND "MI_Id" = ' || p_MI_Id || '
                AND "Fee_Y_Payment"."fyp_date"::date BETWEEN TO_DATE(''' || v_from_date || ''', ''DD/MM/YYYY'') AND CURRENT_DATE
            ) AS s
            PIVOT (
                SUM(amount) FOR payment_type IN (''B'' AS "B", ''O'' AS "O", ''S'' AS "S", ''R'' AS "R")
            )
        ) AS a
        GROUP BY a."Date"
        
        UNION
        
        SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count",
               SUM("ByBank") AS "ByBank", SUM("ByOnline") AS "ByOnline",
               SUM("ByCard") AS "ByCard", SUM("ByRTGS") AS "ByRTGS",
               SUM("ByBank" + "ByOnline" + "ByCard" + "ByRTGS") AS "Total"
        FROM (
            SELECT date, "FYP_Receipt_No",
                   COALESCE("B", 0) AS "ByBank",
                   COALESCE("O", 0) AS "ByOnline",
                   COALESCE("S", 0) AS "ByCard",
                   COALESCE("R", 0) AS "ByRTGS"
            FROM (
                SELECT DISTINCT "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash",
                       TO_CHAR("FYP_Date"::timestamp, ''DD/MM/YYYY'') AS date,
                       "FYP_Bank_Or_Cash" AS payment_type,
                       "FYP_Tot_Amount" AS amount
                FROM "Fee_Y_Payment", "Fee_T_Payment_OthStaff", "Fee_Y_Payment_OthStu"
                WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id"
                AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_OthStu"."FYP_Id"
                AND "Fee_Y_Payment"."ASMAY_ID" = ' || v_ASMAY_Id || '
                AND "MI_Id" = ' || p_MI_Id || '
                AND "Fee_Y_Payment"."fyp_date"::date BETWEEN TO_DATE(''' || v_from_date || ''', ''DD/MM/YYYY'') AND CURRENT_DATE
            ) AS s
            PIVOT (
                SUM(amount) FOR payment_type IN (''B'' AS "B", ''O'' AS "O", ''S'' AS "S", ''R'' AS "R")
            )
        ) AS a
        GROUP BY a."Date"
    ) AS "New"';

    EXECUTE v_query2;

    SELECT SUM("Total") INTO v_OnlinePaidAmount FROM "FeeOnlinePaymentTemp";

    SELECT SUM("FSS_PaidAmount") INTO v_AllPaidAmount1 
    FROM "fee_student_status" 
    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = v_ASMAY_Id;
    
    SELECT SUM("FSSOST_PaidAmount") INTO v_AllPaidAmount2 
    FROM "Fee_Student_Status_OthStu" 
    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = v_ASMAY_Id;
    
    SELECT SUM("FSSST_PaidAmount") INTO v_AllPaidAmount3 
    FROM "Fee_Student_Status_Staff" 
    WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id" = v_ASMAY_Id;

    v_onlinePercentage := (v_OnlinePaidAmount / (v_AllPaidAmount1 + v_AllPaidAmount2 + v_AllPaidAmount3)) * 100;

    RAISE NOTICE '%', v_onlinePercentage;

END;
$$;