CREATE OR REPLACE FUNCTION "dbo"."CLG_COEREPORT"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMCO_Ids VARCHAR(100),
    p_month BIGINT,
    p_typeflag VARCHAR(10)
)
RETURNS TABLE (
    "COEME_Id" BIGINT,
    "AMCO_Id" BIGINT,
    "AMCO_CourseName" VARCHAR,
    "COEME_EventName" VARCHAR,
    "COEME_EventDesc" VARCHAR,
    "COEE_EStartDate" TIMESTAMP,
    "COEE_EEndDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Slqdymaic TEXT;
BEGIN
    IF (p_typeflag = 'M') THEN
        RETURN QUERY
        SELECT DISTINCT
            a."COEME_Id",
            NULL::BIGINT AS "AMCO_Id",
            NULL::VARCHAR AS "AMCO_CourseName",
            a."COEME_EventName",
            a."COEME_EventDesc",
            b."COEE_EStartDate",
            b."COEE_EEndDate"
        FROM
            "COE"."COE_Master_Events" a,
            "COE"."COE_Events" b
        WHERE a."COEME_Id" = b."COEME_Id" 
            AND b."MI_Id" = p_MI_Id 
            AND b."ASMAY_Id" = p_ASMAY_Id 
            AND (EXTRACT(MONTH FROM b."COEE_EStartDate") = p_month)
        ORDER BY a."COEME_Id";
        
    ELSIF (p_typeflag = 'C') THEN
        v_Slqdymaic := 'SELECT DISTINCT
            a."COEME_Id",
            d."AMCO_Id",
            d."AMCO_CourseName",
            a."COEME_EventName",
            a."COEME_EventDesc",
            b."COEE_EStartDate",
            b."COEE_EEndDate"
        FROM
            "COE"."COE_Master_Events" a,
            "COE"."COE_Events" b,
            "COE"."COE_Events_CourseBranch" c,
            "CLG"."Adm_Master_Course" d
        WHERE a."COEME_Id" = b."COEME_Id" 
            AND b."COEE_Id" = c."COEE_Id" 
            AND c."AMCO_Id" = d."AMCO_Id" 
            AND b."MI_Id" = ' || p_MI_Id || ' 
            AND b."ASMAY_Id" = ' || p_ASMAY_Id || '  
            AND c."AMCO_Id" IN (' || p_AMCO_Ids || ')
        ORDER BY a."COEME_Id"';
        
        RETURN QUERY EXECUTE v_Slqdymaic;
    END IF;
    
    RETURN;
END;
$$;