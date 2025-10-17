CREATE OR REPLACE FUNCTION "dbo"."Att_Log_Priv_Check_Duplicate_New"(
    "ASALU_EntryTypeFlag" INT,
    "ASMAY_Id" INT,
    "IVRMUL_Id" INT,
    "MI_Id" INT,
    "ASMCL_Id" INT,
    "ASMC_Id" INT,
    "PAMS_Id" INT,
    "Type" INT,
    "ASALU_Id" TEXT
)
RETURNS TABLE(
    "ASALU_Id" BIGINT,
    "ASALU_EntryTypeFlag" INT,
    "ASMAY_Id" BIGINT,
    "HRME_Id" BIGINT,
    "MI_Id" BIGINT,
    "ASALU_ActiveFlg" BOOLEAN,
    "ASALU_CreatedBy" BIGINT,
    "ASALU_UpdatedBy" BIGINT,
    "ASALU_CreatedDate" TIMESTAMP,
    "ASALU_UpdatedDate" TIMESTAMP,
    "ASALUC_Id" BIGINT,
    "ASALUC_ASALU_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "ASALUC_ActiveFlg" BOOLEAN,
    "ASALUC_CreatedBy" BIGINT,
    "ASALUC_UpdatedBy" BIGINT,
    "ASALUC_CreatedDate" TIMESTAMP,
    "ASALUC_UpdatedDate" TIMESTAMP,
    "ASALUCS_Id" BIGINT,
    "ASALUCS_ASALUC_Id" BIGINT,
    "ISMS_Id" BIGINT,
    "ASALUCS_ActiveFlg" BOOLEAN,
    "ASALUCS_CreatedBy" BIGINT,
    "ASALUCS_UpdatedBy" BIGINT,
    "ASALUCS_CreatedDate" TIMESTAMP,
    "ASALUCS_UpdatedDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "Type" = 1 THEN
        RETURN QUERY
        SELECT usr.*, cls.*, sub.*
        FROM "Adm_School_Attendance_Login_User" usr
        INNER JOIN "Adm_School_Attendance_Login_User_Class" cls ON usr."ASALU_Id" = cls."ASALU_Id"
        INNER JOIN "Adm_School_Attendance_Login_User_Class_Subjects" sub ON cls."ASALUC_Id" = sub."ASALUC_Id"
        WHERE usr."ASALU_EntryTypeFlag" = "ASALU_EntryTypeFlag" 
        AND usr."ASMAY_Id" = "ASMAY_Id" 
        AND usr."HRME_Id" = "IVRMUL_Id" 
        AND usr."MI_Id" = "MI_Id"
        AND cls."ASMCL_Id" = "ASMCL_Id" 
        AND cls."ASMS_Id" = "ASMC_Id" 
        AND sub."ISMS_Id" = "PAMS_Id" 
        AND usr."ASALU_Id"::TEXT != "ASALU_Id";
    ELSE
        RETURN QUERY
        SELECT usr.*, cls.*, NULL::BIGINT, NULL::BIGINT, NULL::BIGINT, NULL::BOOLEAN, NULL::BIGINT, NULL::BIGINT, NULL::TIMESTAMP, NULL::TIMESTAMP
        FROM "Adm_School_Attendance_Login_User" usr
        INNER JOIN "Adm_School_Attendance_Login_User_Class" cls ON usr."ASALU_Id" = cls."ASALU_Id"
        WHERE usr."ASALU_EntryTypeFlag" = "ASALU_EntryTypeFlag" 
        AND usr."ASMAY_Id" = "ASMAY_Id" 
        AND usr."HRME_Id" = "IVRMUL_Id" 
        AND usr."MI_Id" = "MI_Id"
        AND cls."ASMCL_Id" = "ASMCL_Id" 
        AND cls."ASMS_Id" = "ASMC_Id" 
        AND usr."ASALU_Id"::TEXT != "ASALU_Id";
    END IF;
END;
$$;