CREATE OR REPLACE FUNCTION "dbo"."Fee_CourseWise_Settlement_Report_userid"(
    "MI_Id" VARCHAR,
    "ASMAY_Id" VARCHAR,
    "Fromdate" VARCHAR,
    "Todate" VARCHAR,
    "userid" VARCHAR
)
RETURNS TABLE (
    "AMCST_Id" BIGINT,
    "StudentName" TEXT,
    "ClassName" TEXT,
    "SectionName" TEXT,
    "AdmNo" TEXT,
    "UTR_No" TEXT,
    "Transactionid" TEXT,
    "PaymentId" TEXT,
    "FYPPST_Settlement_Date" TEXT,
    "FYP_Date" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "where_condition" VARCHAR;
    "sqlquery" TEXT;
    "SQLQuery2" TEXT;
    "PivotColumnNames" TEXT;
    "PivotSelectColumnNames" TEXT;
    "sqlquery1" TEXT;
    "newsqlqueryy" TEXT;
BEGIN

    DROP TABLE IF EXISTS "FeeSettementReportCollege_Temp";
    DROP TABLE IF EXISTS "FeeSettementReportCollege1_Temp";
    DROP TABLE IF EXISTS "FeeSettementReportCollegeNew_Temp";
    DROP TABLE IF EXISTS "FeeHeadCollege_Temp";

    IF "Fromdate" != '' AND "Todate" != '' THEN
        "where_condition" := ' and "FYPPSTC_Settlement_Date" between TO_TIMESTAMP(''' || "Fromdate" || ''', ''DD/MM/YYYY HH12:MI:SS AM'') and TO_TIMESTAMP(''' || "Todate" || ''', ''DD/MM/YYYY HH12:MI:SS AM'') ';
    ELSE
        "where_condition" := '';
    END IF;

    "sqlquery" := 'CREATE TEMP TABLE "FeeSettementReportCollege_Temp" AS 
    SELECT "Adm_m_student"."AMCST_Id" AS "AMCST_Id",
    (COALESCE("AMCST_FirstName",'''')||''  ''||COALESCE("AMCST_MiddleName",'''')||''  ''||COALESCE("AMCST_LastName",'''')) AS "StudentName",
    "AMCO_CourseName",
    "AMB_BranchName",
    "AMSE_SEMName",
    "AMCST_AdmNo" AS "AdmNo",
    "FYP_ReceiptNo" AS "UTR_No",
    "Fee_Master_Head"."FMH_FeeName" AS "FeeName",
    "FTCP_PaidAmount" AS "paidAmount",
    "FYP_Transaction_Id" AS "Transactionid",
    "FYPPSDC_Payment_Id" AS "PaymentId",
    "FYPPSTC_Settlement_Date",
    "FYP_DOE"
    FROM "CLG"."Adm_Master_College_Student"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id"="CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
        AND "AMCST_SOL"=''S'' AND "AMCST_ActiveFlag"=1 AND "CLG"."Adm_College_Yearly_Student"."ACYST_ActiveFlag"=1
    INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_Master_Course"."AMCO_Id"="CLG"."Adm_College_Yearly_Student"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id"="CLG"."Adm_College_Yearly_Student"."AMB_Id" 
        AND "CLG"."Adm_Master_Branch"."MI_Id"=' || "MI_Id" || '
    INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_Master_Semester"."AMSE_Id"="CLG"."Adm_College_Yearly_Student"."AMSE_Id" 
        AND "CLG"."Adm_Master_Semester"."MI_Id"=' || "MI_Id" || '
    INNER JOIN "CLG"."Fee_Y_Payment_College_Student" ON "CLG"."Fee_Y_Payment_College_Student"."AMCST_Id"="CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
        AND "CLG"."Fee_Y_Payment_College_Student"."ASMAY_Id"="CLG"."Adm_College_Yearly_Student"."ASMAY_Id"
    INNER JOIN "CLG"."Fee_Y_Payment" ON "CLG"."Fee_Y_Payment"."FYP_Id"="CLG"."Fee_Y_Payment_College_Student"."FYP_Id"
    INNER JOIN "CLG"."Fee_T_College_Payment" ON "CLG"."Fee_T_College_Payment"."FYP_Id"="CLG"."Fee_Y_Payment_College_Student"."FYP_Id"
    INNER JOIN "CLG"."Fee_Payment_Settlement_Details_College" ON "CLG"."Fee_Payment_Settlement_Details_College"."FYPPSDC_PAYU_Id"="CLG"."Fee_Y_Payment"."FYP_PaymentReference_Id"
    INNER JOIN "CLG"."Fee_Payment_Overall_Settlement_Details_College" ON "CLG"."Fee_Payment_Overall_Settlement_Details_College"."FYPPSTC_Id"="CLG"."Fee_Payment_Settlement_Details_College"."FYPPSTC_Id" 
        AND "CLG"."Fee_Payment_Overall_Settlement_Details"."ASMAY_Id"="CLG"."Adm_College_Yearly_Student"."ASMAY_Id" 
        AND "CLG"."Fee_Payment_Overall_Settlement_Details_College"."User_id"="CLG"."Fee_Y_Payment"."user_id"
    INNER JOIN "CLG"."Fee_College_Student_Status" ON "CLG"."Fee_College_Student_Status"."AMCST_Id"="CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
        AND "CLG"."Fee_College_Student_Status"."FCMAS_Id"="CLG"."Fee_T_College_Payment"."FCMAS_Id" 
        AND "CLG"."Fee_College_Student_Status"."ASMAY_Id"="CLG"."Adm_College_Yearly_Student"."ASMAY_Id"
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="CLG"."Fee_College_Student_Status"."FMH_Id"
    WHERE "CLG"."Fee_Y_Payment"."MI_Id"=' || "MI_Id" || ' 
        AND "CLG"."Adm_College_Yearly_Student"."ASMAY_Id"=' || "ASMAY_Id" || '
        AND "CLG"."Fee_Y_Payment"."user_Id" IN (' || "userid" || ') ' || "where_condition";

    "sqlquery1" := 'CREATE TEMP TABLE "FeeSettementReportCollege1_Temp" AS
    SELECT "CLG"."Adm_Master_College_Student"."AMCST_Id" AS "AMCST_Id",
    (COALESCE("AMCST_FirstName",'''')||''  ''||COALESCE("AMCST_MiddleName",'''')||''  ''||COALESCE("AMCST_LastName",'''')) AS "StudentName",
    "AMCO_CourseName" AS "AMCO_CourseName",
    "AMB_BranchName",
    "AMSE_SEMName",
    "AMCST_AdmNo" AS "AdmNo",
    "FYP_ReceiptNo" AS "UTR_No",
    "Fee_Master_Head"."FMH_FeeName" AS "FeeName",
    "FTCP_PaidAmount" AS "paidAmount",
    "FYP_Transaction_Id" AS "Transactionid",
    "FYPPSDC_Payment_Id" AS "PaymentId",
    "FYPPSTC_Settlement_Date",
    "FYP_DOE"
    FROM "CLG"."Adm_Master_College_Student"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id"="CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
        AND "AMCST_SOL"!=''S'' AND "AMCST_ActiveFlag"=0 AND "CLG"."Adm_College_Yearly_Student"."ACYST_ActiveFlag"=0
    INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_Master_Course"."AMCO_Id"="CLG"."Adm_College_Yearly_Student"."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_Master_Branch"."AMB_Id"="CLG"."Adm_College_Yearly_Student"."AMB_Id" 
        AND "CLG"."Adm_Master_Branch"."MI_Id"=' || "MI_Id" || '
    INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_Master_Semester"."AMSE_Id"="CLG"."Adm_College_Yearly_Student"."AMSE_Id" 
        AND "CLG"."Adm_Master_Semester"."MI_Id"=' || "MI_Id" || '
    INNER JOIN "CLG"."Fee_Y_Payment_College_Student" ON "CLG"."Fee_Y_Payment_College_Student"."AMCST_Id"="CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
        AND "CLG"."Fee_Y_Payment_College_Student"."ASMAY_Id"="CLG"."Adm_College_Yearly_Student"."ASMAY_Id"
    INNER JOIN "Adm_School_M_Academic_Year" "AY" ON "AY"."MI_Id"="CLG"."Adm_Master_College_Student"."MI_Id" 
        AND "AY"."ASMAY_Id"="CLG"."Adm_Master_College_Student"."ASMAY_Id" 
        AND "CLG"."Fee_Y_Payment_College_Student"."AMCST_Id"="CLG"."Adm_College_Yearly_Student"."AMCST_Id"
    INNER JOIN "CLG"."Fee_Y_Payment" ON "CLG"."Fee_Y_Payment"."FYP_Id"="CLG"."Fee_Y_Payment_College_Student"."FYP_Id"
    INNER JOIN "CLG"."Fee_T_College_Payment" ON "CLG"."Fee_T_College_Payment"."FYP_Id"="CLG"."Fee_Y_Payment_College_Student"."FYP_Id"
    INNER JOIN "CLG"."Fee_Payment_Settlement_Details_College" ON "CLG"."Fee_Payment_Settlement_Details_College"."FYPPSDC_PAYU_Id"="CLG"."Fee_Y_Payment"."FYP_PaymentReference_Id"
    INNER JOIN "CLG"."Fee_Payment_Overall_Settlement_Details_College" ON "CLG"."Fee_Payment_Overall_Settlement_Details_College"."FYPPSTC_Id"="CLG"."Fee_Payment_Settlement_Details_College"."FYPPSTC_Id" 
        AND "CLG"."Fee_Payment_Overall_Settlement_Details_College"."User_id"="CLG"."Fee_Y_Payment"."user_id"
    INNER JOIN "CLG"."Fee_College_Student_Status" ON "CLG"."Fee_College_Student_Status"."AMCST_Id"="CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
        AND "CLG"."Fee_College_Student_Status"."FCMAS_Id"="CLG"."Fee_College_Student_Status"."FCMAS_Id"
    INNER JOIN "Fee_Master_Head" ON "Fee_Master_Head"."FMH_Id"="CLG"."Fee_College_Student_Status"."FMH_Id"
    WHERE "CLG"."Fee_Y_Payment"."MI_Id"=' || "MI_Id" || ' 
        AND "CLG"."Fee_Y_Payment"."user_Id" IN (' || "userid" || ') 
        AND "CLG"."Adm_Master_College_Student"."ASMAY_ID"=' || "ASMAY_Id" || ' ' || "where_condition";

    EXECUTE "sqlquery";
    EXECUTE "sqlquery1";

    CREATE TEMP TABLE "FeeSettementReportCollegeNew_Temp" AS 
    SELECT * FROM "FeeSettementReportCollege_Temp" 
    UNION ALL 
    SELECT * FROM "FeeSettementReportCollege1_Temp";

    "newsqlqueryy" := 'CREATE TEMP TABLE "FeeHeadCollege_Temp" AS
    SELECT DISTINCT "Fee_Master_Head"."FMH_FeeName" AS "FeeName"
    FROM "Fee_Yearly_Group_Head_Mapping"
    INNER JOIN "Fee_Master_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Master_Group"."FMG_Id"
    INNER JOIN "Fee_Master_Head" ON "Fee_Yearly_Group_Head_Mapping"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
    INNER JOIN "Fee_Group_Login_Previledge" ON "Fee_Group_Login_Previledge"."FMG_ID"="Fee_Yearly_Group_Head_Mapping"."FMG_Id"
    WHERE "Fee_Yearly_Group_Head_Mapping"."MI_Id"=' || "MI_Id" || ' 
        AND "Fee_Yearly_Group_Head_Mapping"."ASMAY_Id"=' || "ASMAY_Id" || ' 
        AND "Fee_Group_Login_Previledge"."User_Id" IN (' || "userid" || ')';

    EXECUTE "newsqlqueryy";

    SELECT STRING_AGG('"' || "FeeName" || '"', ',') 
    INTO "PivotColumnNames"
    FROM (SELECT DISTINCT "FeeName" FROM "FeeHeadCollege_Temp") AS "PVColumns";

    SELECT STRING_AGG('COALESCE("' || "FeeName" || '", 0) AS "' || "FeeName" || '"', ',')
    INTO "PivotSelectColumnNames"
    FROM (SELECT DISTINCT "FeeName" FROM "FeeHeadCollege_Temp") AS "PVSelctedColumns";

    "SQLQuery2" := 'SELECT "AMCST_Id","StudentName","AMCO_CourseName" AS "ClassName","AMB_BranchName" AS "SectionName","AdmNo","UTR_No","Transactionid","PaymentId",
    TO_CHAR("FYPPSTC_Settlement_Date",''DD-MM-YYYY'') AS "FYPPST_Settlement_Date",
    TO_CHAR("FYP_DOE",''DD-MM-YYYY'') AS "FYP_Date",' || "PivotSelectColumnNames" || '
    FROM CROSSTAB(
        ''SELECT "AMCST_Id"||''''|''''||"StudentName"||''''|''''||"AMCO_CourseName"||''''|''''||"AMB_BranchName"||''''|''''||"AdmNo"||''''|''''||"UTR_No"||''''|''''||"Transactionid"||''''|''''||"FYPPSDC_Payment_Id"||''''|''''||"FYPPSTC_Settlement_Date"||''''|''''||"FYP_DOE" AS rowkey,
        "FeeName", 
        SUM("paidAmount") 
        FROM "FeeSettementReportCollegeNew_Temp" 
        GROUP BY rowkey, "FeeName" 
        ORDER BY 1,2'',
        ''SELECT DISTINCT "FeeName" FROM "FeeHeadCollege_Temp" ORDER BY 1''
    ) AS ct(rowkey TEXT, ' || "PivotColumnNames" || ')';

    RETURN QUERY EXECUTE "SQLQuery2";

END;
$$;