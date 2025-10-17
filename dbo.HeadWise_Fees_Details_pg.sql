CREATE OR REPLACE FUNCTION "HeadWise_Fees_Details" (
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT
)
RETURNS TABLE (
    "FMH_FeeName" VARCHAR,
    "TotalCharges" NUMERIC,
    "TotalToBePaid" NUMERIC,
    "ToBePaid" NUMERIC,
    "PaidAmount" NUMERIC,
    "ConcessionAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "FMH"."FMH_FeeName",
        SUM("FSS"."FSS_CurrentYrCharges") AS "TotalCharges",
        SUM("FSS"."FSS_TotalToBePaid") AS "TotalToBePaid",
        SUM("FSS"."FSS_ToBePaid") AS "ToBePaid",
        SUM("FSS"."FSS_PaidAmount") AS "PaidAmount",
        SUM("FSS"."FSS_ConcessionAmount") AS "ConcessionAmount"
    FROM "Adm_M_Student" "ST"
    INNER JOIN "Adm_school_y_student" "YST" ON "YST"."AMST_Id" = "ST"."AMST_Id"
    INNER JOIN "Fee_Student_Status" "FSS" ON "FSS"."AMST_Id" = "YST"."AMST_Id" AND "FSS"."ASMAY_Id" = "YST"."ASMAY_Id"
    INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."FMH_Id" = "FSS"."FMH_Id"
    WHERE "FSS"."MI_Id" = p_MI_Id 
        AND "FSS"."ASMAY_Id" = p_ASMAY_Id
        AND "YST"."ASMCL_Id"::TEXT IN (SELECT UNNEST(string_to_array(p_ASMCL_Id, ',')))
        AND "YST"."ASMS_Id"::TEXT IN (SELECT UNNEST(string_to_array(p_ASMS_Id, ',')))
    GROUP BY "FMH"."FMH_FeeName";
END;
$$;