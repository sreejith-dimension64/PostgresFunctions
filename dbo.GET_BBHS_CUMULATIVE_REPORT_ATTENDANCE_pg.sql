CREATE OR REPLACE FUNCTION "dbo"."GET_BBHS_CUMULATIVE_REPORT_ATTENDANCE"(
    "@MI_Id" bigint,
    "@ASMAY_Id" bigint,
    "@ASMCL_Id" bigint,
    "@ASMS_Id" bigint
)
RETURNS TABLE(
    "ECT_Id" bigint,
    "ECT_TermName" text,
    "EMPSG_GroupName" text,
    "AMST_Id" bigint,
    "ASA_ClassHeld" numeric,
    "ASA_Classpresent" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        "ECT"."ECT_Id",
        "ECT"."ECT_TermName",
        "EMPSG"."EMPSG_GroupName",
        "ESMPS"."AMST_Id",
        (SELECT SUM("asa_classheld") 
         FROM "Adm_Student_Attendance" p  
         WHERE "mi_id" = "@MI_Id" 
         AND "ASMAY_Id" = "@ASMAY_Id"
         AND "ASMCL_Id" = "@ASMCL_Id" 
         AND "ASMS_Id" = "@ASMS_Id" 
         AND "ASA_Activeflag" = 1  
         AND ((TO_TIMESTAMP(p."ASA_FromDate", 'DD/MM/YYYY') BETWEEN "EYCE"."EYCE_AttendanceFromDate" AND "EYCE"."EYCE_AttendanceToDate") 
         OR (TO_TIMESTAMP(p."ASA_ToDate", 'DD/MM/YYYY') BETWEEN "EYCE"."EYCE_AttendanceFromDate" AND "EYCE"."EYCE_AttendanceToDate"))) AS "ASA_ClassHeld",
        (SELECT SUM("ASA_Class_Attended")  
         FROM "Adm_Student_Attendance_Students" q
         INNER JOIN "Adm_Student_Attendance" AS p ON p."ASA_Id" = q."ASA_Id"
         WHERE "mi_id" = "@MI_Id" 
         AND "ASA_Activeflag" = 1 
         AND "ASMAY_Id" = "@ASMAY_Id" 
         AND "ASMCL_Id" = "@ASMCL_Id" 
         AND "ASMS_Id" = "@ASMS_Id" 
         AND q."AMST_Id" = "ESMPS"."AMST_Id" 
         AND ((TO_TIMESTAMP(p."ASA_FromDate", 'DD/MM/YYYY') BETWEEN "EYCE"."EYCE_AttendanceFromDate" AND "EYCE"."EYCE_AttendanceToDate"))) AS "ASA_Classpresent"
    FROM "Exm"."Exm_CCE_TERMS" "ECT" 
    INNER JOIN "Exm"."Exm_CCE_TERMS_MP" "ECTM" ON "ECT"."ECT_Id" = "ECTM"."ECT_Id"
    INNER JOIN "Exm"."Exm_CCE_TERMS_MP_EXAMS" "ECTME" ON "ECTME"."ECTMP_Id" = "ECTM"."ECTMP_Id"
    INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" "EMPSGE" ON "EMPSGE"."EME_Id" = "ECTME"."EME_ID"
    INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" "EMPSG" ON "EMPSG"."EMPSG_Id" = "EMPSGE"."EMPSG_Id"
    INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" "ESMPSG" ON "ESMPSG"."EMPSG_Id" = "EMPSG"."EMPSG_Id" AND "ESMPSG"."EMPSG_Id" = "EMPSG"."EMPSG_Id" 
    INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" "ESMPS" ON "ESMPS"."ESTMPPS_Id" = "ESMPSG"."ESTMPPS_Id"
    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYCE"."EME_Id" = "EMPSGE"."EME_Id"
    WHERE "ESMPS"."MI_Id" = "@MI_Id" 
    AND "ESMPS"."ASMAY_Id" = "@ASMAY_Id" 
    AND "ESMPS"."ASMCL_Id" = "@ASMCL_Id" 
    AND "ESMPS"."ASMS_Id" = "@ASMS_Id"
    ORDER BY "ESMPS"."AMST_Id";

END;
$$;