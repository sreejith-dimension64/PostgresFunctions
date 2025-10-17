CREATE OR REPLACE FUNCTION "dbo"."Gate_Pass_Report_For_Mobile_SelectedFromList"(
    "@MI_Id" BIGINT,
    "@radiotype" TEXT,
    "@gatepassid" TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE
    "@sqldynamic" TEXT;
    "@ASMAY_Id" TEXT;
    "@content" TEXT;
BEGIN

    SELECT "ASMAY_Id"::TEXT INTO "@ASMAY_Id" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date" 
    AND "mi_id" = "@MI_Id";

    IF "@gatepassid" != '' THEN
        IF "@radiotype" = 'std' THEN
            "@content" := 'and "GPHS_Id"::VARCHAR = ''' || "@gatepassid" || ''' ';
        ELSIF "@radiotype" = 'emp' THEN
            "@content" := 'and "GPHST_Id"::VARCHAR = ''' || "@gatepassid" || ''' ';
        END IF;
    ELSE
        "@content" := '';
    END IF;

    IF "@radiotype" = 'std' THEN
        "@sqldynamic" := '
        SELECT DISTINCT a."AMST_AdmNo" as "amsT_AdmNo",
        COALESCE(a."AMST_FirstName",'''')||''''||COALESCE(a."AMST_MiddleName",'''')||''''||COALESCE(a."AMST_LastName",'''') as "amsT_FirstName",
        a."AMST_MobileNo" as "amsT_MobileNo",
        c."ASMCL_ClassName" as "asmcL_ClassName",
        s."ASMC_SectionName" as "asmC_SectionName",
        b."GPHS_GatePassNo" as "gphS_GatePassNo",
        b."GPHS_IDCardNo" as "gphS_IDCardNo",
        b."GPHS_DateTime" as "gphS_DateTime",
        b."GPHS_Remarks" as "gphS_Remarks"
        FROM "Adm_School_Y_Student" y 
        INNER JOIN "Adm_School_M_Class" c on c."ASMCL_Id" = y."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" s on s."ASMS_Id" = y."ASMS_Id"
        INNER JOIN "VM"."Gate_Pass_Student" b on y."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_M_Student" a on a."AMST_Id" = b."AMST_Id" and a."AMST_SOL" = ''s'' and a."AMST_ActiveFlag" = 1
        WHERE a."MI_Id" = ' || "@MI_Id"::TEXT || ' and y."ASMAY_Id" = ' || "@ASMAY_Id" || ' ' || "@content";
    ELSIF "@radiotype" = 'emp' THEN
        "@sqldynamic" := '
        SELECT COALESCE(a."HRME_EmployeeFirstName",'''')||''''||COALESCE(a."HRME_EmployeeMiddleName",'''')||''''||COALESCE(a."HRME_EmployeeLastName",'''') as "hrmE_EmployeeFirstName",
        a."HRME_EmployeeCode" as "hrmE_EmployeeCode",
        c."HRMD_DepartmentName" as "hrmD_DepartmentName",
        d."HRMDES_DesignationName" as "hrmdeS_DesignationName",
        b."GPHST_GatePassNo" as "gphsT_GatePassNo",
        b."GPHST_IDCardNo" as "gphsT_IDCardNo",
        b."GPHST_DateTime" as "gphsT_DateTime",
        b."GPHST_Remarks" as "gphsT_Remarks",
        a."HRME_MobileNo" as "hrmE_MobileNo"
        FROM "HR_Master_Employee" a
        INNER JOIN "VM"."Gate_Pass_Staff" b ON a."HRME_Id" = b."HRME_Id"
        INNER JOIN "HR_Master_Department" c ON a."HRMD_Id" = c."HRMD_Id"
        INNER JOIN "HR_Master_Designation" d ON a."HRMDES_Id" = d."HRMDES_Id"
        WHERE a."MI_Id" = ' || "@MI_Id"::TEXT || ' and a."HRME_LeftFlag" = 0 and a."HRME_ActiveFlag" = 1 ' || "@content";
    END IF;

    RETURN QUERY EXECUTE "@sqldynamic";

END;
$$;