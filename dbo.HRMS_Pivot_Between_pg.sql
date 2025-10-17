CREATE OR REPLACE FUNCTION "dbo"."HRMS_Pivot_Between"(
    "p_MI_Id" bigint,
    "p_HRME_Id" bigint,
    "p_HRES_Year" text,
    "p_Fromdate" date,
    "p_Todate" date
)
RETURNS TABLE(
    "MI_Id" text,
    "HRME_Id" text,
    "HMonthName" varchar(60),
    "HRES_YearMonth" text,
    "HRES_Year" bigint
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_dynamic text;
    v_dynamic1 text;
    v_pivot_cols text;
    v_PivotSelectColumnNames text;
    v_columnname1 varchar(50);
    v_HRES_YearMonthtemp1 text;
    v_HRME_id_temp1 text;
    v_InstName_temp1 text;
    v_HRMED_Name_temp1 text;
    v_HRESD_Amount_temp1 text;
    v_MI_Id_temp1 text;
    v_HRMED_Order_temp1 text;
    v_HRMED_Id_temp1 text;
    v_HRMED_Name_Test1 text;
    v_HMonthName text;
    v_content text;
    v_FromYear bigint;
    v_ToYear bigint;
    v_FromMonth bigint;
    v_ToMonth bigint;
    v_count_temp1 bigint;
    v_script1 text;
    v_script22 text;
    v_script33 text;
    rec_createcolumns RECORD;
    rec_insertdata RECORD;
    rec_insertdata2 RECORD;
    v_tablevarr_query text;
BEGIN

    v_FromYear := EXTRACT(YEAR FROM "p_Fromdate");
    v_ToYear := EXTRACT(YEAR FROM "p_Todate");
    
    v_FromMonth := EXTRACT(MONTH FROM "p_Fromdate");
    v_ToMonth := EXTRACT(MONTH FROM "p_Todate");
    
    RAISE NOTICE '%', v_FromYear::varchar;
    RAISE NOTICE '%', v_ToYear::varchar;
    RAISE NOTICE '%', v_FromMonth::varchar;
    RAISE NOTICE '%', v_ToMonth::varchar;
    
    IF v_FromYear <> v_ToYear THEN
        v_content := 'AND ("HRES_Year" =' || v_FromYear::varchar || ' AND "HRES_Month" IN (SELECT "IVRM_Month_Name" FROM "IVRM_Month" WHERE "IVRM_Month_Id" BETWEEN ' || v_FromMonth::varchar || ' AND 12)  
        OR "HRES_Year" =' || v_ToYear::varchar || ' AND "HRES_Month" IN (SELECT "IVRM_Month_Name" FROM "IVRM_Month" WHERE "IVRM_Month_Id" BETWEEN 1 AND ' || v_ToMonth::varchar || '))';
    ELSIF v_FromYear = v_ToYear THEN
        v_content := 'AND "HRES_Year" =' || v_FromYear::varchar || ' AND "HRES_Month" IN (SELECT "IVRM_Month_Name" FROM "IVRM_Month" WHERE "IVRM_Month_Id" BETWEEN ' || v_FromMonth::varchar || ' AND ' || v_ToMonth::varchar || ') ';
    ELSE
        v_content := '';
    END IF;
    
    DROP TABLE IF EXISTS "HRME_PivotTemp";
    DROP TABLE IF EXISTS "temptable1";
    
    v_dynamic1 := '
    SELECT DISTINCT "HR_Employee_Salary"."HRME_Id",
    (CAST("HR_Employee_Salary"."HRES_Year" AS varchar(10)) || '''' || "HR_Employee_Salary"."HRES_Month") AS "HRES_YearMonth",
    "HR_Employee_Salary"."HRES_Month" AS "HMonthName", 
    replace(replace(COALESCE("HR_Master_EarningsDeductions"."HRMED_Name", ''''), ''  '', ''''), '' '', '''') AS "HRMED_Name",
    "HR_Employee_Salary_Details"."HRESD_Amount",
    "HR_Master_EarningsDeductions"."MI_Id"
    FROM "HR_Employee_Salary" 
    INNER JOIN "HR_Master_Employee" ON "HR_Employee_Salary"."HRME_Id" = "HR_Master_Employee"."HRME_Id" 
    INNER JOIN "HR_Employee_Salary_Details" ON "HR_Employee_Salary"."HRES_Id" = "HR_Employee_Salary_Details"."HRES_Id" 
    INNER JOIN "HR_Master_EarningsDeductions" ON "HR_Employee_Salary_Details"."HRMED_Id" = "HR_Master_EarningsDeductions"."HRMED_Id"
    WHERE "HR_Employee_Salary"."HRME_Id" = ' || "p_HRME_Id"::varchar || ' AND "HR_Master_EarningsDeductions"."MI_Id" = ' || "p_MI_Id"::varchar || ' ' || v_content || ' ';
    
    CREATE TEMP TABLE "tablevarr_temp"(
        "HRME_Id" text,
        "HRES_YearMonth" varchar(200),
        "HMonthName" varchar(60),
        "HRMED_Name" text,
        "HRESD_Amount" text,
        "MI_Id" text
    );
    
    EXECUTE 'INSERT INTO "tablevarr_temp" SELECT * FROM (' || v_dynamic1 || ') subq';
    
    CREATE TEMP TABLE "temptable1"(
        "MI_Id" text,
        "HRME_Id" text,
        "HMonthName" varchar(60),
        "HRES_YearMonth" text
    );
    
    FOR rec_createcolumns IN 
        SELECT DISTINCT "HRMED_Name" FROM "tablevarr_temp" GROUP BY "HRMED_Name"
    LOOP
        v_columnname1 := rec_createcolumns."HRMED_Name";
        v_script1 := 'ALTER TABLE "temptable1" ADD COLUMN "' || v_columnname1 || '" text';
        EXECUTE v_script1;
    END LOOP;
    
    FOR rec_insertdata IN 
        SELECT DISTINCT "MI_Id", "HRME_Id", "HRES_YearMonth", "HMonthName", "HRMED_Name"  
        FROM "tablevarr_temp" 
        GROUP BY "MI_Id", "HRME_Id", "HRES_YearMonth", "HRMED_Name", "HMonthName"
    LOOP
        v_MI_Id_temp1 := rec_insertdata."MI_Id";
        v_HRME_id_temp1 := rec_insertdata."HRME_Id";
        v_HRES_YearMonthtemp1 := rec_insertdata."HRES_YearMonth";
        v_HMonthName := rec_insertdata."HMonthName";
        v_HRMED_Name_Test1 := rec_insertdata."HRMED_Name";
        
        v_count_temp1 := 0;
        
        FOR rec_insertdata2 IN 
            SELECT DISTINCT "HRMED_Name", "HRESD_Amount" 
            FROM "tablevarr_temp" 
            WHERE "HRME_Id" = v_HRME_id_temp1 AND "HRES_YearMonth" = v_HRES_YearMonthtemp1
        LOOP
            v_HRMED_Name_temp1 := rec_insertdata2."HRMED_Name";
            v_HRESD_Amount_temp1 := rec_insertdata2."HRESD_Amount";
            
            v_count_temp1 := v_count_temp1 + 1;
            
            IF v_count_temp1 = 1 THEN
                v_script22 := 'INSERT INTO "temptable1" ("MI_Id", "HRME_Id", "HRES_YearMonth", "HMonthName", "' || v_HRMED_Name_temp1 || '") 
                VALUES (''' || v_MI_Id_temp1 || ''', ''' || v_HRME_id_temp1 || ''', ''' || replace(v_HRES_YearMonthtemp1, ' ', ' ') || ''', ''' || replace(v_HMonthName, ' ', ' ') || ''', ''' || replace(v_HRESD_Amount_temp1, ' ', '') || ''')';
                EXECUTE v_script22;
            ELSE
                v_script33 := 'UPDATE "temptable1" SET "' || v_HRMED_Name_temp1 || '" = ''' || replace(v_HRESD_Amount_temp1, ' ', '') || ''' WHERE "HRME_Id" = ''' || v_HRME_id_temp1 || ''' AND "HRES_YearMonth" = ''' || replace(v_HRES_YearMonthtemp1, ' ', '') || '''';
                EXECUTE v_script33;
            END IF;
        END LOOP;
    END LOOP;
    
    RETURN QUERY EXECUTE 
    'SELECT DISTINCT T.*, CAST(substring(T."HRES_YearMonth", 1, 4) AS bigint) AS "HRES_Year" 
    FROM "temptable1" T  
    INNER JOIN "IVRM_Month" M ON T."HMonthName" = M."IVRM_Month_Name" 
    ORDER BY "HRES_Year", M."IVRM_Month_Id"';
    
    DROP TABLE IF EXISTS "tablevarr_temp";
    DROP TABLE IF EXISTS "temptable1";
    
END;
$$;