CREATE OR REPLACE FUNCTION "dbo"."Adm_Student_Attendanceshortage_Insertion"(
    p_MI_ID BIGINT,
    p_ASMAY_ID BIGINT,
    p_USERID BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_IVRMGC_AttendanceShortageAlertFlg BOOLEAN;
    v_IVRMGC_AttendanceShortagePercent VARCHAR(10);
    v_IVRMGC_AttShortageAlertDays BIGINT;
    v_COUNT BIGINT;
    v_ASMAY_From_Date DATE;
    v_CURRENTDATE DATE;
    v_ASASHORT_Id BIGINT;
    v_ASMCL_Id BIGINT;
    v_ASMS_Id BIGINT;
    v_AMST_Id BIGINT;
    v_ASASHORT_AlertDate DATE;
    rec RECORD;
BEGIN

    SELECT "IVRMGC_AttendanceShortageAlertFlg",
           "IVRMGC_AttendanceShortagePercent"::VARCHAR(10),
           "IVRMGC_AttShortageAlertDays"
    INTO v_IVRMGC_AttendanceShortageAlertFlg,
         v_IVRMGC_AttendanceShortagePercent,
         v_IVRMGC_AttShortageAlertDays
    FROM "IVRM_General_Cofiguration"
    WHERE "MI_Id" = p_MI_ID;

    v_CURRENTDATE := CURRENT_DATE;

    IF (v_IVRMGC_AttendanceShortageAlertFlg = TRUE) THEN

        SELECT COUNT(*) INTO v_COUNT
        FROM "Adm_Student_Attendance_Shortage"
        WHERE "MI_Id" = p_MI_ID;

        SELECT "ASMAY_From_Date"::DATE INTO v_ASMAY_From_Date
        FROM "Adm_School_M_Academic_Year"
        WHERE "MI_Id" = p_MI_ID;

        IF (v_COUNT = 0) THEN

            IF ((v_CURRENTDATE - v_ASMAY_From_Date) = v_IVRMGC_AttShortageAlertDays) THEN

                INSERT INTO "Adm_Student_Attendance_Shortage"
                VALUES(p_MI_ID, v_CURRENTDATE, v_CURRENTDATE, v_CURRENTDATE, p_USERID, p_USERID);

                SELECT "ASASHORT_Id" INTO v_ASASHORT_Id
                FROM "Adm_Student_Attendance_Shortage"
                WHERE "MI_Id" = p_MI_ID
                ORDER BY "ASASHORT_Id" DESC
                LIMIT 1;

                PERFORM "AttendanceReport_perc_shortageAlert"(p_MI_ID, p_ASMAY_ID, v_IVRMGC_AttendanceShortagePercent);

                FOR rec IN
                    SELECT DISTINCT "ASMCL_Id", "ASMS_Id", "AMST_Id"
                    FROM "Student_Attendance_percentage_Temp"
                LOOP
                    v_ASMCL_Id := rec."ASMCL_Id";
                    v_ASMS_Id := rec."ASMS_Id";
                    v_AMST_Id := rec."AMST_Id";

                    INSERT INTO "Adm_Student_Attendance_Shortage_Students"
                    VALUES(v_ASASHORT_Id, v_ASMCL_Id, v_ASMS_Id, v_AMST_Id, v_CURRENTDATE, v_CURRENTDATE, p_USERID, p_USERID);

                END LOOP;

            END IF;

        ELSIF (v_COUNT > 0) THEN

            SELECT "ASASHORT_AlertDate", "ASASHORT_Id"
            INTO v_ASASHORT_AlertDate, v_ASASHORT_Id
            FROM "Adm_Student_Attendance_Shortage"
            WHERE "MI_Id" = p_MI_ID
            ORDER BY "ASASHORT_Id" DESC
            LIMIT 1;

            IF ((v_CURRENTDATE - v_ASASHORT_AlertDate) = v_IVRMGC_AttShortageAlertDays) THEN

                INSERT INTO "Adm_Student_Attendance_Shortage"
                VALUES(p_MI_ID, v_CURRENTDATE, v_CURRENTDATE, v_CURRENTDATE, p_USERID, p_USERID);

                PERFORM "AttendanceReport_perc_shortageAlert"(p_MI_ID, p_ASMAY_ID, v_IVRMGC_AttendanceShortagePercent);

                FOR rec IN
                    SELECT "ASMCL_Id", "ASMS_Id", "AMST_Id"
                    FROM "Student_Attendance_percentage_Temp"
                LOOP
                    v_ASMCL_Id := rec."ASMCL_Id";
                    v_ASMS_Id := rec."ASMS_Id";
                    v_AMST_Id := rec."AMST_Id";

                    INSERT INTO "Adm_Student_Attendance_Shortage_Students"
                    VALUES(v_ASASHORT_Id, v_ASMCL_Id, v_ASMS_Id, v_AMST_Id, v_CURRENTDATE, v_CURRENTDATE, p_USERID, p_USERID);

                END LOOP;

            END IF;

        END IF;

    END IF;

END;
$$;