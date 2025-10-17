CREATE OR REPLACE FUNCTION "dbo"."Adm_Active_Deactive_Report"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_type TEXT
)
RETURNS TABLE(
    studentname TEXT,
    admno VARCHAR,
    regno VARCHAR,
    classname VARCHAR,
    sectionname VARCHAR,
    activatedate TEXT,
    activatereason VARCHAR,
    deactivatdate TEXT,
    deactivatereason VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_type = '1' THEN
        RETURN QUERY
        SELECT 
            (COALESCE(c."AMST_FirstName",'') || ' ' || COALESCE(c."AMST_MiddleName",'') || ' ' || COALESCE(c."AMST_LastName",'')) as studentname,
            c."AMST_AdmNo" as admno,
            c."AMST_RegistrationNo" as regno,
            d."ASMCL_ClassName" as classname,
            e."ASMC_SectionName" as sectionname,
            COALESCE(TO_CHAR(a."ASDE_ActivatedDate", 'DD/MM/YYYY'), '') as activatedate,
            a."ASDE_ActivatedReason" as activatereason,
            COALESCE(TO_CHAR(a."ASDE_DeactivatedDate", 'DD/MM/YYYY'), '') as deactivatdate,
            a."ASDE_DeactivatedReason" as deactivatereason
        FROM "Adm_Student_Deactivate" a
        INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id"
        INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id" AND d."ASMCL_Id" = a."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id" AND e."ASMS_Id" = a."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id" AND f."ASMAY_Id" = a."ASMAY_Id"
        WHERE a."MI_Id" = p_MI_Id AND a."ASMAY_Id" = p_ASMAY_Id AND b."ASMAY_Id" = p_ASMAY_Id;

    ELSIF p_type = '2' THEN
        IF p_ASMS_Id = '0' THEN
            RETURN QUERY
            SELECT 
                (COALESCE(c."AMST_FirstName",'') || ' ' || COALESCE(c."AMST_MiddleName",'') || ' ' || COALESCE(c."AMST_LastName",'')) as studentname,
                c."AMST_AdmNo" as admno,
                c."AMST_RegistrationNo" as regno,
                d."ASMCL_ClassName" as classname,
                e."ASMC_SectionName" as sectionname,
                TO_CHAR(a."ASDE_ActivatedDate", 'DD/MM/YYYY') as activatedate,
                a."ASDE_ActivatedReason" as activatereason,
                TO_CHAR(a."ASDE_DeactivatedDate", 'DD/MM/YYYY') as deactivatdate,
                a."ASDE_DeactivatedReason" as deactivatereason
            FROM "Adm_Student_Deactivate" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id" AND d."ASMCL_Id" = a."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id" AND e."ASMS_Id" = a."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id" AND f."ASMAY_Id" = a."ASMAY_Id"
            WHERE a."MI_Id" = p_MI_Id AND a."ASMAY_Id" = p_ASMAY_Id AND a."ASMCL_Id" = p_ASMCL_Id 
                AND b."ASMAY_Id" = p_ASMAY_Id AND b."ASMCL_Id" = p_ASMCL_Id;
        ELSE
            RETURN QUERY
            SELECT 
                (COALESCE(c."AMST_FirstName",'') || ' ' || COALESCE(c."AMST_MiddleName",'') || ' ' || COALESCE(c."AMST_LastName",'')) as studentname,
                c."AMST_AdmNo" as admno,
                c."AMST_RegistrationNo" as regno,
                d."ASMCL_ClassName" as classname,
                e."ASMC_SectionName" as sectionname,
                TO_CHAR(a."ASDE_ActivatedDate", 'DD/MM/YYYY') as activatedate,
                a."ASDE_ActivatedReason" as activatereason,
                TO_CHAR(a."ASDE_DeactivatedDate", 'DD/MM/YYYY') as deactivatdate,
                a."ASDE_DeactivatedReason" as deactivatereason
            FROM "Adm_Student_Deactivate" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id" AND d."ASMCL_Id" = a."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id" AND e."ASMS_Id" = a."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id" AND f."ASMAY_Id" = a."ASMAY_Id"
            WHERE a."MI_Id" = p_MI_Id AND a."ASMAY_Id" = p_ASMAY_Id AND a."ASMCL_Id" = p_ASMCL_Id 
                AND a."ASMS_Id" = p_ASMS_Id AND b."ASMAY_Id" = p_ASMAY_Id AND b."ASMCL_Id" = p_ASMCL_Id 
                AND b."ASMS_Id" = p_ASMS_Id;
        END IF;
    END IF;

    RETURN;
END;
$$;