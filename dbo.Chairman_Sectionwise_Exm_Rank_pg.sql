CREATE OR REPLACE FUNCTION "dbo"."Chairman_Sectionwise_Exm_Rank"(
    p_MI_Id integer,
    p_ASMAY_Id integer,
    p_EME_Id integer,
    p_ASMCL_Id integer,
    p_ASMS_Id integer
)
RETURNS TABLE(
    "MI_Id" integer,
    "ASMAY_Id" integer,
    "ASMCL_Id" integer,
    "ASMS_Id" integer,
    "AMST_Id" integer,
    "EME_Id" integer,
    "ESTMP_TotalMaxMarks" numeric,
    "ESTMP_TotalObtMarks" numeric,
    "ESTMP_Percentage" numeric,
    "ASMCL_ClassName" character varying,
    "ASMC_SectionName" character varying,
    "name" text,
    "AMST_AdmNo" character varying,
    "Section_Rnk" integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        A."MI_Id",
        A."ASMAY_Id",
        A."ASMCL_Id",
        A."ASMS_Id",
        A."AMST_Id",
        A."EME_Id",
        A."ESTMP_TotalMaxMarks",
        A."ESTMP_TotalObtMarks",
        A."ESTMP_Percentage",
        C."ASMCL_ClassName",
        S."ASMC_SectionName",
        (REPLACE(REPLACE(REPLACE(COALESCE(B."AMST_FirstName",''),'.',''),'$',''),'0','')||' '||REPLACE(REPLACE(REPLACE(COALESCE(B."AMST_MiddleName",''),'.',''),'$',''),'0','')||' '||REPLACE(REPLACE(REPLACE(COALESCE(B."AMST_LastName",''),'.',''),'$',''),'0',''))::text AS name,
        B."AMST_AdmNo",
        A."ESTMP_SectionRank" AS "Section_Rnk"
    FROM "EXM"."Exm_Student_Marks_Process" AS A
    INNER JOIN "Adm_M_Student" AS B ON A."AMST_Id" = B."AMST_Id"
    INNER JOIN "Adm_School_M_Class" AS C ON A."ASMCL_Id" = C."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" AS S ON A."ASMS_Id" = S."ASMS_Id"
    WHERE A."ESTMP_SectionRank" <= 3 
        AND A."MI_Id" = p_MI_Id 
        AND A."ASMAY_Id" = p_ASMAY_Id 
        AND A."ASMCL_Id" = p_ASMCL_Id 
        AND A."EME_Id" = p_EME_Id 
        AND A."ASMS_Id" = p_ASMS_Id 
        AND A."ESTMP_SectionRank" <> 0 
        AND A."ESTMP_SectionRank" IS NOT NULL 
    ORDER BY A."ESTMP_SectionRank";
    
    RETURN;
END;
$$;