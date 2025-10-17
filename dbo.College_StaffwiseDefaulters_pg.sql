CREATE OR REPLACE FUNCTION "dbo"."College_StaffwiseDefaulters"(
    p_ASMAY_Id TEXT,
    p_FMG_Id TEXT,
    p_FTI_Id TEXT,
    p_option TEXT,
    p_StdType VARCHAR(50),
    p_type TEXT,
    p_date1 TEXT,
    p_due TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_Sqldynamic TEXT;
    v_str3 TEXT;
    v_ftdd_day BIGINT;
    v_ftdd_month BIGINT;
    v_endyr BIGINT;
    v_startyr BIGINT;
    v_duedate TEXT;
    v_duedate1 TEXT;
    v_fromdate DATE;
    v_todate DATE;
    v_oResult VARCHAR(50);
    v_days TEXT;
    v_months TEXT;
    v_temp1 TEXT;
    v_temp2 TEXT;
    v_mi TEXT;
    v_dt BIGINT;
    v_mt BIGINT;
    
    cur_groupid CURSOR FOR
        SELECT "clg"."Fee_College_T_Due_Date"."FCTDD_Day", "clg"."Fee_College_T_Due_Date"."FCTDD_Month", 
               EXTRACT(YEAR FROM "Adm_School_M_Academic_Year"."ASMAY_From_Date")::BIGINT AS startyr, 
               EXTRACT(YEAR FROM "Adm_School_M_Academic_Year"."ASMAY_To_Date")::BIGINT AS endyr,
               "Adm_School_M_Academic_Year"."ASMAY_From_Date", 
               "Adm_School_M_Academic_Year"."ASMAY_To_Date"
        FROM "Fee_Master_Group"
        INNER JOIN "clg"."Fee_College_Student_Status_Staff" ON "Fee_Master_Group"."FMG_Id" = "clg"."Fee_College_Student_Status_Staff"."FMG_Id"
        INNER JOIN "Fee_Master_Head" ON "clg"."Fee_College_Student_Status_Staff"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
        INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "clg"."Fee_College_Student_Status_Staff"."FTI_Id"
        INNER JOIN "clg"."Fee_College_Master_Amount" ON "Fee_Master_Group"."FMG_Id" = "clg"."Fee_College_Master_Amount"."FMG_Id" 
            AND "clg"."Fee_College_Master_Amount"."FCMA_Id" = "clg"."Fee_College_Master_Amount"."FCMA_Id" 
            AND "Fee_Master_Head"."FMH_Id" = "clg"."Fee_College_Master_Amount"."FMH_Id"
        INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" ON "clg"."Fee_College_Master_Amount_Semesterwise"."FCMA_Id" = "clg"."Fee_College_Master_Amount"."FCMA_Id"
        INNER JOIN "clg"."Fee_College_T_Due_Date" ON "Fee_College_Master_Amount_Semesterwise"."FCMAS_Id" = "clg"."Fee_College_T_Due_Date"."FCMAS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" ON "clg"."Fee_College_Master_Amount"."ASMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
        WHERE ("Adm_School_M_Academic_Year"."ASMAY_Id" = p_ASMAY_Id::BIGINT) 
            AND ("Adm_School_M_Academic_Year"."MI_Id" = v_mi::BIGINT)
        GROUP BY "clg"."Fee_College_T_Due_Date"."FCTDD_Day", "FCTDD_Month", 
                 "Adm_School_M_Academic_Year"."ASMAY_From_Date",
                 "Adm_School_M_Academic_Year"."ASMAY_To_Date";
    
    cur_alldate CURSOR FOR
        SELECT DISTINCT EXTRACT(DAY FROM duedate)::BIGINT AS noofdays, 
                        EXTRACT(MONTH FROM duedate)::BIGINT AS noofmonths 
        FROM "V_DueDate_Staff_College" 
        WHERE duedate = TO_DATE(p_date1, 'DD/MM/YYYY');
    
    cur_getall CURSOR FOR
        SELECT DISTINCT EXTRACT(DAY FROM duedate)::BIGINT AS noofdays, 
                        EXTRACT(MONTH FROM duedate)::BIGINT AS noofmonths 
        FROM "V_DueDate_Staff_College" 
        WHERE duedate <= TO_DATE(p_date1, 'DD/MM/YYYY');
BEGIN
    v_ftdd_day := 0;
    v_ftdd_month := 0;
    v_endyr := 0;
    v_startyr := 0;
    v_days := '0';
    v_months := '0';
    v_dt := 0;
    v_mt := 0;

    IF (p_FTI_Id != '') THEN
        v_str3 := ' where ("clg"."Fee_College_Student_Status_Staff"."FMG_Id" IN (' || p_FMG_Id || ')) AND ("clg"."Fee_College_Student_Status_Staff"."MI_Id" = ' || v_mi || ') and ("Fee_T_Installment"."FTI_Id" IN (' || p_FTI_Id || ')) AND ("clg"."Fee_College_Student_Status_Staff"."FCSSST_ToBePaid" > 0) ';
    END IF;

    IF p_type = 'year' THEN
        SELECT "MI_Id"::TEXT INTO v_mi FROM "Adm_School_M_Academic_Year" WHERE "ASMAY_Id" = p_ASMAY_Id::BIGINT;

        IF (p_StdType = 'Staff') THEN
            IF p_option = 'FGW' THEN
                v_Sqldynamic := 'SELECT SUM("clg"."Fee_College_Student_Status_Staff"."FCSSST_ToBePaid") AS totalbalance, "Fee_Master_Group"."FMG_GroupName" 
                    FROM "Fee_Master_Group" 
                    INNER JOIN "clg"."Fee_College_Student_Status_Staff" ON "Fee_Master_Group"."FMG_Id" = "clg"."Fee_College_Student_Status_Staff"."FMG_Id" 
                    INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status_Staff"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
                    INNER JOIN "HR_Master_Employee" ON "HR_Master_Employee"."HRME_Id" = "clg"."Fee_College_Student_Status_Staff"."HRME_Id"
                    INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "clg"."Fee_College_Student_Status_Staff"."FTI_Id"
                    WHERE ("clg"."Fee_College_Student_Status_Staff"."ASMAY_Id" = ' || p_ASMAY_Id || ') 
                        AND ("clg"."Fee_College_Student_Status_Staff"."FMG_Id" IN (' || p_FMG_Id || ')) 
                        AND ("clg"."Fee_College_Student_Status_Staff"."MI_Id" = ' || v_mi || ') 
                        AND ("Fee_T_Installment"."FTI_Id" IN (' || p_FTI_Id || ')) 
                        AND ("clg"."Fee_College_Student_Status_Staff"."FCSSST_ToBePaid" > 0) 
                    GROUP BY "Fee_Master_Group"."FMG_Id", "Fee_Master_Group"."FMG_GroupName"';
                EXECUTE v_Sqldynamic;

            ELSIF p_option = 'FHW' THEN
                v_Sqldynamic := 'SELECT SUM("clg"."Fee_College_Student_Status_Staff"."FCSSST_ToBePaid") AS totalbalance, "Fee_Master_Head"."FMH_FeeName" 
                    FROM "Fee_Master_Group" 
                    INNER JOIN "clg"."Fee_College_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "clg"."Fee_College_Student_Status"."FMG_Id" 
                    INNER JOIN "Fee_Master_Head" ON "clg"."Fee_College_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
                    INNER JOIN "HR_Master_Employee" ON "HR_Master_Employee"."HRME_Id" = "clg"."Fee_College_Student_Status"."HRME_Id"
                    INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "clg"."Fee_College_Student_Status_Staff"."FTI_Id" 
                        AND "Fee_Student_Status_Staff"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" 
                    INNER JOIN "clg"."Fee_College_T_Due_Date" ON "clg"."Fee_College_T_Due_Date"."FCMA_Id" = "clg"."Fee_College_Student_Status_Staff"."FCMA_Id"
                    WHERE ("clg"."Fee_College_Student_Status_Staff"."ASMAY_Id" = ' || p_ASMAY_Id || ') 
                        AND ("clg"."Fee_College_Student_Status_Staff"."FMG_Id" IN (' || p_FMG_Id || ')) 
                        AND ("clg"."Fee_College_Student_Status_Staff"."MI_Id" = ' || v_mi || ') 
                        AND ("Fee_T_Installment"."FTI_Id" IN (' || p_FTI_Id || ')) 
                        AND ("clg"."Fee_College_Student_Status_Staff"."FCSSST_ToBePaid" > 0) 
                    GROUP BY "Fee_Master_Head"."FMH_FeeName"';
                EXECUTE v_Sqldynamic;

            ELSIF p_option = 'FSW' THEN
                v_Sqldynamic := 'SELECT SUM("clg"."Fee_College_Student_Status_Staff"."FCSSST_ToBePaid") AS totalbalance, 
                    COALESCE("HR_Master_Employee"."HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HR_Master_Employee"."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HR_Master_Employee"."HRME_EmployeeLastName", '''') AS StudentName, 
                    "HR_Master_Employee"."HRME_EmployeeCode" AS AMCST_AdmNo, 
                    "HR_Master_Employee"."HRME_MobileNo" AS AMCST_MobileNo, 
                    "HR_Master_Employee"."HRME_FatherName" AS AMST_FatherName,
                    "HRME_EmailId" AS AMCST_emailId,
                    "HRMDES_DesignationName"
                    FROM "Fee_Master_Group" 
                    INNER JOIN "clg"."Fee_College_Student_Status_Staff" ON "Fee_Master_Group"."FMG_Id" = "clg"."Fee_College_Student_Status_Staff"."FMG_Id" 
                    INNER JOIN "Fee_Master_Head" ON "clg"."Fee_College_Student_Status_Staff"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
                    INNER JOIN "HR_Master_Employee" ON "HR_Master_Employee"."HRME_Id" = "clg"."Fee_College_Student_Status_Staff"."HRME_Id"
                    INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "clg"."Fee_College_Student_Status_Staff"."FTI_Id"
                    INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "clg"."Fee_College_Student_Status_Staff"."ASMAY_Id"
                    INNER JOIN "HR_Master_Designation" ON "HR_Master_Designation"."HRMDES_Id" = "HR_Master_Employee"."HRMDES_Id"
                    WHERE ("clg"."Fee_College_Student_Status_Staff"."ASMAY_Id" = ' || p_ASMAY_Id || ') 
                        AND ("clg"."Fee_College_Student_Status_Staff"."FMG_Id" IN (' || p_FMG_Id || ')) 
                        AND ("clg"."Fee_College_Student_Status_Staff"."MI_Id" = ' || v_mi || ') 
                        AND ("Fee_T_Installment"."FTI_Id" IN (' || p_FTI_Id || ')) 
                        AND ("clg"."Fee_College_Student_Status_Staff"."FCSSST_ToBePaid" > 0) 
                    GROUP BY "HR_Master_Employee"."HRME_MobileNo", "HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName", 
                             "HR_Master_Employee"."HRME_EmployeeCode", "HR_Master_Employee"."HRME_FatherName", "HRME_EmailId", "HRMDES_DesignationName"';
                EXECUTE v_Sqldynamic;
            END IF;

        ELSIF (p_StdType = 'others') THEN
            IF p_option = 'FGW' THEN
                v_Sqldynamic := 'SELECT SUM("clg"."Fee_College_Student_Status_OthStu"."FCSSOST_ToBePaid") AS totalbalance, "Fee_Master_Group"."FMG_GroupName" 
                    FROM "Fee_Master_Group" 
                    INNER JOIN "clg"."Fee_College_Student_Status_OthStu" ON "Fee_Master_Group"."FMG_Id" = "clg"."Fee_College_Student_Status_OthStu"."FMG_Id" 
                    INNER JOIN "Fee_Master_Head" ON "clg"."Fee_College_Student_Status_OthStu"."FMH_Id" = "Fee_Master_Head"."FMH_Id" 
                    INNER JOIN "clg"."Fee_Master_College_OtherStudents" ON "clg"."Fee_Master_College_OtherStudents"."FMCOST_Id" = "Fee_Student_Status_OthStu"."FMCOST_Id"
                    INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "clg"."Fee_College_Student_Status_OthStu"."FTI_Id"
                    WHERE ("clg"."Fee_College_Student_Status_OthStu"."ASMAY_Id" = ' || p_ASMAY_Id || ') 
                        AND ("clg"."Fee_College_Student_Status_OthStu"."FMG_Id" IN (' || p_FMG_Id || ')) 
                        AND ("clg"."Fee_College_Student_Status_OthStu"."MI_Id" = ' || v_mi || ') 
                        AND ("Fee_T_Installment"."FTI_Id" IN (' || p_FTI_Id || ')) 
                        AND ("clg"."Fee_College_Student_Status_OthStu"."FCSSOST_ToBePaid" > 0) 
                    GROUP BY "Fee_Master_Group"."FMG_Id", "Fee_Master_Group"."FMG_GroupName"';
                EXECUTE v_Sqldynamic;

            ELSIF p_option = 'FHW' THEN
                v_Sqldynamic := 'SELECT SUM("clg"."Fee_College_Student_Status_OthStu"."FSSOST_ToBePaid") AS totalbalance, "Fee_Master_Head"."FMH_FeeName" 
                    FROM "Fee_Master_Group" 
                    INNER JOIN "clg"."Fee_College_Student_Status_OthStu" ON "Fee_Master_Group"."FMG_Id" = "clg"."Fee_College_Student_Status_OthStu"."FMG_Id" 
                    INNER JOIN "Fee_Master_Head" ON "clg"."Fee_College_Student_Status_OthStu"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
                    INNER JOIN "clg"."Fee_Master_College_OtherStudents" ON "clg"."Fee_Master_College_OtherStudents"."FMCOST_Id" = "Fee_Student_Status_OthStu"."FMOST_Id" 
                    INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "clg"."Fee_College_Student_Status_OthStu"."FMH_Id"
                    INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "clg"."Fee_College_Student_Status_OthStu"."FTI_Id"
                    INNER JOIN "clg"."Fee_College_T_Due_Date" ON "clg"."Fee_College_T_Due_Date"."FCMA_Id" = "clg"."Fee_College_Student_Status_OthStu"."FCMA_Id"
                    WHERE ("clg"."Fee_College_Student_Status_OthStu"."ASMAY_Id" = ' || p_ASMAY_Id || ') 
                        AND ("clg"."Fee_College_Student_Status_OthStu"."FMG_Id" IN (' || p_FMG_Id || ')) 
                        AND ("clg"."Fee_College_Student_Status_OthStu"."MI_Id" = ' || v_mi || ') 
                        AND ("Fee_T_Installment"."FTI_Id" IN (' || p_FTI_Id || ')) 
                        AND ("clg"."Fee_College_Student_Status_OthStu"."FCSSOST_ToBePaid" > 0) 
                    GROUP BY "Fee_Master_Head"."FMH_FeeName"';
                EXECUTE v_Sqldynamic;

            ELSIF p_option = 'FSW' THEN
                v_Sqldynamic := 'SELECT SUM("clg"."Fee_College_Student_Status_OthStu"."FCSSOST_ToBePaid") AS totalbalance, 
                    "clg"."Fee_Master_College_OtherStudents"."FMCOST_StudentName" AS StudentName, 
                    "clg"."Fee_Master_College_OtherStudents"."FMCOST_StudentMobileNo" AS AMCST_MobileNo,
                    "FMCOST_StudentEmailId" AS AMCST_emailId
                    FROM "Fee_Master_Group" 
                    INNER JOIN "clg"."Fee_College_Student_Status_OthStu" ON "Fee_Master_Group"."FMG_Id" = "clg"."Fee_College_Student_Status_OthStu"."FMG_Id" 
                    INNER JOIN "Fee_Master_Head" ON "clg"."Fee_College_Student_Status_OthStu"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
                    INNER JOIN "clg"."Fee_Master_College_OtherStudents" ON "clg"."Fee_Master_College_OtherStudents"."FMCOST_Id" = "clg"."Fee_College_Student_Status_OthStu"."FMCOST_Id"
                    INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "clg"."Fee_College_Student_Status_OthStu"."FTI_Id"
                    INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "clg"."Fee_College_Student_Status_OthStu"."ASMAY_Id"
                    WHERE ("clg"."Fee_College_Student_Status_OthStu"."ASMAY_Id" = ' || p_ASMAY_Id || ') 
                        AND ("clg"."Fee_College_Student_Status_OthStu"."FMG_Id" IN (' || p_FMG_Id || ')) 
                        AND ("clg"."Fee_College_Student_Status_OthStu"."MI_Id" = ' || v_mi || ') 
                        AND ("Fee_T_Installment"."FTI_Id" IN (' || p_FTI_Id || ')) 
                        AND ("clg"."Fee_College_Student_Status_OthStu"."FCSSOST_ToBePaid" > 0) 
                    GROUP BY "clg"."Fee_Master_College_OtherStudents"."FMCOST_StudentName", 
                             "clg"."Fee_Master_College_OtherStudents"."FMCOST_StudentMobileNo", 
                             "FMCOST_StudentEmailId"';
                EXECUTE v_Sqldynamic;
            END IF;
        END IF;

    ELSE
        DELETE FROM "V_DueDate_Staff_College";

        IF (p_FTI_Id = '0') THEN
            OPEN cur_groupid;
            LOOP
                FETCH cur_groupid INTO v_ftdd_day, v_ftdd_month, v_startyr, v_endyr, v_fromdate, v_todate;
                EXIT WHEN NOT FOUND;

                IF v_ftdd_day = 0 OR v_ftdd_month = 0 THEN
                    v_duedate := p_date1;
                    RETURN;
                ELSE
                    v_duedate := v_startyr::TEXT || '-' || v_ftdd_month::TEXT || '-' || v_ftdd_day::TEXT;
                    v_duedate1 := v_endyr::TEXT || '-' || v_ftdd_month::TEXT || '-' || v_ftdd_day::TEXT;
                END IF;

                IF v_duedate::DATE >= v_fromdate AND v_duedate::DATE <= v_todate THEN
                    INSERT INTO "V_DueDate_Staff_College"("Duedate") VALUES(TO_CHAR(v_duedate::DATE, 'DD/MM/YYYY'));
                ELSIF v_duedate1::DATE >= v_fromdate AND v_duedate1::DATE <= v_todate THEN
                    INSERT INTO "V_DueDate_Staff_College"("Duedate") VALUES(TO_CHAR(v_duedate1::DATE, 'DD/MM/YYYY'));
                ELSE
                    v_oResult := 'select current academic year date';
                END IF;
            END LOOP;
            CLOSE cur_groupid;
        ELSE
            OPEN cur_groupid;
            LOOP
                FETCH cur_groupid INTO v_ftdd_day, v_ftdd_month, v_startyr, v_endyr, v_fromdate, v_todate;
                EXIT WHEN NOT FOUND;

                IF v_ftdd_day = 0 OR v_ftdd_month = 0 THEN
                    v_duedate := p_date1;
                    RETURN;
                ELSE
                    v_duedate := v_startyr::TEXT || '-' || v_ftdd_month::TEXT || '-' || v_ftdd_day::TEXT;
                    v_duedate1 := v_endyr::TEXT || '-' || v_ftdd_month::TEXT || '-' || v_ftdd_day::TEXT;
                END IF;

                IF v_duedate::DATE >= v_fromdate AND v_duedate::DATE <= v_todate THEN
                    INSERT INTO "V_DueDate_Staff_College"("Duedate") VALUES(TO_CHAR(v_duedate::DATE, 'DD/MM/YYYY'));
                ELSIF v_duedate1::DATE >= v_fromdate AND v_duedate1::DATE <= v_todate THEN
                    INSERT INTO "V_DueDate_Staff_College"("Duedate") VALUES(TO_CHAR(v_duedate1::DATE, 'DD/MM/YYYY'));
                ELSE
                    v_oResult := 'select current academic year date';
                END IF;
            END LOOP;
            CLOSE cur_groupid;
        END IF;

        IF p_due = 'duedate' THEN
            OPEN cur_alldate;
            LOOP
                FETCH cur_alldate INTO v_dt, v_mt;
                EXIT WHEN NOT FOUND;

                IF v_dt = 0 AND v_mt = 0 THEN
                    v_days := v_dt::TEXT;
                    v_months := v_mt::TEXT;
                ELSE
                    v_temp1 := v_dt::TEXT;
                    v_temp2 := v_mt::TEXT;
                    v_days := v_days || ',' || v_temp1;
                    v_months := v_months || ',' || v_temp2;
                END IF;
            END LOOP;
            CLOSE cur_alldate;

        ELSIF p_due = 'tillduedate' THEN
            OPEN cur_getall;
            LOOP
                FETCH cur_getall INTO v_dt, v_mt;
                EXIT WHEN NOT FOUND;

                IF v_dt = 0 AND v_mt = 0 THEN
                    v_days := v_dt::TEXT;
                    v_months := v_mt::TEXT;
                ELSE
                    v_temp1 := v_dt::TEXT;
                    v_temp2 := v_mt::TEXT;
                    v_days := v_days || ',' || v_temp1;
                    v_months := v_months || ',' || v_temp2;
                END IF;
            END LOOP;
            CLOSE cur_getall;
        END IF;

        IF p_option = 'FGW' THEN
            v_Sqldynamic := 'SELECT SUM("Fee_Student_Status_Staff"."FSSST_ToBePaid") AS totalbalance, "Fee_Master_Group"."FMG_GroupName"
                FROM "Fee_Master_Group"
                INNER JOIN "clg"."Fee_College_Student_Status_Staff" ON "Fee_Master_Group"."FMG_Id" = "clg"."Fee_College_Student_Status_Staff"."FMG_Id"
                INNER JOIN "Fee_Master_Head" ON "clg"."Fee_College_Student_Status_Staff"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
                INNER JOIN "HR_Master_Employee" ON "HR_Master_Employee"."HRME_Id" = "clg"."Fee_College_Student_Status_Staff"."HRME_Id"
                INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "clg"."Fee_College_Student_Status_Staff"."FTI_Id"
                INNER JOIN "clg"."Fee_College_T_Due_Date" ON "clg"."Fee_College_T_Due_Date"."FCMA_Id" = "clg"."Fee_College_Student_Status_Staff"."FCMA_Id"
                ' || v_str3 || ' AND ("clg"."Fee_College_T_Due_Date"."FCTDD_Day" IN (' || v_days || ')) AND ("clg"."Fee_College_T_Due_Date"."FCTDD_Month" IN (' || v_months || ')) 
                GROUP BY "Fee_Master_Group"."FMG_GroupName"';
            EXECUTE v_Sqldynamic;

        ELSIF p_option = 'FHW' THEN
            v_Sqldynamic := 'SELECT SUM("Fee_Student_Status_Staff"."FSSST_ToBePaid") AS totalbalance, "Fee_Master_Head"."FMH_FeeName"
                FROM "Fee_Master_Group"
                INNER JOIN "clg"."Fee_College_Student_Status_Staff" ON "Fee_Master_Group"."FMG_Id" = "clg"."Fee_College_Student_Status_Staff"."FMG_Id"
                INNER JOIN "Fee_Master_Head" ON "clg"."Fee_College_Student_Status_Staff"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
                INNER JOIN "HR_Master_Employee" ON "HR_Master_Employee"."HRME_Id" = "clg"."Fee_College_Student_Status_Staff"."HRME_Id"
                INNER JOIN "Fee_T_Installment" ON "Fee_T_Installment"."FTI_Id" = "clg"."Fee_College_Student_Status_Staff"."FTI_Id"
                INNER JOIN "clg"."Fee_College_T_Due_Date" ON "clg"."Fee_College_T_Due_Date"."FCMA_Id" = "clg"."Fee_College_Student_Status_Staff"."FCMA_Id"
                ' || v_str3 || ' AND ("clg"."Fee_College_T_Due_Date"."FCTDD_Day" IN (' || v_days || ')) AND ("clg"."Fee_College_T_Due_Date"."FCTDD_Month" IN (' || v_months || ')) 
                GROUP BY "Fee_Master_Head"."FMH_FeeName"';
            EXECUTE v_Sqldynamic;

        ELSIF p_option = 'FSW' THEN
            v_Sqldynamic := 'SELECT SUM("Fee_Student_Status_Staff"."FSSST_ToBePaid") AS totalbalance, 
                COALESCE("HR_Master_Employee"."HRME_EmployeeFirstName", '''') || '' '' || COALESCE("HR_Master_Employee"."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE("HR_Master_Employee"."HRME_EmployeeLastName", '''') AS Student