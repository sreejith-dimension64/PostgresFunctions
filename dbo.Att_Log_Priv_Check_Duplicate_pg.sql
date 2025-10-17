CREATE OR REPLACE FUNCTION "dbo"."Att_Log_Priv_Check_Duplicate"(
    "ASALU_EntryTypeFlag" INT,
    "ASMAY_Id" INT,
    "IVRMUL_Id" INT,
    "MI_Id" INT,
    "ASMCL_Id" INT,
    "ASMC_Id" INT,
    "PAMS_Id" INT,
    "Type" INT
)
RETURNS TABLE(
    "ASALU_Id" INT,
    "ASALU_EntryTypeFlag" INT,
    "ASMAY_Id" INT,
    "HRME_Id" INT,
    "MI_Id" INT,
    "ASALU_ActiveFlag" BOOLEAN,
    "ASALU_CreatedBy" INT,
    "ASALU_CreatedDate" TIMESTAMP,
    "ASALU_UpdatedBy" INT,
    "ASALU_UpdatedDate" TIMESTAMP,
    "ASALUC_Id" INT,
    "ASMCL_Id" INT,
    "ASMS_Id" INT,
    "ASALUC_ActiveFlag" BOOLEAN,
    "ASALUC_CreatedBy" INT,
    "ASALUC_CreatedDate" TIMESTAMP,
    "ASALUC_UpdatedBy" INT,
    "ASALUC_UpdatedDate" TIMESTAMP,
    "ASALUCS_Id" INT,
    "ISMS_Id" INT,
    "ASALUCS_ActiveFlag" BOOLEAN,
    "ASALUCS_CreatedBy" INT,
    "ASALUCS_CreatedDate" TIMESTAMP,
    "ASALUCS_UpdatedBy" INT,
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
        WHERE usr."ASALU_EntryTypeFlag" = "Att_Log_Priv_Check_Duplicate"."ASALU_EntryTypeFlag" 
          AND usr."ASMAY_Id" = "Att_Log_Priv_Check_Duplicate"."ASMAY_Id" 
          AND usr."HRME_Id" = "Att_Log_Priv_Check_Duplicate"."IVRMUL_Id" 
          AND usr."MI_Id" = "Att_Log_Priv_Check_Duplicate"."MI_Id"
          AND cls."ASMCL_Id" = "Att_Log_Priv_Check_Duplicate"."ASMCL_Id" 
          AND cls."ASMS_Id" = "Att_Log_Priv_Check_Duplicate"."ASMC_Id" 
          AND sub."ISMS_Id" = "Att_Log_Priv_Check_Duplicate"."PAMS_Id";
    ELSE
        RETURN QUERY
        SELECT usr.*, cls.*
        FROM "Adm_School_Attendance_Login_User" usr
        INNER JOIN "Adm_School_Attendance_Login_User_Class" cls ON usr."ASALU_Id" = cls."ASALU_Id"
        WHERE usr."ASALU_EntryTypeFlag" = "Att_Log_Priv_Check_Duplicate"."ASALU_EntryTypeFlag" 
          AND usr."ASMAY_Id" = "Att_Log_Priv_Check_Duplicate"."ASMAY_Id" 
          AND usr."HRME_Id" = "Att_Log_Priv_Check_Duplicate"."IVRMUL_Id" 
          AND usr."MI_Id" = "Att_Log_Priv_Check_Duplicate"."MI_Id"
          AND cls."ASMCL_Id" = "Att_Log_Priv_Check_Duplicate"."ASMCL_Id" 
          AND cls."ASMS_Id" = "Att_Log_Priv_Check_Duplicate"."ASMC_Id";
    END IF;
    
    RETURN;
END;
$$;