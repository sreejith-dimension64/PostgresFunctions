CREATE OR REPLACE FUNCTION "dbo"."CWStusUploadedCount"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint
)
RETURNS TABLE(
    "StudentsCount" bigint,
    "CUStudentsCount" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    WITH cte1 AS (
        SELECT COUNT(DISTINCT "ASYS"."AMST_Id") AS "StudentsCount"
        FROM "Adm_School_Y_Student" "ASYS"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
        WHERE "AMS"."MI_Id" = p_MI_Id 
            AND "ASYS"."ASMAY_Id" = p_ASMAY_Id 
            AND "ASYS"."ASMCL_Id" = p_ASMCL_Id 
            AND "ASYS"."ASMS_Id" = p_ASMS_Id
    ),
    cte2 AS (
        SELECT COUNT(DISTINCT "AMST_Id") AS "CUStudentsCount"
        FROM "IVRM_Assignment" "CW"
        INNER JOIN "IVRM_ClassWork_Upload" "CWU" ON "CW"."ICW_Id" = "CWU"."ICW_Id"
        WHERE "CW"."MI_Id" = p_MI_Id 
            AND "CW"."ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id
    )
    SELECT * FROM cte1, cte2;

END;
$$;