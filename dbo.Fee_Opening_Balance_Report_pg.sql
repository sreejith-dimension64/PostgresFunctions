CREATE OR REPLACE FUNCTION "dbo"."Fee_Opening_Balance_Report"(
    "miid" BIGINT,
    "amstid" BIGINT,
    "asmayid" BIGINT,
    "fmgid" BIGINT,
    "fmhid" BIGINT,
    "ftiid" BIGINT,
    "fmaid" BIGINT,
    "fmobentrydate" TIMESTAMP,
    "fmobstud_due" DECIMAL,
    "fmobinst_due" DECIMAL,
    "userid" DECIMAL,
    "refund" VARCHAR(20)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "FSS_OBArrearAmount" BIGINT;
    "FSS_RefundableAmount" BIGINT;
    "count" INT;
    "count2" INT;
    "row_count" INT;
BEGIN

    IF ("refund" = 'Refunable') THEN
        SELECT COUNT("FSS_Id") INTO "count"
        FROM "Fee_Student_Status"
        WHERE "AMST_Id" = "amstid" 
            AND "MI_Id" = "miid" 
            AND "ASMAY_Id" = "asmayid" 
            AND "FMG_Id" = "fmgid" 
            AND "FMH_Id" = "fmhid" 
            AND "FTI_Id" = "ftiid" 
            AND "FMA_Id" = "fmaid"
            AND "USER_ID" = "userid";
        
        IF ("count" = 0) THEN
            RAISE NOTICE 'a';
            INSERT INTO "Fee_Student_Status"(
                "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id",
                "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges",
                "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount",
                "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount",
                "FSS_RunningExcessAmount", "FSS_ConcessionAmount",
                "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount",
                "FSS_FineAmount", "FSS_RefundAmount",
                "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag",
                "FSS_ArrearFlag", "FSS_RefundOverFlag",
                "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount"
            ) VALUES (
                "miid", "asmayid", "amstid", "fmgid", "fmhid", "ftiid", "fmaid",
                "fmobstud_due", "fmobinst_due", 0, "fmobstud_due", "fmobstud_due", 0,
                0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, "userid", "fmobinst_due"
            );
            
            INSERT INTO "Fee_Master_Opening_Balance"(
                "MI_Id", "AMST_Id", "ASMAY_Id", "FMH_Id", "FMOB_EntryDate",
                "FMOB_Student_Due", "FMOB_Institution_Due", "FMG_Id", "FTI_Id", "User_Id"
            ) VALUES (
                "miid", "amstid", "asmayid", "fmhid", "fmobentrydate",
                "fmobstud_due", "fmobinst_due", "fmgid", "ftiid", "userid"
            );
        ELSE
            RAISE NOTICE 'b';
            SELECT "FSS_OBArrearAmount", "FSS_RefundableAmount"
            INTO "FSS_OBArrearAmount", "FSS_RefundableAmount"
            FROM "Fee_Student_Status"
            WHERE "AMST_Id" = "amstid" 
                AND "MI_Id" = "miid" 
                AND "ASMAY_Id" = "asmayid" 
                AND "FMG_Id" = "fmgid"
                AND "FMH_Id" = "fmhid" 
                AND "FTI_Id" = "ftiid" 
                AND "USER_ID" = "userid";
            
            IF ("FSS_RefundableAmount" >= "FSS_OBArrearAmount") THEN
                RAISE NOTICE 'c';
                UPDATE "Fee_Student_Status"
                SET "FSS_OBArrearAmount" = "fmobstud_due",
                    "FSS_OBExcessAmount" = "fmobinst_due",
                    "FSS_RefundableAmount" = ("FSS_RefundableAmount" - "FSS_OBExcessAmount") + "fmobinst_due",
                    "FSS_TotalToBePaid" = "FSS_TotalToBePaid" + "fmobstud_due",
                    "FSS_ToBePaid" = "FSS_ToBePaid" + "fmobstud_due"
                WHERE "AMST_Id" = "amstid"
                    AND "MI_Id" = "miid" 
                    AND "ASMAY_Id" = "asmayid" 
                    AND "FMG_Id" = "fmgid" 
                    AND "FMH_Id" = "fmhid" 
                    AND "FTI_Id" = "ftiid"
                    AND "User_Id" = "userid";
                
                SELECT COUNT(*) INTO "row_count"
                FROM "Fee_Master_Opening_Balance"
                WHERE "AMST_Id" = "amstid" 
                    AND "MI_Id" = "miid"
                    AND "ASMAY_Id" = "asmayid" 
                    AND "FMG_Id" = "fmgid" 
                    AND "FMH_Id" = "fmhid" 
                    AND "FTI_Id" = "ftiid"
                    AND "USER_ID" = "userid";
                
                IF ("row_count" = 0) THEN
                    RAISE NOTICE 'd';
                    INSERT INTO "Fee_Master_Opening_Balance"(
                        "MI_Id", "AMST_Id", "ASMAY_Id", "FMH_Id", "FMOB_EntryDate",
                        "FMOB_Student_Due", "FMOB_Institution_Due", "FMG_Id", "FTI_Id", "User_Id"
                    ) VALUES (
                        "miid", "amstid", "asmayid", "fmhid", "fmobentrydate",
                        "fmobstud_due", "fmobinst_due", "fmgid", "ftiid", "userid"
                    );
                ELSE
                    RAISE NOTICE 'f';
                    UPDATE "Fee_Master_Opening_Balance"
                    SET "FMOB_EntryDate" = "fmobentrydate",
                        "FMOB_Student_Due" = "fmobstud_due",
                        "FMOB_Institution_Due" = "fmobinst_due"
                    WHERE "AMST_Id" = "amstid" 
                        AND "MI_Id" = "miid" 
                        AND "ASMAY_Id" = "asmayid"
                        AND "FMG_Id" = "fmgid" 
                        AND "FMH_Id" = "fmhid" 
                        AND "FTI_Id" = "ftiid" 
                        AND "USER_ID" = "userid";
                END IF;
            END IF;
        END IF;
    ELSE
        SELECT COUNT("FSS_Id") INTO "count2"
        FROM "Fee_Student_Status"
        WHERE "AMST_Id" = "amstid" 
            AND "MI_Id" = "miid" 
            AND "ASMAY_Id" = "asmayid" 
            AND "FMG_Id" = "fmgid" 
            AND "FMH_Id" = "fmhid" 
            AND "FTI_Id" = "ftiid" 
            AND "FMA_Id" = "fmaid"
            AND "USER_ID" = "userid";
        
        IF ("count2" = 0) THEN
            RAISE NOTICE 'g';
            INSERT INTO "Fee_Student_Status"(
                "MI_Id", "ASMAY_Id", "AMST_Id", "FMG_Id", "FMH_Id", "FTI_Id", "FMA_Id",
                "FSS_OBArrearAmount", "FSS_OBExcessAmount", "FSS_CurrentYrCharges",
                "FSS_TotalToBePaid", "FSS_ToBePaid", "FSS_PaidAmount",
                "FSS_ExcessPaidAmount", "FSS_ExcessAdjustedAmount",
                "FSS_RunningExcessAmount", "FSS_ConcessionAmount",
                "FSS_AdjustedAmount", "FSS_WaivedAmount", "FSS_RebateAmount",
                "FSS_FineAmount", "FSS_RefundAmount",
                "FSS_RefundAmountAdjusted", "FSS_NetAmount", "FSS_ChequeBounceFlag",
                "FSS_ArrearFlag", "FSS_RefundOverFlag",
                "FSS_ActiveFlag", "User_Id", "FSS_RefundableAmount"
            ) VALUES (
                "miid", "asmayid", "amstid", "fmgid", "fmhid", "ftiid", "fmaid",
                "fmobstud_due", "fmobinst_due", 0, "fmobstud_due", "fmobstud_due", 0,
                0, 0, "fmobinst_due", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, "userid", 0
            );
            
            INSERT INTO "Fee_Master_Opening_Balance"(
                "MI_Id", "AMST_Id", "ASMAY_Id", "FMH_Id", "FMOB_EntryDate",
                "FMOB_Student_Due", "FMOB_Institution_Due", "FMG_Id", "FTI_Id", "User_Id"
            ) VALUES (
                "miid", "amstid", "asmayid", "fmhid", "fmobentrydate",
                "fmobstud_due", "fmobinst_due", "fmgid", "ftiid", "userid"
            );
        ELSE
            SELECT "FSS_OBArrearAmount", "FSS_RunningExcessAmount"
            INTO "FSS_OBArrearAmount", "FSS_RefundableAmount"
            FROM "Fee_Student_Status"
            WHERE "AMST_Id" = "amstid" 
                AND "MI_Id" = "miid" 
                AND "ASMAY_Id" = "asmayid" 
                AND "FMG_Id" = "fmgid"
                AND "FMH_Id" = "fmhid" 
                AND "FTI_Id" = "ftiid" 
                AND "USER_ID" = "userid";
            
            IF ("FSS_RefundableAmount" >= "FSS_OBArrearAmount") THEN
                RAISE NOTICE 'h';
                UPDATE "Fee_Student_Status"
                SET "FSS_OBArrearAmount" = "fmobstud_due",
                    "FSS_OBExcessAmount" = "fmobinst_due",
                    "FSS_RunningExcessAmount" = ("FSS_RefundableAmount" - "FSS_OBExcessAmount") + "fmobinst_due",
                    "FSS_TotalToBePaid" = "FSS_TotalToBePaid" + "fmobstud_due",
                    "FSS_ToBePaid" = "FSS_ToBePaid" + "fmobstud_due"
                WHERE "AMST_Id" = "amstid" 
                    AND "MI_Id" = "miid" 
                    AND "ASMAY_Id" = "asmayid"
                    AND "FMG_Id" = "fmgid" 
                    AND "FMH_Id" = "fmhid" 
                    AND "FTI_Id" = "ftiid" 
                    AND "User_Id" = "userid";
                
                SELECT COUNT(*) INTO "row_count"
                FROM "Fee_Master_Opening_Balance"
                WHERE "AMST_Id" = "amstid" 
                    AND "MI_Id" = "miid"
                    AND "ASMAY_Id" = "asmayid" 
                    AND "FMG_Id" = "fmgid" 
                    AND "FMH_Id" = "fmhid" 
                    AND "FTI_Id" = "ftiid" 
                    AND "USER_ID" = "userid";
                
                IF ("row_count" = 0) THEN
                    RAISE NOTICE 'i';
                    INSERT INTO "Fee_Master_Opening_Balance"(
                        "MI_Id", "AMST_Id", "ASMAY_Id", "FMH_Id", "FMOB_EntryDate",
                        "FMOB_Student_Due", "FMOB_Institution_Due", "FMG_Id", "FTI_Id", "User_Id"
                    ) VALUES (
                        "miid", "amstid", "asmayid", "fmhid", "fmobentrydate",
                        "fmobstud_due", "fmobinst_due", "fmgid", "ftiid", "userid"
                    );
                ELSE
                    RAISE NOTICE 'j';
                    UPDATE "Fee_Master_Opening_Balance"
                    SET "FMOB_EntryDate" = "fmobentrydate",
                        "FMOB_Student_Due" = "fmobstud_due",
                        "FMOB_Institution_Due" = "fmobinst_due"
                    WHERE "AMST_Id" = "amstid" 
                        AND "MI_Id" = "miid" 
                        AND "ASMAY_Id" = "asmayid" 
                        AND "FMG_Id" = "fmgid"
                        AND "FMH_Id" = "fmhid" 
                        AND "FTI_Id" = "ftiid" 
                        AND "USER_ID" = "userid";
                END IF;
            END IF;
        END IF;
    END IF;

    RETURN;
END;
$$;