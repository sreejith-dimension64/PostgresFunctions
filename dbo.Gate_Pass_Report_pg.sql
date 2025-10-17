CREATE OR REPLACE FUNCTION "dbo"."Gate_Pass_Report"(
    "MI_Id" bigint,
    "radiotype" TEXT,
    "fromdate" TEXT,
    "todate" TEXT,
    "months" TEXT
)
RETURNS TABLE(
    "column1" TEXT,
    "column2" TEXT,
    "column3" TEXT,
    "column4" TEXT,
    "column5" TEXT,
    "column6" TEXT,
    "column7" TEXT,
    "column8" TEXT,
    "column9" TEXT,
    "column10" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "sqldynamic" TEXT;
    "ASMAY_Id" TEXT;
    "content" TEXT;
    "content2" TEXT;
BEGIN

    SELECT "ASMAY_Id"::TEXT INTO "ASMAY_Id" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date" 
    AND "mi_id" = "MI_Id";

    IF "fromdate" != '' AND "todate" != '' THEN
        "content" := 'and CAST(GPHS_DateTime AS DATE) between ''' || "fromdate" || ''' and ''' || "todate" || '''';
    ELSE
        "content" := '';
    END IF;

    IF "months" != '' THEN
        "content2" := 'And EXTRACT(MONTH FROM GPHS_DateTime) ' || "months" || '';
    ELSE
        "content2" := '';
    END IF;

    IF "radiotype" = 'std' THEN
        "sqldynamic" := '
        SELECT DISTINCT a."AMST_AdmNo"::TEXT as "column1",
        COALESCE(a."AMST_FirstName",'''')||''''||COALESCE(a."AMST_MiddleName",'''')||''''||COALESCE(a."AMST_LastName",'''')::TEXT as "column2",
        a."AMST_MobileNo"::TEXT as "column3",
        c."ASMCL_ClassName"::TEXT as "column4",
        s."ASMC_SectionName"::TEXT as "column5",
        b."GPHS_GatePassNo"::TEXT as "column6",
        b."GPHS_IDCardNo"::TEXT as "column7",
        b."GPHS_DateTime"::TEXT as "column8",
        b."GPHS_Remarks"::TEXT as "column9",
        ''''::TEXT as "column10"
        FROM "Adm_School_Y_Student" y 
        INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = y."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" s ON s."ASMS_Id" = y."ASMS_Id"
        INNER JOIN "VM"."Gate_Pass_Student" b ON y."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_M_Student" a ON a."AMST_Id" = b."AMST_Id" AND a."AMST_SOL" = ''s'' AND a."AMST_ActiveFlag" = 1
        WHERE a."MI_Id" = ' || "MI_Id"::TEXT || ' AND y."ASMAY_Id" = ' || "ASMAY_Id" || ' ' || "content" || ' ' || "content2";
    ELSIF "radiotype" = 'emp' THEN
        "sqldynamic" := '
        SELECT COALESCE(a."HRME_EmployeeFirstName",'''')||''''||COALESCE(a."HRME_EmployeeMiddleName",'''')||''''||COALESCE(a."HRME_EmployeeLastName",'''')::TEXT as "column1",
        a."HRME_EmployeeCode"::TEXT as "column2",
        c."HRMD_DepartmentName"::TEXT as "column3",
        d."HRMDES_DesignationName"::TEXT as "column4",
        b."GPHST_GatePassNo"::TEXT as "column5",
        b."GPHST_IDCardNo"::TEXT as "column6",
        b."GPHST_DateTime"::TEXT as "column7",
        b."GPHST_Remarks"::TEXT as "column8",
        a."HRME_MobileNo"::TEXT as "column9",
        ''''::TEXT as "column10"
        FROM "HR_Master_Employee" a
        INNER JOIN "VM"."Gate_Pass_Staff" b ON a."HRME_Id" = b."HRME_Id"
        INNER JOIN "HR_Master_Department" c ON a."HRMD_Id" = c."HRMD_Id"
        INNER JOIN "HR_Master_Designation" d ON a."HRMDES_Id" = d."HRMDES_Id"
        WHERE a."MI_Id" = ' || "MI_Id"::TEXT || ' AND a."HRME_LeftFlag" = 0 AND a."HRME_ActiveFlag" = 1 ' || "content" || ' ' || "content2";
    END IF;

    RETURN QUERY EXECUTE "sqldynamic";

END;
$$;