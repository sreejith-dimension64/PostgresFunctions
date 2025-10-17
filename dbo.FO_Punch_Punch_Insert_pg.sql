CREATE OR REPLACE FUNCTION "dbo"."FO_Punch_Punch_Insert"(
    p_MI_Id bigint,
    p_Biometric_Id varchar(50),
    p_PunchDate timestamp,
    p_PunchTime varchar(50),
    p_Temparature varchar(50)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRME_Id BIGINT;
    v_HRELAP_Id BIGINT;
    v_HRML_Id BIGINT;
    v_HRELAPD_FromDate timestamp;
    v_count bigint;
    v_FOEP_Id bigint;
    v_countlist bigint;
    v_HRELAPD_ToDate timestamp;
    v_HRELAPD_TotalDays decimal;
    v_Time varchar;
    v_FOEPD_InOutFlg varchar;
    v_datetime timestamp;
BEGIN

    SELECT "HRME_Id" INTO v_HRME_Id 
    FROM "HR_Master_Employee" 
    WHERE "MI_Id" = p_MI_Id 
        AND "HRME_BiometricCode" = p_Biometric_Id 
        AND "HRME_ActiveFlag" = 1 
        AND "HRME_LeftFlag" = 0;

    IF (COALESCE(v_HRME_Id, 0) > 0) THEN
        
        v_datetime := DATE(p_PunchDate);
        v_Time := p_PunchTime;

        IF (p_Biometric_Id::bigint > 0) THEN
            
            INSERT INTO "FO_Emp_BiometricPunch" 
            VALUES(p_MI_Id, p_Biometric_Id, v_datetime, p_PunchTime, 1, 1);

        END IF;

        v_countlist := 0;
        v_FOEP_Id := 0;

        SELECT COUNT(*) INTO v_countlist 
        FROM "FO"."FO_Emp_Punch_Details" 
        WHERE "MI_Id" = p_MI_Id 
            AND "FOEPD_PunchTime" = v_Time 
            AND "FOEP_Id" IN (
                SELECT "FOEP_Id" 
                FROM "FO"."FO_Emp_Punch" 
                WHERE "MI_Id" = p_MI_Id 
                    AND "HRME_Id" = v_HRME_Id 
                    AND DATE("FOEP_PunchDate") = DATE(v_datetime)
            );

        SELECT "FOEP_Id" INTO v_FOEP_Id 
        FROM "FO"."FO_Emp_Punch" 
        WHERE "MI_Id" = p_MI_Id 
            AND "HRME_Id" = v_HRME_Id 
            AND DATE("FOEP_PunchDate") = DATE(v_datetime)
        ORDER BY "HRME_Id", "FOEP_PunchDate" DESC
        LIMIT 1;

        IF (COALESCE(v_countlist, 0) = 0) THEN
            
            IF (COALESCE(v_FOEP_Id, 0) > 0) THEN
                
                SELECT "FOEPD_InOutFlg" INTO v_FOEPD_InOutFlg 
                FROM "FO"."FO_Emp_Punch_Details" 
                WHERE "MI_Id" = p_MI_Id 
                    AND "FOEP_Id" = v_FOEP_Id
                ORDER BY "FOEPD_Id" DESC
                LIMIT 1;

                INSERT INTO "FO"."FO_Emp_Punch_Details"(
                    "MI_Id", "FOEP_Id", "FOEPD_PunchTime", "FOEPD_InOutFlg", 
                    "FOEPD_Flag", "CreatedDate", "UpdatedDate", "FOEPD_Temperature"
                )
                VALUES(
                    p_MI_Id, v_FOEP_Id, v_Time, 
                    CASE WHEN v_FOEPD_InOutFlg = 'I' THEN 'O' ELSE 'I' END, 
                    1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_Temparature
                );

            ELSE
                
                INSERT INTO "FO"."FO_Emp_Punch"(
                    "MI_Id", "HRME_Id", "FOEP_PunchDate", "FOEP_HolidayPunchFlg", 
                    "FOEP_Flag", "CreatedDate", "UpdatedDate"
                )
                VALUES(
                    p_MI_Id, v_HRME_Id, DATE(v_datetime), 0, 
                    1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
                )
                RETURNING "FOEP_Id" INTO v_FOEP_Id;

                IF (COALESCE(v_FOEP_Id, 0) > 0) THEN
                    
                    INSERT INTO "FO"."FO_Emp_Punch_Details"(
                        "MI_Id", "FOEP_Id", "FOEPD_PunchTime", "FOEPD_InOutFlg", 
                        "FOEPD_Flag", "CreatedDate", "UpdatedDate", "FOEPD_Temperature"
                    )
                    VALUES(
                        p_MI_Id, v_FOEP_Id, v_Time, 'I', 
                        1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, p_Temparature
                    );

                END IF;

            END IF;

        END IF;

    END IF;

    RETURN;

END;
$$;