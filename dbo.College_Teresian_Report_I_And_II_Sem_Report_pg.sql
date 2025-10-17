CREATE OR REPLACE FUNCTION "dbo"."College_Teresian_Report_I_And_II_Sem_Report"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_AMB_Id TEXT,
    p_AMSE_Id TEXT,
    p_Feegroup TEXT,
    p_category TEXT
)
RETURNS TABLE(
    "StudentName" TEXT,
    "AMCST_FatherName" TEXT,
    "AMCST_AdmNo" TEXT,
    "AMCST_RegistrationNo" TEXT,
    "FYP_ReceiptNo" TEXT,
    "FYP_ReceiptDate" TIMESTAMP,
    "caste" TEXT,
    "gender" TEXT,
    "ACSTPS_PreviousRegNo" TEXT,
    "ExamPassed" TEXT,
    "ACSTPS_PasssedMonthYear" TEXT,
    "ACSTPS_LanguagesTaken" TEXT,
    "LeftYear" TEXT,
    "annualincome" NUMERIC,
    "ACSTPS_PreviousClass" TEXT,
    "PaidAmount" NUMERIC,
    "FineAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := ';with cte
 as
 (
 select (COALESCE("AMCST_FirstName",'''')|| '' ''||COALESCE("AMCST_MiddleName",'''')||'' ''||COALESCE("AMCST_LastName",'''')) AS "StudentName","AMCST_FatherName",
"AMCST_AdmNo","AMCST_RegistrationNo","FYP_ReceiptNo","FYP_ReceiptDate", COALESCE("IMCC_CategoryName",'''') ||''/''|| COALESCE("IMC_CasteName",'''') "caste",  
"AMCST_Sex" "gender" , COALESCE("Me"."ACSTPS_PreviousRegNo",'''') "ACSTPS_PreviousRegNo",  coalesce("Me"."ACSTPS_PreviousExamPassed",'''')
"ExamPassed" ,coalesce("Me"."ACSTPS_PasssedMonthYear",'''') "ACSTPS_PasssedMonthYear" ,COALESCE("Me"."ACSTPS_LanguagesTaken",'''') "ACSTPS_LanguagesTaken", 
COALESCE("Me"."ACSTPS_LeftYear",'''') "LeftYear", "b"."AMCST_FatherAnnIncome" "annualincome","ACSTPS_PreviousClass" ,
sum (("FCSS_PaidAmount")) "PaidAmount" ,0 as "FineAmount"
from "clg"."Adm_College_Yearly_Student" "a" 
INNER JOIN "clg"."Adm_Master_College_Student" "b" on "a"."AMCST_Id"="b"."AMCST_Id"
INNER JOIN "clg"."Adm_Master_Course" "c" on "c"."AMCO_Id" = "a"."AMCO_Id"
INNER JOIN "clg"."Adm_Master_Branch" "d" on "d"."AMB_Id"="a"."AMB_Id"
INNER JOIN "clg"."Adm_Master_Semester" "e" on "e"."AMSE_Id"="a"."AMSE_Id"
INNER JOIN "Adm_School_M_Academic_Year" "f" on "f"."ASMAY_Id"="a"."ASMAY_Id"
INNER JOIN "clg"."Fee_Y_Payment_College_Student" "g" on "g"."AMCST_Id"= "a"."AMCST_Id"
INNER JOIN "clg"."Fee_Y_Payment" "h" on "h"."FYP_Id"="g"."FYP_Id"
INNER JOIN "clg"."Fee_T_College_Payment" "i" on "i"."FYP_Id"="h"."FYP_Id"
INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" "j" on "j"."FCMAS_Id"="i"."FCMAS_Id"
INNER JOIN "clg"."Fee_College_Master_Amount" "k" on "k"."FCMA_Id"="j"."FCMA_Id"
INNER JOIN "Fee_Master_Head" "l" on "l"."FMH_Id"="k"."FMH_Id"
INNER JOIN "CLG"."Fee_College_Student_Status" "CSS" on "CSS"."FCMAS_Id"="j"."FCMAS_Id" and "CSS"."AMCST_Id"="a"."AMCST_Id"
INNER JOIN "IVRM_Master_Caste" "MC" on "MC"."IMC_Id"="b"."IMC_Id" 
INNER JOIN "IVRM_Master_Caste_Category" "Md" on "Md"."IMCC_Id"="b"."IMCC_Id"
INNER JOIN "clg"."Adm_College_Quota" "Mf" on "Mf"."ACQ_Id"="b"."ACQ_Id" 
LEFT JOIN "clg"."Adm_College_Student_PrevSchool" "Me" on "Me"."AMCST_Id"="b"."AMCST_Id" 

where "a"."AMCO_Id"=' || p_AMCO_Id || ' and "a"."AMB_Id"=' || p_AMB_Id || ' AND "a"."AMSE_Id"=' || p_AMSE_Id || ' and "k"."FMG_Id" IN(' || p_Feegroup || ')  and "b"."ACQ_Id"=' || p_category || '

group by "AMCST_FirstName" ,"AMCST_MiddleName" ,"AMCST_LastName" ,"AMCST_FatherName",
"AMCST_AdmNo","AMCST_RegistrationNo","FYP_ReceiptNo","FYP_ReceiptDate",
COALESCE("Me"."ACSTPS_PreviousRegNo",''''),coalesce("Me"."ACSTPS_PreviousExamPassed",'''')
,coalesce("Me"."ACSTPS_PasssedMonthYear",''''),COALESCE("Me"."ACSTPS_LanguagesTaken",''''),COALESCE("Me"."ACSTPS_LeftYear",'''') , "b"."AMCST_FatherAnnIncome","IMCC_CategoryName","IMC_CasteName","AMCST_Sex","ACSTPS_PreviousClass"

union 

select (COALESCE("AMCST_FirstName",'''')|| '' ''||COALESCE("AMCST_MiddleName",'''')||'' ''||COALESCE("AMCST_LastName",'''')) AS "StudentName","AMCST_FatherName",
"AMCST_AdmNo","AMCST_RegistrationNo","FYP_ReceiptNo","FYP_ReceiptDate",
COALESCE("IMCC_CategoryName",'''') ||''/''|| COALESCE("IMC_CasteName",'''') "caste",  
"AMCST_Sex" "gender" , COALESCE("Me"."ACSTPS_PreviousRegNo",'''') "ACSTPS_PreviousRegNo",  
coalesce("Me"."ACSTPS_PreviousExamPassed",'''') "ExamPassed" ,coalesce("Me"."ACSTPS_PasssedMonthYear",'''') "ACSTPS_PasssedMonthYear" , 
COALESCE("Me"."ACSTPS_LanguagesTaken",'''') "ACSTPS_LanguagesTaken", COALESCE("Me"."ACSTPS_LeftYear",'''') "LeftYear", 
"b"."AMCST_FatherAnnIncome" "annualincome","ACSTPS_PreviousClass" ,0 AS "PaidAmount",sum (("FCSS_PaidAmount")) "FineAmount"

from "clg"."Adm_College_Yearly_Student" "a" 
INNER JOIN "clg"."Adm_Master_College_Student" "b" on "a"."AMCST_Id"="b"."AMCST_Id"
INNER JOIN "clg"."Adm_Master_Course" "c" on "c"."AMCO_Id" = "a"."AMCO_Id"
INNER JOIN "clg"."Adm_Master_Branch" "d" on "d"."AMB_Id"="a"."AMB_Id"
INNER JOIN "clg"."Adm_Master_Semester" "e" on "e"."AMSE_Id"="a"."AMSE_Id"
INNER JOIN "Adm_School_M_Academic_Year" "f" on "f"."ASMAY_Id"="a"."ASMAY_Id"
INNER JOIN "clg"."Fee_Y_Payment_College_Student" "g" on "g"."AMCST_Id"= "a"."AMCST_Id"
INNER JOIN "clg"."Fee_Y_Payment" "h" on "h"."FYP_Id"="g"."FYP_Id"
INNER JOIN "clg"."Fee_T_College_Payment" "i" on "i"."FYP_Id"="h"."FYP_Id"
INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" "j" on "j"."FCMAS_Id"="i"."FCMAS_Id"
INNER JOIN "clg"."Fee_College_Master_Amount" "k" on "k"."FCMA_Id"="j"."FCMA_Id"
INNER JOIN "Fee_Master_Head" "l" on "l"."FMH_Id"="k"."FMH_Id"
INNER JOIN "CLG"."Fee_College_Student_Status" "CSS" on "CSS"."FCMAS_Id"="j"."FCMAS_Id" and "CSS"."AMCST_Id"="a"."AMCST_Id"
INNER JOIN "IVRM_Master_Caste" "MC" on "MC"."IMC_Id"="b"."IMC_Id" 
INNER JOIN "IVRM_Master_Caste_Category" "Md" on "Md"."IMCC_Id"="b"."IMCC_Id"
INNER JOIN "clg"."Adm_College_Quota" "Mf" on "Mf"."ACQ_Id"="b"."ACQ_Id" 
LEFT JOIN "clg"."Adm_College_Student_PrevSchool" "Me" on "Me"."AMCST_Id"="b"."AMCST_Id" 
 
where "a"."AMCO_Id"=' || p_AMCO_Id || ' and "a"."AMB_Id"=' || p_AMB_Id || ' AND "a"."AMSE_Id"=' || p_AMSE_Id || ' and "k"."FMG_Id" IN(' || p_Feegroup || ') and "b"."ACQ_Id"=' || p_category || '  and "CSS"."FMH_Id"=155 and "l"."FMH_Id"=155
group by "AMCST_FirstName" ,"AMCST_MiddleName" ,"AMCST_LastName" ,"AMCST_FatherName",
"AMCST_AdmNo","AMCST_RegistrationNo","FYP_ReceiptNo","FYP_ReceiptDate",COALESCE("Me"."ACSTPS_PreviousRegNo",''''),coalesce("Me"."ACSTPS_PreviousExamPassed",'''')
,coalesce("Me"."ACSTPS_PasssedMonthYear",''''),COALESCE("Me"."ACSTPS_LanguagesTaken",''''),COALESCE("Me"."ACSTPS_LeftYear",'''') ,
"b"."AMCST_FatherAnnIncome","IMCC_CategoryName","IMC_CasteName","AMCST_Sex" ,"ACSTPS_PreviousClass"
)select "StudentName","AMCST_FatherName","AMCST_AdmNo","AMCST_RegistrationNo","FYP_ReceiptNo",MIN("FYP_ReceiptDate") "FYP_ReceiptDate","caste","gender","ACSTPS_PreviousRegNo","ExamPassed","ACSTPS_PasssedMonthYear","ACSTPS_LanguagesTaken","LeftYear","annualincome","ACSTPS_PreviousClass","PaidAmount","FineAmount" from cte where "PaidAmount"<>0
 group by  "StudentName","AMCST_FatherName","AMCST_AdmNo","AMCST_RegistrationNo","FYP_ReceiptNo","caste","gender","ACSTPS_PreviousRegNo","ExamPassed","ACSTPS_PasssedMonthYear","ACSTPS_LanguagesTaken","LeftYear","annualincome","ACSTPS_PreviousClass","PaidAmount","FineAmount" ';

    RETURN QUERY EXECUTE v_sql;
    
    RETURN;
END;
$$;