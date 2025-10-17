CREATE OR REPLACE FUNCTION "dbo"."Adm_Statewiseadmissioncount"(
    p_MI_ID TEXT,
    p_ASMAY_ID TEXT,
    p_ASMCL_Id TEXT,
    p_IVRMMS_ID TEXT
)
RETURNS TABLE(
    "ASMAY_Year" TEXT,
    "IVRMMS_Name" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic TEXT;
    v_PivotColumnNames TEXT := '';
    v_column_record RECORD;
BEGIN
    
    -- Build pivot column names
    FOR v_column_record IN (
        SELECT DISTINCT "ASMC"."ASMCL_Classname" 
        FROM "Adm_School_M_Class" "ASMC"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMCL_Id" = "ASMC"."ASMCL_Id"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" 
            AND "AMS"."MI_Id" = "ASMC"."MI_Id"
        WHERE "ASMC"."MI_Id" = p_MI_ID::BIGINT
    )
    LOOP
        v_PivotColumnNames := v_PivotColumnNames || 
            CASE WHEN v_PivotColumnNames = '' THEN '' ELSE ',' END || 
            '"' || v_column_record."ASMCL_Classname" || '"';
    END LOOP;
    
    -- Build dynamic SQL for crosstab pivot
    v_sqldynamic := 'SELECT "ASMAY_Year", "IVRMMS_Name", ' || v_PivotColumnNames || 
    ' FROM crosstab(
        ''SELECT "ASMAY"."ASMAY_Year"::TEXT || ''||'' || "IMS"."IVRMMS_Name"::TEXT AS row_id,
                 "ASMAY"."ASMAY_Year",
                 "IMS"."IVRMMS_Name",
                 "ASMC"."ASMCL_ClassName",
                 COUNT(DISTINCT "ASYS"."AMST_Id")::BIGINT AS "StudentCount"
          FROM "dbo"."Adm_M_Student" "AMS"
          INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id"
          INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ASYS"."ASMAY_Id" 
              AND "ASMAY"."MI_Id" = "AMS"."MI_Id"
          INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id" 
              AND "ASMC"."MI_Id" = "ASMAY"."MI_Id"
          INNER JOIN "IVRM_Master_State" "IMS" ON "IMS"."IVRMMS_Id" = "AMS"."AMST_State"
          WHERE "ASYS"."ASMAY_ID" IN (' || p_ASMAY_ID || ') 
              AND "AMS"."MI_Id" = ' || p_MI_ID || ' 
              AND "AMS"."AMST_State" IN (' || p_IVRMMS_ID || ')
          GROUP BY "ASMAY"."ASMAY_Year", "ASMC"."ASMCL_ClassName", "IMS"."IVRMMS_Name"
          ORDER BY "ASMAY"."ASMAY_Year"'',
        ''SELECT DISTINCT "ASMCL_Classname" FROM "Adm_School_M_Class" 
          WHERE "MI_Id" = ' || p_MI_ID || ' ORDER BY 1''
    ) AS ct(row_id TEXT, "ASMAY_Year" TEXT, "IVRMMS_Name" TEXT, ' || v_PivotColumnNames || ' BIGINT)';
    
    -- Execute dynamic SQL
    RETURN QUERY EXECUTE v_sqldynamic;
    
END;
$$;