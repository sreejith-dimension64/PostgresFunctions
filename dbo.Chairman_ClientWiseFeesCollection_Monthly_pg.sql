CREATE OR REPLACE FUNCTION "dbo"."Chairman_ClientWiseFeesCollection_Monthly"(
    p_USERID BIGINT,
    p_ASMAY_Year TEXT
)
RETURNS TABLE(
    "MI_Id" BIGINT,
    "MI_Name" TEXT,
    "Bank" BIGINT,
    "Cash" BIGINT,
    "Online" BIGINT,
    "Swipe" BIGINT,
    "ECS" BIGINT,
    "RTGS" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SqlDynamic TEXT;
    v_MI_Id TEXT;
    v_StartDate TEXT;
    v_EndDate TEXT;
    inst_cursor CURSOR FOR
        SELECT DISTINCT "MI_Id"::TEXT
        FROM "IVRM_User_Login_Institutionwise" 
        WHERE "id" IN (
            SELECT DISTINCT "UserId" 
            FROM "ApplicationUserRole" 
            WHERE "UserId" = p_USERID
        );
BEGIN

    DROP TABLE IF EXISTS "ChairmanAllCientsFeesCollectionsMonthly_Temp";

    CREATE TEMP TABLE "ChairmanAllCientsFeesCollectionsMonthly_Temp"(
        "MI_Id" BIGINT,
        "MI_Name" TEXT,
        "FeeYear" TEXT,
        "FeeMonth" TEXT,
        "Bank" BIGINT,
        "Cash" BIGINT,
        "Online" BIGINT,
        "Swipe" BIGINT,
        "ECS" BIGINT,
        "RTGS" BIGINT,
        "TotalAmount" BIGINT
    );

    OPEN inst_cursor;
    
    LOOP
        FETCH NEXT FROM inst_cursor INTO v_MI_Id;
        EXIT WHEN NOT FOUND;

        SELECT 
            "ASMAY_From_Date"::DATE::TEXT,
            "ASMAY_To_Date"::DATE::TEXT
        INTO v_StartDate, v_EndDate
        FROM "Adm_School_M_Academic_Year" 
        WHERE "ASMAY_Year" = p_ASMAY_Year 
        AND "MI_Id" = v_MI_Id::BIGINT;

        v_SqlDynamic := '
        SELECT ' || v_MI_Id || '::BIGINT, "MI_Name", EXTRACT(YEAR FROM "Date")::TEXT AS "FeeYear", M."IVRM_Month_Name" AS "FeeMonth",
               SUM("ByBank") "Bank", SUM("ByCash") "Cash", SUM("ByOnline") "Online", 
               SUM("ByCard") "Swipe", SUM("ByECS") "ECS", SUM("ByRTGS") "RTGS", 
               SUM("Total") "TotalAmount"
        FROM (
            SELECT "MI_Name", a."Date", COUNT("FYP_Receipt_No") "Receipts_Count",
                   SUM("ByBank") "ByBank", SUM("ByCash") "ByCash", SUM("ByOnline") "ByOnline", 
                   SUM("ByCard") "ByCard", SUM("ByECS") "ByECS", SUM("ByRTGS") "ByRTGS",
                   SUM("ByBank"+"ByCash"+"ByOnline"+"ByCard"+"ByECS"+"ByRTGS") AS "Total"
            FROM (
                SELECT "MI_Name", "date", "FYP_Receipt_No",
                       COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", 
                       COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard",
                       COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS"
                FROM (
                    SELECT DISTINCT MI."MI_Name", "FYP_Receipt_No", "FYP_Tot_Amount", 
                           "FYP_Bank_Or_Cash", "FYP_Date"::DATE AS "date"
                    FROM "Fee_Y_Payment"
                    INNER JOIN "Fee_T_Payment_OthStaff" ON "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id"
                    INNER JOIN "Fee_Y_Payment_Staff" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_Staff"."FYP_Id"
                    INNER JOIN "Master_Institution" MI ON MI."MI_Id" = "Fee_Y_Payment"."MI_Id"
                    WHERE MI."MI_Id" IN (' || v_MI_Id || ')
                    AND "Fee_Y_Payment"."MI_Id" IN (' || v_MI_Id || ')
                    AND "Fee_Y_Payment"."FYP_Chq_Bounce" <> ''CB''
                    AND "Fee_Y_Payment"."FYP_Chq_Bounce" = ''CL''
                ) AS s
                CROSSTAB(''SELECT "date", "FYP_Receipt_No", "MI_Name", "FYP_Bank_Or_Cash", SUM("FYP_Tot_Amount") 
                           FROM temp_data GROUP BY 1,2,3,4'', 
                         ''VALUES (''''B''''),(''''O''''),(''''C''''),(''''S''''),(''''R''''),(''''E'''')'')
                AS pvt("date" DATE, "FYP_Receipt_No" TEXT, "MI_Name" TEXT, "B" NUMERIC, "O" NUMERIC, "C" NUMERIC, "S" NUMERIC, "R" NUMERIC, "E" NUMERIC)
            ) AS a
            WHERE a."date" BETWEEN ''' || v_StartDate || '''::DATE AND ''' || v_EndDate || '''::DATE
            GROUP BY a."MI_Name", a."Date"

            UNION

            SELECT "MI_Name", a."Date", COUNT("FYP_Receipt_No") "Receipts_Count",
                   SUM("ByBank") "ByBank", SUM("ByCash") "ByCash", SUM("ByOnline") "ByOnline", 
                   SUM("ByCard") "ByCard", SUM("ByECS") "ByECS", SUM("ByRTGS") "ByRTGS",
                   SUM("ByBank"+"ByCash"+"ByOnline"+"ByCard"+"ByECS"+"ByRTGS") AS "Total"
            FROM (
                SELECT "MI_Name", "date", "FYP_Receipt_No",
                       COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", 
                       COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard",
                       COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS"
                FROM (
                    SELECT DISTINCT MI."MI_Name", "FYP_Receipt_No", "FYP_Tot_Amount", 
                           "FYP_Bank_Or_Cash", "FYP_Date"::DATE AS "date"
                    FROM "Fee_Y_Payment"
                    INNER JOIN "Fee_T_Payment" ON "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id"
                    INNER JOIN "Master_Institution" MI ON MI."MI_Id" = "Fee_Y_Payment"."MI_Id"
                    WHERE "Fee_Y_Payment"."MI_Id" IN (' || v_MI_Id || ')
                    AND "Fee_Y_Payment"."FYP_Chq_Bounce" <> ''CB''
                    AND "Fee_Y_Payment"."FYP_Chq_Bounce" = ''CL''
                    AND MI."MI_Id" IN (' || v_MI_Id || ')
                ) AS s
            ) AS a
            WHERE "Date" BETWEEN ''' || v_StartDate || '''::DATE AND ''' || v_EndDate || '''::DATE
            GROUP BY a."MI_Name", a."Date"

            UNION

            SELECT "MI_Name", a."Date", COUNT("FYP_Receipt_No") "Receipts_Count",
                   SUM("ByBank") "ByBank", SUM("ByCash") "ByCash", SUM("ByOnline") "ByOnline", 
                   SUM("ByCard") "ByCard", SUM("ByECS") "ByECS", SUM("ByRTGS") "ByRTGS",
                   SUM("ByBank"+"ByCash"+"ByOnline"+"ByCard"+"ByECS"+"ByRTGS") AS "Total"
            FROM (
                SELECT "MI_Name", "date", "FYP_Receipt_No",
                       COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", 
                       COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard",
                       COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS"
                FROM (
                    SELECT DISTINCT MI."MI_Name", "FYP_Receipt_No", "FYP_Tot_Amount", 
                           "FYP_Bank_Or_Cash", "FYP_Date"::DATE AS "date"
                    FROM "Fee_Y_Payment"
                    INNER JOIN "Fee_T_Payment_OthStaff" ON "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id"
                    INNER JOIN "Fee_Y_Payment_OthStu" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_OthStu"."FYP_Id"
                    INNER JOIN "Master_Institution" MI ON MI."MI_Id" = "Fee_Y_Payment"."MI_Id"
                    WHERE "Fee_Y_Payment"."MI_Id" IN (' || v_MI_Id || ')
                    AND "Fee_Y_Payment"."FYP_Chq_Bounce" <> ''CB''
                    AND "Fee_Y_Payment"."FYP_Chq_Bounce" = ''CL''
                    AND MI."MI_Id" IN (' || v_MI_Id || ')
                ) AS s
            ) AS a
            WHERE a."Date" BETWEEN ''' || v_StartDate || '''::DATE AND ''' || v_EndDate || '''::DATE
            GROUP BY a."MI_Name", a."Date"
        ) AS "New"
        INNER JOIN "IVRM_Month" M ON TO_CHAR("New"."Date", ''Month'') = M."IVRM_Month_Name"
        GROUP BY "MI_Name", EXTRACT(YEAR FROM "Date"), EXTRACT(MONTH FROM "Date"), M."IVRM_Month_Name", "IVRM_Month_Id"
        ORDER BY EXTRACT(YEAR FROM "Date"), "IVRM_Month_Id"';

        EXECUTE 'INSERT INTO "ChairmanAllCientsFeesCollectionsMonthly_Temp"("MI_Id","MI_Name","FeeYear","FeeMonth","Bank","Cash","Online","Swipe","ECS","RTGS","TotalAmount") ' || v_SqlDynamic;

    END LOOP;

    CLOSE inst_cursor;

    RETURN QUERY
    SELECT 
        "MI_Id",
        "MI_Name",
        SUM("Bank") AS "Bank",
        SUM("Cash") AS "Cash",
        SUM("Online") AS "Online",
        SUM("Swipe") AS "Swipe",
        SUM("ECS") AS "ECS",
        SUM("RTGS") AS "RTGS"
    FROM "ChairmanAllCientsFeesCollectionsMonthly_Temp"
    GROUP BY "MI_Id", "MI_Name";

END;
$$;