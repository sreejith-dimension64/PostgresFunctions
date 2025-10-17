CREATE OR REPLACE FUNCTION "dbo"."Fee_ClassWise_Settlement_Report_userid"(
    "p_MI_Id" BIGINT,
    "p_ASMAY_Id" BIGINT,
    "p_Fromdate" TEXT,
    "p_Todate" TEXT,
    "p_userid" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "StudentName" TEXT,
    "ClassName" TEXT,
    "SectionName" TEXT,
    "AdmNo" TEXT,
    "UTR_No" TEXT,
    "Transactionid" TEXT,
    "PaymentId" BIGINT,
    "FYPPST_Settlement_Date" TEXT,
    "FYP_Date" TEXT,
    "result_data" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_aa" TEXT;
    "v_where_condition" TEXT;
    "v_sqlquery" TEXT;
    "v_FeeName" TEXT;
    "v_FT_Name" TEXT;
    "v_FName" TEXT;
    "v_TName" TEXT;
    "v_columnname" VARCHAR(50);
    "v_sqlquerycolumn" TEXT;
    "v_count" INT;
    "v_Feenametemp" VARCHAR(500);
    "v_Studentnametemp" VARCHAR(500);
    "v_amst_id_temp" VARCHAR(500);
    "v_paidamount_temp" VARCHAR(500);
    "v_InstName_temp" VARCHAR(500);
    "v_admission_no" VARCHAR(500);
    "v_columnname1" VARCHAR(50);
    "v_sqlquerycolumn1" TEXT;
    "v_count1" INT;
    "v_Feenametemp1" VARCHAR(500);
    "v_Studentnametemp1" VARCHAR(500);
    "v_amst_id_temp1" VARCHAR(500);
    "v_paidamount_temp1" VARCHAR(500);
    "v_InstName_temp1" VARCHAR(500);
    "v_admission_no1" VARCHAR(500);
    "v_InstName_Test1" VARCHAR(100);
    "v_InstName_Test2" VARCHAR(100);
    "v_condition" VARCHAR(100);
    "v_Classnametemp1" VARCHAR(100);
    "v_Sectionnametemp1" VARCHAR(100);
    "v_ReceiptNotemp1" VARCHAR(100);
    "v_fypdatetemp1" VARCHAR(30);
    "v_chequenotemp1" VARCHAR(100);
    "v_Classname_temp1" VARCHAR(100);
    "v_Sectionname_temp1" VARCHAR(100);
    "v_ReceiptNo_temp1" VARCHAR(100);
    "v_fypdate_temp1" VARCHAR(30);
    "v_chequeno_temp1" VARCHAR(100);
    "v_SQLQuery2" TEXT;
    "v_PivotColumnNames" TEXT;
    "v_PivotSelectColumnNames" TEXT;
    "v_sqlquery1" TEXT;
    "v_newsqlqueryy" TEXT;
BEGIN

    DROP TABLE IF EXISTS "FeeSettementReport";
    DROP TABLE IF EXISTS "FeeSettementReport_1";
    DROP TABLE IF EXISTS "FeeSettementReport_New";
    DROP TABLE IF EXISTS "FeeHead_Temp";

    IF "p_Fromdate" != '' AND "p_Todate" != '' THEN
        "v_where_condition" := ' AND "FYPPST_Settlement_Date" BETWEEN TO_TIMESTAMP(''' || "p_Fromdate" || ''', ''DD/MM/YYYY HH12:MI:SS AM'') AND TO_TIMESTAMP(''' || "p_Todate" || ''', ''DD/MM/YYYY HH12:MI:SS AM'') ';
    ELSE
        "v_where_condition" := '';
    END IF;

    "v_sqlquery" := '
    CREATE TEMP TABLE "FeeSettementReport" AS
    SELECT "Adm_M_Student"."AMST_Id" AS "AMST_Id",
           (COALESCE("AMST_FirstName",'''') || ''  '' || COALESCE("AMST_MiddleName",'''') || ''  '' || COALESCE("AMST_LastName",'''')) AS "StudentName",
           "ASMCL_ClassName" AS "ClassName",
           "ASMC_SectionName" AS "SectionName",
           "AMST_AdmNo" AS "AdmNo",
           "FYP_Receipt_No" AS "UTR_No",
           "Fee_Master_Head"."FMH_FeeName" AS "FeeName",
           "Fee_T_Payment"."FTP_Paid_Amt" AS "paidAmount",
           "fyp_transaction_id" AS "Transactionid",
           "FYPPSD_Payment_Id" AS "PaymentId",
           "FYPPST_Settlement_Date",
           "FYP_Date"
    FROM "Adm_M_Student"
    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
           AND "AMST_SOL" = ''S'' AND "AMST_ActiveFlag" = 1 AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
           AND "Fee_Y_Payment_School_Student"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
    INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id"
    INNER JOIN "Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id"
    INNER JOIN "Fee_Payment_Settlement_Details" ON "Fee_Payment_Settlement_Details"."FYPPSD_PAYU_Id" = "Fee_Y_Payment"."FYP_PaymentReference_Id"
    INNER JOIN "Fee_Payment_Overall_Settlement_Details" ON "Fee_Payment_Overall_Settlement_Details"."FYPPST_Id" = "Fee_Payment_Settlement_Details"."FYPPST_Id"
           AND "Fee_Payment_Overall_Settlement_Details"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" 
           AND "Fee_Payment_Overall_Settlement_Details"."User_id" = "Fee_Y_Payment"."user_id"
    INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
           AND "Fee_Student_Status"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
           AND "Fee_Student_Status"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id"
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
    WHERE "Fee_Y_Payment"."mi_id" = ' || "p_MI_Id"::TEXT || ' 
          AND "Adm_School_Y_Student"."ASMAY_Id" = ' || "p_ASMAY_Id"::TEXT || '
          AND "Fee_Y_Payment"."user_Id" IN (' || "p_userid" || ') ' || "v_where_condition";

    EXECUTE "v_sqlquery";

    "v_sqlquery1" := '
    CREATE TEMP TABLE "FeeSettementReport_1" AS
    SELECT "Adm_M_Student"."AMST_Id" AS "AMST_Id",
           (COALESCE("AMST_FirstName",'''') || ''  '' || COALESCE("AMST_MiddleName",'''') || ''  '' || COALESCE("AMST_LastName",'''')) AS "StudentName",
           "ASMCL_ClassName" AS "ClassName",
           "ASMC_SectionName" AS "SectionName",
           "AMST_AdmNo" AS "AdmNo",
           "FYP_Receipt_No" AS "UTR_No",
           "Fee_Master_Head"."FMH_FeeName" AS "FeeName",
           "Fee_T_Payment"."FTP_Paid_Amt" AS "paidAmount",
           "fyp_transaction_id" AS "Transactionid",
           "FYPPSD_Payment_Id" AS "PaymentId",
           "FYPPST_Settlement_Date",
           "FYP_Date"
    FROM "Adm_M_Student"
    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" 
           AND "AMST_SOL" != ''S'' AND "AMST_ActiveFlag" = 0 AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 0
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    INNER JOIN "Fee_Y_Payment_School_Student" ON "Fee_Y_Payment_School_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "AY" ON "AY"."MI_Id" = "Adm_M_Student"."MI_Id" 
           AND "AY"."ASMAY_Id" = "Adm_M_Student"."ASMAY_Id"
           AND "Fee_Y_Payment_School_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "Fee_Y_Payment" ON "Fee_Y_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id"
    INNER JOIN "Fee_T_Payment" ON "Fee_T_Payment"."FYP_Id" = "Fee_Y_Payment_School_Student"."FYP_Id"
    INNER JOIN "Fee_Payment_Settlement_Details" ON "Fee_Payment_Settlement_Details"."FYPPSD_PAYU_Id" = "Fee_Y_Payment"."FYP_PaymentReference_Id"
    INNER JOIN "Fee_Payment_Overall_Settlement_Details" ON "Fee_Payment_Overall_Settlement_Details"."FYPPST_Id" = "Fee_Payment_Settlement_Details"."FYPPST_Id"
           AND "Fee_Payment_Overall_Settlement_Details"."User_id" = "Fee_Y_Payment"."user_id"
    INNER JOIN "Fee_Student_Status" ON "Fee_Student_Status"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
           AND "Fee_Student_Status"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
    WHERE "Fee_Y_Payment"."mi_id" = ' || "p_MI_Id"::TEXT || ' 
          AND "Fee_Y_Payment"."user_Id" IN (' || "p_userid" || ') 
          AND "Adm_M_Student"."ASMAY_ID" = 2 ' || "v_where_condition";

    EXECUTE "v_sqlquery1";

    CREATE TEMP TABLE "FeeSettementReport_New" AS
    SELECT * FROM "FeeSettementReport"
    UNION ALL
    SELECT * FROM "FeeSettementReport_1";

    "v_newsqlqueryy" := 'CREATE TEMP TABLE "FeeHead_Temp" AS
    SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" AS "FeeName"
    FROM "Fee_Yearly_Group_Head_Mapping"
    INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
    INNER JOIN "Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
    INNER JOIN "Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID" = "Fee_Yearly_Group_Head_Mapping"."FMG_Id"
    WHERE "Fee_Yearly_Group_Head_Mapping"."MI_Id" = ' || "p_MI_Id"::TEXT || '
          AND "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id" = ' || "p_ASMAY_Id"::TEXT || '
          AND "Fee_Group_Login_Previledge"."User_Id" IN (' || "p_userid" || ')';

    EXECUTE "v_newsqlqueryy";

    SELECT STRING_AGG('"' || "FeeName" || '"', ',')
    INTO "v_PivotColumnNames"
    FROM (SELECT DISTINCT "FeeName" FROM "FeeHead_Temp") AS "PVColumns";

    SELECT STRING_AGG('COALESCE("' || "FeeName" || '", 0) AS "' || "FeeName" || '"', ',')
    INTO "v_PivotSelectColumnNames"
    FROM (SELECT DISTINCT "FeeName" FROM "FeeHead_Temp") AS "PVSelctedColumns";

    "v_SQLQuery2" := 'SELECT "AMST_Id", "StudentName", "ClassName", "SectionName", "AdmNo", "UTR_No", "Transactionid", "PaymentId",
                      TO_CHAR("FYPPST_Settlement_Date", ''DD/MM/YYYY'') AS "FYPPST_Settlement_Date",
                      TO_CHAR("FYP_Date", ''DD/MM/YYYY'') AS "FYP_Date", ' || "v_PivotSelectColumnNames" || '
                      FROM CROSSTAB(
                          ''SELECT "AMST_Id"::TEXT || ''|'' || "StudentName" || ''|'' || "ClassName" || ''|'' || "SectionName" || ''|'' || 
                                  "AdmNo" || ''|'' || "UTR_No" || ''|'' || "Transactionid" || ''|'' || "PaymentId"::TEXT || ''|'' || 
                                  TO_CHAR("FYPPST_Settlement_Date", ''''DD/MM/YYYY'''') || ''|'' || TO_CHAR("FYP_Date", ''''DD/MM/YYYY'''') AS "row_key",
                                  "FeeName", SUM("paidAmount")
                           FROM "FeeSettementReport_New"
                           GROUP BY "AMST_Id", "StudentName", "ClassName", "SectionName", "AdmNo", "UTR_No", "Transactionid", "PaymentId", 
                                    "FYPPST_Settlement_Date", "FYP_Date", "FeeName"
                           ORDER BY 1, 2'',
                          ''SELECT DISTINCT "FeeName" FROM "FeeHead_Temp" ORDER BY 1''
                      ) AS ct("row_key" TEXT, ' || "v_PivotColumnNames" || ')';

    RETURN QUERY EXECUTE "v_SQLQuery2";

END;
$$;