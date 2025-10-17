CREATE OR REPLACE FUNCTION "dbo"."Fee_GroupWise_Student_List"()
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "StudentName" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "dbo"."Adm_M_Student"."AMST_Id",
        CAST("dbo"."Adm_School_Y_Student"."AMAY_RollNo" AS VARCHAR(20)) || ':' || 
        "dbo"."Adm_M_Student"."AMST_FirstName" || ' ' || 
        "dbo"."Adm_M_Student"."AMST_MiddleName" || ' ' || 
        "dbo"."Adm_M_Student"."AMST_LastName" AS "StudentName"
    FROM "dbo"."Adm_School_Y_Student"
    INNER JOIN "dbo"."Adm_M_Student" 
        ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id";
END;
$$;