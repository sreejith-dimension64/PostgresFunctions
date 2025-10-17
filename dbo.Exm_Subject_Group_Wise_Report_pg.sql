CREATE OR REPLACE FUNCTION "dbo"."Exm_Subject_Group_Wise_Report"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_EMG_Id TEXT,
    p_report_type TEXT,
    p_examwiseorwithout TEXT,
    p_masteryearly TEXT,
    p_EME_Id TEXT
)
RETURNS TABLE(
    "EMG_Id" BIGINT,
    "EMG_GroupName" VARCHAR,
    "ISMS_SubjectName" VARCHAR,
    "ISMS_OrderFlag" INTEGER,
    "EMG_MaxAplSubjects" INTEGER,
    "EMG_MinAplSubjects" INTEGER,
    "EMG_BestOff" INTEGER,
    "EMG_ElectiveFlg" BOOLEAN,
    "EMG_TotSubjects" INTEGER,
    "EYCES_AplResultFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_masteryearly = 'master' THEN
        
        IF p_report_type = 'all' THEN
            RETURN QUERY
            SELECT DISTINCT A."EMG_Id", A."EMG_GroupName", C."ISMS_SubjectName", C."ISMS_OrderFlag", 
                   A."EMG_MaxAplSubjects", A."EMG_MinAplSubjects", A."EMG_BestOff", 
                   A."EMG_ElectiveFlg", A."EMG_TotSubjects", NULL::BOOLEAN AS "EYCES_AplResultFlg"
            FROM "Exm"."Exm_Master_Group" A 
            INNER JOIN "Exm"."Exm_Master_Group_Subjects" B ON A."EMG_Id" = B."EMG_Id"
            INNER JOIN "IVRM_Master_Subjects" C ON C."ISMS_Id" = B."ISMS_Id"
            WHERE A."MI_Id" = p_MI_Id::BIGINT AND A."EMG_ActiveFlag" = TRUE AND B."EMGS_ActiveFlag" = TRUE 
            ORDER BY "ISMS_OrderFlag";
            
        ELSIF p_report_type != 'all' THEN
            RETURN QUERY
            SELECT DISTINCT A."EMG_Id", A."EMG_GroupName", C."ISMS_SubjectName", C."ISMS_OrderFlag", 
                   A."EMG_MaxAplSubjects", A."EMG_MinAplSubjects", A."EMG_BestOff", 
                   A."EMG_ElectiveFlg", A."EMG_TotSubjects", NULL::BOOLEAN AS "EYCES_AplResultFlg"
            FROM "Exm"."Exm_Master_Group" A 
            INNER JOIN "Exm"."Exm_Master_Group_Subjects" B ON A."EMG_Id" = B."EMG_Id"
            INNER JOIN "IVRM_Master_Subjects" C ON C."ISMS_Id" = B."ISMS_Id"
            WHERE A."MI_Id" = p_MI_Id::BIGINT AND A."EMG_Id" = p_EMG_Id::BIGINT 
                  AND B."EMG_Id" = p_EMG_Id::BIGINT AND A."EMG_ActiveFlag" = TRUE AND B."EMGS_ActiveFlag" = TRUE 
            ORDER BY "ISMS_OrderFlag";
        END IF;
        
    ELSIF p_masteryearly != 'master' THEN
        
        IF p_report_type = 'all' AND p_examwiseorwithout = 'withoutexam' THEN
            RETURN QUERY
            SELECT DISTINCT E."EMG_Id", E."EMG_GroupName", C."ISMS_SubjectName", C."ISMS_OrderFlag", 
                   E."EMG_MaxAplSubjects", E."EMG_MinAplSubjects", E."EMG_BestOff", 
                   E."EMG_ElectiveFlg", E."EMG_TotSubjects", NULL::BOOLEAN AS "EYCES_AplResultFlg"
            FROM "Exm"."Exm_Yearly_Category_Group_Subjects" A 
            INNER JOIN "EXM"."Exm_Yearly_Category_Group" B ON A."EYCG_Id" = B."EYCG_Id"
            INNER JOIN "IVRM_Master_Subjects" C ON C."ISMS_Id" = A."ISMS_Id"
            INNER JOIN "EXM"."Exm_Yearly_Category" D ON D."EYC_Id" = B."EYC_Id"
            INNER JOIN "Exm"."Exm_Master_Group" E ON E."EMG_Id" = B."EMG_Id"
            WHERE D."ASMAY_Id" = p_ASMAY_Id::BIGINT AND D."MI_Id" = p_MI_Id::BIGINT 
                  AND A."EYCGS_ActiveFlg" = TRUE AND B."EYCG_ActiveFlg" = TRUE 
                  AND D."EYC_ActiveFlg" = TRUE AND E."EMG_ActiveFlag" = TRUE
            ORDER BY "ISMS_OrderFlag";
            
        ELSIF p_report_type != 'all' AND p_examwiseorwithout = 'withoutexam' THEN
            RETURN QUERY
            SELECT DISTINCT E."EMG_Id", E."EMG_GroupName", C."ISMS_SubjectName", C."ISMS_OrderFlag", 
                   E."EMG_MaxAplSubjects", E."EMG_MinAplSubjects", E."EMG_BestOff", 
                   E."EMG_ElectiveFlg", E."EMG_TotSubjects", NULL::BOOLEAN AS "EYCES_AplResultFlg"
            FROM "Exm"."Exm_Yearly_Category_Group_Subjects" A 
            INNER JOIN "EXM"."Exm_Yearly_Category_Group" B ON A."EYCG_Id" = B."EYCG_Id"
            INNER JOIN "IVRM_Master_Subjects" C ON C."ISMS_Id" = A."ISMS_Id"
            INNER JOIN "EXM"."Exm_Yearly_Category" D ON D."EYC_Id" = B."EYC_Id"
            INNER JOIN "Exm"."Exm_Master_Group" E ON E."EMG_Id" = B."EMG_Id"
            WHERE D."ASMAY_Id" = p_ASMAY_Id::BIGINT AND D."MI_Id" = p_MI_Id::BIGINT 
                  AND A."EYCGS_ActiveFlg" = TRUE AND B."EYCG_ActiveFlg" = TRUE 
                  AND D."EYC_ActiveFlg" = TRUE AND E."EMG_ActiveFlag" = TRUE
                  AND B."EMG_Id" = p_EMG_Id::BIGINT
            ORDER BY "ISMS_OrderFlag";
            
        ELSIF p_report_type = 'all' AND p_examwiseorwithout != 'withoutexam' THEN
            RETURN QUERY
            SELECT DISTINCT f."EMG_Id", f."EMG_GroupName", e."ISMS_SubjectName", e."ISMS_OrderFlag", 
                   f."EMG_MaxAplSubjects", f."EMG_MinAplSubjects", f."EMG_BestOff",
                   f."EMG_ElectiveFlg", f."EMG_TotSubjects", c."EYCES_AplResultFlg"
            FROM "Exm"."Exm_Yearly_Category" a 
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" b ON a."EYC_Id" = b."EYC_Id"
            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" c ON c."EYCE_Id" = b."EYCE_Id"
            INNER JOIN "Exm"."Exm_Yearly_Category_Group" d ON d."EYC_Id" = a."EYC_Id"
            INNER JOIN "IVRM_Master_Subjects" e ON e."ISMS_Id" = c."ISMS_Id"
            INNER JOIN "Exm"."Exm_Master_Group" f ON f."EMG_Id" = d."EMG_Id"
            WHERE a."EYC_ActiveFlg" = TRUE AND b."EYCE_ActiveFlg" = TRUE AND c."EYCES_ActiveFlg" = TRUE 
                  AND d."EYCG_ActiveFlg" = TRUE AND f."EMG_ActiveFlag" = TRUE 
                  AND a."ASMAY_Id" = p_ASMAY_Id::BIGINT AND b."EME_Id" = p_EME_Id::BIGINT
            ORDER BY "ISMS_OrderFlag";
            
        ELSIF p_report_type != 'all' AND p_examwiseorwithout != 'withoutexam' THEN
            RETURN QUERY
            SELECT DISTINCT f."EMG_Id", f."EMG_GroupName", e."ISMS_SubjectName", e."ISMS_OrderFlag", 
                   f."EMG_MaxAplSubjects", f."EMG_MinAplSubjects", f."EMG_BestOff",
                   f."EMG_ElectiveFlg", f."EMG_TotSubjects", c."EYCES_AplResultFlg"
            FROM "Exm"."Exm_Yearly_Category" a 
            INNER JOIN "Exm"."Exm_Yearly_Category_Exams" b ON a."EYC_Id" = b."EYC_Id"
            INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" c ON c."EYCE_Id" = b."EYCE_Id"
            INNER JOIN "Exm"."Exm_Yearly_Category_Group" d ON d."EYC_Id" = a."EYC_Id"
            INNER JOIN "IVRM_Master_Subjects" e ON e."ISMS_Id" = c."ISMS_Id"
            INNER JOIN "Exm"."Exm_Master_Group" f ON f."EMG_Id" = d."EMG_Id"
            WHERE a."EYC_ActiveFlg" = TRUE AND b."EYCE_ActiveFlg" = TRUE AND c."EYCES_ActiveFlg" = TRUE 
                  AND d."EYCG_ActiveFlg" = TRUE AND f."EMG_ActiveFlag" = TRUE 
                  AND a."ASMAY_Id" = p_ASMAY_Id::BIGINT AND b."EME_Id" = p_EME_Id::BIGINT 
                  AND f."EMG_Id" = p_EMG_Id::BIGINT AND d."EMG_Id" = p_EMG_Id::BIGINT
            ORDER BY "ISMS_OrderFlag";
        END IF;
        
    END IF;
    
    RETURN;
    
END;
$$;