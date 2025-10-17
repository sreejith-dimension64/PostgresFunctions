CREATE OR REPLACE FUNCTION "dbo"."HRMSCandidateRqt_Details"(
    "HRMC_Id" TEXT,
    "HRMPT_Id" TEXT,
    "HRMJ_Id" TEXT,
    "IVRMMR_Id" TEXT,
    "CreatedDate" TIMESTAMP,
    "BELOW_CTC" DECIMAL(25,2),
    "HIGH_CTC" DECIMAL(25,2),
    "HRCD_ExpFrom" DECIMAL(25,2)
)
RETURNS TABLE(
    "HRCD_FirstName" TEXT,
    "HRCD_MobileNo" TEXT,
    "HRCD_EmailId" TEXT,
    "HRCD_Resume" TEXT,
    "HRCD_Photo" TEXT,
    "HRMC_QulaificationName" TEXT,
    "HRMPT_Name" TEXT,
    "HRMJ_JobTiTle" TEXT,
    "IVRMMR_Name" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_content TEXT;
    v_CreatedDate_N TEXT;
    v_sqldynamic TEXT;
    v_content1 TEXT;
    v_content2 TEXT;
BEGIN
    v_CreatedDate_N := CAST("CreatedDate" AS DATE)::TEXT;
    v_content1 := 'where ';
    v_content2 := '';
    v_content := '';

    IF("HRMC_Id" <> '0') THEN
        v_content2 := '"HR_Candidate_Details"."HRMC_Id"=' || "HRMC_Id" || ' and ';
    END IF;

    IF("HRMPT_Id" <> '0') THEN
        v_content2 := v_content2 || '"HR_Candidate_Details"."HRMPT_Id"=' || "HRMPT_Id" || ' and ';
    END IF;

    IF("HRMJ_Id" <> '0') THEN
        v_content2 := v_content2 || '"HR_Candidate_Details"."HRMJ_Id"=' || "HRMJ_Id" || ' and ';
    END IF;

    IF("IVRMMR_Id" <> '0') THEN
        v_content2 := v_content2 || '"HR_Candidate_Details"."HRCD_Religion"=' || "IVRMMR_Id" || ' and ';
    END IF;

    IF("CreatedDate" IS NOT NULL) THEN
        v_content2 := v_content2 || '(CAST("HR_Candidate_Details"."CreatedDate" AS DATE) >= ''' || v_CreatedDate_N || ''' and CAST("HR_Candidate_Details"."CreatedDate" AS DATE) <= ''' || v_CreatedDate_N || ''')  and';
    END IF;

    IF("BELOW_CTC" <> 0) THEN
        v_content2 := v_content2 || '("HR_Candidate_Details"."HRCD_ExpectedCTC" >= ' || CAST("BELOW_CTC" AS TEXT) || ' ) and ';
    END IF;

    IF("HIGH_CTC" <> 0) THEN
        v_content2 := v_content2 || '"HR_Candidate_Details"."HRCD_ExpectedCTC"<=' || CAST("HIGH_CTC" AS TEXT) || ' and ';
    END IF;

    IF("HRCD_ExpFrom" <> 0) THEN
        v_content2 := v_content2 || '"HR_Candidate_Details"."HRCD_ExpFrom"=' || CAST("HRCD_ExpFrom" AS TEXT) || ' and ';
    END IF;

    v_content2 := SUBSTRING(v_content2, 1, LENGTH(v_content2) - 4);

    v_sqldynamic := '
    SELECT "HR_Candidate_Details"."HRCD_FirstName", "HR_Candidate_Details"."HRCD_MobileNo", "HR_Candidate_Details"."HRCD_EmailId", "HR_Candidate_Details"."HRCD_Resume", "HR_Candidate_Details"."HRCD_Photo", "HR_Master_Course"."HRMC_QulaificationName", "HR_Master_PostionType"."HRMPT_Name", "HR_Master_Jobs"."HRMJ_JobTiTle", "IVRM_Master_Religion"."IVRMMR_Name"
    FROM "HR_Candidate_Details"
    LEFT JOIN "HR_Master_Course" ON "HR_Candidate_Details"."HRMC_Id"="HR_Master_Course"."HRMC_Id"          
    LEFT JOIN "HR_Master_PostionType" ON "HR_Candidate_Details"."HRMPT_Id"="HR_Master_PostionType"."HRMPT_Id" 
    LEFT JOIN "HR_Master_Jobs" ON "HR_Candidate_Details"."HRMJ_Id"="HR_Master_Jobs"."HRMJ_Id"
    LEFT JOIN "IVRM_Master_Religion" ON "HR_Candidate_Details"."HRCD_Religion"="IVRM_Master_Religion"."IVRMMR_Id"
    ' || v_content1 || ' ' || v_content || ' ' || v_content2 || '   ';

    RETURN QUERY EXECUTE v_sqldynamic;

END;
$$;