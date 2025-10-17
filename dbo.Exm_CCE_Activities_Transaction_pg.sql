CREATE OR REPLACE FUNCTION "dbo"."Exm_CCE_Activities_Transaction"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "AMST_Id" TEXT
)
RETURNS TABLE(
    "AMST_Id" INTEGER,
    "ECACT_SkillName" VARCHAR,
    "EMGR_Id" INTEGER,
    "EME_Id" INTEGER,
    "ECSACTT_Score" NUMERIC,
    "EMGD_Name" VARCHAR,
    "EME_ExamName" VARCHAR,
    "ECACT_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "SQLQUERY" TEXT;
BEGIN
    "SQLQUERY" := 'SELECT b."AMST_Id", a."ECACT_SkillName", b."EMGR_Id", b."EME_Id", b."ECSACTT_Score",
(SELECT "EMGD_Name" FROM "Exm"."Exm_Master_Grade_Details" WHERE b."ECSACTT_Score"
 BETWEEN "EMGD_From" AND "EMGD_To" AND "EMGR_Id" = b."EMGR_Id") AS "EMGD_Name", c."EME_ExamName", a."ECACT_Id"
FROM "exm"."Exm_CCE_Activities" a
INNER JOIN "exm"."Exm_CCE_Activities_Transaction" b ON a."ECACT_Id" = b."ECACT_Id"
INNER JOIN "Exm"."Exm_Master_Exam" c ON c."EME_Id" = b."EME_Id"
WHERE b."MI_Id" = ' || "MI_Id" || ' AND b."ASMAY_Id" = ' || "ASMAY_Id" || ' AND b."ASMCL_Id" = ' || "ASMCL_Id" || ' AND b."ASMS_Id" = ' || "ASMS_Id" || ' AND b."AMST_Id" IN (' || "AMST_Id" || ')';
    
    RAISE NOTICE '%', "SQLQUERY";
    
    RETURN QUERY EXECUTE "SQLQUERY";
END;
$$;