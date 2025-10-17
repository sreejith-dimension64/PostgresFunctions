CREATE OR REPLACE FUNCTION "dbo"."Get_Student_Status_Details"(
    "MI_Id" varchar(10),
    "ASMAY_Id" varchar(10),
    "User_Id" varchar(10),
    "AMCST_Id" varchar(10),
    "FMG_Id" varchar(100),
    "FYP_ReceiptDate" timestamp
)
RETURNS TABLE(
    "FMG_Id" integer,
    "FCMAS_Id" integer,
    "FMH_Id" integer,
    "FTI_Id" integer,
    "ASMAY_Id" integer,
    "FCSS_ToBePaid" numeric,
    "FCSS_PaidAmount" numeric,
    "FCSS_ConcessionAmount" numeric,
    "FCSS_NetAmount" numeric,
    "FCSS_FineAmount" numeric,
    "FCSS_RefundAmount" numeric,
    "FMH_FeeName" varchar,
    "FTI_Name" varchar,
    "FMG_GroupName" varchar,
    "FCSS_CurrentYrCharges" numeric,
    "FCSS_TotalCharges" numeric,
    "FCSS_OBArrearAmount" numeric,
    "FCSS_WaivedAmount" numeric,
    "FMH_Order" integer,
    "FMH_Flag" varchar,
    "FCMAS_DueDate" timestamp,
    "DiffDays" integer
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" text;
BEGIN

    "query" := 'select distinct * from (
        select 
            a."FMG_Id",
            a."FCMAS_Id",
            a."FMH_Id",
            a."FTI_Id",
            a."ASMAY_Id",
            a."FCSS_ToBePaid",
            a."FCSS_PaidAmount",
            a."FCSS_ConcessionAmount",
            a."FCSS_NetAmount",
            a."FCSS_FineAmount",
            a."FCSS_RefundAmount",
            g."FMH_FeeName",
            h."FTI_Name",
            f."FMG_GroupName",
            a."FCSS_CurrentYrCharges",
            a."FCSS_TotalCharges",
            a."FCSS_OBArrearAmount",
            a."FCSS_WaivedAmount",
            g."FMH_Order",
            g."FMH_Flag",
            a."FCMAS_DueDate",
            ABS(EXTRACT(DAY FROM (CURRENT_DATE - MAKE_DATE("DD"."FCTDD_Year", "DD"."FCTDD_Month", "DD"."FCTDD_Day")))::integer) AS "DiffDays"
        from 
            "CLG"."Fee_College_Student_Status" a,
            "Fee_Group_Login_Previledge" b,
            "clg"."Fee_College_Master_Amount" c,
            "CLG"."Fee_College_Master_Amount_Semesterwise" d,
            "CLG"."Adm_College_Yearly_Student" e,
            "Fee_Master_Group" f,
            "Fee_Master_Head" g,
            "Fee_T_Installment" h,
            "clg"."Fee_College_T_Due_Date" "DD"
        where 
            a."MI_Id" = ' || "MI_Id" || ' 
            and b."MI_ID" = a."MI_Id" 
            and c."MI_Id" = a."MI_Id" 
            and d."MI_Id" = a."MI_Id" 
            and f."MI_Id" = a."MI_Id" 
            and g."MI_Id" = a."MI_Id" 
            and h."MI_ID" = a."MI_Id" 
            and a."FMG_Id" in (' || "FMG_Id" || ') 
            and a."AMCST_Id" = ' || "AMCST_Id" || '
            and a."ASMAY_Id" = ' || "ASMAY_Id" || ' 
            and b."FMG_ID" = a."FMG_Id" 
            and b."FMH_Id" = a."FMH_Id" 
            and b."User_Id" = ' || "User_Id" || ' 
            and c."FMG_Id" = a."FMG_Id" 
            and c."FMH_Id" = a."FMH_Id" 
            and c."FCMA_ActiveFlg" = 1 
            and d."FCMA_Id" = c."FCMA_Id" 
            and d."FCMAS_Id" = a."FCMAS_Id"
            and "DD"."FCMAS_Id" = a."FCMAS_Id" 
            and e."AMCST_Id" = ' || "AMCST_Id" || ' 
            and e."ACYST_ActiveFlag" = 1 
            and e."ASMAY_Id" = ' || "ASMAY_Id" || ' 
            and e."AMCO_Id" = c."AMCO_Id" 
            and e."AMB_Id" = c."AMB_Id" 
            and f."FMG_ActiceFlag" = 1 
            and f."FMG_Id" = a."FMG_Id" 
            and a."FCSS_ToBePaid" > 0 
            and g."FMH_ActiveFlag" = 1 
            and g."FMH_Id" = a."FMH_Id" 
            and h."FTI_Id" = a."FTI_Id"
        
        UNION ALL
        
        select 
            a."FMG_Id",
            a."FCMAS_Id",
            a."FMH_Id",
            a."FTI_Id",
            a."ASMAY_Id",
            a."FCSS_ToBePaid",
            a."FCSS_PaidAmount",
            a."FCSS_ConcessionAmount",
            a."FCSS_NetAmount",
            a."FCSS_FineAmount",
            a."FCSS_RefundAmount",
            g."FMH_FeeName",
            h."FTI_Name",
            f."FMG_GroupName",
            a."FCSS_CurrentYrCharges",
            a."FCSS_TotalCharges",
            a."FCSS_OBArrearAmount",
            a."FCSS_WaivedAmount",
            g."FMH_Order",
            g."FMH_Flag",
            a."FCMAS_DueDate",
            ABS(EXTRACT(DAY FROM (CURRENT_DATE - MAKE_DATE("DD"."FCTDD_Year", "DD"."FCTDD_Month", "DD"."FCTDD_Day")))::integer) AS "DiffDays"
        from 
            "CLG"."Fee_College_Student_Status" a,
            "Fee_Group_Login_Previledge" b,
            "clg"."Fee_College_Master_Amount" c,
            "CLG"."Fee_College_Master_Amount_Semesterwise" d,
            "CLG"."Adm_College_Yearly_Student" e,
            "Fee_Master_Group" f,
            "Fee_Master_Head" g,
            "Fee_T_Installment" h,
            "clg"."Fee_College_T_Due_Date" "DD"
        where 
            a."MI_Id" = ' || "MI_Id" || ' 
            and b."MI_ID" = a."MI_Id" 
            and c."MI_Id" = a."MI_Id" 
            and d."MI_Id" = a."MI_Id"
            and f."MI_Id" = a."MI_Id" 
            and g."MI_Id" = a."MI_Id" 
            and h."MI_ID" = a."MI_Id" 
            and a."FMG_Id" in (' || "FMG_Id" || ') 
            and a."AMCST_Id" = ' || "AMCST_Id" || '
            and a."ASMAY_Id" = ' || "ASMAY_Id" || ' 
            and b."FMG_ID" = a."FMG_Id" 
            and b."FMH_Id" = a."FMH_Id" 
            and b."User_Id" = ' || "User_Id" || ' 
            and c."FMG_Id" = a."FMG_Id"
            and c."FMH_Id" = a."FMH_Id" 
            and c."FCMA_ActiveFlg" = 1 
            and d."FCMA_Id" = c."FCMA_Id" 
            and d."FCMAS_Id" = a."FCMAS_Id" 
            and "DD"."FCMAS_Id" = a."FCMAS_Id"
            and e."AMCST_Id" = ' || "AMCST_Id" || ' 
            and e."ACYST_ActiveFlag" = 1 
            and e."ASMAY_Id" = ' || "ASMAY_Id" || ' 
            and e."AMCO_Id" = c."AMCO_Id" 
            and e."AMB_Id" = c."AMB_Id" 
            and f."FMG_ActiceFlag" = 1 
            and f."FMG_Id" = a."FMG_Id" 
            and (g."fmh_flag" = ''F'' OR g."fmh_flag" = ''E'')
            and g."FMH_ActiveFlag" = 1 
            and g."FMH_Id" = a."FMH_Id" 
            and h."FTI_Id" = a."FTI_Id"
    ) as d';

    RETURN QUERY EXECUTE "query";

END;
$$;