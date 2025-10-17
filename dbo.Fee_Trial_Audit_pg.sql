CREATE OR REPLACE FUNCTION "dbo"."Fee_Trial_Audit"(
    "FYP_Receipt_No" TEXT,
    "Mi_Id" BIGINT,
    "type" TEXT,
    "amst_id" BIGINT,
    "fromdate" TIMESTAMP,
    "todate" TIMESTAMP,
    "statustype" TEXT,
    "Userid" BIGINT
)
RETURNS TABLE(
    "ITAT_TableName" TEXT,
    "StudentName" TEXT,
    "AMST_AdmNo" TEXT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "ITAT_NetworkIp" TEXT,
    "ITAT_MAACAddress" TEXT,
    "ITAT_Date" TIMESTAMP,
    "ITAT_Time" TEXT,
    "ITAT_Operation" TEXT,
    "IATD_ColumnName" TEXT,
    "IATD_PreviousValue" TEXT,
    "IATD_CurrentValue" TEXT,
    "ITAT_RecordPKID" BIGINT,
    "ITAT_Id" BIGINT,
    "FYP_Id" BIGINT,
    "AMST_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "FTP_TotalPaidAmount" BIGINT,
    "FTP_TotalWaivedAmount" BIGINT,
    "FTP_TotalConcessionAmount" BIGINT,
    "FTP_TotalFineAmount" BIGINT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "asmay_id" BIGINT;
BEGIN

    SELECT "ASMAY_Id" INTO "asmay_id"
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "Mi_Id" 
    AND "Is_Active" = 1 
    AND CURRENT_DATE BETWEEN "ASMAY_From_Date" AND "ASMAY_To_Date";

    IF "type" = 'receipt' AND "statustype" = 'IU' THEN
        RETURN QUERY
        SELECT DISTINCT 
            TA."ITAT_TableName",
            AMS."AMST_FirstName" || ' ' || AMS."AMST_MiddleName" || ' ' || AMS."AMST_LastName" AS "StudentName",
            AMS."AMST_AdmNo",
            AMC."ASMCL_ClassName",
            AMSE."ASMC_SectionName",
            TA."ITAT_NetworkIp",
            TA."ITAT_MAACAddress",
            TA."ITAT_Date",
            TA."ITAT_Time",
            TA."ITAT_Operation",
            AD."IATD_ColumnName",
            AD."IATD_PreviousValue",
            AD."IATD_CurrentValue",
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT
        FROM "IVRM_Table_AuditTrail" TA 
        INNER JOIN "IVRM_AuditTrail_Deatils" AD ON TA."ITAT_Id" = AD."ITAT_Id" 
        INNER JOIN "Fee_Y_Payment_School_Student" FYSS ON FYSS."FYP_Id" = TA."ITAT_RecordPKID"
        INNER JOIN "Adm_M_student" AMS ON AMS."AMST_Id" = FYSS."AMST_Id" AND AMS."MI_Id" = "Mi_Id"
        INNER JOIN "Adm_School_Y_Student" ASYS ON ASYS."AMST_Id" = AMS."AMST_Id" AND ASYS."ASMAY_Id" = "asmay_id"
        INNER JOIN "Adm_School_M_Class" AMC ON AMC."ASMCL_Id" = ASYS."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" AMSE ON AMSE."ASMS_Id" = ASYS."ASMS_Id"
        WHERE TA."ITAT_Id" IN (
            SELECT DISTINCT TA."ITAT_Id" 
            FROM "IVRM_Table_AuditTrail" TA 
            INNER JOIN "IVRM_AuditTrail_Deatils" AD ON TA."ITAT_Id" = AD."ITAT_Id" 
            WHERE TA."ITAT_TableName" LIKE 'Fee_Y_Payment%' 
            AND TA."ITAT_Operation" IN ('U','I')
            AND (AD."IATD_PreviousValue" = "FYP_Receipt_No" OR AD."IATD_CurrentValue" = "FYP_Receipt_No") 
            AND AD."IATD_ColumnName" = 'FYP_Receipt_No'
        );
        RETURN;
    END IF;

    IF "type" = 'studentttt' AND "statustype" = 'IU' THEN
        RETURN QUERY
        SELECT DISTINCT 
            TA."ITAT_TableName",
            AMS."AMST_FirstName" || ' ' || AMS."AMST_MiddleName" || ' ' || AMS."AMST_LastName" AS "StudentName",
            AMS."AMST_AdmNo",
            AMC."ASMCL_ClassName",
            AMSE."ASMC_SectionName",
            TA."ITAT_NetworkIp",
            TA."ITAT_MAACAddress",
            TA."ITAT_Date",
            TA."ITAT_Time",
            TA."ITAT_Operation",
            AD."IATD_ColumnName",
            AD."IATD_PreviousValue",
            AD."IATD_CurrentValue",
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT
        FROM "IVRM_Table_AuditTrail" TA  
        INNER JOIN "IVRM_AuditTrail_Deatils" AD ON TA."ITAT_Id" = AD."ITAT_Id"
        INNER JOIN "Fee_Y_Payment_School_Student" FYSS ON FYSS."FYPS_Id" = TA."ITAT_RecordPKID"
        INNER JOIN "Adm_M_student" AMS ON AMS."AMST_Id" = FYSS."AMST_Id" AND AMS."MI_Id" = "Mi_Id"
        INNER JOIN "Adm_School_Y_Student" ASYS ON ASYS."AMST_Id" = AMS."AMST_Id" AND ASYS."ASMAY_Id" = "asmay_id"
        INNER JOIN "Adm_School_M_Class" AMC ON AMC."ASMCL_Id" = ASYS."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" AMSE ON AMSE."ASMS_Id" = ASYS."ASMS_Id"
        WHERE TA."ITAT_Id" IN (
            SELECT DISTINCT TA."ITAT_Id" 
            FROM "IVRM_Table_AuditTrail" TA  
            INNER JOIN "IVRM_AuditTrail_Deatils" AD ON TA."ITAT_Id" = AD."ITAT_Id" 
            WHERE TA."ITAT_TableName" LIKE 'Fee_Y_Payment_School_Student%' 
            AND TA."ITAT_Operation" IN ('U','I') 
            AND (AD."IATD_PreviousValue" = "amst_id"::TEXT OR AD."IATD_CurrentValue" = "amst_id"::TEXT) 
            AND AD."IATD_ColumnName" = 'AMST_Id'
        );
        RETURN;
    END IF;

    IF "type" = 'date' AND "statustype" = 'IU' THEN
        RETURN QUERY
        SELECT DISTINCT 
            TA."ITAT_TableName",
            AMS."AMST_FirstName" || ' ' || AMS."AMST_MiddleName" || ' ' || AMS."AMST_LastName" AS "StudentName",
            AMS."AMST_AdmNo",
            AMC."ASMCL_ClassName",
            AMSE."ASMC_SectionName",
            TA."ITAT_NetworkIp",
            TA."ITAT_MAACAddress",
            TA."ITAT_Date",
            TA."ITAT_Time",
            TA."ITAT_Operation",
            AD."IATD_ColumnName",
            AD."IATD_PreviousValue",
            AD."IATD_CurrentValue",
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::BIGINT
        FROM "IVRM_Table_AuditTrail" TA  
        INNER JOIN "IVRM_AuditTrail_Deatils" AD ON TA."ITAT_Id" = AD."ITAT_Id" 
        INNER JOIN "Fee_Y_Payment_School_Student" FYSS ON FYSS."FYP_Id" = TA."ITAT_RecordPKID"
        INNER JOIN "Adm_M_student" AMS ON AMS."AMST_Id" = FYSS."AMST_Id" AND AMS."MI_Id" = "Mi_Id"
        INNER JOIN "Adm_School_Y_Student" ASYS ON ASYS."AMST_Id" = AMS."AMST_Id" AND ASYS."ASMAY_Id" = "asmay_id"
        INNER JOIN "Adm_School_M_Class" AMC ON AMC."ASMCL_Id" = ASYS."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" AMSE ON AMSE."ASMS_Id" = ASYS."ASMS_Id"
        WHERE TA."ITAT_Id" IN (
            SELECT DISTINCT TA."ITAT_Id" 
            FROM "IVRM_Table_AuditTrail" TA  
            INNER JOIN "IVRM_AuditTrail_Deatils" AD ON TA."ITAT_Id" = AD."ITAT_Id" 
            WHERE TA."ITAT_TableName" LIKE 'Fee_Y_Payment%' 
            AND TA."ITAT_Operation" IN ('U','I')
            AND ((CAST(AD."IATD_PreviousValue" AS DATE) BETWEEN "fromdate"::DATE AND "todate"::DATE) 
                 OR (CAST(AD."IATD_CurrentValue" AS DATE) BETWEEN "fromdate"::DATE AND "todate"::DATE)) 
            AND AD."IATD_ColumnName" = 'FYP_Date'
        );
        RETURN;
    END IF;

    IF "type" = 'receipt' AND "statustype" = 'D' THEN
        RETURN QUERY
        SELECT 
            "New"."ITAT_TableName",
            AMS."AMST_FirstName" || ' ' || AMS."AMST_MiddleName" || ' ' || AMS."AMST_LastName" AS "StudentName",
            AMS."AMST_AdmNo",
            AMC."ASMCL_ClassName",
            AMSE."ASMC_SectionName",
            "New"."ITAT_NetworkIp",
            "New"."ITAT_MAACAddress",
            "New"."ITAT_Date",
            "New"."ITAT_Time",
            "New"."ITAT_Operation",
            NULL::TEXT,
            NULL::TEXT,
            NULL::TEXT,
            "New"."ITAT_RecordPKID",
            "New"."ITAT_Id",
            "New"."FYP_Id",
            "New"."AMST_Id",
            "New"."ASMAY_Id",
            "New"."FTP_TotalPaidAmount",
            "New"."FTP_TotalWaivedAmount",
            "New"."FTP_TotalConcessionAmount",
            "New"."FTP_TotalFineAmount"
        FROM (
            SELECT 
                "ITAT_TableName",
                "ITAT_RecordPKID",
                "ITAT_Id",
                "ITAT_Date",
                "ITAT_Time",
                "ITAT_Operation",
                "ITAT_NetworkIp",
                "ITAT_MAACAddress",
                MAX(CASE WHEN "IATD_ColumnName" = 'FYP_Id' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FYP_Id",
                MAX(CASE WHEN "IATD_ColumnName" = 'AMST_Id' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "AMST_Id",
                MAX(CASE WHEN "IATD_ColumnName" = 'ASMAY_Id' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "ASMAY_Id",
                MAX(CASE WHEN "IATD_ColumnName" = 'FTP_TotalPaidAmount' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FTP_TotalPaidAmount",
                MAX(CASE WHEN "IATD_ColumnName" = 'FTP_TotalWaivedAmount' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FTP_TotalWaivedAmount",
                MAX(CASE WHEN "IATD_ColumnName" = 'FTP_TotalConcessionAmount' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FTP_TotalConcessionAmount",
                MAX(CASE WHEN "IATD_ColumnName" = 'FTP_TotalFineAmount' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FTP_TotalFineAmount"
            FROM (
                SELECT 
                    TA."ITAT_TableName",
                    TA."ITAT_RecordPKID",
                    TA."ITAT_Id",
                    TA."ITAT_Date",
                    TA."ITAT_Time",
                    TA."ITAT_Operation",
                    AD."IATD_ColumnName",
                    AD."IATD_PreviousValue",
                    AD."IATD_CurrentValue",
                    TA."ITAT_NetworkIp",
                    TA."ITAT_MAACAddress"
                FROM "IVRM_Table_AuditTrail" TA  
                INNER JOIN "IVRM_AuditTrail_Deatils" AD ON TA."ITAT_Id" = AD."ITAT_Id" 
                WHERE TA."ITAT_Id" IN (
                    SELECT DISTINCT TA."ITAT_Id" 
                    FROM "IVRM_Table_AuditTrail" TA  
                    INNER JOIN "IVRM_AuditTrail_Deatils" AD ON TA."ITAT_Id" = AD."ITAT_Id" 
                    WHERE AD."IATD_PreviousValue" IN (
                        SELECT DISTINCT TA."ITAT_RecordPKID"::TEXT 
                        FROM "IVRM_Table_AuditTrail" TA  
                        INNER JOIN "IVRM_AuditTrail_Deatils" AD ON TA."ITAT_Id" = AD."ITAT_Id" 
                        WHERE TA."ITAT_TableName" LIKE 'Fee_Y_Payment%' 
                        AND TA."ITAT_Operation" IN ('D')
                        AND AD."IATD_PreviousValue" = "FYP_Receipt_No" 
                        AND AD."IATD_ColumnName" = 'FYP_Receipt_No'
                    ) 
                    AND AD."IATD_ColumnName" = 'FYP_Id' 
                    AND TA."ITAT_Operation" = 'D'
                )
            ) P
            GROUP BY "ITAT_TableName", "ITAT_RecordPKID", "ITAT_Id", "ITAT_Date", "ITAT_Time", "ITAT_Operation", "ITAT_NetworkIp", "ITAT_MAACAddress"
        ) "New" 
        INNER JOIN "Adm_M_student" AMS ON AMS."AMST_Id" = "New"."AMST_Id" AND AMS."MI_Id" = "Mi_Id"
        INNER JOIN "Adm_School_Y_Student" ASYS ON ASYS."AMST_Id" = AMS."AMST_Id" AND ASYS."ASMAY_Id" = "asmay_id"
        INNER JOIN "Adm_School_M_Class" AMC ON AMC."ASMCL_Id" = ASYS."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" AMSE ON AMSE."ASMS_Id" = ASYS."ASMS_Id";
        RETURN;
    END IF;

    IF "type" = 'studentttt' AND "statustype" = 'D' THEN
        RETURN QUERY
        SELECT 
            "New"."ITAT_TableName",
            AMS."AMST_FirstName" || ' ' || AMS."AMST_MiddleName" || ' ' || AMS."AMST_LastName" AS "StudentName",
            AMS."AMST_AdmNo",
            AMC."ASMCL_ClassName",
            AMSE."ASMC_SectionName",
            "New"."ITAT_NetworkIp",
            "New"."ITAT_MAACAddress",
            "New"."ITAT_Date",
            "New"."ITAT_Time",
            "New"."ITAT_Operation",
            NULL::TEXT,
            NULL::TEXT,
            NULL::TEXT,
            NULL::BIGINT,
            NULL::BIGINT,
            "New"."FYP_Id",
            "New"."AMST_Id",
            "New"."ASMAY_Id",
            "New"."FTP_TotalPaidAmount",
            "New"."FTP_TotalWaivedAmount",
            "New"."FTP_TotalConcessionAmount",
            "New"."FTP_TotalFineAmount"
        FROM (
            SELECT 
                "ITAT_TableName",
                "ITAT_Date",
                "ITAT_Time",
                "ITAT_Operation",
                "ITAT_NetworkIp",
                "ITAT_MAACAddress",
                MAX(CASE WHEN "IATD_ColumnName" = 'FYP_Id' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FYP_Id",
                MAX(CASE WHEN "IATD_ColumnName" = 'AMST_Id' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "AMST_Id",
                MAX(CASE WHEN "IATD_ColumnName" = 'ASMAY_Id' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "ASMAY_Id",
                MAX(CASE WHEN "IATD_ColumnName" = 'FTP_TotalPaidAmount' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FTP_TotalPaidAmount",
                MAX(CASE WHEN "IATD_ColumnName" = 'FTP_TotalWaivedAmount' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FTP_TotalWaivedAmount",
                MAX(CASE WHEN "IATD_ColumnName" = 'FTP_TotalConcessionAmount' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FTP_TotalConcessionAmount",
                MAX(CASE WHEN "IATD_ColumnName" = 'FTP_TotalFineAmount' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FTP_TotalFineAmount"
            FROM (
                SELECT 
                    TA."ITAT_TableName",
                    TA."ITAT_Date",
                    TA."ITAT_Time",
                    TA."ITAT_Operation",
                    AD."IATD_ColumnName",
                    AD."IATD_PreviousValue",
                    AD."IATD_CurrentValue",
                    TA."ITAT_NetworkIp",
                    TA."ITAT_MAACAddress"
                FROM "IVRM_Table_AuditTrail" TA  
                INNER JOIN "IVRM_AuditTrail_Deatils" AD ON TA."ITAT_Id" = AD."ITAT_Id"
                WHERE TA."ITAT_Id" IN (
                    SELECT DISTINCT TA."ITAT_Id" 
                    FROM "IVRM_Table_AuditTrail" TA   
                    INNER JOIN "IVRM_AuditTrail_Deatils" AD ON TA."ITAT_Id" = AD."ITAT_Id" 
                    WHERE TA."ITAT_TableName" LIKE 'Fee_Y_Payment_School_Student%' 
                    AND TA."ITAT_Operation" IN ('D') 
                    AND AD."IATD_PreviousValue" = "amst_id"::TEXT 
                    AND AD."IATD_ColumnName" = 'AMST_Id'
                )
            ) P
            GROUP BY "ITAT_TableName", "ITAT_Date", "ITAT_Time", "ITAT_Operation", "ITAT_NetworkIp", "ITAT_MAACAddress"
        ) "New" 
        INNER JOIN "Adm_M_student" AMS ON AMS."AMST_Id" = "New"."AMST_Id" AND AMS."MI_Id" = "Mi_Id"
        INNER JOIN "Adm_School_Y_Student" ASYS ON ASYS."AMST_Id" = AMS."AMST_Id" AND ASYS."ASMAY_Id" = "asmay_id"
        INNER JOIN "Adm_School_M_Class" AMC ON AMC."ASMCL_Id" = ASYS."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" AMSE ON AMSE."ASMS_Id" = ASYS."ASMS_Id";
        RETURN;
    END IF;

    IF "type" = 'date' AND "statustype" = 'D' AND "Userid" = 0 THEN
        RETURN QUERY
        SELECT 
            "New"."ITAT_TableName",
            AMS."AMST_FirstName" || AMS."AMST_MiddleName" || AMS."AMST_LastName" AS "StudentName",
            AMS."AMST_AdmNo",
            AMC."ASMCL_ClassName",
            AMSE."ASMC_SectionName",
            "New"."ITAT_NetworkIp",
            "New"."ITAT_MAACAddress",
            "New"."ITAT_Date",
            "New"."ITAT_Time",
            "New"."ITAT_Operation",
            NULL::TEXT,
            NULL::TEXT,
            NULL::TEXT,
            "New"."ITAT_RecordPKID",
            "New"."ITAT_Id",
            "New"."FYP_Id",
            "New"."AMST_Id",
            "New"."ASMAY_Id",
            "New"."FTP_TotalPaidAmount",
            "New"."FTP_TotalWaivedAmount",
            "New"."FTP_TotalConcessionAmount",
            "New"."FTP_TotalFineAmount"
        FROM (
            SELECT 
                "ITAT_TableName",
                "ITAT_RecordPKID",
                "ITAT_Id",
                "ITAT_Date",
                "ITAT_Time",
                "ITAT_Operation",
                "ITAT_NetworkIp",
                "ITAT_MAACAddress",
                MAX(CASE WHEN "IATD_ColumnName" = 'FYP_Id' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FYP_Id",
                MAX(CASE WHEN "IATD_ColumnName" = 'AMST_Id' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "AMST_Id",
                MAX(CASE WHEN "IATD_ColumnName" = 'ASMAY_Id' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "ASMAY_Id",
                MAX(CASE WHEN "IATD_ColumnName" = 'FTP_TotalPaidAmount' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FTP_TotalPaidAmount",
                MAX(CASE WHEN "IATD_ColumnName" = 'FTP_TotalWaivedAmount' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FTP_TotalWaivedAmount",
                MAX(CASE WHEN "IATD_ColumnName" = 'FTP_TotalConcessionAmount' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FTP_TotalConcessionAmount",
                MAX(CASE WHEN "IATD_ColumnName" = 'FTP_TotalFineAmount' THEN "IATD_PreviousValue"::BIGINT ELSE NULL END) AS "FTP_TotalFineAmount"
            FROM (
                SELECT 
                    TA."ITAT_TableName",
                    TA."ITAT_RecordPKID",
                    TA."ITAT_Id",
                    TA."ITAT_Date",
                    TA."ITAT_Time",
                    TA."ITAT_Operation",
                    AD."IATD_ColumnName",
                    AD."IATD_PreviousValue",
                    AD."IATD_CurrentValue",
                    TA."ITAT_NetworkIp",
                    TA."ITAT_MAACAddress"
                FROM "IVRM_Table_AuditTrail" TA  
                INNER JOIN "IVRM_AuditTrail_Deatils" AD ON TA."ITAT_Id" = AD."ITAT_Id" 
                WHERE TA."ITAT_Id" IN (
                    SELECT DISTINCT TA."ITAT_Id" 
                    FROM "IVRM_Table_AuditTrail" TA  
                    INNER JOIN "IVRM_AuditTrail_Deatils" AD ON TA."ITAT_Id" = AD."ITAT_Id" 
                    WHERE AD."IATD_PreviousValue" IN (
                        SELECT DISTINCT TA."ITAT_RecordPKID"::TEXT 
                        FROM "IVRM_Table_AuditTrail" TA  
                        INNER JOIN "IVRM_AuditTrail_Deatils" AD ON TA."ITAT_Id" = AD."ITAT_Id" 
                        WHERE TA."ITAT_TableName" LIKE 'Fee_Y_Payment%' 
                        AND TA."ITAT_Operation" IN ('D')
                        AND (CAST(AD."IATD_PreviousValue" AS DATE) BETWEEN "fromdate"::DATE AND "todate"::DATE) 
                        AND AD."IATD_ColumnName" = 'FYP_Date'
                    ) 
                    AND AD."IATD_ColumnName" = 'FYP_Id' 
                    AND TA."ITAT_Operation" = 'D'
                )
            ) P
            GROUP BY "ITAT_TableName", "ITAT_RecordPKID", "ITAT_Id", "ITAT_Date", "ITAT_Time", "ITAT_Operation", "ITAT_NetworkIp", "ITAT_MAACAddress"
        ) "New" 
        INNER JOIN "Adm_M_student" AMS ON AMS."AMST_Id" = "New"."AMST_Id" AND AMS."MI_Id" = "Mi_Id"
        INNER JOIN "Adm_School_Y_Student" ASYS ON ASYS."AMST_Id" = AMS."AMST_Id" AND ASYS."ASMAY_Id" = "asmay_id"
        INNER JOIN "Adm_School_M_Class" AMC ON AMC."ASMCL_Id" = ASYS."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" AMSE ON AMSE."ASMS_Id" = ASYS."ASMS_Id"
        ORDER BY "New"."ITAT_Date";
        RETURN;
    END IF;

    IF "Userid" > 0 AND "statustype" = 'D' AND "type" = 'date' THEN
        RETURN QUERY
        SELECT 
            "New"."ITAT_TableName",
            AMS."AMST_FirstName" || AMS."AMST_MiddleName" || AMS."AMST_LastName" AS "StudentName",
            AMS."AMST_AdmNo",
            AMC."ASMCL_ClassName",
            AMSE."ASMC_SectionName",
            "New"."ITAT_NetworkIp",
            "New"."ITAT_MAACAddress",
            "New"."ITAT_Date",
            "New"."ITAT_Time",
            "New"."ITAT_Operation",
            NULL::TEXT,
            NULL::TEXT,
            NULL::TEXT,
            