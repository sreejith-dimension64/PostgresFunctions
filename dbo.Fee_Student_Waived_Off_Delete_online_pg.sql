CREATE OR REPLACE FUNCTION "dbo"."Fee_Student_Waived_Off_Delete_online"(
    "FSWO_ID" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "miid" bigint;
    "asmayid" bigint;
    "amstid" bigint;
    "FMG_id" bigint;
    "FMH_id" bigint;
    "FTI_id" bigint;
    "FMA_id" bigint;
    "userid" bigint;
    "Waivedamount" bigint;
    "FSS_ToBePaid" bigint;
    "FSS_ExcessPaidAmount" bigint;
    "FSS_RefundableAmount" bigint;
    "FSS_RunningExcessAmount" bigint;
    "totalval" bigint;
    "FMH_RefundFlag" boolean;
BEGIN

    DELETE FROM "dbo"."Fee_Student_Waived_Off" 
    WHERE "FSWO_ID" = "Fee_Student_Waived_Off_Delete_online"."FSWO_ID";

END;
$$;