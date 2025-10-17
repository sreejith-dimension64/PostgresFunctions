CREATE OR REPLACE FUNCTION "dbo"."HWStusUploadedCount"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_ASMCL_Id bigint,
    p_ASMS_Id bigint
)
RETURNS TABLE(
    "StudentsCount" bigint,
    "HUStudentsCount" bigint
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
        SELECT COUNT(DISTINCT "AMST_Id") AS "HUStudentsCount"
        FROM "IVRM_HomeWork" "HW"
        INNER JOIN "IVRM_HomeWork_Upload" "HWU" ON "HW"."IHW_Id" = "HWU"."IHW_Id"
        WHERE "HW"."MI_Id" = p_MI_Id 
            AND "HW"."ASMAY_Id" = p_ASMAY_Id 
            AND "ASMCL_Id" = p_ASMCL_Id 
            AND "ASMS_Id" = p_ASMS_Id
    )
    SELECT * FROM cte1, cte2;
END;
$$;