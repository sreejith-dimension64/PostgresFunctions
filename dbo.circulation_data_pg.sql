CREATE OR REPLACE FUNCTION "dbo"."circulation_data" (
    "MI_Id" TEXT,
    "type" TEXT
)
RETURNS TABLE (
    "pk_id" BIGINT,
    "LMC_CategoryName" TEXT,
    "reflag" TEXT,
    "Issue" INTEGER,
    "items" INTEGER,
    "renewal" INTEGER,
    "activeflg" BOOLEAN,
    "flgtype" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "type" = 'BP' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "LBCPAS_Id"::BIGINT AS "pk_id",
            "LMC_CategoryName"::TEXT,
            "LBCPA_IssueRefFlg"::TEXT AS "reflag",
            "LBCPAS_IssueDays" AS "Issue",
            "LBCPAS_NoOfItems" AS "items",
            "LBCPAS_NoOfRenewals" AS "renewal",
            "LBCPAS_ActiveFlg" AS "activeflg",
            "LBCPA_Flg"::TEXT AS "flgtype"
        FROM "lib"."LIB_Circulation_Parameter_Student" 
        INNER JOIN "lib"."LIB_Book_Circulation_Parameter" ON 
            "lib"."LIB_Book_Circulation_Parameter"."LBCPA_Id" = "lib"."LIB_Circulation_Parameter_Student"."LBCPA_Id"
        INNER JOIN "lib"."LIB_Master_Category" ON 
            "lib"."LIB_Master_Category"."LMC_CategoryName" = "lib"."LIB_Book_Circulation_Parameter"."LBCPA_IssueRefFlg"
        WHERE "lib"."LIB_Book_Circulation_Parameter"."MI_Id" = "MI_Id"
        
        UNION ALL
        
        SELECT DISTINCT 
            "LBCPAO_Id"::BIGINT AS "pk_id",
            "LMC_CategoryName"::TEXT,
            "LBCPA_IssueRefFlg"::TEXT,
            "LBCPAO_IssueDays" AS "Issue",
            "LBCPAO_NoOfItems" AS "items",
            "LBCPAO_NoOfRenewals" AS "renewal",
            "LBCPA_ActiveFlg" AS "activeflg",
            "LBCPA_Flg"::TEXT AS "flgtype"
        FROM "lib"."LIB_Circulation_Parameter_Others" 
        INNER JOIN "lib"."LIB_Book_Circulation_Parameter" ON 
            "lib"."LIB_Book_Circulation_Parameter"."LBCPA_Id" = "lib"."LIB_Circulation_Parameter_Others"."LBCPA_Id"
        INNER JOIN "lib"."LIB_Master_Category" ON 
            "lib"."LIB_Master_Category"."LMC_CategoryName" = "lib"."LIB_Book_Circulation_Parameter"."LBCPA_IssueRefFlg"
        WHERE "lib"."LIB_Book_Circulation_Parameter"."MI_Id" = "MI_Id"
        
        UNION ALL
        
        SELECT DISTINCT 
            "LBCPAST_Id"::BIGINT AS "pk_id",
            "LMC_CategoryName"::TEXT,
            "LBCPA_IssueRefFlg"::TEXT,
            "LBCPAST_IssueDays" AS "Issue",
            "LBCPAST_NoOfItems" AS "items",
            "LBCPAST_NoOfRenewals" AS "renewal",
            "LBCPA_ActiveFlg" AS "activeflg",
            "LBCPA_Flg"::TEXT AS "flgtype"
        FROM "lib"."LIB_Circulation_Parameter_Staff" 
        INNER JOIN "lib"."LIB_Book_Circulation_Parameter" ON 
            "lib"."LIB_Book_Circulation_Parameter"."LBCPA_Id" = "lib"."LIB_Circulation_Parameter_Staff"."LBCPA_Id"
        INNER JOIN "lib"."LIB_Master_Category" ON 
            "lib"."LIB_Master_Category"."LMC_CategoryName" = "lib"."LIB_Book_Circulation_Parameter"."LBCPA_IssueRefFlg"
        WHERE "lib"."LIB_Book_Circulation_Parameter"."MI_Id" = "MI_Id";
    ELSE
        RETURN QUERY
        SELECT DISTINCT 
            "LNBCPAS_Id"::BIGINT AS "pk_id",
            "LMC_CategoryName"::TEXT,
            NULL::TEXT AS "reflag",
            "LNBCPAS_IssueDays" AS "Issue",
            "LNBCPAS_NoOfItems" AS "items",
            "LNBCPAS_NoOfRenewals" AS "renewal",
            "LNBCPAS_ActiveFlg" AS "activeflg",
            "LNBCPA_Flg"::TEXT AS "flgtype"
        FROM "lib"."LIB_NonBook_Circulation_Parameter_Student" 
        INNER JOIN "lib"."LIB_NonBook_Circulation_Parameter" ON 
            "lib"."LIB_NonBook_Circulation_Parameter"."LNBCPA_Id" = "lib"."LIB_NonBook_Circulation_Parameter_Student"."LNBCPA_Id"
        INNER JOIN "lib"."LIB_Master_Category" ON 
            "lib"."LIB_Master_Category"."LMC_Id" = "lib"."LIB_NonBook_Circulation_Parameter_Student"."LMC_Id"
        WHERE "lib"."LIB_NonBook_Circulation_Parameter"."MI_Id" = "MI_Id"
        
        UNION ALL
        
        SELECT DISTINCT 
            "LNBCPAO_Id"::BIGINT AS "pk_id",
            "LMC_CategoryName"::TEXT,
            NULL::TEXT,
            "LNBCPAO_IssueDays" AS "Issue",
            "LNBCPAO_NoOfItems" AS "items",
            "LNBCPAO_NoOfRenewals" AS "renewal",
            "LNBCPA_ActiveFlg" AS "activeflg",
            "LNBCPA_Flg"::TEXT AS "flgtype"
        FROM "lib"."LIB_NonBook_Circulation_Parameter_Others" 
        INNER JOIN "lib"."LIB_NonBook_Circulation_Parameter" ON 
            "lib"."LIB_NonBook_Circulation_Parameter"."LNBCPA_Id" = "lib"."LIB_NonBook_Circulation_Parameter_Others"."LNBCPA_Id"
        INNER JOIN "lib"."LIB_Master_Category" ON 
            "lib"."LIB_Master_Category"."LMC_Id" = "lib"."LIB_NonBook_Circulation_Parameter_Others"."LMC_Id"
        WHERE "lib"."LIB_NonBook_Circulation_Parameter"."MI_Id" = "MI_Id"
        
        UNION ALL
        
        SELECT DISTINCT 
            "LNBCPAST_Id"::BIGINT AS "pk_id",
            "LMC_CategoryName"::TEXT,
            NULL::TEXT,
            "LNBCPAST_IssueDays" AS "Issue",
            "LNBCPAST_NoOfItems" AS "items",
            "LNBCPAST_NoOfRenewals" AS "renewal",
            "LNBCPA_ActiveFlg" AS "activeflg",
            "LNBCPA_Flg"::TEXT AS "flgtype"
        FROM "lib"."LIB_NonBook_Circulation_Parameter_Staff" 
        INNER JOIN "lib"."LIB_NonBook_Circulation_Parameter" ON 
            "lib"."LIB_NonBook_Circulation_Parameter"."LNBCPA_Id" = "lib"."LIB_NonBook_Circulation_Parameter_Staff"."LNBCPA_Id"
        INNER JOIN "lib"."LIB_Master_Category" ON 
            "lib"."LIB_Master_Category"."LMC_Id" = "lib"."LIB_NonBook_Circulation_Parameter_Staff"."LMC_Id"
        WHERE "lib"."LIB_NonBook_Circulation_Parameter"."MI_Id" = "MI_Id";
    END IF;

END;
$$;