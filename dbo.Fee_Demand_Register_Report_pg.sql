CREATE OR REPLACE FUNCTION "dbo"."Fee_Demand_Register_Report" (
    p_mi_id BIGINT,
    p_asmay_Id BIGINT,
    p_asmcl_id BIGINT,
    p_amsc_id BIGINT,
    p_amst_id BIGINT,
    p_fmgg_id TEXT,
    p_fmg_id TEXT,
    p_date VARCHAR(10),
    p_fromdate VARCHAR(10),
    p_todate VARCHAR(10),
    p_type VARCHAR(10),
    p_Stu_type VARCHAR(50),
    p_newstud VARCHAR(10)
)
RETURNS TABLE (
    "AMST_Id" VARCHAR(500),
    "StudentName" VARCHAR(400),
    "FeeName" VARCHAR(400),
    "Adm_no" VARCHAR(500)
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_aa TEXT;
    v_where_condition TEXT;
    v_sqlquery TEXT;
    v_FeeName TEXT;
    v_FT_Name TEXT;
    v_FName TEXT;
    v_TName TEXT;
    v_columnname VARCHAR(50);
    v_sqlquerycolumn VARCHAR(400);
    v_count INT;
    v_Feenametemp VARCHAR(500);
    v_Studentnametemp VARCHAR(500);
    v_amst_id_temp VARCHAR(500);
    v_paidamount_temp VARCHAR(500);
    v_InstName_temp VARCHAR(500);
    v_admission_no VARCHAR(500);
    v_columnname1 VARCHAR(50);
    v_sqlquerycolumn1 VARCHAR(400);
    v_count1 INT;
    v_Feenametemp1 VARCHAR(500);
    v_Studentnametemp1 VARCHAR(500);
    v_amst_id_temp1 VARCHAR(500);
    v_paidamount_temp1 VARCHAR(500);
    v_InstName_temp1 VARCHAR(500);
    v_admission_no1 VARCHAR(500);
    v_InstName_Test1 VARCHAR(100);
    v_InstName_Test2 VARCHAR(100);
    v_condition TEXT;
    v_script TEXT;
    v_script1 TEXT;
    v_script2 TEXT;
    v_script22 TEXT;
    v_script3 TEXT;
    v_script33 TEXT;
    v_count_temp BIGINT;
    v_count_temp1 BIGINT;
    rec RECORD;
    rec2 RECORD;
BEGIN

    v_sqlquerycolumn1 := '';
    v_count1 := 0;
    v_sqlquerycolumn := '';
    v_count := 0;

    IF p_newstud = '1' THEN
        v_condition := 'and "Adm_M_Student"."ASMAY_Id"=' || p_asmay_Id::TEXT || '';
    ELSE
        v_condition := 'and "dbo"."Fee_Y_Payment"."ASMAY_ID"=' || p_asmay_Id::TEXT || '';
    END IF;

    IF p_fromdate != '' AND p_todate != '' THEN
        v_where_condition := ' and "FYP_Date"::date between TO_DATE(''' || p_fromdate || ''', ''DD-MM-YYYY'') and TO_DATE(''' || p_todate || ''', ''DD-MM-YYYY'')';
    ELSIF p_date != '' THEN
        v_where_condition := ' and "FYP_Date"::date = TO_DATE(''' || p_date || ''', ''DD-MM-YYYY'')';
    ELSE
        v_where_condition := '';
    END IF;

    IF p_type = 'All' THEN
        IF p_ASMCL_Id <> 0 THEN
            v_sqlquery := 'SELECT DISTINCT (COALESCE("AMST_FirstName",'''') || ''  '' || COALESCE("AMST_MiddleName",'''') || ''  '' || COALESCE("AMST_LastName",'''')) AS "StudentName", "Adm_M_Student"."AMST_Admno" AS "admno", "Fee_Master_Head"."FMH_FeeName" AS "FeeName", "Fee_T_Installment"."FTI_Name" AS "InstName", "FSS_TotalToBePaid" AS "TotalToBePaid", "FSS_ToBePaid" As "ToBePaid", "Fee_T_Payment"."FTP_Paid_Amt" AS "paidAmount", "Fee_Y_Payment_School_Student"."AMST_Id"
FROM "dbo"."Fee_Master_Amount" 
INNER JOIN "dbo"."Fee_Student_Status" ON "Fee_Master_Amount"."FMA_Id" = "Fee_Student_Status"."FMA_Id" and "Fee_Student_Status"."MI_Id"=' || p_mi_id::TEXT || ' and "Fee_Student_Status"."ASMAY_Id"=' || p_asmay_Id::TEXT || ' and "Fee_Master_Amount"."MI_Id"=' || p_mi_id::TEXT || ' and "Fee_Master_Amount"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" and "Fee_Master_Group"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "Fee_Master_Group"."FMG_Id" = "Fee_Master_Group_Grouping_Groups"."FMG_Id" 
INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "Fee_Master_Group_Grouping_Groups"."FMGG_Id" = "Fee_Master_Group_Grouping"."FMGG_Id" 
INNER JOIN "dbo"."Fee_Yearly_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id" and "Fee_Student_Status"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id" and "Fee_Yearly_Group"."MI_Id"=' || p_mi_id::TEXT || ' and "Fee_Yearly_Group"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="Fee_Student_Status"."FMH_Id" and "Fee_Master_Head"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" and "Fee_Y_Payment_School_Student"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment"."fyp_id"="Fee_Y_Payment_School_Student"."fyp_id" 
INNER JOIN "dbo"."Adm_m_student" ON "Adm_m_student"."AMST_Id"="Fee_Y_Payment_School_Student"."AMST_Id" and "Adm_m_student"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id"="Fee_Y_Payment"."FYP_Id" and "Fee_T_Payment"."FMA_Id"="Fee_Master_Amount"."FMA_Id"
INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id"="Fee_Student_Status"."FTI_Id" and "Fee_T_Installment"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id" and "Adm_School_M_Academic_Year"."MI_Id"=' || p_mi_id::TEXT || ' and "Adm_School_M_Academic_Year"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Adm_School_Y_Student" ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" and "Adm_School_Y_Student"."AMST_Id"="Adm_m_student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
AND POSITION('','' || "AMST_SOL" || '','' IN '','' || ''' || p_Stu_type || ''' || '','') > 0
INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id" and "Adm_School_M_Class"."MI_Id"=' || p_mi_id::TEXT || '
where ("Fee_Student_Status"."FMG_Id" IS NOT NULL) and "Fee_Y_Payment"."mi_id"=' || p_mi_id::TEXT || '
and "Adm_School_Y_Student"."ASMCL_Id"=' || p_asmcl_id::TEXT || ' and "Fee_Master_Group_Grouping"."FMGG_Id" in (' || p_fmgg_id || ') and "Fee_Master_Group"."FMG_Id" in (' || p_fmg_id || ') ' || v_where_condition || ' ' || v_condition || ' LIMIT 100';
        ELSIF p_ASMCL_Id = 0 OR p_ASMCL_Id::TEXT = '' THEN
            v_sqlquery := 'SELECT DISTINCT (COALESCE("AMST_FirstName",'''') || ''  '' || COALESCE("AMST_MiddleName",'''') || ''  '' || COALESCE("AMST_LastName",'''')) AS "StudentName", "Adm_M_Student"."AMST_Admno" AS "admno", "Fee_Master_Head"."FMH_FeeName" AS "FeeName", "Fee_T_Installment"."FTI_Name" AS "InstName", "FSS_TotalToBePaid" AS "TotalToBePaid", "FSS_ToBePaid" As "ToBePaid", "Fee_T_Payment"."FTP_Paid_Amt" AS "paidAmount", "Fee_Y_Payment_School_Student"."AMST_Id"
FROM "dbo"."Fee_Master_Amount" 
INNER JOIN "dbo"."Fee_Student_Status" ON "Fee_Master_Amount"."FMA_Id" = "Fee_Student_Status"."FMA_Id" and "Fee_Student_Status"."MI_Id"=' || p_mi_id::TEXT || ' and "Fee_Student_Status"."ASMAY_Id"=' || p_asmay_Id::TEXT || ' and "Fee_Master_Amount"."MI_Id"=' || p_mi_id::TEXT || ' and "Fee_Master_Amount"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" and "Fee_Master_Group"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "Fee_Master_Group"."FMG_Id" = "Fee_Master_Group_Grouping_Groups"."FMG_Id" 
INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "Fee_Master_Group_Grouping_Groups"."FMGG_Id" = "Fee_Master_Group_Grouping"."FMGG_Id" 
INNER JOIN "dbo"."Fee_Yearly_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id" and "Fee_Student_Status"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id" and "Fee_Yearly_Group"."MI_Id"=' || p_mi_id::TEXT || ' and "Fee_Yearly_Group"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="Fee_Student_Status"."FMH_Id" and "Fee_Master_Head"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" and "Fee_Y_Payment_School_Student"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment"."fyp_id"="Fee_Y_Payment_School_Student"."fyp_id" 
INNER JOIN "dbo"."Adm_m_student" ON "Adm_m_student"."AMST_Id"="Fee_Y_Payment_School_Student"."AMST_Id" and "Adm_m_student"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id"="Fee_Y_Payment"."FYP_Id" and "Fee_T_Payment"."FMA_Id"="Fee_Master_Amount"."FMA_Id"
INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id"="Fee_Student_Status"."FTI_Id" and "Fee_T_Installment"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id" and "Adm_School_M_Academic_Year"."MI_Id"=' || p_mi_id::TEXT || ' and "Adm_School_M_Academic_Year"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Adm_School_Y_Student" ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" and "Adm_School_Y_Student"."AMST_Id"="Adm_m_student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
AND POSITION('','' || "AMST_SOL" || '','' IN '','' || ''' || p_Stu_type || ''' || '','') > 0
INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id" and "Adm_School_M_Class"."MI_Id"=' || p_mi_id::TEXT || '
where ("Fee_Student_Status"."FMG_Id" IS NOT NULL) and "Fee_Y_Payment"."mi_id"=' || p_mi_id::TEXT || '
and "Fee_Master_Group_Grouping"."FMGG_Id" in (' || p_fmgg_id || ') and "Fee_Master_Group"."FMG_Id" in (' || p_fmg_id || ') ' || v_where_condition || ' ' || v_condition || ' LIMIT 100';
        END IF;

        DROP TABLE IF EXISTS temp_tablevarr;
        CREATE TEMP TABLE temp_tablevarr("StudentName" VARCHAR(200), "admno" VARCHAR(200), "FeeName" VARCHAR(200), "InstName" VARCHAR(200), "TotalToBePaid" DECIMAL, "ToBePaid" DECIMAL, "paidAmount" DECIMAL, "AMST_Id" BIGINT);
        EXECUTE 'INSERT INTO temp_tablevarr SELECT * FROM (' || v_sqlquery || ') AS subq';

        DROP TABLE IF EXISTS temptable1;
        CREATE TEMP TABLE temptable1("AMST_Id" VARCHAR(500), "StudentName" VARCHAR(400), "FeeName" VARCHAR(400), "Adm_no" VARCHAR(500));

        FOR rec IN SELECT DISTINCT "InstName" FROM temp_tablevarr GROUP BY "InstName" LOOP
            v_columnname1 := rec."InstName";
            v_script1 := 'ALTER TABLE temptable1 ADD COLUMN "' || v_columnname1 || '" VARCHAR(100)';
            EXECUTE v_script1;
        END LOOP;

        FOR rec IN SELECT DISTINCT "AMST_Id", "StudentName", "FeeName", "admno", "InstName" FROM temp_tablevarr GROUP BY "AMST_Id", "StudentName", "FeeName", "admno", "InstName" LOOP
            v_amst_id_temp1 := rec."AMST_Id"::TEXT;
            v_Studentnametemp1 := rec."StudentName";
            v_Feenametemp1 := rec."FeeName";
            v_admission_no1 := rec."admno";
            v_InstName_Test1 := rec."InstName";
            v_count_temp1 := 0;

            FOR rec2 IN SELECT "InstName", "paidAmount" FROM temp_tablevarr WHERE "FeeName" = v_Feenametemp1 AND "AMST_Id"::TEXT = v_amst_id_temp1 LOOP
                v_InstName_temp1 := rec2."InstName";
                v_paidamount_temp1 := rec2."paidAmount"::TEXT;
                v_count_temp1 := v_count_temp1 + 1;

                IF v_count_temp1 = 1 THEN
                    v_script22 := 'INSERT INTO temptable1 ("AMST_Id","StudentName","FeeName","Adm_no","' || v_InstName_temp1 || '") VALUES (''' || v_amst_id_temp1 || ''',''' || REPLACE(v_Studentnametemp1, ' ', ' ') || ''',''' || REPLACE(v_Feenametemp1, ' ', '') || ''',''' || REPLACE(v_admission_no1, ' ', '') || ''',''' || REPLACE(v_paidamount_temp1, ' ', '') || ''')';
                    EXECUTE v_script22;
                ELSE
                    v_script33 := 'UPDATE temptable1 SET "' || v_InstName_temp1 || '"=' || REPLACE(v_paidamount_temp1, ' ', '') || ' WHERE "AMST_Id"=''' || v_amst_id_temp1 || ''' AND "FeeName"=''' || REPLACE(v_Feenametemp1, ' ', '') || '''';
                    EXECUTE v_script33;
                END IF;
            END LOOP;
        END LOOP;

        RETURN QUERY SELECT * FROM temptable1;

    ELSIF p_type = 'Indi' THEN
        IF p_asmcl_id <> 0 THEN
            v_sqlquery := 'SELECT DISTINCT (COALESCE("AMST_FirstName",'''') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''')) AS "StudentName", "Adm_M_Student"."AMST_Admno" AS "admno", "Fee_Master_Head"."FMH_FeeName" AS "FeeName", "Fee_T_Installment"."FTI_Name" AS "InstName", "FSS_TotalToBePaid" AS "TotalToBePaid", "FSS_ToBePaid" As "ToBePaid", "Fee_T_Payment"."FTP_Paid_Amt" AS "paidAmount", "Fee_Y_Payment_School_Student"."AMST_Id"
