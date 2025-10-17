CREATE OR REPLACE FUNCTION "dbo"."Inward_Outward_Report_VMS"(
    "p_MI_Id" TEXT,
    "p_radiotype" TEXT,
    "p_fromdate" TEXT,
    "p_todate" TEXT,
    "p_months" TEXT,
    "p_userName" VARCHAR(10)
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
    "v_sqldynamic" TEXT;
    "v_content" TEXT;
    "v_content2" TEXT;
    "v_content3" TEXT;
BEGIN

    IF "p_userName" = 'admin' THEN
    
        IF "p_fromdate" != '' AND "p_todate" != '' THEN
            IF "p_radiotype" = 'outward' THEN
                "v_content" := ' and "FOOUT_DateTime"::date between ''' || "p_fromdate" || ''' and ''' || "p_todate" || '''';
            ELSIF "p_radiotype" = 'inward' THEN
                "v_content" := ' and "FOIN_DateTime"::date between ''' || "p_fromdate" || ''' and ''' || "p_todate" || '''';
            END IF;
        ELSE
            "v_content" := '';
        END IF;

        IF "p_months" != '' THEN
            IF "p_radiotype" = 'outward' THEN
                "v_content2" := 'and EXTRACT(MONTH FROM "FOOUT_DateTime") = ''' || "p_months" || '''';
            ELSIF "p_radiotype" = 'inward' THEN
                "v_content2" := 'and EXTRACT(MONTH FROM "FOIN_DateTime") = ''' || "p_months" || '''';
            END IF;
        ELSE
            "v_content2" := '';
        END IF;

        IF "p_radiotype" = 'outward' THEN
            "v_sqldynamic" := '
            SELECT COALESCE("HRME_EmployeeFirstName",'''') || '''' || COALESCE("HRME_EmployeeMiddleName",'''') || '''' || COALESCE("HRME_EmployeeLastName",'''') as "hrmE_EmployeeFirstName",
                   "FOOUT_OutwardNo" as "foouT_OutwardNo",
                   "FOOUT_DateTime" as "foouT_DateTime",
                   "FOOUT_Discription" as "foouT_Discription",
                   "FOOUT_From" as "foouT_From",
                   "FOOUT_To" as "foouT_To",
                   "FOOUT_Address" as "foouT_Address",
                   "FOOUT_PhoneNo" as "foouT_PhoneNo",
                   "FOOUT_EmailId" as "foouT_EmailId",
                   "FOOUT_DispatachedBy" as "foouT_DispatachedBy",
                   "FOOUT_DispatchedThrough" as "foouT_DispatchedThrough",
                   "FOOUT_DispatchedDeatils" as "foouT_DispatchedDeatils",
                   "FOOUT_DispatchedPhNo" as "foouT_DispatchedPhNo",
                   NULL::TEXT as "foiN_InwardNo",
                   NULL::TIMESTAMP as "foiN_DateTime",
                   NULL::TEXT as "foiN_From",
                   NULL::TEXT as "foiN_Adddress",
                   NULL::TEXT as "foiN_ContactPerson",
                   NULL::TEXT as "foiN_PhoneNo",
                   NULL::TEXT as "foiN_EmailId",
                   NULL::TEXT as "foiN_Discription",
                   NULL::TEXT as "foiN_To",
                   NULL::TEXT as "foiN_ReceivedBy",
                   NULL::TEXT as "foiN_HandedOverTo"
            FROM "HR_Master_Employee" a
            INNER JOIN "vm"."FO_Outward" b ON a."HRME_Id" = b."FOOUT_DispatachedBy" AND a."MI_Id" = b."MI_Id"
            WHERE b."MI_Id" IN (' || "p_MI_Id" || ') ' || "v_content" || ' ' || "v_content2";
        ELSIF "p_radiotype" = 'inward' THEN
            "v_sqldynamic" := '
            SELECT NULL::TEXT as "hrmE_EmployeeFirstName",
                   NULL::TEXT as "foouT_OutwardNo",
                   NULL::TIMESTAMP as "foouT_DateTime",
                   NULL::TEXT as "foouT_Discription",
                   NULL::TEXT as "foouT_From",
                   NULL::TEXT as "foouT_To",
                   NULL::TEXT as "foouT_Address",
                   NULL::TEXT as "foouT_PhoneNo",
                   NULL::TEXT as "foouT_EmailId",
                   NULL::TEXT as "foouT_DispatachedBy",
                   NULL::TEXT as "foouT_DispatchedThrough",
                   NULL::TEXT as "foouT_DispatchedDeatils",
                   NULL::TEXT as "foouT_DispatchedPhNo",
                   "FOIN_InwardNo" as "foiN_InwardNo",
                   "FOIN_DateTime" as "foiN_DateTime",
                   "FOIN_From" as "foiN_From",
                   "FOIN_Adddress" as "foiN_Adddress",
                   "FOIN_ContactPerson" as "foiN_ContactPerson",
                   "FOIN_PhoneNo" as "foiN_PhoneNo",
                   "FOIN_EmailId" as "foiN_EmailId",
                   "FOIN_Discription" as "foiN_Discription",
                   (SELECT COALESCE("HRME_EmployeeFirstName",'''') || '''' || COALESCE("HRME_EmployeeMiddleName",'''') || '''' || COALESCE("HRME_EmployeeLastName",'''') 
                    FROM "HR_Master_Employee" c WHERE c."HRME_Id" = b."FOIN_To") as "foiN_To",
                   (SELECT COALESCE("HRME_EmployeeFirstName",'''') || '''' || COALESCE("HRME_EmployeeMiddleName",'''') || '''' || COALESCE("HRME_EmployeeLastName",'''') 
                    FROM "HR_Master_Employee" d WHERE d."HRME_Id" = b."FOIN_ReceivedBy") as "foiN_ReceivedBy",
                   (SELECT COALESCE("HRME_EmployeeFirstName",'''') || '''' || COALESCE("HRME_EmployeeMiddleName",'''') || '''' || COALESCE("HRME_EmployeeLastName",'''') 
                    FROM "HR_Master_Employee" e WHERE e."HRME_Id" = b."FOIN_HandedOverTo") as "foiN_HandedOverTo"
            FROM "vm"."FO_Inward" b 
            WHERE b."MI_Id" IN (' || "p_MI_Id" || ') ' || "v_content" || ' ' || "v_content2";
        END IF;

    ELSE
    
        IF "p_fromdate" != '' AND "p_todate" != '' THEN
            IF "p_radiotype" = 'outward' THEN
                "v_content" := 'and "FOOUT_DateTime"::date between ''' || "p_fromdate" || ''' and ''' || "p_todate" || '''';
            ELSIF "p_radiotype" = 'inward' THEN
                "v_content" := 'and "FOIN_DateTime"::date between ''' || "p_fromdate" || ''' and ''' || "p_todate" || '''';
            END IF;
        ELSE
            "v_content" := '';
        END IF;

        IF "p_months" != '' THEN
            IF "p_radiotype" = 'outward' THEN
                "v_content2" := 'and EXTRACT(MONTH FROM "FOOUT_DateTime") = ''' || "p_months" || '''';
            ELSIF "p_radiotype" = 'inward' THEN
                "v_content2" := 'and EXTRACT(MONTH FROM "FOIN_DateTime") = ''' || "p_months" || '''';
            END IF;
        ELSE
            "v_content2" := '';
        END IF;

        IF "p_radiotype" = 'outward' THEN
            "v_sqldynamic" := '
            SELECT COALESCE("HRME_EmployeeFirstName",'''') || '''' || COALESCE("HRME_EmployeeMiddleName",'''') || '''' || COALESCE("HRME_EmployeeLastName",'''') as "hrmE_EmployeeFirstName",
                   "FOOUT_OutwardNo" as "foouT_OutwardNo",
                   "FOOUT_DateTime" as "foouT_DateTime",
                   "FOOUT_Discription" as "foouT_Discription",
                   "FOOUT_From" as "foouT_From",
                   "FOOUT_To" as "foouT_To",
                   "FOOUT_Address" as "foouT_Address",
                   "FOOUT_PhoneNo" as "foouT_PhoneNo",
                   "FOOUT_EmailId" as "foouT_EmailId",
                   "FOOUT_DispatachedBy" as "foouT_DispatachedBy",
                   "FOOUT_DispatchedThrough" as "foouT_DispatchedThrough",
                   "FOOUT_DispatchedDeatils" as "foouT_DispatchedDeatils",
                   "FOOUT_DispatchedPhNo" as "foouT_DispatchedPhNo",
                   NULL::TEXT as "foiN_InwardNo",
                   NULL::TIMESTAMP as "foiN_DateTime",
                   NULL::TEXT as "foiN_From",
                   NULL::TEXT as "foiN_Adddress",
                   NULL::TEXT as "foiN_ContactPerson",
                   NULL::TEXT as "foiN_PhoneNo",
                   NULL::TEXT as "foiN_EmailId",
                   NULL::TEXT as "foiN_Discription",
                   NULL::TEXT as "foiN_To",
                   NULL::TEXT as "foiN_ReceivedBy",
                   NULL::TEXT as "foiN_HandedOverTo"
            FROM "HR_Master_Employee" a
            INNER JOIN "vm"."FO_Outward" b ON a."HRME_Id" = b."FOOUT_DispatachedBy" AND a."MI_Id" = b."MI_Id"
            WHERE a."MI_Id" IN (' || "p_MI_Id" || ') ' || "v_content" || ' ' || "v_content2";
        ELSIF "p_radiotype" = 'inward' THEN
            "v_sqldynamic" := '
            SELECT NULL::TEXT as "hrmE_EmployeeFirstName",
                   NULL::TEXT as "foouT_OutwardNo",
                   NULL::TIMESTAMP as "foouT_DateTime",
                   NULL::TEXT as "foouT_Discription",
                   NULL::TEXT as "foouT_From",
                   NULL::TEXT as "foouT_To",
                   NULL::TEXT as "foouT_Address",
                   NULL::TEXT as "foouT_PhoneNo",
                   NULL::TEXT as "foouT_EmailId",
                   NULL::TEXT as "foouT_DispatachedBy",
                   NULL::TEXT as "foouT_DispatchedThrough",
                   NULL::TEXT as "foouT_DispatchedDeatils",
                   NULL::TEXT as "foouT_DispatchedPhNo",
                   "FOIN_InwardNo" as "foiN_InwardNo",
                   "FOIN_DateTime" as "foiN_DateTime",
                   "FOIN_From" as "foiN_From",
                   "FOIN_Adddress" as "foiN_Adddress",
                   "FOIN_ContactPerson" as "foiN_ContactPerson",
                   "FOIN_PhoneNo" as "foiN_PhoneNo",
                   "FOIN_EmailId" as "foiN_EmailId",
                   "FOIN_Discription" as "foiN_Discription",
                   (SELECT COALESCE("HRME_EmployeeFirstName",'''') || '''' || COALESCE("HRME_EmployeeMiddleName",'''') || '''' || COALESCE("HRME_EmployeeLastName",'''') 
                    FROM "HR_Master_Employee" c WHERE c."HRME_Id" = b."FOIN_To") as "foiN_To",
                   (SELECT COALESCE("HRME_EmployeeFirstName",'''') || '''' || COALESCE("HRME_EmployeeMiddleName",'''') || '''' || COALESCE("HRME_EmployeeLastName",'''') 
                    FROM "HR_Master_Employee" d WHERE d."HRME_Id" = b."FOIN_ReceivedBy") as "foiN_ReceivedBy",
                   (SELECT COALESCE("HRME_EmployeeFirstName",'''') || '''' || COALESCE("HRME_EmployeeMiddleName",'''') || '''' || COALESCE("HRME_EmployeeLastName",'''') 
                    FROM "HR_Master_Employee" e WHERE e."HRME_Id" = b."FOIN_HandedOverTo") as "foiN_HandedOverTo"
            FROM "vm"."FO_Inward" b 
            WHERE b."MI_Id" IN (' || "p_MI_Id" || ') ' || "v_content" || ' ' || "v_content2";
        END IF;

    END IF;

    RETURN QUERY EXECUTE "v_sqldynamic";

END;
$$;