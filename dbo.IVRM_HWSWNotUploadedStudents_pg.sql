CREATE OR REPLACE FUNCTION "dbo"."IVRM_HWSWNotUploadedStudents"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "ASMCL_Id" bigint,
    "ASMS_Id" bigint,
    "ISMS_Id" bigint,
    "FromDate" varchar(10),
    "Todate" varchar(10)
)
RETURNS TABLE("AMST_Id" bigint)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
select distinct "ASYS"."AMST_Id"  
from "Adm_M_Student" "AMS"
INNER JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id"="ASYS"."AMST_Id"
where "AMS"."MI_Id"="MI_Id" and "ASYS"."ASMAY_Id"="ASMAY_Id" and "ASYS"."ASMCL_Id"="ASMCL_Id" and "ASYS"."ASMS_Id"="ASMS_Id"
and "AMS"."AMST_SOL"='S' and "AMS"."AMST_ActiveFlag"=1 and "ASYS"."AMAY_ActiveFlag"=1
and "ASYS"."AMST_Id" NOT IN (
select distinct "AMST_Id"
FROM "IVRM_HomeWork" "ASS"
INNER JOIN "IVRM_HomeWork_Upload" "CU" ON "ASS"."IHW_Id"="CU"."IHW_Id"
INNER JOIN "IVRM_Staff_User_Login" "SUL" ON "SUL"."Id"="ASS"."IVRMUL_Id"
INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id"="SUL"."Emp_Code" 
INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id"="ASS"."ISMS_Id"
where "ASS"."MI_Id"="MI_Id" and "ASS"."ASMAY_Id"="ASMAY_Id" and "ASMCL_Id"="ASMCL_Id" and "ASMS_Id"="ASMS_Id" and "ASS"."ISMS_Id"="ISMS_Id"
and ((CAST("IHW_Date" as date) between CAST("FromDate" as date) and CAST("Todate" as date))) 
);

END;
$$;