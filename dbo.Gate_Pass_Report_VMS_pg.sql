CREATE OR REPLACE FUNCTION "dbo"."Gate_Pass_Report_VMS"(
    p_MI_Id TEXT,
    p_radiotype TEXT,
    p_fromdate TEXT,
    p_todate TEXT,
    p_months TEXT
)
RETURNS TABLE(
    col1 TEXT,
    col2 TEXT,
    col3 TEXT,
    col4 TEXT,
    col5 TEXT,
    col6 TEXT,
    col7 TEXT,
    col8 TIMESTAMP,
    col9 TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic TEXT;
    v_ASMAY_Id TEXT;
    v_content TEXT;
    v_content2 TEXT;
BEGIN

    IF p_fromdate != '' AND p_todate != '' THEN
        IF p_radiotype = 'std' THEN
            v_content := 'and "GPHS_DateTime"::date between ''' || p_fromdate || '''::date and ''' || p_todate || '''::date';
        ELSIF p_radiotype = 'emp' THEN
            v_content := 'and "GPHST_DateTime"::date between ''' || p_fromdate || '''::date and ''' || p_todate || '''::date';
        END IF;
    ELSE
        v_content := '';
    END IF;

    IF p_months != '' THEN
        IF p_radiotype = 'std' THEN
            v_content2 := 'And EXTRACT(MONTH FROM "GPHS_DateTime") = ' || p_months || '';
        ELSIF p_radiotype = 'emp' THEN
            v_content2 := 'And EXTRACT(MONTH FROM "GPHST_DateTime") = ' || p_months || '';
        END IF;
    ELSE
        v_content2 := '';
    END IF;

    IF p_radiotype = 'std' THEN
        v_sqldynamic := '
        SELECT DISTINCT 
            a."AMST_AdmNo"::TEXT,
            COALESCE(a."AMST_FirstName", '''') || '' '' || COALESCE(a."AMST_MiddleName", '''') || '' '' || COALESCE(a."AMST_LastName", '''')::TEXT,
            a."AMST_MobileNo"::TEXT,
            c."ASMCL_ClassName"::TEXT,
            s."ASMC_SectionName"::TEXT,
            b."GPHS_GatePassNo"::TEXT,
            b."GPHS_IDCardNo"::TEXT,
            b."GPHS_DateTime"::TIMESTAMP,
            b."GPHS_Remarks"::TEXT
        FROM "Adm_School_Y_Student" y
        INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = y."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" s ON s."ASMS_Id" = y."ASMS_Id"
        INNER JOIN "VM"."Gate_Pass_Student" b ON y."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_M_Student" a ON a."AMST_Id" = b."AMST_Id" 
            AND a."AMST_SOL" = ''s'' 
            AND a."AMST_ActiveFlag" = 1
        WHERE a."MI_Id"::TEXT IN (' || p_MI_Id || ') 
            AND y."ASMAY_Id" IN (
                SELECT DISTINCT "ASMAY_Id" 
                FROM "Adm_School_M_Academic_Year" 
                WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date" 
                    AND "MI_Id"::TEXT IN (' || p_MI_Id || ')
            ) ' || v_content || ' ' || v_content2;
    ELSIF p_radiotype = 'emp' THEN
        v_sqldynamic := '
        SELECT 
            COALESCE(a."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(a."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(a."HRME_EmployeeLastName", '''')::TEXT,
            a."HRME_EmployeeCode"::TEXT,
            c."HRMD_DepartmentName"::TEXT,
            d."HRMDES_DesignationName"::TEXT,
            b."GPHST_GatePassNo"::TEXT,
            b."GPHST_IDCardNo"::TEXT,
            b."GPHST_DateTime"::TEXT,
            b."GPHST_DateTime"::TIMESTAMP,
            b."GPHST_Remarks"::TEXT
        FROM "HR_Master_Employee" a
        INNER JOIN "VM"."Gate_Pass_Staff" b ON a."HRME_Id" = b."HRME_Id"
        INNER JOIN "HR_Master_Department" c ON a."HRMD_Id" = c."HRMD_Id"
        INNER JOIN "HR_Master_Designation" d ON a."HRMDES_Id" = d."HRMDES_Id"
        WHERE a."MI_Id"::TEXT IN (' || p_MI_Id || ') 
            AND a."HRME_LeftFlag" = 0 
            AND a."HRME_ActiveFlag" = 1 ' || v_content || ' ' || v_content2;
    END IF;

    RETURN QUERY EXECUTE v_sqldynamic;

END;
$$;