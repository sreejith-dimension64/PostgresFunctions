CREATE OR REPLACE FUNCTION "dbo"."IVRM_HW_UP_ATTH_Insert"()
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_IHWUPL_Id bigint;
    v_IHW_Id bigint;
    v_AMST_Id bigint;
    v_IHWUPL_Date timestamp;
    v_IHWUPL_Details text;
    v_IHWUPL_FileName text;
    v_IHWUPL_Attachment text;
    v_IHWUPL_Marks decimal(18,2);
    v_IHWUPL_ActiveFlag boolean;
    v_CreatedDate timestamp;
    v_UpdatedDate timestamp;
    v_IHWUPL_StaffRemarks text;
    v_IHWUPL_StaffUpload text;
    v_IHWUPL_Id_N bigint;
    rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "IVRM_HW_UP_ATTH_Morethan_One_Temp";
    DROP TABLE IF EXISTS "IVRM_HW_UP_ATTH_One_Temp";

    CREATE TEMP TABLE "IVRM_HW_UP_ATTH_Morethan_One_Temp" AS
    WITH cte AS
    (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY "AMST_Id", "IHW_Id" ORDER BY "IHWUPL_Id") AS "RNO" 
        FROM "IVRM_HomeWork_Upload"
    )
    SELECT * FROM cte WHERE "RNO" > 1;

    FOR rec IN 
        SELECT "IHWUPL_Id", "IHW_Id", "AMST_Id", "IHWUPL_Date", "IHWUPL_Details", "IHWUPL_FileName", 
               "IHWUPL_Attachment", "IHWUPL_Marks", "IHWUPL_ActiveFlag", "CreatedDate", "UpdatedDate", 
               "IHWUPL_StaffUpload", "IHWUPL_StaffRemarks" 
        FROM "IVRM_HW_UP_ATTH_Morethan_One_Temp"
    LOOP
        v_IHWUPL_Id := rec."IHWUPL_Id";
        v_IHW_Id := rec."IHW_Id";
        v_AMST_Id := rec."AMST_Id";
        v_IHWUPL_Date := rec."IHWUPL_Date";
        v_IHWUPL_Details := rec."IHWUPL_Details";
        v_IHWUPL_FileName := rec."IHWUPL_FileName";
        v_IHWUPL_Attachment := rec."IHWUPL_Attachment";
        v_IHWUPL_Marks := rec."IHWUPL_Marks";
        v_IHWUPL_ActiveFlag := rec."IHWUPL_ActiveFlag";
        v_CreatedDate := rec."CreatedDate";
        v_UpdatedDate := rec."UpdatedDate";
        v_IHWUPL_StaffUpload := rec."IHWUPL_StaffUpload";
        v_IHWUPL_StaffRemarks := rec."IHWUPL_StaffRemarks";

        SELECT "IHWUPL_Id" INTO v_IHWUPL_Id_N 
        FROM "IVRM_HomeWork_Upload" 
        WHERE "IHW_Id" = v_IHW_Id AND "AMST_Id" = v_AMST_Id 
        ORDER BY "IHWUPL_Id" 
        LIMIT 1;

        INSERT INTO "IVRM_HomeWork_Upload_Attatchment"
        ("IHWUPL_Id", "IHWUPLATT_FileName", "IHWUPLATT_Attachment", "IHWUPLATT_StaffUpload", 
         "IHWUPLATT_StaffRemarks", "IHWUPLATT_ActiveFlag", "IHWUPLATT_CreatedDate", "IHWUPLATT_UpdatedDate")
        VALUES(v_IHWUPL_Id_N, v_IHWUPL_FileName, v_IHWUPL_Attachment, v_IHWUPL_StaffUpload, 
               v_IHWUPL_StaffRemarks, v_IHWUPL_ActiveFlag, v_CreatedDate, v_UpdatedDate);

    END LOOP;

    CREATE TEMP TABLE "IVRM_HW_UP_ATTH_One_Temp" AS
    WITH cte AS
    (
        SELECT *, ROW_NUMBER() OVER(PARTITION BY "AMST_Id", "IHW_Id" ORDER BY "IHWUPL_Id") AS "RNO" 
        FROM "IVRM_HomeWork_Upload"
    )
    SELECT * FROM cte WHERE "RNO" = 1;

    INSERT INTO "IVRM_HomeWork_Upload_Attatchment"
    ("IHWUPL_Id", "IHWUPLATT_FileName", "IHWUPLATT_Attachment", "IHWUPLATT_StaffUpload", 
     "IHWUPLATT_StaffRemarks", "IHWUPLATT_ActiveFlag", "IHWUPLATT_CreatedDate", "IHWUPLATT_UpdatedDate")
    SELECT "IHWUPL_Id", "IHWUPL_FileName", "IHWUPL_Attachment", "IHWUPL_StaffUpload", 
           "IHWUPL_StaffRemarks", "IHWUPL_ActiveFlag", "CreatedDate", "UpdatedDate" 
    FROM "IVRM_HW_UP_ATTH_One_Temp";

    RETURN;

END;
$$;