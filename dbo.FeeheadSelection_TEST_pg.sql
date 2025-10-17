CREATE OR REPLACE FUNCTION "dbo"."FeeheadSelection_TEST" (
    "@MI_Id" TEXT,
    "@FMG_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@fromdate" TEXT,
    "@todate" TEXT
)
RETURNS TABLE (
    "fmH_Id" INTEGER,
    "fmH_FeeName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@query" TEXT;
    "@ASMAY_Id_new" VARCHAR(100);
BEGIN

    IF "@ASMAY_Id" = '0' THEN
        
        "@query" := 
        'SELECT A."fmH_Id", A."fmH_FeeName" FROM "Fee_Master_Head" A
        INNER JOIN "Fee_Master_Amount" B ON A."FMH_Id" = B."FMH_Id"
        INNER JOIN "Fee_T_Payment" C ON C."FMA_Id" = B."FMA_Id"
        INNER JOIN "Fee_Y_Payment" D ON D."FYP_Id" = C."FYP_Id"
        WHERE B."FMG_Id" IN (' || "@FMG_Id" || ') AND A."MI_Id" = ' || "@MI_Id" || ' 
        AND D."FYP_Date"::date BETWEEN ''' || "@fromdate" || ''' AND ''' || "@todate" || '''
        GROUP BY A."fmH_Id", A."FmH_FeeName"
        
        UNION ALL
        
        SELECT A."fmH_Id", A."fmH_FeeName" FROM "Fee_Master_Head" A
        INNER JOIN "Fee_Y_Payment_ThirdParty" B ON B."FMH_Id" = A."FMH_Id"
        INNER JOIN "Fee_y_payment" C ON B."FYP_Id" = C."FYP_Id"
        WHERE C."MI_Id" = ' || "@MI_Id" || ' AND C."FYP_Date"::date BETWEEN ''' || "@fromdate" || ''' AND ''' || "@todate" || '''
        GROUP BY A."fmH_Id", A."FmH_FeeName"';
        
        RAISE NOTICE '%', "@query";
        
        RETURN QUERY EXECUTE "@query";
        
    ELSE
        
        "@query" := 
        'SELECT A."fmH_Id", A."fmH_FeeName" FROM "Fee_Master_Head" A
        INNER JOIN "Fee_Master_Amount" B ON A."FMH_Id" = B."FMH_Id"
        INNER JOIN "Fee_T_Payment" C ON C."FMA_Id" = B."FMA_Id"
        INNER JOIN "Fee_Y_Payment" D ON D."FYP_Id" = C."FYP_Id"
        WHERE B."FMG_Id" IN (' || "@FMG_Id" || ') AND D."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND A."MI_Id" = ' || "@MI_Id" || ' 
        AND D."FYP_Date"::date BETWEEN ''' || "@fromdate" || ''' AND ''' || "@todate" || '''
        GROUP BY A."fmH_Id", A."FmH_FeeName"
        
        UNION ALL
        
        SELECT A."fmH_Id", A."fmH_FeeName" FROM "Fee_Master_Head" A
        INNER JOIN "Fee_Y_Payment_ThirdParty" B ON B."FMH_Id" = A."FMH_Id"
        INNER JOIN "Fee_y_payment" C ON C."FYP_Id" = B."FYP_Id"
        WHERE C."ASMAY_Id" = ' || "@ASMAY_Id" || ' AND C."MI_Id" = ' || "@MI_Id" || ' AND C."FYP_Date"::date BETWEEN ''' || "@fromdate" || ''' AND ''' || "@todate" || '''
        GROUP BY A."fmH_Id", A."FmH_FeeName"';
        
        RETURN QUERY EXECUTE "@query";
        
    END IF;

END;
$$;