CREATE OR REPLACE FUNCTION "Fee_Excel_Imports" (
    "@MI_Id" bigint,
    "@AMST_Id" bigint,
    "@Admno" varchar(50),
    "@amount" bigint,
    "@date" timestamp,
    "@Remark" text,
    "@User_Id" bigint,
    "@ASMAY_Id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN

    INSERT INTO "Fee_Excel_Imports_Pending_Students" (
        "MI_Id",
        "AMST_Id",
        "AMST_AdmNo",
        "FEIPST_Date",
        "FEIPST_Amount",
        "FEIPST_ActiveFlg",
        "FEIPST_CreatedDate",
        "FEIPST_UpdatedDate",
        "FEIPST_CreatedBy",
        "FEIPST_UpdatedBy",
        "FEIPST_Remarks",
        "ASMAY_Id"
    ) 
    VALUES (
        "@MI_Id",
        "@AMST_Id",
        "@Admno",
        "@date",
        "@amount",
        1,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        "@User_Id",
        "@User_Id",
        "@Remark",
        "@ASMAY_Id"
    );

END;
$$;