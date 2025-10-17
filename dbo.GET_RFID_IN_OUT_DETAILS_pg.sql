CREATE OR REPLACE FUNCTION "dbo"."GET_RFID_IN_OUT_DETAILS"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_date DATE,
    p_CARDNO TEXT,
    p_TYPE VARCHAR(20)
)
RETURNS TABLE(
    "IRFPU_AntennaID" TEXT,
    "IRFRE_RearderName" TEXT,
    "IRFRE_ReaderLacation" TEXT,
    "IRFPU_DateTime" TIMESTAMP,
    "AMST_Id" BIGINT,
    "AMST_AdmNo" TEXT,
    "STDNAME" TEXT,
    "AMST_RFCardNo" TEXT,
    "TIME_VALUE" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    
    IF p_TYPE = 'IN' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "B"."IRFPU_AntennaID",
            "C"."IRFRE_RearderName",
            "C"."IRFRE_ReaderLacation",
            "B"."IRFPU_DateTime",
            "A"."AMST_Id",
            "A"."AMST_AdmNo",
            (COALESCE("A"."AMST_FirstName", ' ') || ' ' || COALESCE("A"."AMST_MiddleName", ' ') || ' ' || COALESCE("A"."AMST_LastName", ' ')) AS "STDNAME",
            "A"."AMST_RFCardNo",
            SUBSTRING(CAST("B"."IRFPU_DateTime"::TIME AS VARCHAR(20)), 1, 5) AS "TIME_VALUE"
        FROM "ADM_M_STUDENT" AS "A"
        INNER JOIN "IVRM_RF_Punch" AS "B" ON "B"."IRFPU_RFTagId" = "A"."AMST_RFCardNo"
        INNER JOIN "IVRM_RF_Reader" AS "C" ON "C"."IRFRE_RaederIP" = "B"."IRFPU_RaederIP"
        WHERE "A"."MI_Id" = p_MI_Id 
            AND CAST("B"."IRFPU_DateTime" AS DATE) = p_date 
            AND "B"."IRFPU_RFTagId" = p_CARDNO 
            AND "C"."IRFRE_ActiveFlg" = 1 
            AND "C"."IRFRE_INFlg" = 1;
    ELSIF p_TYPE = 'OUT' THEN
        RETURN QUERY
        SELECT DISTINCT 
            "B"."IRFPU_AntennaID",
            "C"."IRFRE_RearderName",
            "C"."IRFRE_ReaderLacation",
            "B"."IRFPU_DateTime",
            "A"."AMST_Id",
            "A"."AMST_AdmNo",
            (COALESCE("A"."AMST_FirstName", ' ') || ' ' || COALESCE("A"."AMST_MiddleName", ' ') || ' ' || COALESCE("A"."AMST_LastName", ' ')) AS "STDNAME",
            "A"."AMST_RFCardNo",
            SUBSTRING(CAST("B"."IRFPU_DateTime"::TIME AS VARCHAR(20)), 1, 5) AS "TIME_VALUE"
        FROM "ADM_M_STUDENT" AS "A"
        INNER JOIN "IVRM_RF_Punch" AS "B" ON "B"."IRFPU_RFTagId" = "A"."AMST_RFCardNo"
        INNER JOIN "IVRM_RF_Reader" AS "C" ON "C"."IRFRE_RaederIP" = "B"."IRFPU_RaederIP"
        WHERE "A"."MI_Id" = p_MI_Id 
            AND CAST("B"."IRFPU_DateTime" AS DATE) = p_date 
            AND "B"."IRFPU_RFTagId" = p_CARDNO 
            AND "C"."IRFRE_ActiveFlg" = 1 
            AND "C"."IRFRE_OutFlg" = 1;
    END IF;
    
    RETURN;
END;
$$;