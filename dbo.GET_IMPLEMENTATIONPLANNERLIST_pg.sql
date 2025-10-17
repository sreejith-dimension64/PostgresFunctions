CREATE OR REPLACE FUNCTION "dbo"."GET_IMPLEMENTATIONPLANNERLIST" (
    "MI_Id" BIGINT,
    "ISMMIMPPL_Id" BIGINT
)
RETURNS TABLE (
    "ISMIMPPL_Id" BIGINT,
    "MI_Id" BIGINT,
    "ISMIMPPL_ActivityName" TEXT,
    "IVRMM_Id" BIGINT,
    "ISMIMPPL_Periodicity" TEXT,
    "ISMIMPPL_Remarks" TEXT,
    "ISMIMPPL_TimeRequired" TEXT,
    "ISMIMPPL_CreatedDate" TIMESTAMP,
    "ISMIMPPL_TimeRequiredFlg" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "Slqdymaic" TEXT;
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "A"."ISMIMPPL_Id",
        "A"."MI_Id",
        "A"."ISMIMPPL_ActivityName",
        "A"."IVRMM_Id",
        "A"."ISMIMPPL_Periodicity",
        "A"."ISMIMPPL_Remarks",
        "A"."ISMIMPPL_TimeRequired",
        "A"."ISMIMPPL_CreatedDate",
        "A"."ISMIMPPL_TimeRequiredFlg"
    FROM "ISM_Implementation_Planner" AS "A"
    LEFT JOIN "IVRM_Module" AS "B" ON "A"."IVRMM_Id" = "B"."IVRMM_Id"
    WHERE "A"."ISMIMPPL_ActiveFlg" = 1 
        AND "B"."Module_ActiveFlag" = 1 
        AND "A"."ISMMIMPPL_Id" = "ISMMIMPPL_Id"
    ORDER BY "A"."ISMIMPPL_CreatedDate";
    
    RETURN;
END;
$$;