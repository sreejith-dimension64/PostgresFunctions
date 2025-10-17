CREATE OR REPLACE FUNCTION "dbo"."Fee_Montly_collection2"(
    p_fromdate VARCHAR(10),
    p_todate VARCHAR(10),
    p_flag VARCHAR,
    p_allorind VARCHAR,
    p_amstid VARCHAR(100),
    p_groupids VARCHAR,
    p_termids VARCHAR,
    p_left VARCHAR(100),
    p_mi_id VARCHAR,
    p_asmay_id VARCHAR,
    p_term_group VARCHAR(2),
    p_chequedate VARCHAR(10)
)
RETURNS TABLE (
    "AMST_Id" INTEGER,
    "AdmNo" VARCHAR,
    "regno" VARCHAR,
    "StudentName" VARCHAR,
    "aaa" NUMERIC,
    "aa" VARCHAR,
    "ReceiptDetails" VARCHAR,
    "Total" NUMERIC
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_cols TEXT;
    v_cols1 TEXT;
    v_cols2 TEXT;
    v_cols3 TEXT;
    v_query TEXT;
    v_monthyearsd TEXT;
    v_monthids TEXT;
    v_monthids1 TEXT;
    v_monthyearsd1 TEXT;
    v_recno TEXT;
    v_Date TEXT;
    v_total TEXT;
    v_col3 TEXT;
    v_col4 TEXT;
    v_col5 TEXT;
    v_col6 TEXT;
    v_sql TEXT;
    v_leftflag VARCHAR(100);
    v_sql1 TEXT;
    rec RECORD;
BEGIN
    v_total := 'Total';
    v_recno := 'Rcpt.No:';
    v_Date := 'Date:';
    v_monthyearsd := '';
    v_monthyearsd1 := '';

    IF p_chequedate = '0' THEN
        v_sql1 := 'SELECT DISTINCT (TO_CHAR("Fee_Y_Payment"."FYP_Date", ''Month'') || TO_CHAR("Fee_Y_Payment"."FYP_Date", ''YYYY'')) AS monthyear,
        EXTRACT(MONTH FROM "Fee_Y_Payment"."FYP_Date") AS ddd,
        TO_CHAR("Fee_Y_Payment"."FYP_Date", ''Month'') AS rr,
        TO_CHAR("Fee_Y_Payment"."FYP_Date", ''YYYY'') AS vv
        FROM "Adm_School_Y_Student"
        INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        WHERE TO_DATE("Fee_Y_Payment"."FYP_Date"::TEXT, ''DD-MM-YYYY'') BETWEEN TO_DATE(''' || p_fromdate || ''', ''DD-MM-YYYY'') 
        AND TO_DATE(''' || p_todate || ''', ''DD-MM-YYYY'')
        AND ("Fee_Y_Payment"."FYP_Chq_Bounce" <> ''BO'')
        AND "Fee_Y_Payment"."mi_id" = ' || p_mi_id || '
        AND "Fee_Y_Payment"."asmay_id" = ' || p_asmay_id || '
        ORDER BY EXTRACT(MONTH FROM "Fee_Y_Payment"."FYP_Date"), TO_CHAR("Fee_Y_Payment"."FYP_Date", ''Month''), TO_CHAR("Fee_Y_Payment"."FYP_Date", ''YYYY'')';
    ELSE
        v_sql1 := 'SELECT DISTINCT (TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''Month'') || TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''YYYY'')) AS monthyear,
        EXTRACT(MONTH FROM "Fee_Y_Payment"."FYP_DD_Cheque_Date") AS ddd,
        TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''Month'') AS rr,
        TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''YYYY'') AS vv
        FROM "Adm_School_Y_Student"
        INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        WHERE "Fee_Y_Payment"."FYP_DD_Cheque_Date"::DATE BETWEEN TO_DATE(''' || p_fromdate || ''', ''DD-MM-YYYY'') 
        AND TO_DATE(''' || p_todate || ''', ''DD-MM-YYYY'')
        AND ("Fee_Y_Payment"."FYP_Chq_Bounce" <> ''BO'')
        AND "Fee_Y_Payment"."mi_id" = ' || p_mi_id || '
        AND "Fee_Y_Payment"."asmay_id" = ' || p_asmay_id || '
        ORDER BY EXTRACT(MONTH FROM "Fee_Y_Payment"."FYP_DD_Cheque_Date"), TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''Month''), TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''YYYY'')';
    END IF;

    FOR rec IN EXECUTE v_sql1 LOOP
        v_cols := rec.monthyear;
        v_col4 := rec.ddd::TEXT;
        v_col5 := rec.rr;
        v_col6 := rec.vv;
        v_monthyearsd := COALESCE(v_monthyearsd, '') || COALESCE(v_cols || ', ', '');
        v_monthyearsd1 := COALESCE(v_monthyearsd1, '') || COALESCE('COALESCE("' || v_cols || '", 0) AS "' || v_cols || '"' || ', ', '');
    END LOOP;

    v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 2);

    IF p_left = '1' THEN
        v_leftflag := 'L';
    ELSE
        v_leftflag := 'S';
    END IF;

    IF p_allorind = 'all' THEN
        IF p_term_group = 'T' THEN
            IF p_chequedate = '0' THEN
                v_query := 'SELECT DISTINCT "AMST_Id", "AdmNo", "regno", "StudentName", aaa, aa, "ReceiptDetails", ' || v_monthyearsd1 || ' COALESCE(aa, ''' || v_total || ''') AS " ", SUM(aaa) AS "Total"
                FROM (SELECT DISTINCT "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo" AS "AdmNo", "Adm_M_Student"."AMST_RegistrationNo" AS regno,
                (COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''')) AS "StudentName",
                "Fee_Y_Payment"."FYP_Tot_Amount" AS aaa, '''' AS aa, "Fee_Y_Payment"."FYP_Tot_Amount" AS amount,
                TO_CHAR("Fee_Y_Payment"."FYP_Date", ''Month'') || TO_CHAR("Fee_Y_Payment"."FYP_Date", ''YYYY'') AS monthyear,
                (''' || v_recno || ''' || '' '' || CAST("FYP_Receipt_No" AS TEXT) || '' '' || ''' || v_Date || ''' || TO_CHAR("FYP_Date", ''DD-MM-YYYY'')) AS "ReceiptDetails"
                FROM "Fee_Y_Payment"
                INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id"
                INNER JOIN "Fee_Master_Terms_FeeHeads" INNER JOIN "Fee_Student_Status" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
                INNER JOIN "Adm_School_Y_Student" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
                ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
                ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
                WHERE "Fee_Y_Payment"."FYP_Id" IN (SELECT DISTINCT "Fee_T_Payment"."FYP_Id"
                FROM "Fee_Y_Payment_School_Student"
                INNER JOIN "Fee_T_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_T_Payment"."FYP_Id"
                INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
                INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
                WHERE "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || p_termids || '))
                AND TO_DATE("Fee_Y_Payment"."FYP_Date"::TEXT, ''DD-MM-YYYY'') BETWEEN TO_DATE(''' || p_fromdate || ''', ''DD-MM-YYYY'') AND TO_DATE(''' || p_todate || ''', ''DD-MM-YYYY'')
                AND "Fee_Y_Payment"."FYP_Chq_Bounce" <> ''' || p_flag || '''
                AND "Adm_M_Student"."AMST_SOL" = ''' || v_leftflag || '''
                AND "Fee_Y_Payment"."mi_id" = ''' || p_mi_id || '''
                AND "Fee_Y_Payment"."asmay_id" = ''' || p_asmay_id || ''') AS s
                GROUP BY ROLLUP(aaa), "AMST_Id", "StudentName", "AdmNo", regno, aaa, aa, "ReceiptDetails"';
            ELSE
                v_query := 'SELECT DISTINCT "AMST_Id", "AdmNo", "regno", "StudentName", aaa, aa, "ReceiptDetails", ' || v_monthyearsd1 || ' COALESCE(aa, ''' || v_total || ''') AS " ", SUM(aaa) AS "Total"
                FROM (SELECT DISTINCT "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo" AS "AdmNo", "Adm_M_Student"."AMST_RegistrationNo" AS regno,
                (COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''')) AS "StudentName",
                "Fee_Y_Payment"."FYP_Tot_Amount" AS aaa, '''' AS aa, "Fee_Y_Payment"."FYP_Tot_Amount" AS amount,
                TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''Month'') || TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''YYYY'') AS monthyear,
                (''' || v_recno || ''' || '' '' || CAST("FYP_Receipt_No" AS TEXT) || '' '' || ''' || v_Date || ''' || TO_CHAR("FYP_DD_Cheque_Date", ''DD-MM-YYYY'')) AS "ReceiptDetails"
                FROM "Fee_Y_Payment"
                INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id"
                INNER JOIN "Fee_Master_Terms_FeeHeads" INNER JOIN "Fee_Student_Status" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
                INNER JOIN "Adm_School_Y_Student" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
                ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
                ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
                WHERE "Fee_Y_Payment"."FYP_Id" IN (SELECT DISTINCT "Fee_T_Payment"."FYP_Id"
                FROM "Fee_Y_Payment_School_Student"
                INNER JOIN "Fee_T_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_T_Payment"."FYP_Id"
                INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
                INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
                WHERE "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || p_termids || '))
                AND "Fee_Y_Payment"."FYP_DD_Cheque_Date"::DATE BETWEEN TO_DATE(''' || p_fromdate || ''', ''DD-MM-YYYY'') AND TO_DATE(''' || p_todate || ''', ''DD-MM-YYYY'')
                AND "Fee_Y_Payment"."FYP_Chq_Bounce" <> ''' || p_flag || '''
                AND "Adm_M_Student"."AMST_SOL" = ''' || v_leftflag || '''
                AND "Fee_Y_Payment"."mi_id" = ''' || p_mi_id || '''
                AND "Fee_Y_Payment"."asmay_id" = ''' || p_asmay_id || ''') AS s
                GROUP BY ROLLUP(aaa), "AMST_Id", "StudentName", "AdmNo", regno, aaa, aa, "ReceiptDetails"';
            END IF;
        ELSE
            IF p_chequedate = '0' THEN
                v_query := 'SELECT DISTINCT "AMST_Id", "AdmNo", "regno", "StudentName", aaa, aa, "ReceiptDetails", ' || v_monthyearsd1 || ' COALESCE(aa, ''' || v_total || ''') AS " ", SUM(aaa) AS "Total"
                FROM (SELECT DISTINCT "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo" AS "AdmNo", "Adm_M_Student"."AMST_RegistrationNo" AS regno,
                (COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''')) AS "StudentName",
                "Fee_Y_Payment"."FYP_Tot_Amount" AS aaa, '''' AS aa, "Fee_Y_Payment"."FYP_Tot_Amount" AS amount,
                TO_CHAR("Fee_Y_Payment"."FYP_Date", ''Month'') || TO_CHAR("Fee_Y_Payment"."FYP_Date", ''YYYY'') AS monthyear,
                (''' || v_recno || ''' || '' '' || CAST("FYP_Receipt_No" AS TEXT) || '' '' || ''' || v_Date || ''' || TO_CHAR("FYP_Date", ''DD-MM-YYYY'')) AS "ReceiptDetails"
                FROM "Adm_School_Y_Student"
                INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
                INNER JOIN "Fee_Y_Payment_School_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
                INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
                WHERE "Fee_Y_Payment"."FYP_Id" IN (SELECT "Fee_T_Payment"."FYP_Id"
                FROM "Fee_Master_Amount"
                INNER JOIN "Fee_T_Payment" ON "Fee_Master_Amount"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
                INNER JOIN "Fee_Yearly_Group_Head_Mapping" ON "Fee_Master_Amount"."FMH_Id" = "Fee_Yearly_Group_Head_Mapping"."FMH_Id"
                INNER JOIN "Fee_Yearly_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id"
                WHERE "Fee_Yearly_Group"."FMG_Id" IN (' || p_groupids || '))
                AND TO_DATE("Fee_Y_Payment"."FYP_Date"::TEXT, ''DD-MM-YYYY'') BETWEEN TO_DATE(''' || p_fromdate || ''', ''DD-MM-YYYY'') AND TO_DATE(''' || p_todate || ''', ''DD-MM-YYYY'')
                AND "Fee_Y_Payment"."FYP_Chq_Bounce" <> ''' || p_flag || '''
                AND "Fee_Y_Payment"."mi_id" = ' || p_mi_id || '
                AND "Fee_Y_Payment"."asmay_id" = ' || p_asmay_id || '
                AND "Adm_M_Student"."AMST_SOL" = ''' || v_leftflag || ''') AS s
                GROUP BY ROLLUP(aaa), "AMST_Id", "StudentName", "AdmNo", regno, aaa, aa, "ReceiptDetails"';
            ELSE
                v_query := 'SELECT DISTINCT "AMST_Id", "AdmNo", "regno", "StudentName", aaa, aa, "ReceiptDetails", ' || v_monthyearsd1 || ' COALESCE(aa, ''' || v_total || ''') AS " ", SUM(aaa) AS "Total"
                FROM (SELECT DISTINCT "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo" AS "AdmNo", "Adm_M_Student"."AMST_RegistrationNo" AS regno,
                (COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''')) AS "StudentName",
                "Fee_Y_Payment"."FYP_Tot_Amount" AS aaa, '''' AS aa, "Fee_Y_Payment"."FYP_Tot_Amount" AS amount,
                TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''Month'') || TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''YYYY'') AS monthyear,
                (''' || v_recno || ''' || '' '' || CAST("FYP_Receipt_No" AS TEXT) || '' '' || ''' || v_Date || ''' || TO_CHAR("FYP_DD_Cheque_Date", ''DD-MM-YYYY'')) AS "ReceiptDetails"
                FROM "Adm_School_Y_Student"
                INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
                INNER JOIN "Fee_Y_Payment_School_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
                INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
                WHERE "Fee_Y_Payment"."FYP_Id" IN (SELECT "Fee_T_Payment"."FYP_Id"
                FROM "Fee_Master_Amount"
                INNER JOIN "Fee_T_Payment" ON "Fee_Master_Amount"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
                INNER JOIN "Fee_Yearly_Group_Head_Mapping" ON "Fee_Master_Amount"."FMH_Id" = "Fee_Yearly_Group_Head_Mapping"."FMH_Id"
                INNER JOIN "Fee_Yearly_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id"
                WHERE "Fee_Yearly_Group"."FMG_Id" IN (' || p_groupids || '))
                AND "Fee_Y_Payment"."FYP_DD_Cheque_Date"::DATE BETWEEN TO_DATE(''' || p_fromdate || ''', ''DD-MM-YYYY'') AND TO_DATE(''' || p_todate || ''', ''DD-MM-YYYY'')
                AND "Fee_Y_Payment"."FYP_Chq_Bounce" <> ''' || p_flag || '''
                AND "Fee_Y_Payment"."mi_id" = ' || p_mi_id || '
                AND "Fee_Y_Payment"."asmay_id" = ' || p_asmay_id || '
                AND "Adm_M_Student"."AMST_SOL" = ''' || v_leftflag || ''') AS s
                GROUP BY ROLLUP(aaa), "AMST_Id", "StudentName", "AdmNo", regno, aaa, aa, "ReceiptDetails"';
            END IF;
        END IF;
    ELSE
        IF p_term_group = 'T' THEN
            IF p_chequedate = '0' THEN
                v_query := 'SELECT DISTINCT "AMST_Id", "AdmNo", "regno", "StudentName", aaa, aa, "ReceiptDetails", ' || v_monthyearsd1 || ' COALESCE(aa, ''' || v_total || ''') AS " ", SUM(aaa) AS "Total"
                FROM (SELECT DISTINCT "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo" AS "AdmNo", "Adm_M_Student"."AMST_RegistrationNo" AS regno,
                (COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''')) AS "StudentName",
                "Fee_Y_Payment"."FYP_Tot_Amount" AS aaa, '''' AS aa, "Fee_Y_Payment"."FYP_Tot_Amount" AS amount,
                TO_CHAR("Fee_Y_Payment"."FYP_Date", ''Month'') || TO_CHAR("Fee_Y_Payment"."FYP_Date", ''YYYY'') AS monthyear,
                (''' || v_recno || ''' || '' '' || CAST("FYP_Receipt_No" AS TEXT) || '' '' || ''' || v_Date || ''' || TO_CHAR("FYP_Date", ''DD-MM-YYYY'')) AS "ReceiptDetails"
                FROM "Fee_Y_Payment"
                INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id"
                INNER JOIN "Fee_Master_Terms_FeeHeads" INNER JOIN "Fee_Student_Status" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
                INNER JOIN "Adm_School_Y_Student" INNER JOIN "Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
                ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
                ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
                WHERE "Fee_Y_Payment"."FYP_Id" IN (SELECT DISTINCT "Fee_T_Payment"."FYP_Id"
                FROM "Fee_Y_Payment_School_Student"
                INNER JOIN "Fee_T_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_T_Payment"."FYP_Id"
                INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
                INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
                AND "Fee_Master_Terms_FeeHeads"."FTI_Id" = "Fee_Student_Status"."FTI_Id"
                WHERE "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || p_termids || ')
                AND "Adm_School_Y_Student"."AMST_Id" = ''' || p_amstid || '''
                AND TO_DATE("Fee_Y_Payment"."FYP_Date"::TEXT, ''DD-MM-YYYY'') BETWEEN TO_DATE(''' || p_fromdate || ''', ''DD-MM-YYYY'') AND TO_DATE(''' || p_todate || ''', ''DD-MM-YYYY'')
                AND "Fee_Y_Payment"."FYP_Chq_Bounce" <> ''' || p_flag || '''
                AND "Adm_M_Student"."AMST_SOL" = ''' || v_leftflag || '''
                AND "Fee_Y_Payment"."mi_id" = ' || p_mi_id || '
                AND "Fee_Y_Payment"."asmay_id" = ' || p_asmay_id || ')) AS s
                GROUP BY ROLLUP(aaa), "AMST_Id", "StudentName", "AdmNo", regno, aaa, aa, "ReceiptDetails"';
            ELSE
                v_query := 'SELECT DISTINCT "AMST_Id", "AdmNo", "regno", "StudentName", aaa, aa, "ReceiptDetails", ' || v_monthyearsd1 || ' COALESCE(aa, ''' || v_total || ''') AS " ", SUM(aaa) AS "Total"
                FROM (SELECT DISTINCT "Adm_M_Student"."AMST_Id", "Adm_M_Student"."AMST_AdmNo" AS "AdmNo", "Adm_M_Student"."AMST_RegistrationNo" AS regno,
                (COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''')) AS "StudentName",
                "Fee_Y_Payment"."FYP_Tot_Amount" AS aaa, '''' AS aa, "Fee_Y_Payment"."FYP_Tot_Amount" AS amount,
                TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''Month'') || TO_CHAR("Fee_Y_Payment"."FYP_DD_Cheque_Date", ''YYYY'') AS monthyear,
                (''' || v_recno || ''' || '' '' || CAST("FYP_Receipt_No" AS TEXT) || '' '' || ''' || v_Date || ''' || TO_CHAR("FYP_DD_Cheque_Date", ''DD-MM-YYYY'')) AS "ReceiptDetails"
                FROM "Fee_Y_Payment"
                INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_