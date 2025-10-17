CREATE OR REPLACE FUNCTION "dbo"."ISM_Lead_Creation_report_pro"(
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
    "emailsearch" TEXT
)
RETURNS TABLE(
    "ISMSLE_LeadName" VARCHAR,
    "ISMSLE_ContactPerson" VARCHAR,
    "ISMSMPR_ProductName" VARCHAR,
    "ISMSMCA_CategoryName" VARCHAR,
    "ISMSMSO_SourceName" VARCHAR,
    "ISMSMST_StatusNam" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    "CONTENT" TEXT;
    "CONTENT1" TEXT;
    "QUERY" TEXT;
    "CONTENT3" TEXT;
BEGIN

    "CONTENT1" := 'WHERE "A"."ISMSLE_ActiveFlag"=1 AND "A"."MI_Id" =' || "MI_Id" || '';
    "CONTENT3" := 'AND "a"."ISMSMCA_Id"="d"."ISMSMCA_Id" AND "a"."ISMSMSO_Id"="e"."ISMSMSO_Id" AND "a"."ISMSMST_Id"="f"."ISMSMST_Id" AND "a"."IVRMMS_Id"="g"."IVRMMS_Id" AND "a"."IVRMMC_Id"="h"."IVRMMC_Id" AND "b"."ISMSMPR_Id"="c"."ISMSMPR_Id" AND "a"."MI_Id"="b"."MI_Id"';
    
    IF "prodidss" <> '' THEN
        "CONTENT" := 'INNER JOIN "ISM_Sales_Lead_Products" AS "B" ON "B"."ISMSLE_Id"="A"."ISMSLE_Id"';
        "CONTENT1" := "CONTENT1" || ' AND "B"."ISMSMPR_Id" IN(' || "prodidss" || ')';
    ELSE
        "CONTENT" := '';
    END IF;
    
    IF "catIds" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND "A"."ISMSMCA_Id" IN (' || "catIds" || ')';
    END IF;
    
    IF "soursIds" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND "A"."ISMSMSO_Id" IN (' || "soursIds" || ')';
    END IF;
    
    IF "statussidss" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND "A"."ISMSMST_Id" IN (' || "statussidss" || ')';
    END IF;
    
    IF "contryidss" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND "A"."IVRMMC_Id" IN (' || "contryidss" || ')';
    END IF;
    
    IF "stateids" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND "A"."IVRMMS_Id" IN (' || "stateids" || ')';
    END IF;
    
    IF "searchstring" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND "A"."ISMSLE_LeadName" LIKE ''%' || "searchstring" || '%''';
    END IF;
    
    IF "contactname" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND "A"."ISMSLE_ContactPerson" LIKE ''%' || "contactname" || '%''';
    END IF;
    
    IF "emailsearch" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND "A"."ISMSLE_EmailId" LIKE ''%' || "emailsearch" || '%''';
    END IF;
    
    IF "mobilesearch" <> '' THEN
        "CONTENT1" := "CONTENT1" || ' AND "A"."ISMSLE_ContactNo" =' || "mobilesearch" || '';
    END IF;
    
    "QUERY" := 'SELECT DISTINCT 
        "A"."ISMSLE_LeadName","A"."ISMSLE_ContactPerson","c"."ISMSMPR_ProductName","d"."ISMSMCA_CategoryName", "e"."ISMSMSO_SourceName","f"."ISMSMST_StatusNam"
        FROM "ISM_Sales_Master_Product" "c", "ISM_Sales_Master_Category" "d", "ISM_Sales_Master_Source" "e", "ISM_Sales_Master_Status" "f", "IVRM_Master_State" "g", "IVRM_Master_Country" "h", "ISM_Sales_Lead" AS "A" ' || "CONTENT" || ' ' || "CONTENT1" || ' ' || "CONTENT3" || ' ';
    
    RETURN QUERY EXECUTE "QUERY";
    
    RETURN;
END;
$$;