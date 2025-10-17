CREATE OR REPLACE FUNCTION "dbo"."ALUMNI_BirthdayList" (p_MI_Id bigint)
RETURNS TABLE (
    studentname TEXT,
    "ASMAY_Year" VARCHAR,
    "ALMST_AdmNo" VARCHAR,
    classname VARCHAR,
    "ALMST_MobileNo" VARCHAR,
    "ALMST_emailId" VARCHAR,
    "ALMST_DOB" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (alu."ALMST_FirstName" || ' ' || alu."ALMST_MiddleName" || ' ' || alu."ALMST_LastName") AS studentname,
        asm."ASMAY_Year",
        alu."ALMST_AdmNo",
        cla."ASMCL_ClassName" AS classname,
        alu."ALMST_MobileNo",
        alu."ALMST_emailId",
        alu."ALMST_DOB"
    FROM "ALU"."Alumni_Master_Student" alu
    INNER JOIN "Adm_School_M_Class" cla ON alu."ASMCL_Id_Left" = cla."ASMCL_Id"
    INNER JOIN "Adm_School_M_Academic_Year" asm ON alu."ASMAY_Id_Left" = asm."ASMAY_Id"
    WHERE alu."MI_Id" = p_MI_Id
        AND (EXTRACT(DAY FROM alu."ALMST_DOB") = EXTRACT(DAY FROM CURRENT_TIMESTAMP) 
        AND EXTRACT(MONTH FROM alu."ALMST_DOB") = EXTRACT(MONTH FROM CURRENT_TIMESTAMP))
    GROUP BY asm."ASMAY_Year", cla."ASMCL_ClassName", alu."ALMST_FirstName", 
             alu."ALMST_MiddleName", alu."ALMST_LastName", alu."ALMST_AdmNo", 
             alu."ALMST_MobileNo", alu."ALMST_emailId", alu."ALMST_DOB"
    ORDER BY asm."ASMAY_Year" DESC;
END;
$$;