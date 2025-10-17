CREATE OR REPLACE FUNCTION "dbo"."Exam_Cumulative_Report_SubjectWise_Condition_Vikasa_HeadBinding"(
    "@MI_Id" VARCHAR,
    "@ASMAY_Id" VARCHAR,
    "@ASMCL_Id" VARCHAR,
    "@ASMS_Id" VARCHAR,
    "@ISMS_Id" VARCHAR
)
RETURNS TABLE("MI_id" VARCHAR, "ExamName" VARCHAR)
LANGUAGE plpgsql
AS $$
DECLARE
    "@eyc_id_head" VARCHAR;
    "@EMCA_Id_head" VARCHAR;
    "@EMPSG_DisplayName_head" VARCHAR;
    "@EMPSG_Id_head" VARCHAR;
    "@EMPSG_PercentValue_head" VARCHAR;
    "@EMPSG_GroupName" VARCHAR;
    "@eme_id_head" VARCHAR;
    "@eme_name_head" VARCHAR;
    "@eme_order_head" VARCHAR;
    "@total" VARCHAR;
    "display_name_rec" RECORD;
    "exam_name_rec" RECORD;
BEGIN
    DROP TABLE IF EXISTS "temp_vikasa_exam_Head";
    
    CREATE TEMP TABLE "temp_vikasa_exam_Head" (
        "MI_id" VARCHAR,
        "ExamName" VARCHAR
    );

    SELECT DISTINCT a."EMCA_Id" INTO "@EMCA_Id_head"
    FROM "exm"."Exm_Master_Category" a 
    INNER JOIN "exm"."Exm_Category_Class" b ON a."EMCA_Id" = b."EMCA_Id" 
    WHERE b."ASMAY_Id" = "@ASMAY_Id" 
        AND b."ASMCL_Id" = "@ASMCL_Id" 
        AND b."ASMS_Id" = "@ASMS_Id" 
        AND "ECAC_ActiveFlag" = 1 
        AND a."MI_Id" = "@MI_Id" 
        AND b."MI_Id" = "@MI_Id";

    SELECT "EYC_Id" INTO "@eyc_id_head"
    FROM "exm"."Exm_Yearly_Category" 
    WHERE "ASMAY_Id" = "@ASMAY_Id" 
        AND "EMCA_Id" = "@EMCA_Id_head" 
        AND "EYC_ActiveFlg" = 1 
        AND "MI_Id" = "@MI_Id";

    FOR "display_name_rec" IN
        SELECT DISTINCT c."EMPSG_DisplayName", c."EMPSG_Id", c."EMPSG_PercentValue", c."EMPSG_GroupName"
        FROM "exm"."Exm_M_Promotion" a 
        INNER JOIN "exm"."Exm_M_Promotion_Subjects" b ON a."EMP_Id" = b."EMP_Id" 
        INNER JOIN "exm"."Exm_M_Prom_Subj_Group" c ON c."EMPS_Id" = b."EMPS_Id"
        INNER JOIN "exm"."Exm_M_Prom_Subj_Group_Exams" d ON d."EMPSG_Id" = c."EMPSG_Id"
        INNER JOIN "exm"."Exm_Yearly_Category" e ON e."EYC_Id" = a."EYC_Id"
        INNER JOIN "exm"."Exm_Master_Category" f ON f."EMCA_Id" = e."EMCA_Id" 
        WHERE a."EYC_Id" = "@eyc_id_head" 
            AND "EMP_ActiveFlag" = 1 
            AND "ISMS_Id" = "@ISMS_Id"
        ORDER BY c."EMPSG_GroupName"
    LOOP
        "@EMPSG_DisplayName_head" := "display_name_rec"."EMPSG_DisplayName";
        "@EMPSG_Id_head" := "display_name_rec"."EMPSG_Id";
        "@EMPSG_PercentValue_head" := "display_name_rec"."EMPSG_PercentValue";
        "@EMPSG_GroupName" := "display_name_rec"."EMPSG_GroupName";

        FOR "exam_name_rec" IN
            SELECT DISTINCT d."EME_Id", g."EME_ExamName", g."EME_ExamOrder"
            FROM "exm"."Exm_M_Promotion" a 
            INNER JOIN "exm"."Exm_M_Promotion_Subjects" b ON a."EMP_Id" = b."EMP_Id" 
            INNER JOIN "exm"."Exm_M_Prom_Subj_Group" c ON c."EMPS_Id" = b."EMPS_Id"
            INNER JOIN "exm"."Exm_M_Prom_Subj_Group_Exams" d ON d."EMPSG_Id" = c."EMPSG_Id"
            INNER JOIN "exm"."Exm_Yearly_Category" e ON e."EYC_Id" = a."EYC_Id"
            INNER JOIN "exm"."Exm_Master_Exam" g ON g."EME_Id" = d."EME_Id"
            INNER JOIN "exm"."Exm_Master_Category" f ON f."EMCA_Id" = e."EMCA_Id" 
            WHERE a."EYC_Id" = "@eyc_id_head" 
                AND "EMP_ActiveFlag" = 1 
                AND "ISMS_Id" = "@ISMS_Id" 
                AND c."EMPSG_Id" = "@EMPSG_Id_head" 
            ORDER BY g."EME_ExamOrder"
        LOOP
            "@eme_id_head" := "exam_name_rec"."EME_Id";
            "@eme_name_head" := "exam_name_rec"."EME_ExamName";
            "@eme_order_head" := "exam_name_rec"."EME_ExamOrder";

            INSERT INTO "temp_vikasa_exam_Head" ("MI_Id", "ExamName") 
            VALUES ("@MI_Id", REPLACE("@eme_name_head", ' ', ' '));
        END LOOP;

        INSERT INTO "temp_vikasa_exam_Head" ("MI_Id", "ExamName") 
        VALUES ("@MI_Id", REPLACE("@EMPSG_DisplayName_head" || '(' || "@EMPSG_PercentValue_head" || '%)', ' ', ' '));
    END LOOP;

    "@total" := 'Total(100%)';
    INSERT INTO "temp_vikasa_exam_Head" ("MI_Id", "ExamName") 
    VALUES ("@MI_Id", "@total");

    INSERT INTO "temp_vikasa_exam_Head" ("MI_Id", "ExamName") 
    VALUES ("@MI_Id", 'Grade');

    RETURN QUERY SELECT * FROM "temp_vikasa_exam_Head";
END;
$$;