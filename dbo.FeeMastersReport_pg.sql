CREATE OR REPLACE FUNCTION "dbo"."FeeMastersReport"(
    p_MI_ID bigint,
    p_ASMAY_Id bigint,
    p_TYPE bigint
)
RETURNS SETOF record
LANGUAGE plpgsql
AS $$
BEGIN
    
    IF p_TYPE = 1 THEN
        RETURN QUERY
        SELECT a."FMG_Id", a."FMG_GroupName"
        FROM "Fee_Master_Group" a
        INNER JOIN "Fee_Yearly_Group" b ON b."FMG_Id" = a."FMG_Id"
        WHERE a."MI_Id" = p_MI_ID 
            AND b."MI_Id" = p_MI_ID 
            AND b."ASMAY_Id" = p_ASMAY_Id 
            AND a."FMG_ActiceFlag" = 1 
            AND b."FYG_ActiveFlag" = 1;
    
    ELSIF p_TYPE = 2 THEN
        RETURN QUERY
        SELECT "FMH_RefundFlag", "FMH_PDAFlag", "FMH_SpecialFeeFlag", "FMH_Order", "FMH_FeeName", "FMH_Flag", "FMH_Id"
        FROM "Fee_Master_Head"
        WHERE "MI_Id" = p_MI_ID AND "FMH_ActiveFlag" = 1;
    
    ELSIF p_TYPE = 3 THEN
        RETURN QUERY
        SELECT a."ASMAY_Id", b."FMG_GroupName", b."FMG_Id", c."FMH_Id", d."FMI_Id", c."FMH_FeeName", d."FMI_Name", 
               a."FYGHM_FineApplicableFlag", a."FYGHM_Common_AmountFlag", e."FTI_Id", e."FTI_Name"
        FROM "Fee_Yearly_Group_Head_Mapping" a
        INNER JOIN "Fee_master_group" b ON b."FMG_Id" = a."FMG_Id"
        INNER JOIN "Fee_Master_Head" c ON c."FMH_Id" = a."FMH_Id"
        INNER JOIN "Fee_Master_Installment" d ON d."FMI_Id" = a."FMI_Id"
        INNER JOIN "Fee_T_Installment" e ON e."FMI_Id" = d."FMI_Id"
        WHERE a."FYGHM_ActiveFlag" = 1 
            AND b."FMG_ActiceFlag" = 1 
            AND c."FMH_ActiveFlag" = 1 
            AND d."FMI_ActiceFlag" = 1 
            AND a."ASMAY_Id" = p_ASMAY_Id 
            AND a."MI_Id" = p_MI_ID;
    
    ELSIF p_TYPE = 4 THEN
        RETURN QUERY
        SELECT c."FMI_Name", c."FMI_Id", a."FTI_Id", a."FTI_Name", b."FTIDD_ApplicableDate", 
               b."FTIDD_DueDate", b."FTIDD_FromDate", b."FTIDD_ToDate"
        FROM "Fee_Master_Installment" c
        INNER JOIN "Fee_T_Installment" a ON a."FMI_Id" = c."FMI_Id"
        INNER JOIN "Fee_T_Installment_DueDate" b ON b."FTI_Id" = a."FTI_Id"
        WHERE a."MI_ID" = p_MI_ID 
            AND b."ASMAY_Id" = p_ASMAY_Id 
            AND b."MI_Id" = p_MI_ID 
            AND c."FMI_ActiceFlag" = 1;
    
    ELSIF p_TYPE = 5 THEN
        RETURN QUERY
        SELECT "FMFS_Id", "FMFS_FineType", "FMFS_FromDay", "FMFS_ToDay", "FMFS_ECSFlag", "FMFS_ActiveFlag"
        FROM "Fee_Master_Fine_Slabs"
        WHERE "FMFS_ActiveFlag" = 1 AND "MI_Id" = p_MI_ID;
    
    ELSIF p_TYPE = 6 THEN
        RETURN QUERY
        SELECT fycc."MI_Id", fycc."ASMAY_Id", fmcc."FMCC_ClassCategoryName", asms."ASMC_SectionName", 
               fyccc."ASMCL_Id", asmsec."ASMS_Id", asmcl."ASMCL_ClassName", fmcc."FMCC_Id"
        FROM "Fee_Yearly_Class_Category" fycc
        INNER JOIN "Fee_Master_Class_Category" fmcc ON fycc."FMCC_Id" = fmcc."FMCC_Id"
        INNER JOIN "Fee_Yearly_Class_Category_Classes" fyccc ON fycc."FYCC_Id" = fyccc."FYCC_Id"
        INNER JOIN "Adm_School_M_Class" asmcl ON fyccc."ASMCL_Id" = asmcl."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" asmsec ON fycc."MI_Id" = asmsec."MI_Id"
        CROSS JOIN "Adm_School_M_Section" asms
        WHERE fycc."MI_Id" = p_MI_Id AND fycc."ASMAY_Id" = p_ASMAY_Id;
    
    ELSIF p_TYPE = 7 THEN
        RETURN QUERY
        SELECT b."NormalizedUserName", c."FMG_GroupName", c."FMG_Id", d."FMH_Id", d."FMH_FeeName", 
               f."IVRMRT_Role", a."User_Id"
        FROM "Fee_Group_Login_Previledge" a
        INNER JOIN "ApplicationUser" b ON b."Id" = a."User_Id"
        INNER JOIN "Fee_Master_Group" c ON c."FMG_Id" = a."FMG_ID"
        INNER JOIN "Fee_Yearly_Group" g ON g."FMG_Id" = a."FMG_Id"
        INNER JOIN "Fee_Master_Head" d ON d."FMH_Id" = a."FMH_Id"
        INNER JOIN "ApplicationUserRole" e ON e."UserId" = a."User_Id"
        INNER JOIN "IVRM_Role_Type" f ON f."IVRMRT_Id" = e."RoleTypeId"
        WHERE c."MI_Id" = p_MI_ID 
            AND c."FMG_ActiceFlag" = 1 
            AND d."FMH_ActiveFlag" = 1 
            AND g."ASMAY_Id" = p_ASMAY_Id 
            AND g."FYG_ActiveFlag" = 1 
            AND g."MI_Id" = p_MI_ID;
    
    ELSIF p_TYPE = 8 THEN
        RETURN QUERY
        SELECT b."FMT_Id", b."FMT_Name", c."FMH_Id", c."FMH_FeeName", d."FTI_Id", d."FTI_Name"
        FROM "Fee_Master_Terms_FeeHeads" a
        INNER JOIN "Fee_Master_Terms" b ON a."FMT_Id" = b."FMT_Id"
        INNER JOIN "Fee_Master_Head" c ON c."FMH_Id" = a."FMH_Id"
        INNER JOIN "Fee_T_Installment" d ON d."FTI_Id" = a."FTI_Id"
        WHERE a."MI_Id" = p_MI_ID 
            AND b."MI_Id" = p_MI_ID 
            AND d."MI_ID" = p_MI_ID 
            AND b."FMT_ActiveFlag" = 1 
            AND c."FMH_ActiveFlag" = 1;
    
    ELSIF p_TYPE = 9 THEN
        RETURN QUERY
        SELECT k."FMCC_ClassCategoryName", b."FMG_GroupName", b."FMG_Id", f."FMA_Amount", f."FMA_Id", 
               c."FMH_FeeName", c."FMH_Id", e."FTI_Id", e."FTI_Name", j."FTFSE_Amount", g."FTDDE_Month"
        FROM "Fee_Yearly_Group_Head_Mapping" a
        INNER JOIN "Fee_Master_Group" b ON b."FMG_Id" = a."FMG_Id"
        INNER JOIN "Fee_Master_Head" c ON c."FMH_Id" = a."FMH_Id"
        INNER JOIN "Fee_Master_Installment" d ON d."FMI_Id" = a."FMI_Id"
        INNER JOIN "Fee_Master_Amount" f ON f."FMG_Id" = a."FMG_Id" AND f."FMH_Id" = c."FMH_Id"
        INNER JOIN "Fee_T_Installment" e ON e."FTI_Id" = f."FTI_Id"
        LEFT JOIN "Fee_T_Due_Date_ECS" g ON g."FMA_Id" = f."FMA_Id"
        LEFT JOIN "Fee_T_Fine_Slabs_ECS" j ON j."FMA_Id" = f."FMA_Id"
        INNER JOIN "Fee_Master_Class_Category" k ON k."FMCC_Id" = f."FMCC_Id"
        WHERE b."MI_Id" = p_MI_ID 
            AND a."ASMAY_Id" = p_ASMAY_Id 
            AND a."MI_Id" = p_MI_ID 
            AND a."FYGHM_ActiveFlag" = 1 
            AND b."FMG_ActiceFlag" = 1 
            AND c."FMH_ActiveFlag" = 1 
            AND d."MI_Id" = p_MI_ID 
            AND d."FMI_ActiceFlag" = 1 
            AND f."ASMAY_Id" = p_ASMAY_Id 
            AND f."MI_Id" = p_MI_ID 
            AND e."MI_ID" = p_MI_ID;
    
    ELSIF p_TYPE = 10 THEN
        RETURN QUERY
        SELECT b."FMGG_GroupName", c."FMG_GroupName", b."FMGG_Id", a."FMG_Id"
        FROM "Fee_Master_Group_Grouping_Groups" a
        INNER JOIN "Fee_Master_Group_Grouping" b ON b."FMGG_Id" = a."FMGG_Id"
        INNER JOIN "Fee_Master_Group" c ON c."FMG_Id" = a."FMG_Id"
        WHERE c."MI_Id" = p_MI_ID 
            AND b."MI_Id" = p_MI_ID 
            AND b."FMGG_ActiveFlag" = 1 
            AND c."FMG_ActiceFlag" = 1;
    
    END IF;
    
    RETURN;
END;
$$;