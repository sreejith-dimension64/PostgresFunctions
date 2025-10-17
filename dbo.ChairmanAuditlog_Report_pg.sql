CREATE OR REPLACE FUNCTION "dbo"."ChairmanAuditlog_Report"(
    "User_Id" bigint,
    "fromdate" date,
    "todate" date
)
RETURNS TABLE(
    "ITAT_TableName" TEXT,
    "ITAT_RecordPKID" bigint,
    "ITAT_Id" bigint,
    "ITAT_Date" TIMESTAMP,
    "ITAT_Time" TEXT,
    "ITAT_Operation" TEXT,
    "IATD_CurrentValue" TEXT,
    "ITAT_NetworkIp" TEXT,
    "ITAT_MAACAddress" TEXT,
    "FYP_Id" bigint,
    "AMST_Id" bigint,
    "ASMAY_Id" bigint,
    "FTP_TotalPaidAmount" bigint,
    "FTP_TotalWaivedAmount" bigint,
    "FTP_TotalConcessionAmount" bigint,
    "FTP_TotalFineAmount" bigint,
    "StudentName" TEXT,
    "AMST_AdmNo" TEXT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "MI_Id" bigint;
    "asmay_id" bigint;
BEGIN

    DROP TABLE IF EXISTS "ChairmanFeesDeletedReceipts_Temp";

    CREATE TEMP TABLE "ChairmanFeesDeletedReceipts_Temp"(
        "ITAT_TableName" TEXT,
        "ITAT_RecordPKID" bigint,
        "ITAT_Id" bigint,
        "ITAT_Date" TIMESTAMP,
        "ITAT_Time" TEXT,
        "ITAT_Operation" TEXT,
        "IATD_CurrentValue" TEXT,
        "ITAT_NetworkIp" TEXT,
        "ITAT_MAACAddress" TEXT,
        "FYP_Id" bigint,
        "AMST_Id" bigint,
        "ASMAY_Id" bigint,
        "FTP_TotalPaidAmount" bigint,
        "FTP_TotalWaivedAmount" bigint,
        "FTP_TotalConcessionAmount" bigint,
        "FTP_TotalFineAmount" bigint,
        "StudentName" TEXT,
        "AMST_AdmNo" TEXT,
        "ASMCL_ClassName" TEXT,
        "ASMC_SectionName" TEXT
    );

    FOR "MI_Id" IN 
        SELECT DISTINCT "MI_Id" 
        FROM "IVRM_User_Login_Institutionwise" 
        WHERE id IN (65940,65941,65942,66217,66218)
    LOOP

        SELECT "ASMAY_Id" INTO "asmay_id"
        FROM "Adm_School_M_Academic_Year" 
        WHERE "MI_Id" = "MI_Id" 
        AND "Is_Active" = 1 
        AND (CURRENT_DATE BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date");

        DROP TABLE IF EXISTS "ChairmanadmissionFees_temp";
        DROP TABLE IF EXISTS "ChairmanPreadmissionFees_temp";

        CREATE TEMP TABLE "ChairmanAdmissionFees_temp" AS
        SELECT "New".*,
            (COALESCE("AMS"."AMST_FirstName",'') || COALESCE("AMS"."AMST_MiddleName",'') || COALESCE("AMS"."AMST_LastName",'')) AS "StudentName",
            "AMST_AdmNo",
            "ASMCL_ClassName",
            "ASMC_SectionName"
        FROM (
            SELECT * FROM CROSSTAB(
                'SELECT "ITAT_RecordPKID", "IATD_ColumnName", "IATD_PreviousValue"::bigint
                FROM (
                    SELECT "ITAT_TableName", "ITAT_RecordPKID", "TA"."ITAT_Id", "ITAT_Date", "ITAT_Time",
                        "ITAT_Operation", "IATD_ColumnName", "IATD_PreviousValue", "IATD_CurrentValue", 
                        "ITAT_NetworkIp", "ITAT_MAACAddress"
                    FROM "IVRM_Table_AuditTrail" "TA"
                    INNER JOIN "IVRM_AuditTrail_Deatils" "AD" ON "TA"."ITAT_Id" = "AD"."ITAT_Id"
                    WHERE "TA"."ITAT_Id" IN (
                        SELECT DISTINCT "TA"."ITAT_ID"
                        FROM "IVRM_Table_AuditTrail" "TA"
                        INNER JOIN "IVRM_AuditTrail_Deatils" "AD" ON "TA"."ITAT_Id" = "AD"."ITAT_Id"
                        WHERE "AD"."IATD_PreviousValue" IN (
                            SELECT DISTINCT "ITAT_RecordPKID"::text
                            FROM "IVRM_Table_AuditTrail" "TA"
                            INNER JOIN "IVRM_AuditTrail_Deatils" "AD" ON "TA"."ITAT_Id" = "AD"."ITAT_Id"
                            WHERE "ITAT_TableName" = ''Fee_Y_Payment'' 
                            AND "ITAT_Operation" IN (''D'')
                            AND "AD"."IATD_ColumnName" = ''FYP_Date''
                        )
                        AND "AD"."IATD_ColumnName" = ''FYP_Id'' 
                        AND "ITAT_Operation" = ''D''
                    )
                    AND ("ITAT_Date"::date BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || ''')
                    AND "IATD_ColumnName" != ''FYPPA_Type''
                ) "P"
                ORDER BY 1,2',
                'SELECT UNNEST(ARRAY[''FYP_Id'',''AMST_Id'',''ASMAY_Id'',''FTP_TotalPaidAmount'',''FTP_TotalWaivedAmount'',''FTP_TotalConcessionAmount'',''FTP_TotalFineAmount''])'
            ) AS ct(
                "ITAT_RecordPKID" bigint,
                "FYP_Id" bigint,
                "AMST_Id" bigint,
                "ASMAY_Id" bigint,
                "FTP_TotalPaidAmount" bigint,
                "FTP_TotalWaivedAmount" bigint,
                "FTP_TotalConcessionAmount" bigint,
                "FTP_TotalFineAmount" bigint
            )
        ) "New"
        INNER JOIN "Adm_M_student" "AMS" ON "AMS"."AMST_Id" = "New"."AMST_Id" AND "AMS"."MI_Id" = "MI_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id" AND "ASYS"."ASMAY_Id" = "asmay_id"
        INNER JOIN "Adm_School_M_Class" "AMC" ON "AMC"."ASMCL_Id" = "ASYS"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "AMSE" ON "AMSE"."ASMS_Id" = "ASYS"."ASMS_Id"
        ORDER BY "ITAT_Date";

        CREATE TEMP TABLE "ChairmanPreadmissionFees_temp" AS
        SELECT "New".*,
            (COALESCE("PASR_FirstName",'') || COALESCE("PASR_MiddleName",'') || COALESCE("PASR_LastName",'')) AS "StudentName",
            "PASR_RegistrationNo",
            "ASMCL_ClassName"
        FROM (
            SELECT * FROM CROSSTAB(
                'SELECT "ITAT_RecordPKID", "IATD_ColumnName", "IATD_PreviousValue"::bigint
                FROM (
                    SELECT "ITAT_TableName", "ITAT_RecordPKID", "TA"."ITAT_Id", "ITAT_Date", "ITAT_Time",
                        "ITAT_Operation", "IATD_ColumnName", "IATD_PreviousValue", "IATD_CurrentValue",
                        "ITAT_NetworkIp", "ITAT_MAACAddress"
                    FROM "IVRM_Table_AuditTrail" "TA"
                    INNER JOIN "IVRM_AuditTrail_Deatils" "AD" ON "TA"."ITAT_Id" = "AD"."ITAT_Id"
                    WHERE "TA"."ITAT_Id" IN (
                        SELECT DISTINCT "TA"."ITAT_ID"
                        FROM "IVRM_Table_AuditTrail" "TA"
                        INNER JOIN "IVRM_AuditTrail_Deatils" "AD" ON "TA"."ITAT_Id" = "AD"."ITAT_Id"
                        WHERE "AD"."IATD_PreviousValue" IN (
                            SELECT DISTINCT "ITAT_RecordPKID"::text
                            FROM "IVRM_Table_AuditTrail" "TA"
                            INNER JOIN "IVRM_AuditTrail_Deatils" "AD" ON "TA"."ITAT_Id" = "AD"."ITAT_Id"
                            WHERE "ITAT_TableName" = ''Fee_Y_Payment'' 
                            AND "ITAT_Operation" IN (''D'')
                            AND "AD"."IATD_ColumnName" = ''FYP_Date''
                        )
                        AND "AD"."IATD_ColumnName" = ''FYP_Id'' 
                        AND "ITAT_Operation" = ''D''
                    )
                    AND ("ITAT_Date"::date BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || ''')
                    AND "IATD_ColumnName" != ''FYPPA_Type''
                    AND "ITAT_TableName" = ''Fee_Y_Payment_PA_Application'' 
                    AND "IATD_ColumnName" != ''FYPPA_ActiveFlag''
                ) "P"
                ORDER BY 1,2',
                'SELECT UNNEST(ARRAY[''FYP_Id'',''PASA_Id'',''ASMAY_Id'',''FYPPA_TotalPaidAmount''])'
            ) AS ct(
                "ITAT_RecordPKID" bigint,
                "FYP_Id" bigint,
                "PASA_Id" bigint,
                "ASMAY_Id" bigint,
                "FYPPA_TotalPaidAmount" bigint
            )
        ) "New"
        INNER JOIN "Preadmission_School_Registration" "PSR" ON "PSR"."PASR_Id" = "New"."PASA_Id" AND "PSR"."MI_Id" = "MI_Id"
        INNER JOIN "Adm_School_M_Class" "AMC" ON "AMC"."ASMCL_Id" = "PSR"."ASMCL_Id"
        ORDER BY "ITAT_Date";

        INSERT INTO "ChairmanFeesDeletedReceipts_Temp"
        ("ITAT_TableName", "ITAT_RecordPKID", "ITAT_Id", "ITAT_Date", "ITAT_Time", "ITAT_Operation", 
         "IATD_CurrentValue", "ITAT_NetworkIp", "ITAT_MAACAddress", "FYP_Id", "AMST_Id", "ASMAY_Id",
         "FTP_TotalPaidAmount", "FTP_TotalWaivedAmount", "FTP_TotalConcessionAmount", "FTP_TotalFineAmount", 
         "StudentName", "AMST_AdmNo", "ASMCL_ClassName", "ASMC_SectionName")
        SELECT * FROM (
            SELECT "ITAT_TableName", "ITAT_RecordPKID", "ITAT_Id", "ITAT_Date", "ITAT_Time", "ITAT_Operation", 
                   "IATD_CurrentValue", "ITAT_NetworkIp", "ITAT_MAACAddress", "FYP_Id", "AMST_Id", "ASMAY_Id",
                   "FTP_TotalPaidAmount", "FTP_TotalWaivedAmount", "FTP_TotalConcessionAmount", "FTP_TotalFineAmount", 
                   "StudentName", "AMST_AdmNo", "ASMCL_ClassName", "ASMC_SectionName"
            FROM "ChairmanAdmissionFees_temp"

            UNION ALL

            SELECT "ITAT_TableName", "ITAT_RecordPKID", "ITAT_Id", "ITAT_Date", "ITAT_Time", "ITAT_Operation", 
                   "IATD_CurrentValue", "ITAT_NetworkIp", "ITAT_MAACAddress", "FYP_Id", "PASA_Id" AS "AMST_Id", "ASMAY_Id",
                   "FYPPA_TotalPaidAmount" AS "FTP_TotalPaidAmount", 0 AS "FTP_TotalWaivedAmount", 
                   0 AS "FTP_TotalConcessionAmount", 0 AS "FTP_TotalFineAmount", "StudentName", 
                   "PASR_RegistrationNo" AS "AMST_AdmNo", "ASMCL_ClassName", '' AS "ASMC_SectionName"
            FROM "ChairmanPreadmissionFees_temp"
        ) AS "New" 
        ORDER BY "ITAT_Date" ASC;

    END LOOP;

    RETURN QUERY
    SELECT * FROM "ChairmanFeesDeletedReceipts_Temp"
    ORDER BY "ITAT_Date";

END;
$$;