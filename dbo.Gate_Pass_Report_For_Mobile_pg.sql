CREATE OR REPLACE FUNCTION "dbo"."Gate_Pass_Report_For_Mobile"(
    p_MI_Id bigint,
    p_radiotype text,
    p_fromdate text
)
RETURNS TABLE (
    col1 text,
    col2 text,
    col3 text,
    col4 text,
    col5 text,
    col6 text,
    col7 text,
    col8 text,
    col9 text
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic text;
    v_ASMAY_Id text;
    v_content text;
BEGIN
    
    SELECT "ASMAY_Id"::text INTO v_ASMAY_Id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE CURRENT_TIMESTAMP BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date" 
    AND "mi_id" = p_MI_Id;

    IF p_fromdate != '' THEN
        IF p_radiotype = 'std' THEN
            v_content := 'and TO_DATE(TO_CHAR("GPHS_DateTime", ''DD-MM-YYYY''), ''DD-MM-YYYY'') = TO_DATE(''' || p_fromdate || ''', ''YYYY-MM-DD'') ';
        ELSIF p_radiotype = 'emp' THEN
            v_content := 'and TO_DATE(TO_CHAR("GPHST_DateTime", ''DD-MM-YYYY''), ''DD-MM-YYYY'') = TO_DATE(''' || p_fromdate || ''', ''YYYY-MM-DD'') ';
        END IF;
    ELSE
        v_content := '';
    END IF;

    IF p_radiotype = 'std' THEN
        v_sqldynamic := '
        SELECT DISTINCT 
            a."AMST_AdmNo"::text,
            COALESCE(a."AMST_FirstName",'''' ) || '''' || COALESCE(a."AMST_MiddleName",'''' ) || '''' || COALESCE(a."AMST_LastName",'''' )::text,
            a."AMST_MobileNo"::text,
            c."ASMCL_ClassName"::text,
            s."ASMC_SectionName"::text,
            b."GPHS_GatePassNo"::text,
            b."GPHS_IDCardNo"::text,
            b."GPHS_DateTime"::text,
            b."GPHS_Remarks"::text
        FROM "Adm_School_Y_Student" y 
        INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = y."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" s ON s."ASMS_Id" = y."ASMS_Id"
        INNER JOIN "VM"."Gate_Pass_Student" b ON y."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_M_Student" a ON a."AMST_Id" = b."AMST_Id" AND a."AMST_SOL" = ''s'' AND a."AMST_ActiveFlag" = 1
        WHERE a."MI_Id" = ' || p_MI_Id::text || ' AND y."ASMAY_Id" = ' || v_ASMAY_Id || ' ' || v_content;

    ELSIF p_radiotype = 'emp' THEN
        v_sqldynamic := '
        SELECT 
            COALESCE(a."HRME_EmployeeFirstName",'''' ) || '''' || COALESCE(a."HRME_EmployeeMiddleName",'''' ) || '''' || COALESCE(a."HRME_EmployeeLastName",'''' )::text,
            a."HRME_EmployeeCode"::text,
            c."HRMD_DepartmentName"::text,
            d."HRMDES_DesignationName"::text,
            b."GPHST_GatePassNo"::text,
            b."GPHST_IDCardNo"::text,
            b."GPHST_DateTime"::text,
            b."GPHST_Remarks"::text,
            a."HRME_MobileNo"::text
        FROM "HR_Master_Employee" a
        INNER JOIN "VM"."Gate_Pass_Staff" b ON a."HRME_Id" = b."HRME_Id"
        INNER JOIN "HR_Master_Department" c ON a."HRMD_Id" = c."HRMD_Id"
        INNER JOIN "HR_Master_Designation" d ON a."HRMDES_Id" = d."HRMDES_Id"
        WHERE a."MI_Id" = ' || p_MI_Id::text || ' AND a."HRME_LeftFlag" = 0 AND a."HRME_ActiveFlag" = 1 ' || v_content;
    END IF;

    RAISE NOTICE '%', v_sqldynamic;

    RETURN QUERY EXECUTE v_sqldynamic;
    
    RETURN;
END;
$$;