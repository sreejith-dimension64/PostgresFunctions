CREATE OR REPLACE FUNCTION "dbo"."FO_FaceReaderLogData_Import"(
    "FromDate" varchar(10),
    "ToDate" varchar(10)
)
RETURNS TABLE(
    "EMP_Code" bigint,
    "Fo_date" date,
    "FirstPunchTime" varchar(50),
    "NextPunchTime" varchar(50)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_EMPId bigint;
    v_FO_FirstPunchTime varchar(30);
    v_FO_NextPunchTime varchar(30);
    v_fo_date date;
    v_Rcount int;
    empids_rec RECORD;
    fodates_rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "FO_FaceReaderEmpDetails_Temp";

    CREATE TEMP TABLE "FO_FaceReaderEmpDetails_Temp"(
        "EMP_Id" bigint,
        "Fo_date" date,
        "FirstPunchTime" varchar(50),
        "NextPunchTime" varchar(50)
    );

    FOR empids_rec IN 
        SELECT DISTINCT "EMPID" FROM "BBHS_FO_Log_Temp"
    LOOP
        v_EMPId := empids_rec."EMPID";

        FOR fodates_rec IN 
            SELECT DISTINCT CAST("fo_date" AS date) AS fo_date 
            FROM "BBHS_FO_Log_Temp" 
            WHERE "EMPID" = v_EMPId 
            AND CAST("fo_date" AS date) BETWEEN CAST("FromDate" AS date) AND CAST("ToDate" AS date)
        LOOP
            v_fo_date := fodates_rec.fo_date;

            v_FO_FirstPunchTime := '';
            v_FO_NextPunchTime := '';

            SELECT 
                MIN(CAST("fo_date" AS time(0)))::varchar,
                MAX(CAST("fo_date" AS time(0)))::varchar
            INTO v_FO_FirstPunchTime, v_FO_NextPunchTime
            FROM "BBHS_FO_Log_Temp"
            WHERE "empid" = v_EMPId 
            AND CAST("fo_date" AS date) = v_fo_date
            GROUP BY "empid", CAST("fo_date" AS date);

            v_Rcount := 0;
            SELECT COUNT(*) 
            INTO v_Rcount
            FROM "FO_FaceReaderEmpDetails_Temp"
            WHERE "Fo_date" = v_fo_date 
            AND "FirstPunchTime" = v_FO_FirstPunchTime;

            IF (v_Rcount = 0) THEN

                IF (v_FO_FirstPunchTime = v_FO_NextPunchTime) THEN
                    v_FO_NextPunchTime := '';
                END IF;

                INSERT INTO "FO_FaceReaderEmpDetails_Temp" 
                VALUES(v_EMPId, v_fo_date, v_FO_FirstPunchTime, v_FO_NextPunchTime);

            END IF;

        END LOOP;

    END LOOP;

    RETURN QUERY
    SELECT 
        "EMP_Id" AS "EMP_Code",
        "Fo_date",
        "FirstPunchTime",
        "NextPunchTime" 
    FROM "FO_FaceReaderEmpDetails_Temp";

END;
$$;