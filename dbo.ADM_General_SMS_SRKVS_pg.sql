CREATE OR REPLACE FUNCTION "ADM_General_SMS_SRKVS"(
    "MI_ID" TEXT,
    "ASMAY_ID" TEXT,
    "ASMCL_ID" TEXT,
    "ASMS_ID" TEXT,
    "GRADE" TEXT
)
RETURNS TABLE(
    "AMST_ID" BIGINT,
    "AMST_Firstname" TEXT,
    "AMST_AdmNo" TEXT,
    "AMST_MobileNo" BIGINT,
    "AMST_emailId" TEXT,
    "SMS" TEXT,
    "Total" TEXT,
    "Percentage" DECIMAL(18,2),
    "ISMS_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Totalobtmarks DECIMAL(18,2);
    v_Totalmaxmarks DECIMAL(18,2);
    v_AMST_ID BIGINT;
    v_EMCA_ID BIGINT;
    v_EYC_ID BIGINT;
BEGIN

    DROP TABLE IF EXISTS "Temp_Amst_id_SMS";
    
    CREATE TEMP TABLE "Temp_Amst_id_SMS"(
        "AMST_ID" BIGINT,
        "AMST_Firstname" TEXT,
        "AMST_AdmNo" TEXT,
        "AMST_MobileNo" BIGINT,
        "AMST_emailId" TEXT,
        "SMS" TEXT,
        "Total" TEXT,
        "Percentage" DECIMAL(18,2),
        "ISMS_Id" BIGINT
    );
    
    SELECT "EMCA_Id" INTO v_EMCA_ID 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = "MI_ID"::BIGINT 
        AND "ASMAY_Id" = "ASMAY_ID"::BIGINT 
        AND "ASMCL_Id" = "ASMCL_ID"::BIGINT 
        AND "ASMS_Id" = "ASMS_ID"::BIGINT
        AND "ECAC_ActiveFlag" = 1;
    
    SELECT "EYC_Id" INTO v_EYC_ID 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = "MI_ID"::BIGINT 
        AND "ASMAY_Id" = "ASMAY_ID"::BIGINT 
        AND "EMCA_Id" = 32 
        AND "EYC_ActiveFlg" = 1;
    
    FOR v_AMST_ID IN 
        SELECT "AMST_ID" 
        FROM "Adm_school_Y_student" 
        WHERE "ASMAY_Id" = "ASMAY_ID"::BIGINT 
            AND "ASMCL_Id" = "ASMCL_ID"::BIGINT 
            AND "ASMS_Id" = "ASMS_ID"::BIGINT
    LOOP
        
        SELECT 
            ROUND(SUM("SG"."ESTMPPSG_GroupObtMarks"), 0),
            ROUND(SUM("SG"."ESTMPPSG_GroupMaxMarks"), 0)
        INTO v_Totalobtmarks, v_Totalmaxmarks
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" "MPS"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" "SG" ON "MPS"."ESTMPPS_Id" = "SG"."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" "MSG" ON "MSG"."EMPSG_Id" = "SG"."EMPSG_Id" AND "EMPSG_ActiveFlag" = 1
        INNER JOIN "IVRM_Master_Subjects" "MS" ON "MS"."ISMS_Id" = "MPS"."ISMS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "PS" ON "PS"."EMPS_Id" = "MSG"."EMPS_Id" AND "MS"."ISMS_Id" = "PS"."ISMS_Id" AND "PS"."EMPS_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_M_Promotion" "MP" ON "MP"."EMP_Id" = "PS"."EMP_Id" AND "MP"."EMP_ActiveFlag" = 1 AND "MP"."EYC_Id" = v_EYC_ID
        WHERE "MPS"."ASMAY_Id" = "ASMAY_ID"::BIGINT 
            AND "MPS"."MI_Id" = "MI_ID"::BIGINT 
            AND "MPS"."ASMCL_Id" = "ASMCL_ID"::BIGINT 
            AND "MPS"."ASMS_Id" = "ASMS_ID"::BIGINT
            AND "MPS"."AMST_Id" = v_AMST_ID;
        
        INSERT INTO "Temp_Amst_id_SMS"
        SELECT DISTINCT 
            "MPS"."AMST_ID",
            CONCAT(COALESCE("AMS"."AMST_Firstname", ''), ' ', COALESCE("AMS"."AMST_Middlename", ''), ' ', COALESCE("AMS"."AMST_Lastname", '')) AS "AMST_Firstname",
            "AMS"."AMST_AdmNo",
            "AMS"."AMST_MobileNo",
            "AMS"."AMST_emailId",
            ("MS"."ISMS_SubjectName" || ':' || CEILING(SUM("SG"."ESTMPPSG_GroupObtMarks"))::TEXT || '/' || CEILING(SUM("SG"."ESTMPPSG_GroupMaxMarks"))::TEXT) AS "SMS",
            ('TOTAL :' || CEILING(v_Totalobtmarks)::TEXT || '/' || CEILING(v_Totalmaxmarks)::TEXT) AS "Total",
            ROUND(((v_Totalobtmarks / v_Totalmaxmarks) * 100), 2) AS "Percentage",
            "MS"."ISMS_Id"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" "MPS"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" "SG" ON "MPS"."ESTMPPS_Id" = "SG"."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" "MSG" ON "MSG"."EMPSG_Id" = "SG"."EMPSG_Id" AND "EMPSG_ActiveFlag" = 1
        INNER JOIN "IVRM_Master_Subjects" "MS" ON "MS"."ISMS_Id" = "MPS"."ISMS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "PS" ON "PS"."EMPS_Id" = "MSG"."EMPS_Id" AND "MS"."ISMS_Id" = "PS"."ISMS_Id" AND "PS"."EMPS_ActiveFlag" = 1
        INNER JOIN "Exm"."Exm_M_Promotion" "MP" ON "MP"."EMP_Id" = "PS"."EMP_Id" AND "MP"."EMP_ActiveFlag" = 1 AND "MP"."EYC_Id" = v_EYC_ID
        INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_ID" = "MPS"."AMST_ID"
        WHERE "MPS"."ASMAY_Id" = "ASMAY_ID"::BIGINT 
            AND "MPS"."MI_Id" = "MI_ID"::BIGINT 
            AND "MPS"."ASMCL_Id" = "ASMCL_ID"::BIGINT 
            AND "MPS"."ASMS_Id" = "ASMS_ID"::BIGINT
            AND "MPS"."AMST_Id" = v_AMST_ID
        GROUP BY "MPS"."AMST_ID", "MS"."ISMS_SubjectName", "AMS"."AMST_AdmNo", "AMS"."AMST_MobileNo", "MS"."ISMS_Id",
            "AMS"."AMST_emailId", CONCAT(COALESCE("AMS"."AMST_Firstname", ''), ' ', COALESCE("AMS"."AMST_Middlename", ''), ' ', COALESCE("AMS"."AMST_Lastname", ''))
        ORDER BY "MS"."ISMS_Id";
        
    END LOOP;
    
    RETURN QUERY SELECT * FROM "Temp_Amst_id_SMS";
    
END;
$$;