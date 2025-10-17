CREATE OR REPLACE FUNCTION "dbo"."CLG_Attendance_Notdone"(
    p_MI_ID VARCHAR(50),
    p_ASMAY_ID VARCHAR(50),
    p_AMCO_Id TEXT,
    p_AMB_Id TEXT,
    p_AMSE_Id TEXT,
    p_ACMS_ID TEXT,
    p_FROMDATE VARCHAR(10),
    p_TODATE VARCHAR(10)
)
RETURNS TABLE(
    "HRME_EmployeeFirstName" TEXT,
    "AMB_BranchName" TEXT,
    "AMCO_CourseName" TEXT,
    "AMSE_SEMName" TEXT,
    "ACMS_SectionName" TEXT,
    "NOTENTERED_DATE" DATE
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_dt DATE;
    v_MI_Id_CUR BIGINT;
    v_ASMAY_Id_CUR BIGINT;
    v_AMCO_Id_CUR BIGINT;
    v_AMB_Id_CUR BIGINT;
    v_AMSE_Id_CUR BIGINT;
    v_ACMS_ID_CUR BIGINT;
    v_COUNT INT;
    v_EmployeeID VARCHAR;
    v_HRME_EmployeeFirstName TEXT;
    v_AMB_BranchName TEXT;
    v_AMCO_CourseName TEXT;
    v_AMSE_SEMName TEXT;
    v_ACMS_SectionName TEXT;
    rec_attendance RECORD;
    rec_dates RECORD;
BEGIN
    DROP TABLE IF EXISTS "Attendancestaff_Temp1";
    
    CREATE TEMP TABLE "EMPLOYEENOTENTERED" (
        "HRME_EmployeeFirstName" TEXT,
        "AMB_BranchName" TEXT,
        "AMCO_CourseName" TEXT,
        "AMSE_SEMName" TEXT,
        "ACMS_SectionName" TEXT,
        "NOTENTERED_DATE" DATE
    );

    CREATE TEMP TABLE "Attendancestaff_Temp1" AS
    SELECT DISTINCT a."asmay_id", a."mi_id", c."AMCO_Id", c."AMB_Id", c."AMSE_Id", c."ACMS_ID"
    FROM "clg"."Adm_College_Student_Attendance" a 
    INNER JOIN "clg"."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
    INNER JOIN "clg"."Adm_College_Yearly_Student" c ON c."AMCST_Id" = b."AMCST_Id"
    WHERE a."asmay_id" = p_ASMAY_ID::BIGINT 
        AND a."mi_id" = p_MI_ID::BIGINT
        AND c."AMCO_Id"::TEXT IN (SELECT UNNEST(string_to_array(p_AMCO_Id, ',')))
        AND c."AMB_Id"::TEXT IN (SELECT UNNEST(string_to_array(p_AMB_Id, ',')))
        AND c."AMSE_Id"::TEXT IN (SELECT UNNEST(string_to_array(p_AMSE_Id, ',')))
        AND c."ACMS_ID"::TEXT IN (SELECT UNNEST(string_to_array(p_ACMS_ID, ',')))
        AND a."ACSA_ActiveFlag" = 1;

    FOR rec_dates IN 
        SELECT dt FROM "dbo"."alldates"(p_FROMDATE, p_TODATE) 
        WHERE TRIM(TO_CHAR(dt, 'Day')) != 'Sunday'
    LOOP
        v_dt := rec_dates.dt;
        
        FOR rec_attendance IN 
            SELECT "MI_Id", "ASMAY_Id", "AMCO_Id", "AMB_Id", "AMSE_Id", "ACMS_ID" 
            FROM "Attendancestaff_Temp1"
        LOOP
            v_MI_Id_CUR := rec_attendance."MI_Id";
            v_ASMAY_Id_CUR := rec_attendance."ASMAY_Id";
            v_AMCO_Id_CUR := rec_attendance."AMCO_Id";
            v_AMB_Id_CUR := rec_attendance."AMB_Id";
            v_AMSE_Id_CUR := rec_attendance."AMSE_Id";
            v_ACMS_ID_CUR := rec_attendance."ACMS_ID";

            SELECT COUNT(*)
            INTO v_COUNT
            FROM "clg"."Adm_College_Student_Attendance" a
            WHERE a."asmay_id" = v_ASMAY_Id_CUR 
                AND a."mi_id" = v_MI_Id_CUR 
                AND a."AMCO_Id" = v_AMCO_Id_CUR
                AND a."AMB_Id" = v_AMB_Id_CUR 
                AND a."AMSE_Id" = v_AMSE_Id_CUR 
                AND a."ACMS_ID" = v_ACMS_ID_CUR
                AND a."ACSA_AttendanceDate"::DATE = v_dt;

            IF (v_COUNT = 0) THEN
                
                SELECT DISTINCT CONCAT(COALESCE(D."HRME_EmployeeFirstName", ''), ' ', 
                                      COALESCE(D."HRME_EmployeeMiddleName", ''), ' ', 
                                      COALESCE(D."HRME_EmployeeLastName", ''))
                INTO v_HRME_EmployeeFirstName
                FROM "clg"."Adm_College_Student_Attendance" a 
                INNER JOIN "clg"."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
                INNER JOIN "clg"."Adm_College_Yearly_Student" c ON c."AMCST_Id" = b."AMCST_Id"
                INNER JOIN "HR_Master_Employee" D ON D."HRME_ID" = A."HRME_ID"
                WHERE a."asmay_id" = v_ASMAY_Id_CUR 
                    AND a."mi_id" = v_MI_Id_CUR 
                    AND c."AMCO_Id" = v_AMCO_Id_CUR
                    AND c."AMB_Id" = v_AMB_Id_CUR 
                    AND c."AMSE_Id" = v_AMSE_Id_CUR 
                    AND c."ACMS_ID" = v_ACMS_ID_CUR;

                SELECT "AMB_BranchName" 
                INTO v_AMB_BranchName 
                FROM "clg"."Adm_Master_Branch" 
                WHERE "AMB_ID" = v_AMB_Id_CUR AND "AMB_ActiveFlag" = 1;
                
                SELECT "AMCO_CourseName" 
                INTO v_AMCO_CourseName 
                FROM "clg"."Adm_Master_Course" 
                WHERE "AMCO_Id" = v_AMCO_Id_CUR AND "AMCO_ActiveFlag" = 1;
                
                SELECT "AMSE_SEMName" 
                INTO v_AMSE_SEMName 
                FROM "clg"."Adm_Master_Semester" 
                WHERE "AMSE_Id" = v_AMSE_Id_CUR AND "AMSE_ActiveFlg" = 1;
                
                SELECT "ACMS_SectionName" 
                INTO v_ACMS_SectionName 
                FROM "clg"."Adm_College_Master_Section" 
                WHERE "ACMS_Id" = v_AMSE_Id_CUR AND "ACMS_ActiveFlag" = 1;

                INSERT INTO "EMPLOYEENOTENTERED" 
                VALUES(v_HRME_EmployeeFirstName, v_AMB_BranchName, v_AMCO_CourseName, 
                       v_AMSE_SEMName, v_ACMS_SectionName, v_dt);
            END IF;
        END LOOP;
    END LOOP;

    RETURN QUERY
    SELECT DISTINCT 
        e."HRME_EmployeeFirstName",
        e."AMB_BranchName",
        e."AMCO_CourseName",
        e."AMSE_SEMName",
        e."ACMS_SectionName",
        e."NOTENTERED_DATE"
    FROM "EMPLOYEENOTENTERED" e;
    
    DROP TABLE IF EXISTS "EMPLOYEENOTENTERED";
    DROP TABLE IF EXISTS "Attendancestaff_Temp1";
END;
$$;