CREATE OR REPLACE FUNCTION "dbo"."Induction_Program_List"(
    p_MI_Id integer
)
RETURNS TABLE(
    "HRINPC_Id" integer,
    "HRINPC_PrgName" text,
    "HRMB_Title" text,
    "MinDate" date,
    "MaxDate" date,
    "HRICD_ECFlag" text,
    "HRINPC_ActiveFlag" boolean,
    "HRINPC_CostFee" numeric,
    "HRINPC_Desc" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "C"."HRINPC_Id",
        "C"."HRINPC_PrgName",
        "MB"."HRMB_Title",
        MIN("CD"."HRICD_Date"::date) AS "MinDate",
        MAX("CD"."HRICD_Date"::date) AS "MaxDate",
        "CD"."HRICD_ECFlag",
        "C"."HRINPC_ActiveFlag",
        "C"."HRINPC_CostFee",
        "C"."HRINPC_Desc"
    FROM "HR_IndPr_Create" "C"
    INNER JOIN "HR_IndPr_Create_Details" "CD" ON "C"."HRINPC_Id" = "CD"."HRINPC_Id"
    INNER JOIN "HR_Master_Building" "MB" ON "C"."HRMB_Id" = "MB"."HRMB_Id"
    WHERE "MB"."MI_Id" = p_MI_Id
    GROUP BY "C"."HRINPC_PrgName", "MB"."HRMB_Title", "CD"."HRICD_ECFlag", "C"."HRINPC_ActiveFlag", "C"."HRINPC_CostFee", "C"."HRINPC_Desc", "C"."HRINPC_Id";
END;
$$;