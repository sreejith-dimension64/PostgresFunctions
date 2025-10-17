CREATE OR REPLACE FUNCTION "dbo"."Admission_MonthEnd_Report"(
    p_Year TEXT,
    p_month TEXT,
    p_mi_id TEXT
)
RETURNS TABLE(
    "TotalStrendth" BIGINT,
    "NewAdmission" BIGINT,
    "Readmit" BIGINT,
    "WithDraw" BIGINT,
    "MissingPhoto" BIGINT,
    "MissingEmail" BIGINT,
    "MissingMobile" BIGINT,
    "PermanentTc" BIGINT,
    "TemporaryTc" BIGINT,
    "Bonafied" BIGINT,
    "Study" BIGINT,
    "Conduct" BIGINT,
    "DOB_Certificate_count" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_TotalStrength BIGINT;
    v_NewAdmission BIGINT;
    v_Readmit BIGINT;
    v_Withdraw BIGINT;
    v_missingphoto BIGINT;
    v_missionemail BIGINT;
    v_missionmobile BIGINT;
    v_permanent_tc BIGINT;
    v_temporary_tc BIGINT;
    v_bonafide BIGINT;
    v_study BIGINT;
    v_conduct BIGINT;
    v_DOB_Certificate_count BIGINT;
BEGIN
    v_TotalStrength := 0;
    v_NewAdmission := 0;
    v_Readmit := 0;
    v_Withdraw := 0;
    
    v_missingphoto := 0;
    v_missionemail := 0;
    v_missionmobile := 0;
    
    v_permanent_tc := 0;
    v_temporary_tc := 0;
    
    v_bonafide := 0;
    v_study := 0;
    v_conduct := 0;
    
    v_DOB_Certificate_count := 0;
    
    /* Total Strength */
    SELECT COUNT(DISTINCT a."AMST_Id") INTO v_TotalStrength
    FROM "Adm_School_Y_Student" a
    INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
    WHERE b."AMST_SOL" = 'S' AND b."AMST_ActiveFlag" = 1 AND a."AMAY_ActiveFlag" = 1
    AND b."MI_Id" = p_mi_id AND a."ASMAY_Id" = p_Year;
    
    /*New Admission*/
    SELECT COUNT(DISTINCT a."AMST_Id") INTO v_NewAdmission
    FROM "Adm_M_Student" a
    INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
    WHERE a."AMST_SOL" = 'S' AND a."AMST_ActiveFlag" = 1 AND a."MI_Id" = p_mi_id AND a."ASMAY_Id" = p_Year;
    
    /* Readmit Admission */
    SELECT COUNT(DISTINCT a."AMST_Id_New") INTO v_Readmit
    FROM "Adm_Readmit_Student" a
    INNER JOIN "Adm_M_Student" b ON a."AMST_Id_New" = b."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id_New"
    WHERE a."MI_Id" = p_mi_id AND a."ASMAY_Id_New" = p_Year
    AND EXTRACT(MONTH FROM a."CreatedDate") = p_month::INTEGER;
    
    /* Withdraw Details */
    SELECT COUNT(DISTINCT a."AMST_Id") INTO v_Withdraw
    FROM "Adm_AdmissionCancel" a
    INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
    WHERE a."ASMAY_Id" = p_Year AND a."MI_Id" = p_mi_id
    AND EXTRACT(MONTH FROM a."AACA_ACDate") = p_month::INTEGER
    AND b."AMST_SOL" = 'WD';
    
    /*Photo Missing*/
    SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO v_missingphoto
    FROM "Adm_M_Student"
    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    WHERE ("Adm_M_Student"."AMST_Photoname" IS NULL OR "Adm_M_Student"."AMST_Photoname" = '' OR "Adm_M_Student"."AMST_Photoname" = '0')
    AND "AMST_SOL" = 'S' AND "Adm_M_Student"."AMST_ActiveFlag" = 1 AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1 
    AND "Adm_School_Y_Student"."ASMAY_Id" = p_Year
    AND "Adm_M_Student"."MI_Id" = p_mi_id;
    
    /*Email Missing*/
    SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO v_missionemail
    FROM "Adm_M_Student"
    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    WHERE ("Adm_M_Student"."AMST_emailId" IS NULL OR "Adm_M_Student"."AMST_emailId" = '' OR "Adm_M_Student"."AMST_emailId" = '0' OR "AMST_emailId" = 'test@gmail.com')
    AND "AMST_SOL" = 'S' AND "Adm_M_Student"."AMST_ActiveFlag" = 1 AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1 
    AND "Adm_School_Y_Student"."ASMAY_Id" = p_Year
    AND "Adm_M_Student"."MI_Id" = p_mi_id;
    
    /*Mobile Missing*/
    SELECT COUNT(DISTINCT "Adm_M_Student"."AMST_Id") INTO v_missionmobile
    FROM "Adm_M_Student"
    INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
    INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
    WHERE ("Adm_M_Student"."AMST_MobileNo" IS NULL OR "Adm_M_Student"."AMST_MobileNo" = '' OR "Adm_M_Student"."AMST_MobileNo" = '0')
    AND "AMST_SOL" = 'S' AND "Adm_M_Student"."AMST_ActiveFlag" = 1 AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1 
    AND "Adm_School_Y_Student"."ASMAY_Id" = p_Year
    AND "Adm_M_Student"."MI_Id" = p_mi_id;
    
    /*Permanent TC*/
    SELECT COUNT(DISTINCT "Adm_Student_TC"."AMST_Id") INTO v_permanent_tc
    FROM "Adm_Student_TC"
    WHERE "Adm_Student_TC"."ASMAY_Id" = p_Year
    AND EXTRACT(MONTH FROM "Adm_Student_TC"."ASTC_TCDate") = p_month::INTEGER 
    AND "Adm_Student_TC"."MI_Id" = p_mi_id
    AND "Adm_Student_TC"."ASTC_TemporaryFlag" = 0;
    
    /*Temporary TC*/
    SELECT COUNT(DISTINCT "Adm_Student_TC"."AMST_Id") INTO v_temporary_tc
    FROM "Adm_Student_TC"
    WHERE "Adm_Student_TC"."ASMAY_Id" = p_Year
    AND EXTRACT(MONTH FROM "Adm_Student_TC"."ASTC_TCDate") = p_month::INTEGER 
    AND "Adm_Student_TC"."MI_Id" = p_mi_id
    AND "Adm_Student_TC"."ASTC_TemporaryFlag" = 1;
    
    /*Bonafied Certificate*/
    SELECT COUNT(a."AMST_Id") INTO v_bonafide
    FROM "Adm_Study_Certificate_Report" a
    INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
    WHERE a."MI_Id" = p_mi_id AND a."ASMAY_Id" = p_Year AND a."ASC_ReportType" = 'Bonafide Certificate'
    AND EXTRACT(MONTH FROM a."ASC_Date") = p_month::INTEGER;
    
    /*Study Certificate*/
    SELECT COUNT(a."AMST_Id") INTO v_study
    FROM "Adm_Study_Certificate_Report" a
    INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
    WHERE a."MI_Id" = p_mi_id AND a."ASMAY_Id" = p_Year AND a."ASC_ReportType" = 'Study Certificate'
    AND EXTRACT(MONTH FROM a."ASC_Date") = p_month::INTEGER;
    
    /*Conduct Certificate*/
    SELECT COUNT(a."AMST_Id") INTO v_conduct
    FROM "Adm_Study_Certificate_Report" a
    INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
    WHERE a."MI_Id" = p_mi_id AND a."ASMAY_Id" = p_Year AND a."ASC_ReportType" = 'Conduct Certificate'
    AND EXTRACT(MONTH FROM a."ASC_Date") = p_month::INTEGER;
    
    SELECT COUNT(*) INTO v_DOB_Certificate_count
    FROM "Adm_Study_Certificate_Report"
    WHERE "Adm_Study_Certificate_Report"."MI_Id" = p_mi_id 
    AND EXTRACT(MONTH FROM "Adm_Study_Certificate_Report"."ASC_Date") = p_month::INTEGER;
    
    RETURN QUERY
    SELECT v_TotalStrength, v_NewAdmission, v_Readmit,
           v_Withdraw, v_missingphoto, v_missionemail, v_missionmobile,
           v_permanent_tc, v_temporary_tc, v_bonafide, v_study, v_conduct, v_DOB_Certificate_count;
END;
$$;