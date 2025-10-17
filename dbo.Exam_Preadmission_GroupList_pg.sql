CREATE OR REPLACE FUNCTION "dbo"."Exam_Preadmission_GroupList"(
    "p_MI_Id" TEXT, 
    "p_ASMAY_Id" TEXT, 
    "p_ASMCL_Id" TEXT, 
    "p_ASMST_Id" TEXT
)
RETURNS TABLE(
    "EMG_GroupName" VARCHAR,
    "EMG_MaxAplSubjects" INTEGER,
    "EMG_MinAplSubjects" INTEGER,
    "EMG_Id" INTEGER,
    "EMG_ElectiveFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "p_ASMST_Id" != '0' THEN
    
        RETURN QUERY
        SELECT DISTINCT 
            e."EMG_GroupName", 
            e."EMG_MaxAplSubjects", 
            e."EMG_MinAplSubjects", 
            e."EMG_Id", 
            e."EMG_ElectiveFlg"
        FROM "exm"."Exm_Category_Class" a   
        INNER JOIN "exm"."Exm_Master_Category" b ON a."EMCA_Id" = b."EMCA_Id"  
        INNER JOIN "exm"."Exm_Yearly_Category" c ON c."EMCA_Id" = b."EMCA_Id"  
        INNER JOIN "exm"."Exm_Yearly_Category_Group" d ON d."EYC_Id" = c."EYC_Id"  
        INNER JOIN "exm"."Exm_Master_Group" e ON e."EMG_Id" = d."EMG_Id"  
        INNER JOIN "Adm_School_Stream_Class" h ON h."asmcl_id" = a."ASMCL_Id" 
            AND h."asms_id" = a."ASMS_Id" 
            AND h."ASSTCL_ActiveFlag" = 1
        WHERE a."MI_Id" = "p_MI_Id" 
            AND a."ASMCL_Id" = "p_ASMCL_Id" 
            AND a."ASMAY_Id" = "p_ASMAY_Id" 
            AND c."ASMAY_Id" = "p_ASMAY_Id" 
            AND c."EYC_ActiveFlg" = 1 
            AND a."ECAC_ActiveFlag" = 1  
            AND b."EMCA_ActiveFlag" = 1 
            AND d."EYCG_ActiveFlg" = 1 
            AND e."EMG_ActiveFlag" = 1 
            AND a."MI_Id" = "p_MI_Id" 
            AND c."MI_Id" = "p_MI_Id" 
            AND e."MI_Id" = "p_MI_Id" 
            AND h."ASMST_Id" = "p_ASMST_Id" 
            AND e."EMG_ElectiveFlg" = 1;
    
    ELSE
    
        RETURN QUERY
        SELECT DISTINCT 
            e."EMG_GroupName", 
            e."EMG_MaxAplSubjects", 
            e."EMG_MinAplSubjects", 
            e."EMG_Id", 
            e."EMG_ElectiveFlg"
        FROM "exm"."Exm_Category_Class" a   
        INNER JOIN "exm"."Exm_Master_Category" b ON a."EMCA_Id" = b."EMCA_Id"  
        INNER JOIN "exm"."Exm_Yearly_Category" c ON c."EMCA_Id" = b."EMCA_Id"  
        INNER JOIN "exm"."Exm_Yearly_Category_Group" d ON d."EYC_Id" = c."EYC_Id"  
        INNER JOIN "exm"."Exm_Master_Group" e ON e."EMG_Id" = d."EMG_Id"  
        WHERE a."MI_Id" = "p_MI_Id" 
            AND a."ASMCL_Id" = "p_ASMCL_Id" 
            AND a."ASMAY_Id" = "p_ASMAY_Id" 
            AND c."ASMAY_Id" = "p_ASMAY_Id" 
            AND c."EYC_ActiveFlg" = 1 
            AND a."ECAC_ActiveFlag" = 1  
            AND b."EMCA_ActiveFlag" = 1 
            AND d."EYCG_ActiveFlg" = 1 
            AND e."EMG_ActiveFlag" = 1 
            AND a."MI_Id" = "p_MI_Id" 
            AND c."MI_Id" = "p_MI_Id" 
            AND e."MI_Id" = "p_MI_Id" 
            AND e."EMG_ElectiveFlg" = 1;
    
    END IF;

    RETURN;

END;
$$;