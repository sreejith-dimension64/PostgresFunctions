CREATE OR REPLACE FUNCTION "dbo"."College_Admission_Get_Tpin_Student_List"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_Flag BIGINT
)
RETURNS TABLE(
    studentname TEXT,
    admno VARCHAR,
    coursename VARCHAR,
    branchname VARCHAR,
    semname VARCHAR,
    sectionname VARCHAR,
    tpin VARCHAR,
    "AMCO_Order" INTEGER,
    "AMB_Order" INTEGER,
    "AMSE_SEMOrder" INTEGER,
    "ACMS_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    /* Tpin Not Generated List */
    
    IF p_Flag = 1 THEN
        RETURN QUERY
        SELECT 
            (CASE WHEN "A"."AMCST_FirstName" IS NULL OR "A"."AMCST_FirstName" = '' THEN '' ELSE "A"."AMCST_FirstName" END || 
            CASE WHEN "A"."AMCST_MiddleName" IS NULL OR "A"."AMCST_MiddleName" = '' THEN '' ELSE ' ' || "A"."AMCST_MiddleName" END || 
            CASE WHEN "A"."AMCST_LastName" IS NULL OR "A"."AMCST_LastName" = '' THEN '' ELSE ' ' || "A"."AMCST_LastName" END)::TEXT AS studentname,
            "A"."AMCST_AdmNo" AS admno,
            "D"."AMCO_CourseName" AS coursename,
            "E"."AMB_BranchName" AS branchname,
            "F"."AMSE_SEMName" AS semname,
            "G"."ACMS_SectionName" AS sectionname,
            NULL::VARCHAR AS tpin,
            "D"."AMCO_Order",
            "E"."AMB_Order",
            "F"."AMSE_SEMOrder",
            "G"."ACMS_Order"
        FROM "CLG"."Adm_Master_College_Student" "A"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "B" ON "A"."AMCST_Id" = "B"."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "C" ON "C"."ASMAY_Id" = "B"."ASMAY_Id"
        INNER JOIN "Clg"."Adm_Master_Course" "D" ON "D"."AMCO_Id" = "B"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "E" ON "E"."AMB_Id" = "B"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "F" ON "F"."AMSE_Id" = "B"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "G" ON "G"."ACMS_Id" = "B"."ACMS_Id"
        WHERE "B"."ASMAY_Id" = p_ASMAY_Id 
            AND "A"."MI_Id" = p_MI_Id 
            AND "A"."AMCST_SOL" = 'S' 
            AND "A"."AMCST_ActiveFlag" = 1 
            AND "B"."ACYST_ActiveFlag" = 1
            AND ("A"."AMCST_TPINNO" IS NULL OR "A"."AMCST_TPINNO" = '0')
        ORDER BY "D"."AMCO_Order", "E"."AMB_Order", "F"."AMSE_SEMOrder", "G"."ACMS_Order", studentname;
    
    ELSIF p_Flag = 2 THEN
        RETURN QUERY
        SELECT 
            (CASE WHEN "A"."AMCST_FirstName" IS NULL OR "A"."AMCST_FirstName" = '' THEN '' ELSE "A"."AMCST_FirstName" END || 
            CASE WHEN "A"."AMCST_MiddleName" IS NULL OR "A"."AMCST_MiddleName" = '' THEN '' ELSE ' ' || "A"."AMCST_MiddleName" END || 
            CASE WHEN "A"."AMCST_LastName" IS NULL OR "A"."AMCST_LastName" = '' THEN '' ELSE ' ' || "A"."AMCST_LastName" END)::TEXT AS studentname,
            "A"."AMCST_AdmNo" AS admno,
            "D"."AMCO_CourseName" AS coursename,
            "E"."AMB_BranchName" AS branchname,
            "F"."AMSE_SEMName" AS semname,
            "G"."ACMS_SectionName" AS sectionname,
            "A"."AMCST_TPINNO" AS tpin,
            "D"."AMCO_Order",
            "E"."AMB_Order",
            "F"."AMSE_SEMOrder",
            "G"."ACMS_Order"
        FROM "CLG"."Adm_Master_College_Student" "A"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "B" ON "A"."AMCST_Id" = "B"."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "C" ON "C"."ASMAY_Id" = "B"."ASMAY_Id"
        INNER JOIN "Clg"."Adm_Master_Course" "D" ON "D"."AMCO_Id" = "B"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "E" ON "E"."AMB_Id" = "B"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "F" ON "F"."AMSE_Id" = "B"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "G" ON "G"."ACMS_Id" = "B"."ACMS_Id"
        WHERE "B"."ASMAY_Id" = p_ASMAY_Id 
            AND "A"."MI_Id" = p_MI_Id 
            AND "A"."AMCST_SOL" = 'S' 
            AND "A"."AMCST_ActiveFlag" = 1 
            AND "B"."ACYST_ActiveFlag" = 1
            AND ("A"."AMCST_TPINNO" IS NOT NULL AND "A"."AMCST_TPINNO" != '0')
        ORDER BY "D"."AMCO_Order", "E"."AMB_Order", "F"."AMSE_SEMOrder", "G"."ACMS_Order", studentname;
    
    END IF;
    
    RETURN;
END;
$$;