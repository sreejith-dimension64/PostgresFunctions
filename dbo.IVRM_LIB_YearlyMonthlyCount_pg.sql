CREATE OR REPLACE FUNCTION "dbo"."IVRM_LIB_YearlyMonthlyCount"(
    p_MI_Id bigint,
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
    "FINEAMOUNT" numeric,
    "SMSCOUNT" bigint,
    "EMAILCOUNT" bigint,
    "TOTALBOOK" bigint,
    "AVAILBOOK" bigint,
    "PURCHASECNT" bigint,
    "DONATECNT" bigint
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
    v_FINEAMOUNT numeric;
    v_SMSCOUNT bigint;
    v_EMAILCOUNT bigint;
    v_TOTALBOOK bigint;
    v_AVAILBOOK bigint;
    v_PURCHASECNT bigint;
    v_DONATECNT bigint;
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
        "FINEAMOUNT" numeric,
        "SMSCOUNT" bigint,
        "EMAILCOUNT" bigint,
        "TOTALBOOK" bigint,
        "AVAILBOOK" bigint,
        "PURCHASECNT" bigint,
        "DONATECNT" bigint
    );
    
    SELECT "MI_SchoolCollegeFlag" INTO v_FLAG 
    FROM "Master_Institution" 
    WHERE "MI_Id" = p_MI_Id;
    
    IF v_FLAG = 'S' THEN
        SELECT COUNT("LBTR_Status") INTO v_STDISSUECNT
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Student" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "A"."MI_Id" = p_MI_Id
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("LBTR_Status") INTO v_STDRETURNCNT
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Student" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "A"."MI_Id" = p_MI_Id AND "LBTR_Status" = 'return'
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("LBTR_Status") INTO v_STFISSUECNT
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Staff" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("LBTR_Status") INTO v_STFRETURNCNT
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Staff" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'return'
        AND CAST("LBTR_ReturnedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_ReturnedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("LBTR_Status") INTO v_DEPISSUECNT
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Department" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("LBTR_Status") INTO v_DEPRETURNCNT
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Department" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'return'
        AND CAST("LBTR_ReturnedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_ReturnedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("LBTR_Status") INTO v_GSTISSUECNT
        FROM "LIB"."LIB_Book_Transaction"
        WHERE "MI_Id" = p_MI_Id
        AND "LBTR_GuestName" <> '' AND "LBTR_GuestName" IS NOT NULL
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("LBTR_Status") INTO v_GSTRETURNCNT
        FROM "LIB"."LIB_Book_Transaction"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'return'
        AND "LBTR_GuestName" <> '' AND "LBTR_GuestName" IS NOT NULL
        AND CAST("LBTR_ReturnedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_ReturnedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COALESCE(SUM("LBTR_TotalFine"), 0) INTO v_FINEAMOUNT
        FROM "LIB"."LIB_Book_Transaction"
        WHERE "MI_Id" = p_MI_Id
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("IVRM_SSB_ID") INTO v_SMSCOUNT
        FROM "IVRM_sms_sentBox"
        WHERE "Module_Name" = 'Library' AND "MI_Id" = p_MI_Id
        AND "Datetime" = CAST(p_frmdate AS timestamp) 
        AND "Datetime" = CAST(p_todate AS timestamp)
        AND "Mobile_no" <> '0' AND "Mobile_no" <> '';
        
        SELECT COUNT("IVRMESB_ID") INTO v_EMAILCOUNT
        FROM "IVRM_Email_sentBox"
        WHERE "Module_Name" = 'Library' AND "MI_Id" = p_MI_Id
        AND "Datetime" = CAST(p_frmdate AS timestamp) 
        AND "Datetime" = CAST(p_todate AS timestamp)
        AND "Email_Id" <> '';
        
        SELECT COUNT("B"."LMBANO_AccessionNo") INTO v_TOTALBOOK
        FROM "LIB"."LIB_Master_Book" AS "A"
        INNER JOIN "LIB"."LIB_Master_Book_AccnNo" AS "B" ON "A"."LMB_Id" = "B"."LMB_Id"
        WHERE "A"."LMB_ActiveFlg" = TRUE 
        AND "B"."LMBANO_ActiveFlg" = TRUE 
        AND "B"."LMBANO_AvialableStatus" = 'Available' 
        AND "MI_Id" = p_MI_Id;
        
        SELECT COUNT("B"."LMBANO_AccessionNo") INTO v_PURCHASECNT
        FROM "LIB"."LIB_Master_Book" AS "A"
        INNER JOIN "LIB"."LIB_Master_Book_AccnNo" AS "B" ON "A"."LMB_Id" = "B"."LMB_Id"
        WHERE "A"."LMB_ActiveFlg" = TRUE 
        AND "B"."LMBANO_ActiveFlg" = TRUE 
        AND "A"."LMB_PurOrDonated" = 'Purchased' 
        AND "MI_Id" = p_MI_Id;
        
        SELECT COUNT("B"."LMBANO_AccessionNo") INTO v_DONATECNT
        FROM "LIB"."LIB_Master_Book" AS "A"
        INNER JOIN "LIB"."LIB_Master_Book_AccnNo" AS "B" ON "A"."LMB_Id" = "B"."LMB_Id"
        WHERE "A"."LMB_ActiveFlg" = TRUE 
        AND "B"."LMBANO_ActiveFlg" = TRUE 
        AND "A"."LMB_PurOrDonated" = 'Donated' 
        AND "MI_Id" = p_MI_Id;
        
        SELECT COUNT("B"."LMBANO_AccessionNo") INTO v_AVAILBOOK
        FROM "LIB"."LIB_Master_Book" AS "A"
        INNER JOIN "LIB"."LIB_Master_Book_AccnNo" AS "B" ON "A"."LMB_Id" = "B"."LMB_Id"
        WHERE "A"."LMB_ActiveFlg" = TRUE 
        AND "B"."LMBANO_ActiveFlg" = TRUE 
        AND "B"."LMBANO_AvialableStatus" = 'Available' 
        AND "MI_Id" = p_MI_Id
        AND "B"."LMBANO_Id" NOT IN (
            SELECT DISTINCT "D"."LMBANO_Id" 
            FROM "LIB"."LIB_Master_Book_AccnNo" AS "D"
            INNER JOIN "LIB"."LIB_Book_Transaction" AS "DD" ON "D"."LMBANO_Id" = "DD"."LMBANO_Id"
            WHERE "DD"."MI_Id" = p_MI_Id 
            AND "DD"."LBTR_Status" = 'Issue' 
            AND "DD"."LBTR_ActiveFlg" = TRUE
            AND "D"."LMBANO_AvialableStatus" = 'Available'
        );
    ELSE
        SELECT COUNT("LBTR_Status") INTO v_STDISSUECNT
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Student_College" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("LBTR_Status") INTO v_STDRETURNCNT
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Student_College" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'return'
        AND CAST("LBTR_ReturnedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_ReturnedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("LBTR_Status") INTO v_STFISSUECNT
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Staff" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("LBTR_Status") INTO v_STFRETURNCNT
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Staff" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'return'
        AND CAST("LBTR_ReturnedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_ReturnedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("LBTR_Status") INTO v_DEPISSUECNT
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Department" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("LBTR_Status") INTO v_DEPRETURNCNT
        FROM "LIB"."LIB_Book_Transaction" AS "A"
        INNER JOIN "LIB"."LIB_Book_Transaction_Department" AS "B" ON "A"."LBTR_Id" = "B"."LBTR_Id"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'return'
        AND CAST("LBTR_ReturnedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_ReturnedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("LBTR_Status") INTO v_GSTISSUECNT
        FROM "LIB"."LIB_Book_Transaction"
        WHERE "MI_Id" = p_MI_Id
        AND "LBTR_GuestName" <> '' AND "LBTR_GuestName" IS NOT NULL
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("LBTR_Status") INTO v_GSTRETURNCNT
        FROM "LIB"."LIB_Book_Transaction"
        WHERE "MI_Id" = p_MI_Id AND "LBTR_Status" = 'return'
        AND "LBTR_GuestName" <> '' AND "LBTR_GuestName" IS NOT NULL
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COALESCE(SUM("LBTR_TotalFine"), 0) INTO v_FINEAMOUNT
        FROM "LIB"."LIB_Book_Transaction"
        WHERE "MI_Id" = p_MI_Id
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_frmdate AS date) 
        AND CAST("LBTR_IssuedDate" AS date) = CAST(p_todate AS date);
        
        SELECT COUNT("IVRM_SSB_ID") INTO v_SMSCOUNT
        FROM "IVRM_sms_sentBox"
        WHERE "Module_Name" = 'Library' AND "MI_Id" = p_MI_Id
        AND "Datetime" = CAST(p_frmdate AS timestamp) 
        AND "Datetime" = CAST(p_todate AS timestamp)
        AND "Mobile_no" <> '0' AND "Mobile_no" <> '';
        
        SELECT COUNT("IVRMESB_ID") INTO v_EMAILCOUNT
        FROM "IVRM_Email_sentBox"
        WHERE "Module_Name" = 'Library' AND "MI_Id" = p_MI_Id
        AND "Datetime" = CAST(p_frmdate AS timestamp) 
        AND "Datetime" = CAST(p_todate AS timestamp)
        AND "Email_Id" <> '';
        
        SELECT COUNT("B"."LMBANO_AccessionNo") INTO v_TOTALBOOK
        FROM "LIB"."LIB_Master_Book" AS "A"
        INNER JOIN "LIB"."LIB_Master_Book_AccnNo" AS "B" ON "A"."LMB_Id" = "B"."LMB_Id"
        WHERE "A"."LMB_ActiveFlg" = TRUE 
        AND "B"."LMBANO_ActiveFlg" = TRUE 
        AND "B"."LMBANO_AvialableStatus" = 'Available' 
        AND "MI_Id" = p_MI_Id;
        
        SELECT COUNT("B"."LMBANO_AccessionNo") INTO v_AVAILBOOK
        FROM "LIB"."LIB_Master_Book" AS "A"
        INNER JOIN "LIB"."LIB_Master_Book_AccnNo" AS "B" ON "A"."LMB_Id" = "B"."LMB_Id"
        WHERE "A"."LMB_ActiveFlg" = TRUE 
        AND "B"."LMBANO_ActiveFlg" = TRUE 
        AND "B"."LMBANO_AvialableStatus" = 'Available' 
        AND "MI_Id" = p_MI_Id
        AND "B"."LMBANO_Id" NOT IN (
            SELECT DISTINCT "D"."LMBANO_Id" 
            FROM "LIB"."LIB_Master_Book_AccnNo" AS "D"
            INNER JOIN "LIB"."LIB_Book_Transaction" AS "DD" ON "D"."LMBANO_Id" = "DD"."LMBANO_Id"
            WHERE "DD"."MI_Id" = p_MI_Id 
            AND "DD"."LBTR_Status" = 'Issue' 
            AND "DD"."LBTR_ActiveFlg" = TRUE
            AND "D"."LMBANO_AvialableStatus" = 'Available'
        );
        
        v_PURCHASECNT := NULL;
        v_DONATECNT := NULL;
    END IF;
    
    INSERT INTO "LIBMONTHENDT"(
        "STDISSUECNT", "STDRETURNCNT", "STFISSUECNT", "STFRETURNCNT", 
        "DEPISSUECNT", "DEPRETURNCNT", "GSTISSUECNT", "GSTRETURNCNT", 
        "FINEAMOUNT", "SMSCOUNT", "EMAILCOUNT", "TOTALBOOK", 
        "AVAILBOOK", "PURCHASECNT", "DONATECNT"
    )
    VALUES(
        v_STDISSUECNT, v_STDRETURNCNT, v_STFISSUECNT, v_STFRETURNCNT, 
        v_DEPISSUECNT, v_DEPRETURNCNT, v_GSTISSUECNT, v_GSTRETURNCNT, 
        v_FINEAMOUNT, v_SMSCOUNT, v_EMAILCOUNT, v_TOTALBOOK, 
        v_AVAILBOOK, v_PURCHASECNT, v_DONATECNT
    );
    
    RETURN QUERY SELECT * FROM "LIBMONTHENDT";
END;
$$;