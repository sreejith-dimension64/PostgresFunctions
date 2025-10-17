CREATE OR REPLACE FUNCTION "dbo"."IVRM_CW_UP_ATTH_Insert"()
RETURNS TABLE (
    "ICWUPL_Id" bigint,
    "ICW_Id" bigint,
    "AMST_Id" bigint,
    "ICWUPL_Date" timestamp,
    "ICWUPL_Details" text,
    "ICWUPL_FileName" text,
    "ICWUPL_Attachment" text,
    "ICWUPL_Marks" decimal(18,2),
    "ICWUPL_ActiveFlag" boolean,
    "CreatedDate" timestamp,
    "UpdatedDate" timestamp,
    "ICWUPL_StaffUplaod" text,
    "ICWUPL_StaffRemarks" text,
    "RNO" bigint
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ICWUPL_Id bigint;
    v_ICW_Id bigint;
    v_AMST_Id bigint;
    v_ICWUPL_Date timestamp;
    v_ICWUPL_Details text;
    v_ICWUPL_FileName text;
    v_ICWUPL_Attachment text;
    v_ICWUPL_Marks decimal(18,2);
    v_ICWUPL_ActiveFlag boolean;
    v_CreatedDate timestamp;
    v_UpdatedDate timestamp;
    v_ICWUPL_StaffUplaod text;
    v_ICWUPL_StaffRemarks text;
    v_ICWUPL_Id_N bigint;
    rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "IVRM_CW_UP_ATTH_Morethan_One_Temp";
    
    DROP TABLE IF EXISTS "IVRM_CW_UP_ATTH_One_Temp";

    CREATE TEMP TABLE "IVRM_CW_UP_ATTH_Morethan_One_Temp" AS
    WITH cte AS
    (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY "AMST_Id", "ICW_Id" ORDER BY "ICWUPL_Id") AS "RNO" 
        FROM "IVRM_ClassWork_Upload"
    )
    SELECT * FROM cte WHERE "RNO" > 1;

    FOR rec IN 
        SELECT "ICWUPL_Id", "ICW_Id", "AMST_Id", "ICWUPL_Date", "ICWUPL_Details", "ICWUPL_FileName", 
               "ICWUPL_Attachment", "ICWUPL_Marks", "ICWUPL_ActiveFlag", "CreatedDate", "UpdatedDate", 
               "ICWUPL_StaffUplaod", "ICWUPL_StaffRemarks" 
        FROM "IVRM_CW_UP_ATTH_Morethan_One_Temp"
    LOOP
        v_ICWUPL_Id := rec."ICWUPL_Id";
        v_ICW_Id := rec."ICW_Id";
        v_AMST_Id := rec."AMST_Id";
        v_ICWUPL_Date := rec."ICWUPL_Date";
        v_ICWUPL_Details := rec."ICWUPL_Details";
        v_ICWUPL_FileName := rec."ICWUPL_FileName";
        v_ICWUPL_Attachment := rec."ICWUPL_Attachment";
        v_ICWUPL_Marks := rec."ICWUPL_Marks";
        v_ICWUPL_ActiveFlag := rec."ICWUPL_ActiveFlag";
        v_CreatedDate := rec."CreatedDate";
        v_UpdatedDate := rec."UpdatedDate";
        v_ICWUPL_StaffUplaod := rec."ICWUPL_StaffUplaod";
        v_ICWUPL_StaffRemarks := rec."ICWUPL_StaffRemarks";

        SELECT "ICWUPL_Id" INTO v_ICWUPL_Id_N 
        FROM "IVRM_ClassWork_Upload" 
        WHERE "ICW_Id" = v_ICW_Id AND "AMST_Id" = v_AMST_Id 
        ORDER BY "ICWUPL_Id"
        LIMIT 1;

        INSERT INTO "IVRM_ClassWork_Upload_Attatchment"
        ("ICWUPL_Id", "ICWUPLATT_FileName", "ICWUPLATT_Attachment", "ICWUPLATT_StaffUpload", 
         "ICWUPLATT_StaffRemarks", "ICWUPLATT_ActiveFlag", "ICWUPLATT_CreatedDate", "ICWUPLATT_UpdatedDate")
        VALUES(v_ICWUPL_Id_N, v_ICWUPL_FileName, v_ICWUPL_Attachment, v_ICWUPL_StaffUplaod, 
               v_ICWUPL_StaffRemarks, v_ICWUPL_ActiveFlag, v_CreatedDate, v_UpdatedDate);

    END LOOP;

    CREATE TEMP TABLE "IVRM_CW_UP_ATTH_One_Temp" AS
    WITH cte AS
    (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY "AMST_Id", "ICW_Id" ORDER BY "ICWUPL_Id") AS "RNO" 
        FROM "IVRM_ClassWork_Upload"
    )
    SELECT * FROM cte WHERE "RNO" = 1;

    INSERT INTO "IVRM_ClassWork_Upload_Attatchment"
    ("ICWUPL_Id", "ICWUPLATT_FileName", "ICWUPLATT_Attachment", "ICWUPLATT_StaffUpload", 
     "ICWUPLATT_StaffRemarks", "ICWUPLATT_ActiveFlag", "ICWUPLATT_CreatedDate", "ICWUPLATT_UpdatedDate")
    SELECT "ICWUPL_Id", "ICWUPL_FileName", "ICWUPL_Attachment", "ICWUPL_StaffUplaod", 
           "ICWUPL_StaffRemarks", "ICWUPL_ActiveFlag", "CreatedDate", "UpdatedDate" 
    FROM "IVRM_CW_UP_ATTH_One_Temp";

    RETURN QUERY
    WITH cte AS
    (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY "AMST_Id", "ICW_Id" ORDER BY "ICWUPL_Id") AS "RNO" 
        FROM "IVRM_ClassWork_Upload"
    )
    SELECT cte."ICWUPL_Id", cte."ICW_Id", cte."AMST_Id", cte."ICWUPL_Date", cte."ICWUPL_Details", 
           cte."ICWUPL_FileName", cte."ICWUPL_Attachment", cte."ICWUPL_Marks", cte."ICWUPL_ActiveFlag", 
           cte."CreatedDate", cte."UpdatedDate", cte."ICWUPL_StaffUplaod", cte."ICWUPL_StaffRemarks", 
           cte."RNO" 
    FROM cte 
    WHERE cte."RNO" > 1;

END;
$$;