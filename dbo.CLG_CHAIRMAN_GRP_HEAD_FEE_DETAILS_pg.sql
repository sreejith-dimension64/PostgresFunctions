CREATE OR REPLACE FUNCTION "dbo"."CLG_CHAIRMAN_GRP_HEAD_FEE_DETAILS"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint
)
RETURNS TABLE(
    "FMG_Id" bigint,
    "FMG_GroupName" text,
    "FMG_Order" integer,
    "FMH_Id" bigint,
    "FMH_FeeName" text,
    "FMH_Order" integer,
    "recived" numeric,
    "BFCSS_TotalCharges" numeric,
    "BFCSS_ConcessionAmount" numeric,
    "BFCSS_AdjustedAmount" numeric,
    "BFCSS_WaivedAmount" numeric,
    "paid" numeric,
    "CollectionAnyTime" numeric,
    "balance" numeric,
    "StudentDue" numeric,
    "CollegeDue" numeric,
    "OverallDue" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "FMG"."FMG_Id",
        "FMG"."FMG_GroupName",
        "FMG"."FMG_Order",
        "FMH"."FMH_Id",
        "FMH"."FMH_FeeName",
        "FMH"."FMH_Order",
        SUM("FCSS"."FCSS_CurrentYrCharges") AS "recived",
        SUM("FCSS"."FCSS_TotalCharges") AS "BFCSS_TotalCharges",
        SUM("FCSS"."FCSS_ConcessionAmount") AS "BFCSS_ConcessionAmount",
        SUM("FCSS"."FCSS_AdjustedAmount") AS "BFCSS_AdjustedAmount",
        SUM("FCSS"."FCSS_WaivedAmount") AS "BFCSS_WaivedAmount",
        SUM("FCSS"."FCSS_PaidAmount") AS "paid",
        SUM("FCSS"."FCSS_FineAmount") AS "CollectionAnyTime",
        SUM("FCSS"."FCSS_ToBePaid") AS "balance",
        SUM("FCSS"."FCSS_OBArrearAmount") AS "StudentDue",
        SUM("FCSS"."FCSS_OBExcessAmount") AS "CollegeDue",
        (SUM("FCSS"."FCSS_OBArrearAmount") - SUM("FCSS"."FCSS_OBExcessAmount")) AS "OverallDue"
    FROM "CLG"."Fee_College_Master_Amount" "FCMA"
    INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" "FCMAS" 
        ON "FCMAS"."MI_Id" = "MI_Id" AND "FCMAS"."FCMA_Id" = "FCMA"."FCMA_Id"
    INNER JOIN "CLG"."Fee_College_Student_Status" "FCSS" 
        ON "FCSS"."MI_Id" = "MI_Id" AND "FCSS"."FCMAS_Id" = "FCMAS"."FCMAS_Id"
    INNER JOIN "CLG"."Adm_Master_College_Student" AS "AMCS" 
        ON "FCSS"."AMCST_Id" = "AMCS"."AMCST_Id" AND "AMCS"."MI_Id" = "MI_Id"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" AS "ACYS" 
        ON "FCSS"."AMCST_Id" = "ACYS"."AMCST_Id"
    INNER JOIN "CLG"."Adm_Master_Course" AS "AMC" 
        ON "AMC"."AMCO_Id" = "ACYS"."AMCO_Id"
    INNER JOIN "dbo"."Fee_Master_Group" "FMG" 
        ON "FMG"."FMG_Id" = "FCSS"."FMG_Id" AND "FMG"."MI_Id" = "MI_Id" AND "FMG"."FMG_ActiceFlag" = true
    INNER JOIN "dbo"."Fee_Master_Head" "FMH" 
        ON "FMH"."FMH_Id" = "FCSS"."FMH_Id" AND "FMH"."MI_Id" = "MI_Id" AND "FMH"."FMH_ActiveFlag" = true
    WHERE "FCMA"."MI_Id" = "MI_Id"
        AND "ACYS"."ASMAY_Id" = "ASMAY_Id"
        AND "FCSS"."ASMAY_Id" = "ASMAY_Id"
        AND "AMCS"."AMCST_SOL" = 'S' 
        AND "AMCS"."AMCST_ActiveFlag" = true 
        AND "ACYS"."ACYST_ActiveFlag" = true
    GROUP BY "FMG"."FMG_Id", "FMG"."FMG_GroupName", "FMG"."FMG_Order", 
             "FMH"."FMH_Id", "FMH"."FMH_FeeName", "FMH"."FMH_Order"
    ORDER BY "FMG"."FMG_Order", "FMH"."FMH_Order";
END;
$$;