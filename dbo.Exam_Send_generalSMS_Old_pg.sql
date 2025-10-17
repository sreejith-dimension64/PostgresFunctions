CREATE OR REPLACE FUNCTION "dbo"."Exam_Send_generalSMS_Old"(
    "ASMAY_Id" VARCHAR,
    "ASMCL_Id" VARCHAR,
    "ASMS_Id" VARCHAR,
    "MI_Id" VARCHAR,
    "EME_Id" VARCHAR
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "AMST_Name" TEXT,
    "AMST_AdmNo" VARCHAR,
    "AMST_emailId" VARCHAR,
    "AMST_MobileNo" VARCHAR,
    "MarksDetails" TEXT,
    "GradeDetails" TEXT,
    "TotalMarks" TEXT,
    "TotalGrade" TEXT,
    "result" TEXT,
    "ESTMPS_PassFailFlg" VARCHAR,
    "ISMS_OrderFlag" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "wherecondition" TEXT;
    "setquery" TEXT;
BEGIN

    IF "ASMCL_Id" = '0' THEN
        "wherecondition" := 'SELECT "ASMCL_Id" FROM "Adm_School_M_Class" WHERE "MI_Id"=' || "MI_Id" || ' AND "ASMCL_ActiveFlag"=1';
    ELSE
        "wherecondition" := 'SELECT "ASMCL_Id" FROM "Adm_School_M_Class" WHERE "MI_Id"=' || "MI_Id" || ' AND "ASMCL_ActiveFlag"=1 AND "ASMCL_Id"=' || "ASMCL_Id" || ' ';
    END IF;

    IF "ASMS_Id" = '0' THEN
        "setquery" := '
        SELECT DISTINCT "AMS"."AMST_Id",(COALESCE("AMST_FirstName",'' '') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''')) AS "AMST_Name","AMS"."AMST_AdmNo",
        "AMS"."AMST_emailId","AMS"."AMST_MobileNo",
        ("IMS"."ISMS_SubjectName" || '': '' || CAST("ESMPS"."ESTMPS_ObtainedMarks" AS VARCHAR(50)) || ''/'' || CAST("ESMPS"."ESTMPS_MaxMarks" AS VARCHAR(50))) AS "MarksDetails",
        (("IMS"."ISMS_SubjectName" || '': '' || "ESMPS"."ESTMPS_ObtainedGrade")) AS "GradeDetails",
        (''Total: '' || CAST("ESMP"."ESTMP_TotalObtMarks" AS VARCHAR(50)) || ''/'' || CAST("ESMP"."ESTMP_TotalMaxMarks" AS VARCHAR(50))) AS "TotalMarks",
        (''TotalGrade: '' || "ESMP"."ESTMP_TotalGrade") AS "TotalGrade",("IMS"."ISMS_SubjectName" || '': '' || ("ESMPS"."ESTMPS_PassFailFlg") || ''/'' || CAST("ESMPS"."ESTMPS_MaxMarks" AS VARCHAR(50))) AS result,"ESMPS"."ESTMPS_PassFailFlg",NULL::INTEGER AS "ISMS_OrderFlag"
        FROM "ADM_M_STUDENT" "AMS" INNER JOIN "Adm_School_M_Academic_Year" "ASMAY"
        ON "AMS"."ASMAY_Id"="ASMAY"."ASMAY_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id"="AMS"."AMST_Id"
        AND "AMS"."AMST_ActiveFlag" = 1 AND "AMS"."AMST_SOL" =''S'' AND "ASYS"."AMAY_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" "ESMPS" ON
        "ESMPS"."AMST_Id"="AMS"."AMST_Id" AND "ASMAY"."ASMAY_Id"="ESMPS"."ASMAY_Id" 
        AND "ESMPS"."MI_Id"="AMS"."MI_Id"
        INNER JOIN "IVRM_Master_subjects" "IMS" ON "IMS"."ISMS_Id"="ESMPS"."ISMS_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process" "ESMP" ON 
        "ESMP"."AMST_Id"="AMS"."AMST_Id" AND "ASMAY"."ASMAY_Id"="ESMP"."ASMAY_Id"
        AND "ESMP"."MI_Id"="AMS"."MI_Id" AND "ESMPS"."EME_Id"="ESMP"."EME_Id" AND "ESMPS"."ASMCl_Id"="ESMP"."ASMCL_Id" 
        WHERE "ESMPS"."MI_Id"=' || "MI_Id" || ' AND "ESMPS"."ASMAY_Id"=' || "ASMAY_Id" || ' AND "ESMPS"."EME_Id"=' || "EME_Id" || '
        AND "ESMPS"."ASMCL_Id" IN (' || "wherecondition" || ') AND "ASYS"."ASMCL_Id" IN (' || "wherecondition" || ') AND "ESMP"."ASMCL_Id" IN (' || "wherecondition" || ') ';
    ELSIF "ASMS_Id"::INTEGER > 0 THEN
        "setquery" := '
        SELECT DISTINCT a."AMST_Id",(COALESCE("AMST_FirstName",'' '') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''')) AS "AMST_Name",
        b."AMST_AdmNo",b."AMST_emailId",b."AMST_MobileNo",
        (h."ISMS_SubjectName" || '': '' || CAST(c."ESTMPS_ObtainedMarks" AS VARCHAR(50)) || ''/'' || CAST(c."ESTMPS_MaxMarks" AS VARCHAR(50))) AS "MarksDetails",
        ((h."ISMS_SubjectName" || '': '' || c."ESTMPS_ObtainedGrade")) AS "GradeDetails",
        (''Total: '' || CAST(d."ESTMP_TotalObtMarks" AS VARCHAR(50)) || ''/'' || CAST(d."ESTMP_TotalMaxMarks" AS VARCHAR(50))) AS "TotalMarks",
        (''TotalGrade: '' || d."ESTMP_TotalGrade") AS "TotalGrade",(h."ISMS_SubjectName" || '': '' || (c."ESTMPS_PassFailFlg") || ''/'' || CAST(c."ESTMPS_MaxMarks" AS VARCHAR(50))) AS result,c."ESTMPS_PassFailFlg","ISMS_OrderFlag"
        FROM "Adm_School_Y_Student" a INNER JOIN "Adm_M_Student" b ON a."AMST_Id"=b."AMST_Id" 
        INNER JOIN "Exm"."Exm_Student_Marks_Process_Subjectwise" c ON c."AMST_Id"=a."AMST_Id"
        INNER JOIN "Exm"."Exm_Student_Marks_Process" d ON d."AMST_Id"=a."AMST_Id"
        INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id"=a."ASMCL_Id" AND e."ASMCL_Id"=c."ASMCL_Id" AND e."ASMCL_Id"=d."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id"=a."ASMS_Id" AND f."ASMS_Id"=c."ASMS_Id" AND f."ASMS_Id"=d."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id"=a."ASMAY_Id" AND g."ASMAY_Id"=c."ASMAY_Id" AND g."ASMAY_Id"=d."ASMAY_Id"
        INNER JOIN "IVRM_Master_Subjects" h ON h."ISMS_Id"=c."ISMS_Id"
        INNER JOIN "exm"."Exm_Master_Exam" i ON i."EME_Id"=c."EME_Id" AND i."EME_Id"=d."EME_Id" 
        WHERE b."MI_Id"=' || "MI_Id" || ' AND a."ASMAY_Id"=' || "ASMAY_Id" || ' AND c."EME_Id"=' || "EME_Id" || '
        AND a."ASMCL_Id" IN (' || "wherecondition" || ')
        AND a."ASMS_Id"= ' || "ASMS_Id" || ' AND c."ASMAY_Id"=' || "ASMAY_Id" || '
        AND c."ASMCL_Id" IN (' || "wherecondition" || ')
        AND c."ASMS_Id"=' || "ASMS_Id" || ' 
        AND d."ASMAY_Id"=' || "ASMAY_Id" || ' AND d."EME_Id"=' || "EME_Id" || '
        AND d."ASMCL_Id" IN (' || "wherecondition" || ') 
        AND d."ASMS_Id"=' || "ASMS_Id" || ' ORDER BY "ISMS_OrderFlag"';
    END IF;

    RETURN QUERY EXECUTE "setquery";
    
END;
$$;