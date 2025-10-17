CREATE OR REPLACE FUNCTION "dbo"."Fee_Trial_Audit_View_Details"(
    p_MI_Id bigint,
    p_FYP_Id bigint
)
RETURNS TABLE(
    "IATD_Id" bigint,
    "ITAT_Id" bigint,
    "IATD_ColumnName" varchar,
    "IATD_OldValue" text,
    "IATD_NewValue" text,
    "IATD_CreatedDate" timestamp,
    "IATD_UpdatedDate" timestamp,
    "IATD_CreatedBy" bigint,
    "IATD_UpdatedBy" bigint,
    "IATD_ActiveFlag" boolean
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        iad."IATD_Id",
        iad."ITAT_Id",
        iad."IATD_ColumnName",
        iad."IATD_OldValue",
        iad."IATD_NewValue",
        iad."IATD_CreatedDate",
        iad."IATD_UpdatedDate",
        iad."IATD_CreatedBy",
        iad."IATD_UpdatedBy",
        iad."IATD_ActiveFlag"
    FROM "IVRM_AuditTrail_Deatils" iad
    WHERE iad."ITAT_Id" IN (
        SELECT ita."ITAT_Id" 
        FROM "IVRM_Table_AuditTrail" ita
        WHERE ita."ITAT_RecordPKID" = p_FYP_Id 
        AND ita."ITAT_Operation" = 'D'
    ) 
    AND iad."IATD_ColumnName" IN (
        'FYP_Date',
        'FYP_Remarks',
        'FYP_Tot_Amount',
        'FYP_Bank_Or_Cash',
        'FYP_Bank_Name',
        'FYP_DD_Cheque_No',
        'FYP_DD_Cheque_Date'
    );
END;
$$;