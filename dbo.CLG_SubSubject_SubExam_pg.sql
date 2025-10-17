CREATE OR REPLACE FUNCTION "CLG"."CLG_SubSubject_SubExam"(
    "CMI_Id" bigint,
    "CASMAY_Id" bigint,
    "CAMCO_Id" bigint,
    "CAMB_Id" bigint,
    "CAMSE_Id" bigint,
    "CACMS_Id" bigint,
    "AMCST_Id" bigint,
    "CEME_Id" int,
    "CISMS_Id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "CESTMPS_Id" int;
    "CESTM_Id" int;
    "CESTMPSSS_MaxMarks" decimal(10,2);
    "CEMSS_Id" int;
    "CEMSE_Id" int;
    "CSubSEMGR_Id" int;
    "CESTMSS_Marks" decimal(10,2);
    "CEYCESSS_MinMarks" decimal(10,2);
    "CESTMPSSS_PassFailFlg" varchar(50);
    "CGredeFlag" varchar(10);
    "CSubSubject_Percentage" decimal(10,2);
    "CGradeMarksPercentage" decimal(10,2);
    "CESTMPSSS_ObtainedGrade" varchar(10);
    "CEYCES_MarksEntryMax" decimal(10,2);
    "CEYCES_MaxMarks" decimal(10,2);
    "CRatio" decimal(10,2);
    "CESTMSS_Flg" varchar(50);
    "CESTMPSSS_ClassAverage" decimal(10,2);
    "CESTMPSSS_SectionAverage" decimal(10,2);
    "CESTMPSSS_ClassHighest" decimal(10,2);
    "CESTMPSSS_SectionHighest" decimal(10,2);
    "CSClass_Totalmarks" decimal(10,2);
    "CSClass_Totalcount" int;
    "CSSection_Totalmarks" decimal(10,2);
    "CSSection_Totalcount" int;
    "CESTMPSSS_ObtainedMarks" decimal(10,2);
    "CClass_Totalmarks" decimal(10,2);
    "CClass_Totalcount" int;
    "CRoundOffFlg" boolean;
    "CSEMedicalMaxMarksSum" decimal(10,2);
    "CSSMedicalMaxMarksSum" decimal(10,2);
    "CESTMPSSS_Id" int;
    "rec_subsubject" RECORD;
BEGIN

    "CEMSE_Id" := 0;
    "CEMSS_Id" := 0;
    "CSEMedicalMaxMarksSum" := 0;
    "CSSMedicalMaxMarksSum" := 0;

    SELECT "ECSTMPS_Id" INTO "CESTMPS_Id" 
    FROM "CLG"."Exm_Col_Student_Marks_Process_Subjectwise" 
    WHERE "AMCST_Id" = "AMCST_Id" 
        AND "MI_Id" = "CMI_Id" 
        AND "ASMAY_Id" = "CASMAY_Id" 
        AND "AMCO_Id" = "CAMCO_Id" 
        AND "AMB_Id" = "CAMB_Id" 
        AND "AMSE_Id" = "CAMSE_Id" 
        AND "ACMS_Id" = "CACMS_Id" 
        AND "EME_Id" = "CEME_Id" 
        AND "ISMS_Id" = "CISMS_Id";

    SELECT "ECSTM_Id" INTO "CESTM_Id" 
    FROM "CLG"."Exm_Col_Student_Marks" 
    WHERE "AMCST_Id" = "AMCST_Id" 
        AND "MI_Id" = "CMI_Id" 
        AND "ASMAY_Id" = "CASMAY_Id" 
        AND "AMCO_Id" = "CAMCO_Id" 
        AND "AMB_Id" = "CAMB_Id" 
        AND "AMSE_Id" = "CAMSE_Id" 
        AND "ACMS_Id" = "CACMS_Id" 
        AND "EME_Id" = "CEME_Id" 
        AND "ISMS_Id" = "CISMS_Id";

    FOR "rec_subsubject" IN 
        SELECT "EMSS_Id", "EMSE_Id", "ECSTMSS_Marks", "ECSTMSS_Flg" 
        FROM "CLG"."Exm_Col_Student_Marks_SubSubject" 
        WHERE "ECSTM_Id" = "CESTM_Id" 
            AND "MI_Id" = "CMI_Id"
    LOOP
        "CEMSS_Id" := "rec_subsubject"."EMSS_Id";
        "CEMSE_Id" := "rec_subsubject"."EMSE_Id";
        "CESTMSS_Marks" := "rec_subsubject"."ECSTMSS_Marks";
        "CESTMSS_Flg" := "rec_subsubject"."ECSTMSS_Flg";

        IF ("CEMSE_Id" != 0 AND "CEMSS_Id" = 0) OR ("CEMSS_Id" != 0 AND "CEMSE_Id" != 0) THEN
            SELECT "CEYCESS"."ECYSESSS_MaxMarks", "CEYCESS"."EMGR_Id", "CEYCESS"."ECYSESSS_MinMarks"
            INTO "CESTMPSSS_MaxMarks", "CSubSEMGR_Id", "CEYCESSS_MinMarks"
            FROM "CLG"."Exm_Col_Yearly_Scheme" AS "CEYC"
            INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" AS "CEYCE" 
                ON "CEYCE"."ECYS_Id" = "CEYC"."ECYS_Id" 
                AND "CEYCE"."AMCO_Id" = "CAMCO_Id" 
                AND "CEYCE"."AMB_Id" = "CAMB_Id" 
                AND "CEYCE"."AMSE_Id" = "CAMSE_Id" 
                AND "EME_Id" = "CEME_Id" 
                AND "ECYSE_ActiveFlg" = 1 
                AND "CEYC"."ECYS_ActiveFlag" = 1 
                AND "CEYC"."MI_Id" = "CMI_Id"
            INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
                ON "CEYCES"."ECYSE_Id" = "CEYCES"."ECYSE_Id" 
                AND "ECYSES_ActiveFlg" = 1
            INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise_Sub" "CEYCESS" 
                ON "CEYCESS"."ECYSES_Id" = "CEYCES"."ECYSES_Id" 
                AND "ECYSESSS_ActiveFlg" = 1
            WHERE "CEYCESS"."EMSE_Id" = "CEMSE_Id";
        ELSIF ("CEMSS_Id" != 0 AND "CEMSE_Id" = 0) THEN
            SELECT "CEYCESS"."ECYSESSS_MaxMarks", "CEYCESS"."EMGR_Id", "CEYCESS"."ECYSESSS_MinMarks"
            INTO "CESTMPSSS_MaxMarks", "CSubSEMGR_Id", "CEYCESSS_MinMarks"
            FROM "CLG"."Exm_Col_Yearly_Scheme" AS "CEYC"
            INNER JOIN "CLG"."Exm_Col_Yearly_Scheme_Exams" AS "CEYCE" 
                ON "CEYCE"."ECYS_Id" = "CEYC"."ECYS_Id" 
                AND "CEYCE"."AMCO_Id" = "CAMCO_Id" 
                AND "CEYCE"."AMB_Id" = "CAMB_Id" 
                AND "CEYCE"."AMSE_Id" = "CAMSE_Id" 
                AND "EME_Id" = "CEME_Id" 
                AND "ECYSE_ActiveFlg" = 1 
                AND "CEYC"."ECYS_ActiveFlag" = 1 
                AND "CEYC"."MI_Id" = "CMI_Id"
            INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise" AS "CEYCES" 
                ON "CEYCES"."ECYSE_Id" = "CEYCES"."ECYSE_Id" 
                AND "ECYSES_ActiveFlg" = 1
            INNER JOIN "CLG"."Exm_Col_Yrly_Sch_Exams_Subwise_Sub" "CEYCESS" 
                ON "CEYCESS"."ECYSES_Id" = "CEYCES"."ECYSES_Id" 
                AND "ECYSESSS_ActiveFlg" = 1
            WHERE "CEYCESS"."EMSS_Id" = "CEMSS_Id";
        END IF;

        IF ("CEYCES_MaxMarks" > "CEYCES_MarksEntryMax") THEN
            "CRatio" := ("CEYCES_MaxMarks" / NULLIF("CEYCES_MarksEntryMax", 0));
            "CESTMSS_Marks" := "CESTMSS_Marks" * "CRatio";
            "CESTMPSSS_MaxMarks" := "CEYCES_MaxMarks";
        ELSIF ("CEYCES_MaxMarks" < "CEYCES_MarksEntryMax") THEN
            "CRatio" := ("CEYCES_MarksEntryMax" / NULLIF("CEYCES_MaxMarks", 0));
            "CESTMSS_Marks" := "CESTMSS_Marks" / NULLIF("CRatio", 0);
            "CESTMPSSS_MaxMarks" := "CEYCES_MarksEntryMax";
        ELSIF ("CEYCES_MaxMarks" = "CEYCES_MarksEntryMax") THEN
            "CESTMSS_Marks" := "CESTMSS_Marks";
            "CESTMPSSS_MaxMarks" := "CEYCES_MaxMarks";
        END IF;

        SELECT "ExmConfig_RoundoffFlag" INTO "CRoundOffFlg" 
        FROM "Exm"."Exm_Configuration" 
        WHERE "MI_Id" = "CMI_Id" 
        LIMIT 1;

        IF ("CRoundOffFlg" = true) THEN
            "CESTMSS_Marks" := ROUND("CESTMSS_Marks", 0);
        ELSIF ("CRoundOffFlg" = false) THEN
            "CESTMSS_Marks" := "CESTMSS_Marks";
        END IF;

        IF "CESTMSS_Flg" IS NULL OR "CESTMSS_Flg" = '' THEN
            IF ("CEYCESSS_MinMarks" > "CESTMSS_Marks") THEN
                "CESTMPSSS_PassFailFlg" := 'Fail';
            ELSE
                "CESTMPSSS_PassFailFlg" := 'Pass';
            END IF;
        ELSE
            IF ("CESTMSS_Flg" = 'AB') THEN
                "CESTMPSSS_PassFailFlg" := 'AB';
            ELSIF ("CESTMSS_Flg" = 'L') THEN
                "CESTMPSSS_PassFailFlg" := 'L';
            ELSIF ("CESTMSS_Flg" = 'M') THEN
                "CESTMPSSS_PassFailFlg" := 'M';
            END IF;
        END IF;

        SELECT "EMGR_MarksPerFlag" INTO "CGredeFlag" 
        FROM "Exm"."Exm_Master_Grade" 
        WHERE "EMGR_Id" = "CSubSEMGR_Id";

        IF ("CGredeFlag" = 'M') THEN
            "CGradeMarksPercentage" := "CESTMSS_Marks";
        ELSIF ("CGredeFlag" = 'P') THEN
            "CSubSubject_Percentage" := CAST(("CESTMSS_Marks" / NULLIF("CESTMPSSS_MaxMarks", 0)) * 100 AS DECIMAL(10,2));
            "CGradeMarksPercentage" := "CSubSubject_Percentage";
        END IF;

        IF "CESTMPSSS_PassFailFlg" = 'AB' OR "CESTMPSSS_PassFailFlg" = 'M' OR "CESTMPSSS_PassFailFlg" = 'L' THEN
            "CESTMPSSS_ObtainedGrade" := NULL;
        ELSE
            "CESTMPSSS_ObtainedGrade" := NULL;
            SELECT "EMGD_Name" INTO "CESTMPSSS_ObtainedGrade" 
            FROM "Exm"."Exm_Master_Grade_Details" 
            WHERE ((CAST("CGradeMarksPercentage" AS DECIMAL) BETWEEN CAST("EMGD_From" AS DECIMAL) AND CAST("EMGD_To" AS DECIMAL)) 
                OR (CAST("CGradeMarksPercentage" AS DECIMAL) BETWEEN CAST("EMGD_To" AS DECIMAL) AND CAST("EMGD_From" AS DECIMAL)))
                AND "EMGR_Id" = "CSubSEMGR_Id";
        END IF;

        INSERT INTO "CLG"."Exm_Col_Student_Marks_Pro_Sub_SubSubject"(
            "ECSTMPS_Id", "EMSS_Id", "EMSE_Id", "ECSTMPSSS_MaxMarks", "ECSTMPSSS_ObtainedMarks", 
            "ECSTMPSSS_ObtainedGrade", "ECSTMPSSS_PassFailFlg", "CreatedDate", "UpdatedDate"
        )
        VALUES(
            "CESTMPS_Id", "CEMSS_Id", "CEMSE_Id", "CESTMPSSS_MaxMarks", "CESTMSS_Marks", 
            "CESTMPSSS_ObtainedGrade", "CESTMPSSS_PassFailFlg", CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
        );

    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$;