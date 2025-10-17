
CREATE OR REPLACE FUNCTION "dbo"."DON_EXAM_GET_6_8_STUDENT_DETAILS_Modify"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FLAG TEXT,
    p_AMST_Id TEXT
)
RETURNS TABLE(
    result_data JSONB
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_EYC_Id BIGINT;
    v_EMCA_Id BIGINT;
    v_ExmConfig_RankingMethod VARCHAR(50);
    v_ESG_Id BIGINT;
    v_AMST_IdBack BIGINT;
    v_EMPS_SubjOrder BIGINT;
    v_EMP_Id BIGINT;
    v_EMPS_ConvertForMarks DECIMAL(18,2);
    v_FROMDATE TIMESTAMP;
    v_TODATE TIMESTAMP;
    v_COUNT BIGINT;
BEGIN

    SELECT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id"=p_MI_Id::BIGINT AND "ASMAY_Id"=p_ASMAY_Id::BIGINT 
    AND "ASMCL_Id"=p_ASMCL_Id::BIGINT AND "ASMS_Id"=p_ASMS_Id::BIGINT 
    AND "ECAC_ActiveFlag"=1;

    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id"=p_MI_Id::BIGINT AND "ASMAY_Id"=p_ASMAY_Id::BIGINT 
    AND "EMCA_Id"=v_EMCA_Id AND "EYC_ActiveFlg"=1;

    SELECT "EMP_Id" INTO v_EMP_Id 
    FROM "Exm"."Exm_M_Promotion" 
    WHERE "MI_Id"=p_MI_Id::BIGINT AND "EMP_ActiveFlag"=1 AND "EYC_Id"=v_EYC_Id;

    SELECT "ExmConfig_RankingMethod" INTO v_ExmConfig_RankingMethod 
    FROM "Exm"."Exm_Configuration" 
    WHERE "MI_Id"=p_MI_Id::BIGINT;

    DROP TABLE IF EXISTS stthomos_tempthree_Section_Calculation;
    DROP TABLE IF EXISTS "Group_Temp_StudentDetails_Amstids";
    DROP TABLE IF EXISTS "MultipleGroup_Temp_StudentDetails_Amstids";
    DROP TABLE IF EXISTS stthomos_tempNew_Section_Calculation;

    /* STUDENT DETAILS */
    IF p_FLAG='1' THEN
        RETURN QUERY
        SELECT jsonb_agg(jsonb_build_object(
            'AMST_Id', "A"."AMST_Id",
            'studentname', CONCAT(
                COALESCE("AMST_FirstName", ''),
                CASE WHEN COALESCE("AMST_MiddleName", '')='' THEN '' ELSE ' ' || "AMST_MiddleName" END,
                CASE WHEN COALESCE("AMST_LastName", '')='' THEN '' ELSE ' ' || "AMST_LastName" END
            ),
            'admno', "AMST_AdmNo",
            'rollno', "AMAY_RollNo",
            'classname', "ASMCL_ClassName",
            'sectionname', "ASMC_SectionName",
            'fathername', CONCAT(
                COALESCE("AMST_FatherName", '  '),
                CASE WHEN COALESCE("AMST_FatherSurname", '')=' ' THEN '  ' ELSE '  ' || "AMST_FatherSurname" END
            ),
            'mothername', CONCAT(
                COALESCE("AMST_MotherName", ' '),
                CASE WHEN COALESCE("AMST_MotherSurname", '')='  ' THEN '  ' ELSE '   ' || "AMST_MotherSurname" END
            ),
            'dob', TO_CHAR("amst_dob", 'DD/MM/YYYY'),
            'mobileno', "AMST_MobileNo"
        )) AS result_data
        FROM "Adm_M_Student" "A" 
        INNER JOIN "Adm_School_Y_Student" "B" ON "A"."AMST_Id"="B"."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "C" ON "C"."ASMAY_Id"="B"."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" "D" ON "D"."ASMCL_Id"="B"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "E" ON "E"."ASMS_Id"="B"."ASMS_Id"
        WHERE "A"."MI_Id"=p_MI_Id::BIGINT AND "B"."ASMAY_Id"=p_ASMAY_Id::BIGINT 
        AND "B"."ASMCL_Id"=p_ASMCL_Id::BIGINT AND "B"."ASMS_Id"=p_ASMS_Id::BIGINT
        AND "A"."AMST_Id" = ANY(string_to_array(p_AMST_Id, ',')::BIGINT[]);

    /* STUDENT WISE SUBJECT DETAILS */
    ELSIF p_FLAG='2' THEN
        DROP TABLE IF EXISTS "STThomos_Temp__FinalCalculation";

        CREATE TEMP TABLE "STThomos_Temp__FinalCalculation" AS
        SELECT DISTINCT "MPS"."AMST_Id", "MPS"."ISMS_Id", "MS"."ISMS_SubjectName", 
               "MS"."ISMS_SubjectCode", "PS"."EMPS_SubjOrder" AS grporder,
               "PS"."EMPS_AppToResultFlg",
               (CASE WHEN "EMPS_ConvertForMarks"="EMPS_MaxMarks" 
                     THEN ROUND((SUM("SG"."ESTMPPSG_GroupObtMarks")/2), 0)
                     ELSE ROUND((SUM("SG"."ESTMPPSG_GroupObtMarks")/4), 0) 
                END) AS "ESTMPPSG_GroupObtMarks",
               (SELECT "EMGD_Name"
                FROM "Exm"."Exm_Master_Grade_Details" "LKL"
                WHERE ((ROUND((SUM("SG"."ESTMPPSG_GroupObtMarks")/2), 0) BETWEEN "EMGD_From" AND "EMGD_To")
                       OR (ROUND((SUM("SG"."ESTMPPSG_GroupObtMarks")/2), 0) BETWEEN "EMGD_To" AND "EMGD_From"))
                AND "LKL"."EMGR_Id"="MP"."EMGR_Id"
                LIMIT 1) AS "ESTMPPSG_GroupObtGrade"
        FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" "MPS"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" "SG" 
            ON "MPS"."ESTMPPS_Id"="SG"."ESTMPPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" "MSG" 
            ON "MSG"."EMPSG_Id"="SG"."EMPSG_Id" AND "EMPSG_ActiveFlag"=1
        INNER JOIN "IVRM_Master_Subjects" "MS" ON "MS"."ISMS_Id"="MPS"."ISMS_Id"
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "PS" 
            ON "PS"."EMPS_Id"="MSG"."EMPS_Id" AND "MS"."ISMS_Id"="PS"."ISMS_Id" 
            AND "PS"."EMPS_ActiveFlag"=1
        INNER JOIN "Exm"."Exm_M_Promotion" "MP" 
            ON "MP"."EMP_Id"="PS"."EMP_Id" AND "MP"."EMP_ActiveFlag"=1 
            AND "MP"."EYC_Id"=v_EYC_Id
        WHERE "MPS"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "MPS"."MI_Id"=p_MI_Id::BIGINT 
        AND "MPS"."ASMCL_Id"=p_ASMCL_Id::BIGINT AND "MPS"."ASMS_Id"=p_ASMS_Id::BIGINT
        GROUP BY "MPS"."AMST_Id", "MPS"."ISMS_Id", "MS"."ISMS_SubjectName", 
                 "MS"."ISMS_SubjectCode", "PS"."EMPS_SubjOrder", 
                 "PS"."EMPS_AppToResultFlg", "MP"."EMGR_Id", 
                 "EMPS_ConvertForMarks", "EMPS_MaxMarks"
        ORDER BY "MPS"."AMST_Id", grporder;

        RETURN QUERY
        SELECT jsonb_agg(jsonb_build_object(
            'AMST_Id', "AMST_Id",
            'ISMS_Id', a."ISMS_Id",
            'ISMS_SubjectName', "ISMS_SubjectName",
            'ISMS_SubjectCode', "ISMS_SubjectCode",
            'grporder', grporder,
            'EMPS_AppToResultFlg', "EMPS_AppToResultFlg",
            'ESTMPPSG_GroupObtMarks', "ESTMPPSG_GroupObtMarks",
            'ESTMPPSG_GroupObtGrade', "ESTMPPSG_GroupObtGrade"
        )) AS result_data
        FROM "STThomos_Temp__FinalCalculation" a
        INNER JOIN "Exm"."Exm_Yrly_Cat_Exams_Subwise" c 
            ON c."ISMS_Id"=a."ISMS_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" d 
            ON d."EYCE_Id"=c."EYCE_Id" AND d."EYC_Id"=v_EYC_Id
        INNER JOIN "Exm"."Exm_Yearly_Category" "E" 
            ON "E"."EYC_Id"=d."EYC_Id" AND "E"."EYC_Id"=v_EYC_Id 
            AND "E"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "E"."EMCA_Id"=v_EMCA_Id
        ORDER BY "AMST_Id", grporder;

    /* STUDENT WISE ATTENDANCE */
    ELSIF p_FLAG='3' THEN
        SELECT COUNT(1) INTO v_COUNT
        FROM "Exm"."Exm_Yearly_Category_Exams" "A" 
        INNER JOIN "Exm"."Exm_Master_Exam" "B" ON "A"."EME_Id"="B"."EME_Id"
        WHERE "A"."EYC_Id"=v_EYC_Id AND "A"."EYCE_ActiveFlg"=1 
        AND "B"."EME_ActiveFlag"=1 AND "B"."EME_FinalExamFlag"=1;

        IF (v_COUNT>0) THEN
            SELECT "EYCE_AttendanceFromDate", "EYCE_AttendanceToDate" 
            INTO v_FROMDATE, v_TODATE
            FROM "Exm"."Exm_Yearly_Category_Exams" "A" 
            INNER JOIN "Exm"."Exm_Master_Exam" "B" ON "A"."EME_Id"="B"."EME_Id"
            WHERE "A"."EYC_Id"=v_EYC_Id AND "A"."EYCE_ActiveFlg"=1 
            AND "B"."EME_ActiveFlag"=1 AND "B"."EME_FinalExamFlag"=1
            ORDER BY "B"."EME_ExamOrder"
            LIMIT 1;

            RETURN QUERY
            SELECT jsonb_agg(jsonb_build_object(
                'TOTALWORKINGDAYS', "TOTALWORKINGDAYS",
                'PRESENTDAYS', "PRESENTDAYS",
                'ATTENDANCEPERCENTAGE', "ATTENDANCEPERCENTAGE",
                'AMST_Id', "AMST_Id"
            )) AS result_data
            FROM (
                SELECT SUM("ASA_ClassHeld") AS "TOTALWORKINGDAYS", 
                       SUM("ASA_Class_Attended") AS "PRESENTDAYS",
                       ROUND(SUM("ASA_Class_Attended") * 100.0 / SUM("ASA_ClassHeld"), 0) AS "ATTENDANCEPERCENTAGE",
                       "B"."AMST_Id"
                FROM "Adm_Student_Attendance" "A" 
                INNER JOIN "Adm_Student_Attendance_Students" "B" ON "A"."ASA_Id"="B"."ASA_Id"
                INNER JOIN "Adm_School_Y_Student" "C" ON "C"."AMST_Id"="B"."AMST_Id"
                INNER JOIN "Adm_M_Student" "D" ON "D"."AMST_Id"="B"."AMST_Id"
                INNER JOIN "Adm_School_M_Academic_Year" "E" ON "E"."ASMAY_Id"="C"."ASMAY_Id"
                INNER JOIN "Adm_School_M_Class" "F" ON "F"."ASMCL_Id"="C"."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" "G" ON "G"."ASMS_Id"="C"."ASMS_Id"
                WHERE "A"."ASMAY_Id"=p_ASMAY_Id::BIGINT 
                AND "A"."ASA_FromDate"::DATE >= v_FROMDATE::DATE 
                AND "A"."ASA_ToDate"::DATE <= v_TODATE::DATE
                AND "A"."ASMCL_Id"=p_ASMCL_Id::BIGINT 
                AND "A"."ASMS_Id"=p_ASMS_Id::BIGINT 
                AND "A"."ASA_Activeflag"=1 AND "A"."MI_Id"=p_MI_Id::BIGINT
                AND "C"."ASMAY_Id"=p_ASMAY_Id::BIGINT 
                AND "C"."ASMCL_Id"=p_ASMCL_Id::BIGINT 
                AND "C"."ASMS_Id"=p_ASMS_Id::BIGINT 
                AND "C"."AMST_Id" = ANY(string_to_array(p_AMST_Id, ',')::BIGINT[])
                GROUP BY "B"."AMST_Id"
            ) sub;
        END IF;

    /* ****** SKILLS ****** */
    ELSIF p_FLAG='4' THEN
        RETURN QUERY
        SELECT jsonb_agg(jsonb_build_object(
            'ECT_Id', "A"."ECT_Id",
            'ECS_SkillName', "B"."ECS_SkillName",
            'ECSA_SkillArea', "C"."ECSA_SkillArea",
            'ECSA_Id', a."ECSA_Id",
            'ECSA_SkillOrder', "C"."ECSA_SkillOrder",
            'ECST_Score', "ECST_Score",
            'EMGD_Name', "EMGD_Name",
            'AMST_Id', "A"."AMST_Id",
            'ECS_Id', "A"."ECS_Id",
            'ECT_TermName', "D"."ECT_TermName"
        )) AS result_data
        FROM "Exm"."Exm_CCE_SKILLS_Transaction" "A" 
        INNER JOIN "Exm"."Exm_CCE_SKILLS" "B" ON "A"."ECS_Id"="B"."ECS_Id"
        INNER JOIN "Exm"."Exm_CCE_SKILLS_AREA" "C" ON "C"."ECSA_Id"="A"."ECSA_Id"
        INNER JOIN "Exm"."Exm_CCE_TERMS" "D" ON "D"."ECT_ID"="A"."ECT_Id"
        INNER JOIN "Adm_School_Y_Student" "E" ON "E"."AMST_Id"="A"."AMST_Id"
        INNER JOIN "Adm_M_Student" "F" ON "F"."AMST_Id"="E"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" "G" 
            ON "G"."ASMCL_ID"="E"."ASMCL_Id" AND "G"."ASMCL_ID"="A"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "H" 
            ON "H"."ASMS_Id"="E"."ASMS_Id" AND "H"."ASMS_Id"="A"."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "I" 
            ON "I"."ASMAY_Id"="E"."ASMAY_Id" AND "I"."ASMAY_Id"="A"."ASMAY_Id"
        INNER JOIN "Exm"."Exm_CCE_SKILLS_AREA_Mapping" "J" 
            ON "J"."ECS_Id"="B"."ECS_Id" AND "J"."ECSA_Id"="C"."ECSA_Id"
        INNER JOIN "Exm"."Exm_Master_Grade" "K" 
            ON "K"."EMGR_Id"="J"."EMGR_Id" AND "K"."EMGR_ActiveFlag"=1
        INNER JOIN "Exm"."Exm_Master_Grade_Details" "L" 
            ON "L"."EMGR_Id"="K"."EMGR_Id" AND "L"."EMGD_ActiveFlag"=1
        WHERE "E"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "E"."ASMCL_Id"=p_ASMCL_Id::BIGINT 
        AND "E"."ASMS_Id"=p_ASMS_Id::BIGINT 
        AND "A"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "A"."ASMCL_Id"=p_ASMCL_Id::BIGINT 
        AND "A"."ASMS_Id"=p_ASMS_Id::BIGINT
        AND "D"."EMCA_Id"=v_EMCA_Id AND "D"."ASMAY_Id"=p_ASMAY_Id::BIGINT 
        AND "D"."ECT_ActiveFlag"=1 
        AND ("A"."ECST_Score" BETWEEN "L"."EMGD_From" AND "L"."EMGD_To")
        AND "A"."AMST_Id" = ANY(string_to_array(p_AMST_Id, ',')::BIGINT[])
        ORDER BY "ECSA_SkillOrder";

    /* ****** ACTIVITES LIST ********* */
    ELSIF p_FLAG='5' THEN
        RETURN QUERY
        SELECT jsonb_agg(jsonb_build_object(
            'ECT_Id', "A"."ECT_Id",
            'ECACT_SkillName', "B"."ECACT_SkillName",
            'ECACTA_SkillArea', "C"."ECACTA_SkillArea",
            'ECACTA_SkillOrder', "C"."ECACTA_SkillOrder",
            'ECSACTT_Score', "ECSACTT_Score",
            'EMGD_Name', "EMGD_Name",
            'AMST_Id', "A"."AMST_Id"
        )) AS result_data
        FROM "Exm"."Exm_CCE_Activities_Transaction" "A" 
        INNER JOIN "Exm"."Exm_CCE_Activities" "B" ON "A"."ECACT_Id"="B"."ECACT_Id"
        INNER JOIN "Exm"."Exm_CCE_Activities_AREA" "C" ON "C"."ECACTA_Id"="A"."ECACTA_Id"
        INNER JOIN "Exm"."Exm_CCE_TERMS" "D" ON "D"."ECT_ID"="A"."ECT_Id"
        INNER JOIN "Adm_School_Y_Student" "E" ON "E"."AMST_Id"="A"."AMST_Id"
        INNER JOIN "Adm_M_Student" "F" ON "F"."AMST_Id"="E"."AMST_Id"
        INNER JOIN "Adm_School_M_Class" "G" 
            ON "G"."ASMCL_ID"="E"."ASMCL_Id" AND "G"."ASMCL_ID"="A"."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" "H" 
            ON "H"."ASMS_Id"="E"."ASMS_Id" AND "H"."ASMS_Id"="A"."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "I" 
            ON "I"."ASMAY_Id"="E"."ASMAY_Id" AND "I"."ASMAY_Id"="A"."ASMAY_Id"
        INNER JOIN "Exm"."Exm_CCE_Activities_AREA_Mapping" "J" 
            ON "J"."ECACT_Id"="B"."ECACT_Id" AND "J"."ECACTA_Id"="C"."ECACTA_Id"
        INNER JOIN "Exm"."Exm_Master_Grade" "K" 
            ON "K"."EMGR_Id"="J"."EMGR_Id" AND "K"."EMGR_ActiveFlag"=1
        INNER JOIN "Exm"."Exm_Master_Grade_Details" "L" 
            ON "L"."EMGR_Id"="K"."EMGR_Id" AND "L"."EMGD_ActiveFlag"=1
        WHERE "E"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "E"."ASMCL_Id"=p_ASMCL_Id::BIGINT 
        AND "E"."ASMS_Id"=p_ASMS_Id::BIGINT 
        AND "A"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "A"."ASMCL_Id"=p_ASMCL_Id::BIGINT 
        AND "A"."ASMS_Id"=p_ASMS_Id::BIGINT
        AND "D"."EMCA_Id"=v_EMCA_Id AND "D"."ASMAY_Id"=p_ASMAY_Id::BIGINT 
        AND "D"."ECT_ActiveFlag"=1 
        AND ("A"."ECSACTT_Score" BETWEEN "L"."EMGD_From" AND "L"."EMGD_To")
        AND "A"."AMST_Id" = ANY(string_to_array(p_AMST_Id, ',')::BIGINT[])
        ORDER BY "ECACTA_SkillOrder";

    ELSIF p_FLAG='6' THEN
        RETURN QUERY
        SELECT jsonb_agg(jsonb_build_object(
            'AMST_Id', "AMST_Id",
            'Overall_GroupObtMarks', "Overall_GroupObtMarks"
        )) AS result_data
        FROM (
            SELECT "AMST_Id", SUM("ESTMPPSG_GroupObtMarks") AS "Overall_GroupObtMarks"
            FROM (
                SELECT DISTINCT "MPS"."AMST_Id", "MPS"."ISMS_Id", "MS"."ISMS_SubjectName", 
                       "PS"."EMPS_SubjOrder" AS grporder, "PS"."EMPS_AppToResultFlg",
                       ROUND((SUM("SG"."ESTMPPSG_GroupObtMarks")/2), 0) AS "ESTMPPSG_GroupObtMarks",
                       (SELECT "EMGD_Name" FROM "Exm"."Exm_Master_Grade_Details" 
                        WHERE "EMGD_Id"="MPS"."EMGD_Id") AS "ESTMPPSG_GroupObtGrade"
                FROM "Exm"."Exm_Stu_MP_Promo_Subjectwise" "MPS"
                INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_Groupwise" "SG" 
                    ON "MPS"."ESTMPPS_Id"="SG"."ESTMPPS_Id"
                INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" "MSG" 
                    ON "MSG"."EMPSG_Id"="SG"."EMPSG_Id" AND "EMPSG_ActiveFlag"=1
                INNER JOIN "IVRM_Master_Subjects" "MS" ON "MS"."ISMS_Id"="MPS"."ISMS_Id"
                INNER JOIN "Exm"."Exm_M_Promotion_Subjects" "PS" 
                    ON "PS"."EMPS_Id"="MSG"."EMPS_Id" AND "MS"."ISMS_Id"="PS"."ISMS_Id" 
                    AND "PS"."EMPS_ActiveFlag"=1
                INNER JOIN "Exm"."Exm_M_Promotion" "MP" 
                    ON "MP"."EMP_Id"="PS"."EMP_Id" AND "MP"."EMP_ActiveFlag"=1 
                    AND "MP"."EYC_Id"=v_EYC_Id
                WHERE "MPS"."ASMAY_Id"=p_ASMAY_Id::BIGINT AND "MPS"."MI_Id"=p_MI_Id::BIGINT 
                AND "MPS"."ASMCL_Id"=p_ASMCL_Id::BIGINT AND "MPS"."ASMS_Id"=p_ASMS_Id::BIGINT
                AND "AMST_Id" = ANY(string_to_array(p_AMST_Id, ',')::BIGINT[])
                GROUP BY "MPS"."AMST_Id", "MPS"."ISMS_Id", "MS"."ISMS_SubjectName", 
                         "PS"."EMPS_SubjOrder", "PS"."EMPS_AppToResultFlg", "MPS"."EMGD_Id"
            ) "A"
            GROUP BY "AMST_Id"
            ORDER BY "AMST_Id"
        ) sub;

    ELSIF p_FLAG='7' THEN
        DROP TABLE IF EXISTS "Graph_Temp_StudentDetails_Amstids";

        UPDATE stjames_temp_promotion_details 
        SET grporder="EMPS_SubjOrder" 
        WHERE "EMPSG_GroupName" != 'Final Average';

        CREATE TEMP TABLE "Graph_Temp_StudentDetails_Amstids" AS
        SELECT DISTINCT "A"."AMST_Id", "A"."ISMS_SubjectName", "A"."EMPS_SubjOrder",
               "PS"."EMPS_AppToResultFlg",
               (CASE WHEN a.grporder > 1000 THEN 0
                     ELSE SUM("A"."ESTMPPSG_GroupObtMarks") / COUNT("A"."ESTMPPSG_GroupObtMarks")
                END) AS "ESTMPPSG_GroupObtMarks",
               (CASE WHEN a.grporder < 10000 AND "ESG_Id" != 0 THEN 0
                     ELSE SUM("A"."ESTMPPSG_GroupObtMarks") / COUNT("A"."ESTMPPSG_GroupObtMarks")
                END) AS "ESTMPPSG_GroupAVGMarks",
               (SELECT "EMGD_Name" FROM "Exm"."Exm_Master_Grade_Details" 
                WHERE "EMGD_Id"="MPS"."EMGD_Id") AS "ESTMPPSG_GroupObtGrade",
               a."ESG_Id",
               (CASE WHEN a.grporder > 1000 THEN a.grporder ELSE "A"."ISMS_Id" END) AS "ISMS_Id",
               (CASE WHEN a.grporder < 10000 AND "ESG_Id" != 0 
                     THEN SUM("A"."ESTMPPSG_GroupObtMarks") / COUNT("A"."ESTMPPSG_GroupObtMarks")
                     ELSE SUM("A"."ESTMPPSG_GroupObtMarks") / COUNT("A"."ESTMPPSG_GroupObtMarks")
                END) AS "GroupAVGMarks"
        FROM stjames_temp_promotion_details "A"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" "MPS" 
            ON a."AMST_Id"="MPS"."AMST_Id" AND "A"."ISMS_Id"="MPS"."ISMS_Id"
        INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise_