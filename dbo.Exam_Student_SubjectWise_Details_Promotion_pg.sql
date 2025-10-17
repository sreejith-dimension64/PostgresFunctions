CREATE OR REPLACE FUNCTION "dbo"."Exam_Student_SubjectWise_Details_Promotion"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@FLAG" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" VARCHAR,
    "EYCES_SubjectOrder" INTEGER,
    "EYCES_AplResultFlg" BOOLEAN,
    "EYCES_MarksDisplayFlg" BOOLEAN,
    "EYCES_GradeDisplayFlg" BOOLEAN,
    "WORKINGDAYS" BIGINT,
    "PRESENTDAYS" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "@FLAG" = '1' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."AMST_Id",
            B."ISMS_Id",
            B."ISMS_SubjectName",
            M."EYCES_SubjectOrder",
            M."EYCES_AplResultFlg",
            M."EYCES_MarksDisplayFlg",
            M."EYCES_GradeDisplayFlg",
            NULL::BIGINT AS "WORKINGDAYS",
            NULL::BIGINT AS "PRESENTDAYS"
        FROM "EXM"."Exm_Studentwise_Subjects" A 
        INNER JOIN "IVRM_Master_Subjects" B ON A."ISMS_Id" = B."ISMS_Id"
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = C."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = C."ASMAY_Id" AND E."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = C."ASMCL_Id" AND F."ASMCL_Id" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = C."ASMS_Id" AND G."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "EXM"."Exm_Category_Class" H ON H."ASMAY_Id" = E."ASMAY_Id" AND H."ASMCL_Id" = F."ASMCL_Id" AND H."ASMS_Id" = G."ASMS_Id" AND H."ECAC_ActiveFlag" = 1
            AND H."ASMCL_Id"::TEXT = "@ASMCL_Id" AND H."ASMAY_Id"::TEXT = "@ASMAY_Id" AND H."ASMS_Id"::TEXT = "@ASMS_Id"
        INNER JOIN "EXM"."Exm_Master_Category" I ON I."EMCA_Id" = H."EMCA_Id"
        INNER JOIN "EXM"."Exm_Yearly_Category" J ON J."ASMAY_Id" = E."ASMAY_Id" AND J."EMCA_Id" = I."EMCA_Id" AND J."ASMAY_Id"::TEXT = "@ASMAY_Id" AND J."EYC_ActiveFlg" = 1
        INNER JOIN "EXM"."Exm_Yearly_Category_Exams" K ON K."EYC_Id" = J."EYC_Id" AND K."EYCE_ActiveFlg" = 1
        INNER JOIN "EXM"."Exm_Master_Exam" L ON L."EME_Id" = K."EME_Id"
        INNER JOIN "EXM"."Exm_Yrly_Cat_Exams_Subwise" M ON M."EYCE_Id" = K."EYCE_Id" AND M."ISMS_Id" = B."ISMS_Id" AND M."EYCES_ActiveFlg" = 1
        WHERE C."ASMAY_Id"::TEXT = "@ASMAY_Id" AND A."ASMAY_Id"::TEXT = "@ASMAY_Id"
            AND A."ASMCL_Id"::TEXT = "@ASMCL_Id" AND C."ASMCL_Id"::TEXT = "@ASMCL_Id" AND A."ASMS_Id"::TEXT = "@ASMS_Id" AND C."ASMS_Id"::TEXT = "@ASMS_Id"
            AND A."ESTSU_ActiveFlg" = 1 AND B."ISMS_ActiveFlag" = 1
        ORDER BY M."EYCES_SubjectOrder";

    ELSIF "@FLAG" = '2' THEN
        RETURN QUERY
        SELECT 
            B."AMST_Id",
            NULL::BIGINT AS "ISMS_Id",
            NULL::VARCHAR AS "ISMS_SubjectName",
            NULL::INTEGER AS "EYCES_SubjectOrder",
            NULL::BOOLEAN AS "EYCES_AplResultFlg",
            NULL::BOOLEAN AS "EYCES_MarksDisplayFlg",
            NULL::BOOLEAN AS "EYCES_GradeDisplayFlg",
            SUM(A."ASA_ClassHeld") AS "WORKINGDAYS",
            SUM(B."ASA_Class_Attended") AS "PRESENTDAYS"
        FROM "Adm_Student_Attendance" A 
        INNER JOIN "Adm_Student_Attendance_Students" B ON A."ASA_Id" = B."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_ID" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Class" E ON E."ASMCL_ID" = A."ASMCL_Id" AND E."ASMCL_Id" = C."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" F ON F."ASMS_Id" = A."ASMS_Id" AND F."ASMS_Id" = C."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" G ON G."ASMAY_Id" = A."ASMAY_Id" AND G."ASMAY_Id" = C."ASMAY_Id"
        WHERE A."MI_Id"::TEXT = "@MI_Id" AND A."ASMAY_Id"::TEXT = "@ASMAY_Id" AND A."ASMCL_Id"::TEXT = "@ASMCL_Id" AND A."ASMS_Id"::TEXT = "@ASMS_Id"
            AND C."ASMAY_Id"::TEXT = "@ASMAY_Id" AND C."ASMCL_Id"::TEXT = "@ASMCL_Id" AND C."ASMS_Id"::TEXT = "@ASMS_Id" AND C."AMAY_ActiveFlag" = 1
            AND A."ASA_Activeflag" = 1 AND D."AMST_SOL" = 'S' AND D."AMST_ActiveFlag" = 1
        GROUP BY B."AMST_Id";

    ELSIF "@FLAG" = '3' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."AMST_Id",
            B."ISMS_Id",
            B."ISMS_SubjectName",
            L."EMPS_SubjOrder" AS "EYCES_SubjectOrder",
            L."EMPS_AppToResultFlg" AS "EYCES_AplResultFlg",
            FALSE AS "EYCES_MarksDisplayFlg",
            FALSE AS "EYCES_GradeDisplayFlg",
            NULL::BIGINT AS "WORKINGDAYS",
            NULL::BIGINT AS "PRESENTDAYS"
        FROM "EXM"."Exm_Studentwise_Subjects" A 
        INNER JOIN "IVRM_Master_Subjects" B ON A."ISMS_Id" = B."ISMS_Id"
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = A."AMST_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = C."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = C."ASMAY_Id" AND E."ASMAY_Id" = A."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = C."ASMCL_Id" AND F."ASMCL_Id" = A."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = C."ASMS_Id" AND G."ASMS_Id" = A."ASMS_Id"
        INNER JOIN "EXM"."Exm_Category_Class" H ON H."ASMAY_Id" = E."ASMAY_Id" AND H."ASMCL_Id" = F."ASMCL_Id" AND H."ASMS_Id" = G."ASMS_Id" AND H."ECAC_ActiveFlag" = 1
            AND H."ASMCL_Id"::TEXT = "@ASMCL_Id" AND H."ASMAY_Id"::TEXT = "@ASMAY_Id" AND H."ASMS_Id"::TEXT = "@ASMS_Id"
        INNER JOIN "EXM"."Exm_Master_Category" I ON I."EMCA_Id" = H."EMCA_Id"
        INNER JOIN "EXM"."Exm_Yearly_Category" J ON J."ASMAY_Id" = E."ASMAY_Id" AND J."EMCA_Id" = I."EMCA_Id" AND J."ASMAY_Id"::TEXT = "@ASMAY_Id" AND J."EYC_ActiveFlg" = 1
        INNER JOIN "EXM"."Exm_M_Promotion" K ON K."EYC_Id" = J."EYC_Id" AND K."EMP_ActiveFlag" = 1 AND K."MI_Id"::TEXT = "@MI_Id"
        INNER JOIN "EXM"."Exm_M_Promotion_Subjects" L ON L."EMP_Id" = K."EMP_Id" AND L."ISMS_Id" = B."ISMS_Id"
        WHERE C."ASMAY_Id"::TEXT = "@ASMAY_Id" AND A."ASMAY_Id"::TEXT = "@ASMAY_Id"
            AND A."ASMCL_Id"::TEXT = "@ASMCL_Id" AND C."ASMCL_Id"::TEXT = "@ASMCL_Id" AND A."ASMS_Id"::TEXT = "@ASMS_Id" AND C."ASMS_Id"::TEXT = "@ASMS_Id"
            AND A."ESTSU_ActiveFlg" = 1 AND B."ISMS_ActiveFlag" = 1
        ORDER BY L."EMPS_SubjOrder";

    END IF;

    RETURN;
END;
$$;