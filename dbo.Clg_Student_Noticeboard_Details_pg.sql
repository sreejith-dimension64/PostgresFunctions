CREATE OR REPLACE FUNCTION "dbo"."Clg_Student_Noticeboard_Details"(
    "MI_Id" TEXT,
    "Typeflg" TEXT,
    "AMCST_Id" TEXT,
    "ASMAY_Id" TEXT
)
RETURNS TABLE(
    "INTB_Id" INTEGER,
    "INTB_Title" TEXT,
    "AMCO_CourseName" TEXT,
    "AMB_BranchName" TEXT,
    "AMSE_SEMName" TEXT,
    "INTB_DisplayDate" TIMESTAMP,
    "INTB_Description" TEXT,
    "INTB_StartDate" TIMESTAMP,
    "INTB_EndDate" TIMESTAMP,
    "CreatedDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
    "fromyear" VARCHAR(10);
    "Toyear" VARCHAR(10);
    "year" VARCHAR(50);
    "betweendates" TEXT;
    "dynamic" TEXT;
BEGIN
    
    SELECT DISTINCT "ASMAY_Year" INTO "year"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "ASMAY_Id" = "ASMAY_Id"::INTEGER 
    AND "MI_Id" = "MI_Id"::INTEGER;
    
    RAISE NOTICE '%', "year";
    
    SELECT "IMFY_FromDate" INTO "fromyear"
    FROM "IVRM_Master_FinancialYear" 
    WHERE "IMFY_FinancialYear" = "year";
    
    SELECT CAST("INTB_EndDate" AS DATE) INTO "Toyear"
    FROM "IVRM_NoticeBoard" 
    WHERE "intb_id" IN (
        SELECT MAX("intb_id") 
        FROM "IVRM_NoticeBoard"
    );
    
    RAISE NOTICE '%', "Toyear";
    
    "betweendates" := '(CAST(a."intB_StartDate" AS DATE)>=''' || "fromyear" || ''' AND CAST(a."intB_EndDate" AS DATE)<=''' || "Toyear" || ''')';
    
    "dynamic" := '
    SELECT DISTINCT a."INTB_Id",
        a."INTB_Title",
        (SELECT b."AMCO_CourseName" 
         FROM "clg"."Adm_College_Yearly_Student" a
         INNER JOIN "clg"."Adm_Master_Course" b ON a."AMCO_Id" = b."AMCO_Id" 
         WHERE a."ASMAY_Id" = ' || "ASMAY_Id" || ' 
         AND a."AMCST_Id" = ' || "AMCST_Id" || ' 
         LIMIT 1) as "AMCO_CourseName",
        (SELECT b."AMB_BranchName" 
         FROM "clg"."Adm_College_Yearly_Student" a
         INNER JOIN "clg"."Adm_Master_Branch" b ON a."AMB_Id" = b."AMB_Id" 
         WHERE a."ASMAY_Id" = ' || "ASMAY_Id" || ' 
         AND a."AMCST_Id" = ' || "AMCST_Id" || ' 
         LIMIT 1) as "AMB_BranchName",
        (SELECT b."AMSE_SEMName" 
         FROM "clg"."Adm_College_Yearly_Student" a
         INNER JOIN "clg"."Adm_Master_Semester" b ON a."AMSE_Id" = b."AMSE_Id" 
         WHERE a."ASMAY_Id" = ' || "ASMAY_Id" || ' 
         AND a."AMCST_Id" = ' || "AMCST_Id" || ' 
         LIMIT 1) as "AMSE_SEMName",
        a."INTB_DisplayDate",
        a."INTB_Description",
        a."INTB_StartDate",
        a."INTB_EndDate",
        a."CreatedDate"
    FROM "IVRM_NoticeBoard" a
    INNER JOIN "clg"."IVRM_NoticeBoard_Student_College" f ON f."INTB_Id" = a."INTB_Id"
    WHERE a."MI_Id"::TEXT IN (' || "MI_Id" || ') 
    AND a."NTB_TTSylabusFlg" IN (''' || "Typeflg" || ''')
    AND f."AMCST_Id"::TEXT IN (''' || "AMCST_Id" || ''') 
    AND ' || "betweendates" || '
    ORDER BY "CreatedDate" DESC';
    
    RAISE NOTICE '%', "dynamic";
    
    RETURN QUERY EXECUTE "dynamic";
    
END;
$$;