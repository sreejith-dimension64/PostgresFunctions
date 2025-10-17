CREATE OR REPLACE FUNCTION "dbo"."FeeDefaulterRemarkReport"(
    "p_MI_Id" bigint,
    "p_Fromdate" varchar(20),
    "p_Todate" varchar(20),
    "p_ASMCL_Id" bigint,
    "p_ASMS_Id" text,
    "p_ASMAY_Id" bigint
)
RETURNS TABLE(
    "FMG_GroupName" varchar,
    "FMT_Name" varchar,
    "studentname" text,
    "employeename" text,
    "FSDREM_Remarks" text,
    "FSDREM_RemarksDate" timestamp,
    "ASMCL_Id" bigint,
    "ASMS_Id" bigint,
    "ASMAY_Id" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sqlexec" text;
BEGIN
    IF ("p_Todate" = '' AND "p_Fromdate" = '') OR ("p_Fromdate" IS NULL AND "p_Todate" IS NULL) THEN
        "v_sqlexec" := '
        SELECT e."FMG_GroupName", f."FMT_Name", 
               (COALESCE(b."AMST_FirstName",'''')|| COALESCE(b."AMST_MiddleName",'''')||COALESCE(b."AMST_LastName",'''')) as studentname,
               (COALESCE(d."HRME_EmployeeFirstName",'''')|| COALESCE(d."HRME_EmployeeMiddleName",'''')||COALESCE(d."HRME_EmployeeLastName",'''')) as employeename, 
               a."FSDREM_Remarks", a."FSDREM_RemarksDate", g."ASMCL_Id", g."ASMS_Id", g."ASMAY_Id"
        FROM "Fee_Student_Defaulter_Remarks" a 
        INNER JOIN "Adm_M_Student" b ON a."AMST_Id"=b."AMST_Id"
        INNER JOIN "IVRM_Staff_User_Login" c ON c."Id"=a."User_Id"
        LEFT JOIN "HR_Master_Employee" d ON d."HRME_Id"=c."Emp_Code"
        INNER JOIN "Fee_Master_Group" e ON e."FMG_Id"=a."FMG_Id"
        INNER JOIN "Fee_Master_Terms" f ON f."FMT_Id"=a."FMT_Id"
        INNER JOIN "Adm_School_Y_Student" g ON g."AMST_Id"=b."AMST_Id"
        WHERE a."MI_Id"=' || "p_MI_Id" || ' AND g."ASMCL_Id"=' || "p_ASMCL_Id" || ' AND g."ASMS_Id" IN (' || "p_ASMS_Id" || ') AND g."ASMAY_Id"=' || "p_ASMAY_Id";
        
        RETURN QUERY EXECUTE "v_sqlexec";
    ELSE
        "v_sqlexec" := '
        SELECT e."FMG_GroupName", f."FMT_Name", 
               (COALESCE(b."AMST_FirstName",'''')|| COALESCE(b."AMST_MiddleName",'''')||COALESCE(b."AMST_LastName",'''')) as studentname,
               (COALESCE(d."HRME_EmployeeFirstName",'''')|| COALESCE(d."HRME_EmployeeMiddleName",'''')||COALESCE(d."HRME_EmployeeLastName",'''')) as employeename, 
               a."FSDREM_Remarks", a."FSDREM_RemarksDate", g."ASMCL_Id", g."ASMS_Id", g."ASMAY_Id"
        FROM "Fee_Student_Defaulter_Remarks" a 
        INNER JOIN "Adm_M_Student" b ON a."AMST_Id"=b."AMST_Id"
        INNER JOIN "IVRM_Staff_User_Login" c ON c."Id"=a."User_Id"
        LEFT JOIN "HR_Master_Employee" d ON d."HRME_Id"=c."Emp_Code"
        INNER JOIN "Fee_Master_Group" e ON e."FMG_Id"=a."FMG_Id"
        INNER JOIN "Fee_Master_Terms" f ON f."FMT_Id"=a."FMT_Id"
        INNER JOIN "Adm_School_Y_Student" g ON g."AMST_Id"=b."AMST_Id"
        WHERE a."MI_Id"=' || "p_MI_Id" || ' AND a."FSDREM_RemarksDate" BETWEEN ''' || "p_Fromdate" || ''' AND ''' || "p_Todate" || ''' AND g."ASMCL_Id"=' || "p_ASMCL_Id" || ' AND g."ASMS_Id" IN (' || "p_ASMS_Id" || ') AND g."ASMAY_Id"=' || "p_ASMAY_Id";
        
        RETURN QUERY EXECUTE "v_sqlexec";
    END IF;
END;
$$;