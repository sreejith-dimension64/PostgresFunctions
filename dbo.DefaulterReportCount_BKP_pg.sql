CREATE OR REPLACE FUNCTION "dbo"."DefaulterReportCount_BKP"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_FMT_Id TEXT
)
RETURNS TABLE(
    "FMT_Id" BIGINT,
    "FMT_Name" TEXT,
    "ASMCL_ID" BIGINT,
    "ASMCL_ClassName" TEXT,
    "TodayPaidCount" BIGINT,
    "TodayCollection" BIGINT,
    "TillNowPaidCount" BIGINT,
    "TillNowTotalCollection" BIGINT,
    "TotalStrength" BIGINT,
    "Defaulters" BIGINT,
    "Defaulterscnt" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASMCL_ID BIGINT;
BEGIN
    DROP TABLE IF EXISTS temp_fee_countdetails;
    
    CREATE TEMP TABLE temp_fee_countdetails(
        "FMT_Id" BIGINT,
        "FMT_Name" TEXT,
        "ASMCL_ID" BIGINT,
        "ASMCL_ClassName" TEXT,
        "TodayPaidCount" BIGINT,
        "TodayCollection" BIGINT,
        "TillNowPaidCount" BIGINT,
        "TillNowTotalCollection" BIGINT,
        "TotalStrength" BIGINT,
        "Defaulters" BIGINT,
        "Defaulterscnt" BIGINT
    );
    
    FOR v_ASMCL_ID IN 
        SELECT DISTINCT "ASMCL_ID" 
        FROM "Adm_School_M_Class" 
        WHERE "MI_Id" = p_MI_Id::BIGINT
    LOOP
        INSERT INTO temp_fee_countdetails ("FMT_Id", "FMT_Name", "ASMCL_ID", "ASMCL_ClassName", "TodayPaidCount", "TodayCollection", "TillNowPaidCount", "TillNowTotalCollection", "TotalStrength", "Defaulters", "Defaulterscnt")
        WITH "MasterTerms" AS (
            SELECT "FMT_Id", "FMT_Name" 
            FROM "Fee_Master_Terms" 
            WHERE "MI_Id" = p_MI_Id::BIGINT 
            AND "FMT_Id" = p_FMT_Id::BIGINT
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
            AND "ASYS"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND CAST("FYP_Date" AS DATE) = CURRENT_DATE 
            AND ("ASYS"."AMAY_ActiveFlag" = 1) 
            AND ("AMS"."AMST_SOL" = 'S') 
            AND ("AMS"."AMST_ActiveFlag" = 1) 
            AND "FMT"."FMT_Id" = p_FMT_Id::BIGINT 
            AND "ASYS"."ASMCL_ID" = v_ASMCL_ID
            GROUP BY "FMT"."FMT_Id", "FMT"."FMT_Name"
        ),
        "TodayCollection" AS (
            SELECT "FMT"."FMT_Id", "FMT"."FMT_Name", SUM("FTP_Paid_Amt") AS "TodayCollection"
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
            AND CAST("FYP_Date" AS DATE) = CURRENT_DATE 
            AND "FMT"."FMT_Id" = p_FMT_Id::BIGINT 
            AND "ASYS"."ASMCL_ID" = v_ASMCL_ID
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
            AND ("ASYS"."AMAY_ActiveFlag" = 1) 
            AND ("AMS"."AMST_SOL" = 'S') 
            AND ("AMS"."AMST_ActiveFlag" = 1) 
            AND "FMT"."FMT_Id" = p_FMT_Id::BIGINT 
            AND "ASYS"."ASMCL_ID" = v_ASMCL_ID
            GROUP BY "FMT"."FMT_Id", "FMT"."FMT_Name"
        ),
        "TillNowTotalCollection" AS (
            SELECT "FMT"."FMT_Id", "FMT"."FMT_Name", SUM("FTP_Paid_Amt") AS "TillNowTotalCollection"
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
            AND "FMT"."FMT_Id" = p_FMT_Id::BIGINT 
            AND "ASYS"."ASMCL_ID" = v_ASMCL_ID
            GROUP BY "FMT"."FMT_Id", "FMT"."FMT_Name"
        ),
        "TotalStrength" AS (
            SELECT "Fee_Master_Terms"."FMT_Id", "Fee_Master_Terms"."FMT_Name", COUNT(DISTINCT "Fee_Student_Status"."AMST_Id") AS "TotalStrength"
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id" = p_MI_Id::BIGINT
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id"
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            WHERE ("Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_Id::BIGINT) 
            AND ("Fee_Student_Status"."MI_Id" = p_MI_Id::BIGINT) 
            AND "Fee_Student_Status"."ASMAY_Id" = p_ASMAY_Id::BIGINT
            AND ("Adm_School_Y_Student"."AMAY_ActiveFlag" = 1) 
            AND ("Adm_M_Student"."AMST_SOL" = 'S') 
            AND ("Adm_M_Student"."AMST_ActiveFlag" = 1) 
            AND "Fee_Master_Terms"."FMT_Id" = p_FMT_Id::BIGINT 
            AND "Adm_School_Y_Student"."ASMCL_ID" = v_ASMCL_ID
            GROUP BY "Fee_Master_Terms"."FMT_Id", "Fee_Master_Terms"."FMT_Name"
        ),
        "Defaulters" AS (
            SELECT "Fee_Master_Terms"."FMT_Id", "Fee_Master_Terms"."FMT_Name", COUNT(DISTINCT "Fee_Student_Status"."AMST_Id") AS "Defaulters"
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
            INNER JOIN "Fee_Y_Payment_School_Student" "FYPSS" ON "Fee_Student_Status"."AMST_Id" = "FYPSS"."AMST_Id"
            INNER JOIN "Fee_Y_Payment" "FYP" ON "FYP"."FYP_ID" = "FYPSS"."FYP_Id"
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id" = p_MI_Id::BIGINT
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "Fee_Student_Status"."MI_Id" = p_MI_Id::BIGINT 
            AND "Fee_Student_Status"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "Fee_Master_Terms"."FMT_Id" = p_FMT_Id::BIGINT
            AND ("Fee_Master_Terms"."FMT_Id" IN (
                SELECT DISTINCT "FMT_Id" 
                FROM "Fee_Master_Terms_FeeHeads" 
                WHERE "FMTFH_Id" IN (
                    SELECT DISTINCT "FMTFH_Id" 
                    FROM "Fee_Master_Terms_FeeHeads_DueDate" 
                    WHERE "MI_Id" = p_MI_Id::BIGINT 
                    AND CAST("FMTFHDD_DueDate" AS DATE) < CAST("FYP"."FYP_Date" AS DATE)
                    AND "ASMAY_Id" = p_ASMAY_Id::BIGINT
                ) 
                AND "MI_Id" = p_MI_Id::BIGINT
            ))
            AND ("Fee_Student_Status"."FSS_ToBePaid" > 0) 
            AND ("Adm_School_Y_Student"."AMAY_ActiveFlag" = 1) 
            AND ("Adm_M_Student"."AMST_SOL" = 'S') 
            AND ("Adm_M_Student"."AMST_ActiveFlag" = 1) 
            AND "Adm_School_Y_Student"."ASMCL_ID" = v_ASMCL_ID
            GROUP BY "Fee_Master_Terms"."FMT_Id", "Fee_Master_Terms"."FMT_Name"
        ),
        "Defaulterscnt" AS (
            SELECT "Fee_Master_Terms"."FMT_Id", "Fee_Master_Terms"."FMT_Name", COUNT(DISTINCT "Fee_Student_Status"."AMST_Id") AS "Defaulterscnt"
            FROM "Fee_Master_Group"
            INNER JOIN "Fee_Student_Status" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id"
            INNER JOIN "Fee_Y_Payment_School_Student" "FYPSS" ON "Fee_Student_Status"."AMST_Id" = "FYPSS"."AMST_Id"
            INNER JOIN "Fee_Y_Payment" "FYP" ON "FYP"."FYP_ID" = "FYPSS"."FYP_Id"
            INNER JOIN "Fee_Master_Head" ON "Fee_Student_Status"."FMH_Id" = "Fee_Master_Head"."FMH_Id"
            INNER JOIN "Adm_M_Student" ON "Adm_M_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_M_Student"."MI_Id" = p_MI_Id::BIGINT
            INNER JOIN "Adm_School_Y_Student" ON "Adm_School_Y_Student"."AMST_Id" = "Adm_M_Student"."AMST_Id" AND "Adm_School_Y_Student"."AMST_Id" = "Fee_Student_Status"."AMST_Id" AND "Adm_School_Y_Student"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            INNER JOIN "Fee_Master_Terms_FeeHeads" ON "Fee_Master_Terms_FeeHeads"."FMH_Id" = "Fee_Student_Status"."FMH_Id" AND "Fee_Student_Status"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id"
            INNER JOIN "Fee_Master_Terms" ON "Fee_Master_Terms"."FMT_Id" = "Fee_Master_Terms_FeeHeads"."FMT_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."ASMAY_Id" = "Adm_School_Y_Student"."ASMAY_Id" AND "Adm_School_M_Academic_Year"."ASMAY_Id" = "Fee_Student_Status"."ASMAY_Id"
            WHERE "Adm_School_Y_Student"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "Fee_Student_Status"."MI_Id" = p_MI_Id::BIGINT 
            AND "Fee_Student_Status"."ASMAY_Id" = p_ASMAY_Id::BIGINT 
            AND "Fee_Master_Terms"."FMT_Id" = p_FMT_Id::BIGINT 
            AND "Adm_School_Y_Student"."ASMCL_ID" = v_ASMCL_ID
            AND ("Fee_Master_Terms"."FMT_Id" IN (
                SELECT DISTINCT "FMT_Id" 
                FROM "Fee_Master_Terms_FeeHeads" 
                WHERE "FMTFH_Id" IN (
                    SELECT DISTINCT "FMTFH_Id" 
                    FROM "Fee_Master_Terms_FeeHeads_DueDate" 
                    WHERE "MI_Id" = p_MI_Id::BIGINT 
                    AND CAST("FMTFHDD_DueDate" AS DATE) > CAST("FYP"."FYP_Date" AS DATE)
                    AND "ASMAY_Id" = p_ASMAY_Id::BIGINT
                ) 
                AND "MI_Id" = p_MI_Id::BIGINT
            ))
            AND ("Fee_Student_Status"."FSS_ToBePaid" > 0) 
            AND ("Adm_School_Y_Student"."AMAY_ActiveFlag" = 1) 
            AND ("Adm_M_Student"."AMST_SOL" = 'S') 
            AND ("Adm_M_Student"."AMST_ActiveFlag" = 1)
            GROUP BY "Fee_Master_Terms"."FMT_Id", "Fee_Master_Terms"."FMT_Name"
        )
        SELECT 
            "MT"."FMT_Id",
            "MT"."FMT_Name",
            "asmcl"."ASMCL_ID",
            "asmcl"."ASMCL_ClassName",
            COALESCE("TPC"."TodayPaidCount", 0),
            COALESCE("TC"."TodayCollection", 0),
            COALESCE("TNPC"."TillNowPaidCount", 0),
            COALESCE("TNTC"."TillNowTotalCollection", 0),
            COALESCE("TS"."TotalStrength", 0),
            COALESCE("DS"."Defaulters", 0),
            COALESCE("dd"."Defaulterscnt", 0)
        FROM "MasterTerms" "MT"
        LEFT JOIN "TodayPaidCount" "TPC" ON "MT"."FMT_Id" = "TPC"."FMT_Id"
        LEFT JOIN "TodayCollection" "TC" ON "MT"."FMT_Id" = "TC"."FMT_Id"
        LEFT JOIN "TillNowPaidCount" "TNPC" ON "MT"."FMT_Id" = "TNPC"."FMT_Id"
        LEFT JOIN "TillNowTotalCollection" "TNTC" ON "MT"."FMT_Id" = "TNTC"."FMT_Id"
        LEFT JOIN "TotalStrength" "TS" ON "MT"."FMT_Id" = "TS"."FMT_Id"
        LEFT JOIN "Defaulters" "DS" ON "MT"."FMT_Id" = "DS"."FMT_Id"
        LEFT JOIN "Adm_School_M_Class" "asmcl" ON "asmcl"."ASMCL_ID" = v_ASMCL_ID
        LEFT JOIN "Defaulterscnt" "dd" ON "MT"."FMT_Id" = "dd"."FMT_Id"
        WHERE "asmcl"."ASMCL_ID" = v_ASMCL_ID;
    END LOOP;
    
    RETURN QUERY 
    SELECT * FROM temp_fee_countdetails;
    
    DROP TABLE IF EXISTS temp_fee_countdetails;
END;
$$;