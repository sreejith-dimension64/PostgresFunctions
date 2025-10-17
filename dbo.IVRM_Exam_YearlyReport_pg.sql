CREATE OR REPLACE FUNCTION "dbo"."IVRM_Exam_YearlyReport"(
    p_MI_Id bigint,
    p_FromDate varchar(10),
    p_ToDate varchar(10)
)
RETURNS TABLE(
    "EME_Id" int,
    "EME_Name" text,
    "Passcount" bigint,
    "Failcount" bigint,
    "Absentcount" bigint,
    "Medicalcount" bigint,
    "Sportscount" bigint,
    "ODcount" bigint,
    "HallTicketCount" bigint,
    "SMSCount" bigint,
    "EmailCount" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASMAY_Id bigint;
    v_EME_ExamName text;
    v_emeid int;
    v_Passcount bigint;
    v_Failcount bigint;
    v_Absentcount bigint;
    v_Medicalcount bigint;
    v_Sportscount bigint;
    v_ODcount bigint;
    v_HallTicketCount bigint;
    v_SMSCount bigint;
    v_EmailCount bigint;
    rec RECORD;
BEGIN
    
    SELECT "ASMAY_Id" INTO v_ASMAY_Id 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = p_MI_Id 
        AND CAST("ASMAY_From_Date" AS date) >= CAST(p_FromDate AS date) 
        AND CAST(p_ToDate AS date) <= CAST("ASMAY_To_Date" AS date);

    DROP TABLE IF EXISTS "ExamSelectedDatesReport_Temp";

    CREATE TEMP TABLE "ExamSelectedDatesReport_Temp"(
        "EME_Id" int,
        "EME_Name" text,
        "Passcount" bigint,
        "Failcount" bigint,
        "Absentcount" bigint,
        "Medicalcount" bigint,
        "Sportscount" bigint,
        "ODcount" bigint,
        "HallTicketCount" bigint,
        "SMSCount" bigint,
        "EmailCount" bigint
    );

    FOR rec IN 
        SELECT DISTINCT "EYCE"."EME_Id" 
        FROM "Exm"."Exm_Yearly_Category" "EYC"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "EYCE" ON "EYC"."EYC_Id" = "EYCE"."EYC_Id" 
        WHERE "EYC"."MI_Id" = p_MI_Id 
            AND "EYC"."ASMAY_Id" = v_ASMAY_Id  
            AND CAST("EYC_ExamStartDate" AS date) >= CAST(p_FromDate AS date) 
            AND CAST(p_ToDate AS date) <= CAST("EYC_ExamEndDate" AS date)
    LOOP
        v_emeid := rec."EME_Id";

        SELECT 
            COUNT(CASE WHEN "ESTMP_Result" = 'Pass' THEN "ESTMP_Result" END),
            COUNT(CASE WHEN "ESTMP_Result" = 'Fail' THEN "ESTMP_Result" END),
            COUNT(CASE WHEN "ESTMP_Result" = 'AB' THEN "ESTMP_Result" END),
            COUNT(CASE WHEN "ESTMP_Result" = 'M' THEN "ESTMP_Result" END),
            COUNT(CASE WHEN "ESTMP_Result" = 'L' THEN "ESTMP_Result" END),
            COUNT(CASE WHEN "ESTMP_Result" = 'OD' THEN "ESTMP_Result" END)
        INTO v_Passcount, v_Failcount, v_Absentcount, v_Medicalcount, v_Sportscount, v_ODcount
        FROM "Exm"."Exm_Student_Marks_Process" a 
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = v_ASMAY_Id 
            AND "EME_Id" = v_emeid;

        SELECT COUNT(*) INTO v_SMSCount 
        FROM "IVRM_sms_sentBox"  
        WHERE "Module_Name" = 'Exam' 
            AND CAST(datetime AS date) BETWEEN CAST(p_FromDate AS date) AND CAST(p_ToDate AS date);

        SELECT COUNT(*) INTO v_EmailCount 
        FROM "IVRM_email_sentBox"  
        WHERE "Module_Name" = 'Exam' 
            AND CAST(datetime AS date) BETWEEN CAST(p_FromDate AS date) AND CAST(p_ToDate AS date);

        SELECT COUNT(*) INTO v_HallTicketCount 
        FROM "Exm"."Exm_HallTicket" 
        WHERE "MI_Id" = p_MI_Id 
            AND "ASMAY_Id" = v_ASMAY_Id 
            AND "EME_Id" = v_emeid 
            AND "EHT_ActiveFlag" = 1;

        SELECT "EME_ExamName" INTO v_EME_ExamName 
        FROM "Exm"."Exm_Master_Exam" 
        WHERE "MI_Id" = p_MI_Id 
            AND "EME_ActiveFlag" = 1 
            AND "EME_Id" = v_emeid;

        INSERT INTO "ExamSelectedDatesReport_Temp"(
            "EME_Id", "EME_Name", "Passcount", "Failcount", "Absentcount", 
            "Medicalcount", "Sportscount", "ODcount", "HallTicketCount", 
            "SMSCount", "EmailCount"
        ) 
        VALUES(
            v_emeid, v_EME_ExamName, v_Passcount, v_Failcount, v_Absentcount, 
            v_Medicalcount, v_Sportscount, v_ODcount, v_HallTicketCount, 
            v_SMSCount, v_EmailCount
        );

    END LOOP;

    RETURN QUERY SELECT * FROM "ExamSelectedDatesReport_Temp";

END;
$$;