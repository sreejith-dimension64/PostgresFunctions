CREATE OR REPLACE FUNCTION "dbo"."Adm_Get_Batchwise_Student_ListFor_Update"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ISMS_Id" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT,
    "ASASB_Id" TEXT,
    "AMST_Id" TEXT
)
RETURNS TABLE(
    "ASASB_Id" INTEGER,
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "ISMS_Id" BIGINT,
    "ASASB_BatchName" VARCHAR,
    "ASASB_ActiveFlg" BOOLEAN,
    "ASASB_CreatedBy" BIGINT,
    "ASASB_UpdatedBy" BIGINT,
    "ASASB_CreatedDate" TIMESTAMP,
    "ASASB_UpdatedDate" TIMESTAMP,
    "ASASBS_Id" INTEGER,
    "AMST_Id" BIGINT,
    "ASASBS_ActiveFlg" BOOLEAN,
    "ASASBS_CreatedBy" BIGINT,
    "ASASBS_UpdatedBy" BIGINT,
    "ASASBS_CreatedDate" TIMESTAMP,
    "ASASBS_UpdatedDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sql" TEXT;
BEGIN
    "sql" := 'SELECT a.*, b.* FROM "Adm_School_Attendance_Subject_Batch" a 
              INNER JOIN "Adm_School_Attendance_Subject_Batch_Students" b ON a."ASASB_Id" = b."ASASB_Id" 
              WHERE a."MI_Id" = ' || "MI_Id" || ' 
              AND a."ASMAY_Id" = ' || "ASMAY_Id" || ' 
              AND a."ASMCL_Id" = ' || "ASMCL_Id" || ' 
              AND a."ASMS_Id" = ' || "ASMS_Id" || ' 
              AND a."ASASB_Id" = ' || "ASASB_Id" || ' 
              AND b."AMST_Id" NOT IN(' || "AMST_Id" || ')';
    
    RETURN QUERY EXECUTE "sql";
    
    RETURN;
END;
$$;