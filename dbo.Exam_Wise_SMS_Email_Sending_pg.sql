CREATE OR REPLACE FUNCTION "dbo"."Exam_Wise_SMS_Email_Sending"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "EME_Id" TEXT,
    "typeformat" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "STUDENTNAME" TEXT,
    "AMST_AdmNo" TEXT,
    "AMAY_RollNo" INTEGER,
    "AMST_RegistrationNo" TEXT,
    "EME_ExamName" TEXT,
    "ESTMP_TotalMaxMarks" NUMERIC,
    "ESTMP_TotalObtMarks" NUMERIC,
    "MOBILENO" BIGINT,
    "EMAILID" TEXT,
    "MARKSDETAILS" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "ORDER" TEXT;
    "ORDERTYPE" TEXT;
    "SMSDEFALUT" TEXT;
    "SQLQUERY" TEXT;
BEGIN

    SELECT "ExmConfig_Recordsearchtype" INTO "ORDER" 
    FROM "Exm"."Exm_Configuration" 
    WHERE "MI_Id" = "MI_Id";

    SELECT "ASC_DefaultSMS_Flag" INTO "SMSDEFALUT" 
    FROM "Adm_School_Configuration" 
    WHERE "MI_Id" = "MI_Id";

    IF "ORDER" = 'Name' THEN
        "ORDERTYPE" := 'STUDENTNAME';
    ELSIF "ORDER" = 'AdmNo' THEN
        "ORDERTYPE" := 'AMST_AdmNo';
    ELSIF "ORDER" = 'RollNo' THEN
        "ORDERTYPE" := 'AMAY_RollNo';
    ELSIF "ORDER" = 'RegNo' THEN
        "ORDERTYPE" := 'AMST_RegistrationNo';
    ELSE
        "ORDERTYPE" := 'AMAY_RollNo';
    END IF;

    IF "typeformat" = 'Marks' THEN

        "SQLQUERY" := 'SELECT A."AMST_Id", (COALESCE(C."AMST_FirstName",'''') || '' '' || COALESCE(C."AMST_MiddleName",'''') || '' '' || COALESCE(C."AMST_LastName",'''')) AS STUDENTNAME, 
        C."AMST_AdmNo", B."AMAY_RollNo", C."AMST_RegistrationNo", D."EME_ExamName", A."ESTMP_TotalMaxMarks", A."ESTMP_TotalObtMarks",
        CASE WHEN ''' || "SMSDEFALUT" || ''' = ''S'' THEN C."AMST_MobileNo" WHEN ''' || "SMSDEFALUT" || ''' = ''F'' THEN C."AMST_FatherMobleNo"
        WHEN ''' || "SMSDEFALUT" || ''' = ''M'' THEN C."AMST_MotherMobileNo" ELSE 9999999999 END AS MOBILENO,
        CASE WHEN ''' || "SMSDEFALUT" || ''' = ''S'' THEN C."AMST_emailId" WHEN ''' || "SMSDEFALUT" || ''' = ''F'' THEN C."AMST_FatheremailId"
        WHEN ''' || "SMSDEFALUT" || ''' = ''M'' THEN C."AMST_MotherEmailId" ELSE ''TEST@GMAIL.COM'' END AS EMAILID,
        NULL::TEXT AS MARKSDETAILS
        FROM "Exm"."Exm_Student_Marks_Process" A 
        INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_M_Student" C ON C."AMST_Id" = B."AMST_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" D ON D."EME_Id" = A."EME_Id"
        WHERE A."ASMAY_Id" = ' || "ASMAY_Id" || ' AND A."ASMCL_Id" = ' || "ASMCL_Id" || ' AND A."ASMS_Id" IN (' || "ASMS_Id" || ') AND A."EME_Id" = ' || "EME_Id" || '
        AND B."ASMAY_Id" = ' || "ASMAY_Id" || ' AND B."ASMCL_Id" = ' || "ASMCL_Id" || ' AND B."ASMS_Id" IN (' || "ASMS_Id" || ') 
        AND C."AMST_SOL" = ''S'' AND C."AMST_ActiveFlag" = 1 AND B."AMAY_ActiveFlag" = 1
        ORDER BY ' || "ORDERTYPE";

        RETURN QUERY EXECUTE "SQLQUERY";

    ELSIF "typeformat" = 'Progress' THEN

        DROP TABLE IF EXISTS "SCHOOLSTUDENT";

        "SQLQUERY" := 'CREATE TEMP TABLE "SCHOOLSTUDENT" AS 
        SELECT DISTINCT A."AMST_ID", 
        (COALESCE(B."AMST_FIRSTNAME",'' '') || '' '' || COALESCE(B."AMST_MIDDLENAME",'''') || '' '' || COALESCE(B."AMST_LASTNAME",'''')) AS STUDENTNAME,
        B."AMST_AdmNo",
        CASE WHEN ''' || "SMSDEFALUT" || ''' = ''S'' THEN B."AMST_MobileNo" WHEN ''' || "SMSDEFALUT" || ''' = ''F'' THEN B."AMST_FatherMobleNo"
        WHEN ''' || "SMSDEFALUT" || ''' = ''M'' THEN B."AMST_MotherMobileNo" ELSE 9999999999 END AS MOBILENO,
        CASE WHEN ''' || "SMSDEFALUT" || ''' = ''S'' THEN B."AMST_emailId" WHEN ''' || "SMSDEFALUT" || ''' = ''F'' THEN B."AMST_FatheremailId"
        WHEN ''' || "SMSDEFALUT" || ''' = ''M'' THEN B."AMST_MotherEmailId" ELSE ''TEST@GMAIL.COM'' END AS EMAILID,
        B."AMST_RegistrationNo", A."AMAY_RollNo",
        (CASE WHEN YRLYSUBJECTS."EYCES_APLRESULTFLG" = 1 THEN (H."ISMS_SUBJECTNAME" || '' : '' || CAST(C."ESTMPS_OBTAINEDMARKS" AS VARCHAR(50)) || ''/'' || CAST(C."ESTMPS_MAXMARKS" AS VARCHAR(50)))
        ELSE (H."ISMS_SUBJECTNAME" || '' :'' || C."ESTMPS_OBTAINEDGRADE") END) AS MARKSDETAILS,
        ((H."ISMS_SUBJECTNAME" || '': '' || C."ESTMPS_OBTAINEDGRADE")) AS GRADEDETAILS, I."EME_ExamName",
        C."ESTMPS_PASSFAILFLG", YRLYSUBJECTS."EYCES_SUBJECTORDER" AS ISMS_ORDERFLAG
        FROM "ADM_SCHOOL_Y_STUDENT" A 
        INNER JOIN "ADM_M_STUDENT" B ON A."AMST_ID" = B."AMST_ID"
        INNER JOIN "EXM"."EXM_STUDENT_MARKS_PROCESS_SUBJECTWISE" C ON C."AMST_ID" = A."AMST_ID"
        INNER JOIN "EXM"."EXM_STUDENT_MARKS_PROCESS" D ON D."AMST_ID" = A."AMST_ID"
        INNER JOIN "ADM_SCHOOL_M_CLASS" E ON E."ASMCL_ID" = A."ASMCL_ID" AND E."ASMCL_ID" = C."ASMCL_ID" AND E."ASMCL_ID" = D."ASMCL_ID"
        INNER JOIN "ADM_SCHOOL_M_SECTION" F ON F."ASMS_ID" = A."ASMS_ID" AND F."ASMS_ID" = C."ASMS_ID" AND F."ASMS_ID" = D."ASMS_ID"
        INNER JOIN "ADM_SCHOOL_M_ACADEMIC_YEAR" G ON G."ASMAY_ID" = A."ASMAY_ID" AND G."ASMAY_ID" = C."ASMAY_ID" AND G."ASMAY_ID" = D."ASMAY_ID"
        INNER JOIN "IVRM_MASTER_SUBJECTS" H ON H."ISMS_ID" = C."ISMS_ID"
        INNER JOIN "EXM"."EXM_MASTER_EXAM" I ON I."EME_ID" = C."EME_ID" AND I."EME_ID" = D."EME_ID"
        INNER JOIN "EXM"."EXM_YEARLY_CATEGORY_EXAMS" YRLYEXAM ON YRLYEXAM."EME_ID" = I."EME_ID"
        INNER JOIN "EXM"."EXM_YEARLY_CATEGORY" EYC ON EYC."EYC_ID" = YRLYEXAM."EYC_ID"
        INNER JOIN "EXM"."EXM_YRLY_CAT_EXAMS_SUBWISE" YRLYSUBJECTS ON YRLYSUBJECTS."EYCE_ID" = YRLYEXAM."EYCE_ID" AND YRLYSUBJECTS."ISMS_ID" = H."ISMS_ID"
        INNER JOIN "EXM"."EXM_CATEGORY_CLASS" CAT ON CAT."EMCA_ID" = EYC."EMCA_ID"
        WHERE B."MI_ID" = ' || "MI_ID" || ' AND A."ASMAY_ID" = ' || "ASMAY_ID" || ' AND C."EME_ID" = ' || "EME_ID" || ' AND A."ASMCL_ID" IN (' || "ASMCL_ID" || ')
        AND A."ASMS_ID" IN (' || "ASMS_ID" || ') AND C."ASMAY_ID" = ' || "ASMAY_ID" || ' AND C."ASMCL_ID" IN (' || "ASMCL_ID" || ')
        AND C."ASMS_ID" IN (' || "ASMS_ID" || ') AND D."ASMAY_ID" = ' || "ASMAY_ID" || ' AND D."EME_ID" = ' || "EME_ID" || ' 
        AND D."ASMCL_ID" IN (' || "ASMCL_ID" || ') AND D."ASMS_ID" IN (' || "ASMS_ID" || ')
        AND EYC."ASMAY_ID" = ' || "ASMAY_ID" || ' AND YRLYEXAM."EME_ID" = ' || "EME_ID" || ' AND CAT."ASMAY_ID" = ' || "ASMAY_ID" || ' 
        AND CAT."ASMCL_ID" IN (' || "ASMCL_ID" || ') AND CAT."ASMS_ID" IN (' || "ASMS_ID" || ') 
        AND EYC."EYC_ACTIVEFLG" = 1 AND YRLYEXAM."EYCE_ACTIVEFLG" = 1 AND YRLYSUBJECTS."EYCES_ACTIVEFLG" = 1 AND CAT."ECAC_ACTIVEFLAG" = 1
        ORDER BY ' || "ORDERTYPE" || ', ISMS_ORDERFLAG LIMIT 100';

        EXECUTE "SQLQUERY";

        RETURN QUERY EXECUTE 
        'SELECT B."AMST_Id", B.STUDENTNAME, B."AMST_AdmNo", B."AMAY_RollNo"::INTEGER, B."AMST_RegistrationNo", B."EME_ExamName", 
        NULL::NUMERIC AS "ESTMP_TotalMaxMarks", NULL::NUMERIC AS "ESTMP_TotalObtMarks", B.MOBILENO, B.EMAILID,
        STRING_AGG(A.MARKSDETAILS, '', '' ORDER BY A.ISMS_ORDERFLAG) AS MARKSDETAILS
        FROM "SCHOOLSTUDENT" A
        INNER JOIN "SCHOOLSTUDENT" B ON A.STUDENTNAME = B.STUDENTNAME AND A."AMST_RegistrationNo" = B."AMST_RegistrationNo" 
        AND A."EME_ExamName" = B."EME_ExamName" AND A.EMAILID = B.EMAILID AND A.MOBILENO = B.MOBILENO 
        AND A."AMST_AdmNo" = B."AMST_AdmNo" AND A."AMST_Id" = B."AMST_Id"
        GROUP BY B."AMST_Id", B.STUDENTNAME, B."EME_ExamName", B."AMST_RegistrationNo", B.MOBILENO, B.EMAILID, B."AMST_AdmNo", B."AMAY_RollNo"';

    ELSIF "typeformat" = 'Seat Arragement' THEN

        "SQLQUERY" := 'SELECT A."AMST_Id", (COALESCE(C."AMST_FirstName",'''') || '' '' || COALESCE(C."AMST_MiddleName",'''') || '' '' || COALESCE(C."AMST_LastName",'''')) AS STUDENTNAME,
        C."AMST_AdmNo", B."AMAY_RollNo", C."AMST_RegistrationNo", D."EME_ExamName", A."ESTMP_TotalMaxMarks", A."ESTMP_TotalObtMarks",
        CASE WHEN ''' || "SMSDEFALUT" || ''' = ''S'' THEN C."AMST_MobileNo" WHEN ''' || "SMSDEFALUT" || ''' = ''F'' THEN C."AMST_FatherMobleNo"
        WHEN ''' || "SMSDEFALUT" || ''' = ''M'' THEN C."AMST_MotherMobileNo" ELSE 9999999999 END AS MOBILENO,
        CASE WHEN ''' || "SMSDEFALUT" || ''' = ''S'' THEN C."AMST_emailId" WHEN ''' || "SMSDEFALUT" || ''' = ''F'' THEN C."AMST_FatheremailId"
        WHEN ''' || "SMSDEFALUT" || ''' = ''M'' THEN C."AMST_MotherEmailId" ELSE ''TEST@GMAIL.COM'' END AS EMAILID,
        NULL::TEXT AS MARKSDETAILS
        FROM "Exm"."Exm_Student_Marks_Process" A 
        INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_M_Student" C ON C."AMST_Id" = B."AMST_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" D ON D."EME_Id" = A."EME_Id"
        WHERE A."ASMAY_Id" = ' || "ASMAY_Id" || ' AND A."ASMCL_Id" = ' || "ASMCL_Id" || ' AND A."ASMS_Id" IN (' || "ASMS_Id" || ') AND A."EME_Id" = ' || "EME_Id" || '
        AND B."ASMAY_Id" = ' || "ASMAY_Id" || ' AND B."ASMCL_Id" = ' || "ASMCL_Id" || ' AND B."ASMS_Id" IN (' || "ASMS_Id" || ') 
        AND C."AMST_SOL" = ''S'' AND C."AMST_ActiveFlag" = 1 AND B."AMAY_ActiveFlag" = 1
        ORDER BY ' || "ORDERTYPE";

        RETURN QUERY EXECUTE "SQLQUERY";

    END IF;

    RETURN;

END;
$$;