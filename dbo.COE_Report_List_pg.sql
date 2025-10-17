CREATE OR REPLACE FUNCTION "dbo"."COE_Report_List"(
    p_AMST_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_MI_Id bigint,
    p_monthid bigint
)
RETURNS TABLE(
    "COEME_Id" bigint,
    "coemE_EventName" VARCHAR,
    "coemE_EventDesc" TEXT,
    "coeE_EStartDate" TIMESTAMP,
    "coeE_EEndDate" TIMESTAMP,
    "coeeI_Images" TEXT,
    "coeeV_Videos" TEXT,
    "coeE_EStartTime" TIME,
    "coeE_EEndTime" TIME,
    "asmaY_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        a."COEME_Id", 
        a."COEME_EventName" AS "coemE_EventName",
        a."COEME_EventDesc" AS "coemE_EventDesc",
        b."COEE_EStartDate" AS "coeE_EStartDate",
        b."COEE_EEndDate" AS "coeE_EEndDate",
        f."COEEI_Images" AS "coeeI_Images",
        g."COEEV_Videos" AS "coeeV_Videos",
        b."COEE_EStartTime" AS "coeE_EStartTime",
        b."COEE_EEndTime" AS "coeE_EEndTime",
        b."ASMAY_Id" AS "asmaY_Id"
    FROM "COE"."COE_Master_Events" a
    INNER JOIN "COE"."COE_Events" b ON a."COEME_Id" = b."COEME_Id"
    INNER JOIN "Adm_School_Y_Student" c ON b."ASMAY_Id" = c."ASMAY_Id"
    INNER JOIN "Adm_M_Student" d ON c."AMST_Id" = d."AMST_Id"
    LEFT JOIN "COE"."COE_Events_Classes" e ON b."COEE_Id" = e."COEE_Id"
    LEFT JOIN "COE"."COE_Events_Images" f ON f."COEE_Id" = b."COEE_Id"
    LEFT JOIN "COE"."COE_Events_Videos" g ON g."COEE_Id" = b."COEE_Id"
    WHERE c."AMST_Id" = p_AMST_Id 
        AND b."ASMAY_Id" = p_ASMAY_Id 
        AND c."AMST_Id" = d."AMST_Id"
        AND c."ASMCL_Id" = p_ASMCL_Id 
        AND a."MI_Id" = p_MI_Id 
        AND EXTRACT(MONTH FROM b."COEE_EStartDate") = p_monthid;
END;
$$;