CREATE OR REPLACE FUNCTION "dbo"."Datewisefeeamountdetails"(
    "p_ASMAY_Id" VARCHAR(100),
    "p_MI_Id" VARCHAR(100),
    "p_fromdate" DATE,
    "p_todate" DATE
)
RETURNS TABLE(
    "FYP_Date" TEXT,
    "Onlineamt" BIGINT,
    "Bank" BIGINT,
    "Cash" BIGINT,
    "Total" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Dates" TIMESTAMP;
    "v_Online" BIGINT;
    "v_bank" BIGINT;
    "v_cash" BIGINT;
    "v_total" BIGINT;
    "v_Rcount" BIGINT;
    "rec" RECORD;
BEGIN
    DROP TABLE IF EXISTS "datewisecount";
    
    CREATE TEMP TABLE "datewisecount"(
        "FYP_Date" TIMESTAMP,
        "Onlineamt" BIGINT,
        "Bank" BIGINT,
        "Cash" BIGINT,
        "Total" BIGINT
    );
    
    FOR "rec" IN 
        SELECT DISTINCT CAST("FYP_Date" AS DATE) AS "date_val"
        FROM "dbo"."Fee_Y_Payment" 
        WHERE "MI_Id" = "p_MI_Id" 
            AND "ASMAY_Id" = "p_ASMAY_Id" 
            AND "FYP_Date" BETWEEN "p_fromdate" AND "p_todate"
        GROUP BY CAST("FYP_Date" AS DATE)
    LOOP
        "v_Dates" := "rec"."date_val";
        "v_Online" := 0;
        "v_bank" := 0;
        "v_cash" := 0;
        "v_total" := 0;
        
        SELECT COALESCE(SUM("FYP_Tot_Amount"), 0) INTO "v_Online"
        FROM "dbo"."Fee_Y_Payment" 
        WHERE "MI_Id" = "p_MI_Id" 
            AND "ASMAY_Id" = "p_ASMAY_Id" 
            AND "FYP_Bank_Or_Cash" = 'O' 
            AND CAST("FYP_Date" AS DATE) = "v_Dates"
        GROUP BY CAST("FYP_Date" AS DATE);
        
        SELECT COALESCE(SUM("FYP_Tot_Amount"), 0) INTO "v_bank"
        FROM "dbo"."Fee_Y_Payment" 
        WHERE "MI_Id" = "p_MI_Id" 
            AND "ASMAY_Id" = "p_ASMAY_Id" 
            AND "FYP_Bank_Or_Cash" = 'B' 
            AND CAST("FYP_Date" AS DATE) = "v_Dates"
        GROUP BY CAST("FYP_Date" AS DATE);
        
        SELECT COALESCE(SUM("FYP_Tot_Amount"), 0) INTO "v_cash"
        FROM "dbo"."Fee_Y_Payment" 
        WHERE "MI_Id" = "p_MI_Id" 
            AND "ASMAY_Id" = "p_ASMAY_Id" 
            AND "FYP_Bank_Or_Cash" = 'C' 
            AND CAST("FYP_Date" AS DATE) = "v_Dates"
        GROUP BY CAST("FYP_Date" AS DATE);
        
        SELECT COALESCE(SUM("FYP_Tot_Amount"), 0) INTO "v_total"
        FROM "dbo"."Fee_Y_Payment" 
        WHERE "MI_Id" = "p_MI_Id" 
            AND "ASMAY_Id" = "p_ASMAY_Id" 
            AND CAST("FYP_Date" AS DATE) = "v_Dates"
        GROUP BY CAST("FYP_Date" AS DATE);
        
        SELECT COUNT(*) INTO "v_Rcount"
        FROM "datewisecount" 
        WHERE CAST("FYP_Date" AS DATE) = "v_Dates" 
            AND "Onlineamt" = "v_Online" 
            AND "Bank" = "v_bank" 
            AND "Cash" = "v_cash" 
            AND "Total" = "v_total";
        
        IF ("v_Rcount" = 0) THEN
            INSERT INTO "datewisecount"("FYP_Date", "Onlineamt", "Bank", "Cash", "Total") 
            VALUES("v_Dates", "v_Online", "v_bank", "v_cash", "v_total");
        END IF;
    END LOOP;
    
    RETURN QUERY 
    SELECT 
        TO_CHAR(CAST("d"."FYP_Date" AS DATE), 'DD/MM/YYYY') AS "FYP_Date",
        "d"."Onlineamt",
        "d"."Bank",
        "d"."Cash",
        "d"."Total"
    FROM "datewisecount" "d";
    
    DROP TABLE IF EXISTS "datewisecount";
END;
$$;