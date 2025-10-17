CREATE OR REPLACE FUNCTION "clg"."Admission_Branch_Changes"(p_MI_ID bigint)
RETURNS TABLE(
    "AMCST_Id" bigint,
    "sName" varchar,
    "AMCO_CourseName" varchar,
    "AMB_BranchName" varchar,
    "ACSCOB_COBFees" numeric,
    "ACSCOB_OldRegNo" varchar,
    "ACSCOB_NewRegNo" varchar,
    "ACSCOB_ActiveFlag" boolean,
    "ACSCOB_Id" bigint,
    "NewBranch" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        A."AMCST_Id", 
        A."sName",
        A."AMCO_CourseName",
        A."AMB_BranchName",
        A."ACSCOB_COBFees",
        A."ACSCOB_OldRegNo",
        A."ACSCOB_NewRegNo",
        A."ACSCOB_ActiveFlag",
        A."ACSCOB_Id",
        B."NewBranch"
    FROM 
    (SELECT 
        a."AMCST_Id", 
        a."AMCST_FirstName" as "sName",
        c."AMCO_CourseName",
        d."AMB_BranchName",
        a."ACSCOB_COBFees",
        a."ACSCOB_OldRegNo",
        a."ACSCOB_NewRegNo",
        a."ACSCOB_ActiveFlag",
        a."ACSCOB_Id"
    FROM "clg"."Adm_College_Students_COB" a 
    INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_Course" c ON a."AMCO_Id" = c."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" d ON a."AMB_Id" = d."AMB_Id" AND a."MI_Id" = p_MI_ID) AS A
    CROSS JOIN
    (SELECT 
        a."AMCST_Id",
        d."AMB_BranchName" as "NewBranch" 
    FROM "clg"."Adm_College_Students_COB" a 
    INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_Course" c ON a."AMCO_Id" = c."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" d ON a."ACSCOB_AMB_Id" = d."AMB_Id" AND a."MI_Id" = p_MI_ID) AS B 
    WHERE A."AMCST_Id" = B."AMCST_Id";
END;
$$;