FROM "dbo"."Fee_Master_Amount" 
INNER JOIN "dbo"."Fee_Student_Status" ON "Fee_Master_Amount"."FMA_Id" = "Fee_Student_Status"."FMA_Id" and "Fee_Student_Status"."MI_Id"=' || p_mi_id::TEXT || ' and "Fee_Student_Status"."ASMAY_Id"=' || p_asmay_Id::TEXT || ' and "Fee_Master_Amount"."MI_Id"=' || p_mi_id::TEXT || ' and "Fee_Master_Amount"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" and "Fee_Master_Group"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "Fee_Master_Group"."FMG_Id" = "Fee_Master_Group_Grouping_Groups"."FMG_Id" 
INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "Fee_Master_Group_Grouping_Groups"."FMGG_Id" = "Fee_Master_Group_Grouping"."FMGG_Id" 
INNER JOIN "dbo"."Fee_Yearly_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id" and "Fee_Student_Status"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id" and "Fee_Yearly_Group"."MI_Id"=' || p_mi_id::TEXT || ' and "Fee_Yearly_Group"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="Fee_Student_Status"."FMH_Id" and "Fee_Master_Head"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" and "Fee_Y_Payment_School_Student"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment"."fyp_id"="Fee_Y_Payment_School_Student"."fyp_id" 
INNER JOIN "dbo"."Adm_m_student" ON "Adm_m_student"."AMST_Id"="Fee_Y_Payment_School_Student"."AMST_Id" and "Adm_m_student"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id"="Fee_Y_Payment"."FYP_Id" and "Fee_T_Payment"."FMA_Id"="Fee_Master_Amount"."FMA_Id"
INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id"="Fee_Student_Status"."FTI_Id" and "Fee_T_Installment"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id" and "Adm_School_M_Academic_Year"."MI_Id"=' || p_mi_id::TEXT || ' and "Adm_School_M_Academic_Year"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Adm_School_Y_Student" ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" and "Adm_School_Y_Student"."AMST_Id"="Adm_m_student"."AMST_Id" and "Adm_School_Y_Student"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
AND POSITION('','' || "AMST_SOL" || '','' IN '','' || ''' || p_Stu_type || ''' || '','') > 0
INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id"="Adm_School_Y_Student"."ASMCL_Id" and "Adm_School_M_Class"."MI_Id"=' || p_mi_id::TEXT || '
WHERE ("Fee_Student_Status"."FMG_Id" IS NOT NULL) 
AND "Fee_Y_Payment"."mi_id"=' || p_mi_id::TEXT || '
AND "Adm_School_Y_Student"."ASMCL_Id"=' || p_asmcl_id::TEXT || '
AND "Fee_Master_Group_Grouping"."FMGG_Id" in (' || p_fmgg_id || ') and "Fee_Master_Group"."FMG_Id" in (' || p_fmg_id || ') ' || v_where_condition || ' ' || v_condition || ' LIMIT 100';
        ELSE
            v_sqlquery := 'SELECT DISTINCT (COALESCE("AMST_FirstName",'''') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''')) AS "StudentName", "Adm_M_Student"."AMST_Admno" AS "admno", "Fee_Master_Head"."FMH_FeeName" AS "FeeName", "Fee_T_Installment"."FTI_Name" AS "InstName", "FSS_TotalToBePaid" AS "TotalToBePaid", "FSS_ToBePaid" As "ToBePaid", "Fee_T_Payment"."FTP_Paid_Amt" AS "paidAmount", "Fee_Y_Payment_School_Student"."AMST_Id"
