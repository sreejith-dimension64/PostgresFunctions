CREATE OR REPLACE FUNCTION "dbo"."FeeTermwiseStudentDetails"(
    "MI_Id" VARCHAR(100),
    "ASMAY_ID" VARCHAR(100),
    "AMST_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "StudentName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "FTP_Paid_Amt" NUMERIC,
    "FMH_FeeName" VARCHAR,
    "FMH_Id" BIGINT,
    "FMT_Name" VARCHAR
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
    "rec" RECORD;
BEGIN
    -- exec FeeTermwiseStudentDetails '4','2','255'
    
    "monthyearsd" := '';
    "monthyearsd_select" := '';
    
    "sql1head" := 'SELECT DISTINCT "FMT_Name" FROM "Fee_Master_Terms" WHERE "FMT_ActiveFlag"=true AND "MI_Id"::INTEGER = ANY(STRING_TO_ARRAY(' || quote_literal("MI_Id") || ', '','')::INTEGER[])';
    
    FOR "rec" IN EXECUTE "sql1head"
    LOOP
        "cols" := "rec"."FMT_Name";
        
        IF "monthyearsd" = '' THEN
            "monthyearsd" := '"' || "cols" || '"';
            "monthyearsd_select" := 'COALESCE("' || "cols" || '",0) AS "' || "cols" || '"';
        ELSE
            "monthyearsd" := "monthyearsd" || ', "' || "cols" || '"';
            "monthyearsd_select" := "monthyearsd_select" || ', COALESCE("' || "cols" || '",0) AS "' || "cols" || '"';
        END IF;
    END LOOP;
    
    "query" := 'SELECT * FROM CROSSTAB(
        ''SELECT 
            F."AMST_Id", 
            CONCAT(F."AMST_FirstName",'' '',F."AMST_MiddleName",'' '',F."AMST_LastName") AS "StudentName",
            F."AMST_AdmNo",
            H."FMT_Name",
            COALESCE(SUM(C."FTP_Paid_Amt"),0) AS "FTP_Paid_Amt"
        FROM "Fee_Student_Status" A
        INNER JOIN "Fee_Y_Payment_School_Student" B ON A."AMST_Id"=B."AMST_Id" AND A."ASMAY_Id"=B."ASMAY_Id"
        INNER JOIN "Fee_T_Payment" C ON C."FYP_Id"=B."FYP_Id" AND A."FMA_Id"=C."FMA_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" D ON D."FMH_Id"=A."FMH_Id" AND A."FTI_Id"=D."FTI_Id"
        INNER JOIN "Fee_Master_Head" E ON A."FMH_Id"=E."FMH_Id" AND D."FMH_Id"=A."FMH_Id"
        INNER JOIN "Adm_M_Student" F ON F."AMST_Id"=A."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" G ON G."ASMAY_Id"=A."ASMAY_Id" AND A."AMST_Id"=G."AMST_Id"
        INNER JOIN "Fee_Master_Terms" H ON H."FMT_Id"=D."FMT_Id"
        INNER JOIN "Fee_Master_Amount" I ON I."FMA_Id"=A."FMA_Id"
        INNER JOIN "Fee_Master_Class_Category" J ON J."FMCC_Id"=I."FMCC_Id"
        WHERE F."AMST_Id"::INTEGER = ANY(STRING_TO_ARRAY(' || quote_literal("AMST_Id") || ', '','')::INTEGER[])
            AND A."ASMAY_Id"::INTEGER = ANY(STRING_TO_ARRAY(' || quote_literal("ASMAY_ID") || ', '','')::INTEGER[])
            AND A."MI_Id"::INTEGER = ANY(STRING_TO_ARRAY(' || quote_literal("MI_Id") || ', '','')::INTEGER[])
        GROUP BY F."AMST_Id", F."AMST_FirstName", F."AMST_MiddleName", F."AMST_LastName", F."AMST_AdmNo", H."FMT_Name"
        ORDER BY F."AMST_Id", H."FMT_Name"'',
        ''SELECT DISTINCT "FMT_Name" FROM "Fee_Master_Terms" WHERE "FMT_ActiveFlag"=true AND "MI_Id"::INTEGER = ANY(STRING_TO_ARRAY(' || quote_literal("MI_Id") || ', '','')::INTEGER[]) ORDER BY "FMT_Name"''
    ) AS ct("AMST_Id" BIGINT, "StudentName" TEXT, "AMST_AdmNo" VARCHAR, ' || "monthyearsd" || ' NUMERIC)';
    
    RETURN QUERY EXECUTE "query";
    
END;
$$;