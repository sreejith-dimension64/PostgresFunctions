CREATE OR REPLACE FUNCTION "dbo"."DON_BBHS_Student_SubjectWise_Details_Ind"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_AMST_Id TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "EME_Id" BIGINT,
    "EMPSG_GroupName" VARCHAR,
    "EMPSG_DisplayName" VARCHAR,
    "ObtainedMarks" NUMERIC,
    "TotalPercentage" NUMERIC(18,2),
    "ESTMPP_SectionRank" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_EYC_Id BIGINT;
    v_EMCA_Id BIGINT;
    v_EMP_Id BIGINT;
    v_ExmConfig_RankingMethod VARCHAR(50);
    v_grp_name VARCHAR;
    v_EME_Id BIGINT;
    rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "stthomos_temp_Section_Calculation";

    SELECT "ExmConfig_RankingMethod" INTO v_ExmConfig_RankingMethod 
    FROM "Exm"."Exm_Configuration" 
    WHERE "MI_Id" = p_MI_Id::BIGINT;

    SELECT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "ASMCL_Id" = p_ASMCL_Id::BIGINT 
        AND "ASMS_Id" = p_ASMS_Id::BIGINT
        AND "ECAC_ActiveFlag" = 1;

    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "ASMAY_Id" = p_ASMAY_Id::BIGINT 
        AND "EMCA_Id" = v_EMCA_Id 
        AND "EYC_ActiveFlg" = 1;

    SELECT "EMP_Id" INTO v_EMP_Id 
    FROM "Exm"."Exm_M_Promotion" 
    WHERE "MI_Id" = p_MI_Id::BIGINT 
        AND "EMP_ActiveFlag" = 1 
        AND "EYC_Id" = v_EYC_Id;

    CREATE TEMP TABLE "stthomos_temp_Section_Calculation" AS
    SELECT * FROM (
        SELECT 
            "EME_Id",
            "EMPSG_GroupName",
            "EMPSG_DisplayName",
            "AMST_Id",
            SUM("ObtainedMarks") AS "ObtainedMarks",
            CAST((SUM("ObtainedMarks") / SUM("EMPS_ConvertForMarks") * 100) AS NUMERIC(18,2)) AS "TotalPercentage",
            "ESTMPP_SectionRank"
        FROM (
            SELECT 
                9800000 AS "EME_Id",
                "EMPSG_GroupName",
                "EMPSG_DisplayName",
                C."AMST_Id",
                (CASE WHEN "EMPS_ConvertForMarks" = "EMPS_MaxMarks" 
                    THEN B."ESTMPPSG_GroupObtMarks" 
                    ELSE B."ESTMPPSG_GroupObtMarks" / 2 
                END) AS "ObtainedMarks",
                "EMPS_ConvertForMarks",
                0 AS "ESTMPP_SectionRank",
                C."ISMS_Id"
            FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" C ON C."ESTMPPS_Id" = B."ESTMPPS_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" F ON F."EMPSG_Id" = B."EMPSG_Id" AND "EMPSG_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" G ON G."EMPS_Id" = F."EMPS_Id" AND "EMPS_AppToResultFlg" = 1 AND "EMPS_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_M_Promotion" H ON H."EMP_Id" = G."EMP_Id" AND "EMP_ActiveFlag" = 1 AND "EYC_Id" = v_EYC_Id
            INNER JOIN "Exm"."Exm_Student_MP_Promotion" I ON I."ASMAY_Id" = C."ASMAY_Id" AND I."ASMCL_Id" = C."ASMCL_Id" AND I."ASMS_Id" = C."ASMS_Id" AND I."AMST_Id" = C."AMST_Id"
            WHERE C."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND C."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                AND C."ASMS_Id" = p_ASMS_Id::BIGINT
                AND I."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND I."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                AND I."ASMS_Id" = p_ASMS_Id::BIGINT
        ) AS z
        GROUP BY "EMPSG_GroupName", "EMPSG_DisplayName", "AMST_Id", "ESTMPP_SectionRank", "EME_Id"

        UNION

        SELECT 
            "EME_Id",
            "EMPSG_GroupName",
            "EMPSG_DisplayName",
            "AMST_Id",
            SUM("ObtainedMarks") AS "ObtainedMarks",
            CAST((SUM("ObtainedMarks") / SUM("EMPS_ConvertForMarks") * 100) AS NUMERIC(18,2)) AS "TotalPercentage",
            "ESTMPP_SectionRank"
        FROM (
            SELECT 
                9800001 AS "EME_Id",
                C."EMPSG_GroupName",
                C."EMPSG_DisplayName",
                M."AMST_Id",
                (CASE WHEN "EMPS_ConvertForMarks" = "EMPS_MaxMarks" 
                    THEN M."ESTMPPSG_GroupObtMarks" 
                    ELSE M."ESTMPPSG_GroupObtMarks" / 2 
                END) AS "ObtainedMarks",
                M."ESTMPPSG_GroupObtMarks",
                "EMPS_ConvertForMarks",
                0 AS "ESTMPP_SectionRank",
                M."ISMS_Id"
            FROM "stjames_temp_promotion_details" M
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" A ON M."AMST_Id" = A."AMST_Id" AND A."ISMS_Id" = M."ISMS_Id"
                AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT 
                AND A."ASMS_Id" = p_ASMS_Id::BIGINT
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" B ON A."ESTMPPS_Id" = B."ESTMPPS_Id"
            INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subject_Groupwise_Exam" B1 ON B1."ESTMPPSG_Id" = B."ESTMPPSG_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPSG_Id" = B."EMPSG_Id" AND M."EMPSG_DisplayName" = C."EMPSG_DisplayName"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id" = C."EMPSG_Id"
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" E ON E."EMPS_Id" = C."EMPS_Id" AND M."ISMS_Id" = E."ISMS_Id" 
                AND E."EMPS_AppToResultFlg" = 1 AND E."EMP_Id" = v_EMP_Id
            INNER JOIN "Exm"."Exm_M_Promotion" F ON F."EMP_Id" = E."EMP_Id"
            INNER JOIN "IVRM_Master_Subjects" G ON G."ISMS_Id" = A."ISMS_Id" AND G."ISMS_Id" = E."ISMS_Id"
            INNER JOIN "Exm"."Exm_Master_Exam" H ON H."EME_Id" = D."EME_Id" AND B1."EME_Id" = H."EME_Id"
            WHERE A."MI_Id" = p_MI_Id::BIGINT 
                AND M."EMPSG_GroupName" != 'Final Average'
                AND A."ASMAY_Id" = p_ASMAY_Id::BIGINT 
                AND A."ASMCL_Id" = p_ASMCL_Id::BIGINT
                AND A."ASMS_Id" = p_ASMS_Id::BIGINT
                AND F."EYC_Id" = v_EYC_Id 
                AND M."complusoryflag" != 'C'
            GROUP BY C."EMPSG_GroupName", C."EMPSG_DisplayName", M."AMST_Id", M."ISMS_Id", 
                M."ESTMPPSG_GroupObtMarks", E."EMPS_ConvertForMarks", E."EMPS_MaxMarks", M."ESG_Id"
        ) AS d
        GROUP BY "EMPSG_GroupName", "EMPSG_DisplayName", "AMST_Id", "ESTMPP_SectionRank", "EME_Id"
    ) AS D
    ORDER BY "AMST_Id";

    IF (v_ExmConfig_RankingMethod = 'Dense') THEN
        FOR rec IN 
            SELECT DISTINCT "EMPSG_GroupName", "EME_Id" 
            FROM "stthomos_temp_Section_Calculation"
        LOOP
            v_grp_name := rec."EMPSG_GroupName";
            v_EME_Id := rec."EME_Id";

            WITH "Section_Rank" AS (
                SELECT 
                    "AMST_Id",
                    "ObtainedMarks",
                    DENSE_RANK() OVER(ORDER BY "ObtainedMarks" DESC) AS "SRK"
                FROM "stthomos_temp_Section_Calculation"
                WHERE "EME_Id" = v_EME_Id AND "EMPSG_GroupName" = v_grp_name
            )
            UPDATE "stthomos_temp_Section_Calculation" P
            SET "ESTMPP_SectionRank" = S."SRK"
            FROM "Section_Rank" S
            WHERE P."AMST_Id" = S."AMST_Id" 
                AND P."EMPSG_GroupName" = v_grp_name
                AND P."EME_Id" = v_EME_Id;
        END LOOP;

    ELSIF (v_ExmConfig_RankingMethod = 'Standard') THEN
        FOR rec IN 
            SELECT DISTINCT "EMPSG_GroupName", "EME_Id" 
            FROM "stthomos_temp_Section_Calculation"
        LOOP
            v_grp_name := rec."EMPSG_GroupName";
            v_EME_Id := rec."EME_Id";

            WITH "Section_Rank" AS (
                SELECT 
                    "AMST_Id",
                    "ObtainedMarks",
                    RANK() OVER(ORDER BY "ObtainedMarks" DESC) AS "SRK"
                FROM "stthomos_temp_Section_Calculation"
                WHERE "EME_Id" = v_EME_Id AND "EMPSG_GroupName" = v_grp_name
            )
            UPDATE "stthomos_temp_Section_Calculation" P
            SET "ESTMPP_SectionRank" = S."SRK"
            FROM "Section_Rank" S
            WHERE P."AMST_Id" = S."AMST_Id" 
                AND P."EMPSG_GroupName" = v_grp_name
                AND P."EME_Id" = v_EME_Id;
        END LOOP;
    END IF;

    RETURN QUERY
    SELECT 
        a."AMST_Id",
        a."EME_Id",
        a."EMPSG_GroupName",
        a."EMPSG_DisplayName",
        a."ObtainedMarks",
        a."TotalPercentage",
        a."ESTMPP_SectionRank"
    FROM "stthomos_temp_Section_Calculation" a
    WHERE a."AMST_Id" IN (
        SELECT CAST(UNNEST(string_to_array(p_AMST_Id, ',')) AS BIGINT)
    );

    DROP TABLE IF EXISTS "stthomos_temp_Section_Calculation";

END;
$$;