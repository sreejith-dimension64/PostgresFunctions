CREATE OR REPLACE FUNCTION "dbo"."GET_RFID_STUDENT_LIST"(
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_date DATE
)
RETURNS TABLE(
    "ASMAY_Id" BIGINT,
    "IRFPU_DateTime" DATE,
    "AMST_Id" BIGINT,
    "AMST_AdmNo" VARCHAR,
    "STDNAME" TEXT,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "AMST_RFCardNo" VARCHAR,
    "OUTTIME" VARCHAR,
    "INTIME" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT DISTINCT 
    C."ASMAY_Id",
    CAST(B."IRFPU_DateTime" AS DATE) AS "IRFPU_DateTime",
    A."AMST_Id",
    A."AMST_AdmNo",
    (COALESCE(A."AMST_FirstName",' ') || ' ' || COALESCE(A."AMST_MiddleName",' ') || ' ' || COALESCE(A."AMST_LastName",' ')) AS "STDNAME",
    D."ASMCL_ClassName",
    E."ASMC_SectionName",
    A."AMST_RFCardNo",
    (SELECT SUBSTRING(CAST(T."IRFPU_DateTime"::TIME AS VARCHAR(20)), 1, 5)
     FROM "IVRM_RF_Punch" AS T
     INNER JOIN "IVRM_RF_Reader" R ON T."IRFPU_RaederIP" = R."IRFRE_RaederIP"
     WHERE T."IRFPU_RFTagId" = A."AMST_RFCardNo" 
       AND R."IRFRE_OutFlg" = 1
       AND CAST(T."IRFPU_DateTime" AS DATE) = p_date 
     ORDER BY T."IRFPU_DateTime" DESC
     LIMIT 1) AS "OUTTIME",
    (SELECT SUBSTRING(CAST(T."IRFPU_DateTime"::TIME AS VARCHAR(20)), 1, 5)
     FROM "IVRM_RF_Punch" AS T
     INNER JOIN "IVRM_RF_Reader" R ON T."IRFPU_RaederIP" = R."IRFRE_RaederIP" 
       AND R."IRFRE_INFlg" = 1
     WHERE T."IRFPU_RFTagId" = A."AMST_RFCardNo"
       AND CAST(T."IRFPU_DateTime" AS DATE) = p_date 
     ORDER BY T."IRFPU_DateTime" DESC
     LIMIT 1) AS "INTIME"
FROM "ADM_M_STUDENT" AS A
INNER JOIN "IVRM_RF_Punch" AS B ON B."IRFPU_RFTagId" = A."AMST_RFCardNo"
INNER JOIN "Adm_School_Y_Student" AS C ON C."AMST_Id" = A."AMST_Id" AND C."ASMAY_Id" = p_ASMAY_Id
INNER JOIN "Adm_School_M_Class" AS D ON D."ASMCL_Id" = C."ASMCL_Id"
INNER JOIN "Adm_School_M_Section" AS E ON E."ASMS_Id" = C."ASMS_Id"
WHERE A."MI_Id" = p_MI_Id 
  AND C."ASMAY_Id" = p_ASMAY_Id 
  AND CAST(B."IRFPU_DateTime" AS DATE) = p_date 
  AND A."AMST_SOL" = 'S' 
  AND C."AMAY_ActiveFlag" = 1;

END;
$$;