CREATE OR REPLACE FUNCTION "dbo"."HM_DumpChartData"(
    "AMST_Id" bigint,
    "ASMAY_Id" bigint,
    "MI_Id" bigint,
    "HT_OR_WT" varchar(10)
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "std_month" bigint;
    "AyCl_id" bigint;
    "Amcl_Name" varchar(50);
    "Amay_id" int;
    "Amay_yr_Name" varchar(50);
    "Ayst_id" bigint;
    "classHighestMarks" float;
    "exam_name" varchar(50);
    "amcl_id" int;
    "eme_id" bigint;
    "totalmarks" float;
    "marksobtained" float;
    "Student_Per" float;
    "Class_Per" float;
    "classHigest" bigint;
    "maxmarks" bigint;
    "totalmarks1" bigint;
    "std_age" int;
    "std_Sex" char;
    "std_HsmValue" float;
    "std_year" varchar(20);
    "std_H" float;
    "std_W" float;
    "cls_avg" float;
    "sub_avg" float;
    "rec_student" RECORD;
    "rec_htwt" RECORD;
BEGIN

    DROP TABLE IF EXISTS "dbo"."HM_Temp_chart";

    CREATE TABLE "dbo"."HM_Temp_chart" (
        "Field1" varchar(50),
        "Field2" varchar(50),
        "Field3" numeric(18,2),
        "Field4" numeric(18,2),
        "Field5" numeric(18,2),
        "Field6" numeric(18,2)
    );

    FOR "rec_student" IN
        SELECT AMS."AMST_sex", ASMC."ASMCL_ClassName", ASMAY."ASMAY_Year", TM."HMTMES_Value",
               EXTRACT(YEAR FROM AGE(TM."HMTMES_Date", AMS."AMST_Dob"))::int AS "Cur_age"
        FROM "dbo"."Adm_M_Student" AMS
        INNER JOIN "dbo"."Adm_School_Y_Student" ASYS ON AMS."AMST_Id" = ASYS."AMST_Id"
        INNER JOIN "dbo"."Adm_School_M_Class" ASMC ON ASMC."ASMCL_Id" = ASYS."ASMCL_Id"
        INNER JOIN "dbo"."Adm_School_M_Academic_Year" ASMAY ON ASMAY."ASMAY_Id" = ASYS."ASMAY_Id"
        INNER JOIN "dbo"."Adm_School_M_Section" ASMS ON ASMS."ASMS_Id" = ASYS."ASMS_Id"
        INNER JOIN "dbo"."HM_T_Measurement" TM ON TM."AMST_Id" = ASYS."AMST_Id"
        INNER JOIN "dbo"."HM_M_Measurement" HMM ON HMM."HMMMES_Id" = TM."HMMMES_Id"
        WHERE AMS."MI_Id" = "MI_Id" 
          AND ASYS."ASMAY_Id" = "ASMAY_Id"
          AND ASYS."AMAY_ActiveFlag" = 1
          AND AMS."AMST_Id" = "AMST_Id"
          AND AMS."AMST_ActiveFlag" = 1
          AND AMS."AMST_SOL" = 'S'
          AND HMM."HMMMES_Flg" = "HT_OR_WT"
        ORDER BY ASMC."ASMCL_Order"
    LOOP
        "std_Sex" := "rec_student"."AMST_sex";
        "Amcl_Name" := "rec_student"."ASMCL_ClassName";
        "Amay_yr_Name" := "rec_student"."ASMAY_Year";
        "std_HsmValue" := "rec_student"."HMTMES_Value";
        "std_age" := "rec_student"."Cur_age";

        FOR "rec_htwt" IN
            SELECT "HMMSHTWT_ToYear", "HMMSHTWT_StdHeight", "HMMSHTWT_StdWeight", "HMMSHTWT_FromMonth"
            FROM "dbo"."HM_M_StandaradHtWt"
            WHERE "HMMSHTWT_GenderFlg" = "std_Sex"
        LOOP
            "std_year" := "rec_htwt"."HMMSHTWT_ToYear";
            "std_H" := "rec_htwt"."HMMSHTWT_StdHeight";
            "std_W" := "rec_htwt"."HMMSHTWT_StdWeight";
            "std_month" := "rec_htwt"."HMMSHTWT_FromMonth";

            INSERT INTO "dbo"."HM_Temp_chart" VALUES("std_year", '0', "std_H", "std_W", 0, "std_month");

        END LOOP;

    END LOOP;

    RETURN;

END;
$$;