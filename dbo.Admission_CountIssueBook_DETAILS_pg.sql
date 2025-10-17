CREATE OR REPLACE FUNCTION "dbo"."Admission_CountIssueBook_DETAILS"(
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "AMST_Id" BIGINT
)
RETURNS TABLE(
    "LMBANO_AccessionNo" VARCHAR,
    "AMST_Name" TEXT,
    "AMST_AdmNo" VARCHAR,
    "AMAY_RollNo" VARCHAR,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "LMB_BookTitle" VARCHAR,
    "LMB_ISBNNo" VARCHAR,
    "LMB_BookType" VARCHAR,
    "LBTR_IssuedDate" TIMESTAMP,
    "LBTR_DueDate" TIMESTAMP,
    "LBTR_Status" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        "LMA"."LMBANO_AccessionNo",
        COALESCE("AMS"."AMST_FirstName", '') || ' ' || COALESCE("AMS"."AMST_MiddleName", '') || ' ' || COALESCE("AMS"."AMST_LastName", '') AS "AMST_Name",
        "AMS"."AMST_AdmNo",
        "ASYS"."AMAY_RollNo",
        "ASMC"."ASMCL_ClassName",
        "ASMS"."ASMC_SectionName",
        "c"."LMB_BookTitle",
        "c"."LMB_ISBNNo",
        "c"."LMB_BookType",
        "a"."LBTR_IssuedDate",
        "a"."LBTR_DueDate",
        "a"."LBTR_Status"
    FROM "LIB"."LIB_Book_Transaction" "a"
    INNER JOIN "LIB"."LIB_Book_Transaction_Student" "b" ON "a"."LBTR_Id" = "b"."LBTR_Id" AND "a"."LBTR_ActiveFlg" = 1
    INNER JOIN "LIB"."LIB_Master_Book_AccnNo" "LMA" ON "LMA"."LMBANO_Id" = "a"."LMBANO_Id"
    INNER JOIN "LIB"."LIB_Master_Book" "c" ON "c"."LMB_Id" = "LMA"."LMB_Id" AND "c"."MI_Id" = "MI_Id"
    INNER JOIN "LIB"."LIB_Master_Book_Library" "LBL" ON "c"."LMB_Id" = "LBL"."LMB_Id" AND "LMBL_ActiveFlg" = 1
    LEFT JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "b"."AMST_Id" AND "AMS"."MI_Id" = "MI_Id" AND "AMST_SOL" = 'S' AND "AMS"."AMST_ActiveFlag" = 1
    LEFT JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id" = "AMS"."AMST_Id" AND "ASYS"."AMAY_ActiveFlag" = 1
    LEFT JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id" = "ASYS"."ASMCL_Id" AND "ASMC"."MI_Id" = "MI_Id"
    LEFT JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id" = "ASYS"."ASMS_Id" AND "ASMS"."MI_Id" = "MI_Id"
    WHERE "AMS"."AMST_Id" = "AMST_Id" 
        AND "a"."MI_Id" = "MI_Id" 
        AND "a"."LBTR_Status" = 'Issue' 
        AND "ASYS"."ASMAY_Id" = "ASMAY_Id";
END;
$$;