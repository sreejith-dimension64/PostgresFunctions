CREATE OR REPLACE FUNCTION "dbo"."Clg_Student_Noticeboard_Datewise"(
    p_MI_Id TEXT,
    p_AMCST_Id TEXT,
    p_ASMAY_Id TEXT,
    p_fromdate TEXT,
    p_todate TEXT
)
RETURNS TABLE(
    "INTB_Id" INTEGER,
    "INTB_Title" VARCHAR,
    "AMCO_CourseName" VARCHAR,
    "AMB_BranchName" VARCHAR,
    "AMSE_SEMName" VARCHAR,
    "INTB_EndDate" TIMESTAMP,
    "INTB_Description" TEXT,
    "INTB_StartDate" TIMESTAMP,
    "NTB_TTSylabusFlg" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dynamic TEXT;
BEGIN
    
    v_dynamic := '
    SELECT a."INTB_Id", a."INTB_Title", c."AMCO_CourseName", d."AMB_BranchName", e."AMSE_SEMName", 
           a."INTB_EndDate", a."INTB_Description", a."INTB_StartDate", a."NTB_TTSylabusFlg"
    FROM "IVRM_NoticeBoard" a 
    INNER JOIN "clg"."IVRM_NoticeBoard_CoBranch" b ON a."INTB_Id" = b."INTB_Id"
    INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
    INNER JOIN "clg"."IVRM_NoticeBoard_Student_College" f ON f."INTB_Id" = a."INTB_Id"
    WHERE a."MI_Id" IN (' || p_MI_Id || ') 
      AND f."AMCST_Id" IN (' || p_AMCST_Id || ') 
      AND CAST(a."INTB_StartDate" AS DATE) >= ''' || p_fromdate || '''
      AND CAST(a."INTB_EndDate" AS DATE) <= ''' || p_todate || '''
    
    UNION
    
    SELECT a."INTB_Id", a."INTB_Title", f."AMCO_CourseName", g."AMB_BranchName", h."AMSE_SEMName",
           a."INTB_EndDate", a."INTB_Description", a."INTB_StartDate", a."NTB_TTSylabusFlg"
    FROM "IVRM_NoticeBoard" a 
    INNER JOIN "clg"."IVRM_NoticeBoard_CoBranch" b ON a."INTB_Id" = b."INTB_Id"
    INNER JOIN "clg"."IVRM_NoticeBoard_Student_College" c ON c."INTB_Id" = b."INTB_Id"
    INNER JOIN "clg"."Adm_Master_College_Student" d ON d."AMCST_Id" = c."AMCST_Id" AND d."AMCST_ActiveFlag" = 1
    INNER JOIN "clg"."Adm_College_Yearly_Student" e ON e."AMCST_Id" = d."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_Course" f ON f."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" g ON g."AMB_Id" = b."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" h ON h."AMSE_Id" = b."AMSE_Id"
    WHERE a."MI_Id" IN (' || p_MI_Id || ') 
      AND c."AMCST_Id" IN (' || p_AMCST_Id || ')
      AND CAST(a."INTB_StartDate" AS DATE) >= ''' || p_fromdate || '''
      AND CAST(a."INTB_EndDate" AS DATE) <= ''' || p_todate || '''';
    
    RAISE NOTICE '%', v_dynamic;
    
    RETURN QUERY EXECUTE v_dynamic;
    
END;
$$;