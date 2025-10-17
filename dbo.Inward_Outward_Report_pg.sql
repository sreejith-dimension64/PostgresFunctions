CREATE OR REPLACE FUNCTION "dbo"."Inward_Outward_Report"(
    p_MI_Id bigint,
    p_radiotype TEXT,
    p_fromdate TEXT,
    p_todate TEXT,
    p_months TEXT
)
RETURNS TABLE(
    "hrmE_EmployeeFirstName" TEXT,
    "foouT_OutwardNo" TEXT,
    "foouT_DateTime" TIMESTAMP,
    "foouT_Discription" TEXT,
    "foouT_From" TEXT,
    "foouT_To" TEXT,
    "foouT_Address" TEXT,
    "foouT_PhoneNo" TEXT,
    "foouT_EmailId" TEXT,
    "foouT_DispatachedBy" TEXT,
    "foouT_DispatchedThrough" TEXT,
    "foouT_DispatchedDeatils" TEXT,
    "foouT_DispatchedPhNo" TEXT,
    "foiN_InwardNo" TEXT,
    "foiN_DateTime" TIMESTAMP,
    "foiN_From" TEXT,
    "foiN_Adddress" TEXT,
    "foiN_ContactPerson" TEXT,
    "foiN_PhoneNo" TEXT,
    "foiN_EmailId" TEXT,
    "foiN_Discription" TEXT,
    "foiN_To" TEXT,
    "foiN_ReceivedBy" TEXT,
    "foiN_HandedOverTo" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqldynamic TEXT;
    v_content TEXT;
    v_content2 TEXT;
BEGIN
    IF p_fromdate != '' AND p_todate != '' THEN
        IF p_radiotype = 'outward' THEN
            v_content := 'and "FOOUT_DateTime"::date between ''' || p_fromdate || ''' and ''' || p_todate || '''';
        ELSIF p_radiotype = 'inward' THEN
            v_content := 'and "FOIN_DateTime"::date between ''' || p_fromdate || ''' and ''' || p_todate || '''';
        END IF;
    ELSE
        v_content := '';
    END IF;

    IF p_months != '' THEN
        IF p_radiotype = 'outward' THEN
            v_content2 := 'and EXTRACT(MONTH FROM "FOOUT_DateTime")=' || p_months;
        ELSIF p_radiotype = 'inward' THEN
            v_content2 := 'and EXTRACT(MONTH FROM "FOIN_DateTime")=' || p_months;
        END IF;
    ELSE
        v_content2 := '';
    END IF;

    IF p_radiotype = 'outward' THEN
        v_sqldynamic := '
        SELECT COALESCE("HRME_EmployeeFirstName",'''')||'' ''||COALESCE("HRME_EmployeeMiddleName",'''')||'' ''||COALESCE("HRME_EmployeeLastName",'''') as "hrmE_EmployeeFirstName",
               "FOOUT_OutwardNo"::TEXT as "foouT_OutwardNo",
               "FOOUT_DateTime" as "foouT_DateTime",
               "FOOUT_Discription"::TEXT as "foouT_Discription",
               "FOOUT_From"::TEXT as "foouT_From",
               "FOOUT_To"::TEXT as "foouT_To",
               "FOOUT_Address"::TEXT as "foouT_Address",
               "FOOUT_PhoneNo"::TEXT as "foouT_PhoneNo",
               "FOOUT_EmailId"::TEXT as "foouT_EmailId",
               "FOOUT_DispatachedBy"::TEXT as "foouT_DispatachedBy",
               "FOOUT_DispatchedThrough"::TEXT as "foouT_DispatchedThrough",
               "FOOUT_DispatchedDeatils"::TEXT as "foouT_DispatchedDeatils",
               "FOOUT_DispatchedPhNo"::TEXT as "foouT_DispatchedPhNo",
               NULL::TEXT, NULL::TIMESTAMP, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT
        FROM "HR_Master_Employee" a
        INNER JOIN "vm"."FO_Outward" b ON a."HRME_Id" = b."FOOUT_DispatachedBy" AND a."MI_Id" = b."MI_Id"
        WHERE a."MI_Id" = ' || p_MI_Id || ' ' || v_content || ' ' || v_content2;
    ELSIF p_radiotype = 'inward' THEN
        v_sqldynamic := '
        SELECT NULL::TEXT, NULL::TEXT, NULL::TIMESTAMP, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::TEXT,
               "FOIN_InwardNo"::TEXT as "foiN_InwardNo",
               "FOIN_DateTime" as "foiN_DateTime",
               "FOIN_From"::TEXT as "foiN_From",
               "FOIN_Adddress"::TEXT as "foiN_Adddress",
               "FOIN_ContactPerson"::TEXT as "foiN_ContactPerson",
               "FOIN_PhoneNo"::TEXT as "foiN_PhoneNo",
               "FOIN_EmailId"::TEXT as "foiN_EmailId",
               "FOIN_Discription"::TEXT as "foiN_Discription",
               (SELECT COALESCE("HRME_EmployeeFirstName",'''')||'' ''||COALESCE("HRME_EmployeeMiddleName",'''')||'' ''||COALESCE("HRME_EmployeeLastName",'''') 
                FROM "HR_Master_Employee" c WHERE c."HRME_Id" = b."FOIN_To") as "foiN_To",
               (SELECT COALESCE("HRME_EmployeeFirstName",'''')||'' ''||COALESCE("HRME_EmployeeMiddleName",'''')||'' ''||COALESCE("HRME_EmployeeLastName",'''') 
                FROM "HR_Master_Employee" d WHERE d."HRME_Id" = b."FOIN_ReceivedBy") as "foiN_ReceivedBy",
               (SELECT COALESCE("HRME_EmployeeFirstName",'''')||'' ''||COALESCE("HRME_EmployeeMiddleName",'''')||'' ''||COALESCE("HRME_EmployeeLastName",'''') 
                FROM "HR_Master_Employee" e WHERE e."HRME_Id" = b."FOIN_HandedOverTo") as "foiN_HandedOverTo"
        FROM "vm"."FO_Inward" b 
        WHERE b."MI_Id" = ' || p_MI_Id || ' ' || v_content || ' ' || v_content2;
    END IF;

    RETURN QUERY EXECUTE v_sqldynamic;
END;
$$;