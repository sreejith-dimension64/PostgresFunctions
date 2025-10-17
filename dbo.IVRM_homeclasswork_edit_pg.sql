CREATE OR REPLACE FUNCTION "dbo"."IVRM_homeclasswork_edit"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "IHW_Id" bigint,
    "AMST_Id" bigint,
    "Parameter" varchar(50)
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "studentname" text,
    "IHW_Id" bigint,
    "IHW_Topic" text,
    "IHW_Assignment" text,
    "IHW_Date" timestamp,
    "IHW_Marks" numeric,
    "ICW_Id" bigint,
    "ICW_Topic" text,
    "ICW_Assignment" text,
    "ICW_FromDate" timestamp,
    "ICW_ToDate" timestamp,
    "ICW_Marks" numeric
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "Parameter" = 'Homework' THEN
        RETURN QUERY
        SELECT DISTINCT 
            d."AMST_Id", 
            (COALESCE(d."AMST_FirstName", '') || COALESCE(d."AMST_MiddleName", '') || COALESCE(d."AMST_LastName", '')) as studentname, 
            a."IHW_Id", 
            a."IHW_Topic", 
            a."IHW_Assignment", 
            a."IHW_Date",
            c."IHWUPL_Marks",
            NULL::bigint,
            NULL::text,
            NULL::text,
            NULL::timestamp,
            NULL::timestamp,
            NULL::numeric
        FROM "IVRM_HomeWork" a
        INNER JOIN "Adm_School_Y_Student" YS ON YS."ASMAY_Id" = a."ASMAY_Id" 
            AND YS."ASMCL_Id" = a."ASMCL_Id" 
            AND YS."ASMS_Id" = a."ASMS_Id" 
            AND YS."ASMAY_Id" = "ASMAY_Id"
        INNER JOIN "IVRM_HomeWork_Attatchment" b ON b."IHW_Id" = a."IHW_Id"
        INNER JOIN "IVRM_HomeWork_Upload" c ON c."IHW_Id" = b."IHW_Id" 
            AND c."AMST_Id" = YS."AMST_Id"
        INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id" 
            AND d."MI_Id" = "MI_Id"
        WHERE c."AMST_Id" = "AMST_Id" 
            AND a."ASMAY_Id" = "ASMAY_Id" 
            AND a."MI_Id" = "MI_Id";

    ELSIF "Parameter" = 'Classwork' THEN
        RETURN QUERY
        SELECT DISTINCT 
            d."AMST_Id", 
            (COALESCE(d."AMST_FirstName", '') || COALESCE(d."AMST_MiddleName", '') || COALESCE(d."AMST_LastName", '')) as studentname, 
            NULL::bigint,
            NULL::text,
            NULL::text,
            NULL::timestamp,
            NULL::numeric,
            a."ICW_Id", 
            a."ICW_Topic", 
            a."ICW_Assignment", 
            a."ICW_FromDate", 
            a."ICW_ToDate",
            c."ICWUPL_Marks"
        FROM "IVRM_Assignment" a
        INNER JOIN "Adm_School_Y_Student" YS ON YS."ASMAY_Id" = a."ASMAY_Id" 
            AND YS."ASMCL_Id" = a."ASMCL_Id" 
            AND YS."ASMS_Id" = a."ASMS_Id" 
            AND YS."ASMAY_Id" = "ASMAY_Id"
        INNER JOIN "IVRM_ClassWork_Attatchment" b ON b."ICW_Id" = a."ICW_Id"
        INNER JOIN "IVRM_ClassWork_Upload" c ON c."ICW_Id" = a."ICW_Id" 
            AND c."AMST_Id" = YS."AMST_Id"
        INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id" 
            AND d."MI_Id" = "MI_Id"
        WHERE c."AMST_Id" = "AMST_Id" 
            AND a."ASMAY_Id" = "ASMAY_Id" 
            AND a."MI_Id" = "MI_Id";

    END IF;

    RETURN;

END;
$$;