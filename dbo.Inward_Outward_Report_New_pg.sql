CREATE OR REPLACE FUNCTION "dbo"."Inward_Outward_Report_New"(
    "MI_Id" bigint,
    "radiotype" text,
    "fromdate" text,
    "todate" text,
    "months" text,
    "userName" varchar(10)
)
RETURNS TABLE(
    "hrmE_EmployeeFirstName" text,
    "foouT_OutwardNo" text,
    "foouT_DateTime" timestamp,
    "foouT_Discription" text,
    "foouT_From" text,
    "foouT_To" text,
    "foouT_Address" text,
    "foouT_PhoneNo" text,
    "foouT_EmailId" text,
    "foouT_DispatachedBy" bigint,
    "foouT_DispatchedThrough" text,
    "foouT_DispatchedDeatils" text,
    "foouT_DispatchedPhNo" text,
    "foiN_InwardNo" text,
    "foiN_DateTime" timestamp,
    "foiN_From" text,
    "foiN_Adddress" text,
    "foiN_ContactPerson" text,
    "foiN_PhoneNo" text,
    "foiN_EmailId" text,
    "foiN_Discription" text,
    "foiN_To" text,
    "foiN_ReceivedBy" text,
    "foiN_HandedOverTo" text
)
LANGUAGE plpgsql
AS $$
DECLARE
    sqldynamic text;
    content text;
    content2 text;
    content3 text;
