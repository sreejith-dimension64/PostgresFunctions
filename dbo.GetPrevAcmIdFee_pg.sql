CREATE OR REPLACE FUNCTION "dbo"."GetPrevAcmIdFee" (
    "p_Acm_id" bigint,
    OUT "p_Acmid" bigint
)
RETURNS bigint
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Amy_id1" bigint;
    "v_Amy_id" bigint;
    "v_Amc_id" bigint;
BEGIN
    SELECT "Amay_id" INTO "v_Amy_id" 
    FROM "Adm_cat_module" 
    WHERE "acm_id" = "p_Acm_id";
    
    SELECT * INTO "v_Amy_id1" 
    FROM "dbo"."GetPrevAmayId"("v_Amy_id");
    
    SELECT "dbo"."Adm_T_Cat_Module"."AMC_ID" INTO "v_Amc_id"
    FROM "dbo"."Adm_Cat_Module" 
    INNER JOIN "dbo"."Adm_T_Cat_Module" 
        ON "dbo"."Adm_Cat_Module"."ACM_Id" = "dbo"."Adm_T_Cat_Module"."ACM_Id" 
    INNER JOIN "dbo"."Adm_M_Category" 
        ON "dbo"."Adm_T_Cat_Module"."AMC_ID" = "dbo"."Adm_M_Category"."AMC_Id" 
    INNER JOIN "dbo"."Am_Module" 
        ON "dbo"."Adm_Cat_Module"."AM_ID" = 4 
        AND "dbo"."Adm_Cat_Module"."ACM_Id" = "p_Acm_id" 
        AND "dbo"."Adm_Cat_Module"."amay_id" = "v_Amy_id";
    
    SELECT "dbo"."Adm_Cat_Module"."ACM_Id" INTO "p_Acmid"
    FROM "dbo"."Adm_Cat_Module" 
    INNER JOIN "dbo"."Adm_T_Cat_Module" 
        ON "dbo"."Adm_Cat_Module"."ACM_Id" = "dbo"."Adm_T_Cat_Module"."ACM_Id" 
    INNER JOIN "dbo"."Adm_M_Category" 
        ON "dbo"."Adm_T_Cat_Module"."AMC_ID" = "dbo"."Adm_M_Category"."AMC_Id" 
    INNER JOIN "dbo"."Am_Module" 
        ON "dbo"."Adm_Cat_Module"."AM_ID" = 4 
        AND "dbo"."Adm_T_Cat_Module"."AMC_ID" IN (
            SELECT "amc_id" 
            FROM "adm_t_cat_module" 
            WHERE "acm_id" = "p_Acm_id"
        ) 
        AND "dbo"."Adm_Cat_Module"."amay_id" = "v_Amy_id1";
    
    RETURN;
END;
$$;