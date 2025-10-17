CREATE OR REPLACE FUNCTION "dbo"."Fee_TermWiseCollectedAmount_Details"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FromDate VARCHAR(10),
    p_ToDate VARCHAR(10)
)
RETURNS TABLE(
    "FMT_Id" INTEGER,
    "FMT_Name" TEXT,
    "TodayPaidCount" BIGINT,
    "TodayCollection" NUMERIC,
    "TillNowPaidCount" BIGINT,
    "TillNowTotalCollection" NUMERIC,
    "TotalStrength" BIGINT,
    "Defaulters" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sqlDynamic TEXT;
BEGIN

IF (p_FromDate <> '' AND p_ToDate <> '') THEN

    RETURN QUERY
    WITH "MasterTerms" AS (
        SELECT "FMT_Id", "FMT_Name" 
        FROM "Fee_Master_Terms" 
        WHERE "MI_Id" = p_MI_Id::BIGINT
    ),
    "TodayPaidCount" AS (
        SELECT "FMT"."FMT_Id", "FMT"."FMT_Name", COUNT(DISTINCT "FYPSS"."AMST_Id") AS "TodayPaidCount"
        FROM "Fee_Y_Payment" "FYP"
        INNER JOIN "Fee_Y_Payment_School_Student" "FYPSS" ON "FYP"."ASMAY_ID" = "FYPSS"."ASMAY_Id" AND "FYP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "ASYS"."AMST_Id" = "FYPSS"."AMST_Id"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."MI_Id" = p_MI_Id::BIGINT
        INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "FMA"."FMA_Id" = "FTP"."FMA_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" "FMTF" ON "FMTF"."FTI_Id" = "FMA"."FTI_Id" AND "FMTF"."FMH_Id" = "FMA"."FMH_Id" AND "FMTF"."MI_Id" = p_MI_Id::BIGINT
        INNER JOIN "Fee_Master_Terms" "FMT" ON "FMT"."FMT_Id" = "FMTF"."FMT_Id"
        WHERE "FYP"."MI_Id" = p_MI_Id::BIGINT 
            AND "FYP"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "FYP"."FYP_Date"::DATE = CURRENT_DATE 
            AND "ASYS"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "ASYS"."AMAY_ActiveFlag" = 1 
            AND "AMS"."AMST_SOL" = 'S' 
            AND "AMS"."AMST_ActiveFlag" = 1
        GROUP BY "FMT"."FMT_Id", "FMT"."FMT_Name"
    ),
    "TodayCollection" AS (
        SELECT "FMT"."FMT_Id", "FMT"."FMT_Name", SUM("FTP"."FTP_Paid_Amt") AS "TodayCollection"
        FROM "Fee_Y_Payment" "FYP"
        INNER JOIN "Fee_Y_Payment_School_Student" "FYPSS" ON "FYP"."ASMAY_ID" = "FYPSS"."ASMAY_Id" AND "FYP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "ASYS"."AMST_Id" = "FYPSS"."AMST_Id"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."MI_Id" = p_MI_Id::BIGINT
        INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "FMA"."FMA_Id" = "FTP"."FMA_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" "FMTF" ON "FMTF"."FTI_Id" = "FMA"."FTI_Id" AND "FMTF"."FMH_Id" = "FMA"."FMH_Id" AND "FMTF"."MI_Id" = p_MI_Id::BIGINT
        INNER JOIN "Fee_Master_Terms" "FMT" ON "FMT"."FMT_Id" = "FMTF"."FMT_Id"
        WHERE "FYP"."MI_Id" = p_MI_Id::BIGINT 
            AND "FYP"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "FYP"."FYP_Date"::DATE = CURRENT_DATE
        GROUP BY "FMT"."FMT_Id", "FMT"."FMT_Name"
    ),
    "TillNowPaidCount" AS (
        SELECT "FMT"."FMT_Id", "FMT"."FMT_Name", COUNT(DISTINCT "FYPSS"."AMST_Id") AS "TillNowPaidCount"
        FROM "Fee_Y_Payment" "FYP"
        INNER JOIN "Fee_Y_Payment_School_Student" "FYPSS" ON "FYP"."ASMAY_ID" = "FYPSS"."ASMAY_Id" AND "FYP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "ASYS"."AMST_Id" = "FYPSS"."AMST_Id"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."MI_Id" = p_MI_Id::BIGINT
        INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "FMA"."FMA_Id" = "FTP"."FMA_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" "FMTF" ON "FMTF"."FTI_Id" = "FMA"."FTI_Id" AND "FMTF"."FMH_Id" = "FMA"."FMH_Id" AND "FMTF"."MI_Id" = p_MI_Id::BIGINT
        INNER JOIN "Fee_Master_Terms" "FMT" ON "FMT"."FMT_Id" = "FMTF"."FMT_Id"
        WHERE "FYP"."MI_Id" = p_MI_Id::BIGINT 
            AND "FYP"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "FYP"."FYP_Date"::DATE <= CURRENT_DATE 
            AND "ASYS"."AMAY_ActiveFlag" = 1 
            AND "AMS"."AMST_SOL" = 'S' 
            AND "AMS"."AMST_ActiveFlag" = 1
            AND "FYP"."FYP_Date"::DATE BETWEEN p_FromDate::DATE AND p_ToDate::DATE
        GROUP BY "FMT"."FMT_Id", "FMT"."FMT_Name"
    ),
    "TillNowTotalCollection" AS (
        SELECT "FMT"."FMT_Id", "FMT"."FMT_Name", SUM("FTP"."FTP_Paid_Amt") AS "TillNowTotalCollection"
        FROM "Fee_Y_Payment" "FYP"
        INNER JOIN "Fee_Y_Payment_School_Student" "FYPSS" ON "FYP"."ASMAY_ID" = "FYPSS"."ASMAY_Id" AND "FYP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "ASYS"."AMST_Id" = "FYPSS"."AMST_Id"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."MI_Id" = p_MI_Id::BIGINT
        INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "FMA"."FMA_Id" = "FTP"."FMA_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" "FMTF" ON "FMTF"."FTI_Id" = "FMA"."FTI_Id" AND "FMTF"."FMH_Id" = "FMA"."FMH_Id" AND "FMTF"."MI_Id" = p_MI_Id::BIGINT
        INNER JOIN "Fee_Master_Terms" "FMT" ON "FMT"."FMT_Id" = "FMTF"."FMT_Id"
        WHERE "FYP"."MI_Id" = p_MI_Id::BIGINT 
            AND "FYP"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "FYP"."FYP_Date"::DATE <= CURRENT_DATE
            AND "FYP"."FYP_Date"::DATE BETWEEN p_FromDate::DATE AND p_ToDate::DATE
        GROUP BY "FMT"."FMT_Id", "FMT"."FMT_Name"
    ),
    "TotalStrength" AS (
        SELECT "Fee_Master_Terms"."FMT_Id", "Fee_Master_Terms"."FMT_Name", COUNT(DISTINCT "Fee_Student_Status"."AMST_Id") AS "TotalStrength"
        FROM "Fee_Master_Group"
        INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
        INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id" = p_MI_Id::BIGINT
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
        INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
        INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
        WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "Fee_Student_Status"."MI_Id" = p_MI_Id::BIGINT 
            AND "Fee_Student_Status"."ASMAY_Id" = p_ASMAY_Id::BIGINT
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1 
            AND "Adm_M_Student"."AMST_SOL" = 'S' 
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
        GROUP BY "Fee_Master_Terms"."FMT_Id", "Fee_Master_Terms"."FMT_Name"
    ),
    "Defaulters" AS (
        SELECT "Fee_Master_Terms"."FMT_Id", "Fee_Master_Terms"."FMT_Name", COUNT(DISTINCT "Fee_Student_Status"."AMST_Id") AS "Defaulters"
        FROM "Fee_Master_Group"
        INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
        INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
        INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id" = p_MI_Id::BIGINT
        INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" ON "Adm_School_M_Class"."ASMCL_Id" = "Adm_School_Y_Student"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" ON "Adm_School_M_Section"."ASMS_Id" = "Adm_School_Y_Student"."ASMS_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
        INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id"
        INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
        WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "Fee_Student_Status"."MI_Id" = p_MI_Id::BIGINT 
            AND "Fee_Student_Status"."ASMAY_Id" = p_ASMAY_Id::BIGINT
            AND "Fee_Master_Terms"."FMT_Id" IN (
                SELECT DISTINCT "FMT_Id" 
                FROM "Fee_Master_Terms_FeeHeads" 
                WHERE "FMTFH_Id" IN (
                    SELECT DISTINCT "FMTFH_Id" 
                    FROM "Fee_Master_Terms_FeeHeads_DueDate" 
                    WHERE "MI_Id" = p_MI_Id::BIGINT 
                        AND "FMTFHDD_DueDate"::DATE < CURRENT_DATE 
                        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT
                ) 
                AND "MI_Id" = p_MI_Id::BIGINT
            )
            AND "Fee_Student_Status"."FSS_ToBePaid" > 0 
            AND "Adm_School_Y_Student"."AMAY_ActiveFlag" = 1 
            AND "Adm_M_Student"."AMST_SOL" = 'S' 
            AND "Adm_M_Student"."AMST_ActiveFlag" = 1
        GROUP BY "Fee_Master_Terms"."FMT_Id", "Fee_Master_Terms"."FMT_Name"
    )
    SELECT "MT"."FMT_Id", "MT"."FMT_Name", "TPC"."TodayPaidCount", "TC"."TodayCollection", "TNPC"."TillNowPaidCount", 
           "TNTC"."TillNowTotalCollection", "TS"."TotalStrength", "DS"."Defaulters"
    FROM "MasterTerms" "MT"
    LEFT JOIN "TodayPaidCount" "TPC" ON "MT"."FMT_Id" = "TPC"."FMT_Id"
    LEFT JOIN "TodayCollection" "TC" ON "MT"."FMT_Id" = "TC"."FMT_Id"
    LEFT JOIN "TillNowPaidCount" "TNPC" ON "MT"."FMT_Id" = "TNPC"."FMT_Id"
    LEFT JOIN "TillNowTotalCollection" "TNTC" ON "MT"."FMT_Id" = "TNTC"."FMT_Id"
    LEFT JOIN "TotalStrength" "TS" ON "MT"."FMT_Id" = "TS"."FMT_Id"
    LEFT JOIN "Defaulters" "DS" ON "MT"."FMT_Id" = "DS"."FMT_Id";

ELSIF (p_ASMCL_Id <> '0' AND p_ASMS_Id <> '0') THEN

    v_sqlDynamic := '
    WITH "MasterTerms" AS (
        SELECT "FMT_Id", "FMT_Name" 
        FROM "Fee_Master_Terms" 
        WHERE "MI_Id" = ' || p_MI_Id || '
    ),
    "TodayPaidCount" AS (
        SELECT "FMT"."FMT_Id", "FMT"."FMT_Name", COUNT(DISTINCT "FYPSS"."AMST_Id") AS "TodayPaidCount"
        FROM "Fee_Y_Payment" "FYP"
        INNER JOIN "Fee_Y_Payment_School_Student" "FYPSS" ON "FYP"."ASMAY_ID" = "FYPSS"."ASMAY_Id" AND "FYP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "ASYS"."AMST_Id" = "FYPSS"."AMST_Id"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "FMA"."FMA_Id" = "FTP"."FMA_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" "FMTF" ON "FMTF"."FTI_Id" = "FMA"."FTI_Id" AND "FMTF"."FMH_Id" = "FMA"."FMH_Id" AND "FMTF"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "Fee_Master_Terms" "FMT" ON "FMT"."FMT_Id" = "FMTF"."FMT_Id"
        WHERE "FYP"."MI_Id" = ' || p_MI_Id || ' 
            AND "FYP"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
            AND "FYP"."FYP_Date"::DATE = CURRENT_DATE 
            AND "ASYS"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
            AND "ASYS"."ASMCL_Id" IN (' || p_ASMCL_Id || ') 
            AND "ASYS"."ASMS_Id" IN (' || p_ASMS_Id || ') 
            AND "ASYS"."AMAY_ActiveFlag" = 1 
            AND "AMS"."AMST_SOL" = ''S'' 
            AND "AMS"."AMST_ActiveFlag" = 1
        GROUP BY "FMT"."FMT_Id", "FMT"."FMT_Name"
    ),
    "TodayCollection" AS (
        SELECT "FMT"."FMT_Id", "FMT"."FMT_Name", SUM("FTP"."FTP_Paid_Amt") AS "TodayCollection"
        FROM "Fee_Y_Payment" "FYP"
        INNER JOIN "Fee_Y_Payment_School_Student" "FYPSS" ON "FYP"."ASMAY_ID" = "FYPSS"."ASMAY_Id" AND "FYP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "ASYS"."AMST_Id" = "FYPSS"."AMST_Id"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "FMA"."FMA_Id" = "FTP"."FMA_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" "FMTF" ON "FMTF"."FTI_Id" = "FMA"."FTI_Id" AND "FMTF"."FMH_Id" = "FMA"."FMH_Id" AND "FMTF"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "Fee_Master_Terms" "FMT" ON "FMT"."FMT_Id" = "FMTF"."FMT_Id"
        WHERE "FYP"."MI_Id" = ' || p_MI_Id || ' 
            AND "FYP"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
            AND "FYP"."FYP_Date"::DATE = CURRENT_DATE 
            AND "ASYS"."ASMCL_Id" IN (' || p_ASMCL_Id || ') 
            AND "ASYS"."ASMS_Id" IN (' || p_ASMS_Id || ')
        GROUP BY "FMT"."FMT_Id", "FMT"."FMT_Name"
    ),
    "TillNowPaidCount" AS (
        SELECT "FMT"."FMT_Id", "FMT"."FMT_Name", COUNT(DISTINCT "FYPSS"."AMST_Id") AS "TillNowPaidCount"
        FROM "Fee_Y_Payment" "FYP"
        INNER JOIN "Fee_Y_Payment_School_Student" "FYPSS" ON "FYP"."ASMAY_ID" = "FYPSS"."ASMAY_Id" AND "FYP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "ASYS"."AMST_Id" = "FYPSS"."AMST_Id"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "FMA"."FMA_Id" = "FTP"."FMA_Id"
        INNER JOIN "Fee_Master_Terms_FeeHeads" "FMTF" ON "FMTF"."FTI_Id" = "FMA"."FTI_Id" AND "FMTF"."FMH_Id" = "FMA"."FMH_Id" AND "FMTF"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "Fee_Master_Terms" "FMT" ON "FMT"."FMT_Id" = "FMTF"."FMT_Id"
        WHERE "FYP"."MI_Id" = ' || p_MI_Id || ' 
            AND "FYP"."ASMAY_Id" = ' || p_ASMAY_Id || ' 
            AND "FYP"."FYP_Date"::DATE <= CURRENT_DATE 
            AND "ASYS"."ASMCL_Id" IN (' || p_ASMCL_Id || ') 
            AND "ASYS"."ASMS_Id" IN (' || p_ASMS_Id || ') 
            AND "ASYS"."AMAY_ActiveFlag" = 1 
            AND "AMS"."AMST_SOL" = ''S'' 
            AND "AMS"."AMST_ActiveFlag" = 1
        GROUP BY "FMT"."FMT_Id", "FMT"."FMT_Name"
    ),
    "TillNowTotalCollection" AS (
        SELECT "FMT"."FMT_Id", "FMT"."FMT_Name", SUM("FTP"."FTP_Paid_Amt") AS "TillNowTotalCollection"
        FROM "Fee_Y_Payment" "FYP"
        INNER JOIN "Fee_Y_Payment_School_Student" "FYPSS" ON "FYP"."ASMAY_ID" = "FYPSS"."ASMAY_Id" AND "FYP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "FYPSS"."ASMAY_Id" AND "ASYS"."AMST_Id" = "FYPSS"."AMST_Id"
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id" AND "AMS"."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "Fee_T_Payment" "FTP" ON "FTP"."FYP_Id" = "FYPSS"."FYP_Id"
        INNER JOIN "Fee_Master_Amount" "FMA" ON "FMA"."ASMAY