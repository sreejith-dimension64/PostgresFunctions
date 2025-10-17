CREATE OR REPLACE FUNCTION "dbo"."Fees_School_Online_Offline_Details"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE(
    "AMST_Id" bigint,
    "StudentName" text,
    "AMST_AdmNo" text,
    "ASMCL_ClassName" text,
    "ASMC_SectionName" text,
    "AMST_MobileNo" text,
    "AMST_EmailId" text,
    "FYP_Bank_Or_Cash" text
)
LANGUAGE plpgsql
AS $$
BEGIN

    DROP TABLE IF EXISTS "FeesSchoolOnlineStastistics_Temp";

    CREATE TEMP TABLE "FeesSchoolOnlineStastistics_Temp" AS
    SELECT DISTINCT 
        "New"."AMST_Id",
        "New"."StudentName",
        "New"."AMST_AdmNo",
        "New"."ASMCL_ClassName",
        "New"."ASMC_SectionName",
        "New"."AMST_MobileNo",
        "New"."AMST_EmailId",
        "New"."FYP_Bank_Or_Cash"
    FROM (
        SELECT DISTINCT 
            "ASYS"."AMST_Id",
            (COALESCE("AMST_FirstName",'') || ' ' || COALESCE("AMST_MiddleName",'') || ' ' || COALESCE("AMST_LastName",'')) AS "StudentName",
            "AMST_AdmNo",
            "AMST_MobileNo",
            "AMST_EmailId",
            "ASMCL_ClassName",
            "ASMC_SectionName",
            "FYP_Receipt_No",
            "FYP_Tot_Amount",
            (CASE WHEN "FYP_Bank_Or_Cash"='O' THEN 'Online' ELSE 'Offline' END) AS "FYP_Bank_Or_Cash",
            CAST("FYP_Date" AS date) AS date
        FROM "Fee_Y_Payment" "FYP"
        INNER JOIN "Fee_Y_Payment_School_Student" "FYPSS" ON "FYPSS"."ASMAY_Id"="FYP"."ASMAY_ID" AND "FYPSS"."FYP_Id"="FYP"."FYP_Id"
        INNER JOIN "Fee_T_Payment" "FTP" ON "FYP"."FYP_Id"="FTP"."FYP_Id"
        INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."AMST_Id"="FYPSS"."AMST_Id" AND "ASYS"."AMAY_ActiveFlag"=1
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id"="ASYS"."AMST_Id" AND "AMS"."AMST_SOL"='S'
        INNER JOIN "Adm_School_M_Class" "ASMC" ON "ASMC"."ASMCL_Id"="ASYS"."ASMCL_Id" AND "ASMC"."MI_Id"=p_MI_Id
        INNER JOIN "Adm_School_M_Section" "ASMS" ON "ASMS"."ASMS_Id"="ASYS"."ASMS_Id" AND "ASMS"."MI_Id"=p_MI_Id
        WHERE "FYP"."MI_Id"=p_MI_Id 
            AND "FYP"."ASMAY_Id"=p_ASMAY_Id 
            AND "FYP_Chq_Bounce"<>'CB' 
            AND "FYP_Chq_Bounce"='CL' 
            AND "ASYS"."ASMAY_Id"=p_ASMAY_Id
    ) AS "New";

    RETURN QUERY
    SELECT 
        t."AMST_Id",
        t."StudentName",
        t."AMST_AdmNo",
        t."ASMCL_ClassName",
        t."ASMC_SectionName",
        t."AMST_MobileNo",
        t."AMST_EmailId",
        t."FYP_Bank_Or_Cash"
    FROM "FeesSchoolOnlineStastistics_Temp" t
    WHERE t."AMST_Id" NOT IN (
        SELECT DISTINCT t2."AMST_Id" 
        FROM "FeesSchoolOnlineStastistics_Temp" t2
        WHERE t2."FYP_Bank_Or_Cash" IN ('Online','Offline') 
        GROUP BY t2."AMST_Id" 
        HAVING COUNT(*)>1
    )
    UNION ALL
    SELECT 
        t."AMST_Id",
        t."StudentName",
        t."AMST_AdmNo",
        t."ASMCL_ClassName",
        t."ASMC_SectionName",
        t."AMST_MobileNo",
        t."AMST_EmailId",
        t."FYP_Bank_Or_Cash"
    FROM "FeesSchoolOnlineStastistics_Temp" t
    WHERE t."FYP_Bank_Or_Cash"='Online' 
        AND t."AMST_Id" IN (
            SELECT DISTINCT t2."AMST_Id" 
            FROM "FeesSchoolOnlineStastistics_Temp" t2
            WHERE t2."FYP_Bank_Or_Cash" IN ('Online','Offline') 
            GROUP BY t2."AMST_Id" 
            HAVING COUNT(*)>1
        );

    DROP TABLE IF EXISTS "FeesSchoolOnlineStastistics_Temp";

END;
$$;