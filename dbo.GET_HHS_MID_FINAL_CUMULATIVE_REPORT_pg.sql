CREATE OR REPLACE FUNCTION "dbo"."GET_HHS_MID_FINAL_CUMULATIVE_REPORT"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_EME_Id bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "stname" varchar(100),
    "AMST_AdmNo" varchar(100),
    "AMAY_RollNo" bigint,
    "AMST_RegistrationNo" text,
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
    v_amst_id bigint;
    stud_rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "StudentListE";
    
    CREATE TEMP TABLE "StudentListE"(
        "AMST_Id" bigint,
        "stname" varchar(100),
        "AMST_AdmNo" varchar(100),
        "AMAY_RollNo" bigint,
        "AMST_RegistrationNo" text,
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

    FOR stud_rec IN 
        SELECT DISTINCT z."AMST_Id" 
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" AS z
        INNER JOIN "Adm_M_Student" AS m ON z."AMST_Id" = m."AMST_Id"
        INNER JOIN "Adm_School_Y_Student" AS y ON m."AMST_Id" = y."AMST_Id"
        WHERE m."AMST_SOL" = 'S' 
            AND y."AMAY_ActiveFlag" = 1 
            AND z."ASMAY_Id" = p_ASMAY_Id 
            AND z."ASMCL_Id" = p_ASMCL_Id 
            AND z."ASMS_Id" = p_ASMS_Id 
            AND z."MI_Id" = p_MI_Id
    LOOP
        v_amst_id := stud_rec."AMST_Id";
        
        WITH a AS (
            SELECT b."AMST_Id",
                (COALESCE(m."AMST_FirstName", '') || ' ' || COALESCE(m."AMST_MiddleName", '') || ' ' || COALESCE(m."AMST_LastName", '')) AS stname,
                m."AMST_AdmNo",
                y."AMAY_RollNo",
                m."AMST_RegistrationNo",
                a."EMSE_Id",
                b."EME_Id",
                b."ISMS_Id",
                a."ESTMPSSS_PassFailFlg" 
            FROM "Exm"."Exm_Student_Marks_Pro_Sub_SubSubject" AS a
            INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" AS b ON a."ESTMPS_Id" = b."ESTMPS_Id"
            INNER JOIN "Adm_M_Student" AS m ON b."AMST_Id" = m."AMST_Id"
            INNER JOIN "Adm_School_Y_Student" AS y ON m."AMST_Id" = y."AMST_Id"
            WHERE m."AMST_SOL" = 'S' 
                AND y."AMAY_ActiveFlag" = 1 
                AND a."ESTMPS_Id" IN (
                    SELECT "ESTMPS_Id" 
                    FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                    WHERE "MI_Id" = p_MI_Id 
                        AND "ASMAY_Id" = p_ASMAY_Id 
                        AND "ASMCL_Id" = p_ASMCL_Id 
                        AND "ASMS_Id" = p_ASMS_Id 
                        AND "AMST_Id" = v_amst_id 
                        AND "EME_Id" = p_EME_Id
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
            INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" AS b ON a."ESTMPS_Id" = b."ESTMPS_Id"
            INNER JOIN "Exm"."Exm_Master_SubExam" AS c ON a."EMSE_Id" = c."EMSE_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" AS d ON b."EME_Id" = d."EME_Id"
            INNER JOIN "IVRM_Master_Subjects" AS e ON e."ISMS_Id" = b."ISMS_Id"
            WHERE a."ESTMPS_Id" IN (
                SELECT "ESTMPS_Id" 
                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                WHERE "MI_Id" = p_MI_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "ASMCL_Id" = p_ASMCL_Id 
                    AND "ASMS_Id" = p_ASMS_Id 
                    AND "AMST_Id" = v_amst_id 
                    AND "EME_Id" = p_EME_Id
            ) 
            GROUP BY e."ISMS_SubjectName", b."ISMS_Id", b."EME_Id", a."EMSE_Id", d."EME_ExamName", c."EMSE_SubExamName"
        )
        INSERT INTO "StudentListE"(
            "AMST_Id", "stname", "AMST_AdmNo", "AMAY_RollNo", "AMST_RegistrationNo",
            "ISMS_Id", "ISMS_SubjectName", "EME_Id", "EMSE_Id", "EME_ExamName", "EMSE_SubExamName",
            "ESTMPS_ObtainedMarks", "ESTMPS_MaxMarks", "ESTMPS_PassFailFlg"
        )
        SELECT DISTINCT 
            a."AMST_Id", a.stname, a."AMST_AdmNo", a."AMAY_RollNo", a."AMST_RegistrationNo",
            b."ISMS_Id", b."ISMS_SubjectName", b."EME_Id", a."EMSE_Id", b."EME_ExamName", b."EMSE_SubExamName",
            b."ESTMPSSS_ObtainedMarks" AS "ESTMPS_ObtainedMarks",
            b."MaxMarks" AS "ESTMPS_MaxMarks",
            a."ESTMPSSS_PassFailFlg" AS "ESTMPS_PassFailFlg"
        FROM a, b 
        WHERE a."ISMS_Id" = b."ISMS_Id" 
            AND a."EME_Id" = b."EME_Id" 
            AND a."EMSE_Id" = b."EMSE_Id"
        UNION 
        SELECT DISTINCT 
            i."AMST_Id",
            (COALESCE(i."AMST_FirstName", '') || ' ' || COALESCE(i."AMST_MiddleName", '') || ' ' || COALESCE(i."AMST_LastName", '')) AS stname,
            i."AMST_AdmNo",
            h."AMAY_RollNo",
            i."AMST_RegistrationNo",
            e."ISMS_Id",
            f."ISMS_SubjectName",
            z."EME_Id",
            '1001' AS "EMSE_Id",
            d."EME_ExamName",
            'Total' AS "EMSE_SubExamName",
            z."ESTMPS_ObtainedMarks",
            z."ESTMPS_MaxMarks",
            z."ESTMPS_PassFailFlg"
        FROM "Exm"."Exm_Category_Class" a,
            "Exm"."Exm_Yearly_Category" b,
            "Exm"."Exm_Yearly_Category_Exams" c,
            "Exm"."Exm_Master_Exam" d,
            "Exm"."Exm_Yrly_Cat_Exams_Subwise" e,
            "IVRM_Master_Subjects" f,
            "Exm"."Exm_Student_Marks_Process" g,
            "dbo"."Adm_School_Y_Student" h,
            "dbo"."Adm_M_Student" i,
            "Exm"."Exm_Student_Marks_Process_Subjectwise" z
        WHERE c."EYC_Id" = b."EYC_Id" 
            AND b."EYC_ActiveFlg" = 1 
            AND c."EYCE_ActiveFlg" = 1 
            AND d."EME_Id" = c."EME_Id" 
            AND d."EME_ActiveFlag" = 1 
            AND e."EYCE_Id" = c."EYCE_Id" 
            AND e."EYCES_ActiveFlg" = 1
            AND a."MI_Id" = p_MI_Id 
            AND a."ASMAY_Id" = p_ASMAY_Id 
            AND a."ASMCL_Id" = p_ASMCL_Id 
            AND a."ECAC_ActiveFlag" = 1 
            AND a."ASMS_Id" = p_ASMS_Id 
            AND a."EMCA_Id" = b."EMCA_Id" 
            AND b."MI_Id" = p_MI_Id 
            AND b."ASMAY_Id" = p_ASMAY_Id
            AND f."ISMS_Id" = e."ISMS_Id" 
            AND f."ISMS_ActiveFlag" = 1 
            AND d."EME_Id" = p_EME_Id 
            AND g."AMST_Id" = h."AMST_Id" 
            AND h."AMST_Id" = i."AMST_Id" 
            AND g."AMST_Id" = v_amst_id 
            AND e."EYCES_AplResultFlg" = 1 
            AND z."AMST_Id" = i."AMST_Id" 
            AND z."EME_Id" = d."EME_Id" 
            AND z."ISMS_Id" = e."ISMS_Id" 
            AND z."ASMAY_Id" = p_ASMAY_Id 
            AND z."MI_Id" = p_MI_Id 
            AND z."ASMCL_Id" = h."ASMCL_Id" 
            AND z."ASMS_Id" = h."ASMS_Id";
            
    END LOOP;

    RETURN QUERY
    SELECT 
        B."AMST_Id",
        B."stname",
        B."AMST_AdmNo",
        B."AMAY_RollNo",
        B."AMST_RegistrationNo",
        B."ISMS_Id",
        B."ISMS_SubjectName",
        B."EME_Id",
        B."EMSE_Id",
        B."EME_ExamName",
        B."EMSE_SubExamName",
        COALESCE(B."ESTMPS_ObtainedMarks", 0) AS "ESTMPS_ObtainedMarks",
        COALESCE(B."ESTMPS_MaxMarks", 0) AS "ESTMPS_MaxMarks",
        SUBSTRING(
            (SELECT ',' || A."ESTMPS_PassFailFlg"
             FROM "StudentListE" A
             WHERE A."AMST_Id" = B."AMST_Id" 
                 AND A."stname" = B."stname" 
                 AND A."AMST_AdmNo" = B."AMST_AdmNo" 
                 AND A."AMAY_RollNo" = B."AMAY_RollNo"
                 AND A."AMST_RegistrationNo" = B."AMST_RegistrationNo" 
                 AND A."ISMS_Id" = B."ISMS_Id" 
                 AND A."ISMS_SubjectName" = B."ISMS_SubjectName" 
                 AND A."EME_Id" = B."EME_Id" 
                 AND A."EMSE_Id" = B."EMSE_Id" 
                 AND A."EME_ExamName" = B."EME_ExamName" 
                 AND A."EMSE_SubExamName" = B."EMSE_SubExamName" 
                 AND COALESCE(A."ESTMPS_ObtainedMarks", 0) = COALESCE(B."ESTMPS_ObtainedMarks", 0) 
                 AND COALESCE(A."ESTMPS_MaxMarks", 0) = COALESCE(B."ESTMPS_MaxMarks", 0)
             ORDER BY A."ESTMPS_PassFailFlg"
             FOR XML PATH('')), 2
        ) AS "ESTMPS_PassFailFlg"
    FROM "StudentListE" B
    GROUP BY 
        B."AMST_Id", B."stname", B."AMST_AdmNo", B."AMAY_RollNo", B."AMST_RegistrationNo",
        B."ISMS_Id", B."ISMS_SubjectName", B."EME_Id", B."EMSE_Id", B."EME_ExamName", 
        B."EMSE_SubExamName", B."ESTMPS_ObtainedMarks", B."ESTMPS_MaxMarks";

    DROP TABLE IF EXISTS "StudentListE";
    
    RETURN;
END;
$$;