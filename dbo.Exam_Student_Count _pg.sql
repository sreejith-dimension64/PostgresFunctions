CREATE OR REPLACE FUNCTION "dbo"."Exam_Student_Count"(@ASMAY_ID TEXT)
RETURNS TABLE(
    "ASMCL_ID" INTEGER,
    "ASMS_Id" INTEGER,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "studentcount" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN 
    RETURN QUERY
    SELECT DISTINCT 
        D."ASMCL_ID",
        D."ASMS_Id",
        b."ASMCL_ClassName",
        c."ASMC_SectionName",
        COUNT(D."AMST_ID") AS studentcount
    FROM "Adm_School_Y_Student" D
    INNER JOIN "Adm_M_Student" A ON A."AMST_Id" = D."AMST_Id"
    INNER JOIN "Adm_School_M_Class" B ON B."ASMCL_Id" = D."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" C ON C."ASMS_Id" = D."ASMS_Id"
    WHERE D."ASMAY_Id" = @ASMAY_ID
    GROUP BY D."ASMCL_ID", D."ASMS_Id", b."ASMCL_ClassName", c."ASMC_SectionName";
END;
$$;