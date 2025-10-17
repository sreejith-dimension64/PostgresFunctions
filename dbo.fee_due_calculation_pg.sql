CREATE OR REPLACE FUNCTION "dbo"."fee_due_calculation"(
    "ASMAY_ID" TEXT,
    "mi" TEXT,
    "date1" TEXT,
    "user_id" TEXT,
    OUT "VOUCHER_NO_NEW" TEXT
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    "dt" BIGINT;
    "mt" BIGINT;
    "ftdd_day" BIGINT;
    "ftdd_month" BIGINT;
    "endyr" BIGINT;
    "startyr" BIGINT;
    "duedate" TEXT;
    "duedate1" TEXT;
    "fromdate" DATE;
    "todate" DATE;
    "oResult" VARCHAR(50);
    "days" TEXT;
    "months" TEXT;
    "query" TEXT;
    "str1" TEXT;
    "mi_new" TEXT;
    "temp1" VARCHAR(200);
    "temp2" VARCHAR(200);
    "rec" RECORD;
    "scount_result" INTEGER;
BEGIN
    "ftdd_day" := 0;
    "ftdd_month" := 0;
    "endyr" := 0;
    "startyr" := 0;
    "days" := '0';
    "months" := '0';
    "dt" := 0;
    "mt" := 0;

    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'v_duedate') THEN
        TRUNCATE TABLE "V_DueDate";
    END IF;

    FOR "rec" IN
        SELECT "Fee_T_Due_Date"."FTDD_Day", 
               "Fee_T_Due_Date"."FTDD_Month", 
               EXTRACT(YEAR FROM "Adm_School_M_Academic_Year"."ASMAY_From_Date")::BIGINT AS startyr, 
               EXTRACT(YEAR FROM "Adm_School_M_Academic_Year"."ASMAY_To_Date")::BIGINT AS endyr,
               "Adm_School_M_Academic_Year"."ASMAY_From_Date", 
               "Adm_School_M_Academic_Year"."ASMAY_To_Date" 
        FROM "dbo"."Fee_Master_Terms_FeeHeads" 
        INNER JOIN "dbo"."Fee_Master_Group" 
            INNER JOIN "dbo"."Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" 
            INNER JOIN "dbo"."Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
            ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" 
        INNER JOIN "dbo"."Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" 
            AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
        INNER JOIN "dbo"."Fee_Master_Amount" ON "Fee_Master_Group"."FMG_Id" = "Fee_Master_Amount"."FMG_Id" 
            AND "Fee_Student_Status"."FMA_Id" = "Fee_Master_Amount"."FMA_Id" 
            AND "Fee_Master_Head"."FMH_Id" = "Fee_Master_Amount"."FMH_Id" 
        INNER JOIN "dbo"."Fee_T_Due_Date" ON "Fee_Master_Amount"."FMA_Id" = "Fee_T_Due_Date"."FMA_Id" 
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Fee_Master_Amount"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id" 
        WHERE ("Adm_School_M_Academic_Year"."ASMAY_Id" = "ASMAY_ID") 
            AND ("Adm_School_M_Academic_Year"."MI_Id" = "mi") 
            AND "Fee_Student_Status"."user_id" = "user_id" 
        GROUP BY "Fee_T_Due_Date"."FTDD_Day", 
                 "Fee_T_Due_Date"."FTDD_Month", 
                 "Adm_School_M_Academic_Year"."ASMAY_From_Date",
                 EXTRACT(YEAR FROM "Adm_School_M_Academic_Year"."ASMAY_From_Date"),
                 EXTRACT(YEAR FROM "Adm_School_M_Academic_Year"."ASMAY_To_Date"),
                 "Adm_School_M_Academic_Year"."ASMAY_To_Date"
    LOOP
        "ftdd_day" := "rec"."FTDD_Day";
        "ftdd_month" := "rec"."FTDD_Month";
        "startyr" := "rec".startyr;
        "endyr" := "rec".endyr;
        "fromdate" := "rec"."ASMAY_From_Date";
        "todate" := "rec"."ASMAY_To_Date";

        IF ("ftdd_day" = 0) OR ("ftdd_month" = 0) THEN
            "duedate" := "date1";
            "VOUCHER_NO_NEW" := '0';
            RETURN;
        ELSE
            "duedate" := CAST("startyr" AS TEXT) || '-' || LPAD(CAST("ftdd_month" AS TEXT), 2, '0') || '-' || LPAD(CAST("ftdd_day" AS TEXT), 2, '0');
            "duedate1" := CAST("endyr" AS TEXT) || '-' || LPAD(CAST("ftdd_month" AS TEXT), 2, '0') || '-' || LPAD(CAST("ftdd_day" AS TEXT), 2, '0');
        END IF;

        IF CAST("duedate" AS DATE) >= "fromdate" AND CAST("duedate" AS DATE) <= "todate" THEN
            INSERT INTO "V_DueDate"("Duedate") VALUES("duedate");
        ELSIF CAST("duedate1" AS DATE) >= "fromdate" AND CAST("duedate1" AS DATE) <= "todate" THEN
            INSERT INTO "V_DueDate"("Duedate") VALUES("duedate1");
        ELSE
            "oResult" := 'select current academic year date';
        END IF;
    END LOOP;

    FOR "rec" IN
        SELECT DISTINCT EXTRACT(DAY FROM CAST("duedate" AS DATE))::BIGINT AS noofdays,
                        EXTRACT(MONTH FROM CAST("duedate" AS DATE))::BIGINT AS noofmonths 
        FROM "v_duedate" 
        WHERE CAST("duedate" AS DATE) <= TO_DATE("date1", 'DD/MM/YYYY')
    LOOP
        "dt" := "rec".noofdays;
        "mt" := "rec".noofmonths;

        IF ("dt" = 0) AND ("mt" = 0) THEN
            "days" := CAST("dt" AS TEXT);
            "months" := CAST("mt" AS TEXT);
        ELSE
            "temp1" := CAST("dt" AS TEXT);
            "temp2" := CAST("mt" AS TEXT);
            "days" := "days" || ',' || "temp1";
            "months" := "months" || ',' || "temp2";
        END IF;
    END LOOP;

    "query" := 'SELECT COUNT(*) FROM  
    (SELECT SUM("fee_student_status"."FSS_ToBePaid") AS totalbalance,
            COALESCE("Adm_M_Student"."AMST_FirstName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName",'''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName",'''') as "StudentName",
            "Adm_M_Student"."AMST_AdmNo",
            ("Adm_School_M_Class"."ASMCL_ClassName" || '':'' || "Adm_School_M_Section"."ASMC_SectionName") as "ClassSection",
            "Adm_M_Student"."AMST_MobileNo",
            "Adm_M_Student"."AMST_FatherName" 
     FROM "Fee_Master_Group" 
     INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" 
     INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
     INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" 
     INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
     INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id" 
     INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id" 
     INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
     INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" 
         AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
     INNER JOIN "Fee_T_Due_Date" ON "Fee_T_Due_Date"."FMA_Id" = "Fee_Student_Status"."FMA_Id"
     WHERE "Adm_School_Y_Student"."ASMAY_Id" = ' || "ASMAY_ID" || ' 
         AND "fee_student_status"."MI_Id" = ' || "mi" || ' 
         AND "fee_student_status"."FSS_ToBePaid" > 0 
         AND "Fee_T_Due_Date"."FTDD_Day" IN (' || "days" || ') 
         AND "Fee_T_Due_Date"."FTDD_Month" IN  (' || "months" || ') 
     GROUP BY "Adm_M_Student"."AMST_Id", "AMST_FirstName", "AMST_MiddleName", "AMST_LastName",
              "Adm_M_Student"."AMST_AdmNo", "Adm_M_Student"."AMST_MobileNo", "ASMCL_ClassName",
              "ASMC_SectionName", "Adm_M_Student"."AMST_FatherName") a';

    DROP TABLE IF EXISTS "student_count";
    CREATE TEMP TABLE "student_count"("scount" INTEGER);
    
    EXECUTE "query" INTO "scount_result";
    INSERT INTO "student_count" VALUES ("scount_result");

    SELECT "scount" INTO "VOUCHER_NO_NEW" FROM "student_count";
    "VOUCHER_NO_NEW" := CAST(COALESCE(CAST("VOUCHER_NO_NEW" AS INTEGER), 0) AS TEXT);
    
    RETURN;
END;
$$;