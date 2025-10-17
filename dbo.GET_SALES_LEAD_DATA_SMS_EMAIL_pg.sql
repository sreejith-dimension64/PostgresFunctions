CREATE OR REPLACE FUNCTION "dbo"."GET_SALES_LEAD_DATA_SMS_EMAIL"(
    "MI_Id" varchar(20),
    "catIds" text,
    "soursIds" text,
    "prodidss" text,
    "statussidss" text,
    "contryidss" text,
    "stateids" text,
    "searchstring" text,
    "contactname" text,
    "mobilesearch" text,
    "emailsearch" text
)
RETURNS TABLE(
    "ISMSLE_Id" INTEGER,
    "ISMSLE_LeadName" VARCHAR,
    "ISMSLE_ContactPerson" VARCHAR,
    "ISMSLE_ContactNo" VARCHAR,
    "ISMSLE_EmailId" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "CONTENT" TEXT;
    "CONTENT1" TEXT;
    "QUERY" TEXT;
BEGIN

    "CONTENT1" := 'WHERE A."ISMSLE_ActiveFlag"=1 AND A."MI_Id" =' || "MI_Id" || '';
    
    IF "prodidss" <> '' THEN
        "CONTENT" := 'INNER JOIN  "ISM_Sales_Lead_Products" AS B ON B."ISMSLE_Id"=A."ISMSLE_Id"';
        "CONTENT1" := "CONTENT1" || ' AND B."ISMSMPR_Id" IN(' || "prodidss" || ')';
    ELSE
        "CONTENT" := '';
    END IF;
    
    IF "catIds" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."ISMSMCA_Id" IN (' || "catIds" || ')';
    END IF;
    
    IF "soursIds" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."ISMSMSO_Id" IN (' || "soursIds" || ')';
    END IF;
    
    IF "statussidss" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."ISMSMST_Id" IN (' || "statussidss" || ')';
    END IF;
    
    IF "contryidss" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."IVRMMC_Id" IN (' || "contryidss" || ')';
    END IF;
    
    IF "stateids" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."IVRMMS_Id" IN (' || "stateids" || ')';
    END IF;
    
    IF "searchstring" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."ISMSLE_LeadName" LIKE ''%' || "searchstring" || '%''';
    END IF;
    
    IF "contactname" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."ISMSLE_ContactPerson" LIKE ''%' || "contactname" || '%''';
    END IF;
    
    IF "emailsearch" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."ISMSLE_EmailId" LIKE ''%' || "emailsearch" || '%''';
    END IF;
    
    IF "mobilesearch" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."ISMSLE_ContactNo" =' || "mobilesearch" || '';
    END IF;
    
    "QUERY" := 'SELECT DISTINCT A."ISMSLE_Id", A."ISMSLE_LeadName", A."ISMSLE_ContactPerson", A."ISMSLE_ContactNo", A."ISMSLE_EmailId" FROM "ISM_Sales_Lead" AS A ' || "CONTENT" || ' ' || "CONTENT1" || ' ';
    
    RETURN QUERY EXECUTE "QUERY";
    
END;
$$;