CREATE OR REPLACE FUNCTION "dbo"."CLGCOE_PARAMETER"(
    "amst_FName" VARCHAR(100),
    "template" VARCHAR(200),
    "miid" BIGINT
)
RETURNS TABLE(
    "[NAME]" VARCHAR(100),
    "[INSTUITENAME]" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "miid" = 6 THEN
        RETURN QUERY
        SELECT 
            COALESCE("amst_FName", '')::VARCHAR(100) AS "[NAME]",
            COALESCE("Master_Institution"."MI_Name", '') AS "[INSTUITENAME]"
        FROM "clg"."Adm_Master_College_Student"
        INNER JOIN "Master_Institution" ON "clg"."Adm_Master_College_Student"."MI_Id" = "Master_Institution"."MI_Id"
        INNER JOIN "HR_Master_Employee" ON "Master_Institution"."MI_Id" = "HR_Master_Employee"."MI_Id"
        WHERE "Master_Institution"."MI_Id" = "miid"
        LIMIT 1;
    ELSE
        RETURN QUERY
        SELECT 
            COALESCE("amst_FName", '')::VARCHAR(100) AS "[NAME]",
            COALESCE("Master_Institution"."MI_Name", '') AS "[INSTUITENAME]"
        FROM "clg"."Adm_Master_College_Student"
        INNER JOIN "Master_Institution" ON "clg"."Adm_Master_College_Student"."MI_Id" = "Master_Institution"."MI_Id"
        INNER JOIN "HR_Master_Employee" ON "Master_Institution"."MI_Id" = "HR_Master_Employee"."MI_Id"
        WHERE "Master_Institution"."MI_Id" = "miid"
        LIMIT 1;
    END IF;
END;
$$;