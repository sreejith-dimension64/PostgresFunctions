CREATE OR REPLACE FUNCTION "dbo"."IVRM_MEMO_NOTICE_Outgoing"(
    p_HRME_ID bigint,
    p_ASMAY_ID bigint,
    p_MI_Id text,
    p_ISMEMN_No text,
    p_ISMEMN_Type text,
    p_ISMEMN_Description text,
    p_ISMEMN_CreatedBy bigint,
    p_INDDate timestamp,
    p_COMPDate timestamp,
    p_startdate timestamp,
    p_Enddate timestamp
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_date timestamp;
BEGIN
    v_date := CURRENT_TIMESTAMP;
    
    INSERT INTO "ISM_EMPLOYEE_MEMO_NOTICE"(
        "HRME_ID",
        "ASMAY_ID",
        "MI_ID",
        "ISMEMN_No",
        "ISMEMN_Date",
        "ISMEMN_Type",
        "ISMEMN_Description",
        "ISMEMN_CreatedBy",
        "ISMEMN_UpdatedBy",
        "CreatedDate",
        "UpdatedDate",
        "ISMEMN_EmailSentFlag",
        "ISMEMN_CompleByDate",
        "ISMEMN_Startdate",
        "ISMEMN_Enddate"
    )
    VALUES(
        p_HRME_ID,
        p_ASMAY_ID,
        p_MI_Id,
        p_ISMEMN_No,
        p_INDDate,
        p_ISMEMN_Type,
        p_ISMEMN_Description,
        p_ISMEMN_CreatedBy,
        p_ISMEMN_CreatedBy,
        p_INDDate,
        p_INDDate,
        0,
        p_COMPDate,
        p_startdate,
        p_Enddate
    );
    
    RETURN;
END;
$$;