CREATE OR REPLACE FUNCTION "dbo"."Clg_Staff_Noticeboard_Details"(
    p_MI_Id TEXT,
    p_HRME_id TEXT,
    p_Typeflg TEXT,
    p_ASMAY_Id TEXT
)
RETURNS TABLE(
    "INTB_Id" INTEGER,
    "INTBCSTF_Id" INTEGER,
    "HRME_Id" INTEGER,
    "HRME_EmployeeFirstName" TEXT,
    "INTB_StartDate" TIMESTAMP,
    "INTB_EndDate" TIMESTAMP,
    "MI_Id" INTEGER,
    "HRMD_DepartmentName" VARCHAR,
    "HRMDES_DesignationName" VARCHAR,
    "INTB_Description" TEXT,
    "INTB_Title" VARCHAR,
    "NTB_TTSylabusFlg" VARCHAR,
    "CreatedDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
    v_year VARCHAR(20);
    v_betweendates TEXT;
    v_fromdate TIMESTAMP;
    v_todate TIMESTAMP;
BEGIN

    SELECT DISTINCT "ASMAY_Year" INTO v_year
    FROM "Adm_School_M_Academic_Year"
    WHERE "ASMAY_Id" IN (SELECT UNNEST(STRING_TO_ARRAY(p_ASMAY_Id, ','))::INTEGER)
    AND "MI_Id" = p_MI_Id::INTEGER;

    SELECT "IMFY_FromDate" INTO v_fromdate
    FROM "IVRM_Master_FinancialYear"
    WHERE "IMFY_FinancialYear" = v_year;

    SELECT MAX(CAST("INTB_EndDate" AS DATE)) INTO v_todate
    FROM "IVRM_NoticeBoard";

    v_sql := '
    SELECT DISTINCT 
        a."INTB_Id",
        c."INTBCSTF_Id",
        d."HRME_Id",
        CONCAT(COALESCE(d."HRME_EmployeeFirstName", '' ''), '''', COALESCE(d."HRME_EmployeeMiddleName", '' ''), '''', COALESCE(d."HRME_EmployeeLastName", '' '')) as "HRME_EmployeeFirstName",
        a."INTB_StartDate",
        a."INTB_EndDate",
        a."MI_Id",
        e."HRMD_DepartmentName",
        f."HRMDES_DesignationName",
        a."INTB_Description",
        a."INTB_Title",
        a."NTB_TTSylabusFlg",
        a."CreatedDate"
    FROM "IVRM_NoticeBoard" a
    INNER JOIN "IVRM_NoticeBoard_Staff" c ON c."INTB_Id" = a."INTB_Id"
    INNER JOIN "HR_Master_Employee" d ON d."HRME_Id" = c."HRME_Id" AND d."HRME_ActiveFlag" = true
    INNER JOIN "HR_Master_Department" e ON e."HRMD_Id" = d."HRMD_Id"
    INNER JOIN "HR_Master_Designation" f ON f."HRMDES_Id" = d."HRMDES_Id"
    WHERE a."MI_Id" IN (SELECT UNNEST(STRING_TO_ARRAY(''' || p_MI_Id || ''', '',''))::INTEGER)
    AND d."HRME_Id" = (' || p_HRME_Id || ')::INTEGER
    AND a."NTB_TTSylabusFlg" IN (''' || p_Typeflg || ''')
    ORDER BY a."CreatedDate" DESC';

    RAISE NOTICE '%', v_sql;

    RETURN QUERY EXECUTE v_sql;

END;
$$;