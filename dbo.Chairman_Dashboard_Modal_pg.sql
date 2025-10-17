CREATE OR REPLACE FUNCTION "Chairman_Dashboard_Modal"(
    p_id BIGINT,
    p_Type TEXT
)
RETURNS TABLE (
    "MI_Name" VARCHAR,
    "studentcount" BIGINT,
    "Employeecount" BIGINT,
    "Tobepaid" NUMERIC,
    "FSS_CurrentYrCharges" NUMERIC,
    "FSS_PaidAmount" NUMERIC,
    "Preadmissioncount" BIGINT,
    "admissioncount" BIGINT,
    "tccount" BIGINT,
    "salarycount" DOUBLE PRECISION,
    "defaultercount" BIGINT,
    "bookcount" BIGINT,
    "eventcount" BIGINT,
    "transport" BIGINT,
    "MI_Id" BIGINT,
    "PASS_PERCENTAGE" BIGINT,
    "FAIL_PERCENTAGE" BIGINT,
    "Absent" BIGINT,
    "present" BIGINT,
    "interactioncount" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (p_Type = 'Student') THEN
        RETURN QUERY
        SELECT 
            "B"."MI_Name",
            COUNT("C"."AMST_Id") as studentcount,
            NULL::BIGINT, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::DOUBLE PRECISION,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT
        FROM "Adm_M_Student" "A"
        INNER JOIN "Master_Institution" "B" ON "B"."MI_Id" = "A"."MI_Id"
        INNER JOIN "Adm_School_Y_Student" "C" ON "C"."AMST_Id" = "A"."AMST_Id"
        WHERE "A"."AMST_ActiveFlag" = 1
        AND "B"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        AND "C"."ASMAY_Id" IN (
            SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
            WHERE "MI_ID" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
            AND (CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS DATE) AND CAST("ASMAy_To_Date" AS DATE))
        )
        GROUP BY "B"."MI_Name";

    ELSIF (p_Type = 'Employee') THEN
        RETURN QUERY
        SELECT 
            "B"."MI_Name",
            NULL::BIGINT,
            COUNT(DISTINCT "A"."HRME_id") as Employeecount,
            NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::DOUBLE PRECISION,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT
        FROM "HR_MAster_EMployee" "A"
        INNER JOIN "Master_Institution" "B" ON "B"."MI_Id" = "A"."MI_Id"
        WHERE "A"."HRME_ActiveFlag" = 1
        AND "B"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        GROUP BY "B"."MI_Name";

    ELSIF (p_Type = 'Payment') THEN
        RETURN QUERY
        SELECT 
            "C"."MI_Name",
            NULL::BIGINT, NULL::BIGINT,
            SUM("A"."FSS_ToBePaid") as Tobepaid,
            SUM("A"."FSS_CurrentYrCharges") as FSS_CurrentYrCharges,
            SUM("A"."FSS_PaidAmount") as FSS_PaidAmount,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::DOUBLE PRECISION,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT
        FROM "Fee_Student_Status" "A"
        INNER JOIN "Adm_School_M_Academic_Year" "B" ON "B"."ASMAY_ID" = "A"."ASMAY_ID"
        INNER JOIN "Master_Institution" "C" ON "C"."MI_Id" = "B"."MI_Id"
        WHERE "C"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        AND "B"."ASMAY_Id" IN (
            SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
            WHERE (CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS DATE) AND CAST("ASMAy_To_Date" AS DATE))
            AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        )
        GROUP BY "C"."MI_Name";

    ELSIF (p_Type = 'Preadmission') THEN
        RETURN QUERY
        SELECT 
            "B"."MI_Name",
            NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            COUNT("A"."PASR_id") as Preadmissioncount,
            NULL::BIGINT, NULL::BIGINT, NULL::DOUBLE PRECISION,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT
        FROM "Preadmission_School_Registration" "A"
        INNER JOIN "Master_Institution" "B" ON "B"."MI_Id" = "A"."MI_Id"
        WHERE "B"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        AND "A"."ASMAY_Id" IN (
            SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
            WHERE (CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS DATE) AND CAST("ASMAy_To_Date" AS DATE))
            AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        )
        GROUP BY "B"."MI_Name";

    ELSIF (p_Type = 'Admission') THEN
        RETURN QUERY
        SELECT 
            "D"."MI_Name",
            NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            NULL::BIGINT,
            COUNT(DISTINCT "A"."AMST_id") as admissioncount,
            NULL::BIGINT, NULL::DOUBLE PRECISION,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT
        FROM "Adm_M_Student" "A"
        INNER JOIN "Adm_School_Y_Student" "B" ON "B"."AMST_id" = "A"."AMST_id"
        INNER JOIN "Adm_School_M_Academic_Year" "C" ON "C"."ASMAY_Id" = "A"."ASMAY_Id"
        INNER JOIN "Master_Institution" "D" ON "D"."MI_Id" = "C"."MI_Id"
        WHERE "D"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        AND "B"."ASMAY_Id" IN (
            SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
            WHERE (CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS DATE) AND CAST("ASMAy_To_Date" AS DATE))
            AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        )
        GROUP BY "D"."MI_Name";

    ELSIF (p_Type = 'TcIssued') THEN
        RETURN QUERY
        SELECT 
            "B"."MI_Name",
            NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            NULL::BIGINT, NULL::BIGINT,
            COUNT(DISTINCT "A"."ASTC_id") as tccount,
            NULL::DOUBLE PRECISION,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT
        FROM "Adm_Student_TC" "A"
        INNER JOIN "Master_Institution" "B" ON "B"."MI_Id" = "A"."MI_Id"
        WHERE "B"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        AND "A"."ASMAY_Id" IN (
            SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
            WHERE (CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS DATE) AND CAST("ASMAy_To_Date" AS DATE))
            AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        )
        GROUP BY "B"."MI_Name";

    ELSIF (p_Type = 'Salary') THEN
        RETURN QUERY
        SELECT 
            "B"."MI_Name",
            NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            SUM("A"."HRES_WorkingDays" * CAST("A"."HRES_DailyRates" AS DOUBLE PRECISION)) as salarycount,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT
        FROM "HR_Employee_Salary" "A"
        INNER JOIN "Master_Institution" "B" ON "B"."MI_Id" = "A"."MI_Id"
        WHERE "B"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        GROUP BY "B"."MI_Name";

    ELSIF (p_Type = 'Defaulter') THEN
        RETURN QUERY
        SELECT 
            "B"."MI_Name",
            NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::DOUBLE PRECISION,
            COUNT(DISTINCT "A"."FSS_Id") as defaultercount,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT
        FROM "Fee_Student_Status" "A"
        INNER JOIN "Master_Institution" "B" ON "B"."MI_Id" = "A"."MI_Id"
        WHERE "A"."FSS_PaidAmount" > 0
        AND "B"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        AND "A"."ASMAY_Id" IN (
            SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
            WHERE (CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS DATE) AND CAST("ASMAy_To_Date" AS DATE))
            AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        )
        GROUP BY "B"."MI_Name";

    ELSIF (p_Type = 'Book') THEN
        RETURN QUERY
        SELECT 
            "B"."MI_Name",
            NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::DOUBLE PRECISION,
            NULL::BIGINT,
            COUNT(DISTINCT "A"."LMB_id") as bookcount,
            NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT
        FROM "LIB"."LIB_Master_Book" "A"
        INNER JOIN "Master_Institution" "B" ON "B"."MI_Id" = "A"."MI_Id"
        WHERE "B"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        GROUP BY "B"."MI_Name";

    ELSIF (p_Type = 'Event') THEN
        RETURN QUERY
        SELECT 
            "B"."MI_Name",
            NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::DOUBLE PRECISION,
            NULL::BIGINT, NULL::BIGINT,
            COUNT(DISTINCT "A"."COEE_Id") as eventcount,
            NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT
        FROM "COE"."COE_Events" "A"
        INNER JOIN "Master_Institution" "B" ON "B"."MI_Id" = "A"."MI_Id"
        WHERE "B"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        GROUP BY "B"."MI_Name";

    ELSIF (p_Type = 'Transport') THEN
        RETURN QUERY
        SELECT 
            "B"."MI_Name",
            NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::DOUBLE PRECISION,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            COUNT(DISTINCT "A"."TRMV_Id") as transport,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT
        FROM "TRN"."TR_Master_Vehicle" "A"
        INNER JOIN "Master_Institution" "B" ON "B"."MI_Id" = "A"."MI_Id"
        WHERE "B"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        GROUP BY "B"."MI_Name";

    ELSIF (p_Type = 'Result') THEN
        RETURN QUERY
        WITH "MasterInstitute" AS (
            SELECT "MI_Id", "MI_Name"
            FROM "Master_Institution"
            WHERE "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        ),
        "PASS_PERCENTAGE" AS (
            SELECT "B"."MI_ID", "B"."MI_Name", COUNT("A"."ESTMP_Id") as pass_count
            FROM "Exm"."Exm_Student_Marks_Process" "A"
            INNER JOIN "Master_Institution" "B" ON "B"."MI_Id" = "A"."MI_Id"
            WHERE "B"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
            AND "A"."ESTMP_Result" = 'Pass'
            AND "A"."ASMAY_Id" IN (
                SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
                WHERE (CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS DATE) AND CAST("ASMAy_To_Date" AS DATE))
                AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
            )
            GROUP BY "B"."MI_Name", "B"."MI_ID"
        ),
        "FAIL_PERCENTAGE" AS (
            SELECT "B"."MI_ID", "B"."MI_Name", COUNT("A"."ESTMP_Id") as fail_count
            FROM "Exm"."Exm_Student_Marks_Process" "A"
            INNER JOIN "Master_Institution" "B" ON "B"."MI_Id" = "A"."MI_Id"
            WHERE "B"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
            AND "A"."ESTMP_Result" = 'Fail'
            AND "A"."ASMAY_Id" IN (
                SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
                WHERE (CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS DATE) AND CAST("ASMAy_To_Date" AS DATE))
                AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
            )
            GROUP BY "B"."MI_Name", "B"."MI_ID"
        )
        SELECT 
            "MT"."MI_Name",
            NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::DOUBLE PRECISION,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            "MT"."MI_Id",
            COALESCE("TPC".pass_count, 0) as PASS_PERCENTAGE,
            COALESCE("TC".fail_count, 0) as FAIL_PERCENTAGE,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT
        FROM "MasterInstitute" "MT"
        INNER JOIN "PASS_PERCENTAGE" "TPC" ON "MT"."MI_Id" = "TPC"."MI_ID"
        INNER JOIN "FAIL_PERCENTAGE" "TC" ON "MT"."MI_Id" = "TC"."MI_ID";

    ELSIF (p_Type = 'Attendence') THEN
        RETURN QUERY
        SELECT 
            "B"."MI_Name",
            NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::DOUBLE PRECISION,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            COALESCE(CASE WHEN "A"."ASA_Att_EntryType" = 'Absent' THEN COUNT("A"."ASA_Id") END, 0) as Absent,
            COALESCE(CASE WHEN "A"."ASA_Att_EntryType" = 'Present' THEN COUNT("A"."ASA_Id") END, 0) as present,
            NULL::BIGINT
        FROM "Adm_Student_Attendance" "A"
        INNER JOIN "Master_Institution" "B" ON "B"."MI_Id" = "A"."MI_Id"
        WHERE "B"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        AND "A"."ASMAY_Id" IN (
            SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
            WHERE (CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS DATE) AND CAST("ASMAy_To_Date" AS DATE))
            AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        )
        GROUP BY "B"."MI_Name", "A"."ASA_Att_EntryType";

    ELSIF (p_Type = 'Interaction') THEN
        RETURN QUERY
        SELECT 
            "B"."MI_Name",
            NULL::BIGINT, NULL::BIGINT, NULL::NUMERIC, NULL::NUMERIC, NULL::NUMERIC,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::DOUBLE PRECISION,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT,
            COUNT("A"."ISMINT_Id") as interactioncount
        FROM "IVRM_School_Master_Interactions" "A"
        INNER JOIN "Master_Institution" "B" ON "B"."MI_Id" = "A"."MI_Id"
        WHERE "B"."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        AND "A"."ASMAY_Id" IN (
            SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
            WHERE (CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS DATE) AND CAST("ASMAy_To_Date" AS DATE))
            AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE "Id" = p_id)
        )
        GROUP BY "B"."MI_Name";

    END IF;

END;
$$;