CREATE OR REPLACE FUNCTION "dbo"."Fee_StudentTermWiseExcessAmount_Details"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_userid bigint
)
RETURNS TABLE (
    "AMST_Id" bigint,
    "StudentName" text,
    "ASMCL_ClassName" text,
    "AMST_AdmNo" text,
    "FMT_Id" bigint,
    "FMT_Name" text,
    "NetAmount" numeric,
    "PayableAmount" numeric,
    "PaidAmount" numeric,
    "BalanceAmount" numeric,
    "ExcessAmount" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        b."AMST_Id",
        (COALESCE(b."AMST_FirstName",'') || ' ' || COALESCE(b."AMST_MiddleName",'') || ' ' || COALESCE(b."AMST_LastName",'')) AS "StudentName",
        e."ASMCL_ClassName" || ':' || f."ASMC_SectionName" AS "ASMCL_ClassName",
        b."AMST_AdmNo",
        k."FMT_Id",
        k."FMT_Name",
        SUM(a."FSS_NetAmount") AS "NetAmount",
        SUM(a."FSS_TotalToBePaid") AS "PayableAmount",
        SUM(a."FSS_PaidAmount") AS "PaidAmount",
        SUM(a."FSS_ToBePaid") AS "BalanceAmount",
        SUM(a."FSS_ExcessPaidAmount") AS "ExcessAmount"
    FROM 
        "Fee_Student_Status" a,
        "Adm_M_Student" b,
        "Adm_School_Y_Student" c,
        "Adm_School_M_Class" e,
        "Adm_School_M_Section" f,
        "Fee_T_Installment" g,
        "Fee_Master_Amount" h,
        "Fee_Master_Terms_FeeHeads" i,
        "Fee_Master_Head" j,
        "Fee_Master_Terms" k
    WHERE 
        a."AMST_Id" = b."AMST_Id" 
        AND b."AMST_Id" = c."AMST_Id" 
        AND h."FMA_Id" = a."FMA_Id" 
        AND a."ASMAY_Id" = c."ASMAY_Id" 
        AND a."MI_Id" = p_MI_Id 
        AND b."MI_Id" = p_MI_Id 
        AND a."ASMAY_Id" = p_ASMAY_Id 
        AND c."ASMAY_Id" = p_ASMAY_Id 
        AND e."MI_Id" = p_MI_Id 
        AND e."ASMCL_Id" = c."ASMCL_Id" 
        AND f."MI_Id" = p_MI_Id 
        AND f."ASMS_Id" = c."ASMS_Id" 
        AND g."MI_Id" = p_MI_Id 
        AND a."FTI_Id" = g."FTI_Id" 
        AND i."FMH_Id" = a."FMH_Id" 
        AND i."FTI_Id" = a."FTI_Id" 
        AND i."FMH_Id" = j."FMH_Id" 
        AND k."FMT_Id" = i."FMT_Id" 
        AND a."user_id" = p_userid
    GROUP BY 
        b."AMST_Id",
        k."FMT_Id",
        k."FMT_Name",
        b."AMST_FirstName",
        b."AMST_MiddleName",
        b."AMST_LastName",
        e."ASMCL_ClassName",
        f."ASMC_SectionName",
        b."AMST_AdmNo"
    HAVING 
        SUM(a."FSS_ExcessPaidAmount") > 0 
        AND SUM(a."FSS_AdjustedAmount") = 0 
        AND SUM(a."FSS_RunningExcessAmount") > 0
    ORDER BY 
        k."FMT_Id",
        "StudentName";
END;
$$;