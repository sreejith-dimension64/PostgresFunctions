CREATE OR REPLACE FUNCTION "dbo"."GET_LIB_MONTH_END_REPORT"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_frmdate text,
    p_todate text
)
RETURNS TABLE(
    "STDISSUECNT" bigint,
    "STDRETURNCNT" bigint,
    "STFISSUECNT" bigint,
    "STFRETURNCNT" bigint,
    "DEPISSUECNT" bigint,
    "DEPRETURNCNT" bigint,
    "GSTISSUECNT" bigint,
    "GSTRETURNCNT" bigint,
    "FINEAMOUNT" decimal,
    "SMSCOUNT" bigint,
    "EMAILCOUNT" bigint,
    "TOTALBOOK" bigint,
    "AVAILBOOK" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_STDISSUECNT bigint;
    v_STDRETURNCNT bigint;
    v_STFISSUECNT bigint;
    v_STFRETURNCNT bigint;
    v_DEPISSUECNT bigint;
    v_DEPRETURNCNT bigint;
    v_GSTISSUECNT bigint;
    v_GSTRETURNCNT bigint;
    v_FINEAMOUNT decimal;
    v_SMSCOUNT bigint;
    v_EMAILCOUNT bigint;
    v_TOTALBOOK bigint;
    v_AVAILBOOK bigint;
    v_FLAG varchar(10);
BEGIN
    DROP TABLE IF EXISTS "LIBMONTHENDT";
    
    CREATE TEMP TABLE "LIBMONTHENDT"(
        "STDISSUECNT" bigint,
        "STDRETURNCNT" bigint,
        "STFISSUECNT" bigint,
        "STFRETURNCNT" bigint,
        "DEPISSUECNT" bigint,
        "DEPRETURNCNT" bigint,
        "GSTISSUECNT" bigint,
        "GSTRETURNCNT" bigint,
        "FINEAMOUNT" decimal,
        "SMSCOUNT" bigint,
        "EMAILCOUNT" bigint,
        "TOTALBOOK" bigint,
        "AVAILBOOK" bigint
    );

    SELECT "MI_SchoolCollegeFlag" INTO v_FLAG 
    FROM "Master_Institution" 
    WHERE "MI_Id" = p_MI_Id;

    IF v_FLAG = 'S' THEN
        SELECT count("LBTR_Status") INTO v_STDISSUECNT 
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Student" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'Issue' 
        AND EXTRACT(YEAR FROM "LBTR_IssuedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT count("LBTR_Status") INTO v_STDRETURNCNT 
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Student" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'return' 
        AND EXTRACT(YEAR FROM "LBTR_ReturnedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT count("LBTR_Status") INTO v_STFISSUECNT 
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Staff" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'Issue' 
        AND EXTRACT(YEAR FROM "LBTR_IssuedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT count("LBTR_Status") INTO v_STFRETURNCNT 
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Staff" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = 8 AND "LBTR_Status" = 'return' 
        AND EXTRACT(YEAR FROM "LBTR_ReturnedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT count("LBTR_Status") INTO v_DEPISSUECNT 
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Department" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'Issue' 
        AND EXTRACT(YEAR FROM "LBTR_IssuedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT count("LBTR_Status") INTO v_DEPRETURNCNT 
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Department" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'return' 
        AND EXTRACT(YEAR FROM "LBTR_ReturnedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT count("LBTR_Status") INTO v_GSTISSUECNT 
        FROM "LIB"."LIB_Book_Transaction"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'Issue' 
        AND "LBTR_GuestName" <> '' AND "LBTR_GuestName" IS NOT NULL 
        AND EXTRACT(YEAR FROM "LBTR_IssuedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT count("LBTR_Status") INTO v_GSTRETURNCNT 
        FROM "LIB"."LIB_Book_Transaction"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'return' 
        AND "LBTR_GuestName" <> '' AND "LBTR_GuestName" IS NOT NULL 
        AND EXTRACT(YEAR FROM "LBTR_ReturnedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT COALESCE(SUM("LBTR_TotalFine"), 0) INTO v_FINEAMOUNT 
        FROM "LIB"."LIB_Book_Transaction" 
        WHERE "MI_Id" = p_MI_Id 
        AND EXTRACT(YEAR FROM "LBTR_IssuedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT COUNT("IVRM_SSB_ID") INTO v_SMSCOUNT 
        FROM "IVRM_sms_sentBox" 
        WHERE "Module_Name" = 'Library' AND "MI_Id" = p_MI_Id
        AND EXTRACT(YEAR FROM "Datetime") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "Datetime") = p_todate::int 
        AND "Mobile_no" <> '0' AND "Mobile_no" <> '';

        SELECT COUNT("IVRMESB_ID") INTO v_EMAILCOUNT 
        FROM "IVRM_Email_sentBox" 
        WHERE "Module_Name" = 'Library' AND "MI_Id" = p_MI_Id
        AND EXTRACT(YEAR FROM "Datetime") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "Datetime") = p_todate::int 
        AND "Email_Id" <> '';

        SELECT Count("B"."LMBANO_AccessionNo") INTO v_TOTALBOOK
        FROM "LIB"."LIB_Master_Book" AS "A"
        INNER JOIN "LIB"."LIB_Master_Book_AccnNo" AS "B" ON "A"."LMB_Id" = "B"."LMB_Id" 
        WHERE "A"."LMB_ActiveFlg" = 1 AND "B"."LMBANO_ActiveFlg" = 1 
        AND "B"."LMBANO_AvialableStatus" = 'Available' AND "MI_Id" = p_MI_Id;

        SELECT Count("B"."LMBANO_AccessionNo") INTO v_AVAILBOOK
        FROM "LIB"."LIB_Master_Book" AS "A"
        INNER JOIN "LIB"."LIB_Master_Book_AccnNo" AS "B" ON "A"."LMB_Id" = "B"."LMB_Id" 
        WHERE "A"."LMB_ActiveFlg" = 1 AND "B"."LMBANO_ActiveFlg" = 1 
        AND "B"."LMBANO_AvialableStatus" = 'Available' AND "MI_Id" = p_MI_Id 
        AND "B"."LMBANO_Id" NOT IN (
            SELECT DISTINCT "D"."LMBANO_Id" 
            FROM "LIB"."LIB_Master_Book_AccnNo" AS "D"
            INNER JOIN "LIB"."LIB_Book_Transaction" AS "DD" ON "D"."LMBANO_Id" = "DD"."LMBANO_Id"
            WHERE "DD"."MI_Id" = p_MI_Id AND "DD"."LBTR_Status" = 'Issue' 
            AND "DD"."LBTR_ActiveFlg" = 1 
            AND "D"."LMBANO_AvialableStatus" = 'Available'
        );
    ELSE
        SELECT count("LBTR_Status") INTO v_STDISSUECNT 
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Student_College" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'Issue' 
        AND EXTRACT(YEAR FROM "LBTR_IssuedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT count("LBTR_Status") INTO v_STDRETURNCNT 
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Student_College" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'return' 
        AND EXTRACT(YEAR FROM "LBTR_ReturnedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT count("LBTR_Status") INTO v_STFISSUECNT 
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Staff" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'Issue' 
        AND EXTRACT(YEAR FROM "LBTR_IssuedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT count("LBTR_Status") INTO v_STFRETURNCNT 
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Staff" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = 8 AND "LBTR_Status" = 'return' 
        AND EXTRACT(YEAR FROM "LBTR_ReturnedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT count("LBTR_Status") INTO v_DEPISSUECNT 
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Department" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'Issue' 
        AND EXTRACT(YEAR FROM "LBTR_IssuedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT count("LBTR_Status") INTO v_DEPRETURNCNT 
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Department" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'return' 
        AND EXTRACT(YEAR FROM "LBTR_ReturnedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT count("LBTR_Status") INTO v_GSTISSUECNT 
        FROM "LIB"."LIB_Book_Transaction"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'Issue' 
        AND "LBTR_GuestName" <> '' AND "LBTR_GuestName" IS NOT NULL 
        AND EXTRACT(YEAR FROM "LBTR_IssuedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT count("LBTR_Status") INTO v_GSTRETURNCNT 
        FROM "LIB"."LIB_Book_Transaction"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'return' 
        AND "LBTR_GuestName" <> '' AND "LBTR_GuestName" IS NOT NULL 
        AND EXTRACT(YEAR FROM "LBTR_ReturnedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT COALESCE(SUM("LBTR_TotalFine"), 0) INTO v_FINEAMOUNT 
        FROM "LIB"."LIB_Book_Transaction" 
        WHERE "MI_Id" = p_MI_Id 
        AND EXTRACT(YEAR FROM "LBTR_IssuedDate") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "LBTR_IssuedDate") = p_todate::int;

        SELECT COUNT("IVRM_SSB_ID") INTO v_SMSCOUNT 
        FROM "IVRM_sms_sentBox" 
        WHERE "Module_Name" = 'Library' AND "MI_Id" = p_MI_Id
        AND EXTRACT(YEAR FROM "Datetime") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "Datetime") = p_todate::int 
        AND "Mobile_no" <> '0' AND "Mobile_no" <> '';

        SELECT COUNT("IVRMESB_ID") INTO v_EMAILCOUNT 
        FROM "IVRM_Email_sentBox" 
        WHERE "Module_Name" = 'Library' AND "MI_Id" = p_MI_Id
        AND EXTRACT(YEAR FROM "Datetime") = p_frmdate::int 
        AND EXTRACT(MONTH FROM "Datetime") = p_todate::int 
        AND "Email_Id" <> '';

        SELECT Count("B"."LMBANO_AccessionNo") INTO v_TOTALBOOK
        FROM "LIB"."LIB_Master_Book" AS "A"
        INNER JOIN "LIB"."LIB_Master_Book_AccnNo" AS "B" ON "A"."LMB_Id" = "B"."LMB_Id" 
        WHERE "A"."LMB_ActiveFlg" = 1 AND "B"."LMBANO_ActiveFlg" = 1 
        AND "B"."LMBANO_AvialableStatus" = 'Available' AND "MI_Id" = p_MI_Id;

        SELECT Count("B"."LMBANO_AccessionNo") INTO v_AVAILBOOK
        FROM "LIB"."LIB_Master_Book" AS "A"
        INNER JOIN "LIB"."LIB_Master_Book_AccnNo" AS "B" ON "A"."LMB_Id" = "B"."LMB_Id" 
        WHERE "A"."LMB_ActiveFlg" = 1 AND "B"."LMBANO_ActiveFlg" = 1 
        AND "B"."LMBANO_AvialableStatus" = 'Available' AND "MI_Id" = p_MI_Id 
        AND "B"."LMBANO_Id" NOT IN (
            SELECT DISTINCT "D"."LMBANO_Id" 
            FROM "LIB"."LIB_Master_Book_AccnNo" AS "D"
            INNER JOIN "LIB"."LIB_Book_Transaction" AS "DD" ON "D"."LMBANO_Id" = "DD"."LMBANO_Id"
            WHERE "DD"."MI_Id" = p_MI_Id AND "DD"."LBTR_Status" = 'Issue' 
            AND "DD"."LBTR_ActiveFlg" = 1 
            AND "D"."LMBANO_AvialableStatus" = 'Available'
        );
    END IF;

    INSERT INTO "LIBMONTHENDT"(
        "STDISSUECNT", "STDRETURNCNT", "STFISSUECNT", "STFRETURNCNT", 
        "DEPISSUECNT", "DEPRETURNCNT", "GSTISSUECNT", "GSTRETURNCNT", 
        "FINEAMOUNT", "SMSCOUNT", "EMAILCOUNT", "TOTALBOOK", "AVAILBOOK"
    )
    VALUES(
        v_STDISSUECNT, v_STDRETURNCNT, v_STFISSUECNT, v_STFRETURNCNT, 
        v_DEPISSUECNT, v_DEPRETURNCNT, v_GSTISSUECNT, v_GSTRETURNCNT, 
        v_FINEAMOUNT, v_SMSCOUNT, v_EMAILCOUNT, v_TOTALBOOK, v_AVAILBOOK
    );

    RETURN QUERY SELECT * FROM "LIBMONTHENDT";
END;
$$;