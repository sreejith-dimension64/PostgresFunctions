CREATE OR REPLACE FUNCTION "dbo"."College_Exam_Get_Student_Other_Details_JNU"(
    @MI_Id TEXT,
    @ASMAY_Id TEXT,
    @AMCO_Id TEXT,
    @AMB_Id TEXT,
    @AMSE_Id TEXT,
    @ACMS_Id TEXT,
    @EME_Id TEXT,
    @ACST_Id TEXT,
    @ACSS_Id TEXT,
    @AMCST_Id TEXT,
    @FLAG TEXT
)
RETURNS TABLE(
    "AMCST_Id" BIGINT,
    "StudentName" TEXT,
    "AMCST_AdmNo" TEXT,
    "AMCST_RegistrationNo" TEXT,
    "AMCO_CourseName" TEXT,
    "AMB_BranchName" TEXT,
    "AMSE_SEMName" TEXT,
    "AMCST_FatherName" TEXT,
    "AMCST_MotherName" TEXT,
    "ACYST_RollNo" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SQL TEXT;
BEGIN

    IF @FLAG = '1' THEN
    
        v_SQL := 'SELECT B."AMCST_Id",
(CASE WHEN B."AMCST_FirstName" IS NULL OR B."AMCST_FirstName"='''' THEN '''' ELSE B."AMCST_FirstName" END)||
(CASE WHEN B."AMCST_MiddleName" IS NULL OR B."AMCST_MiddleName"='''' THEN '''' ELSE '' ''|| B."AMCST_MiddleName" END)||
(CASE WHEN B."AMCST_LastName" IS NULL OR B."AMCST_LastName"='''' THEN '''' ELSE '' ''||  B."AMCST_LastName" END) AS "StudentName",
B."AMCST_AdmNo", B."AMCST_RegistrationNo", C."AMCO_CourseName", D."AMB_BranchName", E."AMSE_SEMName",

(CASE WHEN B."AMCST_FatherName" IS NULL OR B."AMCST_FatherName"='''' THEN '''' ELSE B."AMCST_FatherName" END)||
(CASE WHEN B."AMCST_FatherSurname" IS NULL OR B."AMCST_FatherSurname"='''' THEN '''' ELSE '' ''|| B."AMCST_FatherSurname" END) AS "AMCST_FatherName",

(CASE WHEN B."AMCST_MotherName" IS NULL OR B."AMCST_MotherName"='''' THEN '''' ELSE B."AMCST_MotherName" END)||
(CASE WHEN B."AMCST_MotherSurname" IS NULL OR B."AMCST_MotherSurname"='''' THEN '''' ELSE '' ''|| B."AMCST_MotherSurname" END) AS "AMCST_MotherName",

A."ACYST_RollNo"

FROM "CLG"."Adm_College_Yearly_Student" A 
INNER JOIN "CLG"."Adm_Master_College_Student" B ON A."AMCST_Id"=B."AMCST_Id"
INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id"=A."AMCO_Id"
INNER JOIN "CLG"."Adm_Master_Branch" D ON D."AMB_Id"=A."AMB_Id"
INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id"=A."AMSE_Id"
INNER JOIN "Adm_School_M_Academic_Year" F ON F."ASMAY_Id"=A."ASMAY_Id"
INNER JOIN "CLG"."Adm_College_SchemeType" G ON G."ACST_Id"=B."ACST_Id"
INNER JOIN "CLG"."Adm_College_SubjectScheme" H ON H."ACSS_Id"=B."ACSS_Id"
INNER JOIN "CLG"."Adm_College_Master_Section" I ON I."ACMS_Id"=A."ACMS_Id"
WHERE B."MI_Id"=' || @MI_Id || ' AND A."ASMAY_Id"=' || @ASMAY_Id || ' AND A."AMCO_Id"=' || @AMCO_Id || ' AND A."AMB_Id"=' || @AMB_Id || ' AND A."AMSE_Id"=' || @AMSE_Id || '
AND A."ACMS_Id"=' || @ACMS_Id || ' AND B."ACSS_Id"=' || @ACSS_Id || ' AND B."ACST_Id"=' || @ACST_Id || ' AND A."AMCST_Id" IN (' || @AMCST_Id || ')
ORDER BY "StudentName"';

        RETURN QUERY EXECUTE v_SQL;
        
    END IF;

    RETURN;

END;
$$;