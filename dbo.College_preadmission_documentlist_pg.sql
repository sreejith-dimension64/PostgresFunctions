CREATE OR REPLACE FUNCTION "dbo"."College_preadmission_documentlist"(
    "MI_Id" TEXT,
    "PACA_Id" TEXT,
    "status" TEXT,
    "ASMAY_Id" TEXT
)
RETURNS TABLE(
    "paca_id" BIGINT,
    "stu_cnt" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "sql" TEXT;
BEGIN
    "sql" := 'SELECT DISTINCT a."paca_id",
                (SELECT COUNT("paca_id") 
                 FROM "clg"."PA_College_Student_Documents" 
                 WHERE a."paca_id" = "paca_id") AS "stu_cnt" 
              FROM "clg"."pa_college_application" a 
              LEFT JOIN "clg"."PA_College_Student_Documents" b ON a."paca_id" = b."paca_id"
              LEFT JOIN "Adm_m_School_Master_Documents" c ON b."amsmd_id" = c."amsmd_id" 
              WHERE a."paca_id" IN (' || "PACA_Id" || ') 
                AND a."asmay_id" = ' || "ASMAY_Id" || ' 
                AND a."mi_id" = ' || "MI_Id";

    RETURN QUERY EXECUTE "sql";
END;
$$;