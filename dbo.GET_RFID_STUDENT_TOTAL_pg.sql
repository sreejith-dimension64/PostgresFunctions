CREATE OR REPLACE FUNCTION "dbo"."GET_RFID_STUDENT_TOTAL"(
  "@MI_Id" bigint, 
  "@ASMAY_Id" bigint,
  "@DATE" date,
  "@TYPE" varchar(20) 
)
RETURNS TABLE (
  "STDCOUNT" bigint,
  "PCOUNT" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF "@TYPE" = 'STDCNT' THEN
        RETURN QUERY
        SELECT COUNT(A."AMST_Id") AS "STDCOUNT", NULL::bigint AS "PCOUNT"
        FROM "Adm_M_Student" AS A 
        INNER JOIN "Adm_School_Y_Student" AS B ON B."AMST_Id" = A."AMST_Id"
        WHERE A."AMST_ActiveFlag" = 1 
          AND A."AMST_SOL" = 'S' 
          AND B."AMAY_ActiveFlag" = 1 
          AND A."MI_Id" = "@MI_Id" 
          AND B."ASMAY_Id" = "@ASMAY_Id";
    ELSIF "@TYPE" = 'PCNT' THEN
        RETURN QUERY
        SELECT NULL::bigint AS "STDCOUNT", COUNT(DISTINCT A."AMST_Id") AS "PCOUNT"
        FROM "ADM_M_STUDENT" AS A
        INNER JOIN "IVRM_RF_Punch" AS B ON B."IRFPU_RFTagId" = A."AMST_RFCardNo"
        INNER JOIN "IVRM_RF_Reader" AS C ON C."IRFRE_RaederIP" = B."IRFPU_RaederIP"
        WHERE A."MI_Id" = "@MI_Id" 
          AND CAST(B."IRFPU_DateTime" AS date) = "@DATE" 
          AND C."IRFRE_ActiveFlg" = 1;
    END IF;
END;
$$;