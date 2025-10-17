CREATE OR REPLACE FUNCTION "CollegeDashboard_timetable_daywise"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_AMCST_Id bigint,
    p_dayname varchar(50)
)
RETURNS TABLE(
    "TTMD_DayName" varchar,
    "TTMD_DayCode" varchar,
    "ISMS_SubjectName" varchar,
    "TTMSUAB_Abbreviation" varchar,
    "TTMDPT_StartTime" varchar,
    "TTMDPT_EndTime" varchar,
    "TTMSAB_Abbreviation" varchar
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMCO_Id bigint;
    v_AMSE_Id bigint;
    v_AMB_Id bigint;
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
        I."ISMS_SubjectName",
        F."TTMSUAB_Abbreviation",
        COALESCE(H."TTMDPT_StartTime", '') AS "TTMDPT_StartTime",
        COALESCE(H."TTMDPT_EndTime", '') AS "TTMDPT_EndTime",
        J."TTMSAB_Abbreviation"
    FROM "TT_Final_Generation" A
    INNER JOIN "TT_Final_Generation_Detailed_College" B ON B."TTFG_Id" = A."TTFG_Id"
    INNER JOIN "TT_Master_Day" C ON C."TTMD_Id" = B."TTMD_Id"
    INNER JOIN "TT_Master_Period" D ON D."TTMP_Id" = B."TTMP_Id"
    INNER JOIN "TT_Master_Period_CourseBranch" E ON E."TTMP_Id" = D."TTMP_Id" 
        AND B."AMCO_Id" = E."AMCO_Id" 
        AND B."AMSE_Id" = E."AMSE_Id" 
        AND B."AMB_Id" = E."AMB_Id" 
        AND A."ASMAY_Id" = E."ASMAY_Id"
    INNER JOIN "TT_Master_Subject_Abbreviation" F ON F."ISMS_Id" = B."ISMS_Id"
    INNER JOIN "TT_Master_Category" G ON G."TTMC_Id" = A."TTMC_Id"
    LEFT JOIN "TT_Master_Day_Period_Time" H ON H."TTMC_Id" = G."TTMC_Id" 
        AND H."TTMD_Id" = C."TTMD_Id" 
        AND H."TTMP_Id" = D."TTMP_Id" 
        AND H."ASMAY_Id" = E."ASMAY_Id"
    INNER JOIN "IVRM_Master_Subjects" I ON I."ISMS_Id" = F."ISMS_Id"
    INNER JOIN "TT_Master_Staff_Abbreviation" J ON J."HRME_Id" = B."HRME_Id"
    WHERE A."MI_Id" = p_MI_Id 
        AND A."ASMAY_Id" = p_ASMAY_Id 
        AND B."AMCO_Id" = v_AMCO_Id 
        AND B."AMSE_Id" = v_AMSE_Id 
        AND B."AMB_Id" = v_AMB_Id 
        AND C."TTMD_DayName" = p_dayname
    ORDER BY D."TTMP_PeriodName";
    
END;
$$;