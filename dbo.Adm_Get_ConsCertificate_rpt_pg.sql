CREATE OR REPLACE FUNCTION "Adm_Get_ConsCertificate_rpt"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT,
    "ASC_ReportType" TEXT,
    "ASMCL_Id" TEXT,
    "ASMS_Id" TEXT
)
RETURNS TABLE(
    "MI_Id" INTEGER,
    "ASMAY_Id" INTEGER,
    "ASMCL_Ids" TEXT,
    "ASMS_Ids" TEXT,
    "ASC_ReportType" TEXT,
    "CertificateCount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_SQLQUERY TEXT;
    v_ASC_ReportType TEXT;
BEGIN
    v_ASC_ReportType := "ASC_ReportType";
    
    IF v_ASC_ReportType = 'Select All' THEN
        v_ASC_ReportType := NULL;
        
        IF "ASMS_Id" = '0' THEN
            v_SQLQUERY := 'SELECT ' || "MI_Id" || ' AS "MI_Id",' || "ASMAY_Id" || ' AS "ASMAY_Id",''' || "ASMCL_Id" || ''' AS "ASMCL_Ids", ''' || "ASMS_Id" || ''' AS "ASMS_Ids",
            a."ASC_ReportType", COUNT(a."ASC_Id") AS "CertificateCount" 
            FROM "Adm_Study_Certificate_Report" a
            INNER JOIN "adm_school_y_student" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id"
            INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id" AND c."ASMAY_Id" = b."ASMAY_Id"
            WHERE a."ASMAY_Id" = ' || "ASMAY_Id" || ' AND c."MI_Id" = ' || "MI_Id" || ' AND b."ASMCL_Id" IN (' || "ASMCL_Id" || ')
            AND a."ASC_ReportType" IS NOT NULL
            GROUP BY a."ASC_ReportType"';
        ELSE
            v_SQLQUERY := 'SELECT ' || "MI_Id" || ' AS "MI_Id",' || "ASMAY_Id" || ' AS "ASMAY_Id",''' || "ASMCL_Id" || ''' AS "ASMCL_Ids", ''' || "ASMS_Id" || ''' AS "ASMS_Ids",
            a."ASC_ReportType", COUNT(a."ASC_Id") AS "CertificateCount" 
            FROM "Adm_Study_Certificate_Report" a
            INNER JOIN "adm_school_y_student" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id"
            INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id" AND c."ASMAY_Id" = b."ASMAY_Id"
            WHERE a."ASMAY_Id" = ' || "ASMAY_Id" || ' AND c."MI_Id" = ' || "MI_Id" || ' AND b."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND b."ASMS_Id" IN (' || "ASMS_Id" || ')
            AND a."ASC_ReportType" IS NOT NULL
            GROUP BY a."ASC_ReportType"';
        END IF;
        
        RETURN QUERY EXECUTE v_SQLQUERY;
    ELSE
        IF "ASMS_Id" = '0' THEN
            v_SQLQUERY := 'SELECT ' || "MI_Id" || ' AS "MI_Id",' || "ASMAY_Id" || ' AS "ASMAY_Id",''' || "ASMCL_Id" || ''' AS "ASMCL_Ids", ''' || "ASMS_Id" || ''' AS "ASMS_Ids",
            a."ASC_ReportType", COUNT(a."ASC_Id") AS "CertificateCount" 
            FROM "Adm_Study_Certificate_Report" a
            INNER JOIN "adm_school_y_student" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id"
            INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id" AND c."ASMAY_Id" = b."ASMAY_Id"
            WHERE a."ASMAY_Id" = ' || "ASMAY_Id" || ' AND c."MI_Id" = ' || "MI_Id" || ' AND b."ASMCL_Id" IN (' || "ASMCL_Id" || ')
            AND a."ASC_ReportType" = COALESCE(''' || v_ASC_ReportType || ''', a."ASC_ReportType") AND a."ASC_ReportType" IS NOT NULL
            GROUP BY a."ASC_ReportType"';
        ELSE
            v_SQLQUERY := 'SELECT ' || "MI_Id" || ' AS "MI_Id",' || "ASMAY_Id" || ' AS "ASMAY_Id",''' || "ASMCL_Id" || ''' AS "ASMCL_Ids", ''' || "ASMS_Id" || ''' AS "ASMS_Ids",
            a."ASC_ReportType", COUNT(a."ASC_Id") AS "CertificateCount" 
            FROM "Adm_Study_Certificate_Report" a
            INNER JOIN "adm_school_y_student" b ON a."AMST_Id" = b."AMST_Id" AND a."ASMAY_Id" = b."ASMAY_Id"
            INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id" AND c."ASMAY_Id" = b."ASMAY_Id"
            WHERE a."ASMAY_Id" = ' || "ASMAY_Id" || ' AND c."MI_Id" = ' || "MI_Id" || ' AND b."ASMCL_Id" IN (' || "ASMCL_Id" || ') AND b."ASMS_Id" IN (' || "ASMS_Id" || ')
            AND a."ASC_ReportType" = COALESCE(''' || v_ASC_ReportType || ''', a."ASC_ReportType") AND a."ASC_ReportType" IS NOT NULL
            GROUP BY a."ASC_ReportType"';
        END IF;
        
        RETURN QUERY EXECUTE v_SQLQUERY;
    END IF;
END;
$$;