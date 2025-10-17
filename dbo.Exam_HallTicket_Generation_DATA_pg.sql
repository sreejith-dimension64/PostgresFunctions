CREATE OR REPLACE FUNCTION "dbo"."Exam_HallTicket_Generation_DATA"(
    p_MI_Id bigint,
    p_Flag VARCHAR(50),
    p_ASMAY_Id BIGINT,
    p_AMCO_Id BIGINT,
    p_AMB_Id BIGINT,
    p_AMSE_Id BIGINT,
    p_ACMS_Id BIGINT,
    p_EME_Id BIGINT,
    p_AMCST_Id TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    v_SQLQUERY TEXT;
BEGIN
    -- Drop temporary table if exists
    DROP TABLE IF EXISTS "EXAM_Temp_StudentDetails_Amstids";
    
    -- Create dynamic SQL and execute
    v_SQLQUERY := 'CREATE TEMP TABLE "EXAM_Temp_StudentDetails_Amstids" AS ' ||
                  'SELECT DISTINCT "AMCST_Id" FROM "CLG"."Adm_Master_College_Student" ' ||
                  'WHERE "AMCST_Id" IN (' || p_AMCST_Id || ')';
    EXECUTE v_SQLQUERY;
    
    IF p_Flag = '1' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "ACY"."ASMAY_Year",
            "CO"."AMCO_CourseName",
            "AMB"."AMB_BranchName",
            "AMS"."AMSE_SEMName",
            "ACMS"."ACMS_SectionName",
            "EME"."EME_ExamName",
            "CLG"."ASMAY_Id",
            "CLG"."AMCO_Id",
            "CLG"."AMB_Id",
            "CLG"."AMSE_Id",
            "CLG"."ACMS_Id",
            "CLG"."EME_Id"
        FROM "CLG"."Exm_HallTicket_College" "CLG"
        INNER JOIN "Adm_School_M_Academic_Year" "ACY" ON "CLG"."ASMAY_Id" = "ACY"."ASMAY_Id"
        INNER JOIN "CLG"."Adm_Master_Course" "CO" ON "CO"."AMCO_Id" = "CLG"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "AMB" ON "AMB"."AMB_Id" = "CLG"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "AMS" ON "AMS"."AMSE_Id" = "CLG"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "ACMS" ON "ACMS"."ACMS_Id" = "CLG"."ACMS_Id"
        INNER JOIN "EXM"."Exm_Master_Exam" "EME" ON "EME"."EME_Id" = "CLG"."EME_Id"
        WHERE "CLG"."MI_Id" = p_MI_Id
        GROUP BY 
            "ACY"."ASMAY_Year",
            "CO"."AMCO_CourseName",
            "AMB"."AMB_BranchName",
            "AMS"."AMSE_SEMName",
            "ACMS"."ACMS_SectionName",
            "EME"."EME_ExamName",
            "CLG"."ASMAY_Id",
            "CLG"."AMCO_Id",
            "CLG"."AMB_Id",
            "CLG"."AMSE_Id",
            "CLG"."ACMS_Id",
            "CLG"."EME_Id";
            
    ELSIF p_Flag = '2' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "CLG"."AMCST_Id",
            "CLG"."EHTC_Id",
            "ACY"."ASMAY_Year",
            "CO"."AMCO_CourseName",
            "AMB"."AMB_BranchName",
            "AMS"."AMSE_SEMName",
            "ACMS"."ACMS_SectionName",
            "EME"."EME_ExamName",
            "CLG"."ASMAY_Id",
            "CLG"."AMCO_Id",
            "CLG"."AMB_Id",
            "CLG"."AMSE_Id",
            "CLG"."ACMS_Id",
            "CLG"."EME_Id",
            CONCAT("AMCS"."AMCST_FirstName", ' ', "AMCS"."AMCST_MiddleName", ' ', "AMCS"."AMCST_LastName", '') AS "AMCST_FirstName",
            "CLG"."EHTC_HallTicketNo",
            "CLG"."EHTC_PublishFlg",
            "AMCS"."AMCST_AdmNo",
            "ACYS"."ACYST_RollNo"
        FROM "CLG"."Exm_HallTicket_College" "CLG"
        INNER JOIN "Adm_School_M_Academic_Year" "ACY" ON "CLG"."ASMAY_Id" = "ACY"."ASMAY_Id"
        INNER JOIN "CLG"."Adm_Master_Course" "CO" ON "CO"."AMCO_Id" = "CLG"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "AMB" ON "AMB"."AMB_Id" = "CLG"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "AMS" ON "AMS"."AMSE_Id" = "CLG"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "ACMS" ON "ACMS"."ACMS_Id" = "CLG"."ACMS_Id"
        INNER JOIN "EXM"."Exm_Master_Exam" "EME" ON "EME"."EME_Id" = "CLG"."EME_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" "AMCS" ON "AMCS"."AMCST_Id" = "CLG"."AMCST_Id" AND "AMCS"."AMCST_SOL" = 'S'
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "ACYS" ON "ACYS"."AMCST_Id" = "AMCS"."AMCST_Id" 
            AND "AMCS"."AMCST_ActiveFlag" = 1
            AND "AMCS"."AMCST_SOL" = 'S' 
            AND "ACYS"."ACYST_ActiveFlag" = 1
            AND "AMCS"."AMCST_ActiveFlag" = 1 
            AND "CLG"."ASMAY_Id" = "ACYS"."ASMAY_Id" 
            AND "CLG"."ASMAY_Id" = "ACYS"."ASMAY_Id" 
            AND "CLG"."AMCO_Id" = "ACYS"."AMCO_Id"
            AND "CLG"."AMB_Id" = "ACYS"."AMB_Id" 
            AND "CLG"."AMSE_Id" = "ACYS"."AMSE_Id" 
            AND "CLG"."ACMS_Id" = "ACYS"."ACMS_Id"
            AND "ACYS"."ASMAY_Id" = p_ASMAY_Id 
            AND "ACYS"."AMCO_Id" = p_AMCO_Id 
            AND "ACYS"."AMB_Id" = p_AMB_Id
            AND "ACYS"."AMSE_Id" = p_AMSE_Id 
            AND "ACYS"."ACMS_Id" = p_ACMS_Id
        WHERE "CLG"."MI_Id" = p_MI_Id 
            AND "CLG"."ASMAY_Id" = p_ASMAY_Id 
            AND "CLG"."AMCO_Id" = p_AMCO_Id 
            AND "CLG"."AMB_Id" = p_AMB_Id
            AND "CLG"."AMSE_Id" = p_AMSE_Id 
            AND "CLG"."ACMS_Id" = p_ACMS_Id 
            AND "CLG"."EME_Id" = p_EME_Id;
            
    ELSIF p_Flag = '3' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "CLG"."AMCST_Id",
            "CLG"."EHTC_Id",
            "ACY"."ASMAY_Year",
            "CO"."AMCO_CourseName",
            "AMB"."AMB_BranchName",
            "AMS"."AMSE_SEMName",
            "ACMS"."ACMS_SectionName",
            "EME"."EME_ExamName",
            "CLG"."ASMAY_Id",
            "CLG"."AMCO_Id",
            "CLG"."AMB_Id",
            "CLG"."AMSE_Id",
            "CLG"."ACMS_Id",
            "CLG"."EME_Id",
            CONCAT("AMCS"."AMCST_FirstName", ' ', "AMCS"."AMCST_MiddleName", ' ', "AMCS"."AMCST_LastName", '') AS "AMCST_FirstName",
            "CLG"."EHTC_HallTicketNo",
            "CLG"."EHTC_PublishFlg",
            "AMCS"."AMCST_AdmNo",
            "ACYS"."ACYST_RollNo"
        FROM "CLG"."Exm_HallTicket_College" "CLG"
        INNER JOIN "Adm_School_M_Academic_Year" "ACY" ON "CLG"."ASMAY_Id" = "ACY"."ASMAY_Id"
        INNER JOIN "CLG"."Adm_Master_Course" "CO" ON "CO"."AMCO_Id" = "CLG"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "AMB" ON "AMB"."AMB_Id" = "CLG"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "AMS" ON "AMS"."AMSE_Id" = "CLG"."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "ACMS" ON "ACMS"."ACMS_Id" = "CLG"."ACMS_Id"
        INNER JOIN "EXM"."Exm_Master_Exam" "EME" ON "EME"."EME_Id" = "CLG"."EME_Id"
        INNER JOIN "CLG"."Adm_Master_College_Student" "AMCS" ON "AMCS"."AMCST_Id" = "CLG"."AMCST_Id" AND "AMCS"."AMCST_SOL" = 'S'
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "ACYS" ON "ACYS"."AMCST_Id" = "AMCS"."AMCST_Id" 
            AND "AMCS"."AMCST_ActiveFlag" = 1
            AND "AMCS"."AMCST_SOL" = 'S' 
            AND "ACYS"."ACYST_ActiveFlag" = 1
            AND "AMCS"."AMCST_ActiveFlag" = 1 
            AND "CLG"."ASMAY_Id" = "ACYS"."ASMAY_Id" 
            AND "CLG"."ASMAY_Id" = "ACYS"."ASMAY_Id" 
            AND "CLG"."AMCO_Id" = "ACYS"."AMCO_Id"
            AND "CLG"."AMB_Id" = "ACYS"."AMB_Id" 
            AND "CLG"."AMSE_Id" = "ACYS"."AMSE_Id" 
            AND "CLG"."ACMS_Id" = "ACYS"."ACMS_Id"
            AND "ACYS"."ASMAY_Id" = p_ASMAY_Id 
            AND "ACYS"."AMCO_Id" = p_AMCO_Id 
            AND "ACYS"."AMB_Id" = p_AMB_Id
            AND "ACYS"."AMSE_Id" = p_AMSE_Id 
            AND "ACYS"."ACMS_Id" = p_ACMS_Id
        WHERE "CLG"."MI_Id" = p_MI_Id 
            AND "CLG"."ASMAY_Id" = p_ASMAY_Id 
            AND "CLG"."AMCO_Id" = p_AMCO_Id 
            AND "CLG"."AMB_Id" = p_AMB_Id
            AND "CLG"."AMSE_Id" = p_AMSE_Id 
            AND "CLG"."ACMS_Id" = p_ACMS_Id 
            AND "CLG"."EME_Id" = p_EME_Id
            AND "CLG"."AMCST_Id" IN (SELECT "AMCST_Id" FROM "EXAM_Temp_StudentDetails_Amstids");
            
    ELSIF p_Flag = '4' THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."EME_Id" AS "emE_Id",
            "C"."EME_ExamName" AS "emE_ExamName"
        FROM "CLG"."Exm_HallTicket_College" a
        INNER JOIN "CLG"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id" AND b."ACYST_ActiveFlag" = 1
        INNER JOIN "EXM"."Exm_Master_Exam" "C" ON "C"."EME_Id" = a."EME_Id"
        WHERE a."ASMAY_Id" = p_ASMAY_Id 
            AND a."AMCST_Id" = p_AMCST_Id::bigint 
            AND "C"."EME_ActiveFlag" = 1 
            AND a."MI_Id" = p_MI_Id;
    END IF;
    
    RETURN;
END;
$$;