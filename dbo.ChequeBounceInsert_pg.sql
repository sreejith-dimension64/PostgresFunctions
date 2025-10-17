CREATE OR REPLACE FUNCTION "dbo"."ChequeBounceInsert" (
    "FCBId" bigint,
    "@ASMAY_ID" bigint,
    "@AMST_Id" bigint,
    "@FCB_DATE" timestamp,
    "@FCB_Remarks" text,
    "@FYPId" bigint,
    "@MI_Id" bigint,
    "@User_Id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "FYP_TotalPaidAmount" decimal(18,2);
    "FMA_Id" bigint;
    "FMH_Id" bigint;
    "cnt" bigint;
    "FTP_Paid_Amt" decimal(18,2);
BEGIN

    SELECT "FYP_Tot_Amount" INTO "FYP_TotalPaidAmount" 
    FROM "Fee_Y_Payment" 
    WHERE "FYP_Id" = "@FYPId";

    IF ("FCBId" != 0) THEN
        UPDATE "Fee_Cheque_Bounce" 
        SET "FCB_Date" = "@FCB_DATE",
            "FCB_Amount" = "FYP_TotalPaidAmount",
            "FCB_Remarks" = "@FCB_Remarks",
            "User_Id" = "@User_Id"
        WHERE "FYP_ID" = "@FYPId" AND "FCB_Id" = "FCBId";
    
    ELSIF ("FCBId" = 0) THEN
        INSERT INTO "Fee_Cheque_Bounce" (
            "FYP_Id",
            "MI_Id",
            "ASMAY_Id",
            "AMST_Id",
            "FCB_Date",
            "FCB_Amount",
            "FCB_Remarks",
            "FCB_ActiveFlag",
            "FCB_CreatedDate",
            "FCB_UpdatedDate",
            "FCB_CreatedBy",
            "FCB_UpdatedBy",
            "user_id"
        )
        VALUES (
            "@FYPId",
            "@MI_Id",
            "@ASMAY_ID",
            "@AMST_Id",
            "@FCB_DATE",
            "FYP_TotalPaidAmount",
            "@FCB_Remarks",
            1,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            "@User_Id",
            "@User_Id",
            "@User_Id"
        );

        UPDATE "Fee_Y_Payment" 
        SET "FYP_UpdatedBy" = "@User_Id",
            "UpdatedDate" = CURRENT_TIMESTAMP,
            "FYP_Chq_Bounce" = 'CB'
        WHERE "FYP_Id" = "@FYPId";

        UPDATE "Fee_Student_Status" "FSS"
        SET "FSS_ToBePaid" = "FSS"."FSS_ToBePaid" + "FTP"."FTP_Paid_Amt",
            "FSS_PaidAmount" = "FSS"."FSS_PaidAmount" - "FTP"."FTP_Paid_Amt"
        FROM "Fee_T_Payment" "FTP"
        INNER JOIN "Fee_Master_Amount" "FMA" ON "FTP"."FMA_Id" = "FMA"."FMA_Id"
        INNER JOIN "Fee_Student_Status" "FSS2" ON "FSS2"."ASMAY_Id" = "FMA"."ASMAY_Id" 
            AND "FSS2"."FMA_Id" = "FMA"."FMA_Id" 
            AND "FSS2"."FMH_Id" = "FMA"."FMH_Id" 
            AND "FSS2"."FMG_Id" = "FMA"."FMG_Id"
        INNER JOIN "Fee_Master_Head" "FMH" ON "FMH"."MI_Id" = "FSS2"."MI_Id" 
            AND "FMH"."FMH_Id" = "FSS2"."FMH_Id"
        WHERE "FTP"."FYP_Id" = "@FYPId" 
            AND "FSS2"."AMST_Id" = "@AMST_Id" 
            AND "FSS2"."ASMAY_Id" = "@ASMAY_ID" 
            AND "FMA"."ASMAY_Id" = "@ASMAY_ID"
            AND "FMH"."FMH_Flag" != 'F'
            AND "FSS"."FMH_Id" = "FSS2"."FMH_Id"
            AND "FSS"."FMA_Id" = "FSS2"."FMA_Id"
            AND "FSS"."ASMAY_Id" = "FSS2"."ASMAY_Id"
            AND "FSS"."FMG_Id" = "FSS2"."FMG_Id"
            AND "FSS"."AMST_Id" = "FSS2"."AMST_Id";

    END IF;

END;
$$;