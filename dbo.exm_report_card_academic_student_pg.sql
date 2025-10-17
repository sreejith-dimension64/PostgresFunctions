CREATE OR REPLACE FUNCTION "dbo"."exm_report_card_academic_student"(
    "@mi_id" bigint,
    "@ASMAY_Id" bigint,
    "@ASMCL_Id" bigint,
    "@ASMS_Id" bigint,
    "@AMST_Id" bigint,
    "@eyc_id" int
)
RETURNS TABLE(
    "EMSS_Id" bigint,
    "EMSS_SubSubjectName" varchar,
    "ISMS_Id" bigint,
    "ISMS_SubjectName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        e."EMSS_Id",
        e."EMSS_SubSubjectName",
        b."ISMS_Id",
        b."ISMS_SubjectName" 
    FROM "exm"."Exm_Studentwise_Subjects" a
    INNER JOIN "IVRM_Master_Subjects" b ON a."ISMS_Id" = b."isms_id"
    INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" c ON c."ISMS_Id" = b."ISMS_Id"
    LEFT JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise_SubSubjects" d ON d."EYCES_Id" = c."EYCES_Id"
    LEFT JOIN "exm"."Exm_Master_SubSubject" e ON e."EMSS_Id" = d."EMSS_Id"
    WHERE a."mi_id" = "@mi_id" 
        AND a."ASMCL_Id" = "@ASMCL_Id" 
        AND a."ASMAY_Id" = "@ASMAY_Id" 
        AND a."ASMS_Id" = "@ASMS_Id" 
        AND a."AMST_Id" = "@AMST_Id" 
        AND a."EYCE_Id" IN (
            SELECT DISTINCT "EYCE_Id" 
            FROM "Exm"."Exm_Yearly_Category_Exams" 
            WHERE "eyc_id" = "@eyc_id"
        )
    ORDER BY e."EMSS_SubSubjectName";
END;
$$;