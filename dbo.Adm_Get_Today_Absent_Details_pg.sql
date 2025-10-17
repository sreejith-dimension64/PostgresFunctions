CREATE OR REPLACE FUNCTION "dbo"."Adm_Get_Today_Absent_Details"(
    "p_Mi_id" TEXT,
    "p_FromDate" TEXT,
    "p_ASMAY_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT d."AMST_Id" 
    FROM "dbo"."Adm_Student_Attendance_Students" a 
    INNER JOIN "dbo"."Adm_Student_Attendance" b ON a."ASA_Id" = b."ASA_Id"
    INNER JOIN "dbo"."Adm_School_Y_Student" c ON c."AMST_Id" = a."AMST_Id"
    INNER JOIN "dbo"."Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
    WHERE d."amst_sol" = 'S' 
        AND d."AMST_ActiveFlag" = 1 
        AND c."AMAY_ActiveFlag" = 1 
        AND b."ASA_FromDate" = "p_FromDate"::DATE 
        AND a."ASA_Class_Attended" = 0.00 
        AND b."MI_Id" = "p_Mi_id" 
        AND c."ASMAY_Id" = "p_ASMAY_Id";
END;
$$;