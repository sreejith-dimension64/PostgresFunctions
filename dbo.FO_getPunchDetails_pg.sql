CREATE OR REPLACE FUNCTION "dbo"."FO_getPunchDetails"(
    p_FOEP_PunchDate TIMESTAMP,
    p_FOEPD_PunchTime VARCHAR(50),
    p_HRME_Id BIGINT,
    p_MI_Id BIGINT
)
RETURNS TABLE(
    "FOEPD_Id" BIGINT,
    "FOEPD_InOutFlg" VARCHAR,
    "FOEPD_PunchTime" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "FOEPD_Id", 
        "FOEPD_InOutFlg", 
        TO_CHAR("FOEPD_PunchTime", 'YYYY-MM-DD HH24:MI:SS') AS "FOEPD_PunchTime" 
    FROM "FO"."FO_Emp_Punch_Details" 
    WHERE TO_CHAR("FOEPD_PunchTime", 'MM/DD/YYYY') = TO_CHAR(TO_TIMESTAMP(p_FOEPD_PunchTime, 'MM/DD/YYYY'), 'MM/DD/YYYY')
    AND "FOEP_Id" IN (
        SELECT "FOEP_Id" 
        FROM "fo"."FO_Emp_Punch"  
        WHERE CAST("FOEP_PunchDate" AS DATE) = CAST(p_FOEP_PunchDate AS DATE) 
        AND "HRME_Id" = p_HRME_Id 
        AND "MI_ID" = p_MI_Id
    );
END;
$$;