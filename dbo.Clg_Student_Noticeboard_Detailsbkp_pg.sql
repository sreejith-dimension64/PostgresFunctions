CREATE OR REPLACE FUNCTION "Clg_Student_Noticeboard_Detailsbkp"(
    p_MI_Id TEXT,
    p_Typeflg TEXT,
    p_AMCST_Id TEXT,
    p_ASMAY_Id TEXT
)
RETURNS TABLE(
    "INTB_Id" INTEGER,
    "INTB_Title" TEXT,
    "AMCO_CourseName" TEXT,
    "AMB_BranchName" TEXT,
    "AMSE_SEMName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
    v_fromyear VARCHAR(10);
    v_Toyear VARCHAR(10);
    v_year VARCHAR(50);
    v_betweendates TEXT;
    v_dynamic TEXT;
BEGIN
    
    -- Get year from Adm_School_M_Academic_Year
    SELECT DISTINCT "ASMAY_Year" INTO v_year
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_Id" = p_ASMAY_Id::INTEGER 
    AND "MI_Id" = p_MI_Id::INTEGER;
    
    RAISE NOTICE '%', v_year;
    
    -- Get from year
    SELECT "IMFY_FromDate" INTO v_fromyear
    FROM "IVRM_Master_FinancialYear" 
    WHERE "IMFY_FinancialYear" = v_year;
    
    RAISE NOTICE '%', v_fromyear;
    
    -- Get to year
    SELECT CAST("INTB_EndDate" AS DATE)::VARCHAR INTO v_Toyear
    FROM "IVRM_NoticeBoard";
    
    RAISE NOTICE '%', v_Toyear;
    
    SET v_betweendates = '(CAST(a."intB_StartDate" AS DATE)>=''' || v_fromyear || ''' AND CAST(a."intB_EndDate" AS DATE)<=''' || v_Toyear || ''')';
    
    -- Build dynamic query
    v_dynamic := '
    SELECT DISTINCT a."INTB_Id", a."INTB_Title", f."AMCO_CourseName", g."AMB_BranchName", h."AMSE_SEMName"
    FROM "IVRM_NoticeBoard" a 
    INNER JOIN clg."IVRM_NoticeBoard_CoBranch" b ON a."INTB_Id" = b."INTB_Id"
    INNER JOIN clg."IVRM_NoticeBoard_Student_College" c ON c."INTB_Id" = b."INTB_Id"
    INNER JOIN clg."Adm_Master_College_Student" d ON d."AMCST_Id" = c."AMCST_Id" AND "AMCST_ActiveFlag" = 1
    INNER JOIN clg."Adm_College_Yearly_Student" e ON e."AMCST_Id" = d."AMCST_Id"
    INNER JOIN clg."Adm_Master_Course" f ON f."AMCO_Id" = b."AMCO_Id"
    INNER JOIN clg."Adm_Master_Branch" g ON g."AMB_Id" = b."AMB_Id"
    INNER JOIN clg."Adm_Master_Semester" h ON h."AMSE_Id" = b."AMSE_Id"
    WHERE a."MI_Id" IN (' || p_MI_Id || ') 
    AND a."NTB_TTSylabusFlg" IN (''' || p_Typeflg || ''') 
    AND c."AMCST_Id" IN (''' || p_AMCST_Id || ''') 
    AND ' || v_betweendates;
    
    RAISE NOTICE '%', v_dynamic;
    
    -- Execute dynamic query and return results
    RETURN QUERY EXECUTE v_dynamic;
    
END;
$$;