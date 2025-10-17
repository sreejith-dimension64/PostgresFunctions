CREATE OR REPLACE FUNCTION "dbo"."Admission_StudentListSearch" (
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "searchfilter" TEXT,
    "AMST_SOL" VARCHAR(50),
    "activeflagyear" INT
)
RETURNS TABLE (
    "studentName" TEXT,
    "AMST_FirstName" TEXT,
    "AMST_MiddleName" TEXT,
    "AMST_LastName" TEXT,
    "amsT_Id" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "dynamic" TEXT;
BEGIN

    "dynamic" := '
    
    SELECT * FROM (
        SELECT DISTINCT 
            COALESCE("AMST_FirstName", '''') || '' '' || COALESCE("AMST_MiddleName", '''') || '' '' || COALESCE("AMST_LastName", '''') || '' : '' || b."amsT_AdmNo" AS "studentName",
            COALESCE("AMST_FirstName", '''') AS "AMST_FirstName",
            '' '' || COALESCE("AMST_MiddleName", '''') AS "AMST_MiddleName",
            COALESCE("AMST_LastName", '''') AS "AMST_LastName",
            b."amsT_Id"
        FROM "Adm_School_Y_Student" a 
        INNER JOIN "Adm_M_Student" b ON A."AMST_Id" = b."AMST_Id" 
        WHERE B."MI_Id" = ' || "MI_Id"::VARCHAR || ' 
            AND B."AMST_SOL" = ''' || "AMST_SOL" || ''' 
            AND a."ASMAY_Id" = ' || "ASMAY_Id"::VARCHAR || ' 
            AND b."AMST_ActiveFlag" = ' || "activeflagyear"::VARCHAR || '
    ) "New"   
    WHERE (CASE WHEN LENGTH("studentName") > 0 THEN TRIM(REPLACE("studentName", '' '', ''''))
            ELSE TRIM(REPLACE("studentName", '' '', '''')) END LIKE ''%'' || 
            CASE WHEN LENGTH(''' || REPLACE("searchfilter", '''', '''''') || ''') > 0 
                THEN TRIM(REPLACE(''' || REPLACE("searchfilter", '''', '''''') || ''', '' '', '''')) 
                ELSE TRIM(REPLACE(''' || REPLACE("searchfilter", '''', '''''') || ''', '' '', '''')) END || ''%'')
    OR (TRIM("AMST_FirstName") LIKE ''%'' || TRIM(''' || REPLACE("searchfilter", '''', '''''') || ''') || ''%'' 
        OR TRIM("AMST_MiddleName") LIKE ''%'' || TRIM(''' || REPLACE("searchfilter", '''', '''''') || ''') || ''%'' 
        OR TRIM("AMST_LastName") LIKE ''%'' || TRIM(''' || REPLACE("searchfilter", '''', '''''') || ''') || ''%'')';

    RETURN QUERY EXECUTE "dynamic";

END;
$$;