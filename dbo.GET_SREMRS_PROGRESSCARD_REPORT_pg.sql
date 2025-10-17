CREATE OR REPLACE FUNCTION "dbo"."GET_SREMRS_PROGRESSCARD_REPORT"(
    "p_MI_Id" bigint,
    "p_ASMAY_Id" bigint,
    "p_ASMCL_Id" bigint,
    "p_ASMS_Id" bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "stname" varchar(100),
    "fathername" varchar(100),
    "AMST_AdmNo" varchar(100),
    "AMAY_RollNo" bigint,
    "ISMS_Id" bigint,
    "ISMS_SubjectName" varchar(100),
    "EME_Id" int,
    "EMSE_Id" varchar(50),
    "EME_ExamName" varchar(100),
    "EMSE_SubExamName" varchar(100),
    "ESTMPS_ObtainedMarks" decimal(10,2),
    "ESTMPS_MaxMarks" decimal(10,2),
    "ESTMPS_PassFailFlg" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_amst_id" bigint;
BEGIN
    DROP TABLE IF EXISTS "StudentListE1";
    
    CREATE TEMP TABLE "StudentListE1"(
        "AMST_Id" bigint,
        "stname" varchar(100),
        "fathername" varchar(100),
        "AMST_AdmNo" varchar(100),
        "AMAY_RollNo" bigint,
        "ISMS_Id" bigint,
        "ISMS_SubjectName" varchar(100),
        "EME_Id" int,
        "EMSE_Id" varchar(50),
        "EME_ExamName" varchar(100),
        "EMSE_SubExamName" varchar(100),
        "ESTMPS_ObtainedMarks" decimal(10,2),
        "ESTMPS_MaxMarks" decimal(10,2),
        "ESTMPS_PassFailFlg" varchar(100)
    );

    FOR "v_amst_id" IN 
        SELECT DISTINCT z."AMST_Id" 
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" AS z
        INNER JOIN "Adm_M_Student" AS m ON z."AMST_Id"=m."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" AS y ON m."AMST_Id"=y."AMST_Id"
        WHERE m."AMST_SOL"='S' AND y."AMAY_ActiveFlag"=1 
        AND z."ASMAY_Id"="p_ASMAY_Id" 
        AND z."ASMCL_Id"="p_ASMCL_Id" 
        AND z."ASMS_Id"="p_ASMS_Id" 
        AND z."MI_Id"="p_MI_Id"
    LOOP
        INSERT INTO "StudentListE1"("AMST_Id","stname","fathername","AMST_AdmNo","AMAY_RollNo","ISMS_Id","ISMS_SubjectName","EME_Id","EMSE_Id","EME_ExamName","EMSE_SubExamName","ESTMPS_ObtainedMarks","ESTMPS_MaxMarks","ESTMPS_PassFailFlg")
        WITH a AS (
            SELECT b."AMST_Id",
            (COALESCE(m."AMST_FirstName",'')||' '||COALESCE(m."AMST_MiddleName",'')||' '||COALESCE(m."AMST_LastName",'')) AS stname,
            m."AMST_FatherName",
            m."AMST_AdmNo",
            y."AMAY_RollNo",
            a."EMSE_Id",
            b."EME_Id",
            b."ISMS_Id",
            a."ESTMPSSS_PassFailFlg" 
            FROM "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" AS a
            INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" AS b ON a."ESTMPS_Id"=b."ESTMPS_Id"
            INNER JOIN "Adm_M_Student" AS m ON b."AMST_Id"=m."AMST_Id"
            INNER JOIN "Adm_School_Y_Student" AS y ON m."AMST_Id"=y."AMST_Id"
            WHERE m."AMST_SOL"='S' AND y."AMAY_ActiveFlag"=1 
            AND a."ESTMPS_Id" IN (
                SELECT "ESTMPS_Id" 
                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                WHERE "MI_Id"="p_MI_Id" 
                AND "ASMAY_Id"="p_ASMAY_Id" 
                AND "ASMCL_Id"="p_ASMCL_Id" 
                AND "ASMS_Id"="p_ASMS_Id" 
                AND "AMST_Id"="v_amst_id"
            )
        ), b AS (
            SELECT e."ISMS_SubjectName",
            b."ISMS_Id",
            b."EME_Id",
            a."EMSE_Id",
            d."EME_ExamName",
            c."EMSE_SubExamName",
            SUM(a."ESTMPSSS_ObtainedMarks") AS "ESTMPSSS_ObtainedMarks",
            SUM(a."ESTMPSSS_MaxMarks") AS "MaxMarks" 
            FROM "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" AS a
            INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" AS b ON a."ESTMPS_Id"=b."ESTMPS_Id"
            INNER JOIN "Exm"."Exm_Master_SubExam" AS c ON a."EMSE_Id"=c."EMSE_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" AS d ON b."EME_Id"=d."EME_Id"
            INNER JOIN "IVRM_Master_Subjects" AS e ON e."ISMS_Id"=b."ISMS_Id"
            WHERE a."ESTMPS_Id" IN (
                SELECT "ESTMPS_Id" 
                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                WHERE "MI_Id"="p_MI_Id" 
                AND "ASMAY_Id"="p_ASMAY_Id" 
                AND "ASMCL_Id"="p_ASMCL_Id" 
                AND "ASMS_Id"="p_ASMS_Id" 
                AND "AMST_Id"="v_amst_id"
            )
            GROUP BY e."ISMS_SubjectName",b."ISMS_Id",b."EME_Id",a."EMSE_Id",d."EME_ExamName",c."EMSE_SubExamName"
        )
        SELECT DISTINCT "AMS"."AMST_Id",
        (COALESCE("AMS"."AMST_FirstName",'')||' '||COALESCE("AMS"."AMST_MiddleName",'')||' '||COALESCE("AMS"."AMST_LastName",'')) AS stname,
        COALESCE("AMS"."AMST_FatherName",''),
        "AMS"."AMST_AdmNo",
        "ASYS"."AMAY_RollNo",
        "EYCES"."ISMS_Id",
        "IMS"."ISMS_SubjectName",
        "EME"."EME_Id",
        '1001' AS "EMSE_Id",
        "EME"."EME_ExamName",
        'Total' AS "EMSE_SubexamName",
        "ESMPS"."ESTMPS_ObtainedMarks",
        "ESMPS"."ESTMPS_MaxMarks",
        "ESMPS"."ESTMPS_PassFailFlg"
        FROM "Exm"."Exm_Category_Class" "ECC"
        INNER JOIN "Exm"."Exm_Yearly_Category" "EYC" ON "ECC"."EMCA_Id"="EYC"."EMCA_Id" AND "EYC"."EYC_ActiveFlg"=1 AND "ECC"."ECAC_ActiveFlag"=1
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCE"."EYC_Id"="EYC"."EYC_Id" AND "EYCE"."EYCE_ActiveFlg"=1
        INNER JOIN "Exm"."Exm_Master_Exam" "EME" ON "EME"."EME_Id"="EYCE"."EME_Id" AND "EME"."EME_ActiveFlag"=1
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" "EYCES" ON "EYCES"."EYCE_Id"="EYCE"."EYCE_Id" AND "EYCES"."EYCES_ActiveFlg"=1 AND "EYCES"."EYCES_AplResultFlg"=1
        INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id"="EYCES"."ISMS_Id" AND "IMS"."ISMS_ActiveFlag"=1
        INNER JOIN "Exm"."Exm_Student_Marks_Process" "ESMP" ON "ESMP"."EME_Id"="EME"."EME_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id"="ESMP"."AMST_Id"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id"="ASYS"."AMST_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" ON "ESMPS"."ISMS_Id"="IMS"."ISMS_Id" 
        AND "ESMPS"."AMST_Id"="AMS"."AMST_Id"
        AND "ESMPS"."EME_Id"="EME"."EME_Id" 
        AND "ESMPS"."ISMS_Id"="EYCES"."ISMS_Id" 
        AND "ESMPS"."ASMAY_Id"="p_ASMAY_Id" 
        AND "ESMPS"."MI_Id"="p_MI_Id" 
        AND "ESMPS"."ASMCL_Id"="ASYS"."ASMCL_Id" 
        AND "ESMPS"."ASMS_Id"="ASYS"."ASMS_Id"
        WHERE "ESMP"."MI_Id"="p_MI_Id" 
        AND "ESMP"."ASMAY_Id"="p_ASMAY_Id" 
        AND "ESMP"."ASMCL_Id"="p_ASMCL_Id" 
        AND "ESMP"."ASMS_Id"="p_ASMS_Id" 
        AND "ESMP"."AMST_Id"="v_amst_id";
    END LOOP;

    RETURN QUERY
    SELECT "B"."AMST_Id",
    "B"."stname",
    "B"."fathername",
    "B"."AMST_AdmNo",
    "B"."AMAY_RollNo",
    "B"."ISMS_Id",
    "B"."ISMS_SubjectName",
    "B"."EME_Id",
    "B"."EMSE_Id",
    "B"."EME_ExamName",
    "B"."EMSE_SubExamName",
    COALESCE("B"."ESTMPS_ObtainedMarks",0) AS "ESTMPS_ObtainedMarks",
    COALESCE("B"."ESTMPS_MaxMarks",0) AS "ESTMPS_MaxMarks",
    (SELECT STRING_AGG("A"."ESTMPS_PassFailFlg",',')
     FROM "StudentListE1" "A"
     WHERE "A"."AMST_Id"="B"."AMST_Id" 
     AND "A"."stname"="B"."stname"
     AND "A"."fathername"="B"."fathername" 
     AND "A"."AMST_AdmNo"="B"."AMST_AdmNo" 
     AND "A"."AMAY_RollNo"="B"."AMAY_RollNo" 
     AND "A"."ISMS_Id"="B"."ISMS_Id" 
     AND "A"."ISMS_SubjectName"="B"."ISMS_SubjectName" 
     AND "A"."EME_Id"="B"."EME_Id" 
     AND "A"."EMSE_Id"="B"."EMSE_Id" 
     AND "A"."EME_ExamName"="B"."EME_ExamName" 
     AND "A"."EMSE_SubExamName"="B"."EMSE_SubExamName" 
     AND COALESCE("A"."ESTMPS_ObtainedMarks",0)=COALESCE("B"."ESTMPS_ObtainedMarks",0) 
     AND COALESCE("A"."ESTMPS_MaxMarks",0)=COALESCE("B"."ESTMPS_MaxMarks",0)
    ) AS "ESTMPS_PassFailFlg"
    FROM "StudentListE1" "B"
    GROUP BY "B"."AMST_Id","B"."stname","B"."fathername","B"."AMST_AdmNo","B"."AMAY_RollNo","B"."ISMS_Id","B"."ISMS_SubjectName","B"."EME_Id","B"."EMSE_Id","B"."EME_ExamName","B"."EMSE_SubExamName","B"."ESTMPS_ObtainedMarks","B"."ESTMPS_MaxMarks";

    DROP TABLE IF EXISTS "StudentListE1";
END;
$$;