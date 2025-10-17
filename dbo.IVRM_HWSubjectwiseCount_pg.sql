CREATE OR REPLACE FUNCTION "dbo"."IVRM_HWSubjectwiseCount"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "FromDate" VARCHAR(10),
    "Todate" VARCHAR(10)
)
RETURNS TABLE(
    "StudentsCount" BIGINT,
    "EmpName" TEXT,
    "ISMS_SubjectName" TEXT,
    "SubStudentsCount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic TEXT;
BEGIN
    
    v_sqldynamic := '
    WITH "StudentsCount"
    AS
    (
        SELECT COUNT(DISTINCT "ASYS"."AMST_Id") AS "StudentsCount"
        FROM "Adm_M_Student" "AMS" 
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
        WHERE "AMS"."MI_Id" = ' || "MI_Id" || ' 
            AND "ASYS"."ASMAY_Id" = ' || "ASMAY_Id" || ' 
            AND "ASYS"."ASMCL_Id" = ' || "ASMCL_Id" || ' 
            AND "ASYS"."ASMS_Id" IN (' || "ASMS_Id" || ')
            AND "AMS"."AMST_SOL" = ''S'' 
            AND "AMS"."AMST_ActiveFlag" = 1 
            AND "ASYS"."AMAY_ActiveFlag" = 1
    ),
    "SubAssigCount"
    AS
    (
        SELECT 
            CONCAT("HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName") AS "EmpName",
            "ISMS_SubjectName",
            COUNT(DISTINCT "AMST_Id") AS "SubStudentsCount"
        FROM "IVRM_HomeWork" "ASS"
        INNER JOIN "IVRM_HomeWork_Upload" "CU" ON "ASS"."IHW_Id" = "CU"."IHW_Id"
        INNER JOIN "IVRM_Staff_User_Login" "SUL" ON "SUL"."Id" = "ASS"."IVRMUL_Id"
        INNER JOIN "HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "SUL"."Emp_Code" 
        INNER JOIN "IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id" = "ASS"."ISMS_Id"
        WHERE "ASS"."MI_Id" = ' || "MI_Id" || ' 
            AND "ASS"."ASMAY_Id" = ' || "ASMAY_Id" || ' 
            AND "ASS"."ASMCL_Id" = ' || "ASMCL_Id" || ' 
            AND "ASS"."ASMS_Id" IN (' || "ASMS_Id" || ') 
            AND (CAST("IHW_Date" AS DATE) BETWEEN ''' || "FromDate" || ''' AND ''' || "Todate" || ''')
            AND "HME"."MI_Id" = ' || "MI_Id" || ' 
            AND "IMS"."MI_Id" = ' || "MI_Id" || '
        GROUP BY "ASS"."MI_Id", "ASS"."ASMAY_Id", "ASS"."ASMCL_Id", "ASS"."ASMS_Id",
            CONCAT("HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName"), "ISMS_SubjectName"
    )
    SELECT * FROM "StudentsCount", "SubAssigCount"';
    
    RETURN QUERY EXECUTE v_sqldynamic;
    
END;
$$;