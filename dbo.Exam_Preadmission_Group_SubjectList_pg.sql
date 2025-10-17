CREATE OR REPLACE FUNCTION "dbo"."Exam_Preadmission_Group_SubjectList"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT
)
RETURNS TABLE(
    "EMG_GroupName" VARCHAR,
    "EMG_MaxAplSubjects" INTEGER,
    "EMG_MinAplSubjects" INTEGER,
    "EMG_Id" INTEGER,
    "ISMS_SubjectName" VARCHAR,
    "ISMS_OrderFlag" INTEGER,
    "EMG_BestOff" INTEGER,
    "ISMS_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        e."EMG_GroupName", 
        e."EMG_MaxAplSubjects", 
        e."EMG_MinAplSubjects", 
        e."EMG_Id", 
        g."ISMS_SubjectName",
        g."ISMS_OrderFlag",
        e."EMG_BestOff",
        g."ISMS_Id"
    FROM "exm"."Exm_Category_Class" a 
    INNER JOIN "exm"."Exm_Master_Category" b ON a."EMCA_Id" = b."EMCA_Id"
    INNER JOIN "exm"."Exm_Yearly_Category" c ON c."EMCA_Id" = b."EMCA_Id"
    INNER JOIN "exm"."Exm_Yearly_Category_Group" d ON d."EYC_Id" = c."EYC_Id"
    INNER JOIN "exm"."Exm_Master_Group" e ON e."EMG_Id" = d."EMG_Id"
    INNER JOIN "exm"."Exm_Yearly_Category_Group_Subjects" f ON f."EYCG_Id" = d."EYCG_Id"
    INNER JOIN "IVRM_Master_Subjects" g ON g."ISMS_Id" = f."ISMS_Id"
    WHERE a."MI_Id" = "@MI_Id" 
        AND a."ASMCL_Id" = "@ASMCL_Id" 
        AND a."ASMAY_Id" = "@ASMAY_Id" 
        AND c."ASMAY_Id" = "@ASMAY_Id" 
        AND c."EYC_ActiveFlg" = 1 
        AND a."ECAC_ActiveFlag" = 1
        AND b."EMCA_ActiveFlag" = 1 
        AND d."EYCG_ActiveFlg" = 1 
        AND e."EMG_ActiveFlag" = 1 
        AND a."MI_Id" = "@MI_Id" 
        AND c."MI_Id" = "@MI_Id" 
        AND e."MI_Id" = "@MI_Id" 
        AND f."EYCGS_ActiveFlg" = 1
        AND g."ISMS_ActiveFlag" = 1 
        AND g."ISMS_ExamFlag" = 1 
        AND e."EMG_ElectiveFlg" = 1 
    ORDER BY g."ISMS_OrderFlag" DESC;
END;
$$;