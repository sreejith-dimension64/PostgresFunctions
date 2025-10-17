CREATE OR REPLACE FUNCTION "dbo"."FeeTermwiseFeeReceiptDetails"(
    "MI_Id" VARCHAR(100),
    "ASMAY_ID" VARCHAR(100),
    "AMST_Id" TEXT,
    "FYP_Id" TEXT
)
RETURNS TABLE(
    "FMH_FeeName" VARCHAR,
    "term_data" TEXT
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
    "term_record" RECORD;
BEGIN
    "monthyearsd" := '';
    "monthyearsd_select" := '';

    "sql1head" := 'SELECT DISTINCT d."FMT_Name"
        FROM (
            SELECT DISTINCT "FMT_Name", "FMT_order"
            FROM "Fee_Student_Status" A
            INNER JOIN "Fee_Y_Payment_School_Student" B ON A."AMST_Id" = B."AMST_Id" AND A."ASMAY_Id" = B."ASMAY_Id"
            INNER JOIN "Fee_T_Payment" C ON C."FYP_Id" = B."FYP_Id" AND A."FMA_Id" = C."FMA_Id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" D ON D."FMH_Id" = A."FMH_Id" AND A."FTI_Id" = D."FTI_Id"
            INNER JOIN "Fee_Master_Head" E ON A."FMH_Id" = E."FMH_Id" AND D."FMH_Id" = A."FMH_Id"
            INNER JOIN "Fee_Master_Terms" H ON H."FMT_Id" = D."FMT_Id"
            WHERE A."ASMAY_Id" = ANY(STRING_TO_ARRAY(' || quote_literal("ASMAY_ID") || ', '','')::BIGINT[])
                AND A."MI_Id" = ANY(STRING_TO_ARRAY(' || quote_literal("MI_Id") || ', '','')::BIGINT[])
                AND B."FYP_Id" = ANY(STRING_TO_ARRAY(' || quote_literal("FYP_Id") || ', '','')::BIGINT[])
        ) AS d
        ORDER BY d."FMT_order"';

    FOR "term_record" IN EXECUTE "sql1head"
    LOOP
        "cols" := "term_record"."FMT_Name";
        "monthyearsd" := COALESCE("monthyearsd", '') || COALESCE('"' || "cols" || '"' || ', ', '');
        "monthyearsd_select" := COALESCE("monthyearsd_select", '') || COALESCE('CAST("' || "cols" || '" AS VARCHAR) AS "' || "cols" || '"' || ', ', '');
    END LOOP;

    "monthyearsd" := LEFT("monthyearsd", LENGTH("monthyearsd") - 1);
    "monthyearsd_select" := LEFT("monthyearsd_select", LENGTH("monthyearsd_select") - 1);

    "query" := 'SELECT * FROM CROSSTAB(
        ''SELECT 
            s."FMH_FeeName",
            s."FMT_Name",
            COALESCE(SUM(s."FTP_Paid_Amt"), 0) AS "FTP_Paid_Amt"
        FROM (
            SELECT
                COALESCE(C."FTP_Paid_Amt", 0) AS "FTP_Paid_Amt",
                E."FMH_FeeName",
                H."FMT_Name",
                E."FMH_Order"
            FROM "Fee_Student_Status" A
            INNER JOIN "Fee_Y_Payment_School_Student" B ON A."AMST_Id" = B."AMST_Id" AND A."ASMAY_Id" = B."ASMAY_Id"
            INNER JOIN "Fee_T_Payment" C ON C."FYP_Id" = B."FYP_Id" AND A."FMA_Id" = C."FMA_Id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" D ON D."FMH_Id" = A."FMH_Id" AND A."FTI_Id" = D."FTI_Id"
            INNER JOIN "Fee_Master_Head" E ON A."FMH_Id" = E."FMH_Id" AND D."FMH_Id" = A."FMH_Id"
            INNER JOIN "Fee_Master_Terms" H ON H."FMT_Id" = D."FMT_Id"
            WHERE A."AMST_Id" = ANY(STRING_TO_ARRAY(' || quote_literal("AMST_Id") || ', '','')::BIGINT[])
                AND A."ASMAY_Id" = ANY(STRING_TO_ARRAY(' || quote_literal("ASMAY_ID") || ', '','')::BIGINT[])
                AND A."MI_Id" = ANY(STRING_TO_ARRAY(' || quote_literal("MI_Id") || ', '','')::BIGINT[])
                AND B."FYP_Id" = ANY(STRING_TO_ARRAY(' || quote_literal("FYP_Id") || ', '','')::BIGINT[])
        ) AS s
        GROUP BY s."FMH_FeeName", s."FMT_Name", s."FMH_Order"
        ORDER BY s."FMH_Order", s."FMH_FeeName"'',
        ''SELECT DISTINCT "FMT_Name" FROM (
            SELECT DISTINCT H."FMT_Name", H."FMT_order"
            FROM "Fee_Student_Status" A
            INNER JOIN "Fee_Y_Payment_School_Student" B ON A."AMST_Id" = B."AMST_Id" AND A."ASMAY_Id" = B."ASMAY_Id"
            INNER JOIN "Fee_T_Payment" C ON C."FYP_Id" = B."FYP_Id" AND A."FMA_Id" = C."FMA_Id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" D ON D."FMH_Id" = A."FMH_Id" AND A."FTI_Id" = D."FTI_Id"
            INNER JOIN "Fee_Master_Head" E ON A."FMH_Id" = E."FMH_Id" AND D."FMH_Id" = A."FMH_Id"
            INNER JOIN "Fee_Master_Terms" H ON H."FMT_Id" = D."FMT_Id"
            WHERE A."ASMAY_Id" = ANY(STRING_TO_ARRAY(' || quote_literal("ASMAY_ID") || ', '','')::BIGINT[])
                AND A."MI_Id" = ANY(STRING_TO_ARRAY(' || quote_literal("MI_Id") || ', '','')::BIGINT[])
                AND B."FYP_Id" = ANY(STRING_TO_ARRAY(' || quote_literal("FYP_Id") || ', '','')::BIGINT[])
        ) AS d ORDER BY "FMT_order"''
    ) AS ct("FMH_FeeName" VARCHAR, ' || "monthyearsd" || ' NUMERIC)';

    RETURN QUERY EXECUTE "query";

    RETURN;
END;
$$;