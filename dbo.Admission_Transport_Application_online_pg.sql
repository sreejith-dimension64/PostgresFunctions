CREATE OR REPLACE FUNCTION "dbo"."Admission_Transport_Application_online"(
    @mi_id VARCHAR(50),
    @classid VARCHAR(50),
    @studentis VARCHAR(50),
    @asmay_id VARCHAR(50),
    @amount VARCHAR(50),
    @transid VARCHAR(50),
    @checkid VARCHAR(50),
    @fmaid BIGINT,
    @recno VARCHAR(100)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    @setstatus BIGINT;
    @lastid BIGINT;
    @fma_id BIGINT;
    @fypid BIGINT;
    @sql1head TEXT;
    @sqlhead TEXT;
    @remarks VARCHAR(50);
    @CURR_IDENTYTY BIGINT;
    @fypwaived BIGINT;
    @fypconcessionamt BIGINT;
    @fypfine BIGINT;
    @userid BIGINT;
BEGIN
    @CURR_IDENTYTY := 0;
    @fypwaived := 0;
    @fypconcessionamt := 0;
    @fypfine := 0;
    @remarks := 'Online Payment';

    BEGIN
        SELECT "fyp_id" INTO @fypid 
        FROM "Fee_Y_Payment" 
        WHERE "FYP_Transaction_Id" = '' || @transid || ''
        LIMIT 1;

        SELECT "a"."Id" INTO @userid 
        FROM "ApplicationUser" AS "a" 
        INNER JOIN "ApplicationUserRole" AS "b" ON "a"."Id" = "b"."UserId" 
        INNER JOIN "IVRM_Role_Type" AS "c" ON "c"."IVRMRT_Id" = "b"."RoleTypeId" 
        WHERE "c"."IVRMRT_Role" = 'ADMIN'
        LIMIT 1;

        UPDATE "Fee_Y_Payment" 
        SET "FYP_OnlineChallanStatusFlag" = 'Sucessfull',
            "FYP_PaymentReference_Id" = @checkid,
            "user_id" = @userid,
            "fyp_receipt_no" = @recno 
        WHERE "FYP_Id" = @fypid;

        SELECT "fyp_Id" INTO @CURR_IDENTYTY 
        FROM "fee_Y_payment" 
        WHERE "FYP_Id" = @fypid;

        SELECT "Fee_Master_Amount"."FMA_Id" INTO @fma_id 
        FROM "Fee_Master_Amount" 
        INNER JOIN "Fee_Master_Head" ON "Fee_Master_Amount"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
        INNER JOIN "Fee_Yearly_Class_Category" ON "Fee_Yearly_Class_Category"."FMCC_Id" = "Fee_Master_Amount"."FMCC_Id"
            AND "Fee_Yearly_Class_Category"."ASMAY_Id" = "Fee_Master_Amount"."ASMAY_Id"
        INNER JOIN "Fee_Yearly_Class_Category_Classes" ON "Fee_Yearly_Class_Category_Classes"."FYCC_Id" = "Fee_Yearly_Class_Category"."FYCC_Id"
        INNER JOIN "Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Master_Amount"."FMG_Id"
        WHERE "Fee_Master_Amount"."MI_Id" = @mi_id 
            AND "Fee_Master_Amount"."ASMAY_Id" = @asmay_id 
            AND "Fee_Master_Head"."FMH_Flag" = 'T' 
            AND "ASMCL_Id" = @classid 
            AND "FMG_CompulsoryFlag" = 'T';

        INSERT INTO "Fee_T_Payment" (
            "FYP_Id",
            "FMA_Id",
            "FTP_Paid_Amt",
            "FTP_Fine_Amt",
            "FTP_Concession_Amt",
            "FTP_Waived_Amt",
            "ftp_remarks"
        ) 
        VALUES (
            @CURR_IDENTYTY,
            @fma_id,
            @amount,
            @fypfine,
            @fypconcessionamt,
            @fypwaived,
            @remarks
        );

    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END;

    RETURN;
END;
$$;