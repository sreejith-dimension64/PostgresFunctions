CREATE OR REPLACE FUNCTION "dbo"."GET_SALES_LEAD_Report_Proc"(
    "MI_Id" VARCHAR(20),
    "catIds" TEXT,
    "soursIds" TEXT,
    "prodidss" TEXT,
    "statussidss" TEXT,
    "contryidss" TEXT,
    "stateids" TEXT,
    "searchstring" TEXT,
    "contactname" TEXT,
    "mobilesearch" TEXT,
    "emailsearch" TEXT,
    "StartDate" TIMESTAMP,
    "EndDate" TIMESTAMP
)
RETURNS TABLE(
    "ISMSLE_LeadName" VARCHAR,
    "ISMSLE_ContactPerson" VARCHAR,
    "ISMSMPR_ProductName" VARCHAR,
    "ISMSMCA_CategoryName" VARCHAR,
    "ISMSMSO_SourceName" VARCHAR,
    "ISMSMST_StatusName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "CONTENT" TEXT;
    "CONTENT1" TEXT;
    "QUERY" TEXT;
    "CONTENT3" TEXT;
    "CONTENT4" TEXT;
    "FROMDATE1" VARCHAR(50);
    "TODATE1" VARCHAR(50);
BEGIN
    SELECT TO_CHAR("StartDate", 'YYYY-MM-DD') INTO "FROMDATE1";
    SELECT TO_CHAR("EndDate", 'YYYY-MM-DD') INTO "TODATE1";

    "CONTENT1" := 'WHERE A."ISMSLE_ActiveFlag"=1 AND A."MI_Id" =' || "MI_Id" || '';

    IF ("StartDate" IS NOT NULL AND "EndDate" IS NOT NULL) THEN
        "CONTENT4" := 'AND (A."CreatedDate" BETWEEN ''' || "FROMDATE1" || ''' AND ''' || "TODATE1" || ''')';
    ELSE
        "CONTENT4" := '';
    END IF;

    IF COALESCE("prodidss", '') <> '' THEN
        "CONTENT" := 'INNER JOIN "ISM_Sales_Lead_Products" AS B ON B."ISMSLE_Id"=A."ISMSLE_Id" INNER JOIN "ISM_Sales_Master_Product" c ON b."ISMSMPR_Id"=c."ISMSMPR_Id" INNER JOIN "ISM_Sales_Master_Category" d ON a."ISMSMCA_Id"=d."ISMSMCA_Id" INNER JOIN "ISM_Sales_Master_Source" e ON a."ISMSMSO_Id"=e."ISMSMSO_Id" INNER JOIN "ISM_Sales_Master_Status" f ON a."ISMSMST_Id"=f."ISMSMST_Id" INNER JOIN "IVRM_Master_State" g ON a."IVRMMS_Id"=g."IVRMMS_Id" INNER JOIN "IVRM_Master_Country" h ON a."IVRMMC_Id"=h."IVRMMC_Id"';

        "CONTENT1" := "CONTENT1" || ' AND B."ISMSMPR_Id" IN(' || "prodidss" || ')';
    ELSE
        "CONTENT" := '';
    END IF;

    IF COALESCE("catIds", '') <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."ISMSMCA_Id" IN (' || "catIds" || ')';
    END IF;

    IF COALESCE("soursIds", '') <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."ISMSMSO_Id" IN (' || "soursIds" || ')';
    END IF;

    IF COALESCE("statussidss", '') <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."ISMSMST_Id" IN (' || "statussidss" || ')';
    END IF;

    IF COALESCE("contryidss", '') <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."IVRMMC_Id" IN (' || "contryidss" || ')';
    END IF;

    IF COALESCE("stateids", '') <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."IVRMMS_Id" IN (' || "stateids" || ')';
    END IF;

    IF COALESCE("searchstring", '') <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."ISMSLE_LeadName" LIKE ''%' || "searchstring" || '%''';
    END IF;

    IF COALESCE("contactname", '') <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."ISMSLE_ContactPerson" LIKE ''%' || "contactname" || '%''';
    END IF;

    IF COALESCE("emailsearch", '') <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."ISMSLE_EmailId" LIKE ''%' || "emailsearch" || '%''';
    END IF;

    IF COALESCE("mobilesearch", '') <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND A."ISMSLE_ContactNo" =' || "mobilesearch" || '';
    END IF;

    "QUERY" := 'SELECT DISTINCT 
A."ISMSLE_LeadName",A."ISMSLE_ContactPerson",c."ISMSMPR_ProductName",d."ISMSMCA_CategoryName", e."ISMSMSO_SourceName", f."ISMSMST_StatusName" 
FROM "ISM_Sales_Lead" AS A ' || "CONTENT" || ' ' || "CONTENT1" || ' ' || "CONTENT4" || '';

    RETURN QUERY EXECUTE "QUERY";

    RETURN;
END;
$$;