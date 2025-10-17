CREATE OR REPLACE FUNCTION "dbo"."College_Attendance_preview_save_dates_All"(
    "MI_Id" TEXT,
    "asmay_id" TEXT,
    "amco_id" TEXT,
    "amb_id" TEXT,
    "amse_id" TEXT,
    "acms_id" TEXT,
    "hrme_id" TEXT
)
RETURNS TABLE(
    "AMCO_CourseName" TEXT,
    "AMB_BranchName" TEXT,
    "AMSE_SEMName" TEXT,
    "ACMS_SectionName" TEXT,
    "AMB_Id" INTEGER,
    "AMCO_Id" INTEGER,
    "AMSE_Id" INTEGER,
    "ACMS_Id" INTEGER,
    "ACSA_Id" INTEGER,
    "ISMS_SubjectName" TEXT,
    "TTMP_PeriodName" TEXT,
    "ACSA_AttendanceDate" TIMESTAMP,
    "ISMS_OrderFlag" INTEGER,
    "TTMP_Id" INTEGER,
    "TotalPresent" BIGINT,
    "totalabsent" BIGINT,
    "totalcount" BIGINT,
    "ACSA_Regular_Extra" TEXT,
    "employeename" TEXT,
    "flag" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "WHERECONDITIONFORBRANCH" TEXT;
    "WHERECONDITIONFORSECTION" TEXT;
    "SETQUERY" TEXT;
BEGIN

    IF "amb_id" = '0' OR "amb_id" = '' THEN
        "WHERECONDITIONFORBRANCH" := 'SELECT DISTINCT "AMB_Id" FROM "CLG"."Adm_Master_Branch" WHERE "MI_Id"=' || "MI_Id" || ' AND "AMB_ActiveFlag"=1';
    ELSE
        "WHERECONDITIONFORBRANCH" := 'SELECT DISTINCT "AMB_Id" FROM "CLG"."Adm_Master_Branch" WHERE "MI_Id"=' || "MI_Id" || ' AND "AMB_ActiveFlag"=1 AND "AMB_Id" IN (' || "amb_id" || ')';
    END IF;

    IF "acms_id" = '0' OR "acms_id" = '' THEN
        "WHERECONDITIONFORSECTION" := 'SELECT DISTINCT "ACMS_Id" FROM "CLG"."Adm_College_Master_Section" WHERE "MI_Id"=' || "MI_Id" || ' AND "ACMS_ActiveFlag"=1';
    ELSE
        "WHERECONDITIONFORSECTION" := 'SELECT DISTINCT "ACMS_Id" FROM "CLG"."Adm_College_Master_Section" WHERE "MI_Id"=' || "MI_Id" || ' AND "ACMS_ActiveFlag"=1 AND "ACMS_Id" IN (' || "acms_id" || ')';
    END IF;

    "SETQUERY" := ' select * from (
select distinct "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName" , "ACMS_SectionName", a."AMB_Id", a."AMCO_Id", a."AMSE_Id", a."ACMS_Id",
a."ACSA_Id", ( COALESCE("ISMS_SubjectName",'''')|| '':''||COALESCE("isms_subjectcode",''''))  "ISMS_SubjectName" , "TTMP_PeriodName" , "ACSA_AttendanceDate"  , 
"ISMS_OrderFlag"  ,c."TTMP_Id" ,sum(b."ACSAS_ClassAttended") "TotalPresent" , (COUNT(b."ACSAS_ClassAttended")-sum("ACSAS_ClassAttended")) "totalabsent" ,
COUNT(b."ACSAS_ClassAttended") "totalcount"  ,"ACSA_Regular_Extra", (COALESCE("HRME_EmployeeFirstName",'''')||'' ''|| COALESCE("HRME_EmployeeMiddleName",'''')||'' ''||COALESCE("HRME_EmployeeLastName",''''))"employeename", 1 as "flag"
from "clg"."Adm_College_Student_Attendance" a 
inner join "clg"."Adm_College_Student_Attendance_Students" b on a."ACSA_Id"=b."ACSA_Id"
inner join "clg"."Adm_College_Student_Attendance_Periodwise" c on c."ACSA_Id" =a."ACSA_Id" 
inner join "clg"."Adm_College_Yearly_Student" d on d."AMCST_Id"=b."AMCST_Id"
inner join "clg"."Adm_Master_College_Student" e on e."AMCST_Id"=d."AMCST_Id"
inner join "clg"."Adm_Master_Course" f on f."AMCO_Id"=d."AMCO_Id" and f."AMCO_Id"=a."AMCO_Id"
inner join "clg"."Adm_Master_Branch" g on g."amb_id"=d."amb_id" and g."amb_id"=a."amb_id"
inner join "clg"."Adm_Master_Semester" h on h."AMSE_Id"=d."AMSE_Id" and h."AMSE_Id"=a."AMSE_Id"
inner join "clg"."Adm_College_Master_Section" i on i."ACMS_Id"=d."ACMS_Id" and i."ACMS_Id"=a."ACMS_Id"
inner join "IVRM_Master_Subjects" j on j."ISMS_Id"=a."ISMS_Id"
inner join "TT_Master_Period" k on k."TTMP_Id"=c."TTMP_Id" 
inner join "HR_Master_Employee" emp on emp."hrme_id"=a."hrme_id"
where d."AMCO_Id" IN (' || "amco_id" || ') and  a."AMCO_Id" IN (' || "amco_id" || ')
and d."AMB_Id" IN (' || "WHERECONDITIONFORBRANCH" || ')
and a."AMB_Id" IN (' || "WHERECONDITIONFORBRANCH" || ')
and a."AMSE_Id" IN (' || "amse_id" || ')
and d."AMSE_Id" IN (' || "amse_id" || ')
and a."ACMS_Id" IN (' || "WHERECONDITIONFORSECTION" || ') 
and d."ACMS_Id" IN (' || "WHERECONDITIONFORSECTION" || ')  and a."hrme_id" =' || "hrme_id" || '
and a."ASMAY_Id"=' || "asmay_id" || ' and d."ASMAY_Id"=' || "asmay_id" || ' and a."ACSA_ActiveFlag"=1   and a."MI_Id"=' || "MI_Id" || ' and e."MI_Id"=' || "MI_Id" || '
group by   "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName" , "ACMS_SectionName",  a."ACSA_Id",  "ISMS_SubjectName" , a."AMB_Id", a."AMCO_Id", a."AMSE_Id", a."ACMS_Id",
"TTMP_PeriodName" ,  "ACSA_AttendanceDate" , "ISMS_OrderFlag"  ,c."TTMP_Id" ,"isms_subjectcode" ,"ACSA_Regular_Extra", 
"HRME_EmployeeFirstName","HRME_EmployeeMiddleName","HRME_EmployeeLastName"
order by  "ACSA_AttendanceDate" ,"ISMS_OrderFlag" ,"TTMP_Id" 
LIMIT 100

union 

select distinct "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName" , "ACMS_SectionName", a."AMB_Id", a."AMCO_Id", a."AMSE_Id", a."ACMS_Id",
a."ACSA_Id", ( COALESCE("ISMS_SubjectName",'''')|| '':''||COALESCE("isms_subjectcode",''''))  "ISMS_SubjectName" , "TTMP_PeriodName" , "ACSA_AttendanceDate"  , 
"ISMS_OrderFlag"  ,c."TTMP_Id" ,sum(b."ACSAS_ClassAttended") "TotalPresent" , (COUNT(b."ACSAS_ClassAttended")-sum("ACSAS_ClassAttended")) "totalabsent" ,
COUNT(b."ACSAS_ClassAttended") "totalcount"  ,"ACSA_Regular_Extra", (COALESCE("HRME_EmployeeFirstName",'''')||'' ''|| COALESCE("HRME_EmployeeMiddleName",'''')||'' ''||COALESCE("HRME_EmployeeLastName",''''))"employeename", 0 as "flag"
from "clg"."Adm_College_Student_Attendance" a 
inner join "clg"."Adm_College_Student_Attendance_Students" b on a."ACSA_Id"=b."ACSA_Id"
inner join "clg"."Adm_College_Student_Attendance_Periodwise" c on c."ACSA_Id" =a."ACSA_Id" 
inner join "clg"."Adm_College_Yearly_Student" d on d."AMCST_Id"=b."AMCST_Id"
inner join "clg"."Adm_Master_College_Student" e on e."AMCST_Id"=d."AMCST_Id"
inner join "clg"."Adm_Master_Course" f on f."AMCO_Id"=d."AMCO_Id" and f."AMCO_Id"=a."AMCO_Id"
inner join "clg"."Adm_Master_Branch" g on g."amb_id"=d."amb_id" and g."amb_id"=a."amb_id"
inner join "clg"."Adm_Master_Semester" h on h."AMSE_Id"=d."AMSE_Id" and h."AMSE_Id"=a."AMSE_Id"
inner join "clg"."Adm_College_Master_Section" i on i."ACMS_Id"=d."ACMS_Id" and i."ACMS_Id"=a."ACMS_Id"
inner join "IVRM_Master_Subjects" j on j."ISMS_Id"=a."ISMS_Id"
inner join "TT_Master_Period" k on k."TTMP_Id"=c."TTMP_Id" 
inner join "HR_Master_Employee" emp on emp."hrme_id"=a."hrme_id"
where d."AMCO_Id" IN (' || "amco_id" || ') and  a."AMCO_Id" IN (' || "amco_id" || ')
and d."AMB_Id" IN (' || "WHERECONDITIONFORBRANCH" || ')
and a."AMB_Id" IN (' || "WHERECONDITIONFORBRANCH" || ')
and a."AMSE_Id" IN (' || "amse_id" || ')
and d."AMSE_Id" IN (' || "amse_id" || ')
and a."ACMS_Id" IN (' || "WHERECONDITIONFORSECTION" || ') 
and d."ACMS_Id" IN (' || "WHERECONDITIONFORSECTION" || ')  and a."hrme_id" ! =' || "hrme_id" || '
and a."ASMAY_Id"=' || "asmay_id" || ' and d."ASMAY_Id"=' || "asmay_id" || ' and a."ACSA_ActiveFlag"=1   and a."MI_Id"=' || "MI_Id" || ' and e."MI_Id"=' || "MI_Id" || '
group by   "AMCO_CourseName", "AMB_BranchName", "AMSE_SEMName" , "ACMS_SectionName",  a."ACSA_Id",  "ISMS_SubjectName" , a."AMB_Id", a."AMCO_Id", a."AMSE_Id", a."ACMS_Id",
"TTMP_PeriodName" ,  "ACSA_AttendanceDate" , "ISMS_OrderFlag"  ,c."TTMP_Id" ,"isms_subjectcode" ,"ACSA_Regular_Extra" , 
"HRME_EmployeeFirstName","HRME_EmployeeMiddleName","HRME_EmployeeLastName"
order by  "ACSA_AttendanceDate" ,"ISMS_OrderFlag" ,"TTMP_Id" 
LIMIT 100

) as d';

    RETURN QUERY EXECUTE "SETQUERY";

END;
$$;