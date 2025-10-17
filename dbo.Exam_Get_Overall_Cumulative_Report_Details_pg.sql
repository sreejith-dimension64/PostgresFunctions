CREATE OR REPLACE FUNCTION "dbo"."Exam_Get_Overall_Cumulative_Report_Details"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@FLAG" TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "studentname" TEXT,
    "admno" VARCHAR,
    "rollno" BIGINT,
    "classname" VARCHAR,
    "sectionname" VARCHAR,
    "fathername" TEXT,
    "mothername" TEXT,
    "dob" TEXT,
    "mobileno" BIGINT,
    "address" TEXT,
    "photoname" VARCHAR,
    "SPCCMH_HouseName" VARCHAR,
    "ISMS_Id" BIGINT,
    "ISMS_SubjectName" VARCHAR,
    "EMPSG_GroupName" TEXT,
    "ESTMPPSG_GroupMaxMarks" NUMERIC,
    "ESTMPPSG_GroupObtMarks" NUMERIC,
    "EMPS_SubjOrder" INT,
    "EMPS_AppToResultFlg" BOOLEAN,
    "ESTMPPSG_GroupObtGrade" VARCHAR,
    "grporder" BIGINT,
    "ESTMPPS_PassFailFlg" VARCHAR,
    "EMPSG_DisplayName" TEXT,
    "ESG_Id" BIGINT,
    "subjectgrporder" BIGINT,
    "complusoryflag" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@EYC_Id" BIGINT;
    "@EMCA_Id" BIGINT;
    "@complosry" TEXT;
    "@complosryflag" TEXT;
    "@ESG_Idnew" BIGINT;
    "@ISMS_Id_Old" BIGINT;
    "@ISMS_Id" BIGINT;
    "@ESG_SubjectGroupName" TEXT;
    "@ESG_Id" INT;
    "@ESG_Count" INT;
    "@ordercount" INT;
    "@Countrow" INT;
    "@ESTMPPSG_GroupMaxMarks" NUMERIC(18,2);
    "@ESTMPPSG_GroupObtMarks" NUMERIC(18,2);
    "@EMPSG_GroupName" TEXT;
    "@EMPSG_DisplayName" TEXT;
    "@amst_id" BIGINT;
    "@ISMS_Id_Avg" BIGINT;
    "@ESG_SubjectGroupName_Avg" TEXT;
    "@ESG_Id_Avg" INT;
    "@ESG_Count_Avg" INT;
    "@ordercount_Avg" INT;
    "@Countrow_Avg" INT;
    "@ESTMPPSG_GroupMaxMarks_AVG" NUMERIC(18,2);
    "@ESTMPPSG_GroupObtMarks_AVG" NUMERIC(18,2);
    "@EMPSG_GroupName_AVG" TEXT;
    "@EMPSG_DisplayName_AVG" TEXT;
    "@amst_id_AVG" BIGINT;
    rec RECORD;
