CREATE OR REPLACE FUNCTION "dbo"."Get_Student_Status_Details_Online"(
    "MI_Id" VARCHAR(10),
    "ASMAY_Id" VARCHAR(10),
    "AMCST_Id" VARCHAR(10),
    "FMG_Id" VARCHAR(100)
)
RETURNS TABLE(
    "FMG_Id" INTEGER,
    "FCMAS_Id" INTEGER,
    "FMH_Id" INTEGER,
    "FTI_Id" INTEGER,
    "ASMAY_Id" INTEGER,
    "fcsS_ToBePaid" NUMERIC,
    "fcsS_PaidAmount" NUMERIC,
    "fcsS_ConcessionAmount" NUMERIC,
    "fcsS_NetAmount" NUMERIC,
    "fcsS_FineAmount" NUMERIC,
    "fcsS_RefundAmount" NUMERIC,
    "fmH_FeeName" VARCHAR,
    "ftI_Name" VARCHAR,
    "fmG_GroupName" VARCHAR,
    "fcsS_CurrentYrCharges" NUMERIC,
    "fcsS_TotalCharges" NUMERIC,
    "fcsS_OBArrearAmount" NUMERIC,
    "fcsS_WaivedAmount" NUMERIC,
    "FMH_Order" INTEGER,
    "FMH_Flag" VARCHAR,
    "fcmaS_DueDate" TIMESTAMP,
    "DiffDays" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
BEGIN
    "query" := 'SELECT DISTINCT a."FMG_Id",a."FCMAS_Id",a."FMH_Id",a."FTI_Id",a."ASMAY_Id",a."fcsS_ToBePaid",a."fcsS_PaidAmount",a."fcsS_ConcessionAmount",a."fcsS_NetAmount",a."fcsS_FineAmount",a."fcsS_RefundAmount",g."fmH_FeeName",h."ftI_Name",
f."fmG_GroupName",a."fcsS_CurrentYrCharges",
a."fcsS_TotalCharges",a."fcsS_OBArrearAmount",a."fcsS_WaivedAmount",g."FMH_Order",g."FMH_Flag",d."FCMAS_DueDate" AS "fcmaS_DueDate",ABS(EXTRACT(DAY FROM (CURRENT_DATE - MAKE_DATE("DD"."FCTDD_Year","DD"."FCTDD_Month","DD"."FCTDD_Day")))::INTEGER) AS "DiffDays"
FROM "CLG"."Fee_College_Student_Status" a, "Fee_Group_Login_Previledge" b,"clg"."Fee_College_Master_Amount" c,"CLG"."Fee_College_Master_Amount_Semesterwise" d,"CLG"."Adm_College_Yearly_Student" e,"Fee_Master_Group" f,"Fee_Master_Head" g,"Fee_T_Installment" h,"clg"."Fee_College_T_Due_Date" "DD"
WHERE a."MI_Id" = ' || "MI_Id" || ' AND b."MI_ID" = a."MI_Id" AND c."MI_Id" = a."MI_Id" AND d."MI_Id" = a."MI_Id" AND f."MI_Id" = a."MI_Id" AND g."MI_Id" = a."MI_Id" AND h."MI_ID" = a."MI_Id" AND a."FMG_Id" IN (' || "FMG_Id" || ') AND a."AMCST_Id" = ' || "AMCST_Id" || ' AND a."ASMAY_Id" = ' || "ASMAY_Id" || ' AND
b."FMG_ID" = a."FMG_Id" AND b."FMH_Id" = a."FMH_Id" AND c."FMG_Id" = a."FMG_Id" AND c."FMH_Id" = a."FMH_Id" AND c."FCMA_ActiveFlg" = 1 AND d."FCMA_Id" = c."FCMA_Id" AND d."FCMAS_Id" = a."FCMAS_Id" AND "DD"."FCMAS_Id"=a."FCMAS_Id" AND e."AMCST_Id" = ' || "AMCST_Id" || ' AND e."ACYST_ActiveFlag"=1
AND e."ASMAY_Id" = ' || "ASMAY_Id" || ' AND e."AMCO_Id" = c."AMCO_Id" AND e."AMB_Id" = c."AMB_Id" AND f."FMG_ActiceFlag"=1 AND f."FMG_Id" = a."FMG_Id" AND a."FCSS_ToBePaid">0 AND g."FMH_ActiveFlag"=1 AND g."FMH_Id" = a."FMH_Id" AND h."FTI_Id" = a."FTI_Id"';

    RETURN QUERY EXECUTE "query";
END;
$$;