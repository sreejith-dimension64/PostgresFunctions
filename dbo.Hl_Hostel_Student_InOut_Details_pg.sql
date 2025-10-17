CREATE OR REPLACE FUNCTION "Hl_Hostel_Student_InOut_Details"(
    p_AMCST_Id TEXT,
    p_fromdate TEXT,
    p_todate TEXT
)
RETURNS TABLE(
    "AMCST_Id" VARCHAR,
    "StudentName" TEXT,
    "HLHSTBIO_PunchDate" TIMESTAMP,
    "Intime" TIME,
    "Outtime" TIME
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
    v_Inflg VARCHAR(10);
    v_outflg VARCHAR(10);
BEGIN
    v_Inflg := 'I';
    v_outflg := 'O';
    
    v_sql := '
    SELECT a."AMCST_Id",
           CONCAT(COALESCE(b."AMCST_FirstName",''''),'' '',COALESCE(b."AMCST_MiddleName",''''),'' '',COALESCE(b."AMCST_LastName",'''')) as "StudentName",
           a."HLHSTBIO_PunchDate",
           g."HLHSTBIOD_PunchTime" as "Intime",
           h."HLHSTBIOD_PunchTime" as "Outtime"
    FROM "HL_Hostel_Student_Biometric" a 
    INNER JOIN "clg"."Adm_Master_College_Student" b
        ON a."AMCST_Id" = b."AMCST_Id" AND b."AMCST_ActiveFlag" = TRUE
    INNER JOIN "HL_Hostel_Student_Biometric_Details" g 
        ON g."HLHSTBIO_Id" = a."HLHSTBIO_Id"
    INNER JOIN "HL_Hostel_Student_Biometric_Details" h 
        ON h."HLHSTBIO_Id" = a."HLHSTBIO_Id"
    WHERE a."AMCST_Id" IN (' || p_AMCST_Id || ') 
        AND CAST(a."HLHSTBIO_PunchDate" AS DATE) BETWEEN ''' || p_fromdate || ''' AND ''' || p_todate || '''
        AND g."HLHSTBIOD_InOutFlg" = ''' || v_Inflg || '''
        AND h."HLHSTBIOD_InOutFlg" = ''' || v_outflg || '''';
    
    RETURN QUERY EXECUTE v_sql;
END;
$$;