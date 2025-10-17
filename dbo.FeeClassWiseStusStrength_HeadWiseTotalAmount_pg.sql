CREATE OR REPLACE FUNCTION "dbo"."FeeClassWiseStusStrength_HeadWiseTotalAmount"(
    "MI_Id" VARCHAR(200),
    "ASMAY_Id" VARCHAR(200)
)
RETURNS TABLE(
    "ASMCL_ClassName" VARCHAR,
    "NewAdm" BIGINT,
    "oldAdm" BIGINT,
    "TotalStrength" BIGINT,
    "FMH_FeeName" VARCHAR,
    "FMA_Amount" NUMERIC,
    "FMH_FeeName_N" VARCHAR,
    "FMA_Amount_N" NUMERIC,
    "TutionFees_TotalAmount" NUMERIC,
    "CautionDeposit_TotalAmount" NUMERIC,
    "TotalPayableAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "CFMH_Id" BIGINT;
    "TFeeFMH_Id" BIGINT;
BEGIN

    SELECT "FMH"."FMH_Id" INTO "CFMH_Id"
    FROM "Fee_Yearly_Group_Head_Mapping" "FYGHM"
    INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FYGHM"."FMH_Id"
    WHERE "FMH"."MI_Id" = "MI_Id" AND "FYGHM"."ASMAY_Id" = "ASMAY_Id"
    AND TRIM(COALESCE("FMH"."FMH_FeeName", '')) LIKE 'Caution%' 
    AND "FMH"."FMH_Flag" IN ('N', 'G');

    SELECT "FMH"."FMH_Id" INTO "TFeeFMH_Id"
    FROM "Fee_Yearly_Group_Head_Mapping" "FYGHM"
    INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FYGHM"."FMH_Id"
    WHERE "FMH"."MI_Id" = "MI_Id" AND "FYGHM"."ASMAY_Id" = "ASMAY_Id"
    AND TRIM(COALESCE("FMH"."FMH_FeeName", '')) LIKE 'Tution%' 
    AND "FMH"."FMH_Flag" = 'G';

    RETURN QUERY
    SELECT DISTINCT 
        "New"."ASMCL_ClassName",
        "New"."NewAdm",
        "New"."oldAdm",
        ("New"."NewAdm" + "New"."oldAdm") AS "TotalStrength",
        MAX(COALESCE("New"."FMH_FeeName", '')) AS "FMH_FeeName",
        SUM(COALESCE("New"."FMA_Amount", 0)) AS "FMA_Amount",
        MAX(COALESCE("New"."FMH_FeeName_N", '')) AS "FMH_FeeName_N",
        SUM(COALESCE("New"."FMA_Amount_N", 0)) AS "FMA_Amount_N",
        (("New"."NewAdm" + "New"."oldAdm") * SUM(COALESCE("New"."FMA_Amount", 0))) AS "TutionFees_TotalAmount",
        (("New"."NewAdm" + "New"."oldAdm") * SUM(COALESCE("New"."FMA_Amount_N", 0))) AS "CautionDeposit_TotalAmount",
        ((("New"."NewAdm" + "New"."oldAdm") * SUM(COALESCE("New"."FMA_Amount", 0))) + 
         (("New"."NewAdm" + "New"."oldAdm") * SUM(COALESCE("New"."FMA_Amount_N", 0)))) AS "TotalPayableAmount"
    FROM (
        SELECT DISTINCT 
            "ASMC"."ASMCL_ClassName",
            (SELECT COUNT("AMST_Id") 
             FROM "Adm_M_Student" 
             WHERE "ASMCL_Id" = "ASMC"."ASMCL_Id" 
             AND "ASMAY_Id" = "FeeClassWiseStusStrength_HeadWiseTotalAmount"."ASMAY_Id" 
             AND "AMST_ActiveFlag" = 1 
             AND "AMST_SOL" = 'S') AS "NewAdm",
            (SELECT COUNT("ASYS"."AMST_Id") 
             FROM "Adm_School_Y_Student" "ASYS" 
             INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
             WHERE "ASYS"."ASMAY_Id" = "FeeClassWiseStusStrength_HeadWiseTotalAmount"."ASMAY_Id" 
             AND "AMS"."AMST_ActiveFlag" = 1 
             AND "AMS"."AMST_SOL" = 'S' 
             AND "ASYS"."AMAY_ActiveFlag" = 1 
             AND "ASYS"."ASMCL_Id" = "ASMC"."ASMCL_Id"
             AND "ASYS"."AMST_Id" NOT IN (
                 SELECT "AMST_Id" 
                 FROM "Adm_M_Student" 
                 WHERE "ASMCL_Id" = "ASMC"."ASMCL_Id" 
                 AND "ASMAY_Id" = "FeeClassWiseStusStrength_HeadWiseTotalAmount"."ASMAY_Id" 
                 AND "AMST_ActiveFlag" = 1 
                 AND "AMST_SOL" = 'S')) AS "oldAdm",
            (SELECT "FMH_FeeName" 
             FROM "Fee_Master_Head" 
             WHERE "FMH_Id" = "FMH"."FMH_Id" 
             AND "FMH_Id" = "CFMH_Id" 
             LIMIT 1) AS "FMH_FeeName",
            (SELECT "FMA_Amount" 
             FROM "Fee_Master_Amount" 
             WHERE "FMH_Id" = "FMH"."FMH_Id" 
             AND "ASMAY_Id" = "FeeClassWiseStusStrength_HeadWiseTotalAmount"."ASMAY_Id" 
             AND "FMH_Id" = "CFMH_Id" 
             LIMIT 1) AS "FMA_Amount",
            (SELECT "FMH_FeeName" 
             FROM "Fee_Master_Head" 
             WHERE "FMH_Id" = "FMH"."FMH_Id" 
             AND "FMH_Id" = "TFeeFMH_Id" 
             LIMIT 1) AS "FMH_FeeName_N",
            (SELECT "FMA_Amount" 
             FROM "Fee_Master_Amount" 
             WHERE "FMH_Id" = "FMH"."FMH_Id" 
             AND "ASMAY_Id" = "FeeClassWiseStusStrength_HeadWiseTotalAmount"."ASMAY_Id" 
             AND "FMH_Id" = "TFeeFMH_Id" 
             LIMIT 1) AS "FMA_Amount_N"
        FROM "Adm_School_M_Class" "ASMC"
        INNER JOIN "Fee_Yearly_Class_Category_Classes" "FYCCC" ON "FYCCC"."ASMCL_Id" = "ASMC"."ASMCL_Id"
        INNER JOIN "Fee_Yearly_Class_Category" "FYCC" ON "FYCC"."FYCC_Id" = "FYCCC"."FYCC_Id"
        INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."FMCC_Id" = "FYCC"."FMCC_Id"
        INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FMA"."FMH_Id"
        WHERE "ASMC"."MI_Id" = "FeeClassWiseStusStrength_HeadWiseTotalAmount"."MI_Id" 
        AND "FMA"."ASMAY_Id" = "FeeClassWiseStusStrength_HeadWiseTotalAmount"."ASMAY_Id"
        AND "FMH"."FMH_Id" IN (
            SELECT DISTINCT "FMH"."FMH_Id" 
            FROM "Fee_Yearly_Group_Head_Mapping" "FYGHM"
            INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FYGHM"."FMH_Id"
            WHERE "FMH"."MI_Id" = "FeeClassWiseStusStrength_HeadWiseTotalAmount"."MI_Id" 
            AND "FYGHM"."ASMAY_Id" = "FeeClassWiseStusStrength_HeadWiseTotalAmount"."ASMAY_Id" 
            AND ("FMH"."FMH_Id" = "CFMH_Id" OR "FMH"."FMH_Id" = "TFeeFMH_Id")
        )
    ) AS "New"
    GROUP BY "New"."ASMCL_ClassName", "New"."NewAdm", "New"."oldAdm";

    RETURN;
END;
$$;