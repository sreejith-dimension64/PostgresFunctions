CREATE OR REPLACE FUNCTION "dbo"."Insert_ISM_Driver_Indent"(
    p_MI_Id BIGINT,
    p_ISMDIT_Date TIMESTAMP,
    p_TRMV_Id BIGINT,
    p_ISMDIT_BillNo TEXT,
    p_ISMDIT_Qty DECIMAL,
    p_ISMDIT_Amount DECIMAL,
    p_ISMDIT_Remarks TEXT,
    p_ISMDIT_OpeningKM DECIMAL,
    p_ISMDIT_ClosingKM DECIMAL,
    p_ISMDIT_BalanceDiesel DECIMAL,
    p_ISMDIT_PreviousReading DECIMAL,
    p_ISMDIT_CurrentReading DECIMAL,
    p_CreatedDate TIMESTAMP,
    p_UpdatedDate TIMESTAMP,
    p_ISMDIT_PreparedByUserId BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_MaxISMDIT_Id BIGINT;
BEGIN
    INSERT INTO "ISM_Driver_Indent" (
        "MI_Id",
        "ISMDIT_Date",
        "TRMV_Id",
        "ISMDIT_BillNo",
        "ISMDIT_Qty",
        "ISMDIT_Amount",
        "ISMDIT_Remarks",
        "ISMDIT_OpeningKM",
        "ISMDIT_ClosingKM",
        "ISMDIT_BalanceDiesel",
        "ISMDIT_PreviousReading",
        "ISMDIT_CurrentReading",
        "CreatedDate",
        "UpdatedDate"
    ) VALUES (
        p_MI_Id,
        p_ISMDIT_Date,
        p_TRMV_Id,
        p_ISMDIT_BillNo,
        p_ISMDIT_Qty,
        p_ISMDIT_Amount,
        p_ISMDIT_Remarks,
        p_ISMDIT_OpeningKM,
        p_ISMDIT_ClosingKM,
        p_ISMDIT_BalanceDiesel,
        p_ISMDIT_PreviousReading,
        p_ISMDIT_CurrentReading,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );

    SELECT MAX("ISMDIT_Id") INTO v_MaxISMDIT_Id
    FROM "ISM_Driver_Indent"
    LIMIT 1;

    INSERT INTO "ISM_Driver_Indent_Approval" (
        "ISMDIT_Id",
        "ISMDIT_PreparedByUserId",
        "ISMDIT_ApprovalUserId",
        "ISMDIT_ReceivedByUserId",
        "CreatedDate",
        "UpdatedDate"
    ) VALUES (
        v_MaxISMDIT_Id,
        p_ISMDIT_PreparedByUserId,
        0,
        0,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );

    RETURN;
END;
$$;