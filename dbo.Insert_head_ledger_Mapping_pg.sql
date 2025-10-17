CREATE OR REPLACE FUNCTION "dbo"."Insert_head_ledger_Mapping"(
    "FYGHLM_Id" BIGINT,
    "FYGHM_Id" BIGINT,
    "FYGHM_RVRegLedgerId" TEXT,
    "FYGHM_RVRegLedgerUnder" TEXT,
    "FYGHM_RVAdvanceLegderId" TEXT,
    "FYGHM_RVAdvanceLegderUnder" TEXT,
    "FYGHM_RVArrearLedgerId" TEXT,
    "FYGHM_RVArrearLedgerUnder" TEXT,
    "FYGHM_JVRegLedgerId" TEXT,
    "FYGHM_JVRegLedgerUnder" TEXT,
    "FYGHM_JVAdvanceLegderId" TEXT,
    "FYGHM_JVAdvanceLegderUnder" TEXT,
    "FYGHM_JVArrearLedgerId" TEXT,
    "FYGHM_JVArrearLedgerUnder" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF "FYGHLM_Id" = 0 THEN
        INSERT INTO "dbo"."Fee_Yearly_Group_Head_LedgerMapping" (
            "FYGHM_Id",
            "FYGHM_RVRegLedgerId",
            "FYGHM_RVRegLedgerUnder",
            "FYGHM_RVAdvanceLegderId",
            "FYGHM_RVAdvanceLegderUnder",
            "FYGHM_RVArrearLedgerId",
            "FYGHM_RVArrearLedgerUnder",
            "FYGHM_JVRegLedgerId",
            "FYGHM_JVRegLedgerUnder",
            "FYGHM_JVAdvanceLegderId",
            "FYGHM_JVAdvanceLegderUnder",
            "FYGHM_JVArrearLedgerId",
            "FYGHM_JVArrearLedgerUnder"
        ) VALUES (
            "FYGHM_Id",
            "FYGHM_RVRegLedgerId",
            "FYGHM_RVRegLedgerUnder",
            "FYGHM_RVAdvanceLegderId",
            "FYGHM_RVAdvanceLegderUnder",
            "FYGHM_RVArrearLedgerId",
            "FYGHM_RVArrearLedgerUnder",
            "FYGHM_JVRegLedgerId",
            "FYGHM_JVRegLedgerUnder",
            "FYGHM_JVAdvanceLegderId",
            "FYGHM_JVAdvanceLegderUnder",
            "FYGHM_JVArrearLedgerId",
            "FYGHM_JVArrearLedgerUnder"
        );
    ELSE
        UPDATE "dbo"."Fee_Yearly_Group_Head_LedgerMapping"
        SET "FYGHM_Id" = "FYGHM_Id",
            "FYGHM_RVRegLedgerId" = "FYGHM_RVRegLedgerId",
            "FYGHM_RVRegLedgerUnder" = "FYGHM_RVRegLedgerUnder",
            "FYGHM_RVAdvanceLegderId" = "FYGHM_RVAdvanceLegderId",
            "FYGHM_RVAdvanceLegderUnder" = "FYGHM_RVAdvanceLegderUnder",
            "FYGHM_RVArrearLedgerId" = "FYGHM_RVArrearLedgerId",
            "FYGHM_RVArrearLedgerUnder" = "FYGHM_RVArrearLedgerUnder",
            "FYGHM_JVRegLedgerId" = "FYGHM_JVRegLedgerId",
            "FYGHM_JVRegLedgerUnder" = "FYGHM_JVRegLedgerUnder",
            "FYGHM_JVAdvanceLegderId" = "FYGHM_JVAdvanceLegderId",
            "FYGHM_JVAdvanceLegderUnder" = "FYGHM_JVAdvanceLegderUnder",
            "FYGHM_JVArrearLedgerId" = "FYGHM_JVArrearLedgerId",
            "FYGHM_JVArrearLedgerUnder" = "FYGHM_JVArrearLedgerUnder"
        WHERE "FYGHLM_Id" = "FYGHLM_Id";
    END IF;
END;
$$;