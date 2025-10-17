CREATE OR REPLACE FUNCTION "dbo"."College_Student_DocumentsPre"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "AMCO_Id" TEXT,
    "FLAG" TEXT,
    "PACA_Id" TEXT
)
RETURNS TABLE(
    "PACA_RegistrationNo" VARCHAR,
    "paca_id" BIGINT,
    "PACSTD_Id" BIGINT,
    "docpath" TEXT,
    "docname" VARCHAR,
    "AMSMD_Id" BIGINT,
    "PACA_StudentPhoto" TEXT,
    "PACA_FirstName" VARCHAR,
    "PACA_MiddleName" VARCHAR,
    "PACA_LastName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "FLAG" = 'Appsts' THEN
    
        RETURN QUERY
        SELECT c."PACA_RegistrationNo",
               c."paca_id",
               a."PACSTD_Id",
               a."ACSTD_Doc_Path" AS docpath,
               b."AMSMD_DocumentName" AS docname,
               a."AMSMD_Id",
               c."PACA_StudentPhoto",
               c."PACA_FirstName",
               c."PACA_MiddleName",
               c."PACA_LastName" 
        FROM "clg"."PA_College_Student_Documents" a
        INNER JOIN "Adm_m_School_Master_Documents" b ON a."AMSMD_Id" = b."AMSMD_Id"
        INNER JOIN "clg"."PA_College_Application" c ON a."PACA_Id" = c."PACA_Id"
        WHERE c."MI_Id" = "College_Student_DocumentsPre"."MI_Id" 
          AND c."AMCO_Id" = "College_Student_DocumentsPre"."AMCO_Id" 
          AND c."paca_id" = "College_Student_DocumentsPre"."PACA_Id"
          AND c."ASMAY_Id" = "College_Student_DocumentsPre"."ASMAY_Id";
    
    ELSIF "FLAG" = 'admsts' THEN
    
        RETURN QUERY
        SELECT c."PACA_RegistrationNo",
               c."paca_id",
               a."PACSTD_Id",
               a."ACSTD_Doc_Path" AS docpath,
               b."AMSMD_DocumentName" AS docname,
               a."AMSMD_Id",
               c."PACA_StudentPhoto",
               c."PACA_FirstName",
               c."PACA_MiddleName",
               c."PACA_LastName" 
        FROM "clg"."PA_College_Student_Documents" a
        INNER JOIN "Adm_m_School_Master_Documents" b ON a."AMSMD_Id" = b."AMSMD_Id"
        INNER JOIN "clg"."PA_College_Application" c ON a."PACA_Id" = c."PACA_Id"
        WHERE c."MI_Id" = "College_Student_DocumentsPre"."MI_Id" 
          AND c."AMCO_Id" = "College_Student_DocumentsPre"."AMCO_Id" 
          AND c."ASMAY_Id" = "College_Student_DocumentsPre"."ASMAY_Id" 
          AND c."PACA_Id" = "College_Student_DocumentsPre"."PACA_Id";
    
    END IF;

    RETURN;

END;
$$;