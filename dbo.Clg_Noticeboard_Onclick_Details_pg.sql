CREATE OR REPLACE FUNCTION "dbo"."Clg_Noticeboard_Onclick_Details"(
    "@MI_Id" TEXT,
    "@INTB_Id" TEXT
)
RETURNS TABLE (
    "INTBCB_Id" INTEGER,
    "INTB_Title" TEXT,
    "AMCO_Id" INTEGER,
    "AMB_Id" INTEGER,
    "AMSE_Id" INTEGER,
    "AMCO_CourseName" TEXT,
    "AMB_BranchName" TEXT,
    "INTBCB_ActiveFlag" BOOLEAN,
    "INTBFL_FileName" TEXT,
    "INTBFL_FilePath" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        b."INTBCB_Id",
        a."INTB_Title",
        b."AMCO_Id",
        b."AMB_Id",
        b."AMSE_Id",
        c."AMCO_CourseName",
        d."AMB_BranchName",
        b."INTBCB_ActiveFlag",
        f."INTBFL_FileName",
        f."INTBFL_FilePath"
    FROM "IVRM_NoticeBoard" a 
    INNER JOIN "clg"."IVRM_NoticeBoard_CoBranch" b ON a."INTB_Id" = b."INTB_Id"
    INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = b."AMSE_Id"
    INNER JOIN "IVRM_NoticeBoard_Files" f ON f."INTB_Id" = a."INTB_Id"
    WHERE a."MI_Id" = "@MI_Id" AND a."INTB_Id" = "@INTB_Id"
    ORDER BY b."INTBCB_Id";
END;
$$;