CREATE OR REPLACE FUNCTION "dbo"."Fee_Demand_Register_College_Report"(
    "MI_Id" VARCHAR,
    "ASMAY_Id" VARCHAR,
    "AMCO_Id" VARCHAR,
    "AMB_Id" VARCHAR,
    "AMSE_Id" VARCHAR,
    "AMCST_Id" VARCHAR,
    "FMGG_Id" VARCHAR,
    "FMG_Id" VARCHAR,
    "date" VARCHAR(10),
    "Fromdate" VARCHAR(10),
    "Todate" VARCHAR(10),
    "Type" VARCHAR(10),
    "Stu_Type" VARCHAR(50),
    "NewStud" VARCHAR(10)
)
RETURNS TABLE (
    "AMCST_Id" TEXT,
    "StudentName" TEXT,
    "FeeName" TEXT,
    "Adm_no" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "aa" VARCHAR;
    "where_condition" VARCHAR;
    "sqlquery" TEXT;
    "FeeName" TEXT;
    "FT_Name" TEXT;
    "FName" TEXT;
    "TName" TEXT;
    "columnname" VARCHAR(50);
    "sqlquerycolumn" VARCHAR(400);
    "count" INT;
    "Feenametemp" VARCHAR(500);
    "Studentnametemp" VARCHAR(500);
    "amcst_id_temp" VARCHAR(500);
    "paidamount_temp" VARCHAR(500);
    "InstName_temp" VARCHAR(500);
    "admission_no" VARCHAR(500);
    "columnname1" VARCHAR(50);
    "sqlquerycolumn1" VARCHAR(400);
    "count1" INT;
    "Feenametemp1" VARCHAR(500);
    "Studentnametemp1" VARCHAR(500);
    "amcst_id_temp1" VARCHAR(500);
    "paidamount_temp1" VARCHAR(500);
    "InstName_temp1" VARCHAR(500);
    "admission_no1" VARCHAR(500);
    "InstName_Test1" VARCHAR(100);
    "InstName_Test2" VARCHAR(100);
    "condition" TEXT;
    "script" VARCHAR(8000);
    "script1" VARCHAR(8000);
    "script2" VARCHAR(8000);
    "script3" VARCHAR(8000);
    "script22" VARCHAR(8000);
    "script33" VARCHAR(8000);
    "count_temp" BIGINT;
    "count_temp1" BIGINT;
    rec RECORD;
    rec2 RECORD;
BEGIN

    "sqlquerycolumn1" := '';
    "count1" := 0;
    "sqlquerycolumn" := '';
    "count" := 0;

    IF "NewStud" = '1' THEN
        "condition" := 'and "CLG"."Adm_Master_College_Student"."ASMAY_Id"=' || "ASMAY_Id" || '';
    ELSE
        "condition" := 'and "CLG"."Fee_Y_Payment"."ASMAY_Id"=' || "ASMAY_Id" || '';
    END IF;

    IF "Fromdate" != '' AND "Todate" != '' THEN
        "where_condition" := ' and "FYP_DOE"::date between TO_DATE(''' || "Fromdate" || ''', ''DD/MM/YYYY'') and TO_DATE(''' || "Todate" || ''', ''DD/MM/YYYY'')';
    ELSIF "date" != '' THEN
        "where_condition" := ' and "FYP_DOE"::date = TO_DATE(''' || "date" || ''', ''DD/MM/YYYY'')';
    ELSE
        "where_condition" := '';
    END IF;

    IF "Type" = 'All' THEN
        IF "AMSE_Id" != '0' THEN
            "sqlquery" := 'SELECT DISTINCT (COALESCE("AMCST_FirstName",'''') || ''  '' || COALESCE("AMCST_MiddleName",'''') || ''  '' || COALESCE("AMCST_LastName",'''')) AS "StudentName", 
                "AMCST_Admno" AS "admno", "dbo"."Fee_Master_Head"."FMH_FeeName" AS "FeeName", "dbo"."Fee_T_Installment"."FTI_Name" AS "InstName",
                "FCSS_ToBePaid" As "ToBePaid", "FTCP_PaidAmount" AS "paidAmount", "CLG"."Fee_Y_Payment_College_Student"."AMCST_Id"
            FROM "CLG"."Fee_College_Master_Amount_SemesterWise" 
            INNER JOIN "CLG"."Fee_College_Student_Status" ON "CLG"."Fee_College_Master_Amount_SemesterWise"."FCMAS_Id" = "CLG"."Fee_College_Student_Status"."FCMAS_Id" 
                and "CLG"."Fee_College_Student_Status"."MI_Id"=' || "MI_Id" || ' and "CLG"."Fee_College_Student_Status"."ASMAY_Id"=' || "ASMAY_Id" || '
            INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id"="dbo"."Fee_Student_Status"."FMG_Id" and "dbo"."Fee_Master_Group"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id" 
            INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id" = "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" 
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" 
                and "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" 
                and "dbo"."Fee_Yearly_Group"."MI_Id"=' || "MI_Id" || ' and "dbo"."Fee_Yearly_Group"."ASMAY_Id"=' || "ASMAY_Id" || '
            INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id"="dbo"."Fee_Student_Status"."FMH_Id" and "dbo"."Fee_Master_Head"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "CLG"."Fee_Y_Payment_College_Student" ON "CLG"."Fee_Y_Payment_College_Student"."AMCST_Id"="CLG"."Fee_College_Student_Status"."AMCST_Id" 
                and "CLG"."Fee_Y_Payment_College_Student"."ASMAY_Id"=' || "ASMAY_Id" || '
            INNER JOIN "CLG"."Fee_Y_Payment" ON "CLG"."Fee_Y_Payment"."FYP_Id"="CLG"."Fee_Y_Payment_College_Student"."FYP_Id" 
            INNER JOIN "CLG"."Adm_Master_College_student" ON "CLG"."Adm_Master_College_student"."AMCST_Id"="CLG"."Fee_Y_Payment_College_Student"."AMCST_Id" 
                and "CLG"."Adm_Master_College_student"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "CLG"."Fee_T_College_Payment" ON "CLG"."Fee_T_College_Payment"."FYP_Id"="CLG"."Fee_Y_Payment"."FYP_Id" 
                and "CLG"."Fee_T_College_Payment"."FCMAS_Id"="CLG"."Fee_College_Master_Amount_SemesterWise"."FCMAS_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id"="CLG"."Fee_College_Student_Status"."FTI_Id" 
                and "dbo"."Fee_T_Installment"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"="CLG"."Fee_College_Student_Status"."ASMAY_Id" 
                and "dbo"."Adm_School_M_Academic_Year"."MI_Id"=' || "MI_Id" || ' and "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"=' || "ASMAY_Id" || '
            INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Fee_College_Student_Status"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
                and "CLG"."Adm_College_Yearly_Student"."AMCST_Id"="CLG"."Adm_Master_College_student"."AMCST_Id" 
                and "CLG"."Adm_College_Yearly_Student"."ASMAY_Id"=' || "ASMAY_Id" || '
                AND POSITION('','' || "AMST_SOL" || '','' IN '','' || ''' || "Stu_Type" || ''' || '','') > 0
            INNER JOIN "CLG"."Adm_Master_Course" ON "dbo"."Adm_School_Y_Student"."AMCO_Id" = "CLG"."Adm_Master_Course"."AMCO_Id" 
            INNER JOIN "CLG"."Adm_Master_Branch" on "CLG"."Adm_Master_Branch"."AMB_Id"="CLG"."Adm_College_Yearly_Student"."AMB_Id" 
                and "CLG"."Adm_Master_Branch"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "CLG"."Adm_Master_Semester" on "CLG"."Adm_Master_Semester"."AMSE_Id"="CLG"."Adm_College_Yearly_Student"."AMSE_Id" 
                and "CLG"."Adm_Master_Semester"."MI_Id"=' || "MI_Id" || '
            WHERE ("CLG"."Fee_College_Student_Status"."FMG_Id" IS NOT NULL) and "CLG"."Fee_Y_Payment"."MI_Id"=' || "MI_Id" || '
                and "CLG"."Adm_College_Yearly_Student"."AMCO_Id"=' || "AMCO_Id" || ' 
                AND "CLG"."Adm_Master_Branch"."AMB_Id"=' || "AMB_Id" || ' 
                and ("CLG"."Adm_Master_Semester"."AMSE_Id" IN (' || "AMSE_Id" || '))
                and "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" in (' || "FMGG_Id" || ') 
                and "dbo"."Fee_Master_Group"."FMG_Id" in (' || "FMG_Id" || ') ' || "where_condition" || ' ' || "condition" || '
            LIMIT 100';
        ELSIF "AMSE_Id" = '0' OR "AMSE_Id" = '' THEN
            "sqlquery" := 'SELECT DISTINCT (COALESCE("AMCST_FirstName",'''') || ''  '' || COALESCE("AMCST_MiddleName",'''') || ''  '' || COALESCE("AMCST_LastName",'''')) AS "StudentName",
                "AMCST_Admno" AS "admno", "dbo"."Fee_Master_Head"."FMH_FeeName" AS "FeeName", "dbo"."Fee_T_Installment"."FTI_Name" AS "InstName",
                "FCSS_ToBePaid" As "ToBePaid", "FTCP_PaidAmount" AS "paidAmount", "CLG"."Fee_Y_Payment_College_Student"."AMCST_Id"
            FROM "CLG"."Fee_College_Master_Amount_SemesterWise" 
            INNER JOIN "CLG"."Fee_College_Student_Status" ON "CLG"."Fee_College_Master_Amount_SemesterWise"."FCMAS_Id" = "CLG"."Fee_College_Student_Status"."FCMAS_Id" 
                and "CLG"."Fee_College_Student_Status"."MI_Id"=' || "MI_Id" || ' and "CLG"."Fee_College_Student_Status"."ASMAY_Id"=' || "ASMAY_Id" || '
            INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id"="dbo"."Fee_Student_Status"."FMG_Id" and "dbo"."Fee_Master_Group"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id" 
            INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id" = "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" 
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" 
                and "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" 
                and "dbo"."Fee_Yearly_Group"."MI_Id"=' || "MI_Id" || ' and "dbo"."Fee_Yearly_Group"."ASMAY_Id"=' || "ASMAY_Id" || '
            INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id"="dbo"."Fee_Student_Status"."FMH_Id" and "dbo"."Fee_Master_Head"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "CLG"."Fee_Y_Payment_College_Student" ON "CLG"."Fee_Y_Payment_College_Student"."AMCST_Id"="CLG"."Fee_College_Student_Status"."AMCST_Id" 
                and "CLG"."Fee_Y_Payment_College_Student"."ASMAY_Id"=' || "ASMAY_Id" || '
            INNER JOIN "CLG"."Fee_Y_Payment" ON "CLG"."Fee_Y_Payment"."FYP_Id"="CLG"."Fee_Y_Payment_College_Student"."FYP_Id" 
            INNER JOIN "CLG"."Adm_Master_College_student" ON "CLG"."Adm_Master_College_student"."AMCST_Id"="CLG"."Fee_Y_Payment_College_Student"."AMCST_Id" 
                and "CLG"."Adm_Master_College_student"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "CLG"."Fee_T_College_Payment" ON "CLG"."Fee_T_College_Payment"."FYP_Id"="CLG"."Fee_Y_Payment"."FYP_Id" 
                and "CLG"."Fee_T_College_Payment"."FCMAS_Id"="CLG"."Fee_College_Master_Amount_SemesterWise"."FCMAS_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id"="CLG"."Fee_College_Student_Status"."FTI_Id" 
                and "dbo"."Fee_T_Installment"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"="CLG"."Fee_College_Student_Status"."ASMAY_Id" 
                and "dbo"."Adm_School_M_Academic_Year"."MI_Id"=' || "MI_Id" || ' and "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"=' || "ASMAY_Id" || '
            INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Fee_College_Student_Status"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
                and "CLG"."Adm_College_Yearly_Student"."AMCST_Id"="CLG"."Adm_Master_College_student"."AMCST_Id" 
                and "CLG"."Adm_College_Yearly_Student"."ASMAY_Id"=' || "ASMAY_Id" || '
                AND POSITION('','' || "AMST_SOL" || '','' IN '','' || ''' || "Stu_Type" || ''' || '','') > 0
            INNER JOIN "CLG"."Adm_Master_Course" ON "dbo"."Adm_School_Y_Student"."AMCO_Id" = "CLG"."Adm_Master_Course"."AMCO_Id" 
            INNER JOIN "CLG"."Adm_Master_Branch" on "CLG"."Adm_Master_Branch"."AMB_Id"="CLG"."Adm_College_Yearly_Student"."AMB_Id" 
                and "CLG"."Adm_Master_Branch"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "CLG"."Adm_Master_Semester" on "CLG"."Adm_Master_Semester"."AMSE_Id"="CLG"."Adm_College_Yearly_Student"."AMSE_Id" 
                and "CLG"."Adm_Master_Semester"."MI_Id"=' || "MI_Id" || '
            WHERE ("CLG"."Fee_College_Student_Status"."FMG_Id" IS NOT NULL) and "CLG"."Fee_Y_Payment"."MI_Id"=' || "MI_Id" || '
                and "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" in (' || "FMGG_Id" || ') 
                and "dbo"."Fee_Master_Group"."FMG_Id" in (' || "FMG_Id" || ') ' || "where_condition" || ' ' || "condition" || '
            LIMIT 100';
        END IF;

        CREATE TEMP TABLE "temptable1"(
            "AMCST_Id" TEXT,
            "StudentName" TEXT,
            "FeeName" TEXT,
            "Adm_no" TEXT
        ) ON COMMIT DROP;

        FOR rec IN EXECUTE "sqlquery" LOOP
            FOR rec2 IN 
                SELECT DISTINCT "InstName" 
                FROM (SELECT * FROM json_populate_recordset(NULL::record, rec::json)) t
                GROUP BY "InstName"
            LOOP
                "columnname1" := rec2."InstName";
                "script1" := 'ALTER TABLE "temptable1" ADD COLUMN "' || "columnname1" || '" TEXT';
                EXECUTE "script1";
            END LOOP;
        END LOOP;

        FOR rec IN EXECUTE "sqlquery" LOOP
            "amcst_id_temp1" := rec."AMCST_Id"::TEXT;
            "Studentnametemp1" := rec."StudentName";
            "Feenametemp1" := rec."FeeName";
            "admission_no1" := rec."admno";
            "InstName_Test1" := rec."InstName";
            "count_temp1" := 0;

            FOR rec2 IN 
                EXECUTE 'SELECT "InstName", "paidAmount" FROM (' || "sqlquery" || ') t WHERE "FeeName"=$1 AND "AMCST_Id"=$2'
                USING "Feenametemp1", "amcst_id_temp1"::BIGINT
            LOOP
                "InstName_temp1" := rec2."InstName";
                "paidamount_temp1" := rec2."paidAmount"::TEXT;
                "count_temp1" := "count_temp1" + 1;

                IF "count_temp1" = 1 THEN
                    "script22" := 'INSERT INTO "temptable1" ("AMCST_Id","StudentName","FeeName","Adm_no","' || "InstName_temp1" || '") VALUES ($1,$2,$3,$4,$5)';
                    EXECUTE "script22" USING "amcst_id_temp1", REPLACE("Studentnametemp1", ' ', ' '), REPLACE("Feenametemp1", ' ', ''), REPLACE("admission_no1", ' ', ''), REPLACE("paidamount_temp1", ' ', '');
                ELSE
                    "script33" := 'UPDATE "temptable1" SET "' || "InstName_temp1" || '"=$1 WHERE "AMCST_Id"=$2 AND "FeeName"=$3';
                    EXECUTE "script33" USING REPLACE("paidamount_temp1", ' ', ''), "amcst_id_temp1", REPLACE("Feenametemp1", ' ', '');
                END IF;
            END LOOP;
        END LOOP;

        RETURN QUERY SELECT * FROM "temptable1";

    ELSIF "Type" = 'Indi' THEN
        IF "AMSE_Id" != '0' THEN
            "sqlquery" := 'SELECT DISTINCT (COALESCE("AMCST_FirstName",'''') || '' '' || COALESCE("AMCST_MiddleName",'''') || '' '' || COALESCE("AMCST_LastName",'''')) AS "StudentName",
                "AMCST_Admno" AS "admno", "dbo"."Fee_Master_Head"."FMH_FeeName" AS "FeeName", "dbo"."Fee_T_Installment"."FTI_Name" AS "InstName",
                "FCSS_ToBePaid" As "ToBePaid", "FTCP_PaidAmount" AS "paidAmount", "CLG"."Fee_Y_Payment_College_Student"."AMCST_Id"
            FROM "CLG"."Fee_College_Master_Amount_SemesterWise" 
            INNER JOIN "CLG"."Fee_College_Student_Status" ON "CLG"."Fee_College_Master_Amount_SemesterWise"."FCMAS_Id" = "CLG"."Fee_College_Student_Status"."FCMAS_Id" 
                and "CLG"."Fee_College_Student_Status"."MI_Id"=' || "MI_Id" || ' and "CLG"."Fee_College_Student_Status"."ASMAY_Id"=' || "ASMAY_Id" || '
            INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id"="dbo"."Fee_Student_Status"."FMG_Id" and "dbo"."Fee_Master_Group"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "dbo"."Fee_Master_Group_Grouping_Groups" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Master_Group_Grouping_Groups"."FMG_Id" 
            INNER JOIN "dbo"."Fee_Master_Group_Grouping" ON "dbo"."Fee_Master_Group_Grouping_Groups"."FMGG_Id" = "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" 
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" 
                and "dbo"."Fee_Student_Status"."FMG_Id" = "dbo"."Fee_Yearly_Group"."FMG_Id" 
                and "dbo"."Fee_Yearly_Group"."MI_Id"=' || "MI_Id" || ' and "dbo"."Fee_Yearly_Group"."ASMAY_Id"=' || "ASMAY_Id" || '
            INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id"="dbo"."Fee_Student_Status"."FMH_Id" and "dbo"."Fee_Master_Head"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "CLG"."Fee_Y_Payment_College_Student" ON "CLG"."Fee_Y_Payment_College_Student"."AMCST_Id"="CLG"."Fee_College_Student_Status"."AMCST_Id" 
                and "CLG"."Fee_Y_Payment_College_Student"."ASMAY_Id"=' || "ASMAY_Id" || '
            INNER JOIN "CLG"."Fee_Y_Payment" ON "CLG"."Fee_Y_Payment"."FYP_Id"="CLG"."Fee_Y_Payment_College_Student"."FYP_Id" 
            INNER JOIN "CLG"."Adm_Master_College_student" ON "CLG"."Adm_Master_College_student"."AMCST_Id"="CLG"."Fee_Y_Payment_College_Student"."AMCST_Id" 
                and "CLG"."Adm_Master_College_student"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "CLG"."Fee_T_College_Payment" ON "CLG"."Fee_T_College_Payment"."FYP_Id"="CLG"."Fee_Y_Payment"."FYP_Id" 
                and "CLG"."Fee_T_College_Payment"."FCMAS_Id"="CLG"."Fee_College_Master_Amount_SemesterWise"."FCMAS_Id"
            INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id"="CLG"."Fee_College_Student_Status"."FTI_Id" 
                and "dbo"."Fee_T_Installment"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"="CLG"."Fee_College_Student_Status"."ASMAY_Id" 
                and "dbo"."Adm_School_M_Academic_Year"."MI_Id"=' || "MI_Id" || ' and "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"=' || "ASMAY_Id" || '
            INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Fee_College_Student_Status"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
                and "CLG"."Adm_College_Yearly_Student"."AMCST_Id"="CLG"."Adm_Master_College_student"."AMCST_Id" 
                and "CLG"."Adm_College_Yearly_Student"."ASMAY_Id"=' || "ASMAY_Id" || '
                AND POSITION('','' || "AMST_SOL" || '','' IN '','' || ''' || "Stu_Type" || ''' || '','') > 0
            INNER JOIN "CLG"."Adm_Master_Course" ON "dbo"."Adm_School_Y_Student"."AMCO_Id" = "CLG"."Adm_Master_Course"."AMCO_Id" 
            INNER JOIN "CLG"."Adm_Master_Branch" on "CLG"."Adm_Master_Branch"."AMB_Id"="CLG"."Adm_College_Yearly_Student"."AMB_Id" 
                and "CLG"."Adm_Master_Branch"."MI_Id"=' || "MI_Id" || '
            INNER JOIN "CLG"."Adm_Master_Semester" on "CLG"."Adm_Master_Semester"."AMSE_Id"="CLG"."Adm_College_Yearly_Student"."AMSE_Id" 
                and "CLG"."Adm_Master_Semester"."MI_Id"=' || "MI_Id" || '
            WHERE ("CLG"."Fee_College_Student_Status"."FMG_Id" IS NOT NULL) AND "CLG"."Fee_Y_Payment"."MI_Id"=' || "MI_Id" || ' 
                AND "CLG"."Adm_College_Yearly_Student"."AMCO_Id"=' || "AMCO_Id" || ' 
                AND "CLG"."Adm_Master_Branch"."AMB_Id"=' || "AMB_Id" || ' 
                and ("CLG"."Adm_Master_Semester"."AMSE_Id" IN (' || "AMSE_Id" || '))
                AND "dbo"."Fee_Master_Group_Grouping"."FMGG_Id" in (' || "FMGG_Id" || ') 
                and "dbo"."Fee_Master_Group"."FMG_Id" in (' || "FMG_Id" || ') ' || "where_condition" || ' ' || "condition" || '
            LIMIT 100';
        ELSE
            "sqlquery" := 'SELECT DISTINCT (COALESCE("AMCST_FirstName",'''') || '' '' || COALESCE("AMCST_MiddleName",'''') || '' '' || COALESCE("AMCST_LastName",'''')) AS "StudentName",
                "AMCST_Admno" AS "admno", "dbo"."Fee_Master_Head"."F