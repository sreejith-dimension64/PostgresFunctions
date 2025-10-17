CREATE OR REPLACE FUNCTION "dbo"."College_Student_Document_Report"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_AMB_Id TEXT,
    p_AMSE_Id TEXT,
    p_ACMS_Id TEXT,
    p_FLAG TEXT,
    p_AMCST_Id TEXT,
    p_AMSMD_Id TEXT
)
RETURNS TABLE(
    docname TEXT,
    statuss TEXT,
    submited TEXT,
    docpath TEXT,
    studentnam TEXT,
    admno TEXT,
    coursename TEXT,
    branchname TEXT,
    semestername TEXT,
    sectionname TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_FLAG = '2' THEN
        RETURN QUERY
        SELECT 
            b."AMSMD_DocumentName" AS docname,
            'Yes'::TEXT AS statuss,
            'Submited'::TEXT AS submited,
            a."ACSTD_Doc_Path" AS docpath,
            (CASE WHEN d."AMCST_FirstName" IS NULL OR d."AMCST_FirstName" = '' THEN '' ELSE d."AMCST_FirstName" END ||
             CASE WHEN d."AMCST_MiddleName" IS NULL OR d."AMCST_MiddleName" = '' OR d."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || d."AMCST_MiddleName" END ||
             CASE WHEN d."AMCST_LastName" IS NULL OR d."AMCST_LastName" = '' OR d."AMCST_LastName" = '0' THEN '' ELSE ' ' || d."AMCST_LastName" END)::TEXT AS studentnam,
            d."AMCST_AdmNo"::TEXT AS admno,
            e."AMCO_CourseName"::TEXT AS coursename,
            f."AMB_BranchName"::TEXT AS branchname,
            h."AMSE_SEMName"::TEXT AS semestername,
            i."ACMS_SectionName"::TEXT AS sectionname
        FROM "CLG"."Adm_College_Student_Documents" a
        INNER JOIN "Adm_m_School_Master_Documents" b ON a."ACSMD_Id" = b."AMSMD_Id"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" c ON c."AMCST_Id" = a."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" d ON d."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" e ON e."AMCO_Id" = c."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" f ON f."AMB_Id" = c."AMB_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" h ON h."AMSE_Id" = c."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" i ON i."ACMS_Id" = c."ACMS_Id" AND c."ACYST_ActiveFlag" = 1
        WHERE d."MI_Id" = p_MI_Id 
            AND c."AMCO_Id" = p_AMCO_Id 
            AND c."ACMS_Id" = p_ACMS_Id 
            AND c."AMB_Id" = p_AMB_Id 
            AND c."AMSE_Id" = p_AMSE_Id
            AND c."ASMAY_Id" = p_ASMAY_Id 
            AND a."ACSMD_Id" = p_AMSMD_Id

        UNION ALL

        SELECT 
            ''::TEXT AS docname,
            'No'::TEXT AS statuss,
            'Not Submited'::TEXT AS submited,
            ''::TEXT AS docpath,
            (CASE WHEN d."AMCST_FirstName" IS NULL OR d."AMCST_FirstName" = '' THEN '' ELSE d."AMCST_FirstName" END ||
             CASE WHEN d."AMCST_MiddleName" IS NULL OR d."AMCST_MiddleName" = '' OR d."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || d."AMCST_MiddleName" END ||
             CASE WHEN d."AMCST_LastName" IS NULL OR d."AMCST_LastName" = '' OR d."AMCST_LastName" = '0' THEN '' ELSE ' ' || d."AMCST_LastName" END)::TEXT AS studentnam,
            d."AMCST_AdmNo"::TEXT AS admno,
            e."AMCO_CourseName"::TEXT AS coursename,
            f."AMB_BranchName"::TEXT AS branchname,
            h."AMSE_SEMName"::TEXT AS semestername,
            i."ACMS_SectionName"::TEXT AS sectionname
        FROM "CLG"."Adm_College_Yearly_Student" c
        INNER JOIN "CLG"."Adm_Master_College_Student" d ON d."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" e ON e."AMCO_Id" = c."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" f ON f."AMB_Id" = c."AMB_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" h ON h."AMSE_Id" = c."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" i ON i."ACMS_Id" = c."ACMS_Id" AND c."ACYST_ActiveFlag" = 1
        WHERE c."AMCST_Id" NOT IN (
            SELECT c2."AMCST_Id" 
            FROM "CLG"."Adm_College_Student_Documents" c2
            INNER JOIN "Adm_m_School_Master_Documents" d2 ON d2."AMSMD_Id" = c2."ACSMD_Id"
            WHERE c2."ACSMD_Id" = p_AMSMD_Id
        )
        AND d."MI_Id" = p_MI_Id 
        AND d."MI_Id" = p_MI_Id 
        AND c."AMCO_Id" = p_AMCO_Id 
        AND c."ACMS_Id" = p_ACMS_Id 
        AND c."AMB_Id" = p_AMB_Id 
        AND c."AMSE_Id" = p_AMSE_Id
        AND c."ASMAY_Id" = p_ASMAY_Id;

    ELSIF p_FLAG = '1' THEN
        RETURN QUERY
        SELECT 
            b."AMSMD_DocumentName" AS docname,
            'Yes'::TEXT AS statuss,
            'Submited'::TEXT AS submited,
            a."ACSTD_Doc_Path" AS docpath,
            (CASE WHEN d."AMCST_FirstName" IS NULL OR d."AMCST_FirstName" = '' THEN '' ELSE d."AMCST_FirstName" END ||
             CASE WHEN d."AMCST_MiddleName" IS NULL OR d."AMCST_MiddleName" = '' OR d."AMCST_MiddleName" = '0' THEN '' ELSE ' ' || d."AMCST_MiddleName" END ||
             CASE WHEN d."AMCST_LastName" IS NULL OR d."AMCST_LastName" = '' OR d."AMCST_LastName" = '0' THEN '' ELSE ' ' || d."AMCST_LastName" END)::TEXT AS studentnam,
            d."AMCST_AdmNo"::TEXT AS admno,
            e."AMCO_CourseName"::TEXT AS coursename,
            f."AMB_BranchName"::TEXT AS branchname,
            h."AMSE_SEMName"::TEXT AS semestername,
            i."ACMS_SectionName"::TEXT AS sectionname
        FROM "CLG"."Adm_College_Student_Documents" a
        INNER JOIN "Adm_m_School_Master_Documents" b ON a."ACSMD_Id" = b."AMSMD_Id"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" c ON c."AMCST_Id" = a."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" d ON d."AMCST_Id" = c."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" e ON e."AMCO_Id" = c."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" f ON f."AMB_Id" = c."AMB_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" h ON h."AMSE_Id" = c."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" i ON i."ACMS_Id" = c."ACMS_Id" AND c."ACYST_ActiveFlag" = 1
        WHERE d."MI_Id" = p_MI_Id 
            AND c."AMCO_Id" = p_AMCO_Id 
            AND c."ACMS_Id" = p_ACMS_Id 
            AND c."AMB_Id" = p_AMB_Id 
            AND c."AMSE_Id" = p_AMSE_Id
            AND c."ASMAY_Id" = p_ASMAY_Id 
            AND a."AMCST_Id" = p_AMCST_Id

        UNION ALL

        SELECT 
            "AMSMD_DocumentName"::TEXT AS docname,
            'No'::TEXT AS statuss,
            ' Not Submited'::TEXT AS submited,
            ''::TEXT AS docpath,
            ''::TEXT AS studentnam,
            ''::TEXT AS admno,
            ''::TEXT AS coursename,
            ''::TEXT AS branchname,
            ''::TEXT AS semestername,
            ''::TEXT AS sectionname
        FROM "Adm_m_School_Master_Documents" 
        WHERE "AMSMD_Id" NOT IN (
            SELECT a."ACSMD_Id" 
            FROM "CLG"."Adm_College_Student_Documents" a
            INNER JOIN "CLG"."Adm_College_Yearly_Student" c ON c."AMCST_Id" = a."AMCST_Id"
            INNER JOIN "CLG"."Adm_Master_College_Student" b ON b."AMCST_Id" = c."AMCST_Id"
            INNER JOIN "CLG"."Adm_Master_Course" d ON c."AMCO_Id" = d."AMCO_Id"
            INNER JOIN "CLG"."Adm_Master_Branch" e ON e."AMB_Id" = c."AMB_Id"
            INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = c."ASMAY_Id"
            INNER JOIN "CLG"."Adm_Master_Semester" h ON h."AMSE_Id" = c."AMSE_Id"
            INNER JOIN "CLG"."Adm_College_Master_Section" i ON i."ACMS_Id" = c."ACMS_Id" AND c."ACYST_ActiveFlag" = 1
            WHERE a."AMCST_Id" = p_AMCST_Id 
                AND b."MI_Id" = p_MI_Id 
                AND c."ASMAY_Id" = p_ASMAY_Id 
                AND c."AMCO_Id" = p_AMCO_Id
                AND c."ACMS_Id" = p_ACMS_Id 
                AND c."AMB_Id" = p_AMB_Id 
                AND c."AMSE_Id" = p_AMSE_Id
        )
        AND "MI_Id" = p_MI_Id;

    END IF;

    RETURN;

END;
$$;