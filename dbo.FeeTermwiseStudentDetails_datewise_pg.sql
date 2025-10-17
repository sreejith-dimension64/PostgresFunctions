CREATE OR REPLACE FUNCTION "dbo"."FeeTermwiseStudentDetails_datewise"(
    "MI_Id" VARCHAR(100),
    "ASMAY_ID" VARCHAR(100),
    "AMST_Id" TEXT
)
RETURNS TABLE(
    "classname" VARCHAR,
    "sectionname" VARCHAR,
    "AMST_Id" BIGINT,
    "StudentName" TEXT,
    "AMST_AdmNo" VARCHAR
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "head_names" TEXT;
    "sql1head" TEXT;
    "sqlhead" TEXT;
    "cols" TEXT;
    "query" TEXT;
    "monthyearsd" TEXT;
    "monthyearsd_select" TEXT;
    "objcursor" REFCURSOR;
    "full_query" TEXT;
    "term_columns" TEXT := '';
    "term_columns_select" TEXT := '';
BEGIN
    
    "sql1head" := 'SELECT DISTINCT "FMT_Name" FROM "Fee_Master_Terms" WHERE "FMT_ActiveFlag"=true AND "MI_Id"::VARCHAR IN (' || "MI_Id" || ')';
    
    "monthyearsd" := '';
    "monthyearsd_select" := '';
    
    FOR "cols" IN EXECUTE "sql1head"
    LOOP
        "monthyearsd" := COALESCE("monthyearsd", '') || COALESCE('"' || "cols" || '"' || ', ', '');
        "monthyearsd_select" := COALESCE("monthyearsd_select", '') || COALESCE('CAST("' || "cols" || '" AS VARCHAR) AS "' || "cols" || '"' || ', ', '');
    END LOOP;
    
    "monthyearsd" := LEFT("monthyearsd", LENGTH("monthyearsd")-2);
    "monthyearsd_select" := LEFT("monthyearsd_select", LENGTH("monthyearsd_select")-2);
    
    "query" := '
    SELECT "classname","sectionname","AMST_Id","StudentName","AMST_AdmNo",' || "monthyearsd_select" || ' 
    FROM crosstab(
        ''SELECT "K"."ASMCL_ClassName" as classname, 
                 "L"."ASMC_SectionName" as sectionname,
                 "F"."AMST_Id", 
                 CONCAT("F"."AMST_FirstName",'''''' '''''''', "F"."AMST_MiddleName",'''''' '''''''', "F"."AMST_LastName") as StudentName,
                 "F"."AMST_AdmNo",
                 "H"."FMT_Name",
                 COALESCE("C"."FTP_Paid_Amt", 0) as FTP_Paid_Amt
          FROM "Fee_Student_Status" "A"
          INNER JOIN "Fee_Y_Payment_School_Student" "B" ON "A"."AMST_Id" = "B"."AMST_Id" AND "A"."ASMAY_Id" = "B"."ASMAY_Id"
          INNER JOIN "Fee_T_Payment" "C" ON "C"."FYP_Id" = "B"."FYP_Id" AND "A"."FMA_Id" = "C"."FMA_Id"
          INNER JOIN "Fee_Master_Terms_FeeHeads" "D" ON "D"."FMH_Id" = "A"."FMH_Id" AND "A"."FTI_Id" = "D"."FTI_Id"
          INNER JOIN "Fee_Master_Head" "E" ON "A"."FMH_Id" = "E"."FMH_Id" AND "D"."FMH_Id" = "A"."FMH_Id"
          INNER JOIN "Adm_M_Student" "F" ON "F"."AMST_Id" = "A"."AMST_Id"
          INNER JOIN "Adm_School_Y_Student" "G" ON "G"."ASMAY_Id" = "A"."ASMAY_Id" AND "A"."AMST_Id" = "G"."AMST_Id"
          INNER JOIN "Fee_Master_Terms" "H" ON "H"."FMT_Id" = "D"."FMT_Id"
          INNER JOIN "Fee_Master_Amount" "I" ON "I"."FMA_Id" = "A"."FMA_Id"
          INNER JOIN "Fee_Master_Class_Category" "J" ON "J"."FMCC_Id" = "I"."FMCC_Id"
          INNER JOIN "Adm_School_M_Class" "K" ON "K"."ASMCL_Id" = "G"."ASMCL_Id"
          INNER JOIN "Adm_School_M_Section" "L" ON "L"."ASMS_Id" = "G"."ASMS_Id"
          WHERE "F"."AMST_Id"::VARCHAR IN (' || "AMST_Id" || ') 
            AND "A"."ASMAY_Id"::VARCHAR IN (' || "ASMAY_ID" || ') 
            AND "A"."MI_Id"::VARCHAR IN (' || "MI_Id" || ')
          ORDER BY 1, 2, 3, 4, 5, 6''
    ) AS ct(
        "classname" VARCHAR, 
        "sectionname" VARCHAR, 
        "AMST_Id" BIGINT, 
        "StudentName" TEXT, 
        "AMST_AdmNo" VARCHAR, 
        ' || "monthyearsd" || '
    )';
    
    RETURN QUERY EXECUTE "query";
    
END;
$$;