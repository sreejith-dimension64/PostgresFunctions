CREATE OR REPLACE FUNCTION "Chairman_Dashboard_Count"(p_id bigint)
RETURNS TABLE(
    studentcount bigint,
    employeescount bigint,
    "Paymentcount" numeric,
    "Preadmissionscount" bigint,
    "Admissioncount" bigint,
    "Tccount" bigint,
    "Salarycount" numeric,
    passcount bigint,
    failcount bigint,
    "Bookscount" bigint,
    "Eventscount" bigint,
    "Transportscount" bigint,
    "Defaulterscount" bigint,
    "Interactioncount" bigint,
    absentcount bigint,
    presentcount bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_studentcount bigint;
    v_Employeecount bigint;
    v_Paymentcount numeric;
    v_Preadmissioncount bigint;
    v_Admissioncount bigint;
    v_Tccount bigint;
    v_Salarycount numeric;
    v_Passcount bigint;
    v_Failcount bigint;
    v_Bookcount bigint;
    v_Eventcount bigint;
    v_Transportcount bigint;
    v_Presentcount bigint;
    v_Absentcount bigint;
    v_Defaultercount bigint;
    v_Interactioncount bigint;
BEGIN
    v_studentcount := 0;
    v_Employeecount := 0;
    v_Paymentcount := 0;
    v_Preadmissioncount := 0;
    v_Admissioncount := 0;
    v_Tccount := 0;
    v_Salarycount := 0;
    v_Passcount := 0;
    v_Failcount := 0;
    v_Bookcount := 0;
    v_Eventcount := 0;
    v_Transportcount := 0;
    v_Presentcount := 0;
    v_Absentcount := 0;
    v_Defaultercount := 0;
    v_Interactioncount := 0;

    SELECT count(DISTINCT "AMST_id") INTO v_studentcount
    FROM "Adm_M_Student"
    WHERE "AMST_ActiveFlag" = true
    AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    AND "ASMAY_Id" IN (
        SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
        WHERE CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS date) AND CAST("ASMAy_To_Date" AS date)
        AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    );

    SELECT count(DISTINCT "HRME_id") INTO v_Employeecount
    FROM "HR_MAster_EMployee"
    WHERE "HRME_ActiveFlag" = true
    AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id);

    SELECT sum("FSS_ToBePaid" + "FSS_CurrentYrCharges" + "FSS_CurrentYrCharges") INTO v_Paymentcount
    FROM "Fee_Student_Status"
    WHERE "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    AND "ASMAY_Id" IN (
        SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
        WHERE CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS date) AND CAST("ASMAy_To_Date" AS date)
        AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    );

    SELECT count(DISTINCT "PASR_id") INTO v_Preadmissioncount
    FROM "Preadmission_School_Registration"
    WHERE "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    AND "ASMAY_Id" IN (
        SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
        WHERE CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS date) AND CAST("ASMAy_To_Date" AS date)
        AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    );

    SELECT count(DISTINCT a."AMST_id") INTO v_Admissioncount
    FROM "Adm_M_Student" a
    INNER JOIN "Adm_School_Y_Student" b ON b."AMST_id" = a."AMST_id"
    WHERE a."MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    AND b."ASMAY_Id" IN (
        SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
        WHERE CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS date) AND CAST("ASMAy_To_Date" AS date)
        AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    );

    SELECT count(DISTINCT "ASTC_id") INTO v_Tccount
    FROM "Adm_Student_TC"
    WHERE "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    AND "ASMAY_Id" IN (
        SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
        WHERE CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS date) AND CAST("ASMAy_To_Date" AS date)
        AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    );

    SELECT sum("HRES_WorkingDays" * CAST("HRES_DailyRates" AS numeric)) INTO v_Salarycount
    FROM "HR_Employee_Salary"
    WHERE "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id);

    SELECT count(DISTINCT "ESTMP_Id") INTO v_Passcount
    FROM "Exm"."Exm_Student_Marks_Process"
    WHERE "ESTMP_Result" = 'Pass'
    AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    AND "ASMAY_Id" IN (
        SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
        WHERE CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS date) AND CAST("ASMAy_To_Date" AS date)
        AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    );

    SELECT count(DISTINCT "ESTMP_Id") INTO v_Failcount
    FROM "Exm"."Exm_Student_Marks_Process"
    WHERE "ESTMP_Result" = 'Fail'
    AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    AND "ASMAY_Id" IN (
        SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
        WHERE CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS date) AND CAST("ASMAy_To_Date" AS date)
        AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    );

    SELECT count(DISTINCT "FSS_Id") INTO v_Defaultercount
    FROM "Fee_Student_Status"
    WHERE "FSS_PaidAmount" > 0
    AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    AND "ASMAY_Id" IN (
        SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
        WHERE CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS date) AND CAST("ASMAy_To_Date" AS date)
        AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    );

    SELECT count(DISTINCT "LMB_id") INTO v_Bookcount
    FROM "LIB"."LIB_Master_Book"
    WHERE "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id);

    SELECT count(DISTINCT "COEE_Id") INTO v_Eventcount
    FROM "COE"."COE_Events"
    WHERE "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id);

    SELECT count(DISTINCT "TRMV_Id") INTO v_Transportcount
    FROM "TRN"."TR_Master_Vehicle"
    WHERE "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id);

    SELECT count(DISTINCT "ASA_Id") INTO v_Absentcount
    FROM "Adm_Student_Attendance"
    WHERE "ASA_Att_EntryType" = 'Absent'
    AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    AND "ASMAY_Id" IN (
        SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
        WHERE CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS date) AND CAST("ASMAy_To_Date" AS date)
        AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    );

    SELECT count(DISTINCT "ASA_Id") INTO v_Presentcount
    FROM "Adm_Student_Attendance"
    WHERE "ASA_Att_EntryType" = 'Present'
    AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    AND "ASMAY_Id" IN (
        SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
        WHERE CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS date) AND CAST("ASMAy_To_Date" AS date)
        AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    );

    SELECT count(DISTINCT "ISMINT_Id") INTO v_Interactioncount
    FROM "IVRM_School_Master_Interactions"
    WHERE "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    AND "ASMAY_Id" IN (
        SELECT "ASMAY_Id" FROM "Adm_School_M_Academic_Year"
        WHERE CURRENT_DATE BETWEEN CAST("ASMAY_From_Date" AS date) AND CAST("ASMAy_To_Date" AS date)
        AND "MI_Id" IN (SELECT "MI_Id" FROM "IVRM_User_Login_Institutionwise" WHERE id = p_id)
    );

    RETURN QUERY
    SELECT 
        v_studentcount,
        v_Employeecount,
        v_Paymentcount,
        v_Preadmissioncount,
        v_Admissioncount,
        v_Tccount,
        v_Salarycount,
        v_Passcount,
        v_Failcount,
        v_Bookcount,
        v_Eventcount,
        v_Transportcount,
        v_Defaultercount,
        v_Interactioncount,
        v_Absentcount,
        v_Presentcount;
END;
$$;