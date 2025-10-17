CREATE OR REPLACE FUNCTION "dbo"."insert_student_in_temp"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "Examdate" date,
    "time_slot" bigint,
    "AMCO_Id" bigint,
    "ESAETT_Id" bigint,
    "EME_Id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "amb_id" bigint;
    "amb_name" varchar(100);
    "amse_name" varchar(50);
    "amse_id" bigint;
    "ems_name" varchar(50);
    "ISMS_Id" bigint;
    "AMCST_Id" bigint;
    exam_rec RECORD;
    student_rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "temp_student_details";

    CREATE TEMP TABLE "temp_student_details"(
        "AMCST_Id" bigint,
        "AMCO_Id" bigint,
        "AMB_Id" bigint,
        "AMSE_Id" bigint,
        "ISMS_Id" bigint,
        "EXT_DATE" timestamp,
        "EMT_Id" bigint,
        "Alot_flag" boolean
    );

    FOR exam_rec IN
        SELECT MB."AMB_Id", MB."AMB_BranchName", MS."AMSE_id", MS."AMSE_SEMName", ETTD."ISMS_Id", CSS."ACSS_SchmeName"
        FROM "dbo"."Exam_SA_ETT" ETT
        INNER JOIN "Exam_SA_ETT_Details" ETTD ON ETT."ESAETT_Id" = ETTD."ESAETT_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" MB ON MB."AMB_Id" = ETT."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" MS ON MS."AMSE_Id" = ETT."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_SubjectScheme_AY" SSAY ON SSAY."ACSS_Id" = ETTD."ACSS_Id" 
            AND ETT."ASMAY_Id" = ETT."ASMAY_Id" 
            AND ETT."MI_Id" = SSAY."MI_Id" 
            AND "ACST_ActiveFlg" = 1
        INNER JOIN "CLG"."Adm_College_SubjectScheme" CSS ON CSS."ACSS_Id" = SSAY."ACSS_Id" 
            AND CSS."MI_Id" = "MI_Id"
        WHERE "ESAETT_ExamDate" = "Examdate" 
            AND ETT."ASMAY_Id" = "ASMAY_Id" 
            AND ETTD."ESAESLOT_Id" = "time_slot" 
            AND ETT."ESAETT_Id" = "ESAETT_Id" 
            AND "EME_Id" = "EME_Id" 
            AND ETT."AMCO_Id" = "AMCO_Id"
    LOOP
        "amb_id" := exam_rec."AMB_Id";
        "amb_name" := exam_rec."AMB_BranchName";
        "amse_id" := exam_rec."AMSE_id";
        "amse_name" := exam_rec."AMSE_SEMName";
        "ISMS_Id" := exam_rec."ISMS_Id";
        "ems_name" := exam_rec."ACSS_SchmeName";

        RAISE NOTICE '%', "amb_id";
        RAISE NOTICE '%', "amb_name";
        RAISE NOTICE '%', "amse_id";
        RAISE NOTICE '%', "amse_name";
        RAISE NOTICE '%', "ISMS_Id";
        RAISE NOTICE '%', "ems_name";

        FOR student_rec IN
            SELECT YS."AMCST_Id", ETTD."ISMS_Id"
            FROM "clg"."Adm_College_Yearly_Student" YS
            INNER JOIN "clg"."Adm_Master_College_Student" MS ON YS."AMCST_Id" = MS."AMCST_Id"
            INNER JOIN "CLG"."Adm_Master_Branch" MB ON MB."AMB_Id" = YS."AMB_Id"
            INNER JOIN "CLG"."Adm_Master_Semester" MSE ON MSE."AMSE_Id" = YS."AMSE_Id"
            INNER JOIN "Exam_SA_ETT" ETT ON ETT."AMCO_Id" = YS."AMCO_Id" 
                AND ETT."AMB_Id" = YS."AMB_Id" 
                AND ETT."AMSE_Id" = YS."AMSE_Id"
            INNER JOIN "Exam_SA_ETT_Details" ETTD ON ETTD."ESAETT_Id" = ETTD."ESAETT_Id"
            WHERE YS."ASMAY_Id" = "ASMAY_Id" 
                AND YS."AMCO_Id" = "AMCO_Id" 
                AND ETTD."ISMS_Id" = "ISMS_Id" 
                AND YS."AMB_Id" = "amb_id" 
                AND YS."AMSE_Id" = "amse_id" 
                AND YS."ACYST_ActiveFlag" = 1 
                AND MS."AMCST_ActiveFlag" = 1
                AND MS."AMCST_SOL" = 'S' 
                AND ETTD."ESAESLOT_Id" = "time_slot" 
                AND ETTD."ESAETT_ExamDate" = "Examdate"
                AND YS."AMCST_Id" IN (
                    SELECT DISTINCT "AMCST_Id" 
                    FROM "Exam_SA_Allotted_Student" 
                    WHERE "AMCO_Id" = "AMCO_Id" 
                        AND "AMB_Id" = "amb_id" 
                        AND "AMSE_Id" = "amse_id" 
                        AND "ISMS_Id" = "ISMS_Id" 
                        AND "ESAESLOT_Id" = "time_slot" 
                        AND "ESAALLSTU_ExamDate" = "Examdate"
                )
        LOOP
            "AMCST_Id" := student_rec."AMCST_Id";
            "ISMS_Id" := student_rec."ISMS_Id";

            RAISE NOTICE '%', "AMCST_Id";
            RAISE NOTICE '%', "amb_id";
            RAISE NOTICE '%', "amse_id";
            RAISE NOTICE '%', "ISMS_Id";
            RAISE NOTICE '%', "Examdate";
            RAISE NOTICE '%', "time_slot";

            IF "AMCST_Id" <> 0 THEN
                INSERT INTO "temp_student_details" (
                    "AMCST_Id", "AMCO_Id", "AMB_Id", "AMSE_Id", "ISMS_Id", "EXT_DATE", "EMT_Id", "Alot_flag"
                )
                VALUES (
                    "AMCST_Id", "AMCO_Id", "amb_id", "amse_id", "ISMS_Id", "Examdate", "time_slot", false
                );
            END IF;

        END LOOP;

    END LOOP;

    RETURN;

END;
$$;