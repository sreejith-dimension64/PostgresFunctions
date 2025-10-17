CREATE OR REPLACE FUNCTION "dbo"."Fee_refundable_list_proc"(
    "@MI_Id" bigint,
    "@userid" bigint,
    "@ASMAY_ID" bigint
)
RETURNS TABLE(
    "FR_Date" TIMESTAMP,
    "fR_RefundNo" VARCHAR,
    "amsT_ID" bigint,
    "amsT_FirstName" VARCHAR,
    "amsT_MiddleName" VARCHAR,
    "amsT_LastName" VARCHAR,
    "amsT_AdmNo" VARCHAR,
    "fR_RefundAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT
        a."FR_Date",
        a."FR_RefundNo" AS "fR_RefundNo",
        a."AMST_ID" AS "amsT_ID",
        b."AMST_FirstName" AS "amsT_FirstName",
        b."AMST_MiddleName" AS "amsT_MiddleName",
        b."AMST_LastName" AS "amsT_LastName",
        b."AMST_AdmNo" AS "amsT_AdmNo",
        SUM(a."FR_RefundAmount") AS "fR_RefundAmount"
    FROM "Fee_Refund" a
    INNER JOIN "Adm_M_Student" b ON a."AMST_ID" = b."AMST_Id"
    INNER JOIN "Fee_Master_Head" c ON a."FMH_ID" = c."FMH_Id"
    INNER JOIN "Adm_School_Y_Student" d ON b."AMST_Id" = d."AMST_Id"
    INNER JOIN "Fee_T_Installment" e ON e."FTI_Id" = a."FTI_Id"
    WHERE d."ASMAY_Id" = "@ASMAY_ID"
        AND a."MI_Id" = "@MI_Id"
        AND a."FR_RefundFlag" = 'true'
        AND a."User_Id" = "@userid"
    GROUP BY
        a."AMST_ID",
        b."AMST_FirstName",
        b."AMST_MiddleName",
        b."AMST_LastName",
        b."AMST_AdmNo",
        a."FR_RefundNo",
        a."FR_Date";
END;
$$;