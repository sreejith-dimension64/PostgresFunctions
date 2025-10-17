CREATE OR REPLACE FUNCTION "dbo"."EXM_ProgressCard_RecordsInsert"(
    "@MI_Id" bigint,
    "@ASMAY_Id_Old" bigint,
    "@ASMAY_Id_New" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO "Exm"."EXM_ProgressCard_Formats"(
        "MI_Id",
        "ASMAY_Id",
        "EPCFT_ProgressCardFormat",
        "EPCFT_ActiveFlg",
        "EPCFT_CreatedBy",
        "EPCFT_CreateDate",
        "EPCFT_UpdatedBy",
        "EPCFT_UpdateDate",
        "EMCA_Id",
        "EPCFT_SPFlag",
        "EPCFT_ExamFlag",
        "EPCFT_ExamwiseFlg"
    )
    SELECT 
        "MI_Id",
        "@ASMAY_Id_New",
        "EPCFT_ProgressCardFormat",
        "EPCFT_ActiveFlg",
        "EPCFT_CreatedBy",
        "EPCFT_CreateDate",
        "EPCFT_UpdatedBy",
        "EPCFT_UpdateDate",
        "EMCA_Id",
        "EPCFT_SPFlag",
        "EPCFT_ExamFlag",
        "EPCFT_ExamwiseFlg"
    FROM "Exm"."EXM_ProgressCard_Formats"
    WHERE "MI_Id" = "@MI_Id" 
        AND "ASMAY_Id" = "@ASMAY_Id_Old";

END;
$$;