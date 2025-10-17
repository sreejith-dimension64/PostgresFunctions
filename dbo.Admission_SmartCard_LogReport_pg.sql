CREATE OR REPLACE FUNCTION "dbo"."Admission_SmartCard_LogReport"(
    p_allorindivflag TEXT,
    p_mallorindivflag TEXT,
    p_dailyordatewiseflag TEXT,
    p_dailydate TEXT,
    p_fromdate TEXT,
    p_todate TEXT,
    p_amstid TEXT,
    p_modulename TEXT
)
RETURNS TABLE(
    "Name" TEXT,
    "Class" TEXT,
    "Section" TEXT,
    "Modulename" TEXT,
    "Mdate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_allorindivflag = 'ALL' THEN
        IF p_mallorindivflag = 'mall' THEN
            IF p_dailyordatewiseflag = 'daily' THEN
                RETURN QUERY
                SELECT 
                    ("AMST_FirstName" || '' || "AMST_MiddleName" || '' || "AMST_LastName") AS "Name",
                    "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                    "Adm_School_M_Section"."ASMC_SectionName" AS "Section",
                    "CRM_SMARTCARD_LOG"."CSL_MODULENAME" AS "Modulename",
                    "CRM_SMARTCARD_LOG"."CSL_DATETIME" AS "Mdate"
                FROM "dbo"."CRM_SMARTCARD_LOG"
                INNER JOIN "dbo"."Adm_M_Student" ON "CRM_SMARTCARD_LOG"."CSL_AMST_ID" = "Adm_M_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."AMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                WHERE DATE("CRM_SMARTCARD_LOG"."CSL_DATETIME") = TO_DATE(p_dailydate, 'DD/MM/YYYY');
            ELSIF p_dailyordatewiseflag = 'btwdates' THEN
                RETURN QUERY
                SELECT 
                    ("AMST_FirstName" || '' || "AMST_MiddleName" || '' || "AMST_LastName") AS "Name",
                    "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                    "Adm_School_M_Section"."ASMC_SectionName" AS "Section",
                    "CRM_SMARTCARD_LOG"."CSL_MODULENAME" AS "Modulename",
                    "CRM_SMARTCARD_LOG"."CSL_DATETIME" AS "Mdate"
                FROM "dbo"."CRM_SMARTCARD_LOG"
                INNER JOIN "dbo"."Adm_M_Student" ON "CRM_SMARTCARD_LOG"."CSL_AMST_ID" = "Adm_M_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."AMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                WHERE DATE("CRM_SMARTCARD_LOG"."CSL_DATETIME") BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY');
            END IF;
        ELSIF p_mallorindivflag = 'mindi' THEN
            IF p_dailyordatewiseflag = 'daily' THEN
                RETURN QUERY
                SELECT 
                    ("AMST_FirstName" || '' || "AMST_MiddleName" || '' || "AMST_LastName") AS "Name",
                    "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                    "Adm_School_M_Section"."ASMC_SectionName" AS "Section",
                    "CRM_SMARTCARD_LOG"."CSL_MODULENAME" AS "Modulename",
                    "CRM_SMARTCARD_LOG"."CSL_DATETIME" AS "Mdate"
                FROM "dbo"."CRM_SMARTCARD_LOG"
                INNER JOIN "dbo"."Adm_M_Student" ON "CRM_SMARTCARD_LOG"."CSL_AMST_ID" = "Adm_M_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."AMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                WHERE DATE("CRM_SMARTCARD_LOG"."CSL_DATETIME") = TO_DATE(p_dailydate, 'DD/MM/YYYY')
                AND "CRM_SMARTCARD_LOG"."CSL_MODULENAME" = p_modulename;
            ELSIF p_dailyordatewiseflag = 'btwdates' THEN
                RETURN QUERY
                SELECT 
                    ("AMST_FirstName" || '' || "AMST_MiddleName" || '' || "AMST_LastName") AS "Name",
                    "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                    "Adm_School_M_Section"."ASMC_SectionName" AS "Section",
                    "CRM_SMARTCARD_LOG"."CSL_MODULENAME" AS "Modulename",
                    "CRM_SMARTCARD_LOG"."CSL_DATETIME" AS "Mdate"
                FROM "dbo"."CRM_SMARTCARD_LOG"
                INNER JOIN "dbo"."Adm_M_Student" ON "CRM_SMARTCARD_LOG"."CSL_AMST_ID" = "Adm_M_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."AMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                WHERE DATE("CRM_SMARTCARD_LOG"."CSL_DATETIME") BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
                AND "CRM_SMARTCARD_LOG"."CSL_MODULENAME" = p_modulename;
            END IF;
        END IF;
    ELSIF p_allorindivflag = 'indi' THEN
        IF p_mallorindivflag = 'mall' THEN
            IF p_dailyordatewiseflag = 'daily' THEN
                RETURN QUERY
                SELECT 
                    ("AMST_FirstName" || '' || "AMST_MiddleName" || '' || "AMST_LastName") AS "Name",
                    "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                    "Adm_School_M_Section"."ASMC_SectionName" AS "Section",
                    "CRM_SMARTCARD_LOG"."CSL_MODULENAME" AS "Modulename",
                    "CRM_SMARTCARD_LOG"."CSL_DATETIME" AS "Mdate"
                FROM "dbo"."CRM_SMARTCARD_LOG"
                INNER JOIN "dbo"."Adm_M_Student" ON "CRM_SMARTCARD_LOG"."CSL_AMST_ID" = "Adm_M_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."AMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                WHERE DATE("CRM_SMARTCARD_LOG"."CSL_DATETIME") = TO_DATE(p_dailydate, 'DD/MM/YYYY')
                AND "CRM_SMARTCARD_LOG"."CSL_AMST_ID"::TEXT = p_amstid;
            ELSIF p_dailyordatewiseflag = 'btwdates' THEN
                RETURN QUERY
                SELECT 
                    ("AMST_FirstName" || '' || "AMST_MiddleName" || '' || "AMST_LastName") AS "Name",
                    "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                    "Adm_School_M_Section"."ASMC_SectionName" AS "Section",
                    "CRM_SMARTCARD_LOG"."CSL_MODULENAME" AS "Modulename",
                    "CRM_SMARTCARD_LOG"."CSL_DATETIME" AS "Mdate"
                FROM "dbo"."CRM_SMARTCARD_LOG"
                INNER JOIN "dbo"."Adm_M_Student" ON "CRM_SMARTCARD_LOG"."CSL_AMST_ID" = "Adm_M_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."AMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                WHERE DATE("CRM_SMARTCARD_LOG"."CSL_DATETIME") BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
                AND "CRM_SMARTCARD_LOG"."CSL_AMST_ID"::TEXT = p_amstid;
            END IF;
        ELSIF p_mallorindivflag = 'mindi' THEN
            IF p_dailyordatewiseflag = 'daily' THEN
                RETURN QUERY
                SELECT 
                    ("AMST_FirstName" || '' || "AMST_MiddleName" || '' || "AMST_LastName") AS "Name",
                    "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                    "Adm_School_M_Section"."ASMC_SectionName" AS "Section",
                    "CRM_SMARTCARD_LOG"."CSL_MODULENAME" AS "Modulename",
                    "CRM_SMARTCARD_LOG"."CSL_DATETIME" AS "Mdate"
                FROM "dbo"."CRM_SMARTCARD_LOG"
                INNER JOIN "dbo"."Adm_M_Student" ON "CRM_SMARTCARD_LOG"."CSL_AMST_ID" = "Adm_M_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."AMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                WHERE DATE("CRM_SMARTCARD_LOG"."CSL_DATETIME") = TO_DATE(p_dailydate, 'DD/MM/YYYY')
                AND "CRM_SMARTCARD_LOG"."CSL_MODULENAME" = p_modulename
                AND "CRM_SMARTCARD_LOG"."CSL_AMST_ID"::TEXT = p_amstid;
            ELSIF p_dailyordatewiseflag = 'btwdates' THEN
                RETURN QUERY
                SELECT 
                    ("AMST_FirstName" || '' || "AMST_MiddleName" || '' || "AMST_LastName") AS "Name",
                    "Adm_School_M_Class"."ASMCL_ClassName" AS "Class",
                    "Adm_School_M_Section"."ASMC_SectionName" AS "Section",
                    "CRM_SMARTCARD_LOG"."CSL_MODULENAME" AS "Modulename",
                    "CRM_SMARTCARD_LOG"."CSL_DATETIME" AS "Mdate"
                FROM "dbo"."CRM_SMARTCARD_LOG"
                INNER JOIN "dbo"."Adm_M_Student" ON "CRM_SMARTCARD_LOG"."CSL_AMST_ID" = "Adm_M_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id"
                INNER JOIN "dbo"."Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id"
                INNER JOIN "dbo"."Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id"
                INNER JOIN "dbo"."Adm_School_M_Academic_Year" ON "Adm_School_Y_Student"."AMAY_Id" = "Adm_School_M_Academic_Year"."ASMAY_Id"
                WHERE DATE("CRM_SMARTCARD_LOG"."CSL_DATETIME") BETWEEN TO_DATE(p_fromdate, 'DD/MM/YYYY') AND TO_DATE(p_todate, 'DD/MM/YYYY')
                AND "CRM_SMARTCARD_LOG"."CSL_AMST_ID"::TEXT = p_amstid
                AND "CRM_SMARTCARD_LOG"."CSL_MODULENAME" = p_modulename;
            END IF;
        END IF;
    END IF;

    RETURN;
END;
$$;