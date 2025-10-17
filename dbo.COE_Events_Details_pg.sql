CREATE OR REPLACE FUNCTION "dbo"."COE_Events_Details"(
    "@mi_id" bigint,
    "@amst_id" bigint,
    "@asmay_id" bigint,
    "@asmcl_id" bigint,
    "@month_id" bigint
)
RETURNS TABLE(
    "coemE_Id" bigint,
    "coemE_EventName" text,
    "coemE_EventDesc" text,
    "coeE_Id" bigint,
    "coeE_EStartDate" timestamp,
    "coeE_EEndDate" timestamp,
    "coeE_EStartTime" time,
    "coeE_EEndTimed" time,
    "coeeI_Images" text
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."COEME_Id" AS "coemE_Id",
        a."COEME_EventName" AS "coemE_EventName",
        a."COEME_EventDesc" AS "coemE_EventDesc",
        b."COEE_Id" AS "coeE_Id",
        b."COEE_EStartDate" AS "coeE_EStartDate",
        b."COEE_EEndDate" AS "coeE_EEndDate",
        b."COEE_EStartTime" AS "coeE_EStartTime",
        b."COEE_EEndTime" AS "coeE_EEndTimed",
        f."COEEI_Images" AS "coeeI_Images"
    FROM "coe"."COE_Master_Events" a 
    INNER JOIN "coe"."COE_Events" b ON a."COEME_Id" = b."COEME_Id"
    INNER JOIN "Adm_School_Y_Student" c ON c."ASMAY_Id" = b."ASMAY_Id"
    INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
    INNER JOIN "coe"."COE_Events_Classes" e ON e."COEE_Id" = b."COEE_Id"
    LEFT JOIN "coe"."COE_Events_Images" f ON f."COEE_Id" = b."COEE_Id"
    WHERE a."mi_id" = "@mi_id" 
        AND b."ASMAY_Id" = "@asmay_id" 
        AND c."ASMCL_Id" = "@asmcl_id" 
        AND b."COEE_ActiveFlag" = 1 
        AND c."AMST_Id" = "@amst_id"
        AND EXTRACT(MONTH FROM b."COEE_EStartDate") = "@month_id"
    ORDER BY "coeE_EStartDate";
    
    RETURN;
END;
$$;