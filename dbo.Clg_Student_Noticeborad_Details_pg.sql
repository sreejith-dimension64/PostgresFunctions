CREATE OR REPLACE FUNCTION "dbo"."Clg_Student_Noticeborad_Details"(
    "MI_Id" TEXT,
    "Typeflg" TEXT
)
RETURNS TABLE(
    "INTB_Id" BIGINT,
    "INTB_Title" TEXT,
    "AMCO_CourseName" TEXT,
    "AMB_BranchName" TEXT,
    "AMSE_SEMName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_dynamic TEXT;
    v_NTB_TTSylabusFlg VARCHAR(100);
    v_AMCST_Id BIGINT;
BEGIN
    v_dynamic := '
    SELECT a."INTB_Id", a."INTB_Title", c."AMCO_CourseName", d."AMB_BranchName", e."AMSE_SEMName"
    FROM "IVRM_NoticeBoard" a 
    INNER JOIN "clg"."IVRM_NoticeBoard_CoBranch" b ON a."INTB_Id" = b."INTB_Id"
    INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
    WHERE a."MI_Id"::TEXT IN (' || "MI_Id" || ') AND a."NTB_TTSylabusFlg" IN (''' || "Typeflg" || ''')
    
    UNION
    
    SELECT a."INTB_Id", a."INTB_Title", f."AMCO_CourseName", g."AMB_BranchName", h."AMSE_SEMName"
    FROM "IVRM_NoticeBoard" a 
    INNER JOIN "clg"."IVRM_NoticeBoard_CoBranch" b ON a."INTB_Id" = b."INTB_Id"
    INNER JOIN "clg"."IVRM_NoticeBoard_Student_College" c ON c."INTB_Id" = b."INTB_Id"
    INNER JOIN "clg"."Adm_Master_College_Student" d ON d."AMCST_Id" = c."AMCST_Id" AND "AMCST_ActiveFlag" = 1
    INNER JOIN "clg"."Adm_College_Yearly_Student" e ON e."AMCST_Id" = d."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_Course" f ON f."AMCO_Id" = d."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" g ON g."AMB_Id" = d."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" h ON h."AMSE_Id" = d."AMSE_Id"
    WHERE a."MI_Id"::TEXT IN (' || "MI_Id" || ') AND a."NTB_TTSylabusFlg" IN (''' || "Typeflg" || ''')';
    
    RAISE NOTICE '%', v_dynamic;
    
    RETURN QUERY EXECUTE v_dynamic;
    
END;
$$;