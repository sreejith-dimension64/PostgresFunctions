
CREATE OR REPLACE FUNCTION "dbo"."HRMS_Pivot_Update"(
    p_MI_Id bigint,
    p_HRME_Id bigint,
    p_HRES_Year varchar(20)
)
RETURNS TABLE(
    "MI_Id" text,
    "HRME_Id" text,
    "HMonthName" varchar(60),
    "HRES_YearMonth" text,
    "IVRM_Month_Id" integer,
    "IVRM_Month_Name" text,
    column_data jsonb
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_dynamic text;
    v_dynamic1 text;
    v_pivot_cols text;
    v_PivotSelectColumnNames text;
    v_columnname1 text;
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
    v_count_temp1 bigint;
    v_script1 text;
    v_script22 text;
    v_script33 text;
    rec_tablevarr record;
    rec_insertdata record;
    rec_insertdata2 record;
    rec_createcolumns record;
BEGIN
    
    DROP TABLE IF EXISTS "HRME_PivotTemp";
    DROP TABLE IF EXISTS temp_temptable1;

    v_dynamic1 := '
    SELECT DISTINCT "HR_Employee_Salary"."HRME_Id",
    (CAST("HR_Employee_Salary"."HRES_Year" AS varchar(10)) || '''' || "HR_Employee_Salary"."HRES_Month") AS "HRES_YearMonth",
    "HR_Employee_Salary"."HRES_Month" AS "HMonthName", 
    replace(replace(COALESCE("HR_Master_EarningsDeductions"."HRMED_Name", ''''), ''  '', ''''), '' '', '''') AS "HRMED_Name",
    "HR_Employee_Salary_Details"."HRESD_Amount",
    "HR_Master_EarningsDeductions"."MI_Id"
    FROM "dbo"."HR_Employee_Salary" 
    INNER JOIN "dbo"."HR_Master_Employee" ON "HR_Employee_Salary"."HRME_Id" = "HR_Master_Employee"."HRME_Id" 
    INNER JOIN "dbo"."HR_Employee_Salary_Details" ON "HR_Employee_Salary"."HRES_Id" = "HR_Employee_Salary_Details"."HRES_Id" 
    INNER JOIN "dbo"."HR_Master_EarningsDeductions" ON "HR_Employee_Salary_Details"."HRMED_Id" = "HR_Master_EarningsDeductions"."HRMED_Id"
    WHERE "HR_Employee_Salary"."HRME_Id" = ' || p_HRME_Id || 
    ' AND "HR_Employee_Salary"."HRES_Year" = ''' || p_HRES_Year || 
    ''' AND "HR_Master_EarningsDeductions"."MI_Id" = ' || p_MI_Id;

    CREATE TEMP TABLE temp_tablevarr(
        "HRME_Id" text,
        "HRES_YearMonth" varchar(200),
        "HMonthName" varchar(60),
        "HRMED_Name" text,
        "HRESD_Amount" text,
        "MI_Id" text
    ) ON COMMIT DROP;

    EXECUTE 'INSERT INTO temp_tablevarr("HRME_Id", "HRES_YearMonth", "HMonthName", "HRMED_Name", "HRESD_Amount", "MI_Id") ' || v_dynamic1;

    CREATE TEMP TABLE temp_temptable1(
        "MI_Id" text,
        "HRME_Id" text,
        "HMonthName" varchar(60),
        "HRES_YearMonth" text
    ) ON COMMIT DROP;

    FOR rec_createcolumns IN 
        SELECT DISTINCT "HRMED_Name" FROM temp_tablevarr GROUP BY "HRMED_Name"
    LOOP
        v_columnname1 := rec_createcolumns."HRMED_Name";
        v_script1 := 'ALTER TABLE temp_temptable1 ADD COLUMN "' || v_columnname1 || '" text';
        EXECUTE v_script1;
    END LOOP;

    FOR rec_insertdata IN 
        SELECT DISTINCT "MI_Id", "HRME_Id", "HRES_YearMonth", "HMonthName", "HRMED_Name" 
        FROM temp_tablevarr 
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
            FROM temp_tablevarr 
            WHERE "HRME_Id" = v_HRME_id_temp1 AND "HRES_YearMonth" = v_HRES_YearMonthtemp1
        LOOP
            v_HRMED_Name_temp1 := rec_insertdata2."HRMED_Name";
            v_HRESD_Amount_temp1 := rec_insertdata2."HRESD_Amount";
            
            v_count_temp1 := v_count_temp1 + 1;

            IF v_count_temp1 = 1 THEN
                v_script22 := 'INSERT INTO temp_temptable1 ("MI_Id", "HRME_Id", "HRES_YearMonth", "HMonthName", "' || 
                    v_HRMED_Name_temp1 || '") VALUES (''' || v_MI_Id_temp1 || ''', ''' || v_HRME_id_temp1 || ''', ''' || 
                    replace(v_HRES_YearMonthtemp1, ' ', ' ') || ''', ''' || replace(v_HMonthName, ' ', ' ') || ''', ''' || 
                    replace(v_HRESD_Amount_temp1, ' ', '') || ''')';
                EXECUTE v_script22;
            ELSE
                v_script33 := 'UPDATE temp_temptable1 SET "' || v_HRMED_Name_temp1 || '" = ''' || 
                    replace(v_HRESD_Amount_temp1, ' ', '') || ''' WHERE "HRME_Id" = ''' || v_HRME_id_temp1 || 
                    ''' AND "HRES_YearMonth" = ''' || replace(v_HRES_YearMonthtemp1, ' ', '') || '''';
                EXECUTE v_script33;
            END IF;
        END LOOP;
    END LOOP;

    RETURN QUERY EXECUTE 
        'SELECT T."MI_Id", T."HRME_Id", T."HMonthName", T."HRES_YearMonth", M."IVRM_Month_Id", M."IVRM_Month_Name", 
         to_jsonb(T.*) - ''MI_Id'' - ''HRME_Id'' - ''HMonthName'' - ''HRES_YearMonth'' AS column_data
         FROM temp_temptable1 T 
         INNER JOIN "IVRM_Month" M ON T."HMonthName" = M."IVRM_Month_Name" 
         ORDER BY M."IVRM_Month_Id"';

    RETURN;
END;
$$;