CREATE OR REPLACE FUNCTION "dbo"."CLG_TT_class_sections"(
    p_MI_Id BIGINT, 
    p_ASMAY_Id BIGINT, 
    p_HRME_Id BIGINT
)
RETURNS TABLE(
    p_Days VARCHAR,
    period VARCHAR,
    asmcL_ClassName TEXT,
    ismS_SubjectName VARCHAR
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        f."TTMD_DayName" as p_Days,
        e."TTMP_PeriodName" as period,
        STRING_AGG(CONCAT(c."AMCO_CourseName", '-', d."AMB_BranchName", '-', h."AMSE_SEMName"), '/') as asmcL_ClassName,
        g."ISMS_SubjectName" as ismS_SubjectName
    FROM "TT_Final_Generation" a 
    INNER JOIN "TT_Final_Generation_Detailed_College" b ON a."TTFG_Id" = b."TTFG_Id"
    INNER JOIN "CLG"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" h ON h."AMSE_Id" = b."AMSE_Id"
    INNER JOIN "TT_Master_Period" e ON b."TTMP_Id" = e."TTMP_Id"
    INNER JOIN "TT_Master_Day" f ON b."TTMD_Id" = f."TTMD_Id"
    INNER JOIN "IVRM_Master_Subjects" g ON b."ISMS_Id" = g."ISMS_Id" AND a."MI_Id" = g."MI_Id"
    WHERE a."ASMAY_Id" = p_ASMAY_Id 
        AND a."MI_Id" = p_MI_Id 
        AND c."MI_Id" = p_MI_Id 
        AND d."AMB_ActiveFlag" = 1 
        AND c."AMCO_ActiveFlag" = 1 
        AND h."AMSE_ActiveFlg" = 1 
        AND b."HRME_Id" = p_HRME_Id
    GROUP BY f."TTMD_DayName", e."TTMP_PeriodName", g."ISMS_SubjectName"
    ORDER BY asmcL_ClassName;
    
    RETURN;
END;
$$;