BEGIN
    IF "@FLAG" = '1' THEN
        RETURN QUERY
        SELECT DISTINCT 
            A."AMST_Id",
            (CASE WHEN A."AMST_FirstName" IS NULL OR A."AMST_FirstName" = '' THEN '' ELSE A."AMST_FirstName" END || 
            CASE WHEN A."AMST_MiddleName" IS NULL OR A."AMST_MiddleName" = '' THEN '' ELSE ' ' || A."AMST_MiddleName" END ||
            CASE WHEN A."AMST_LastName" IS NULL OR A."AMST_LastName" = '' THEN '' ELSE ' ' || A."AMST_LastName" END)::TEXT AS studentname,
            A."AMST_AdmNo" AS admno,
            B."AMAY_RollNo" AS rollno,
            D."ASMCL_ClassName" AS classname,
            E."ASMC_SectionName" AS sectionname,
            (CASE WHEN A."AMST_FatherName" IS NULL OR A."AMST_FatherName" = '' THEN '' ELSE A."AMST_FatherName" END || 
            CASE WHEN A."AMST_FatherSurname" IS NULL OR A."AMST_FatherSurname" = '' THEN '' ELSE ' ' || A."AMST_FatherSurname" END)::TEXT AS fathername,
            (CASE WHEN A."AMST_MotherName" IS NULL OR A."AMST_MotherName" = '' THEN '' ELSE A."AMST_MotherName" END || 
            CASE WHEN A."AMST_MotherSurname" IS NULL OR A."AMST_MotherSurname" = '' THEN '' ELSE ' ' || A."AMST_MotherSurname" END)::TEXT AS mothername,
            TO_CHAR(A."amst_dob", 'DD/MM/YYYY')::TEXT AS dob,
            A."AMST_MobileNo" AS mobileno,
            (CASE WHEN A."AMST_PerStreet" IS NULL OR A."AMST_PerStreet" = '' THEN '' ELSE A."AMST_PerStreet" END || 
            CASE WHEN A."AMST_PerArea" IS NULL OR A."AMST_PerArea" = '' THEN '' ELSE ',' || A."AMST_PerArea" END || 
            CASE WHEN A."AMST_PerCity" IS NULL OR A."AMST_PerCity" = '' THEN '' ELSE ',' || A."AMST_PerCity" END || 
            CASE WHEN A."AMST_PerAdd3" IS NULL OR A."AMST_PerAdd3" = '' THEN '' ELSE ',' || A."AMST_PerAdd3" END)::TEXT AS address,
            A."AMST_Photoname" AS photoname,
            I."SPCCMH_HouseName",
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::TEXT,
            NULL::NUMERIC,
            NULL::NUMERIC,
            NULL::INT,
            NULL::BOOLEAN,
            NULL::VARCHAR,
            NULL::BIGINT,
            NULL::VARCHAR,
            NULL::TEXT,
            NULL::BIGINT,
            NULL::BIGINT,
            NULL::TEXT
        FROM "Adm_M_Student" A 
        INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id" = B."ASMS_Id"
        LEFT JOIN "SPC"."SPCC_Student_House" H ON H."AMST_Id" = B."AMST_Id" AND H."ASMAY_Id" = "@ASMAY_Id"::BIGINT AND H."ASMCL_Id" = "@ASMCL_Id"::BIGINT AND H."ASMS_Id" = "@ASMS_Id"::BIGINT AND H."SPCCMH_ActiveFlag" = 1
        LEFT JOIN "SPC"."SPCC_Master_House" I ON I."SPCCMH_Id" = H."SPCCMH_Id" AND I."SPCCMH_ActiveFlag" = 1 AND I."MI_Id" = 1
        WHERE A."MI_Id" = "@MI_Id"::BIGINT AND B."ASMAY_Id" = "@ASMAY_Id"::BIGINT AND B."ASMCL_Id" = "@ASMCL_Id"::BIGINT AND B."ASMS_Id" = "@ASMS_Id"::BIGINT
        AND B."AMAY_ActiveFlag" = 1 AND A."AMST_SOL" = 'S' AND A."AMST_ActiveFlag" = 1
        ORDER BY rollno;

    ELSIF "@FLAG" = '2' THEN
        DROP TABLE IF EXISTS "stjames_temp_cumulative_promotion_details";

        SELECT DISTINCT "@EMCA_Id" = "EMCA_Id" INTO "@EMCA_Id" FROM "Exm"."Exm_Category_Class" 
        WHERE "MI_Id" = "@MI_Id"::BIGINT AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT AND "ASMCL_Id" = "@ASMCL_Id"::BIGINT AND "ASMS_Id" = "@ASMS_Id"::BIGINT AND "ECAC_ActiveFlag" = 1;

        SELECT DISTINCT "@EYC_Id" = "EYC_Id" INTO "@EYC_Id" FROM "Exm"."Exm_Yearly_Category" 
        WHERE "MI_Id" = "@MI_Id"::BIGINT AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT AND "EYC_ActiveFlg" = 1;

        CREATE TEMP TABLE "stjames_temp_cumulative_promotion_details" AS
        SELECT * FROM (
            SELECT DISTINCT 
                MPS."AMST_Id", MPS."ISMS_Id", MS."ISMS_SubjectName", MSG."EMPSG_GroupName",
                SG."ESTMPPSG_GroupMaxMarks", SG."ESTMPPSG_GroupObtMarks", PS."EMPS_SubjOrder", PS."EMPS_AppToResultFlg", 
                SG."ESTMPPSG_GroupObtGrade", MSG."EMPSG_Order" AS grporder, ''::VARCHAR AS "ESTMPPS_PassFailFlg", MSG."EMPSG_DisplayName"
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" MPS
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" SG ON MPS."ESTMPPS_Id" = SG."ESTMPPS_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" MSG ON MSG."EMPSG_Id" = SG."EMPSG_Id" AND MSG."EMPSG_ActiveFlag" = 1
            INNER JOIN "IVRM_Master_Subjects" MS ON MS."ISMS_Id" = MPS."ISMS_Id"
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" PS ON PS."EMPS_Id" = MSG."EMPS_Id" AND MS."ISMS_Id" = PS."ISMS_Id" AND PS."EMPS_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_M_Promotion" MP ON MP."EMP_Id" = PS."EMP_Id" AND MP."EMP_ActiveFlag" = 1 AND MP."EYC_Id" = 85
            WHERE MPS."ASMAY_Id" = "@ASMAY_Id"::BIGINT AND MPS."MI_Id" = "@MI_Id"::BIGINT AND MPS."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND MPS."ASMS_Id" = "@ASMS_Id"::BIGINT AND MPS."AMST_Id" = 19202
            ORDER BY PS."EMPS_SubjOrder"
            LIMIT 100

            UNION

            SELECT DISTINCT 
                MPS."AMST_Id", MPS."ISMS_Id", MS."ISMS_SubjectName", 'Final Average'::TEXT AS "EMPSG_GroupName",
                MPS."ESTMPPS_MaxMarks" AS "ESTMPPSG_GroupMaxMarks", MPS."ESTMPPS_ObtainedMarks" AS "ESTMPPSG_GroupObtMarks", 
                PS."EMPS_SubjOrder", PS."EMPS_AppToResultFlg", MPS."ESTMPPS_ObtainedGrade" AS "ESTMPPSG_GroupObtGrade", 
                1001 AS grporder, MPS."ESTMPPS_PassFailFlg", 'Final Average'::TEXT AS "EMPSG_DisplayName"
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" MPS
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" SG ON MPS."ESTMPPS_Id" = SG."ESTMPPS_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" MSG ON MSG."EMPSG_Id" = SG."EMPSG_Id" AND MSG."EMPSG_ActiveFlag" = 1
            INNER JOIN "IVRM_Master_Subjects" MS ON MS."ISMS_Id" = MPS."ISMS_Id"
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" PS ON PS."EMPS_Id" = MSG."EMPS_Id" AND MS."ISMS_Id" = PS."ISMS_Id" AND PS."EMPS_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_M_Promotion" MP ON MP."EMP_Id" = PS."EMP_Id" AND MP."EMP_ActiveFlag" = 1 AND MP."EYC_Id" = 85
            WHERE MPS."ASMAY_Id" = "@ASMAY_Id"::BIGINT AND MPS."MI_Id" = "@MI_Id"::BIGINT AND MPS."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND MPS."ASMS_Id" = "@ASMS_Id"::BIGINT AND MPS."AMST_Id" = 19202
            ORDER BY "EMPS_SubjOrder"
            LIMIT 100
        ) AS t
        ORDER BY "EMPS_SubjOrder", grporder;

        ALTER TABLE "stjames_temp_cumulative_promotion_details" ADD COLUMN "ESG_Id" BIGINT;
        ALTER TABLE "stjames_temp_cumulative_promotion_details" ADD COLUMN "subjectgrporder" BIGINT;
        ALTER TABLE "stjames_temp_cumulative_promotion_details" ADD COLUMN "complusoryflag" TEXT;

        UPDATE "stjames_temp_cumulative_promotion_details" SET "ESG_Id" = 0;
        UPDATE "stjames_temp_cumulative_promotion_details" SET "subjectgrporder" = 0;
        UPDATE "stjames_temp_cumulative_promotion_details" SET "complusoryflag" = '';

        FOR rec IN 
            SELECT DISTINCT "ISMS_Id" FROM "stjames_temp_cumulative_promotion_details"
        LOOP
            "@ISMS_Id_Old" := rec."ISMS_Id";
            "@complosry" := '';
            "@complosryflag" := '';
            "@ESG_Idnew" := 0;

            SELECT DISTINCT a."ESG_CompulsoryFlag", a."ESG_Id" INTO "@complosry", "@ESG_Idnew"
            FROM "exm"."Exm_Subject_Group" a
            INNER JOIN "exm"."Exm_Subject_Group_Subjects" c ON a."ESG_Id" = c."ESG_Id"
            WHERE a."ASMAY_Id" = "@ASMAY_Id"::BIGINT AND a."MI_Id" = "@MI_Id"::BIGINT AND a."EMCA_Id" = "@EMCA_Id" 
            AND a."ESG_ExamPromotionFlag" != 'IE' AND c."ISMS_Id" = "@ISMS_Id_Old"
            AND a."ESG_ActiveFlag" = 1 AND c."ESGS_ActiveFlag" = 1;

            IF "@complosry" = 'Y' OR "@complosry" = 'N' THEN
                "@complosryflag" := 'C';
            ELSE
                "@complosryflag" := '';
            END IF;

            UPDATE "stjames_temp_cumulative_promotion_details" 
            SET "ESG_Id" = "@ESG_Idnew", "complusoryflag" = "@complosryflag" 
            WHERE "ISMS_Id" = "@ISMS_Id_Old";
        END LOOP;

        "@ordercount" := 10001;

        FOR rec IN 
            SELECT a."ESG_SubjectGroupName", a."ESG_Id", COUNT(DISTINCT b."ISMS_Id") AS countdetails
            FROM "Exm"."Exm_Subject_Group" a 
            INNER JOIN "Exm"."Exm_Subject_Group_Subjects" b ON a."ESG_Id" = b."ESG_Id"
            INNER JOIN "IVRM_Master_Subjects" c ON c."ISMS_Id" = b."ISMS_Id"
            INNER JOIN "Exm"."Exm_Category_Class" d ON d."EMCA_Id" = a."EMCA_Id"
            WHERE a."ESG_ExamPromotionFlag" = 'PE' AND a."ASMAY_Id" = "@ASMAY_Id"::BIGINT AND d."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND d."ASMCL_Id" = "@ASMCL_Id"::BIGINT AND d."ASMS_Id" = "@ASMS_Id"::BIGINT
            AND a."ESG_ActiveFlag" = 1 AND b."ESGS_ActiveFlag" = 1 AND d."ECAC_ActiveFlag" = 1 
            AND d."MI_Id" = "@MI_Id"::BIGINT AND a."MI_Id" = "@MI_Id"::BIGINT
            GROUP BY a."ESG_SubjectGroupName", a."ESG_Id"
        LOOP
            "@ESG_SubjectGroupName" := rec."ESG_SubjectGroupName";
            "@ESG_Id" := rec."ESG_Id";
            "@ESG_Count" := rec.countdetails;
            "@Countrow" := 0;

            SELECT COUNT(*) INTO "@Countrow" FROM "stjames_temp_cumulative_promotion_details" 
            WHERE "ISMS_SubjectName" = "@ESG_SubjectGroupName";

            IF "@Countrow" > 0 THEN
                SELECT "subjectgrporder" INTO "@ordercount" FROM "stjames_temp_cumulative_promotion_details" 
                WHERE "ISMS_SubjectName" = "@ESG_SubjectGroupName" LIMIT 1;
            ELSE
                "@ordercount" := "@ordercount" + 1;
            END IF;

            FOR rec IN 
                SELECT (SUM(b."ESTMPPSG_GroupMaxMarks") / "@ESG_Count") AS "ESTMPPSG_GroupMaxMarks", 
                       (SUM(b."ESTMPPSG_GroupObtMarks") / "@ESG_Count") AS "ESTMPPSG_GroupObtMarks",
                       c."EMPSG_GroupName", a."AMST_Id", c."EMPSG_DisplayName"
                FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" a
                INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" b ON a."ESTMPPS_Id" = b."ESTMPPS_Id"
                INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" c ON c."EMPSG_Id" = b."EMPSG_Id"
                WHERE a."ISMS_Id" IN (
                    SELECT b."ISMS_Id" FROM "Exm"."Exm_Subject_Group" a 
                    INNER JOIN "Exm"."Exm_Subject_Group_Subjects" b ON a."ESG_Id" = b."ESG_Id"
                    INNER JOIN "IVRM_Master_Subjects" c ON c."ISMS_Id" = b."ISMS_Id"
                    INNER JOIN "Exm"."Exm_Category_Class" d ON d."EMCA_Id" = a."EMCA_Id"
                    WHERE a."ESG_ExamPromotionFlag" = 'PE' AND a."ASMAY_Id" = "@ASMAY_Id"::BIGINT AND d."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
                    AND d."ASMCL_Id" = "@ASMCL_Id"::BIGINT AND d."ASMS_Id" = "@ASMS_Id"::BIGINT
                    AND a."ESG_ActiveFlag" = 1 AND b."ESGS_ActiveFlag" = 1 AND d."ECAC_ActiveFlag" = 1 
                    AND d."MI_Id" = "@MI_Id"::BIGINT AND a."MI_Id" = "@MI_Id"::BIGINT AND a."ESG_Id" = "@ESG_Id"
                )
                AND a."ASMAY_Id" = "@ASMAY_Id"::BIGINT AND a."ASMCL_Id" = "@ASMCL_Id"::BIGINT AND a."ASMS_Id" = "@ASMS_Id"::BIGINT
                GROUP BY c."EMPSG_GroupName", a."AMST_Id", c."EMPSG_DisplayName"
            LOOP
                "@ESTMPPSG_GroupMaxMarks" := rec."ESTMPPSG_GroupMaxMarks";
                "@ESTMPPSG_GroupObtMarks" := rec."ESTMPPSG_GroupObtMarks";
                "@EMPSG_GroupName" := rec."EMPSG_GroupName";
                "@amst_id" := rec."AMST_Id";
                "@EMPSG_DisplayName" := rec."EMPSG_DisplayName";

                INSERT INTO "stjames_temp_cumulative_promotion_details" (
                    "AMST_Id", "ISMS_Id", "ISMS_SubjectName", "EMPSG_GroupName", "ESTMPPSG_GroupMaxMarks", 
                    "ESTMPPSG_GroupObtMarks", "EMPS_SubjOrder", "EMPS_AppToResultFlg", "ESTMPPSG_GroupObtGrade", 
                    "grporder", "ESG_Id", "subjectgrporder", "complusoryflag", "EMPSG_DisplayName"
                ) VALUES (
                    "@amst_id", 2, "@ESG_SubjectGroupName", "@EMPSG_GroupName", "@ESTMPPSG_GroupMaxMarks",
                    "@ESTMPPSG_GroupObtMarks", "@ordercount", TRUE, '', "@ordercount", "@ESG_Id", "@ordercount", 'B', "@EMPSG_DisplayName"
                );
            END LOOP;
        END LOOP;

        "@ordercount_Avg" := 10001;

        FOR rec IN 
            SELECT a."ESG_SubjectGroupName", a."ESG_Id", COUNT(DISTINCT b."ISMS_Id") AS countdetails
            FROM "Exm"."Exm_Subject_Group" a 
            INNER JOIN "Exm"."Exm_Subject_Group_Subjects" b ON a."ESG_Id" = b."ESG_Id"
            INNER JOIN "IVRM_Master_Subjects" c ON c."ISMS_Id" = b."ISMS_Id"
            INNER JOIN "Exm"."Exm_Category_Class" d ON d."EMCA_Id" = a."EMCA_Id"
            WHERE a."ESG_ExamPromotionFlag" = 'PE' AND a."ASMAY_Id" = "@ASMAY_Id"::BIGINT AND d."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND d."ASMCL_Id" = "@ASMCL_Id"::BIGINT AND d."ASMS_Id" = "@ASMS_Id"::BIGINT
            AND a."ESG_ActiveFlag" = 1 AND b."ESGS_ActiveFlag" = 1 AND d."ECAC_ActiveFlag" = 1 
            AND d."MI_Id" = "@MI_Id"::BIGINT AND a."MI_Id" = "@MI_Id"::BIGINT
            GROUP BY a."ESG_SubjectGroupName", a."ESG_Id"
        LOOP
            "@ESG_SubjectGroupName_Avg" := rec."ESG_SubjectGroupName";
            "@ESG_Id_Avg" := rec."ESG_Id";
            "@ESG_Count_Avg" := rec.countdetails;
            "@Countrow_Avg" := 0;

            SELECT COUNT(*) INTO "@Countrow_Avg" FROM "stjames_temp_cumulative_promotion_details" 
            WHERE "ISMS_SubjectName" = "@ESG_SubjectGroupName_Avg";

            IF "@Countrow_Avg" > 0 THEN
                SELECT "subjectgrporder" INTO "@ordercount_Avg" FROM "stjames_temp_cumulative_promotion_details" 
                WHERE "ISMS_SubjectName" = "@ESG_SubjectGroupName_Avg" LIMIT 1;
            ELSE
                "@ordercount_Avg" := "@ordercount_Avg" + 1;
            END IF;

            FOR rec IN 
                SELECT (SUM("ESTMPPSG_GroupMaxMarks") / "@ESG_Count_Avg") AS "ESTMPPSG_GroupMaxMarks",
                       (SUM("ESTMPPSG_GroupObtMarks") / "@ESG_Count_Avg") AS "ESTMPPSG_GroupObtMarks",
                       "EMPSG_GroupName", "AMST_Id", "EMPSG_DisplayName"
                FROM "stjames_temp_cumulative_promotion_details" a
                WHERE a."ISMS_Id" IN (
                    SELECT b."ISMS_Id" FROM "Exm"."Exm_Subject_Group" a 
                    INNER JOIN "Exm"."Exm_Subject_Group_Subjects" b ON a."ESG_Id" = b."ESG_Id"
                    INNER JOIN "IVRM_Master_Subjects" c ON c."ISMS_Id" = b."ISMS_Id"
                    INNER JOIN "Exm"."Exm_Category_Class" d ON d."EMCA_Id" = a."EMCA_Id"
                    WHERE a."ESG_ExamPromotionFlag" = 'PE' AND a."ASMAY_Id" = "@ASMAY_Id"::BIGINT AND d."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
                    AND d."ASMCL_Id" = "@ASMCL_Id"::BIGINT AND d."ASMS_Id" = "@ASMS_Id"::BIGINT
                    AND a."ESG_ActiveFlag" = 1 AND b."ESGS_ActiveFlag" = 1 AND d."ECAC_ActiveFlag" = 1 
                    AND d."MI_Id" = "@MI_Id"::BIGINT AND a."MI_Id" = "@MI_Id"::BIGINT AND a."ESG_Id" = "@ESG_Id_Avg"
                )
                AND "EMPSG_GroupName" = 'Final Average'
                GROUP BY "EMPSG_GroupName", "AMST_Id", "EMPSG_DisplayName"
            LOOP
                "@ESTMPPSG_GroupMaxMarks_AVG" := rec."ESTMPPSG_GroupMaxMarks";
                "@ESTMPPSG_GroupObtMarks_AVG" := rec."ESTMPPSG_GroupObtMarks";
                "@EMPSG_GroupName_AVG" := rec."EMPSG_GroupName";
                "@amst_id_AVG" := rec."AMST_Id";
                "@EMPSG_DisplayName_AVG" := rec."EMPSG_DisplayName";

                INSERT INTO "stjames_temp_cumulative_promotion_details" (
                    "AMST_Id", "ISMS_Id", "ISMS_SubjectName", "EMPSG_GroupName", "ESTMPPSG_GroupMaxMarks",
                    "ESTMPPSG_GroupObtMarks", "EMPS_SubjOrder", "EMPS_AppToResultFlg", "ESTMPPSG_GroupObtGrade",
                    "grporder", "ESG_Id", "subjectgrporder", "complusoryflag", "EMPSG_DisplayName"
                ) VALUES (
                    "@amst_id_AVG", 2, "@ESG_SubjectGroupName_Avg", "@EMPSG_GroupName_AVG", "@ESTMPPSG_GroupMaxMarks_AVG",
                    "@ESTMPPSG_GroupObtMarks_AVG", "@ordercount_Avg", TRUE, '', "@ordercount_Avg", "@ESG_Id_Avg", 
                    "@ordercount_Avg", 'B', "@EMPSG_DisplayName_AVG"
                );
            END LOOP;
        END LOOP;

        RETURN QUERY
        SELECT 
            NULL::BIGINT, NULL::TEXT, NULL::VARCHAR, NULL::BIGINT, NULL::VARCHAR, NULL::VARCHAR, 
            NULL::TEXT, NULL::TEXT, NULL::TEXT, NULL::BIGINT, NULL::TEXT, NULL::VARCHAR, NULL::VARCHAR,
            "ISMS_Id", "ISMS_SubjectName", "EMPSG_GroupName", "ESTMPPSG_GroupMaxMarks", "ESTMPPSG_GroupObtMarks",
            "EMPS_SubjOrder", "EMPS_AppToResultFlg", "ESTMPPSG_GroupObtGrade", "grporder", "ESTMPPS_PassFailFlg",
            "EMPSG_DisplayName", "ESG_Id", "subjectgrporder", "complusoryflag"
        FROM "stjames_temp_cumulative_promotion_details"
        ORDER BY "EMPS_SubjOrder", "grporder";
    END IF;

    RETURN;
END;
$$;