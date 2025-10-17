CREATE OR REPLACE FUNCTION "dbo"."IVRM_CWSWNotUploadedStudents"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint,
    p_ISMS_Id bigint,
    p_FromDate varchar(10),
    p_Todate varchar(10)
)
RETURNS TABLE (
    "AMST_Id" bigint
) 
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT "ASYS"."AMST_Id"  
    FROM "dbo"."Adm_M_Student" "AMS" 
    INNER JOIN "dbo"."Adm_School_Y_Student" "ASYS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
    WHERE "AMS"."MI_Id" = p_MI_Id 
        AND "ASYS"."ASMAY_Id" = p_ASMAY_Id 
        AND "ASYS"."ASMCL_Id" = p_ASMCL_Id 
        AND "ASYS"."ASMS_Id" = p_ASMS_Id
        AND "AMS"."AMST_SOL" = 'S' 
        AND "AMS"."AMST_ActiveFlag" = 1 
        AND "ASYS"."AMAY_ActiveFlag" = 1
        AND "ASYS"."AMST_Id" NOT IN (
            SELECT DISTINCT "AMST_Id"
            FROM "dbo"."IVRM_Assignment" "ASS"
            INNER JOIN "dbo"."IVRM_ClassWork_Upload" "CU" ON "ASS"."ICW_Id" = "CU"."ICW_Id"
            INNER JOIN "dbo"."IVRM_Staff_User_Login" "SUL" ON "SUL"."Id" = "ASS"."Login_Id"
            INNER JOIN "dbo"."HR_Master_Employee" "HME" ON "HME"."HRME_Id" = "SUL"."Emp_Code" 
            INNER JOIN "dbo"."IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id" = "ASS"."ISMS_Id"
            WHERE "ASS"."MI_Id" = p_MI_Id 
                AND "ASS"."ASMAY_Id" = p_ASMAY_Id 
                AND "ASMCL_Id" = p_ASMCL_Id 
                AND "ASMS_Id" = p_ASMS_Id 
                AND "ASS"."ISMS_Id" = p_ISMS_Id
                AND ((CAST("ICW_FromDate" AS date) BETWEEN CAST(p_FromDate AS date) AND CAST(p_Todate AS date)) 
                    OR (CAST("ICW_ToDate" AS date) BETWEEN CAST(p_FromDate AS date) AND CAST(p_Todate AS date)))
        );

END;
$$;