CREATE OR REPLACE FUNCTION "dbo"."Adm_Languagewiseadmissioncount"(
    "MI_ID" TEXT,
    "ASMAY_ID" TEXT
)
RETURNS TABLE(
    "ASMAY_Year" VARCHAR,
    "AMST_MotherTongue" VARCHAR
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "sqldynamic" TEXT;
    "PivotColumnNames" TEXT;
BEGIN
    
    -- Build pivot column names
    SELECT STRING_AGG('"' || "ASMCL_Classname" || '"', ',') INTO "PivotColumnNames"
    FROM (
        SELECT DISTINCT "ASMC"."ASMCL_Classname" 
        FROM "Adm_School_M_Class" "ASMC"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMCL_Id" = "ASMC"."ASMCL_Id"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" 
            AND "AMS"."MI_Id" = "ASMC"."MI_Id"
        WHERE "ASMC"."MI_Id" = "MI_ID"::BIGINT 
            AND "ASYS"."ASMAY_Id" = "ASMAY_ID"::BIGINT
        ORDER BY "ASMC"."ASMCL_Classname"
    ) AS "Pvcolumns";
    
    "PivotColumnNames" := COALESCE("PivotColumnNames", '');
    
    -- Build and execute dynamic SQL
    "sqldynamic" := 'SELECT * FROM CROSSTAB(
        ''SELECT "ASMAY"."ASMAY_Year"::TEXT || ''||'' || COALESCE("AMS"."AMST_MotherTongue", '''''''') AS groupkey,
                 "AMS"."AMST_MotherTongue",
                 "ASMC"."ASMCL_ClassName",
                 COALESCE(COUNT(DISTINCT "ASYS"."AMST_Id"), 0) AS Studentcount
          FROM "dbo"."Adm_M_Student" "AMS"
          INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id"
          INNER JOIN "Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "ASYS"."ASMAY_Id" 
              AND "ASMAY"."MI_Id" = "AMS"."MI_Id"
          INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id" 
              AND "ASMC"."MI_Id" = "ASMAY"."MI_Id"
          WHERE "ASYS"."ASMAY_ID" = ' || "ASMAY_ID" || ' 
              AND "AMS"."MI_Id" = ' || "MI_ID" || '
          GROUP BY "ASMAY"."ASMAY_Year", "ASMC"."ASMCL_ClassName", "AMS"."AMST_MotherTongue"
          ORDER BY 1, 3'',
        ''SELECT DISTINCT "ASMCL_Classname" 
          FROM "Adm_School_M_Class" 
          WHERE "MI_Id" = ' || "MI_ID" || '
          ORDER BY 1''
    ) AS ct(groupkey TEXT, "AMST_MotherTongue" VARCHAR, ' || "PivotColumnNames" || ' BIGINT)';
    
    RETURN QUERY EXECUTE "sqldynamic";
    
END;
$$;