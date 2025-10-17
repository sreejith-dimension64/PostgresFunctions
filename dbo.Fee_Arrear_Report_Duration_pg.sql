CREATE OR REPLACE FUNCTION "dbo"."Fee_Arrear_Report_Duration"(
    "Terms" TEXT,
    "Mi_Id" BIGINT
)
RETURNS TABLE(
    "MONTH123" TEXT,
    "ENDDATE" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ID TEXT;
    v_sql1 TEXT;
BEGIN
    v_ID := "Mi_Id"::TEXT;
    
    v_sql1 := 'SELECT "MIMONTH" || ''-'' || "MAMONTH" AS "MONTH123", "EFG"."ENDDATE" 
    FROM (
        SELECT 
            TO_CHAR(TO_DATE(MIN("FTDD_Month")::TEXT, ''MM''), ''Month'') AS "MIMONTH",
            TO_CHAR(TO_DATE(MAX("FTDD_Month")::TEXT, ''MM''), ''Month'') AS "MAMONTH" 
        FROM (
            SELECT DISTINCT 
                "Fee_Master_Terms_FeeHeads"."FMT_Id",
                "Fee_Master_Terms_FeeHeads"."FTI_Id",
                "Fee_Student_Status"."FMA_Id", 
                "FTDD_Day",
                TO_CHAR(TO_DATE("FTDD_Month"::TEXT, ''MM''), ''Month'') AS "DueMonth",
                "FTDD_Month"::INTEGER AS "FTDD_Month" 
            FROM 
                "Fee_Master_Terms_FeeHeads",
                "Fee_Student_Status",
                "Fee_T_Due_Date" 
            WHERE 
                "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
                AND "Fee_T_Due_Date"."FMA_Id" = "Fee_Student_Status"."FMA_Id" 
                AND "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "Terms" || ') 
                AND "Fee_Master_Terms_FeeHeads"."MI_Id" = "Fee_Student_Status"."MI_Id" 
                AND "Fee_Student_Status"."MI_Id" = ' || v_ID || '
        ) AS "ABC"
    ) AS "ABC123",
    (
        SELECT 
            MAX("FTDD_Day") || ''   '' || TO_CHAR(TO_DATE(MAX("ABC21"."MAXMONTH")::TEXT, ''MM''), ''Month'') AS "ENDDATE" 
        FROM (
            SELECT DISTINCT 
                "Fee_Master_Terms_FeeHeads"."FMT_Id",
                "Fee_Master_Terms_FeeHeads"."FTI_Id",
                "Fee_Student_Status"."FMA_Id", 
                "FTDD_Day",
                ("FTDD_Day" || '' '' || TO_CHAR(TO_DATE("FTDD_Month"::TEXT, ''MM''), ''Month'')) AS "DueMonth",
                "FTDD_Month"::INTEGER AS "FTDD_Month" 
            FROM 
                "Fee_Master_Terms_FeeHeads",
                "Fee_Student_Status",
                "Fee_T_Due_Date" 
            WHERE 
                "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
                AND "Fee_T_Due_Date"."FMA_Id" = "Fee_Student_Status"."FMA_Id" 
                AND "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "Terms" || ') 
                AND "Fee_Master_Terms_FeeHeads"."MI_Id" = "Fee_Student_Status"."MI_Id" 
                AND "Fee_Student_Status"."MI_Id" = ' || v_ID || ' 
                AND "Fee_T_Due_Date"."FTDD_Month" = (
                    SELECT MAX("FTDD_Month") AS "MAXMONTH" 
                    FROM (
                        SELECT DISTINCT 
                            "Fee_Master_Terms_FeeHeads"."FMT_Id",
                            "Fee_Master_Terms_FeeHeads"."FTI_Id",
                            "Fee_Student_Status"."FMA_Id", 
                            "FTDD_Day",
                            ("FTDD_Day" || '' '' || TO_CHAR(TO_DATE("FTDD_Month"::TEXT, ''MM''), ''Month'')) AS "DueMonth",
                            "FTDD_Month"::INTEGER AS "FTDD_Month" 
                        FROM 
                            "Fee_Master_Terms_FeeHeads",
                            "Fee_Student_Status",
                            "Fee_T_Due_Date" 
                        WHERE 
                            "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
                            AND "Fee_T_Due_Date"."FMA_Id" = "Fee_Student_Status"."FMA_Id" 
                            AND "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "Terms" || ') 
                            AND "Fee_Master_Terms_FeeHeads"."MI_Id" = "Fee_Student_Status"."MI_Id" 
                            AND "Fee_Student_Status"."MI_Id" = ' || v_ID || '
                    ) AS "ABC2"
                )
        ) AS "ABC12",
        (
            SELECT MAX("FTDD_Month") AS "MAXMONTH" 
            FROM (
                SELECT DISTINCT 
                    "Fee_Master_Terms_FeeHeads"."FMT_Id",
                    "Fee_Master_Terms_FeeHeads"."FTI_Id",
                    "Fee_Student_Status"."FMA_Id", 
                    "FTDD_Day",
                    ("FTDD_Day" || '' '' || TO_CHAR(TO_DATE("FTDD_Month"::TEXT, ''MM''), ''Month'')) AS "DueMonth",
                    "FTDD_Month"::INTEGER AS "FTDD_Month" 
                FROM 
                    "Fee_Master_Terms_FeeHeads",
                    "Fee_Student_Status",
                    "Fee_T_Due_Date" 
                WHERE 
                    "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
                    AND "Fee_T_Due_Date"."FMA_Id" = "Fee_Student_Status"."FMA_Id" 
                    AND "Fee_Master_Terms_FeeHeads"."FMT_Id" IN (' || "Terms" || ') 
                    AND "Fee_Master_Terms_FeeHeads"."MI_Id" = "Fee_Student_Status"."MI_Id" 
                    AND "Fee_Student_Status"."MI_Id" = ' || v_ID || '
            ) AS "ABC2"
        ) AS "ABC21"
    ) AS "EFG"';
    
    RETURN QUERY EXECUTE v_sql1;
    
END;
$$;