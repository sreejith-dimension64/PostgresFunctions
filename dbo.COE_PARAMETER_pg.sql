CREATE OR REPLACE FUNCTION "dbo"."COE_PARAMETER"(
    "amst_FName" VARCHAR(100),
    "template" TEXT,
    "miid" BIGINT
)
RETURNS TABLE(
    "NAME" VARCHAR(100),
    "INSTUITENAME" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "Name_Institution" INT;
    "Name" INT;
    "Templ" INT;
    "Namecount" INT;
    "InstCount" INT;
BEGIN
    SELECT POSITION('[Name]' IN "template"), POSITION('[INSTUITENAME]' IN "template")
    INTO "Namecount", "InstCount";

    IF ("Namecount" > 0 AND "InstCount" > 0) THEN
        RETURN QUERY
        SELECT 
            COALESCE("amst_FName", '')::VARCHAR(100) AS "NAME",
            COALESCE("Master_Institution"."MI_Name", '') AS "INSTUITENAME"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "Master_Institution" ON "dbo"."Adm_M_Student"."MI_Id" = "Master_Institution"."MI_Id"
        INNER JOIN "HR_Master_Employee" ON "Master_Institution"."MI_Id" = "HR_Master_Employee"."MI_Id"
        WHERE "Master_Institution"."MI_Id" = "miid"
        LIMIT 1;
        
    ELSIF ("Namecount" > 0) THEN
        RETURN QUERY
        SELECT 
            COALESCE("amst_FName", '')::VARCHAR(100) AS "NAME",
            NULL::TEXT AS "INSTUITENAME"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "Master_Institution" ON "dbo"."Adm_M_Student"."MI_Id" = "Master_Institution"."MI_Id"
        INNER JOIN "HR_Master_Employee" ON "Master_Institution"."MI_Id" = "HR_Master_Employee"."MI_Id"
        WHERE "Master_Institution"."MI_Id" = "miid"
        LIMIT 1;
        
    ELSIF ("InstCount" > 0) THEN
        RETURN QUERY
        SELECT 
            NULL::VARCHAR(100) AS "NAME",
            COALESCE("Master_Institution"."MI_Name", '') AS "INSTUITENAME"
        FROM "dbo"."Adm_M_Student"
        INNER JOIN "Master_Institution" ON "dbo"."Adm_M_Student"."MI_Id" = "Master_Institution"."MI_Id"
        INNER JOIN "HR_Master_Employee" ON "Master_Institution"."MI_Id" = "HR_Master_Employee"."MI_Id"
        WHERE "Master_Institution"."MI_Id" = "miid"
        LIMIT 1;
    END IF;

    RETURN;
END;
$$;