CREATE OR REPLACE FUNCTION "dbo"."FEE_OPENINGBALANCE_NAME_SEARCH"(
    "@Mi_Id" bigint,
    "@searchtext" text,
    "@ASMAY_ID" bigint,
    "@USERID" bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "AMST_FirstName" character varying,
    "AMST_MiddleName" character varying,
    "AMST_LastName" character varying,
    "AMST_AdmNo" character varying,
    "AMST_RegistrationNo" character varying,
    "AMAY_RollNo" character varying,
    "ASMCL_ClassName" character varying,
    "ASMC_SectionName" character varying,
    "AMST_MobileNo" character varying,
    "ASMCL_Order" integer,
    "FMOB_Id" bigint,
    "asmay_id" bigint,
    "FMOB_EntryDate" timestamp,
    "FMOB_Student_Due" numeric,
    "FMOB_Institution_Due" numeric
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        A."AMST_Id",
        A."AMST_FirstName",
        A."AMST_MiddleName",
        A."AMST_LastName",
        A."AMST_AdmNo",
        A."AMST_RegistrationNo",
        D."AMAY_RollNo",
        C."ASMCL_ClassName",
        G."ASMC_SectionName",
        A."AMST_MobileNo",
        C."ASMCL_Order",
        B."FMOB_Id",
        B."asmay_id",
        B."FMOB_EntryDate",
        B."FMOB_Student_Due",
        B."FMOB_Institution_Due"
    FROM "Adm_M_Student" AS A
    INNER JOIN "Fee_Master_Opening_Balance" AS B ON B."AMST_Id" = A."AMST_Id" AND A."MI_Id" = B."MI_Id"
    INNER JOIN "Adm_School_Y_Student" AS D ON D."AMST_Id" = A."AMST_Id"
    INNER JOIN "Adm_School_M_Class" AS C ON C."ASMCL_Id" = D."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" AS G ON G."ASMS_Id" = D."ASMS_Id"
    WHERE A."MI_Id" = "@Mi_Id" 
        AND D."ASMAY_ID" = "@ASMAY_ID" 
        AND C."MI_Id" = "@Mi_Id" 
        AND G."MI_Id" = "@Mi_Id" 
        AND D."AMAY_ActiveFlag" = 1 
        AND A."AMST_ActiveFlag" = 1 
        AND A."AMST_SOL" = 'S' 
        AND B."User_Id" = "@USERID" 
        AND B."ASMAY_Id" = "@ASMAY_ID"
        AND (A."AMST_FirstName" LIKE '%' || "@searchtext" || '%' 
            OR A."AMST_MiddleName" LIKE '%' || "@searchtext" || '%' 
            OR A."AMST_LastName" LIKE '%' || "@searchtext" || '%')
    ORDER BY C."ASMCL_Order";
END;
$$;