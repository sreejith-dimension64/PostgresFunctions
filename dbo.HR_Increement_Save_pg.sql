CREATE OR REPLACE FUNCTION "dbo"."HR_Increement_Save"(
    p_MI_Id bigint,
    p_HRME_Id bigint,
    p_HRMED_Id bigint,
    p_HREICED_Amount decimal,
    p_HREICED_Percentage varchar(15),
    p_Incrementdate date,
    p_userid bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRME_DOJ timestamp;
    v_HRC_MinimumWorkingPeriod bigint;
    v_LastIncrementDate date;
    v_HREIC_IncrementDueDate timestamp;
    v_HREICED_PreviousAmount decimal(18,2);
    v_HREIC_Id bigint;
    v_COUNT bigint;
    v_lastnumber int;
    v_percentamount decimal(18,2);
    v_DateDiff int;
BEGIN

    SELECT CAST("HRME_DOJ" AS date) INTO v_HRME_DOJ 
    FROM "HR_Master_Employee" 
    WHERE "HRME_Id" = p_HRME_Id;
    
    SELECT EXTRACT(YEAR FROM AGE(CURRENT_TIMESTAMP, v_HRME_DOJ)) * 12 + 
           EXTRACT(MONTH FROM AGE(CURRENT_TIMESTAMP, v_HRME_DOJ)) INTO v_DateDiff;

    v_HREIC_IncrementDueDate := p_Incrementdate + INTERVAL '12 months';

    SELECT COUNT(*) INTO v_COUNT 
    FROM "HR_Employee_Increment" 
    WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = p_HRME_Id;

    IF (v_COUNT = 0) THEN
    
        INSERT INTO "HR_Employee_Increment"(
            "MI_Id", "HRME_Id", "HREIC_LastIncrementDate", "HREIC_IncrementDueDate", 
            "HREIC_IncrementDate", "HREIC_ArrearApplicableFlg", "HREIC_ArrearGivenFlg", 
            "HREIC_ArrearMonths", "HREIC_ActiveFlag", "HREIC_CreatedBy", "HREIC_UpdatedBy", 
            "HREIC_CreatedDate", "HREIC_UpdatedDate", "HREIC_NextIncrementGivenDate"
        )
        VALUES(
            p_MI_Id, p_HRME_Id, p_Incrementdate, v_HREIC_IncrementDueDate, 
            p_Incrementdate, 0, 0, 0, 1, p_userid, p_userid, 
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_HREIC_IncrementDueDate
        );

        SELECT "HREIC_Id" INTO v_HREIC_Id 
        FROM "HR_Employee_Increment" 
        WHERE "MI_Id" = p_MI_Id 
            AND "HRME_Id" = p_HRME_Id 
            AND CAST("HREIC_IncrementDate" AS date) = CAST(CURRENT_TIMESTAMP AS date) 
            AND "HREIC_CreatedBy" = p_userid;

        SELECT "HREED_Amount" INTO v_HREICED_PreviousAmount 
        FROM "HR_Employee_EarningsDeductions" 
        WHERE "HRME_Id" = p_HRME_Id AND "HRMED_Id" = p_HRMED_Id;

        INSERT INTO "HR_Employee_Increment_EDHeads"(
            "MI_Id", "HREIC_Id", "HRMED_Id", "HREICED_Amount", "HREICED_Percentage", 
            "HREICED_ActiveFlag", "HREICED_CreatedDate", "HREICED_UpdatedDate", 
            "HREICED_CreatedBy", "HREICED_UpdatedBy", "HREICED_PreviousAmount"
        )
        VALUES(
            p_MI_Id, v_HREIC_Id, p_HRMED_Id, p_HREICED_Amount, p_HREICED_Percentage, 
            1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_userid, p_userid, v_HREICED_PreviousAmount
        );

    ELSIF (v_COUNT > 0) THEN

        SELECT "HREIC_IncrementDate" INTO v_LastIncrementDate 
        FROM "HR_Employee_Increment" 
        WHERE "MI_Id" = p_MI_Id AND "HRME_Id" = p_HRME_Id 
        ORDER BY "HREIC_IncrementDate" DESC 
        LIMIT 1;

        INSERT INTO "HR_Employee_Increment"(
            "MI_Id", "HRME_Id", "HREIC_LastIncrementDate", "HREIC_IncrementDueDate", 
            "HREIC_IncrementDate", "HREIC_ArrearApplicableFlg", "HREIC_ArrearGivenFlg", 
            "HREIC_ArrearMonths", "HREIC_ActiveFlag", "HREIC_CreatedBy", "HREIC_UpdatedBy", 
            "HREIC_CreatedDate", "HREIC_UpdatedDate", "HREIC_NextIncrementGivenDate"
        )
        VALUES(
            p_MI_Id, p_HRME_Id, v_LastIncrementDate, v_HREIC_IncrementDueDate, 
            p_Incrementdate, 0, 0, 0, 1, p_userid, p_userid, 
            CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, v_HREIC_IncrementDueDate
        );

        SELECT "HREIC_Id" INTO v_HREIC_Id 
        FROM "HR_Employee_Increment" 
        WHERE "MI_Id" = p_MI_Id 
            AND "HRME_Id" = p_HRME_Id 
            AND CAST("HREIC_IncrementDate" AS date) = CAST(CURRENT_TIMESTAMP AS date) 
            AND "HREIC_CreatedBy" = p_userid;

        SELECT "HREED_Amount" INTO v_HREICED_PreviousAmount 
        FROM "HR_Employee_EarningsDeductions" 
        WHERE "HRME_Id" = p_HRME_Id AND "HRMED_Id" = p_HRMED_Id;

        INSERT INTO "HR_Employee_Increment_EDHeads"(
            "MI_Id", "HREIC_Id", "HRMED_Id", "HREICED_Amount", "HREICED_Percentage", 
            "HREICED_ActiveFlag", "HREICED_CreatedDate", "HREICED_UpdatedDate", 
            "HREICED_CreatedBy", "HREICED_UpdatedBy", "HREICED_PreviousAmount"
        )
        VALUES(
            p_MI_Id, v_HREIC_Id, p_HRMED_Id, p_HREICED_Amount, p_HREICED_Percentage, 
            1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_userid, p_userid, v_HREICED_PreviousAmount
        );

    END IF;

    IF (p_HREICED_Amount > 0) THEN
    
        UPDATE "HR_Employee_EarningsDeductions" 
        SET "HREED_Amount" = "HREED_Amount" + p_HREICED_Amount 
        WHERE "HRME_Id" = p_HRME_Id AND "HRMED_Id" = p_HRMED_Id;

    ELSE

        v_percentamount := (v_HREICED_PreviousAmount * p_HREICED_Percentage::decimal) / 100;

        SELECT RIGHT(RTRIM(CAST(ROUND(v_percentamount, 0) AS TEXT)), 1)::int INTO v_lastnumber;

        IF (v_lastnumber < 5) THEN

            UPDATE "HR_Employee_EarningsDeductions" 
            SET "HREED_Amount" = ("HREED_Amount" + ROUND(v_percentamount, 0)) - v_lastnumber 
            WHERE "HRME_Id" = p_HRME_Id AND "HRMED_Id" = p_HRMED_Id;

        ELSIF (v_lastnumber >= 5) THEN

            UPDATE "HR_Employee_EarningsDeductions" 
            SET "HREED_Amount" = (("HREED_Amount" + ROUND(v_percentamount, 0)) - v_lastnumber) + 10 
            WHERE "HRME_Id" = p_HRME_Id AND "HRMED_Id" = p_HRMED_Id;

        END IF;

    END IF;

    RETURN;

END;
$$;