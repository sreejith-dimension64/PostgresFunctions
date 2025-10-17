CREATE OR REPLACE FUNCTION "dbo"."FO_getStudentPunchDetails"(
    "ASPU_PunchDate" TIMESTAMP,
    "ASPUD_PunchTime" VARCHAR(50),
    "AMST_Id" BIGINT,
    "MI_Id" BIGINT
)
RETURNS TABLE(
    "ASPUD_Id" BIGINT,
    "ASPUD_InOutFlg" VARCHAR,
    "ASPUD_PunchTime" VARCHAR(20)
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "Adm_Student_Punch_Details"."ASPUD_Id", 
        "Adm_Student_Punch_Details"."ASPUD_InOutFlg", 
        TO_CHAR("Adm_Student_Punch_Details"."ASPUD_PunchTime", 'YYYY-MM-DD HH24:MI:SS')::VARCHAR(20) AS "ASPUD_PunchTime"
    FROM "dbo"."Adm_Student_Punch_Details"
    WHERE "Adm_Student_Punch_Details"."ASPUD_PunchTime"::DATE = TO_DATE("ASPUD_PunchTime", 'MM/DD/YYYY')
    AND "Adm_Student_Punch_Details"."ASPU_Id" IN (
        SELECT "Adm_Student_Punch"."ASPU_Id" 
        FROM "dbo"."Adm_Student_Punch" 
        WHERE "Adm_Student_Punch"."ASPU_PunchDate"::DATE = "ASPU_PunchDate"::DATE 
        AND "Adm_Student_Punch"."AMST_Id" = "AMST_Id" 
        AND "Adm_Student_Punch"."MI_ID" = "MI_Id"
    );
END;
$$;