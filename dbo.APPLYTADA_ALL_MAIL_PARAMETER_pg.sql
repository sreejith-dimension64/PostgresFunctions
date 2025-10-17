CREATE OR REPLACE FUNCTION "dbo"."APPLYTADA_ALL_MAIL_PARAMETER"(
    p_UserID bigint,
    p_MI_Id bigint,
    p_INVMPR_Id bigint
)
RETURNS TABLE (
    "VMSTADA_Id" bigint,
    "MI_Id" bigint,
    "HRME_Id" bigint,
    "VMSTADA_TADAStartDate" timestamp,
    "VMSTADA_TADAEndDate" timestamp,
    "VMSTADA_TADADays" integer,
    "VMSTADA_TADAAppliedDate" timestamp,
    "VMSTADA_TADAType" character varying,
    "VMSTADA_TADAFromPlace" character varying,
    "VMSTADA_TADAToPlace" character varying,
    "VMSTADA_TADAAdvanceRequired" boolean,
    "VMSTADA_TADAAdvanceAmount" numeric,
    "VMSTADA_TADAPurpose" text,
    "VMSTADA_TADARemarks" text,
    "VMSTADA_TADAStatus" character varying,
    "VMSTADA_TADASanctionedDate" timestamp,
    "VMSTADA_TADASanctionedBy" bigint,
    "VMSTADA_TADASanctionRemarks" text,
    "VMSTADA_ActiveFlag" boolean,
    "VMSTADA_CreatedBy" bigint,
    "VMSTADA_UpdatedBy" bigint,
    "VMSTADA_CreatedDate" timestamp,
    "VMSTADA_UpdatedDate" timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM "VMS_TADA_Apply";
END;
$$;