BEGIN

    IF "userName" = 'admin' THEN
    
        IF "fromdate" != '' AND "todate" != '' THEN
            IF "radiotype" = 'outward' THEN
                content := ' "FOOUT_DateTime"::date between ''' || "fromdate" || ''' and ''' || "todate" || '''';
            ELSIF "radiotype" = 'inward' THEN
                content := ' "FOIN_DateTime"::date between ''' || "fromdate" || ''' and ''' || "todate" || '''';
            END IF;
        ELSE
            content := '';
        END IF;

        IF "months" != '' THEN
            IF "radiotype" = 'outward' THEN
                content2 := ' EXTRACT(MONTH FROM "FOOUT_DateTime") = ''' || "months" || '''';
            ELSIF "radiotype" = 'inward' THEN
                content2 := ' EXTRACT(MONTH FROM "FOIN_DateTime") = ''' || "months" || '''';
            END IF;
        ELSE
            content2 := '';
        END IF;

        IF "radiotype" = 'outward' THEN
            sqldynamic := 'SELECT COALESCE(a."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(a."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(a."HRME_EmployeeLastName", '''') as "hrmE_EmployeeFirstName",
                b."FOOUT_OutwardNo" as "foouT_OutwardNo",
                b."FOOUT_DateTime" as "foouT_DateTime",
                b."FOOUT_Discription" as "foouT_Discription",
                b."FOOUT_From" as "foouT_From",
                b."FOOUT_To" as "foouT_To",
                b."FOOUT_Address" as "foouT_Address",
                b."FOOUT_PhoneNo" as "foouT_PhoneNo",
                b."FOOUT_EmailId" as "foouT_EmailId",
                b."FOOUT_DispatachedBy" as "foouT_DispatachedBy",
                b."FOOUT_DispatchedThrough" as "foouT_DispatchedThrough",
                b."FOOUT_DispatchedDeatils" as "foouT_DispatchedDeatils",
                b."FOOUT_DispatchedPhNo" as "foouT_DispatchedPhNo",
                NULL::text as "foiN_InwardNo", NULL::timestamp as "foiN_DateTime", NULL::text as "foiN_From",
                NULL::text as "foiN_Adddress", NULL::text as "foiN_ContactPerson", NULL::text as "foiN_PhoneNo",
                NULL::text as "foiN_EmailId", NULL::text as "foiN_Discription", NULL::text as "foiN_To",
                NULL::text as "foiN_ReceivedBy", NULL::text as "foiN_HandedOverTo"
            FROM "HR_Master_Employee" a
            INNER JOIN "vm"."FO_Outward" b ON a."HRME_Id" = b."FOOUT_DispatachedBy" AND a."MI_Id" = b."MI_Id"
            WHERE ' || content || ' ' || content2;
            
        ELSIF "radiotype" = 'inward' THEN
            sqldynamic := 'SELECT NULL::text as "hrmE_EmployeeFirstName", NULL::text as "foouT_OutwardNo", NULL::timestamp as "foouT_DateTime",
                NULL::text as "foouT_Discription", NULL::text as "foouT_From", NULL::text as "foouT_To",
                NULL::text as "foouT_Address", NULL::text as "foouT_PhoneNo", NULL::text as "foouT_EmailId",
                NULL::bigint as "foouT_DispatachedBy", NULL::text as "foouT_DispatchedThrough",
                NULL::text as "foouT_DispatchedDeatils", NULL::text as "foouT_DispatchedPhNo",
                b."FOIN_InwardNo" as "foiN_InwardNo",
                b."FOIN_DateTime" as "foiN_DateTime",
                b."FOIN_From" as "foiN_From",
                b."FOIN_Adddress" as "foiN_Adddress",
                b."FOIN_ContactPerson" as "foiN_ContactPerson",
                b."FOIN_PhoneNo" as "foiN_PhoneNo",
                b."FOIN_EmailId" as "foiN_EmailId",
                b."FOIN_Discription" as "foiN_Discription",
                (SELECT COALESCE(c."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(c."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(c."HRME_EmployeeLastName", '''') FROM "HR_Master_Employee" c WHERE c."HRME_Id" = b."FOIN_To") as "foiN_To",
                (SELECT COALESCE(d."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(d."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(d."HRME_EmployeeLastName", '''') FROM "HR_Master_Employee" d WHERE d."HRME_Id" = b."FOIN_ReceivedBy") as "foiN_ReceivedBy",
                (SELECT COALESCE(e."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(e."HRME_EmployeeLastName", '''') FROM "HR_Master_Employee" e WHERE e."HRME_Id" = b."FOIN_HandedOverTo") as "foiN_HandedOverTo"
            FROM "vm"."FO_Inward" b 
            WHERE ' || content || ' ' || content2;
        END IF;

    ELSE
    
        IF "fromdate" != '' AND "todate" != '' THEN
            IF "radiotype" = 'outward' THEN
                content := ' AND "FOOUT_DateTime"::date between ''' || "fromdate" || ''' and ''' || "todate" || '''';
            ELSIF "radiotype" = 'inward' THEN
                content := ' AND "FOIN_DateTime"::date between ''' || "fromdate" || ''' and ''' || "todate" || '''';
            END IF;
        ELSE
            content := '';
        END IF;

        IF "months" != '' THEN
            IF "radiotype" = 'outward' THEN
                content2 := ' AND EXTRACT(MONTH FROM "FOOUT_DateTime") = ''' || "months" || '''';
            ELSIF "radiotype" = 'inward' THEN
                content2 := ' AND EXTRACT(MONTH FROM "FOIN_DateTime") = ''' || "months" || '''';
            END IF;
        ELSE
            content2 := '';
        END IF;

        IF "radiotype" = 'outward' THEN
            sqldynamic := 'SELECT COALESCE(a."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(a."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(a."HRME_EmployeeLastName", '''') as "hrmE_EmployeeFirstName",
                b."FOOUT_OutwardNo" as "foouT_OutwardNo",
                b."FOOUT_DateTime" as "foouT_DateTime",
                b."FOOUT_Discription" as "foouT_Discription",
                b."FOOUT_From" as "foouT_From",
                b."FOOUT_To" as "foouT_To",
                b."FOOUT_Address" as "foouT_Address",
                b."FOOUT_PhoneNo" as "foouT_PhoneNo",
                b."FOOUT_EmailId" as "foouT_EmailId",
                b."FOOUT_DispatachedBy" as "foouT_DispatachedBy",
                b."FOOUT_DispatchedThrough" as "foouT_DispatchedThrough",
                b."FOOUT_DispatchedDeatils" as "foouT_DispatchedDeatils",
                b."FOOUT_DispatchedPhNo" as "foouT_DispatchedPhNo",
                NULL::text as "foiN_InwardNo", NULL::timestamp as "foiN_DateTime", NULL::text as "foiN_From",
                NULL::text as "foiN_Adddress", NULL::text as "foiN_ContactPerson", NULL::text as "foiN_PhoneNo",
                NULL::text as "foiN_EmailId", NULL::text as "foiN_Discription", NULL::text as "foiN_To",
                NULL::text as "foiN_ReceivedBy", NULL::text as "foiN_HandedOverTo"
            FROM "HR_Master_Employee" a
            INNER JOIN "vm"."FO_Outward" b ON a."HRME_Id" = b."FOOUT_DispatachedBy" AND a."MI_Id" = b."MI_Id"
            WHERE a."MI_Id" = ' || "MI_Id"::text || ' ' || content || ' ' || content2;
            
        ELSIF "radiotype" = 'inward' THEN
            sqldynamic := 'SELECT NULL::text as "hrmE_EmployeeFirstName", NULL::text as "foouT_OutwardNo", NULL::timestamp as "foouT_DateTime",
                NULL::text as "foouT_Discription", NULL::text as "foouT_From", NULL::text as "foouT_To",
                NULL::text as "foouT_Address", NULL::text as "foouT_PhoneNo", NULL::text as "foouT_EmailId",
                NULL::bigint as "foouT_DispatachedBy", NULL::text as "foouT_DispatchedThrough",
                NULL::text as "foouT_DispatchedDeatils", NULL::text as "foouT_DispatchedPhNo",
                b."FOIN_InwardNo" as "foiN_InwardNo",
                b."FOIN_DateTime" as "foiN_DateTime",
                b."FOIN_From" as "foiN_From",
                b."FOIN_Adddress" as "foiN_Adddress",
                b."FOIN_ContactPerson" as "foiN_ContactPerson",
                b."FOIN_PhoneNo" as "foiN_PhoneNo",
                b."FOIN_EmailId" as "foiN_EmailId",
                b."FOIN_Discription" as "foiN_Discription",
                (SELECT COALESCE(c."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(c."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(c."HRME_EmployeeLastName", '''') FROM "HR_Master_Employee" c WHERE c."HRME_Id" = b."FOIN_To") as "foiN_To",
                (SELECT COALESCE(d."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(d."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(d."HRME_EmployeeLastName", '''') FROM "HR_Master_Employee" d WHERE d."HRME_Id" = b."FOIN_ReceivedBy") as "foiN_ReceivedBy",
                (SELECT COALESCE(e."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(e."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(e."HRME_EmployeeLastName", '''') FROM "HR_Master_Employee" e WHERE e."HRME_Id" = b."FOIN_HandedOverTo") as "foiN_HandedOverTo"
            FROM "vm"."FO_Inward" b 
            WHERE b."MI_Id" = ' || "MI_Id"::text || ' ' || content || ' ' || content2;
        END IF;

    END IF;

    RETURN QUERY EXECUTE sqldynamic;

END;
$$;