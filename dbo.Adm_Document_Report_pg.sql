CREATE OR REPLACE FUNCTION "dbo"."Adm_Document_Report"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@AMST_Id" TEXT,
    "@STDORDOC" TEXT,
    "@SUBORNOT" TEXT,
    "@AMSMD_Id" TEXT
)
RETURNS TABLE(
    "docname" TEXT,
    "statuss" TEXT,
    "submited" TEXT,
    "docpath" TEXT,
    "studentnam" TEXT,
    "admno" TEXT,
    "classname" TEXT,
    "secname" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN

    -- if section is all
    IF "@ASMS_Id" = '0' THEN
    
        -- STUDENT WISE
        IF "@STDORDOC" = '1' THEN
        
            RETURN QUERY
            SELECT 
                mstdoc."AMSMD_DocumentName" as "docname",
                'Yes' as "statuss",
                'Submited' as "submited",
                stddoc."AMSTD_DOC_Path" as "docpath",
                CASE WHEN mstd."AMST_FirstName" IS NULL OR mstd."AMST_FirstName" = '' THEN '' ELSE mstd."AMST_FirstName" END ||
                CASE WHEN mstd."AMST_MiddleName" IS NULL OR mstd."AMST_MiddleName" = '' OR mstd."AMST_MiddleName" = '0' THEN '' ELSE ' ' || mstd."AMST_MiddleName" END ||
                CASE WHEN mstd."AMST_LastName" IS NULL OR mstd."AMST_LastName" = '' OR mstd."AMST_LastName" = '0' THEN '' ELSE ' ' || mstd."AMST_LastName" END as "studentnam",
                mstd."AMST_AdmNo" as "admno",
                cls."ASMCL_ClassName" as "classname",
                sec."ASMC_SectionName" as "secname"
            FROM "Adm_Master_Student_Documents" stddoc
            INNER JOIN "Adm_m_School_Master_Documents" mstdoc ON stddoc."AMSMD_Id" = mstdoc."AMSMD_Id"
            INNER JOIN "Adm_School_Y_Student" ystd ON ystd."AMST_Id" = stddoc."AMST_Id"
            INNER JOIN "Adm_M_Student" mstd ON ystd."AMST_Id" = mstd."AMST_Id"
            INNER JOIN "Adm_School_M_Class" cls ON cls."ASMCL_Id" = ystd."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" sec ON sec."ASMS_Id" = ystd."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" ye ON ye."ASMAY_Id" = ystd."ASMAY_Id"
            WHERE ystd."AMST_Id" = "@AMST_Id" 
                AND ystd."ASMCL_Id" = "@ASMCL_Id" 
                AND ystd."ASMS_Id" IN (SELECT "ASMS_Id" FROM "Adm_School_M_Section" WHERE "MI_Id" = "@MI_Id" AND "ASMC_ActiveFlag" = 1)
                AND mstd."MI_Id" = "@MI_Id" 
                AND ystd."ASMAY_Id" = "@ASMAY_Id"
                
            UNION ALL
            
            SELECT 
                "AMSMD_DocumentName" as "docname",
                'No' as "statuss",
                ' Not Submited' as "submited",
                '' as "docpath",
                '' as "studentnam",
                '' as "admno",
                '' as "classname",
                '' as "secname"
            FROM "Adm_m_School_Master_Documents"
            WHERE "AMSMD_Id" NOT IN (
                SELECT "AMSMD_Id" 
                FROM "Adm_Master_Student_Documents" a
                INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = a."AMST_Id"
                INNER JOIN "Adm_M_Student" b ON b."AMST_Id" = c."AMST_Id"
                INNER JOIN "Adm_School_M_Class" d ON c."ASMCL_Id" = d."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = c."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = c."ASMAY_Id"
                WHERE a."AMST_Id" = "@AMST_Id" 
                    AND b."MI_Id" = "@MI_Id" 
                    AND c."ASMAY_Id" = "@ASMAY_Id" 
                    AND c."ASMCL_Id" = "@ASMCL_Id"
                    AND c."ASMS_Id" IN (SELECT "ASMS_Id" FROM "Adm_School_M_Section" WHERE "MI_Id" = "@MI_Id" AND "ASMC_ActiveFlag" = 1)
            ) 
            AND "MI_Id" = "@MI_Id";
            
        -- document wise
        ELSIF "@STDORDOC" = '2' THEN
        
            -- both
            IF "@SUBORNOT" = '3' THEN
            
                RETURN QUERY
                SELECT 
                    b."AMSMD_DocumentName" as "docname",
                    'Yes' as "statuss",
                    'Submited' as "submited",
                    a."AMSTD_DOC_Path" as "docpath",
                    CASE WHEN d."AMST_FirstName" IS NULL OR d."AMST_FirstName" = '' THEN '' ELSE d."AMST_FirstName" END ||
                    CASE WHEN d."AMST_MiddleName" IS NULL OR d."AMST_MiddleName" = '' OR d."AMST_MiddleName" = '0' THEN '' ELSE ' ' || d."AMST_MiddleName" END ||
                    CASE WHEN d."AMST_LastName" IS NULL OR d."AMST_LastName" = '' OR d."AMST_LastName" = '0' THEN '' ELSE ' ' || d."AMST_LastName" END as "studentnam",
                    d."AMST_AdmNo" as "admno",
                    e."ASMCL_ClassName" as "classname",
                    f."ASMC_SectionName" as "sectionname"
                FROM "Adm_Master_Student_Documents" a
                INNER JOIN "Adm_m_School_Master_Documents" b ON a."AMSMD_Id" = b."AMSMD_Id"
                INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = a."AMST_Id"
                INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
                INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = c."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = c."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = c."ASMAY_Id"
                WHERE a."MI_Id" = "@MI_Id" 
                    AND c."ASMCL_Id" = "@ASMCL_Id" 
                    AND c."ASMS_Id" IN (SELECT "ASMS_Id" FROM "Adm_School_M_Section" WHERE "MI_Id" = "@MI_Id" AND "ASMC_ActiveFlag" = 1)
                    AND a."MI_Id" = "@MI_Id" 
                    AND c."ASMAY_Id" = "@ASMAY_Id" 
                    AND a."AMSMD_Id" = "@AMSMD_Id"
                    
                UNION ALL
                
                SELECT 
                    '' as "docname",
                    'No' as "statuss",
                    'Not Submited' as "submited",
                    '' as "docpath",
                    CASE WHEN b."AMST_FirstName" IS NULL OR b."AMST_FirstName" = '' THEN '' ELSE b."AMST_FirstName" END ||
                    CASE WHEN b."AMST_MiddleName" IS NULL OR b."AMST_MiddleName" = '' OR b."AMST_MiddleName" = '0' THEN '' ELSE ' ' || b."AMST_MiddleName" END ||
                    CASE WHEN b."AMST_LastName" IS NULL OR b."AMST_LastName" = '' OR b."AMST_LastName" = '0' THEN '' ELSE ' ' || b."AMST_LastName" END as "studentnam",
                    b."AMST_AdmNo" as "admno",
                    e."ASMCL_ClassName" as "classname",
                    f."ASMC_SectionName" as "sectionname"
                FROM "Adm_School_Y_Student" a
                INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = a."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = a."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = a."ASMAY_Id"
                WHERE a."AMST_Id" NOT IN (
                    SELECT c."AMST_Id" 
                    FROM "Adm_Master_Student_Documents" c
                    INNER JOIN "Adm_m_School_Master_Documents" d ON d."AMSMD_Id" = c."AMSMD_Id"
                    WHERE c."AMSMD_Id" = "@AMSMD_Id" AND c."MI_Id" = "@MI_Id"
                )
                AND b."MI_Id" = "@MI_Id" 
                AND a."ASMCL_Id" = "@ASMCL_Id" 
                AND a."ASMS_Id" IN (SELECT "ASMS_Id" FROM "Adm_School_M_Section" WHERE "MI_Id" = "@MI_Id" AND "ASMC_ActiveFlag" = 1)
                AND b."MI_Id" = "@MI_Id" 
                AND a."ASMAY_Id" = "@ASMAY_Id";
                
            -- submitted
            ELSIF "@SUBORNOT" = '2' THEN
            
                RETURN QUERY
                SELECT 
                    b."AMSMD_DocumentName" as "docname",
                    'Yes' as "statuss",
                    'Submited' as "submited",
                    a."AMSTD_DOC_Path" as "docpath",
                    CASE WHEN d."AMST_FirstName" IS NULL OR d."AMST_FirstName" = '' THEN '' ELSE d."AMST_FirstName" END ||
                    CASE WHEN d."AMST_MiddleName" IS NULL OR d."AMST_MiddleName" = '' OR d."AMST_MiddleName" = '0' THEN '' ELSE ' ' || d."AMST_MiddleName" END ||
                    CASE WHEN d."AMST_LastName" IS NULL OR d."AMST_LastName" = '' OR d."AMST_LastName" = '0' THEN '' ELSE ' ' || d."AMST_LastName" END as "studentnam",
                    d."AMST_AdmNo" as "admno",
                    e."ASMCL_ClassName" as "classname",
                    f."ASMC_SectionName" as "sectionname"
                FROM "Adm_Master_Student_Documents" a
                INNER JOIN "Adm_m_School_Master_Documents" b ON a."AMSMD_Id" = b."AMSMD_Id"
                INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = a."AMST_Id"
                INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
                INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = c."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = c."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = c."ASMAY_Id"
                WHERE a."MI_Id" = "@MI_Id" 
                    AND c."ASMCL_Id" = "@ASMCL_Id" 
                    AND c."ASMS_Id" IN (SELECT "ASMS_Id" FROM "Adm_School_M_Section" WHERE "MI_Id" = "@MI_Id" AND "ASMC_ActiveFlag" = 1)
                    AND a."MI_Id" = "@MI_Id" 
                    AND c."ASMAY_Id" = "@ASMAY_Id" 
                    AND a."AMSMD_Id" = "@AMSMD_Id";
                    
            -- not submitted
            ELSIF "@SUBORNOT" = '1' THEN
            
                RETURN QUERY
                SELECT 
                    '' as "docname",
                    'No' as "statuss",
                    'Not Submited' as "submited",
                    '' as "docpath",
                    CASE WHEN b."AMST_FirstName" IS NULL OR b."AMST_FirstName" = '' THEN '' ELSE b."AMST_FirstName" END ||
                    CASE WHEN b."AMST_MiddleName" IS NULL OR b."AMST_MiddleName" = '' OR b."AMST_MiddleName" = '0' THEN '' ELSE ' ' || b."AMST_MiddleName" END ||
                    CASE WHEN b."AMST_LastName" IS NULL OR b."AMST_LastName" = '' OR b."AMST_LastName" = '0' THEN '' ELSE ' ' || b."AMST_LastName" END as "studentnam",
                    b."AMST_AdmNo" as "admno",
                    '' as "classname",
                    '' as "sectionname"
                FROM "Adm_School_Y_Student" a
                INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_School_M_Class" e ON e."ASMCL_Id" = a."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" f ON f."ASMS_Id" = a."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" g ON g."ASMAY_Id" = a."ASMAY_Id"
                WHERE a."AMST_Id" NOT IN (
                    SELECT c."AMST_Id" 
                    FROM "Adm_Master_Student_Documents" c
                    INNER JOIN "Adm_m_School_Master_Documents" d ON d."AMSMD_Id" = c."AMSMD_Id"
                    WHERE c."AMSMD_Id" = "@AMSMD_Id" AND c."MI_Id" = "@MI_Id"
                )
                AND b."MI_Id" = "@MI_Id" 
                AND a."ASMCL_Id" = "@ASMCL_Id" 
                AND a."ASMS_Id" IN (SELECT "ASMS_Id" FROM "Adm_School_M_Section" WHERE "MI_Id" = "@MI_Id" AND "ASMC_ActiveFlag" = 1)
                AND b."MI_Id" = "@MI_Id" 
                AND a."ASMAY_Id" = "@ASMAY_Id";
                
            END IF;
            
        END IF;
        
    -- if section is selected
    ELSE
    
        -- STUDENT WISE
        IF "@STDORDOC" = '1' THEN
        
            RETURN QUERY
            SELECT 
                mstdoc."AMSMD_DocumentName" as "docname",
                'Yes' as "statuss",
                'Submited' as "submited",
                stddoc."AMSTD_DOC_Path" as "docpath",
                CASE WHEN mstd."AMST_FirstName" IS NULL OR mstd."AMST_FirstName" = '' THEN '' ELSE mstd."AMST_FirstName" END ||
                CASE WHEN mstd."AMST_MiddleName" IS NULL OR mstd."AMST_MiddleName" = '' OR mstd."AMST_MiddleName" = '0' THEN '' ELSE ' ' || mstd."AMST_MiddleName" END ||
                CASE WHEN mstd."AMST_LastName" IS NULL OR mstd."AMST_LastName" = '' OR mstd."AMST_LastName" = '0' THEN '' ELSE ' ' || mstd."AMST_LastName" END as "studentnam",
                mstd."AMST_AdmNo" as "admno",
                '' as "classname",
                '' as "secname"
            FROM "Adm_Master_Student_Documents" stddoc
            INNER JOIN "Adm_m_School_Master_Documents" mstdoc ON stddoc."AMSMD_Id" = mstdoc."AMSMD_Id"
            INNER JOIN "Adm_School_Y_Student" ystd ON ystd."AMST_Id" = stddoc."AMST_Id"
            INNER JOIN "Adm_M_Student" mstd ON ystd."AMST_Id" = mstd."AMST_Id"
            WHERE ystd."AMST_Id" = "@AMST_Id" 
                AND ystd."ASMCL_Id" = "@ASMCL_Id" 
                AND ystd."ASMS_Id" = "@ASMS_Id" 
                AND mstd."MI_Id" = "@MI_Id" 
                AND ystd."ASMAY_Id" = "@ASMAY_Id"
                
            UNION ALL
            
            SELECT 
                "AMSMD_DocumentName" as "docname",
                'No' as "statuss",
                ' Not Submited' as "submited",
                '' as "docpath",
                '' as "studentnam",
                '' as "admno",
                '' as "classname",
                '' as "secname"
            FROM "Adm_m_School_Master_Documents"
            WHERE "AMSMD_Id" NOT IN (
                SELECT "AMSMD_Id" 
                FROM "Adm_Master_Student_Documents" a
                INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = a."AMST_Id"
                INNER JOIN "Adm_M_Student" b ON b."AMST_Id" = c."AMST_Id"
                WHERE a."AMST_Id" = "@AMST_Id" 
                    AND b."MI_Id" = "@MI_Id" 
                    AND c."ASMAY_Id" = "@ASMAY_Id" 
                    AND c."ASMCL_Id" = "@ASMCL_Id"
                    AND "ASMS_Id" = "@ASMS_Id"
            )
            AND "MI_Id" = "@MI_Id";
            
        -- document wise
        ELSIF "@STDORDOC" = '2' THEN
        
            -- both
            IF "@SUBORNOT" = '3' THEN
            
                RETURN QUERY
                SELECT 
                    b."AMSMD_DocumentName" as "docname",
                    'Yes' as "statuss",
                    'Submited' as "submited",
                    a."AMSTD_DOC_Path" as "docpath",
                    CASE WHEN d."AMST_FirstName" IS NULL OR d."AMST_FirstName" = '' THEN '' ELSE d."AMST_FirstName" END ||
                    CASE WHEN d."AMST_MiddleName" IS NULL OR d."AMST_MiddleName" = '' OR d."AMST_MiddleName" = '0' THEN '' ELSE ' ' || d."AMST_MiddleName" END ||
                    CASE WHEN d."AMST_LastName" IS NULL OR d."AMST_LastName" = '' OR d."AMST_LastName" = '0' THEN '' ELSE ' ' || d."AMST_LastName" END as "studentnam",
                    d."AMST_AdmNo" as "admno",
                    '' as "classname",
                    '' as "secname"
                FROM "Adm_Master_Student_Documents" a
                INNER JOIN "Adm_m_School_Master_Documents" b ON a."AMSMD_Id" = b."AMSMD_Id"
                INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = a."AMST_Id"
                INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
                WHERE a."MI_Id" = "@MI_Id" 
                    AND c."ASMCL_Id" = "@ASMCL_Id" 
                    AND c."ASMS_Id" = "@ASMS_Id" 
                    AND a."MI_Id" = "@MI_Id" 
                    AND c."ASMAY_Id" = "@ASMAY_Id" 
                    AND a."AMSMD_Id" = "@AMSMD_Id"
                    
                UNION ALL
                
                SELECT 
                    '' as "docname",
                    'No' as "statuss",
                    'Not Submited' as "submited",
                    '' as "docpath",
                    CASE WHEN b."AMST_FirstName" IS NULL OR b."AMST_FirstName" = '' THEN '' ELSE b."AMST_FirstName" END ||
                    CASE WHEN b."AMST_MiddleName" IS NULL OR b."AMST_MiddleName" = '' OR b."AMST_MiddleName" = '0' THEN '' ELSE ' ' || b."AMST_MiddleName" END ||
                    CASE WHEN b."AMST_LastName" IS NULL OR b."AMST_LastName" = '' OR b."AMST_LastName" = '0' THEN '' ELSE ' ' || b."AMST_LastName" END as "studentnam",
                    b."AMST_AdmNo" as "admno",
                    '' as "classname",
                    '' as "secname"
                FROM "Adm_School_Y_Student" a
                INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
                WHERE a."AMST_Id" NOT IN (
                    SELECT c."AMST_Id" 
                    FROM "Adm_Master_Student_Documents" c
                    INNER JOIN "Adm_m_School_Master_Documents" d ON d."AMSMD_Id" = c."AMSMD_Id"
                    WHERE c."AMSMD_Id" = "@AMSMD_Id" AND c."MI_Id" = "@MI_Id"
                )
                AND b."MI_Id" = "@MI_Id" 
                AND a."ASMCL_Id" = "@ASMCL_Id" 
                AND a."ASMS_Id" = "@ASMS_Id" 
                AND b."MI_Id" = "@MI_Id" 
                AND a."ASMAY_Id" = "@ASMAY_Id";
                
            -- submitted
            ELSIF "@SUBORNOT" = '2' THEN
            
                RETURN QUERY
                SELECT 
                    b."AMSMD_DocumentName" as "docname",
                    'Yes' as "statuss",
                    'Submited' as "submited",
                    a."AMSTD_DOC_Path" as "docpath",
                    CASE WHEN d."AMST_FirstName" IS NULL OR d."AMST_FirstName" = '' THEN '' ELSE d."AMST_FirstName" END ||
                    CASE WHEN d."AMST_MiddleName" IS NULL OR d."AMST_MiddleName" = '' OR d."AMST_MiddleName" = '0' THEN '' ELSE ' ' || d."AMST_MiddleName" END ||
                    CASE WHEN d."AMST_LastName" IS NULL OR d."AMST_LastName" = '' OR d."AMST_LastName" = '0' THEN '' ELSE ' ' || d."AMST_LastName" END as "studentnam",
                    d."AMST_AdmNo" as "admno",
                    '' as "classname",
                    '' as "secname"
                FROM "Adm_Master_Student_Documents" a
                INNER JOIN "Adm_m_School_Master_Documents" b ON a."AMSMD_Id" = b."AMSMD_Id"
                INNER JOIN "Adm_School_Y_Student" c ON c."AMST_Id" = a."AMST_Id"
                INNER JOIN "Adm_M_Student" d ON d."AMST_Id" = c."AMST_Id"
                WHERE a."MI_Id" = "@MI_Id" 
                    AND c."ASMCL_Id" = "@ASMCL_Id" 
                    AND c."ASMS_Id" = "@ASMS_Id" 
                    AND a."MI_Id" = "@MI_Id" 
                    AND c."ASMAY_Id" = "@ASMAY_Id" 
                    AND a."AMSMD_Id" = "@AMSMD_Id";
                    
            -- not submitted
            ELSIF "@SUBORNOT" = '1' THEN
            
                RETURN QUERY
                SELECT 
                    '' as "docname",
                    'No' as "statuss",
                    'Not Submited' as "submited",
                    '' as "docpath",
                    CASE WHEN b."AMST_FirstName" IS NULL OR b."AMST_FirstName" = '' THEN '' ELSE b."AMST_FirstName" END ||
                    CASE WHEN b."AMST_MiddleName" IS NULL OR b."AMST_MiddleName" = '' OR b."AMST_MiddleName" = '0' THEN '' ELSE ' ' || b."AMST_MiddleName" END ||
                    CASE WHEN b."AMST_LastName" IS NULL OR b."AMST_LastName" = '' OR b."AMST_LastName" = '0' THEN '' ELSE ' ' || b."AMST_LastName" END as "studentnam",
                    b."AMST_AdmNo" as "admno",
                    '' as "classname",
                    '' as "secname"
                FROM "Adm_School_Y_Student" a
                INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
                WHERE a."AMST_Id" NOT IN (
                    SELECT c."AMST_Id" 
                    FROM "Adm_Master_Student_Documents" c
                    INNER JOIN "Adm_m_School_Master_Documents" d ON d."AMSMD_Id" = c."AMSMD_Id"
                    WHERE c."AMSMD_Id" = "@AMSMD_Id" AND c."MI_Id" = "@MI_Id"
                )
                AND b."MI_Id" = "@MI_Id" 
                AND a."ASMCL_Id" = "@ASMCL_Id" 
                AND a."ASMS_Id" = "@ASMS_Id" 
                AND b."MI_Id" = "@MI_Id" 
                AND a."ASMAY_Id" = "@ASMAY_Id";
                
            END IF;
            
        END IF;
        
    END IF;

    RETURN;

END;
$$;