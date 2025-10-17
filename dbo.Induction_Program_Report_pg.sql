CREATE OR REPLACE FUNCTION "dbo"."Induction_Program_Report"(
    p_MI_Id INT,
    p_ALL INT,
    p_OPEN INT,
    p_RUNNING INT,
    p_COMPLETE INT,
    p_START_DATE TIMESTAMP,
    p_END_DATE TIMESTAMP
)
RETURNS TABLE(
    "HRTCR_Id" INT,
    "HRTCR_PrgogramName" VARCHAR,
    "HRTCR_StartDate" TIMESTAMP,
    "HRTCR_EndDate" TIMESTAMP,
    "HRTCR_InternalORExternalFlg" VARCHAR,
    "HRTCR_StatusFlg" INT,
    "HRMB_BuildingName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_FROMDATE1 VARCHAR(50);
    v_TODATE1 VARCHAR(50);
BEGIN
    SELECT TO_CHAR(p_START_DATE, 'YYYY-MM-DD') INTO v_FROMDATE1;
    SELECT TO_CHAR(p_END_DATE, 'YYYY-MM-DD') INTO v_TODATE1;

    IF(p_ALL = 4) THEN
        RETURN QUERY
        SELECT 
            c."HRTCR_Id", 
            c."HRTCR_PrgogramName", 
            c."HRTCR_StartDate",
            c."HRTCR_EndDate", 
            c."HRTCR_InternalORExternalFlg", 
            c."HRTCR_StatusFlg", 
            m."HRMB_BuildingName"
        FROM "HR_Training_Create" c 
        INNER JOIN "HR_Master_Building" m ON c."HRMB_Id" = m."HRMB_Id" 
        WHERE c."MI_Id" = p_MI_Id AND c."HRTCR_ActiveFlag" = 1;

    ELSIF(p_OPEN = 1 AND p_RUNNING = 2 AND p_COMPLETE = 3) THEN
        RETURN QUERY
        SELECT 
            c."HRTCR_Id", 
            c."HRTCR_PrgogramName", 
            c."HRTCR_StartDate",
            c."HRTCR_EndDate", 
            c."HRTCR_InternalORExternalFlg", 
            c."HRTCR_StatusFlg", 
            m."HRMB_BuildingName"
        FROM "HR_Training_Create" c 
        INNER JOIN "HR_Master_Building" m ON c."HRMB_Id" = m."HRMB_Id" 
        WHERE c."MI_Id" = p_MI_Id 
        AND c."HRTCR_StatusFlg" IN(0,1,2) 
        AND c."HRTCR_StartDate" BETWEEN v_FROMDATE1::DATE AND v_TODATE1::DATE 
        AND c."HRTCR_ActiveFlag" = 1;

    ELSIF(p_OPEN = 1 AND p_RUNNING = 2) THEN
        RETURN QUERY
        SELECT 
            c."HRTCR_Id", 
            c."HRTCR_PrgogramName", 
            c."HRTCR_StartDate",
            c."HRTCR_EndDate", 
            c."HRTCR_InternalORExternalFlg", 
            c."HRTCR_StatusFlg", 
            m."HRMB_BuildingName"
        FROM "HR_Training_Create" c 
        INNER JOIN "HR_Master_Building" m ON c."HRMB_Id" = m."HRMB_Id" 
        WHERE c."MI_Id" = p_MI_Id 
        AND c."HRTCR_StatusFlg" IN(0,1) 
        AND c."HRTCR_StartDate" BETWEEN v_FROMDATE1::DATE AND v_TODATE1::DATE 
        AND c."HRTCR_ActiveFlag" = 1;

    ELSIF(p_OPEN = 1 AND p_COMPLETE = 3) THEN
        RETURN QUERY
        SELECT 
            c."HRTCR_Id", 
            c."HRTCR_PrgogramName", 
            c."HRTCR_StartDate",
            c."HRTCR_EndDate", 
            c."HRTCR_InternalORExternalFlg", 
            c."HRTCR_StatusFlg", 
            m."HRMB_BuildingName"
        FROM "HR_Training_Create" c 
        INNER JOIN "HR_Master_Building" m ON c."HRMB_Id" = m."HRMB_Id" 
        WHERE c."MI_Id" = p_MI_Id 
        AND c."HRTCR_StatusFlg" IN(0,2) 
        AND c."HRTCR_StartDate" BETWEEN v_FROMDATE1::DATE AND v_TODATE1::DATE 
        AND c."HRTCR_ActiveFlag" = 1;

    ELSIF(p_RUNNING = 2 AND p_COMPLETE = 3) THEN
        RETURN QUERY
        SELECT 
            c."HRTCR_Id", 
            c."HRTCR_PrgogramName", 
            c."HRTCR_StartDate",
            c."HRTCR_EndDate", 
            c."HRTCR_InternalORExternalFlg", 
            c."HRTCR_StatusFlg", 
            m."HRMB_BuildingName"
        FROM "HR_Training_Create" c 
        INNER JOIN "HR_Master_Building" m ON c."HRMB_Id" = m."HRMB_Id" 
        WHERE c."MI_Id" = p_MI_Id 
        AND c."HRTCR_StatusFlg" IN(2,1) 
        AND c."HRTCR_StartDate" BETWEEN v_FROMDATE1::DATE AND v_TODATE1::DATE 
        AND c."HRTCR_ActiveFlag" = 1;

    ELSIF(p_OPEN = 1) THEN
        RETURN QUERY
        SELECT 
            c."HRTCR_Id", 
            c."HRTCR_PrgogramName", 
            c."HRTCR_StartDate",
            c."HRTCR_EndDate", 
            c."HRTCR_InternalORExternalFlg", 
            c."HRTCR_StatusFlg", 
            m."HRMB_BuildingName"
        FROM "HR_Training_Create" c 
        INNER JOIN "HR_Master_Building" m ON c."HRMB_Id" = m."HRMB_Id" 
        WHERE c."MI_Id" = p_MI_Id 
        AND c."HRTCR_StatusFlg" = 0 
        AND c."HRTCR_StartDate" BETWEEN v_FROMDATE1::DATE AND v_TODATE1::DATE 
        AND c."HRTCR_ActiveFlag" = 1;

    ELSIF(p_RUNNING = 2) THEN
        RETURN QUERY
        SELECT 
            c."HRTCR_Id", 
            c."HRTCR_PrgogramName", 
            c."HRTCR_StartDate",
            c."HRTCR_EndDate", 
            c."HRTCR_InternalORExternalFlg", 
            c."HRTCR_StatusFlg", 
            m."HRMB_BuildingName"
        FROM "HR_Training_Create" c 
        INNER JOIN "HR_Master_Building" m ON c."HRMB_Id" = m."HRMB_Id" 
        WHERE c."MI_Id" = p_MI_Id 
        AND c."HRTCR_StatusFlg" = 1 
        AND c."HRTCR_StartDate" BETWEEN v_FROMDATE1::DATE AND v_TODATE1::DATE 
        AND c."HRTCR_ActiveFlag" = 1;

    ELSIF(p_COMPLETE = 3) THEN
        RETURN QUERY
        SELECT 
            c."HRTCR_Id", 
            c."HRTCR_PrgogramName", 
            c."HRTCR_StartDate",
            c."HRTCR_EndDate", 
            c."HRTCR_InternalORExternalFlg", 
            c."HRTCR_StatusFlg", 
            m."HRMB_BuildingName"
        FROM "HR_Training_Create" c 
        INNER JOIN "HR_Master_Building" m ON c."HRMB_Id" = m."HRMB_Id" 
        WHERE c."MI_Id" = p_MI_Id 
        AND c."HRTCR_StatusFlg" = 2 
        AND c."HRTCR_StartDate" BETWEEN v_FROMDATE1::DATE AND v_TODATE1::DATE 
        AND c."HRTCR_ActiveFlag" = 1;
    END IF;

    RETURN;
END;
$$;