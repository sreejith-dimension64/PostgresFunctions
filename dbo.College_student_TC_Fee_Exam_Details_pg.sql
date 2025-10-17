CREATE OR REPLACE FUNCTION "dbo"."College_student_TC_Fee_Exam_Details"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_FLAG TEXT,
    p_AMCST_Id TEXT,
    p_FLAGNEW TEXT
)
RETURNS TABLE(
    balance NUMERIC,
    subjectname VARCHAR,
    flag VARCHAR
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_ACTIVEFLAG INTEGER;
    v_YEARLYACTIVEFLAG INTEGER;
BEGIN

    IF p_FLAGNEW = 'F' THEN
    
        RETURN QUERY
        SELECT SUM("FCSS_ToBePaid") AS balance, NULL::VARCHAR, NULL::VARCHAR 
        FROM "CLG"."Fee_College_Student_Status" 
        WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "AMCST_Id" = p_AMCST_Id;
    
    ELSIF p_FLAGNEW = 'E' THEN
    
        IF p_FLAG = 'S' OR p_FLAG = 'D' THEN
        
            v_ACTIVEFLAG := 1;
            v_YEARLYACTIVEFLAG := 1;
        
        ELSIF p_FLAG = 'L' THEN
        
            v_ACTIVEFLAG := 0;
            v_YEARLYACTIVEFLAG := 0;
        
        ELSIF p_FLAG = 'T' THEN
        
            v_ACTIVEFLAG := 1;
            v_YEARLYACTIVEFLAG := 1;
        
        END IF;
        
        RETURN QUERY
        SELECT NULL::NUMERIC, "B"."ISMS_SubjectName" AS subjectname, "B"."ISMS_LanguageFlg" AS flag  
        FROM "CLG"."Exm_Col_Studentwise_Subjects" "A" 
        INNER JOIN "IVRM_Master_Subjects" "B" ON "A"."ISMS_Id" = "B"."ISMS_Id" 
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "C" ON "C"."AMCST_Id" = "A"."AMCST_Id" 
        INNER JOIN "CLG"."Adm_Master_College_Student" "D" ON "D"."AMCST_Id" = "C"."AMCST_Id"
        INNER JOIN "CLG"."Adm_Master_Course" "F" ON "F"."AMCO_Id" = "D"."AMCO_Id" AND "F"."AMCO_Id" = "A"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "G" ON "G"."AMB_Id" = "C"."AMB_Id" AND "G"."AMB_Id" = "A"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "H" ON "H"."AMSE_Id" = "C"."AMSE_Id" AND "H"."AMSE_Id" = "A"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "I" ON "I"."ACMS_Id" = "C"."ACMS_Id" AND "I"."ACMS_Id" = "A"."ACMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "J" ON "J"."ASMAY_Id" = "A"."ASMAY_Id" AND "J"."ASMAY_Id" = "C"."ASMAY_Id"
        WHERE "A"."MI_Id" = p_MI_Id 
        AND "A"."ASMAY_Id" = p_ASMAY_Id 
        AND "A"."ECSTSU_ActiveFlg" = 1 
        AND "C"."ASMAY_Id" = p_ASMAY_Id
        AND "A"."AMCST_Id" = p_AMCST_Id 
        AND "C"."AMCST_Id" = p_AMCST_Id 
        AND "C"."ACYST_ActiveFlag" = v_ACTIVEFLAG 
        AND "D"."AMCST_ActiveFlag" = v_YEARLYACTIVEFLAG 
        AND "D"."AMCST_SOL" = p_FLAG;
    
    END IF;

    RETURN;

END;
$$;