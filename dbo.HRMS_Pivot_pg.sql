CREATE OR REPLACE FUNCTION "dbo"."HRMS_Pivot"(
    p_MI_Id bigint,
    p_HRME_Id bigint,
    p_HRES_Year varchar(20)
)
RETURNS TABLE(
    "MI_Id" varchar,
    "HRME_Id" varchar,
    "HRES_YearMonth" varchar,
    dynamic_columns text
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_dynamic text;
    v_dynamic1 text;
    v_pivot_cols text;
    v_PivotSelectColumnNames text;
    v_columnname1 varchar(50);
    v_HRES_YearMonthtemp1 varchar;
    v_HRME_id_temp1 varchar;
    v_InstName_temp1 varchar;
    v_HRMED_Name_temp1 varchar;
    v_HRESD_Amount_temp1 varchar;
    v_MI_Id_temp1 varchar;
    v_HRMED_Order_temp1 varchar;
    v_HRMED_Id_temp1 varchar;
    v_HRMED_Name_Test1 varchar;
    v_script1 text;
    v_script22 text;
    v_script33 text;
    v_count_temp1 bigint;
    rec_createcolumns RECORD;
    rec_insertdata RECORD;
    rec_insertdata2 RECORD;
    v_table_exists boolean;
BEGIN
    DROP TABLE IF EXISTS "temptable1";
    
    v_dynamic1 := '
    SELECT DISTINCT "HR_Employee_Salary"."HRME_Id"::varchar,
    (CAST("HR_Employee_Salary"."HRES_Year" AS varchar(10)) || '''' || "HR_Employee_Salary"."HRES_Month") AS "HRES_YearMonth", 
    replace(replace(COALESCE("HR_Master_EarningsDeductions"."HRMED_Name",''''),''  '',''''),'' '','''') AS "HRMED_Name",
    "HR_Employee_Salary_Details"."HRESD_Amount"::varchar,
    "HR_Master_EarningsDeductions"."MI_Id"::varchar
    FROM "dbo"."HR_Employee_Salary" 
    INNER JOIN "dbo"."HR_Master_Employee" ON "HR_Employee_Salary"."HRME_Id" = "HR_Master_Employee"."HRME_Id" 
    INNER JOIN "dbo"."HR_Employee_Salary_Details" ON "HR_Employee_Salary"."HRES_Id" = "HR_Employee_Salary_Details"."HRES_Id" 
    INNER JOIN "dbo"."HR_Master_EarningsDeductions" ON "HR_Employee_Salary_Details"."HRMED_Id" = "HR_Master_EarningsDeductions"."HRMED_Id"
    WHERE ("HR_Employee_Salary"."HRME_Id" = ' || p_HRME_Id || ') 
    AND ("HR_Employee_Salary"."HRES_Year" = ''' || p_HRES_Year || ''') 
    AND ("HR_Master_EarningsDeductions"."MI_Id" = ' || p_MI_Id || ')';

    CREATE TEMP TABLE "tablevarr"(
        "HRME_Id" varchar(50),
        "HRES_YearMonth" varchar(200),
        "HRMED_Name" varchar(500),
        "HRESD_Amount" varchar(200),
        "MI_Id" varchar(50)
    ) ON COMMIT DROP;

    EXECUTE 'INSERT INTO "tablevarr"("HRME_Id","HRES_YearMonth","HRMED_Name","HRESD_Amount","MI_Id") ' || v_dynamic1;

    CREATE TEMP TABLE "temptable1"(
        "MI_Id" varchar(500),
        "HRME_Id" varchar(500),
        "HRES_YearMonth" varchar(400)
    ) ON COMMIT DROP;

    FOR rec_createcolumns IN 
        SELECT DISTINCT "HRMED_Name" FROM "tablevarr" GROUP BY "HRMED_Name"
    LOOP
        v_columnname1 := rec_createcolumns."HRMED_Name";
        
        v_script1 := 'ALTER TABLE "temptable1" ADD COLUMN "' || v_columnname1 || '" varchar(100)';
        
        EXECUTE v_script1;
    END LOOP;

    FOR rec_insertdata IN 
        SELECT DISTINCT "MI_Id", "HRME_Id", "HRES_YearMonth", "HRMED_Name" 
        FROM "tablevarr" 
        GROUP BY "MI_Id", "HRME_Id", "HRES_YearMonth", "HRMED_Name"
    LOOP
        v_MI_Id_temp1 := rec_insertdata."MI_Id";
        v_HRME_id_temp1 := rec_insertdata."HRME_Id";
        v_HRES_YearMonthtemp1 := rec_insertdata."HRES_YearMonth";
        v_HRMED_Name_Test1 := rec_insertdata."HRMED_Name";
        
        v_count_temp1 := 0;

        FOR rec_insertdata2 IN 
            SELECT DISTINCT "HRMED_Name", "HRESD_Amount" 
            FROM "tablevarr" 
            WHERE "HRME_Id" = v_HRME_id_temp1 
            AND "HRES_YearMonth" = v_HRES_YearMonthtemp1
        LOOP
            v_HRMED_Name_temp1 := rec_insertdata2."HRMED_Name";
            v_HRESD_Amount_temp1 := rec_insertdata2."HRESD_Amount";
            
            v_count_temp1 := v_count_temp1 + 1;

            IF v_count_temp1 = 1 THEN
                v_script22 := 'INSERT INTO "temptable1" ("MI_Id","HRME_Id","HRES_YearMonth","' || v_HRMED_Name_temp1 || '") ' ||
                             'VALUES (''' || v_MI_Id_temp1 || ''',''' || v_HRME_id_temp1 || ''',''' || 
                             replace(v_HRES_YearMonthtemp1, ' ', ' ') || ''',''' || 
                             replace(v_HRESD_Amount_temp1, ' ', '') || ''')';
                
                EXECUTE v_script22;
            ELSE
                v_script33 := 'UPDATE "temptable1" SET "' || v_HRMED_Name_temp1 || '" = ' || 
                             replace(v_HRESD_Amount_temp1, ' ', '') || 
                             ' WHERE "HRME_Id" = ''' || v_HRME_id_temp1 || ''' AND "HRES_YearMonth" = ''' || 
                             replace(v_HRES_YearMonthtemp1, ' ', '') || '''';
                
                EXECUTE v_script33;
            END IF;
        END LOOP;
    END LOOP;

    RETURN QUERY EXECUTE 'SELECT DISTINCT * FROM "temptable1"';

END;
$$;