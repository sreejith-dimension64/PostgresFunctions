CREATE OR REPLACE FUNCTION "dbo"."AddLeaveApplAuthorisation"(
    p_HRELAP_Id BIGINT,
    p_HRME_Id BIGINT,
    p_HRELAPA_Remarks TEXT,
    p_HRELAPA_InTime VARCHAR(10),
    p_HRELAPA_OutTime VARCHAR(10)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO "HR_Emp_Leave_Appl_Authorisation"(
        "HRELAP_Id",
        "HRME_Id",
        "HRELAPA_SanctioningLevel",
        "HRELAPA_Remarks",
        "HRELAPA_FinalFlag",
        "CreatedDate",
        "UpdatedDate",
        "HRELAPA_InTime",
        "HRELAPA_OutTime"
    ) 
    VALUES(
        p_HRELAP_Id,
        p_HRME_Id,
        '1',
        p_HRELAPA_Remarks,
        '1',
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        p_HRELAPA_InTime,
        p_HRELAPA_OutTime
    );
END;
$$;