FROM "dbo"."Fee_Master_Amount" 
INNER JOIN "dbo"."Fee_Student_Status" ON "Fee_Master_Amount"."FMA_Id" = "Fee_Student_Status"."FMA_Id" and "Fee_Student_Status"."MI_Id"=' || p_mi_id::TEXT || ' and "Fee_Student_Status"."ASMAY_Id"=' || p_asmay_Id::TEXT || ' and "Fee_Master_Amount"."MI_Id"=' || p_mi_id::TEXT || ' and "Fee_Master_Amount"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id"="Fee_Student_Status"."FMG_Id" and "Fee_Master_Group"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "Fee_Master_Group"."FMG_Id" = "Fee_Master_Group_Grouping_Groups"."FMG_Id" 
INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "Fee_Master_Group_Grouping_Groups"."FMGG_Id" = "Fee_Master_Group_Grouping"."FMGG_Id" 
INNER JOIN "dbo"."Fee_Yearly_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id" and "Fee_Student_Status"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id" and "Fee_Yearly_Group"."MI_Id"=' || p_mi_id::TEXT || ' and "Fee_Yearly_Group"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="Fee_Student_Status"."FMH_Id" and "Fee_Master_Head"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."AMST_Id"="Fee_Student_Status"."AMST_Id" and "Fee_Y_Payment_School_Student"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment"."fyp_id"="Fee_Y_Payment_School_Student"."fyp_id" 
INNER JOIN "dbo"."Adm_m_student" ON "Adm_m_student"."AMST_Id"="Fee_Y_Payment_School_Student"."AMST_Id" and "Adm_m_student"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id"="Fee_Y_Payment"."FYP_Id" and "Fee_T_Payment"."FMA_Id"="Fee_Master_Amount"."FMA_Id"
INNER JOIN "dbo"."Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id"="Fee_Student_Status"."FTI_Id" and "Fee_T_Installment"."MI_Id"=' || p_mi_id::TEXT || '
INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id"="Fee_Student_Status"."ASMAY_Id" and "Adm_School_M_Academic_Year"."MI_Id"=' || p_mi_id::TEXT || ' and "Adm_School_M_Academic_Year"."ASMAY_Id"=' || p_asmay_Id::TEXT || '
INNER JOIN "dbo"."Adm_School_Y_Student" ON "Fee_Student_Status"."AMST_Id" = "