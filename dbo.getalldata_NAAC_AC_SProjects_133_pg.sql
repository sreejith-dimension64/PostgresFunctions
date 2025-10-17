CREATE OR REPLACE FUNCTION "dbo"."getalldata_NAAC_AC_SProjects_133"(@MI_Id bigint)
RETURNS TABLE (
    "AMCST_Id" bigint,
    "AMCO_Id" bigint,
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "AMCO_CourseName" varchar,
    "AMB_Id" bigint,
    "AMB_BranchName" varchar,
    "AMSE_Id" bigint,
    "AMSE_SEMName" varchar,
    "NCACSPR133_ActiveFlg" boolean,
    "NCACSPR133_Id" bigint,
    "NCACSPR133_ProjectName" varchar,
    "ncacspR133_StatusFlg" boolean,
    "ncacspR133_ApprovedFlg" boolean,
    "NCACSPR133_Remarks" text,
    "studentname" text,
    "AMCST_AdmNo" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT a."AMCST_Id", b."AMCO_Id", m."MI_Id", c."ASMAY_Id", d."AMCO_CourseName", b."AMB_Id", 
           e."AMB_BranchName", b."AMSE_Id", f."AMSE_SEMName", m."NCACSPR133_ActiveFlg", m."NCACSPR133_Id", 
           m."NCACSPR133_ProjectName", m."NCACSPR133_StatusFlg" as "ncacspR133_StatusFlg",
           m."NCACSPR133_ApprovedFlg" as "ncacspR133_ApprovedFlg", m."NCACSPR133_Remarks",
           (COALESCE(a."AMCST_FirstName", '') || '' || COALESCE(a."AMCST_MiddleName", '') || '' || COALESCE(a."AMCST_LastName", ''))::text as "studentname", 
           a."AMCST_AdmNo"
    FROM "CLG"."Adm_Master_College_Student" a
    INNER JOIN "CLG"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id" 
    INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = b."ASMAY_Id"
    INNER JOIN "CLG"."Adm_Master_Course" d ON d."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" e ON e."AMB_Id" = b."AMB_Id" 
    INNER JOIN "CLG"."Adm_Master_Semester" f ON f."AMSE_Id" = b."AMSE_Id" 
    INNER JOIN "NAAC_AC_SProjects_133" m ON b."AMCO_Id" = m."AMCO_Id" 
                                         AND b."AMB_Id" = m."AMB_Id" 
                                         AND b."AMCST_Id" = m."AMCST_Id" 
    WHERE a."AMCST_ActiveFlag" = 1 
      AND a."AMCST_SOL" = 'S' 
      AND a."MI_Id" = @MI_Id;
END;
$$;