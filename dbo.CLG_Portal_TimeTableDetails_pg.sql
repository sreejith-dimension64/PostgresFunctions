CREATE OR REPLACE FUNCTION "dbo"."CLG_Portal_TimeTableDetails"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMCST_Id BIGINT
)
RETURNS TABLE(
    "TTMD_DayName" VARCHAR,
    "TTMD_DayCode" VARCHAR,
    "ISMS_SubjectName" TEXT,
    "TTMDPT_StartTime" TIME,
    "TTMDPT_EndTime" TIME,
    "TTMP_PeriodName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMCO_Id BIGINT;
    v_AMSE_Id BIGINT;
    v_AMB_Id BIGINT;
BEGIN
    
    SELECT "AMCO_Id", "AMSE_Id", "AMB_Id"
    INTO v_AMCO_Id, v_AMSE_Id, v_AMB_Id
    FROM "CLG"."Adm_College_Yearly_Student"
    WHERE "AMCST_Id" = p_AMCST_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "ACYST_ActiveFlag" = 1;

    RETURN QUERY
    SELECT 
        C."TTMD_DayName",
        C."TTMD_DayCode",
        STRING_AGG(I."ISMS_SubjectName", '/' ORDER BY I."ISMS_SubjectName")::TEXT AS "ISMS_SubjectName",
        H."TTMDPT_StartTime",
        H."TTMDPT_EndTime",
        D."TTMP_PeriodName"
    FROM "TT_Final_Generation" A
    INNER JOIN "TT_Final_Generation_Detailed_College" B ON B."TTFG_Id" = A."TTFG_Id"
    INNER JOIN "TT_Master_Day" C ON C."TTMD_Id" = B."TTMD_Id"
    INNER JOIN "TT_Master_Period" D ON D."TTMP_Id" = B."TTMP_Id"
    INNER JOIN "TT_Master_Period_CourseBranch" E ON E."TTMP_Id" = D."TTMP_Id" 
        AND B."AMCO_Id" = E."AMCO_Id" 
        AND B."AMSE_Id" = E."AMSE_Id" 
        AND B."AMB_Id" = E."AMB_Id" 
        AND A."ASMAY_Id" = E."ASMAY_Id"
    INNER JOIN "CLG"."Adm_College_Master_Section" J ON J."ACMS_Id" = B."ACMS_Id"
    INNER JOIN "TT_Master_Subject_Abbreviation" F ON F."ISMS_Id" = B."ISMS_Id"
    INNER JOIN "TT_Master_Category" G ON G."TTMC_Id" = A."TTMC_Id"
    LEFT JOIN "TT_Master_Day_Period_Time" H ON H."TTMC_Id" = G."TTMC_Id" 
        AND H."TTMD_Id" = C."TTMD_Id" 
        AND H."TTMP_Id" = D."TTMP_Id" 
        AND H."ASMAY_Id" = E."ASMAY_Id"
    INNER JOIN "IVRM_Master_Subjects" I ON I."ISMS_Id" = F."ISMS_Id"
    WHERE A."MI_Id" = p_MI_Id 
        AND A."ASMAY_Id" = p_ASMAY_Id 
        AND C."TTMD_DayName" = TO_CHAR(CURRENT_TIMESTAMP, 'Day')
    GROUP BY 
        H."TTMDPT_StartTime",
        H."TTMDPT_EndTime",
        C."TTMD_DayName",
        C."TTMD_DayCode",
        D."TTMP_PeriodName"
    ORDER BY D."TTMP_PeriodName";
    
    RETURN;
END;
$$;