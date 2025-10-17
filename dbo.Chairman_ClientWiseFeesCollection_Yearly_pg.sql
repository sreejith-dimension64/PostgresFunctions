CREATE OR REPLACE FUNCTION "dbo"."Chairman_ClientWiseFeesCollection_Yearly"(
    p_USERID BIGINT,
    p_ASMAY_Year TEXT
)
RETURNS TABLE(
    "MI_Id" BIGINT,
    "MI_Name" TEXT,
    "FeeYear" TEXT,
    "TotalAmount" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_SqlDynamic TEXT;
    v_SqlDynamic1 TEXT;
    v_SqlDynamic2 TEXT;
    v_MI_Id TEXT;
    v_StartDate VARCHAR(10);
    v_EndDate VARCHAR(10);
    rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "ChairmanAllCientsFeesCollectionsYearly_Temp";

    CREATE TEMP TABLE "ChairmanAllCientsFeesCollectionsYearly_Temp"(
        "MI_Id" BIGINT,
        "MI_Name" TEXT,
        "FeeYear" TEXT,
        "TotalAmount" BIGINT
    );

    FOR rec IN 
        SELECT DISTINCT "MI_Id"::TEXT
        FROM "IVRM_User_Login_Institutionwise" 
        WHERE "id" IN (
            SELECT DISTINCT "UserId" 
            FROM "ApplicationUserRole" 
            WHERE "UserId" = p_USERID
        )
    LOOP
        v_MI_Id := rec."MI_Id";

        SELECT TO_CHAR("ASMAY_From_Date", 'YYYY-MM-DD'), 
               TO_CHAR("ASMAY_To_Date", 'YYYY-MM-DD')
        INTO v_StartDate, v_EndDate
        FROM "Adm_School_M_Academic_Year" 
        WHERE "ASMAY_Year" = p_ASMAY_Year 
        AND "MI_Id" = v_MI_Id::BIGINT;

        v_SqlDynamic := '
        SELECT ' || v_MI_Id || '::BIGINT, "MI_Name", EXTRACT(YEAR FROM "Date")::TEXT AS "FeeYear", SUM("Total")::BIGINT AS "TotalAmount"
        FROM (
            SELECT "MI_Name", a."Date", COUNT("FYP_Receipt_No") "Receipts_Count", SUM("ByBank") "ByBank", SUM("ByCash") "ByCash", SUM("ByOnline") "ByOnline", SUM("ByCard") "ByCard", SUM("ByECS") "ByECS", SUM("ByRTGS") "ByRTGS", SUM("ByBank"+"ByCash"+"ByOnline"+"ByCard"+"ByECS"+"ByRTGS") AS "Total"
            FROM (
                SELECT "MI_Name", "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS"
                FROM (
                    SELECT DISTINCT "MI"."MI_Name", "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", CAST("FYP_Date" AS DATE) AS "date"
                    FROM "Fee_Y_Payment", "Fee_T_Payment_OthStaff", "Fee_Y_Payment_Staff", "Master_Institution" "MI"
                    WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" 
                    AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_Staff"."FYP_Id" 
                    AND "MI"."MI_Id" = "Fee_Y_Payment"."MI_Id" 
                    AND "MI"."MI_Id" IN (' || v_MI_Id || ')
                    AND "Fee_Y_Payment"."MI_Id" IN (' || v_MI_Id || ') 
                    AND "Fee_Y_Payment"."FYP_Chq_Bounce" <> ''CB'' 
                    AND "Fee_Y_Payment"."FYP_Chq_Bounce" = ''CL''
                ) AS s 
                CROSSTAB(''SELECT "FYP_Receipt_No", "FYP_Bank_Or_Cash", SUM("FYP_Tot_Amount") FROM ... GROUP BY ...'') AS pvt("FYP_Receipt_No" TEXT, "B" NUMERIC, "O" NUMERIC, "C" NUMERIC, "S" NUMERIC, "R" NUMERIC, "E" NUMERIC)
            ) AS a
            WHERE a."date" BETWEEN ''' || v_StartDate || '''::DATE AND ''' || v_EndDate || '''::DATE
            GROUP BY a."MI_Name", a."Date"

            UNION

            SELECT "MI_Name", a."Date", COUNT("FYP_Receipt_No") "Receipts_Count", SUM("ByBank") "ByBank", SUM("ByCash") "ByCash", SUM("ByOnline") "ByOnline", SUM("ByCard") "ByCard", SUM("ByECS") "ByECS", SUM("ByRTGS") "ByRTGS", SUM("ByBank"+"ByCash"+"ByOnline"+"ByCard"+"ByECS"+"ByRTGS") AS "Total"
            FROM (
                SELECT "MI_Name", "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS"
                FROM (
                    SELECT DISTINCT "MI"."MI_Name", "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", CAST("FYP_Date" AS DATE) AS "date"
                    FROM "Fee_Y_Payment", "Fee_T_Payment", "Master_Institution" "MI"
                    WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment"."FYP_Id" 
                    AND "Fee_Y_Payment"."MI_Id" IN (' || v_MI_Id || ') 
                    AND "Fee_Y_Payment"."FYP_Chq_Bounce" <> ''CB'' 
                    AND "Fee_Y_Payment"."FYP_Chq_Bounce" = ''CL''
                    AND "MI"."MI_Id" = "Fee_Y_Payment"."MI_Id" 
                    AND "MI"."MI_Id" IN (' || v_MI_Id || ')
                ) AS s
            ) AS a
            WHERE "date" BETWEEN ''' || v_StartDate || '''::DATE AND ''' || v_EndDate || '''::DATE
            GROUP BY a."MI_Name", a."Date"

            UNION

            SELECT "MI_Name", a."Date", COUNT("FYP_Receipt_No") "Receipts_Count", SUM("ByBank") "ByBank", SUM("ByCash") "ByCash", SUM("ByOnline") "ByOnline", SUM("ByCard") "ByCard", SUM("ByECS") "ByECS", SUM("ByRTGS") "ByRTGS", SUM("ByBank"+"ByCash"+"ByOnline"+"ByCard"+"ByECS"+"ByRTGS") AS "Total"
            FROM (
                SELECT "MI_Name", "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS"
                FROM (
                    SELECT DISTINCT "MI"."MI_Name", "FYP_Receipt_No", "FYP_Tot_Amount", "FYP_Bank_Or_Cash", CAST("FYP_Date" AS DATE) AS "date"
                    FROM "Fee_Y_Payment", "Fee_T_Payment_OthStaff", "Fee_Y_Payment_OthStu", "Master_Institution" "MI"
                    WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" 
                    AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_OthStu"."FYP_Id"
                    AND "Fee_Y_Payment"."MI_Id" IN (' || v_MI_Id || ') 
                    AND "Fee_Y_Payment"."FYP_Chq_Bounce" <> ''CB'' 
                    AND "Fee_Y_Payment"."FYP_Chq_Bounce" = ''CL''
                    AND "MI"."MI_Id" = "Fee_Y_Payment"."MI_Id" 
                    AND "MI"."MI_Id" IN (' || v_MI_Id || ')
                ) AS s
            ) AS a
            WHERE a."date" BETWEEN ''' || v_StartDate || '''::DATE AND ''' || v_EndDate || '''::DATE
            GROUP BY a."MI_Name", a."Date"
        ) AS "New"
        GROUP BY "MI_Name", EXTRACT(YEAR FROM "Date")
        ORDER BY EXTRACT(YEAR FROM "Date")';

        EXECUTE 'INSERT INTO "ChairmanAllCientsFeesCollectionsYearly_Temp"("MI_Id", "MI_Name", "FeeYear", "TotalAmount") ' || v_SqlDynamic;

    END LOOP;

    RETURN QUERY SELECT * FROM "ChairmanAllCientsFeesCollectionsYearly_Temp";

    DROP TABLE IF EXISTS "ChairmanAllCientsFeesCollectionsYearly_Temp";

END;
$$;