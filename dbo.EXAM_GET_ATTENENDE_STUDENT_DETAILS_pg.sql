CREATE OR REPLACE FUNCTION "dbo"."EXAM_GET_ATTENENDE_STUDENT_DETAILS"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@FLAG" TEXT,
    "@AMST_Id" TEXT,
    "@FROM_DATE" DATE,
    "@TO_DATE" DATE
)
RETURNS TABLE(
    "TOTALWORKINGDAYS" DECIMAL(18,2),
    "PRESENTDAYS" DECIMAL(18,2),
    "ABSENTDAYS" DECIMAL(18,2),
    "ATTENDANCEPERCENTAGE" DECIMAL(18,2),
    "AMST_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@EYC_Id" BIGINT;
    "@EMCA_Id" BIGINT;
    "@SQL" TEXT;
    "@SQLQUERY" TEXT;
    "@FROMDATE" DATE;
    "@TODATE" DATE;
    "@AMST_IdtEMP" BIGINT;
    "v_rec" RECORD;
BEGIN

    SELECT "EMCA_Id" INTO "@EMCA_Id" 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT 
        AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "ASMCL_Id" = "@ASMCL_Id"::BIGINT 
        AND "ASMS_Id" = "@ASMS_Id"::BIGINT
        AND "ECAC_ActiveFlag" = 1
    LIMIT 1;

    SELECT "EYC_Id" INTO "@EYC_Id" 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT 
        AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "EMCA_Id" = "@EMCA_Id" 
        AND "EYC_ActiveFlg" = 1
    LIMIT 1;

    DROP TABLE IF EXISTS "NDS_Jr_Sr_KG_EXAM_LIST";

    DROP TABLE IF EXISTS "NDS_Temp_StudentDetails_Amstids";

    "@SQLQUERY" := 'CREATE TEMP TABLE "NDS_Temp_StudentDetails_Amstids" AS 
                    SELECT DISTINCT "AMST_Id" 
                    FROM "ADM_M_STUDENT" 
                    WHERE "AMST_Id" IN(' || "@AMST_Id" || ') 
                    AND "MI_Id" = ' || "@MI_Id";
    
    EXECUTE "@SQLQUERY";

    IF "@FLAG" = '4' THEN
    
        DROP TABLE IF EXISTS "NDS_Jr_Sr_KG_ATTENDANCE_LIST";

        CREATE TEMP TABLE "NDS_Jr_Sr_KG_ATTENDANCE_LIST" (
            "TOTALWORKINGDAYS" DECIMAL(18,2), 
            "PRESENTDAYS" DECIMAL(18,2), 
            "ABSENTDAYS" DECIMAL(18,2), 
            "ATTENDANCEPERCENTAGE" DECIMAL(18,2),
            "AMST_Id" BIGINT
        );

        FOR "v_rec" IN 
            SELECT "AMST_Id" 
            FROM "NDS_Temp_StudentDetails_Amstids"
        LOOP
            "@AMST_IdtEMP" := "v_rec"."AMST_Id";

            INSERT INTO "NDS_Jr_Sr_KG_ATTENDANCE_LIST" (
                "TOTALWORKINGDAYS",
                "PRESENTDAYS",
                "ABSENTDAYS",
                "ATTENDANCEPERCENTAGE",
                "AMST_Id"
            )
            SELECT 
                SUM("A"."ASA_ClassHeld") AS "TOTALWORKINGDAYS", 
                SUM("A"."ASA_Class_Attended") AS "PRESENTDAYS",
                (SUM("A"."ASA_ClassHeld") - SUM("A"."ASA_Class_Attended")) AS "ABSENTDAYS",
                CAST(SUM("A"."ASA_Class_Attended") * 100.0 / NULLIF(SUM("A"."ASA_ClassHeld"), 0) AS DECIMAL(18,2)) AS "ATTENDANCEPERCENTAGE",
                "B"."AMST_Id"
            FROM "Adm_Student_Attendance" "A"
            INNER JOIN "Adm_Student_Attendance_Students" "B" ON "A"."ASA_Id" = "B"."ASA_Id"
            INNER JOIN "Adm_School_Y_Student" "C" ON "C"."AMST_Id" = "B"."AMST_Id"
            INNER JOIN "Adm_M_Student" "D" ON "D"."AMST_Id" = "B"."AMST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" "E" ON "E"."ASMAY_Id" = "C"."ASMAY_Id"
            INNER JOIN "Adm_School_M_Class" "F" ON "F"."ASMCL_Id" = "C"."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" "G" ON "G"."ASMS_Id" = "C"."ASMS_Id"
            WHERE "A"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
                AND "A"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
                AND "A"."ASMS_Id" = "@ASMS_Id"::BIGINT 
                AND "A"."ASA_Activeflag" = 1 
                AND "A"."MI_Id" = "@MI_Id"::BIGINT
                AND "C"."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
                AND "C"."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
                AND "C"."ASMS_Id" = "@ASMS_Id"::BIGINT 
                AND "B"."AMST_Id" = "@AMST_IdtEMP" 
                AND "C"."AMST_Id" = "@AMST_IdtEMP"
                AND (("A"."ASA_FromDate" BETWEEN "@FROM_DATE" AND "@TO_DATE") 
                     OR ("A"."ASA_ToDate" BETWEEN "@FROM_DATE" AND "@TO_DATE"))
            GROUP BY "B"."AMST_Id";

        END LOOP;

        RETURN QUERY 
        SELECT 
            "NDS_Jr_Sr_KG_ATTENDANCE_LIST"."TOTALWORKINGDAYS",
            "NDS_Jr_Sr_KG_ATTENDANCE_LIST"."PRESENTDAYS",
            "NDS_Jr_Sr_KG_ATTENDANCE_LIST"."ABSENTDAYS",
            "NDS_Jr_Sr_KG_ATTENDANCE_LIST"."ATTENDANCEPERCENTAGE",
            "NDS_Jr_Sr_KG_ATTENDANCE_LIST"."AMST_Id"
        FROM "NDS_Jr_Sr_KG_ATTENDANCE_LIST";

    END IF;

    RETURN;

END;
$$;