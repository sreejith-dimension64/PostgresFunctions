CREATE OR REPLACE FUNCTION "ADM_STUDENT_YEARLY_ATTENDANCE_NEW_CATEGORY"(
    "asmay_id" TEXT,
    "asmcl_id" TEXT,
    "asms_id" TEXT,
    "mi_id" TEXT,
    "flag" TEXT,
    "AMC_Id" VARCHAR(10)
)
RETURNS TABLE(
    "TOTAL_PRESENT" BIGINT,
    "AMST_Id" BIGINT,
    "name" TEXT,
    "AMST_AdmNo" TEXT,
    "AMST_RegistrationNo" TEXT,
    "AMAY_RollNo" TEXT,
    "yearidname" DOUBLE PRECISION,
    "monthidname" DOUBLE PRECISION
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
    "category" TEXT;
BEGIN
    IF ("AMC_Id" != '0' AND "AMC_Id" != '') THEN
        "category" := 'and AMC.AMC_Id =' || "AMC_Id" || '';
    ELSE
        "category" := '';
    END IF;

    IF "flag" = 'indi' THEN
        "query" := 'select  sum(b.ASA_Class_Attended) as TOTAL_PRESENT , b.AMST_Id ,  
(COALESCE(d.AMST_FirstName ,'''')||'''' ||COALESCE(d.AMST_MiddleName,'''')||''''||COALESCE(d.AMST_LastName,'''')) as name ,   
 d.AMST_AdmNo,d.AMST_RegistrationNo, c.AMAY_RollNo,  
 EXTRACT(YEAR FROM asa_fromdate) yearidname , EXTRACT(MONTH FROM a.ASA_FromDate) monthidname  
  
from "adm_student_attendance" a inner join "adm_student_attendance_students" b on a."asa_id"=b."asa_id"   
inner join "adm_school_Y_student" c on c."amst_id"=b."AMST_Id"  and c."asmay_id"=a."asmay_id"  
inner join "Adm_M_Student" d on d."AMST_Id" =c."AMST_Id"   
INNER JOIN "Adm_School_M_Class_Category" ASMCC on ASMCC."ASMCC_Id"=d."AMC_Id"
INNER JOIN "Adm_M_Category" AMC ON ASMCC."AMC_Id"=AMC."AMC_Id" 
where c."ASMAY_Id"=' || "asmay_id" || ' and a."ASMAY_Id"=' || "asmay_id" || ' and a."MI_Id"=' || "mi_id" || ' and "ASA_Activeflag"=1 and c."ASMCL_Id"=' || "asmcl_id" || '   
and a."ASMCL_Id"=' || "asmcl_id" || '  
and c."ASMS_Id"=' || "asms_id" || ' and a."ASMS_Id"=' || "asms_id" || ' and "amst_sol"=''S'' and "amst_activeflag"=1 and "amay_activeflag"=1 ' || "category" || '  
group  by b."AMST_Id" , TO_CHAR(a."asa_fromdate", ''Month''), TO_CHAR(a."asa_fromdate", ''YYYY''),  
d."AMST_FirstName",  
d."AMST_MiddleName",d."AMST_LastName" ,d."AMST_AdmNo",d."AMST_RegistrationNo", c."AMAY_RollNo", EXTRACT(MONTH FROM a."ASA_FromDate"), EXTRACT(YEAR FROM "asa_fromdate")';
    ELSE
        "query" := 'select  sum(b.ASA_Class_Attended) as TOTAL_PRESENT , b.AMST_Id ,  
 (COALESCE(d.AMST_FirstName ,'''')||''''||COALESCE(d.AMST_MiddleName,'''')||''''||COALESCE(d.AMST_LastName,'''')) as name ,   
 d.AMST_AdmNo,d.AMST_RegistrationNo, c.AMAY_RollNo, EXTRACT(YEAR FROM asa_fromdate) yearidname ,  
 EXTRACT(MONTH FROM a.ASA_FromDate) monthidname  
from "adm_student_attendance" a inner join "adm_student_attendance_students" b on a."asa_id"=b."asa_id"   
inner join "adm_school_Y_student" c on c."amst_id"=b."AMST_Id" and c."asmay_id"=a."asmay_id"  
inner join "Adm_M_Student" d on d."AMST_Id" =c."AMST_Id"
INNER JOIN "Adm_School_M_Class_Category" ASMCC on ASMCC."ASMCC_Id"=d."AMC_Id"
INNER JOIN "Adm_M_Category" AMC ON ASMCC."AMC_Id"=AMC."AMC_Id"    
where c."ASMAY_Id"=' || "asmay_id" || ' and a."MI_Id"=' || "mi_id" || ' and "ASA_Activeflag"=1  and "amst_sol"=''S''   
and "amst_activeflag"=1 and "amay_activeflag"=1 ' || "category" || '  
group  by b."AMST_Id" , TO_CHAR(a."asa_fromdate", ''Month''), TO_CHAR(a."asa_fromdate", ''YYYY''),d."AMST_FirstName",d."AMST_MiddleName",  
d."AMST_LastName" ,d."AMST_AdmNo",d."AMST_RegistrationNo", c."AMAY_RollNo", EXTRACT(MONTH FROM a."ASA_FromDate"), EXTRACT(YEAR FROM "asa_fromdate")';
    END IF;

    RETURN QUERY EXECUTE "query";
END;
$$;