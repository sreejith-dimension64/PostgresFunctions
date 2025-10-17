CREATE OR REPLACE FUNCTION "dbo"."Exam_EXAM_Wise_Remarks"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT
)
RETURNS TABLE(
    "amsT_Id" BIGINT,
    "emE_ID" BIGINT,
    "emeR_Remarks" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        a."AMST_Id" AS "amsT_Id",
        a."EME_Id" AS "emE_ID",
        (
            SELECT b."EMGD_Remarks"
            FROM "Exm"."Exm_Master_Grade_Details" b
            WHERE (
                a."ESTMP_Percentage" BETWEEN b."EMGD_From" AND b."EMGD_To" 
                AND a."EMGD_Id" = b."EMGD_Id"
            )
            OR (
                a."ESTMP_Percentage" BETWEEN b."EMGD_To" AND b."EMGD_From" 
                AND a."EMGD_Id" = b."EMGD_Id"
            )
            LIMIT 1
        ) AS "emeR_Remarks"
    FROM "Exm"."Exm_Student_Marks_Process" a
    WHERE 
        a."MI_Id" = "@MI_Id"::BIGINT
        AND a."ASMCL_Id" = "@ASMCL_Id"::BIGINT
        AND a."ASMAY_Id" = "@ASMAY_Id"::BIGINT
        AND a."ASMS_Id" = "@ASMS_Id"::BIGINT;
END;
$$;