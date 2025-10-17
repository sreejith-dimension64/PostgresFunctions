CREATE OR REPLACE FUNCTION "dbo"."CLGALUMNI_BirthdayList" (p_MI_Id bigint)
RETURNS TABLE (
    "AlCMST_Id" bigint,
    "studentname" text,
    "AlCMST_AdmNo" text,
    "AMCO_CourseName" text,
    "AMB_BranchName" text,
    "AMSE_SEMName" text,
    "AlCMST_MobileNo" text,
    "AlCMST_emailId" text,
    "AlCMST_DOB" timestamp,
    "ASMAY_Year" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "AMCS"."AlCMST_Id",
        (CASE WHEN "AMCS"."AlCMST_FirstName" IS NULL OR "AMCS"."AlCMST_FirstName" = '' THEN '' ELSE "AMCS"."AlCMST_FirstName" END || 
         CASE WHEN "AMCS"."AlCMST_MiddleName" IS NULL OR "AMCS"."AlCMST_MiddleName" = '' OR "AMCS"."AlCMST_MiddleName" = '0' THEN '' ELSE ' ' || "AMCS"."AlCMST_MiddleName" END || 
         CASE WHEN "AMCS"."AlCMST_LastName" IS NULL OR "AMCS"."AlCMST_LastName" = '' OR "AMCS"."AlCMST_LastName" = '0' THEN '' ELSE ' ' || "AMCS"."AlCMST_LastName" END)::text AS "studentname",
        "AMCS"."AlCMST_AdmNo",
        "AMCO"."AMCO_CourseName",
        "AMB"."AMB_BranchName",
        "AMSE"."AMSE_SEMName",
        "AMCS"."AlCMST_MobileNo",
        "AMCS"."AlCMST_emailId",
        "AMCS"."AlCMST_DOB",
        "ASMAY"."ASMAY_Year"
    FROM "CLG"."Alumni_College_Master_Student" "AMCS"
    INNER JOIN "CLG"."Adm_Master_Course" "AMCO" ON "AMCO"."MI_Id" = p_MI_Id AND "AMCO"."AMCO_Id" = "AMCS"."AMCO_Left_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" "AMB" ON "AMB"."MI_Id" = p_MI_Id AND "AMB"."AMB_Id" = "AMCS"."AMB_Id_Left"
    INNER JOIN "dbo"."Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = "AMCS"."ASMAY_Id_Left" AND "ASMAY"."MI_Id" = p_MI_Id
    INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."MI_Id" = p_MI_Id AND "AMSE"."AMSE_Id" = "AMCS"."AMSE_Id_Left"
    WHERE "AMCS"."MI_Id" = p_MI_Id AND (EXTRACT(MONTH FROM "AMCS"."ALCMST_DOB") = EXTRACT(MONTH FROM CURRENT_TIMESTAMP));
END;
$$;