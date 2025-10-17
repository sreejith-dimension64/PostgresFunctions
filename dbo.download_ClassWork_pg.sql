CREATE OR REPLACE FUNCTION "dbo"."download_ClassWork"(
    "@MI_Id" TEXT,
    "@ISMS_Id" TEXT,
    "@AMST_Id" TEXT,
    "@ASMAY_Id" TEXT
)
RETURNS TABLE(
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "AMST_Id" BIGINT,
    "ICW_Id" BIGINT,
    "ICW_Assignment" TEXT,
    "ICW_Attachment" TEXT,
    "ICW_Topic" TEXT,
    "ICW_SubTopic" TEXT,
    "ICW_FromDate" TIMESTAMP,
    "ICW_ToDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT "a"."ASMCL_Id", "b"."ASMS_Id", "c"."AMST_Id", "e"."ICW_Id", "e"."ICW_Assignment", 
           "e"."ICW_Attachment", "e"."ICW_Topic", "e"."ICW_SubTopic", "e"."ICW_FromDate", "e"."ICW_ToDate"
    FROM "Adm_School_M_Academic_Year" AS "d"
    CROSS JOIN "Adm_School_M_Class" AS "a"
    CROSS JOIN "Adm_School_M_Section" AS "b"
    CROSS JOIN "Adm_School_Y_Student" AS "c"
    CROSS JOIN "IVRM_ClassWork" AS "e"
    CROSS JOIN "IVRM_Master_Subjects" AS "f"
    WHERE "a"."ASMCL_Id" = "c"."ASMCL_Id" 
      AND "b"."ASMS_Id" = "c"."ASMS_Id" 
      AND "d"."ASMAY_Id" = "c"."ASMAY_Id" 
      AND "e"."ISMS_Id" = "f"."ISMS_Id"
      AND "a"."MI_Id" = "@MI_Id"
      AND "b"."MI_Id" = "@MI_Id"
      AND "c"."AMST_Id" = "@AMST_Id"
      AND "d"."MI_Id" = "@MI_Id"
      AND "c"."ASMAY_Id" = "@ASMAY_Id"
      AND (CURRENT_TIMESTAMP >= "e"."ICW_FromDate") 
      AND (CURRENT_TIMESTAMP <= "e"."ICW_ToDate");
END;
$$;