CREATE OR REPLACE FUNCTION "dbo"."HM_Get_Student_Illness_List"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT
)
RETURNS TABLE(
    "amsT_Id" BIGINT,
    "studentName" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "b"."AMST_Id" AS "amsT_Id",
        (CASE WHEN "a"."AMST_FirstName" IS NULL THEN '' ELSE "a"."AMST_FirstName" END || 
         CASE WHEN "a"."AMST_MiddleName" IS NULL THEN '' ELSE ' ' || "a"."AMST_MiddleName" END || 
         CASE WHEN "a"."AMST_LastName" IS NULL THEN '' ELSE ' ' || "a"."AMST_LastName" END ||
         CASE WHEN "a"."AMST_AdmNo" IS NULL THEN '' ELSE ' : ' || "a"."AMST_AdmNo" END) AS "studentName"
    FROM "Adm_M_Student" AS "a"
    CROSS JOIN "HM_T_Illness" AS "b"
    WHERE "a"."AMST_Id" = "b"."AMST_Id" 
        AND "a"."MI_Id" = "@MI_Id" 
        AND "b"."ASMAY_Id" = "@ASMAY_Id";
END;
$$;