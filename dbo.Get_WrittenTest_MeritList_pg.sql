CREATE OR REPLACE FUNCTION "dbo"."Get_WrittenTest_MeritList"(
    "@ASMAY_Id" INTEGER,
    "@Mi_id" BIGINT
)
RETURNS TABLE(
    "PASR_Id" BIGINT,
    "PASR_FirstName" TEXT,
    "PASR_MiddleName" TEXT,
    "PASR_LastName" TEXT,
    "PASR_TotalMarksScored" NUMERIC,
    "PASR_Status" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."PASR_Id", 
        b."PASR_FirstName",
        b."PASR_MiddleName",
        b."PASR_LastName",
        a."PASR_TotalMarksScored",
        a."PASR_Status"
    FROM 
        "Preadmission_Written_Marks_Students" a 
        INNER JOIN "Preadmission_School_Registration" b ON a."pasr_id" = b."pasr_id" 
    WHERE 
        b."MI_Id" = "@Mi_id"
        AND b."ASMAY_Id" = "@ASMAY_Id" 
    ORDER BY 
        a."PASR_TotalMarksScored" DESC;
END;
$$;