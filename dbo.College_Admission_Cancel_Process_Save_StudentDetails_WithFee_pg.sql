CREATE OR REPLACE FUNCTION "dbo"."College_Admission_Cancel_Process_Save_StudentDetails_WithFee"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@AMCO_Id" TEXT,
    "@AMB_Id" TEXT,
    "@AMSE_Id" TEXT,
    "@AMCST_Id" TEXT,
    "@REFUNDPER" TEXT,
    "@CANCELPER" TEXT,
    "@REASON" TEXT,
    "@USERID" TEXT
)
RETURNS TABLE(
    "MI_Id" BIGINT,
    "AMCST_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "AMCO_Id" BIGINT,
    "AMB_Id" BIGINT,
    "AMSE_Id" BIGINT,
    "AMCST_FirstName" VARCHAR,
    "AMCST_MiddleName" VARCHAR,
    "AMCST_LastName" VARCHAR,
    "AMCST_Date" TIMESTAMP,
    "AMCST_Sex" VARCHAR,
    "AMCST_RegistrationNo" VARCHAR,
    "AMCST_AdmNo" VARCHAR,
    "AMCST_emailId" VARCHAR,
    "AMCST_MobileNo" BIGINT,
    "AMCST_StudentPhoto" TEXT,
    "AMCST_SOL" VARCHAR,
    "AMCST_ActiveFlag" BOOLEAN,
    "AMCST_CreatedBy" BIGINT,
    "AMCST_UpdatedBy" BIGINT,
    "CreatedDate" TIMESTAMP,
    "UpdatedDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    "REFUND_AMOUNT" BIGINT;
    "CANCEL_AMOUNT" BIGINT;
    "REFUND_PER_NEW" BIGINT;
    "CANCEL_PER_NEW" BIGINT;
    "TOTAL_FEE" BIGINT;
BEGIN
    BEGIN
        SELECT SUM("FCSS_CurrentYrCharges") INTO "TOTAL_FEE"
        FROM "clg"."Fee_College_Student_Status"
        WHERE "ASMAY_Id" = "@ASMAY_Id"::BIGINT
        AND "AMCST_Id" = "@AMCST_Id"::BIGINT;

        "REFUND_AMOUNT" := 0;
        "CANCEL_AMOUNT" := 0;

        "REFUND_AMOUNT" := (COALESCE("TOTAL_FEE", 0) / 100) * "@REFUNDPER"::BIGINT;
        "CANCEL_AMOUNT" := (COALESCE("TOTAL_FEE", 0) / 100) * "@CANCELPER"::BIGINT;

        RETURN QUERY
        SELECT *
        FROM "CLG"."Adm_Master_College_Student"
        WHERE "MI_Id" = "@MI_Id"::BIGINT
        AND "AMCST_Id" = "@AMCST_Id"::BIGINT;

        UPDATE "CLG"."Adm_Master_College_Student"
        SET "AMCST_SOL" = 'c',
            "AMCST_ActiveFlag" = FALSE
        WHERE "MI_Id" = "@MI_Id"::BIGINT
        AND "AMCST_Id" = "@AMCST_Id"::BIGINT;

        INSERT INTO "CLG"."Adm_College_AdmissionCancel" (
            "MI_Id",
            "AMCST_Id",
            "ASMAY_Id",
            "AMCO_Id",
            "AMB_Id",
            "AMSE_Id",
            "ACACA_ACReason",
            "ACACA_ACDate",
            "ACACA_AmountAdjusted",
            "ACACA_ToRefundAmount",
            "ACACA_CreatedBy",
            "ACACA_UpdatedBy",
            "ACACA_ActiveFlag",
            "CreatedDate",
            "UpdatedDate"
        )
        VALUES(
            "@MI_Id"::BIGINT,
            "@AMCST_Id"::BIGINT,
            "@ASMAY_Id"::BIGINT,
            "@AMCO_Id"::BIGINT,
            "@AMB_Id"::BIGINT,
            "@AMSE_Id"::BIGINT,
            "@REASON",
            CURRENT_TIMESTAMP,
            "CANCEL_AMOUNT",
            "REFUND_AMOUNT",
            "@USERID"::BIGINT,
            "@USERID"::BIGINT,
            TRUE,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        );

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;
END;
$$;