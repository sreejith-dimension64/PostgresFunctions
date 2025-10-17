CREATE OR REPLACE FUNCTION "dbo"."Daily_Collection_Report_All_staffothers"(
    p_Asmay_id VARCHAR(100),
    p_Mi_Id VARCHAR(100),
    p_from_date TEXT,
    p_to_date TEXT,
    p_asmcl_id TEXT,
    p_fmg_id TEXT,
    p_type TEXT,
    p_done_by TEXT,
    p_trans_by TEXT,
    p_cheque TEXT,
    p_userid VARCHAR(100),
    p_option TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_head_names TEXT;
    v_sql1head TEXT;
    v_sqlhead TEXT;
    v_cols TEXT;
    v_cols1 TEXT;
    v_query TEXT;
    v_monthyearsd TEXT;
    v_monthids TEXT;
    v_monthids1 TEXT;
    v_date TEXT;
    v_rec RECORD;
BEGIN

    IF p_cheque = '0' THEN
        v_date := 'TO_DATE("Fee_Y_Payment"."fyp_date"::text, ''DD/MM/YYYY'') BETWEEN TO_DATE(''' || p_from_date || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || p_to_date || ''', ''DD/MM/YYYY'')';
    ELSE
        v_date := 'TO_DATE("Fee_Y_Payment"."FYP_DD_Cheque_Date"::text, ''DD/MM/YYYY'') BETWEEN TO_DATE(''' || p_from_date || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || p_to_date || ''', ''DD/MM/YYYY'')';
    END IF;

    IF p_fmg_id = '0' THEN
        v_sql1head := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" FROM "Fee_Yearly_Group_Head_Mapping" INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN
        "Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" INNER JOIN "Fee_Group_Login_Previledge" ON 
        "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Yearly_Group_Head_Mapping"."FMG_Id" WHERE ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || p_Mi_Id || ') AND ("Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = ' || p_Asmay_id || ') AND "Fee_Group_Login_Previledge"."User_Id" = ' || p_userid;
    ELSE
        v_sql1head := 'SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" FROM "Fee_Yearly_Group_Head_Mapping" INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id" INNER JOIN
        "Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id" WHERE ("Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || p_Mi_Id || ') AND ("Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = ' || p_Asmay_id || ') AND ("Fee_Master_Group"."FMG_Id" IN (' || p_fmg_id || '))';
    END IF;

    v_monthyearsd := '';
    FOR v_rec IN EXECUTE v_sql1head LOOP
        v_cols := v_rec."FMH_FeeName";
        v_monthyearsd := COALESCE(v_monthyearsd, '') || COALESCE('"' || v_cols || '"' || ', ', '');
    END LOOP;

    IF v_monthyearsd IS NOT NULL AND LENGTH(v_monthyearsd) > 0 THEN
        v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 2);
    END IF;

    IF p_type = 'all' THEN
        IF p_fmg_id = '0' THEN
            IF p_option = 'staff' THEN
                v_query := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (
                    SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline",
                    COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM
                    CROSSTAB(
                        ''SELECT "FYP_Receipt_No", "FYP_Bank_Or_Cash", SUM("FYP_Tot_Amount"), TO_CHAR("FYP_Date", ''''DD/MM/YYYY'''') AS "date"
                        FROM "Fee_Y_Payment", "Fee_T_Payment_OthStaff", "Fee_Y_Payment_Staff"
                        WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" 
                        AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_Staff"."FYP_Id" 
                        AND "Fee_Y_Payment"."ASMAY_ID" = ' || quote_literal(p_Asmay_id) || '
                        AND "MI_Id" = ' || quote_literal(p_Mi_Id) || ' AND ' || v_date || '
                        GROUP BY "FYP_Receipt_No", "FYP_Bank_Or_Cash", "date"'',
                        ''VALUES (''''B''''),(''''C''''),(''''O''''),(''''S''''),(''''R''''),(''''E'''')''
                    ) AS ct("FYP_Receipt_No" TEXT, "date" TEXT, "B" NUMERIC, "C" NUMERIC, "O" NUMERIC, "S" NUMERIC, "R" NUMERIC, "E" NUMERIC)
                ) AS a GROUP BY a."Date"';
            ELSE
                v_query := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (
                    SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline",
                    COALESCE("S", 0) AS "ByCard", COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM
                    CROSSTAB(
                        ''SELECT "FYP_Receipt_No", "FYP_Bank_Or_Cash", SUM("FYP_Tot_Amount"), TO_CHAR("FYP_Date", ''''DD/MM/YYYY'''') AS "date"
                        FROM "Fee_Y_Payment", "Fee_T_Payment_OthStaff", "Fee_Y_Payment_OthStu"
                        WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" 
                        AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_OthStu"."FYP_Id" 
                        AND "Fee_Y_Payment"."ASMAY_ID" = ' || quote_literal(p_Asmay_id) || '
                        AND "MI_Id" = ' || quote_literal(p_Mi_Id) || ' AND ' || v_date || '
                        GROUP BY "FYP_Receipt_No", "FYP_Bank_Or_Cash", "date"'',
                        ''VALUES (''''B''''),(''''C''''),(''''O''''),(''''S''''),(''''R''''),(''''E'''')''
                    ) AS ct("FYP_Receipt_No" TEXT, "date" TEXT, "B" NUMERIC, "C" NUMERIC, "O" NUMERIC, "S" NUMERIC, "R" NUMERIC, "E" NUMERIC)
                ) AS a GROUP BY a."Date"';
            END IF;
        ELSE
            IF p_option = 'staff' THEN
                v_query := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (
                    SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard",
                    COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM
                    CROSSTAB(
                        ''SELECT "FYP_Receipt_No", "FYP_Bank_Or_Cash", SUM("FYP_Tot_Amount"), TO_CHAR("FYP_Date", ''''DD/MM/YYYY'''') AS "date"
                        FROM "Fee_Y_Payment", "Fee_T_Payment_OthStaff", "Fee_Y_Payment_Staff", "Fee_Master_Amount_OthStaffs"
                        WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" 
                        AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_Staff"."FYP_Id" 
                        AND "Fee_Master_Amount_OthStaffs"."FMAOST_Id" = "Fee_T_Payment_OthStaff"."FMAOST_Id"
                        AND "Fee_Y_Payment"."ASMAY_ID" = ' || quote_literal(p_Asmay_id) || ' 
                        AND "fmg_id" IN (' || p_fmg_id || ')
                        AND "Fee_Y_Payment"."MI_Id" = ' || quote_literal(p_Mi_Id) || ' AND ' || v_date || '
                        GROUP BY "FYP_Receipt_No", "FYP_Bank_Or_Cash", "date"'',
                        ''VALUES (''''B''''),(''''C''''),(''''O''''),(''''S''''),(''''R''''),(''''E'''')''
                    ) AS ct("FYP_Receipt_No" TEXT, "date" TEXT, "B" NUMERIC, "C" NUMERIC, "O" NUMERIC, "S" NUMERIC, "R" NUMERIC, "E" NUMERIC)
                ) AS a GROUP BY a."Date"';
            ELSE
                v_query := 'SELECT a."Date", COUNT("FYP_Receipt_No") AS "Receipts_Count", SUM("ByBank") AS "ByBank", SUM("ByCash") AS "ByCash", SUM("ByOnline") AS "ByOnline", SUM("ByCard") AS "ByCard", SUM("ByECS") AS "ByECS", SUM("ByRTGS") AS "ByRTGS", SUM("ByBank" + "ByCash" + "ByOnline" + "ByCard" + "ByECS" + "ByRTGS") AS "Total" FROM (
                    SELECT "date", "FYP_Receipt_No", COALESCE("B", 0) AS "ByBank", COALESCE("C", 0) AS "ByCash", COALESCE("O", 0) AS "ByOnline", COALESCE("S", 0) AS "ByCard",
                    COALESCE("E", 0) AS "ByECS", COALESCE("R", 0) AS "ByRTGS" FROM
                    CROSSTAB(
                        ''SELECT "FYP_Receipt_No", "FYP_Bank_Or_Cash", SUM("FYP_Tot_Amount"), TO_CHAR("FYP_Date", ''''DD/MM/YYYY'''') AS "date"
                        FROM "Fee_Y_Payment", "Fee_T_Payment_OthStaff", "Fee_Y_Payment_OthStu", "Fee_Master_Amount_OthStaffs"
                        WHERE "Fee_Y_Payment"."FYP_Id" = "Fee_T_Payment_OthStaff"."FYP_Id" 
                        AND "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_OthStu"."FYP_Id" 
                        AND "Fee_Master_Amount_OthStaffs"."FMAOST_Id" = "Fee_T_Payment_OthStaff"."FMAOST_Id"
                        AND "Fee_Y_Payment"."ASMAY_ID" = ' || quote_literal(p_Asmay_id) || ' 
                        AND "fmg_id" IN (' || p_fmg_id || ')
                        AND "Fee_Y_Payment"."MI_Id" = ' || quote_literal(p_Mi_Id) || ' AND ' || v_date || '
                        GROUP BY "FYP_Receipt_No", "FYP_Bank_Or_Cash", "date"'',
                        ''VALUES (''''B''''),(''''C''''),(''''O''''),(''''S''''),(''''R''''),(''''E'''')''
                    ) AS ct("FYP_Receipt_No" TEXT, "date" TEXT, "B" NUMERIC, "C" NUMERIC, "O" NUMERIC, "S" NUMERIC, "R" NUMERIC, "E" NUMERIC)
                ) AS a GROUP BY a."Date"';
            END IF;
        END IF;
    ELSE
        IF p_fmg_id = '0' THEN
            IF p_option = 'staff' THEN
                v_query := 'SELECT * FROM CROSSTAB(
                    ''SELECT COALESCE("HRME_EmployeeFirstName", '''''''') || '''' '''' || COALESCE("HRME_EmployeeMiddleName", '''' '''') || '''' '''' || COALESCE("HRME_EmployeeLastName", '''' '''') AS "Name",
                    "Fee_Y_Payment"."FYP_Receipt_No", "Fee_Y_Payment"."FYP_Bank_Name",
                    CASE "Fee_Y_Payment"."FYP_Bank_Or_Cash" WHEN ''''B'''' THEN ''''Bank'''' WHEN ''''C'''' THEN ''''Cash'''' WHEN ''''O'''' THEN ''''Online'''' WHEN ''''S'''' THEN ''''Card'''' WHEN ''''R'''' THEN ''''RTGS'''' ELSE ''''ECS'''' END AS "FYP_Bank_Or_Cash",
                    "Fee_Y_Payment"."FYP_DD_Cheque_No", TO_CHAR("Fee_Y_Payment"."FYP_Date", ''''DD/MM/YYYY'''') AS "Date",
                    TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''''DD/MM/YYYY'''') AS "Chequedate",
                    "Fee_Y_Payment"."ASMAY_ID", "Fee_Y_Payment"."MI_Id", "Fee_Master_Head"."FMH_FeeName",
                    "Fee_T_Payment_OthStaff"."FTPOST_PaidAmount"
                    FROM "Fee_Y_Payment_Staff"
                    INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment_Staff"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
                    INNER JOIN "HR_Master_Employee" ON "Fee_Y_Payment_Staff"."HRME_Id" = "HR_Master_Employee"."HRME_Id"
                    INNER JOIN "Fee_T_Payment_OthStaff" ON "Fee_T_Payment_OthStaff"."FYP_Id" = "Fee_Y_Payment_Staff"."FYP_Id"
                    INNER JOIN "Fee_Master_Amount_OthStaffs" ON "Fee_Master_Amount_OthStaffs"."FMAOST_Id" = "Fee_T_Payment_OthStaff"."FMAOST_Id"
                    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Amount_OthStaffs"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
                    WHERE "Fee_Y_Payment"."MI_Id" = ' || quote_literal(p_Mi_Id) || '
                    AND "Fee_Master_Amount_OthStaffs"."FMAOST_OthStaffFlag" = ''''S''''
                    AND "Fee_Y_Payment"."ASMAY_Id" = ' || quote_literal(p_Asmay_id) || ' AND ' || v_date || '
                    ORDER BY 1, 9'',
                    ''' || v_sql1head || '''
                ) AS ct("Name" TEXT, "FYP_Receipt_No" TEXT, "FYP_Bank_Name" TEXT, "FYP_Bank_Or_Cash" TEXT, 
                    "FYP_DD_Cheque_No" TEXT, "Date" TEXT, "Chequedate" TEXT, "ASMAY_ID" TEXT, "MI_Id" TEXT, ' || v_monthyearsd || ')';
            ELSE
                v_query := 'SELECT * FROM CROSSTAB(
                    ''SELECT "fmost_studentname" AS "Name",
                    "Fee_Y_Payment"."FYP_Receipt_No", "Fee_Y_Payment"."FYP_Bank_Name",
                    CASE "Fee_Y_Payment"."FYP_Bank_Or_Cash" WHEN ''''B'''' THEN ''''Bank'''' WHEN ''''C'''' THEN ''''Cash'''' WHEN ''''O'''' THEN ''''Online'''' WHEN ''''S'''' THEN ''''Card'''' WHEN ''''R'''' THEN ''''RTGS'''' ELSE ''''ECS'''' END AS "FYP_Bank_Or_Cash",
                    "Fee_Y_Payment"."FYP_DD_Cheque_No", TO_CHAR("Fee_Y_Payment"."FYP_Date", ''''DD/MM/YYYY'''') AS "Date",
                    TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''''DD/MM/YYYY'''') AS "Chequedate",
                    "Fee_Y_Payment"."ASMAY_ID", "Fee_Y_Payment"."MI_Id", "Fee_Master_Head"."FMH_FeeName",
                    "Fee_T_Payment_OthStaff"."FTPOST_PaidAmount"
                    FROM "Fee_Y_Payment_OthStu"
                    INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment_OthStu"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
                    INNER JOIN "Fee_Master_OtherStudents" ON "Fee_Y_Payment_OthStu"."FMOST_Id" = "Fee_Master_OtherStudents"."FMOST_Id"
                    INNER JOIN "Fee_T_Payment_OthStaff" ON "Fee_T_Payment_OthStaff"."FYP_Id" = "Fee_Y_Payment_OthStu"."FYP_Id"
                    INNER JOIN "Fee_Master_Amount_OthStaffs" ON "Fee_Master_Amount_OthStaffs"."FMAOST_Id" = "Fee_T_Payment_OthStaff"."FMAOST_Id"
                    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Amount_OthStaffs"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
                    WHERE "Fee_Y_Payment"."MI_Id" = ' || quote_literal(p_Mi_Id) || '
                    AND "Fee_Master_Amount_OthStaffs"."FMAOST_OthStaffFlag" = ''''O''''
                    AND "Fee_Y_Payment"."ASMAY_Id" = ' || quote_literal(p_Asmay_id) || ' AND ' || v_date || '
                    ORDER BY 1, 9'',
                    ''' || v_sql1head || '''
                ) AS ct("Name" TEXT, "FYP_Receipt_No" TEXT, "FYP_Bank_Name" TEXT, "FYP_Bank_Or_Cash" TEXT, 
                    "FYP_DD_Cheque_No" TEXT, "Date" TEXT, "Chequedate" TEXT, "ASMAY_ID" TEXT, "MI_Id" TEXT, ' || v_monthyearsd || ')';
            END IF;
        ELSE
            IF p_option = 'staff' THEN
                v_query := 'SELECT * FROM CROSSTAB(
                    ''SELECT COALESCE("HRME_EmployeeFirstName", '''''''') || '''' '''' || COALESCE("HRME_EmployeeMiddleName", '''' '''') || '''' '''' || COALESCE("HRME_EmployeeLastName", '''' '''') AS "Name",
                    "Fee_Y_Payment"."FYP_Receipt_No", "Fee_Y_Payment"."FYP_Bank_Name",
                    CASE "Fee_Y_Payment"."FYP_Bank_Or_Cash" WHEN ''''B'''' THEN ''''Bank'''' WHEN ''''C'''' THEN ''''Cash'''' WHEN ''''O'''' THEN ''''Online'''' WHEN ''''S'''' THEN ''''Card'''' WHEN ''''R'''' THEN ''''RTGS'''' ELSE ''''ECS'''' END AS "FYP_Bank_Or_Cash",
                    "Fee_Y_Payment"."FYP_DD_Cheque_No", TO_CHAR("Fee_Y_Payment"."FYP_Date", ''''DD/MM/YYYY'''') AS "Date",
                    TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''''DD/MM/YYYY'''') AS "Chequedate",
                    "Fee_Y_Payment"."ASMAY_ID", "Fee_Y_Payment"."MI_Id", "Fee_Master_Head"."FMH_FeeName",
                    "Fee_T_Payment_OthStaff"."FTPOST_PaidAmount"
                    FROM "Fee_Y_Payment_Staff"
                    INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment_Staff"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
                    INNER JOIN "HR_Master_Employee" ON "Fee_Y_Payment_Staff"."HRME_Id" = "HR_Master_Employee"."HRME_Id"
                    INNER JOIN "Fee_T_Payment_OthStaff" ON "Fee_T_Payment_OthStaff"."FYP_Id" = "Fee_Y_Payment_Staff"."FYP_Id"
                    INNER JOIN "Fee_Master_Amount_OthStaffs" ON "Fee_Master_Amount_OthStaffs"."FMAOST_Id" = "Fee_T_Payment_OthStaff"."FMAOST_Id"
                    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Amount_OthStaffs"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
                    WHERE "Fee_Y_Payment"."MI_Id" = ' || quote_literal(p_Mi_Id) || '
                    AND "Fee_Y_Payment"."ASMAY_Id" = ' || quote_literal(p_Asmay_id) || '
                    AND "Fee_Master_Amount_OthStaffs"."FMAOST_OthStaffFlag" = ''''S''''
                    AND "Fee_Master_Amount_OthStaffs"."fmg_id" IN (' || p_fmg_id || ') AND ' || v_date || '
                    ORDER BY 1, 9'',
                    ''' || v_sql1head || '''
                ) AS ct("Name" TEXT, "FYP_Receipt_No" TEXT, "FYP_Bank_Name" TEXT, "FYP_Bank_Or_Cash" TEXT, 
                    "FYP_DD_Cheque_No" TEXT, "Date" TEXT, "Chequedate" TEXT, "ASMAY_ID" TEXT, "MI_Id" TEXT, ' || v_monthyearsd || ')';
            ELSE
                v_query := 'SELECT * FROM CROSSTAB(
                    ''SELECT "fmost_studentname" AS "Name",
                    "Fee_Y_Payment"."FYP_Receipt_No", "Fee_Y_Payment"."FYP_Bank_Name",
                    CASE "Fee_Y_Payment"."FYP_Bank_Or_Cash" WHEN ''''B'''' THEN ''''Bank'''' WHEN ''''C'''' THEN ''''Cash'''' WHEN ''''O'''' THEN ''''Online'''' WHEN ''''S'''' THEN ''''Card'''' WHEN ''''R'''' THEN ''''RTGS'''' ELSE ''''ECS'''' END AS "FYP_Bank_Or_Cash",
                    "Fee_Y_Payment"."FYP_DD_Cheque_No", TO_CHAR("Fee_Y_Payment"."FYP_Date", ''''DD/MM/YYYY'''') AS "Date",
                    TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''''DD/MM/YYYY'''') AS "Chequedate",
                    "Fee_Y_Payment"."ASMAY_ID", "Fee_Y_Payment"."MI_Id", "Fee_Master_Head"."FMH_FeeName",
                    "Fee_T_Payment_OthStaff"."FTPOST_PaidAmount"
                    FROM "Fee_Y_Payment_OthStu"
                    INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment_OthStu"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
                    INNER JOIN "Fee_Master_OtherStudents" ON "Fee_Y_Payment_OthStu"."FMOST_Id" = "Fee_Master_OtherStudents"."FMOST_Id"
                    INNER JOIN "Fee_T_Payment_OthStaff" ON "Fee_T_Payment_OthStaff"."FYP_Id" = "Fee_Y_Payment_OthStu"."FYP_Id"
                    INNER JOIN "Fee_Master_Amount_OthStaffs" ON "Fee_Master_Amount_OthStaffs"."FMAOST_Id" = "Fee_T_Payment_OthStaff"."FMAOST_Id"
                    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Amount_OthStaffs"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
                    WHERE "Fee_Y_Payment"."MI_Id" = ' || quote_literal(p_Mi_Id) || '
                    AND "Fee_Master_Amount_OthStaffs"."FMAOST_OthStaffFlag" = ''''O''''
                    AND "Fee_Y_Payment"."ASMAY_Id" = ' || quote_literal(p_Asmay_id) || '
                    AND "Fee_Master_Amount_OthStaffs"."fmg_id" IN (' || p_fmg_id || ') AND ' || v_date || '
                    ORDER BY 1, 9'',
                    ''' || v_sql1head || '''
                ) AS ct("Name" TEXT, "FYP_Receipt_No" TEXT, "FYP_Bank_Name" TEXT, "FYP_Bank_Or_Cash" TEXT, 
                    "FYP_DD_Cheque_No" TEXT, "Date" TEXT, "Chequedate" TEXT, "ASMAY_ID" TEXT, "MI_Id" TEXT, ' || v_monthyearsd || ')';
            END IF;
        END IF;
    END IF;

    RETURN QUERY EXECUTE v_query;

END;
$$;