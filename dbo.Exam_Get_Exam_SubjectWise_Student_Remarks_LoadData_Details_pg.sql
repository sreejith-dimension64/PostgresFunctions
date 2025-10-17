CREATE OR REPLACE FUNCTION "dbo"."Exam_Get_Exam_SubjectWise_Student_Remarks_LoadData_Details"(
    "@MI_Id" TEXT, 
    "@ASMAY_Id" TEXT, 
    "@UserId" TEXT
)
RETURNS TABLE(
    "asmaY_Id" BIGINT,
    "asmcL_Id" BIGINT,
    "asmS_Id" BIGINT,
    "emE_Id" BIGINT,
    "ismS_Id" BIGINT,
    "asmaY_Year" VARCHAR,
    "asmcL_ClassName" VARCHAR,
    "asmC_SectionName" VARCHAR,
    "emE_ExamName" VARCHAR,
    "ismS_SubjectName" VARCHAR,
    "ASMAY_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@RowCount" BIGINT;
BEGIN
    
    SELECT COUNT(*) INTO "@RowCount" 
    FROM "IVRM_Staff_User_Login" 
    WHERE "id" = "@UserId";
    
    IF ("@RowCount" > 0) THEN
        
        RETURN QUERY
        SELECT DISTINCT 
            "PS"."ASMAY_Id" AS "asmaY_Id",
            "PS"."ASMCL_Id" AS "asmcL_Id",
            "PS"."ASMS_Id" AS "asmS_Id",
            "PS"."EME_Id" AS "emE_Id",
            "PS"."ISMS_Id" AS "ismS_Id",
            "f"."ASMAY_Year" AS "asmaY_Year",
            "d"."ASMCL_ClassName" AS "asmcL_ClassName",
            "e"."ASMC_SectionName" AS "asmC_SectionName",
            "EX"."EME_ExamName" AS "emE_ExamName",
            "c"."ISMS_SubjectName" AS "ismS_SubjectName",
            "f"."ASMAY_Order"
        FROM "Exm"."Exm_Login_Privilege" "a"
        INNER JOIN "Exm"."Exm_Login_Privilege_Subjects" "b" 
            ON "a"."ELP_Id" = "b"."ELP_Id" 
            AND "b"."ELPS_ActiveFlg" = 1 
            AND "a"."ELP_ActiveFlg" = 1
        INNER JOIN "IVRM_Master_Subjects" "c" ON "c"."ISMS_Id" = "b"."ISMS_Id"
        INNER JOIN "Adm_School_M_Class" "d" ON "d"."ASMCL_Id" = "b"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "e" ON "e"."ASMS_Id" = "b"."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "f" ON "f"."ASMAY_Id" = "a"."ASMAY_Id"
        INNER JOIN "IVRM_Staff_User_Login" "g" ON "g"."IVRMSTAUL_Id" = "a"."Login_Id"
        INNER JOIN "Exm"."Exm_Student_SubjEx_PC_Remarks" "PS" 
            ON "PS"."ASMCL_Id" = "b"."ASMCL_Id" 
            AND "PS"."ASMS_Id" = "b"."ASMS_Id"
            AND "PS"."ISMS_Id" = "b"."ISMS_Id" 
            AND "PS"."ASMAY_Id" = "a"."ASMAY_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" "EX" ON "EX"."EME_Id" = "PS"."EME_Id"
        WHERE "a"."MI_Id" = "@MI_Id" 
            AND "g"."Id" = "@UserId" 
            AND "PS"."MI_Id" = "@MI_Id"
        ORDER BY "ASMAY_Order" DESC;
        
    ELSE
        
        RETURN QUERY
        SELECT DISTINCT 
            "a"."ASMAY_Id" AS "asmaY_Id",
            "a"."ASMCL_Id" AS "asmcL_Id",
            "a"."ASMS_Id" AS "asmS_Id",
            "a"."EME_Id" AS "emE_Id",
            "a"."ISMS_Id" AS "ismS_Id",
            "b"."ASMAY_Year" AS "asmaY_Year",
            "c"."ASMCL_ClassName" AS "asmcL_ClassName",
            "d"."ASMC_SectionName" AS "asmC_SectionName",
            "e"."EME_ExamName" AS "emE_ExamName",
            "f"."ISMS_SubjectName" AS "ismS_SubjectName",
            "b"."ASMAY_Order"
        FROM "Exm"."Exm_Student_SubjEx_PC_Remarks" "a"
        INNER JOIN "Adm_School_M_Academic_Year" "b" ON "a"."ASMAY_Id" = "b"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "c" ON "a"."ASMCL_Id" = "c"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "d" ON "d"."ASMS_Id" = "a"."ASMS_Id"
        INNER JOIN "Exm"."Exm_Master_Exam" "e" ON "e"."EME_Id" = "a"."EME_Id"
        INNER JOIN "IVRM_Master_Subjects" "f" ON "f"."ISMS_Id" = "a"."ISMS_Id"
        ORDER BY "b"."ASMAY_Order" DESC;
        
    END IF;
    
END;
$$;