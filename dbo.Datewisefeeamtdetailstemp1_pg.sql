CREATE OR REPLACE FUNCTION "dbo"."Datewisefeeamtdetailstemp1"(
    "ASMAY_Id" VARCHAR(100),
    "MI_Id" VARCHAR(100),
    "fromdate" DATE,
    "todate" DATE
)
RETURNS TABLE(
    "FYP_Date" TIMESTAMP,
    "Onlineamt" BIGINT,
    "Bank" BIGINT,
    "Cash" BIGINT,
    "Total" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Dates" TIMESTAMP;
    "Online" BIGINT;
    "bank" BIGINT;
    "cash" BIGINT;
    "total" BIGINT;
BEGIN
    DROP TABLE IF EXISTS "datewisecount";
    
    CREATE TEMP TABLE "datewisecount"(
        "FYP_Date" TIMESTAMP,
        "Onlineamt" BIGINT,
        "Bank" BIGINT,
        "Cash" BIGINT,
        "Total" BIGINT
    );
    
    SELECT CAST("FYP_Date" AS DATE) INTO "Dates"
    FROM "dbo"."Fee_Y_Payment" 
    WHERE "MI_Id" = "MI_Id" 
        AND "ASMAY_Id" = "ASMAY_Id" 
        AND "FYP_Date" BETWEEN "fromdate" AND "todate" 
    GROUP BY "FYP_Date"
    LIMIT 1;
    
    SELECT SUM("FYP_Tot_Amount") INTO "Online"
    FROM "dbo"."Fee_Y_Payment" 
    WHERE "MI_Id" = "MI_Id" 
        AND "ASMAY_Id" = "ASMAY_Id" 
        AND "FYP_Bank_Or_Cash" = 'O' 
        AND "FYP_Date" BETWEEN "fromdate" AND "todate" 
    GROUP BY "FYP_Date"
    LIMIT 1;
    
    SELECT SUM("FYP_Tot_Amount") INTO "bank"
    FROM "dbo"."Fee_Y_Payment" 
    WHERE "MI_Id" = "MI_Id" 
        AND "ASMAY_Id" = "ASMAY_Id" 
        AND "FYP_Bank_Or_Cash" = 'B' 
        AND "FYP_Date" BETWEEN "fromdate" AND "todate" 
    GROUP BY "FYP_Date"
    LIMIT 1;
    
    SELECT SUM("FYP_Tot_Amount") INTO "cash"
    FROM "dbo"."Fee_Y_Payment" 
    WHERE "MI_Id" = "MI_Id" 
        AND "ASMAY_Id" = "ASMAY_Id" 
        AND "FYP_Bank_Or_Cash" = 'C' 
        AND "FYP_Date" BETWEEN "fromdate" AND "todate" 
    GROUP BY "FYP_Date"
    LIMIT 1;
    
    SELECT SUM("FYP_Tot_Amount") INTO "total"
    FROM "dbo"."Fee_Y_Payment" 
    WHERE "MI_Id" = "MI_Id" 
        AND "ASMAY_Id" = "ASMAY_Id" 
        AND "FYP_Bank_Or_Cash" = 'C' 
        AND "FYP_Date" BETWEEN "fromdate" AND "todate" 
    GROUP BY "FYP_Date"
    LIMIT 1;
    
    INSERT INTO "datewisecount"("FYP_Date", "Onlineamt", "Bank", "Cash", "Total")
    VALUES("Dates", "Online", "bank", "cash", "total");
    
    RETURN QUERY SELECT * FROM "datewisecount";
    
END;
$$;