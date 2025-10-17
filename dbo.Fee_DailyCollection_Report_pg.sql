CREATE OR REPLACE FUNCTION "dbo"."Fee_DailyCollection_Report"(
    p_year TEXT,
    p_miid BIGINT,
    p_fromdate TEXT,
    p_todate TEXT,
    p_groupids VARCHAR,
    p_classid TEXT,
    p_allorindivflag TEXT,
    p_allorstdorothersflag TEXT,
    p_allorcorchoronlineflag TEXT,
    p_classflag TEXT
)
RETURNS SETOF REFCURSOR
LANGUAGE plpgsql
AS $$
DECLARE
    v_cols TEXT;
    v_query TEXT;
    v_monthyearsd TEXT;
    v_monthids TEXT;
    v_monthids1 TEXT;
    v_recno TEXT;
    v_Date TEXT;
    v_total TEXT;
    v_space TEXT;
    v_fmg_id VARCHAR;
    v_fmg_ids TEXT;
    v_sql TEXT;
    v_objcursor REFCURSOR;
    v_sql1 TEXT;
    v_result REFCURSOR;
    rec RECORD;
BEGIN

    v_fmg_id := '0';
    v_total := 'C';
    v_recno := 'Rece.No:';
    v_Date := '     Date:';
    v_space := ' ';
    v_fmg_ids := '';

    IF p_groupids = '0' THEN
        v_fmg_ids := '';
        FOR rec IN 
            SELECT "fmg_id" 
            FROM "Fee_Master_Group" 
            WHERE "FMG_Id" IN (
                SELECT "FMG_Id" 
                FROM "Fee_Yearly_Group" 
                WHERE "ASMAY_Id" = p_year::BIGINT
            )
        LOOP
            IF v_fmg_ids = '' THEN
                v_fmg_ids := rec."fmg_id"::TEXT;
            ELSE
                v_fmg_ids := v_fmg_ids || ',' || rec."fmg_id"::TEXT;
            END IF;
        END LOOP;
    ELSE
        v_fmg_ids := p_groupids;
    END IF;

    IF p_allorindivflag = 'all' THEN
        IF p_classflag = '1' THEN
            OPEN v_result FOR
            SELECT * FROM (
                SELECT 
                    "dbo"."Fee_Master_Head"."FMH_FeeName",
                    "dbo"."Fee_Master_Head"."FMH_Id",
                    "dbo"."Fee_Y_Payment"."FYP_Bank_Or_Cash",
                    CAST(SUM("dbo"."Fee_T_Payment"."FTP_Paid_Amt" + "dbo"."Fee_T_Payment"."FTP_Fine_Amt") AS DECIMAL(10,2)) AS amount
                FROM "dbo"."Fee_Yearly_Group_Head_Mapping" 
                INNER JOIN "dbo"."Fee_Master_Amount" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Amount"."FMH_Id"
                INNER JOIN "dbo"."Fee_T_Payment" 
                INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_T_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" 
                ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_T_Payment"."FMA_Id" 
                INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id"
                WHERE "Fee_Y_Payment"."FYP_Id" IN (
                    SELECT "dbo"."Fee_T_Payment"."FYP_Id" 
                    FROM "dbo"."Fee_Master_Amount" 
                    INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_T_Payment"."FMA_Id"
                    INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "dbo"."Fee_Master_Amount"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id"
                    INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id"
                    WHERE "dbo"."Fee_Yearly_Group"."FMG_Id"::TEXT = ANY(string_to_array(p_groupids, ','))
                )
                AND TO_DATE("FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
                GROUP BY "dbo"."Fee_Master_Head"."FMH_FeeName", "dbo"."Fee_Master_Head"."FMH_Id", "dbo"."Fee_Y_Payment"."FYP_Bank_Or_Cash"
            ) AS tab;
            RETURN NEXT v_result;
        ELSE
            OPEN v_result FOR
            SELECT * FROM (
                SELECT 
                    "dbo"."Fee_Master_Head"."FMH_FeeName",
                    "dbo"."Fee_Master_Head"."FMH_Id",
                    "dbo"."Fee_Y_Payment"."FYP_Bank_Or_Cash",
                    CAST(SUM("dbo"."Fee_T_Payment"."FTP_Paid_Amt" + "dbo"."Fee_T_Payment"."FTP_Fine_Amt") AS DECIMAL(10,2)) AS amount
                FROM "dbo"."Fee_Yearly_Group_Head_Mapping" 
                INNER JOIN "dbo"."Fee_Master_Amount" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Amount"."FMH_Id"
                INNER JOIN "dbo"."Fee_T_Payment" 
                INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_T_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" 
                ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_T_Payment"."FMA_Id" 
                INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id"
                WHERE "Fee_Y_Payment"."FYP_Id" IN (
                    SELECT "dbo"."Fee_T_Payment"."FYP_Id" 
                    FROM "dbo"."Fee_Master_Amount" 
                    INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_T_Payment"."FMA_Id"
                    INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "dbo"."Fee_Master_Amount"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id"
                    INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id"
                    WHERE "dbo"."Fee_Yearly_Group"."FMG_Id"::TEXT = ANY(string_to_array(p_groupids, ','))
                )
                AND TO_DATE("FYP_Date", 'DD/MM/YYYY') BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
                GROUP BY "dbo"."Fee_Master_Head"."FMH_FeeName", "dbo"."Fee_Master_Head"."FMH_Id", "dbo"."Fee_Y_Payment"."FYP_Bank_Or_Cash"
            ) AS tab;
            RETURN NEXT v_result;
        END IF;
    ELSIF p_allorindivflag = 'indi' THEN
        IF p_allorstdorothersflag = 'Aso' THEN
            IF p_allorcorchoronlineflag = 'Ac' THEN
                v_sql1 := 'SELECT DISTINCT "dbo"."Fee_Master_Head"."FMH_FeeName" AS monthyear 
                FROM "dbo"."Fee_Yearly_Group_Head_Mapping" 
                INNER JOIN "dbo"."Fee_Master_Amount" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Amount"."FMH_Id" 
                    AND "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Master_Amount"."FMG_Id" 
                INNER JOIN "Fee_T_Payment" ON "Fee_Master_Amount"."FMA_Id" = "Fee_T_Payment"."FMA_Id" 
                INNER JOIN "dbo"."Fee_Y_Payment" ON "dbo"."Fee_T_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_Id" 
                INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id" 
                INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id" 
                WHERE "Fee_Y_Payment"."FYP_Id" IN (
                    SELECT "dbo"."Fee_T_Payment"."FYP_Id" 
                    FROM "dbo"."Fee_Master_Amount" 
                    INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_Master_Amount"."FMA_Id" = "dbo"."Fee_T_Payment"."FMA_Id" 
                    INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "dbo"."Fee_Master_Amount"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" 
                        AND "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Master_Amount"."FMG_Id" 
                    INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" 
                    WHERE "Fee_Yearly_Group_Head_Mapping"."FMG_Id"::TEXT = ANY(string_to_array($1, '',''))
                ) 
                AND TO_DATE("FYP_Date", ''DD/MM/YYYY'') BETWEEN TO_DATE($2, ''DD/MM/YYYY'') AND TO_DATE($3, ''DD/MM/YYYY'') 
                OR ("dbo"."Fee_Y_Payment_School_Student"."AMST_Id" IS NULL OR "dbo"."Fee_Y_Payment_School_Student"."Amst_id" = 0)';

                v_monthyearsd := '';
                FOR rec IN EXECUTE v_sql1 USING p_groupids, p_fromdate, p_todate
                LOOP
                    v_monthyearsd := COALESCE(v_monthyearsd, '') || COALESCE('"' || rec.monthyear || '"' || ', ', '');
                END LOOP;
                
                IF v_monthyearsd <> '' THEN
                    v_monthyearsd := LEFT(v_monthyearsd, LENGTH(v_monthyearsd) - 1);
                END IF;

                v_query := 'SELECT * FROM (
                    SELECT DISTINCT 
                        ("dbo"."Adm_School_M_Class"."ASMCL_ClassName" || ''' || v_space || ''' || "dbo"."Adm_School_M_Section"."ASMC_SectionName") AS classec,
                        (COALESCE("dbo"."Adm_M_Student"."AMST_FirstName", '''') || ''' || v_space || ''' || COALESCE("dbo"."Adm_M_Student"."Amst_MiddleName", '''') || ''' || v_space || ''' || COALESCE("dbo"."Adm_M_Student"."Amst_LastName", '''')) AS name,
                        "Adm_M_Student"."AMST_AdmNo" AS admno,
                        "Adm_M_Student"."AMST_RegistrationNo",
                        ("dbo"."Fee_T_Payment"."FTP_Paid_Amt") AS amount,
                        ("FTP_Fine_Amt") AS "FTP_Fine_Amt",
                        (''' || v_recno || ''' || CAST("FYP_Receipt_No" AS TEXT) || ''' || v_Date || ''' || TO_CHAR("FYP_Date", ''DD/MM/YYYY'')) AS redate,
                        "dbo"."Fee_Y_Payment"."FYP_DD_Cheque_No",
                        "dbo"."Fee_Y_Payment"."FYP_Bank_Name",
                        "dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date" AS ccdate,
                        "dbo"."Fee_Y_Payment"."FYP_Tot_Amount",
                        "dbo"."Fee_Y_Payment"."FYP_Id",
                        "dbo"."Fee_Y_Payment"."FYP_Bank_Or_Cash",
                        "dbo"."Fee_Y_Payment"."FYP_Remarks",
                        "dbo"."Fee_Y_Payment_School_Student"."AMST_Id",
                        "Adm_School_Y_Student"."AMAY_RollNo",
                        "Fee_Master_Head"."FMH_FeeName" AS monthyear
                    FROM "dbo"."Fee_Y_Payment" 
                    INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id" 
                    INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Fee_Y_Payment_School_Student"."AMST_ID" = "dbo"."Adm_School_Y_Student"."AMST_Id" 
                    INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."MI_Id" = "dbo"."Fee_Y_Payment"."MI_Id" 
                        AND "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = "dbo"."Fee_Y_Payment"."ASMAY_ID" 
                    INNER JOIN "dbo"."Fee_T_Payment" ON "dbo"."Fee_T_Payment"."FYP_Id" = "dbo"."Fee_Y_Payment"."FYP_ID" 
                    INNER JOIN "dbo"."Fee_Master_Amount" ON "dbo"."Fee_T_Payment"."FMA_Id" = "dbo"."Fee_Master_Amount"."FMA_Id" 
                    INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "dbo"."Fee_Master_Amount"."FMG_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" 
                        AND "dbo"."Fee_Master_Amount"."FMH_Id" = "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" 
                    INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" 
                    INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
                    INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."AsMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id" 
                    INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id" 
                    INNER JOIN "Fee_Yearly_Class_Category_Classes" ON "Fee_Yearly_Class_Category_Classes"."AMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" 
                    INNER JOIN "dbo"."Fee_Yearly_Class_Category" ON "dbo"."Fee_Yearly_Class_Category"."FYCC_Id" = "dbo"."Fee_Yearly_Class_Category_Classes"."FYCC_Id" 
                    INNER JOIN "Fee_Master_Class_Category" ON "dbo"."Fee_Master_Class_Category"."FMCC_Id" = "dbo"."Fee_Yearly_Class_Category"."FMCC_Id" 
                    INNER JOIN "dbo"."Fee_Bank_Details" ON "dbo"."Fee_Master_Class_Category"."FMCC_ClassCategoryName" = "dbo"."Fee_Bank_Details"."Class" 
                    INNER JOIN "dbo"."Acc_Ledger" ON "dbo"."Fee_Bank_Details"."L_code" = "dbo"."Acc_Ledger"."L_Code" 
                    INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "dbo"."Fee_Master_Head"."FMH_Id"
                    WHERE (TO_DATE("dbo"."Fee_Y_Payment"."FYP_Date", ''DD/MM/YYYY'') BETWEEN TO_DATE(''' || p_fromdate || ''', ''DD/MM/YYYY'') AND TO_DATE(''' || p_todate || ''', ''DD/MM/YYYY''))
                    AND ("dbo"."Fee_Yearly_Group"."FMG_Id"::TEXT = ANY(string_to_array(''' || p_groupids || ''', '','')) ) 
                    AND "dbo"."Fee_Y_Payment"."FYP_Bank_Or_Cash" = ''' || v_total || ''' 
                    AND ("dbo"."Adm_School_M_Academic_Year"."ASMAY_Id" = ' || p_year || ') 
                    GROUP BY "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", 
                        "dbo"."Adm_M_Student"."AMST_FirstName", "dbo"."Adm_M_Student"."AMST_MiddleName", "dbo"."Adm_M_Student"."AMST_LastName", 
                        "Adm_M_Student"."AMST_AdmNo", "Fee_Y_Payment"."FYP_Receipt_No", "FYP_Date", "Adm_M_Student"."AMST_RegistrationNo", 
                        ("dbo"."Fee_T_Payment"."FTP_Paid_Amt"), ("dbo"."Fee_Y_Payment"."FYP_Receipt_No"), "dbo"."Fee_Y_Payment"."FYP_Date", 
                        "dbo"."Fee_Y_Payment"."FYP_DD_Cheque_No", "dbo"."Fee_Y_Payment"."FYP_Bank_Name", "dbo"."Fee_Y_Payment"."FYP_DD_Cheque_Date", 
                        "dbo"."Fee_Y_Payment"."FYP_Tot_Amount", "dbo"."Fee_Y_Payment"."FYP_Id", "dbo"."Fee_Y_Payment"."FYP_Bank_Or_Cash", 
                        "dbo"."Fee_Y_Payment"."FYP_Remarks", "dbo"."Fee_Y_Payment_School_Student"."AMST_Id", "FTP_Fine_Amt", 
                        "Adm_School_Y_Student"."AMAY_RollNo", "FMH_FeeName"
                ) AS c';

                IF v_monthyearsd IS NOT NULL AND v_monthyearsd <> '' THEN
                    EXECUTE v_query;
                END IF;
            END IF;
        END IF;
    END IF;

    RETURN;
    
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in Fee_DailyCollection_Report: %', SQLERRM;
        RETURN;
END;
$$;