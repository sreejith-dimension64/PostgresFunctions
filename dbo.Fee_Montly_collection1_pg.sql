CREATE OR REPLACE FUNCTION "dbo"."Fee_Montly_collection1"(
    "fromdate" TEXT,
    "todate" TEXT,
    "flag" TEXT,
    "allorind" TEXT,
    "amstid" VARCHAR(100),
    "groupids" TEXT,
    "left" VARCHAR(100)
)
RETURNS TABLE(
    "result" JSON
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "cols" TEXT;
    "query" TEXT;
    "monthyearsd" TEXT := '';
    "monthids" TEXT;
    "monthids1" TEXT;
    "recno" TEXT;
    "Date" TEXT;
    "total" TEXT;
    "sql1" TEXT;
    "leftflag" VARCHAR(100);
    "col_record" RECORD;
BEGIN
    "total" := 'Total';
    "recno" := 'Rece.No:';
    "Date" := 'Date:';
    
    "sql1" := 'SELECT DISTINCT (TO_CHAR("Fee_Y_Payment"."FYP_Date", ''Month'') || TO_CHAR("Fee_Y_Payment"."FYP_Date", ''YYYY'')) AS monthyear
    FROM "dbo"."Adm_School_Y_Student" 
    INNER JOIN "dbo"."Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
    INNER JOIN "Fee_Y_Payment_School_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
    INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id" 
    WHERE "Fee_Y_Payment"."FYP_Id" IN
    (SELECT "Fee_T_Payment"."FYP_Id" FROM "dbo"."Fee_Master_Amount" 
    INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_Master_Amount"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
    INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "Fee_Master_Amount"."FMH_Id" = "Fee_Yearly_Group_Head_Mapping"."FMH_Id"
    INNER JOIN "dbo"."Fee_Yearly_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id" 
    WHERE "Fee_Yearly_Group"."FMG_Id" IN (' || "groupids" || '))
    AND TO_DATE(TO_CHAR("Fee_Y_Payment"."fyp_date", ''DD/MM/YYYY''), ''DD/MM/YYYY'') 
        BETWEEN TO_DATE(''' || "fromdate" || ''', ''DD/MM/YYYY'') 
        AND TO_DATE(''' || "todate" || ''', ''DD/MM/YYYY'')
    AND ("Fee_Y_Payment"."FYP_Chq_Bounce" <> ''' || "flag" || ''')
    ORDER BY monthyear';
    
    FOR "col_record" IN EXECUTE "sql1"
    LOOP
        "monthyearsd" := COALESCE("monthyearsd", '') || COALESCE("col_record".monthyear || ', ', '');
    END LOOP;
    
    IF "monthyearsd" IS NOT NULL AND LENGTH("monthyearsd") > 0 THEN
        "monthyearsd" := LEFT("monthyearsd", LENGTH("monthyearsd") - 1);
    END IF;
    
    IF "allorind" = 'all' THEN
        IF "left" = '1' THEN
            "leftflag" := 'L';
            
            "query" := 'SELECT DISTINCT *, COALESCE(aa, ''' || "total" || ''') AS " ", SUM(aaa) AS "Total" 
            FROM (SELECT DISTINCT "Adm_M_Student"."AMST_Id", 
                "Adm_M_Student"."AMST_AdmNo" AS admno, 
                "Adm_M_Student"."AMST_RegistrationNo" AS regno, 
                ("Adm_M_Student"."AMST_FirstName" || "Adm_M_Student"."AMST_MiddleName" || "Adm_M_Student"."AMST_LastName") AS "Name",
                "Fee_Y_Payment"."FYP_Tot_Amount" AS aaa, 
                '''' AS aa,
                "Fee_Y_Payment"."FYP_Tot_Amount" AS amount,
                (TO_CHAR("Fee_Y_Payment"."FYP_Date", ''Month'') || TO_CHAR("Fee_Y_Payment"."FYP_Date", ''YYYY'')) AS monthyear,
                (''' || "recno" || ''' || CAST("FYP_Receipt_No" AS TEXT) || ''' || "Date" || ''' || TO_CHAR("FYP_Date", ''DD/MM/YYYY'')) AS redate
            FROM "dbo"."Adm_School_Y_Student" 
            INNER JOIN "dbo"."Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
            INNER JOIN "Fee_Y_Payment_School_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id" 
            WHERE "Fee_Y_Payment"."FYP_Id" IN
            (SELECT "Fee_T_Payment"."FYP_Id" FROM "dbo"."Fee_Master_Amount" 
            INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_Master_Amount"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "Fee_Master_Amount"."FMH_Id" = "Fee_Yearly_Group_Head_Mapping"."FMH_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id" 
            WHERE "Fee_Yearly_Group"."FMG_Id" IN (' || "groupids" || '))
            AND TO_DATE(TO_CHAR("Fee_Y_Payment"."fyp_date", ''DD/MM/YYYY''), ''DD/MM/YYYY'') 
                BETWEEN TO_DATE(''' || "fromdate" || ''', ''DD/MM/YYYY'') 
                AND TO_DATE(''' || "todate" || ''', ''DD/MM/YYYY'')
            AND ("Fee_Y_Payment"."FYP_Chq_Bounce" <> ''' || "flag" || ''')
            AND "amst_sol" = ''' || "leftflag" || ''') AS s
            PIVOT (SUM(amount) FOR monthyear IN(' || "monthyearsd" || ')) AS p
            GROUP BY ROLLUP(aaa), "AMST_Id", "Name", admno, regno, aaa, aa, redate, ' || "monthyearsd";
        ELSE
            "query" := 'SELECT DISTINCT *, COALESCE(aa, ''' || "total" || ''') AS " ", SUM(aaa) AS "Total" 
            FROM (SELECT DISTINCT "Adm_M_Student"."AMST_Id", 
                "Adm_M_Student"."AMST_AdmNo" AS admno, 
                "Adm_M_Student"."AMST_RegistrationNo" AS regno, 
                ("Adm_M_Student"."AMST_FirstName" || "Adm_M_Student"."AMST_MiddleName" || "Adm_M_Student"."AMST_LastName") AS "Name",
                "Fee_Y_Payment"."FYP_Tot_Amount" AS aaa, 
                '''' AS aa,
                "Fee_Y_Payment"."FYP_Tot_Amount" AS amount,
                (TO_CHAR("Fee_Y_Payment"."FYP_Date", ''Month'') || TO_CHAR("Fee_Y_Payment"."FYP_Date", ''YYYY'')) AS monthyear,
                (''' || "recno" || ''' || CAST("FYP_Receipt_No" AS TEXT) || ''' || "Date" || ''' || TO_CHAR("FYP_Date", ''DD/MM/YYYY'')) AS redate
            FROM "dbo"."Adm_School_Y_Student" 
            INNER JOIN "dbo"."Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
            INNER JOIN "Fee_Y_Payment_School_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
            INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id" 
            WHERE "Fee_Y_Payment"."FYP_Id" IN
            (SELECT "Fee_T_Payment"."FYP_Id" FROM "dbo"."Fee_Master_Amount" 
            INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_Master_Amount"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "Fee_Master_Amount"."FMH_Id" = "Fee_Yearly_Group_Head_Mapping"."FMH_Id"
            INNER JOIN "dbo"."Fee_Yearly_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id" 
            WHERE "Fee_Yearly_Group"."FMG_Id" IN (' || "groupids" || '))
            AND TO_DATE(TO_CHAR("Fee_Y_Payment"."fyp_date", ''DD/MM/YYYY''), ''DD/MM/YYYY'') 
                BETWEEN TO_DATE(''' || "fromdate" || ''', ''DD/MM/YYYY'') 
                AND TO_DATE(''' || "todate" || ''', ''DD/MM/YYYY'')
            AND ("Fee_Y_Payment"."FYP_Chq_Bounce" <> ''' || "flag" || ''')) AS s
            PIVOT (SUM(amount) FOR monthyear IN(' || "monthyearsd" || ')) AS p
            GROUP BY ROLLUP(aaa), "AMST_Id", "Name", admno, regno, aaa, aa, redate, ' || "monthyearsd";
        END IF;
    ELSE
        "query" := ';WITH cte AS (
        SELECT DISTINCT "Adm_M_Student"."AMST_Id", 
            "Adm_M_Student"."AMST_AdmNo" AS admno, 
            "Adm_M_Student"."AMST_RegistrationNo" AS regno,
            COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''') AS "Name",
            "Fee_Y_Payment"."FYP_Tot_Amount" AS aaa, 
            '''' AS aa,
            "Fee_Y_Payment"."FYP_Tot_Amount" AS amount,
            EXTRACT(MONTH FROM "Fee_Y_Payment"."FYP_Date") AS "FYP_Month",
            (TO_CHAR("Fee_Y_Payment"."FYP_Date", ''Month'') || TO_CHAR("Fee_Y_Payment"."FYP_Date", ''YYYY'')) AS monthyear,
            (''Rece.No:'' || CAST("FYP_Receipt_No" AS TEXT) || ''     Date:'' || TO_CHAR("FYP_Date", ''DD/MM/YYYY'')) AS redate,
            "Fee_Y_Payment"."FYP_Remarks"
        FROM "dbo"."Adm_School_Y_Student"
        INNER JOIN "dbo"."Adm_M_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Fee_Y_Payment_School_Student"."AMST_Id"
        INNER JOIN "dbo"."Fee_Y_Payment" ON "Fee_Y_Payment_School_Student"."FYP_Id" = "Fee_Y_Payment"."FYP_Id"
        WHERE "Fee_Y_Payment"."FYP_Id" IN
        (SELECT "Fee_T_Payment"."FYP_Id" FROM "dbo"."Fee_Master_Amount"
        INNER JOIN "dbo"."Fee_T_Payment" ON "Fee_Master_Amount"."FMA_Id" = "Fee_T_Payment"."FMA_Id"
        INNER JOIN "dbo"."Fee_Yearly_Group_Head_Mapping" ON "Fee_Master_Amount"."FMH_Id" = "Fee_Yearly_Group_Head_Mapping"."FMH_Id"
        INNER JOIN "dbo"."Fee_Yearly_Group" ON "Fee_Yearly_Group_Head_Mapping"."FMG_Id" = "Fee_Yearly_Group"."FMG_Id"
        WHERE "Fee_Yearly_Group"."FMG_Id" IN (' || "groupids" || '))
        AND "Adm_School_Y_Student"."AMST_Id" IN
        (SELECT "AMST_Id" FROM "Adm_School_Y_Student" WHERE "AMST_Id" = ' || "amstid" || ')
        AND TO_DATE(TO_CHAR("Fee_Y_Payment"."fyp_date", ''DD/MM/YYYY''), ''DD/MM/YYYY'') 
            BETWEEN TO_DATE(''' || "fromdate" || ''', ''DD/MM/YYYY'') 
            AND TO_DATE(''' || "todate" || ''', ''DD/MM/YYYY'')
        AND ("Fee_Y_Payment"."FYP_Chq_Bounce" <> ''BO'')
        )
        SELECT DISTINCT "AMST_Id", "Name", admno, regno, SUM(aaa) AS "Total", aa, redate, 
        COALESCE("August2017", 0) AS "August2017", COALESCE("October2017", 0) AS "October2017", COALESCE("September2017", 0) AS "September2017"
        FROM cte
        PIVOT (SUM(cte.amount) FOR monthyear IN(' || "monthyearsd" || ')) AS p
        GROUP BY ROLLUP(aaa), "AMST_Id", "Name", admno, regno, aaa, aa, redate, ' || "monthyearsd";
    END IF;
    
    RETURN QUERY EXECUTE "query";
    
END;
$$;