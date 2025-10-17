CREATE OR REPLACE FUNCTION "College_Feedback_Report_CourseWise_New"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_Flag TEXT,
    p_Type TEXT,
    p_FlagType TEXT,
    p_FMQE_Id TEXT,
    p_GraphType TEXT
)
RETURNS TABLE(
    miid TEXT,
    amcoid BIGINT,
    amseid BIGINT,
    semnameyear TEXT,
    remarks TEXT,
    options TEXT,
    qid BIGINT,
    opid BIGINT,
    count BIGINT,
    total NUMERIC(18,2),
    coursename TEXT
) AS $$
DECLARE
    v_AMSE_Id TEXT;
    v_AMSE_SEMName TEXT;
    v_AMCO_CourseName TEXT;
    v_AMCO_Id_NEW TEXT;
    v_COUNT BIGINT;
    v_AMCOID_Order BIGINT;
    v_QUESID TEXT;
    v_QUESTIONREMARKS TEXT;
    v_QUESTIONORDER TEXT;
    v_OPTIONID TEXT;
    v_OPTIONREMARKS TEXT;
    v_OPTIONORDER TEXT;
    v_countNEW1 NUMERIC(18,2);
    v_countNEW NUMERIC(18,2);
    v_id TEXT;
    v_QUESID_NEW TEXT;
    v_QUESTIONREMARKS_NEW TEXT;
    v_QUESTIONORDER_NEW TEXT;
    v_OPTIONID_NEW TEXT;
    v_OPTIONREMARKS_NEW TEXT;
    v_OPTIONORDER_NEW TEXT;
    v_countNEW1_NEW NUMERIC(18,2);
    v_countNEW_NEW NUMERIC(18,2);
    v_id_NEW TEXT;
    v_AMCOID_ID TEXT;
    v_AMCOID_COURSENAME TEXT;
    v_AMCOID_ORDERNew TEXT;
    v_QUESTIONID TEXT;
    v_QUESTIONNAME TEXT;
    v_QUESTIONORDERNEW TEXT;
    v_OPTIONIDNEW TEXT;
    v_OPTIONNAME TEXT;
    v_OPTIONORDERNEW TEXT;
    v_countNEW1_NEW1 NUMERIC(18,2);
    v_countNEW_NEW1 NUMERIC(18,2);
    v_id_NEW1 TEXT;
    v_AMCOID_ID_no TEXT;
    v_AMCOID_COURSENAME_no TEXT;
    v_AMCOID_ORDERNew_no TEXT;
    v_QUESTIONID_no TEXT;
    v_QUESTIONNAME_no TEXT;
    v_QUESTIONORDERNEW_no TEXT;
    v_OPTIONIDNEW_no TEXT;
    v_OPTIONNAME_no TEXT;
    v_OPTIONORDERNEW_no TEXT;
    v_countNEW1_NEW1_no NUMERIC(18,2);
    v_countNEW_NEW1_no NUMERIC(18,2);
    v_id_NEW1_no TEXT;
    v_QUESTIONID_pie TEXT;
    v_QUESTIONNAME_pie TEXT;
    v_QUESTIONORDERNEW_pie TEXT;
    v_OPTIONIDNEW_pie TEXT;
    v_OPTIONNAME_pie TEXT;
    v_OPTIONORDERNEW_pie TEXT;
    v_countNEW1_NEW1_pie NUMERIC(18,2);
    v_countNEW_NEW1_pie NUMERIC(18,2);
    v_id_NEW1_pie TEXT;
    rec_course RECORD;
    rec_question RECORD;
    rec_option RECORD;
BEGIN
    DROP TABLE IF EXISTS temp_feedback_reporttemp_NEW;
    DROP TABLE IF EXISTS temp_feedback_reporttemp_NEW_DETAILS;
    DROP TABLE IF EXISTS temp_feedback_reporttemp_NEW_DETAILS_QUESTION;
    DROP TABLE IF EXISTS temp_feedback_reporttemp_NEW_DETAILS_QUESTION_NO;
    DROP TABLE IF EXISTS temp_feedback_reporttemp_NEW_DETAILS_QUESTION_pie;

    IF p_FlagType = 'Yearwise' THEN
        CREATE TEMP TABLE temp_feedback_reporttemp_NEW (
            miid TEXT,
            amcoid BIGINT,
            amseid BIGINT,
            semnameyear TEXT,
            remarks TEXT,
            options TEXT,
            qid BIGINT,
            opid BIGINT,
            count BIGINT,
            total NUMERIC(18,2)
        );

        FOR rec_course IN
            SELECT DISTINCT B."AMCO_Id", C."AMCO_CourseName", E."AMSE_Id", E."AMSE_Year", "AMCO_Order", COUNT(DISTINCT a."AMCST_Id") AS COUNT_VAL
            FROM "CLG"."Adm_College_Yearly_Student" A 
            INNER JOIN "CLG"."Adm_Master_College_Student" B ON A."AMCST_Id" = B."AMCST_Id"
            INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id" = A."AMCO_Id"
            INNER JOIN "CLG"."Adm_Master_Branch" D ON D."AMB_Id" = A."AMB_Id"
            INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id" = A."AMSE_Id"
            INNER JOIN "Adm_School_M_Academic_Year" F ON a."ASMAY_Id" = F."ASMAY_Id"
            INNER JOIN "CLG"."Feedback_College_Student_Transaction" G ON G."AMCST_Id" = A."AMCST_Id" 
                AND G."ASMAY_Id" = p_ASMAY_Id::BIGINT AND G."AMCO_Id" = p_AMCO_Id::BIGINT 
                AND G."FMTY_Id" = p_Type::BIGINT AND g."FCSTR_StudParFlg" = p_Flag
            WHERE A."ASMAY_Id" = p_ASMAY_Id::BIGINT AND A."AMCO_Id" = p_AMCO_Id::BIGINT 
                AND A."ACYST_ActiveFlag" = TRUE AND B."AMCST_SOL" = 'S' AND B."AMCST_ActiveFlag" = TRUE
            GROUP BY B."AMCO_Id", C."AMCO_CourseName", E."AMSE_Id", E."AMSE_Year", "AMCO_Order"
            ORDER BY "AMCO_Order"
        LOOP
            v_AMCO_Id_NEW := rec_course."AMCO_Id"::TEXT;
            v_AMCO_CourseName := rec_course."AMCO_CourseName";
            v_AMSE_Id := rec_course."AMSE_Id"::TEXT;
            v_AMSE_SEMName := rec_course."AMSE_Year";
            v_AMCOID_Order := rec_course."AMCO_Order";
            v_COUNT := rec_course.COUNT_VAL;

            FOR rec_question IN
                SELECT DISTINCT c."FMQE_Id", c."FMQE_FeedbackQRemarks", c."FMQE_FQOrder"
                FROM "Feedback_Type_Questions" A 
                INNER JOIN "Feedback_Master_Type" B ON A."FMTY_Id" = B."FMTY_Id"
                INNER JOIN "Feedback_Master_Questions" C ON C."FMQE_Id" = A."FMQE_Id"
                WHERE C."MI_Id" = p_MI_Id::BIGINT AND A."MI_Id" = p_MI_Id::BIGINT AND B."MI_Id" = p_MI_Id::BIGINT 
                    AND A."FMTQ_ActiveFlag" = TRUE AND B."FMTY_ActiveFlag" = TRUE AND C."FMQE_ActiveFlag" = TRUE
                    AND A."FMTY_Id" = p_Type::BIGINT AND B."FMTY_StakeHolderFlag" = p_Flag
                ORDER BY C."FMQE_FQOrder"
            LOOP
                v_QUESID := rec_question."FMQE_Id"::TEXT;
                v_QUESTIONREMARKS := rec_question."FMQE_FeedbackQRemarks";
                v_QUESTIONORDER := rec_question."FMQE_FQOrder"::TEXT;

                FOR rec_option IN
                    SELECT DISTINCT c."FMOP_Id", c."FMOP_FeedbackOptions", c."FMOP_FOOrder"
                    FROM "Feedback_Type_Options" A 
                    INNER JOIN "Feedback_Master_Type" B ON A."FMTY_Id" = B."FMTY_Id"
                    INNER JOIN "Feedback_Master_Options" C ON C."FMOP_Id" = A."FMOP_Id"
                    WHERE C."MI_Id" = p_MI_Id::BIGINT AND A."MI_Id" = p_MI_Id::BIGINT AND B."MI_Id" = p_MI_Id::BIGINT 
                        AND A."FMTO_ActiveFlag" = TRUE AND B."FMTY_ActiveFlag" = TRUE AND C."FMOP_ActiveFlag" = TRUE
                        AND A."FMTY_Id" = p_Type::BIGINT AND B."FMTY_StakeHolderFlag" = p_Flag
                    ORDER BY C."FMOP_FOOrder"
                LOOP
                    v_OPTIONID := rec_option."FMOP_Id"::TEXT;
                    v_OPTIONREMARKS := rec_option."FMOP_FeedbackOptions";
                    v_OPTIONORDER := rec_option."FMOP_FOOrder"::TEXT;

                    v_countNEW := 0;
                    v_countNEW1 := 0;

                    SELECT COUNT(*), "FMOP_Id"::TEXT INTO v_countNEW1, v_id
                    FROM "clg"."Feedback_College_Student_Transaction"
                    WHERE "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT
                        AND "FCSTR_StudParFlg" = p_Flag AND "FMTY_Id" = p_Type::BIGINT 
                        AND "FMQE_Id" = v_QUESID::BIGINT AND "FMOP_Id" = v_OPTIONID::BIGINT 
                        AND "AMCO_Id" = v_AMCO_Id_NEW::BIGINT AND "AMSE_Id" = v_AMSE_Id::BIGINT
                    GROUP BY "FMOP_Id";

                    v_countNEW1 := COALESCE(v_countNEW1, 0);
                    v_countNEW := CAST((v_countNEW1 * 100.0 / v_COUNT) AS NUMERIC(18,2));

                    IF v_countNEW1 > 0 THEN
                        INSERT INTO temp_feedback_reporttemp_NEW 
                        VALUES (p_MI_Id, v_AMCO_Id_NEW::BIGINT, v_AMSE_Id::BIGINT, v_AMSE_SEMName, 
                                v_QUESTIONREMARKS, v_OPTIONREMARKS, v_QUESID::BIGINT, v_OPTIONID::BIGINT, 
                                v_countNEW1::BIGINT, v_countNEW);
                    ELSE
                        INSERT INTO temp_feedback_reporttemp_NEW 
                        VALUES (p_MI_Id, v_AMCO_Id_NEW::BIGINT, v_AMSE_Id::BIGINT, v_AMSE_SEMName, 
                                v_QUESTIONREMARKS, v_OPTIONREMARKS, v_QUESID::BIGINT, v_OPTIONID::BIGINT, 0, 0);
                    END IF;
                END LOOP;
            END LOOP;
        END LOOP;

        RETURN QUERY SELECT t.miid, t.amcoid, t.amseid, t.semnameyear, t.remarks, t.options, 
                            t.qid, t.opid, t.count, t.total, NULL::TEXT AS coursename
                     FROM temp_feedback_reporttemp_NEW t;

    ELSIF p_FlagType = 'Overall' THEN
        CREATE TEMP TABLE temp_feedback_reporttemp_NEW_DETAILS (
            miid TEXT,
            amcoid BIGINT,
            remarks TEXT,
            options TEXT,
            qid BIGINT,
            opid BIGINT,
            count BIGINT,
            total NUMERIC(18,2)
        );

        FOR rec_course IN
            SELECT DISTINCT B."AMCO_Id", C."AMCO_CourseName", "AMCO_Order", COUNT(DISTINCT A."AMCST_Id") AS COUNT_VAL
            FROM "CLG"."Adm_College_Yearly_Student" A 
            INNER JOIN "CLG"."Adm_Master_College_Student" B ON A."AMCST_Id" = B."AMCST_Id"
            INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id" = A."AMCO_Id"
            INNER JOIN "CLG"."Adm_Master_Branch" D ON D."AMB_Id" = A."AMB_Id"
            INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id" = A."AMSE_Id"
            INNER JOIN "Adm_School_M_Academic_Year" F ON a."ASMAY_Id" = F."ASMAY_Id"
            INNER JOIN "CLG"."Feedback_College_Student_Transaction" G ON G."AMCST_Id" = A."AMCST_Id" 
                AND G."ASMAY_Id" = p_ASMAY_Id::BIGINT AND G."AMCO_Id" = p_AMCO_Id::BIGINT 
                AND G."FMTY_Id" = p_Type::BIGINT AND g."FCSTR_StudParFlg" = p_Flag
            WHERE A."ASMAY_Id" = p_ASMAY_Id::BIGINT AND A."AMCO_Id" = p_AMCO_Id::BIGINT 
                AND A."ACYST_ActiveFlag" = TRUE AND B."AMCST_SOL" = 'S' AND B."AMCST_ActiveFlag" = TRUE
            GROUP BY B."AMCO_Id", C."AMCO_CourseName", "AMCO_Order"
            ORDER BY "AMCO_Order"
        LOOP
            v_AMCO_Id_NEW := rec_course."AMCO_Id"::TEXT;
            v_AMCO_CourseName := rec_course."AMCO_CourseName";
            v_AMCOID_Order := rec_course."AMCO_Order";
            v_COUNT := rec_course.COUNT_VAL;

            FOR rec_question IN
                SELECT DISTINCT c."FMQE_Id", c."FMQE_FeedbackQRemarks", c."FMQE_FQOrder"
                FROM "Feedback_Type_Questions" A 
                INNER JOIN "Feedback_Master_Type" B ON A."FMTY_Id" = B."FMTY_Id"
                INNER JOIN "Feedback_Master_Questions" C ON C."FMQE_Id" = A."FMQE_Id"
                WHERE C."MI_Id" = p_MI_Id::BIGINT AND A."MI_Id" = p_MI_Id::BIGINT AND B."MI_Id" = p_MI_Id::BIGINT 
                    AND A."FMTQ_ActiveFlag" = TRUE AND B."FMTY_ActiveFlag" = TRUE AND C."FMQE_ActiveFlag" = TRUE
                    AND A."FMTY_Id" = p_Type::BIGINT AND B."FMTY_StakeHolderFlag" = p_Flag
                ORDER BY C."FMQE_FQOrder"
            LOOP
                v_QUESID_NEW := rec_question."FMQE_Id"::TEXT;
                v_QUESTIONREMARKS_NEW := rec_question."FMQE_FeedbackQRemarks";
                v_QUESTIONORDER_NEW := rec_question."FMQE_FQOrder"::TEXT;

                FOR rec_option IN
                    SELECT DISTINCT c."FMOP_Id", c."FMOP_FeedbackOptions", c."FMOP_FOOrder"
                    FROM "Feedback_Type_Options" A 
                    INNER JOIN "Feedback_Master_Type" B ON A."FMTY_Id" = B."FMTY_Id"
                    INNER JOIN "Feedback_Master_Options" C ON C."FMOP_Id" = A."FMOP_Id"
                    WHERE C."MI_Id" = p_MI_Id::BIGINT AND A."MI_Id" = p_MI_Id::BIGINT AND B."MI_Id" = p_MI_Id::BIGINT 
                        AND A."FMTO_ActiveFlag" = TRUE AND B."FMTY_ActiveFlag" = TRUE AND C."FMOP_ActiveFlag" = TRUE
                        AND A."FMTY_Id" = p_Type::BIGINT AND B."FMTY_StakeHolderFlag" = p_Flag
                    ORDER BY C."FMOP_FOOrder"
                LOOP
                    v_OPTIONID_NEW := rec_option."FMOP_Id"::TEXT;
                    v_OPTIONREMARKS_NEW := rec_option."FMOP_FeedbackOptions";
                    v_OPTIONORDER_NEW := rec_option."FMOP_FOOrder"::TEXT;

                    v_countNEW_NEW := 0;
                    v_countNEW1_NEW := 0;

                    SELECT COUNT(*), "FMOP_Id"::TEXT INTO v_countNEW1_NEW, v_id_NEW
                    FROM "clg"."Feedback_College_Student_Transaction"
                    WHERE "MI_Id" = p_MI_Id::BIGINT AND "ASMAY_Id" = p_ASMAY_Id::BIGINT
                        AND "FCSTR_StudParFlg" = p_Flag AND "FMTY_Id" = p_Type::BIGINT 
                        AND "FMQE_Id" = v_QUESID_NEW::BIGINT AND "FMOP_Id" = v_OPTIONID_NEW::BIGINT 
                        AND "AMCO_Id" = v_AMCO_Id_NEW::BIGINT
                    GROUP BY "FMOP_Id";

                    v_countNEW1_NEW := COALESCE(v_countNEW1_NEW, 0);
                    v_countNEW_NEW := CAST((v_countNEW1_NEW * 100.0 / v_COUNT) AS NUMERIC(18,2));

                    IF v_countNEW1_NEW > 0 THEN
                        INSERT INTO temp_feedback_reporttemp_NEW_DETAILS 
                        VALUES (p_MI_Id, v_AMCO_Id_NEW::BIGINT, v_QUESTIONREMARKS_NEW, v_OPTIONREMARKS_NEW, 
                                v_QUESID_NEW::BIGINT, v_OPTIONID_NEW::BIGINT, v_countNEW1_NEW::BIGINT, v_countNEW_NEW);
                    ELSE
                        INSERT INTO temp_feedback_reporttemp_NEW_DETAILS 
                        VALUES (p_MI_Id, v_AMCO_Id_NEW::BIGINT, v_QUESTIONREMARKS_NEW, v_OPTIONREMARKS_NEW, 
                                v_QUESID_NEW::BIGINT, v_OPTIONID_NEW::BIGINT, 0, 0);
                    END IF;
                END LOOP;
            END LOOP;
        END LOOP;

        RETURN QUERY SELECT t.miid, t.amcoid, NULL::BIGINT AS amseid, NULL::TEXT AS semnameyear, 
                            t.remarks, t.options, t.qid, t.opid, t.count, t.total, NULL::TEXT AS coursename
                     FROM temp_feedback_reporttemp_NEW_DETAILS t;

    ELSIF p_FlagType = 'question' THEN
        IF p_GraphType = 'columnper' THEN
            CREATE TEMP TABLE temp_feedback_reporttemp_NEW_DETAILS_QUESTION (
                miid TEXT,
                amcoid BIGINT,
                remarks TEXT,
                options TEXT,
                qid BIGINT,
                opid BIGINT,
                count BIGINT,
                total NUMERIC(18,2),
                coursename TEXT
            );

            FOR rec_course IN
                SELECT DISTINCT C."AMCO_Id", C."AMCO_CourseName", C."AMCO_Order", COUNT(DISTINCT g."AMCST_Id") AS COUNT_VAL
                FROM "CLG"."Adm_College_AY_Course" A 
                INNER JOIN "Adm_School_M_Academic_Year" B ON A."ASMAY_Id" = B."ASMAY_Id"
                INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id" = A."AMCO_Id"
                INNER JOIN "CLG"."Adm_College_Yearly_Student" D ON D."AMCO_Id" = C."AMCO_Id" AND D."ASMAY_Id" = B."ASMAY_Id"
                INNER JOIN "CLG"."Adm_Master_College_Student" E ON E."AMCST_Id" = D."AMCST_Id"
                INNER JOIN "CLG"."Feedback_College_Student_Transaction" G ON G."AMCO_Id" = A."AMCO_Id" AND G."ASMAY_Id" = p_ASMAY_Id::BIGINT
                WHERE A."ASMAY_Id" = p_ASMAY_Id::BIGINT AND A."MI_Id" = p_MI_Id::BIGINT 
                    AND A."ACAYC_ActiveFlag" = TRUE AND C."AMCO_ActiveFlag" = TRUE 
                    AND D."ACYST_ActiveFlag" = TRUE AND E."AMCST_SOL" = 'S' AND E."AMCST_ActiveFlag" = TRUE
                    AND g."FMTY_Id" = p_Type::BIGINT AND g."FMQE_Id" = p_FMQE_Id::BIGINT AND g."FCSTR_StudParFlg" = p_Flag
                GROUP BY C."AMCO_Id", C."AMCO_CourseName", C."AMCO_Order"
                ORDER BY C."AMCO_Order"
            LOOP
                v_AMCOID_ID := rec_course."AMCO_Id"::TEXT;
                v_AMCOID_COURSENAME := rec_course."AMCO_CourseName";
                v_AMCOID_ORDERNew := rec_course."AMCO_Order"::TEXT;
                v_COUNT := rec_course.COUNT_VAL;

                FOR rec_question IN
                    SELECT DISTINCT c."FMQE_Id", c."FMQE_FeedbackQRemarks", c."FMQE_FQOrder"
                    FROM "Feedback_Type_Questions" A 
                    INNER JOIN "Feedback_Master_Type" B ON A."FMTY_Id" = B."FMTY_Id"
                    INNER JOIN "Feedback_Master_Questions" C ON C."FMQE_Id" = A."FMQE_Id"
                    WHERE C."MI_Id" = p_MI_Id::BIGINT AND A."MI_Id" = p_MI_Id::BIGINT AND B."MI_Id" = p_MI_Id::BIGINT 
                        AND A."FMTQ_ActiveFlag" = TRUE AND B."FMTY_ActiveFlag" = TRUE AND C."FMQE_ActiveFlag" = TRUE 
                        AND A."FMQE_Id" = p_FMQE_Id::BIGINT AND C."FMQE_Id" = p_FMQE_Id::BIGINT
                        AND A."FMTY_Id" = p_Type::BIGINT AND B."FMTY_StakeHolderFlag" = p_Flag
                    ORDER BY C."FMQE_FQOrder"
                LOOP
                    v_QUESTIONID := rec_question."FMQE_Id"::TEXT;
                    v_QUESTIONNAME := rec_question."FMQE_FeedbackQRemarks";
                    v_QUESTIONORDERNEW := rec_question."FMQE_FQOrder"::TEXT;

                    FOR rec_option IN
                        SELECT DISTINCT c."FMOP_Id", c."FMOP_FeedbackOptions", c."FMOP_FOOrder"
                        FROM "Feedback_Type_Options" A 
                        INNER JOIN "Feedback_Master_Type" B ON A."FMTY_Id" = B."FMTY_Id"
                        INNER JOIN "Feedback_Master_Options" C ON C."FMOP_Id" = A."FMOP_Id"
                        WHERE C."MI_Id" = p_MI_Id::BIGINT AND A."MI_Id" = p_MI_Id::BIGINT AND B."MI_Id" = p_MI_Id::BIGINT 
                            AND A."FMTO_ActiveFlag" = TRUE AND B."FMTY_ActiveFlag" = TRUE AND C."FMOP_ActiveFlag" = TRUE
                            AND A."FMTY_Id" = p_Type::BIGINT AND B."FMTY_StakeHolderFlag" = p_Flag
                        ORDER BY C."FMOP_FOOrder"
                    LOOP
                        v_OPTIONIDNEW := rec_option."FMOP_Id"::TEXT;
                        v_OPTIONNAME := rec_option."FMOP_FeedbackOptions";
                        v_OPTIONORDERNEW := rec_option."FMOP_FOOrder"::TEXT;

                        v_countNEW_NEW1 := 0;
                        v_countNEW1_NEW1 := 0;

                        SELECT COUNT(*), "FMOP_Id"::TEXT INTO v_countNEW1_NEW1, v_id_NEW1
                        FROM "clg"."Feedback_College_Student_Transaction"
                        WHERE "MI_Id" = p_MI_Id::BIGINT AND p_ASMAY_Id::BIGINT = p_ASMAY_Id::BIGINT
                            AND "FCSTR_StudParFlg" = p_Flag AND "FMTY_Id" = p_Type::BIGINT 
                            AND "FMQE_Id" = v_QUESTIONID::BIGINT AND "FMOP_Id" = v_OPTIONIDNEW::BIGINT 
                            AND "AMCO_Id" = v_AMCOID_ID::BIGINT
                        GROUP BY "FMOP_Id";

                        v_countNEW1_NEW1 := COALESCE(v_countNEW1_NEW1, 0);
                        v_countNEW_NEW1 := CAST((v_countNEW1_NEW1 * 100.0 / v_COUNT) AS NUMERIC(18,2));

                        IF v_countNEW1_NEW1 > 0 THEN
                            INSERT INTO temp_feedback_reporttemp_NEW_DETAILS_QUESTION 
                            VALUES (p_MI_Id, v_AMCOID_ID::BIGINT, v_QUESTIONNAME, v_OPTIONNAME, 
                                    v_QUESTIONID::BIGINT, v_OPTIONIDNEW::BIGINT, v_countNEW1_NEW1::BIGINT, 
                                    v_countNEW_NEW1, v_AMCOID_COURSENAME);
                        ELSE
                            INSERT INTO temp_feedback_reporttemp_NEW_DETAILS_QUESTION 
                            VALUES (p_MI_Id, v_AMCOID_ID::BIGINT, v_QUESTIONNAME, v_OPTIONNAME, 
                                    v_QUESTIONID::BIGINT, v_OPTIONIDNEW::BIGINT, 0, 0, v_AMCOID_COURSENAME);
                        END IF;
                    END LOOP;
                END LOOP;
            END LOOP;

            RETURN QUERY SELECT t.miid, t.amcoid, NULL::BIGINT AS amseid, NULL::TEXT AS semnameyear, 
                                t.remarks, t.options, t.qid, t.opid, t.count, t.total, t.coursename
                         FROM temp_feedback_reporttemp_NEW_DETAILS_QUESTION t;

        ELSIF p_GraphType = 'columnno' THEN
            CREATE TEMP TABLE temp_feedback_reporttemp_NEW_DETAILS_QUESTION_NO (
                miid TEXT,
                amcoid BIGINT,
                remarks TEXT,
                options TEXT,
                qid BIGINT,
                opid BIGINT,
                count BIGINT,
                total NUMERIC(18,2),
                coursename TEXT
            );

            FOR rec_course IN
                SELECT DISTINCT C."AMCO_Id", C."AMCO_CourseName", C."AMCO_Order", COUNT(*) AS COUNT_VAL
                FROM "CLG"."Adm_College_AY_Course" A 
                INNER JOIN "Adm_School_M_Academic_Year" B ON A."ASMAY_Id" = B."ASMAY_Id"
                INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id" = A."AMCO_Id"
                INNER JOIN "CLG"."Adm_College_Yearly_Student" D ON D."AMCO_Id" = C."AMCO_Id" AND D."ASMAY_Id" = B."ASMAY_Id"
                INNER JOIN "CLG"."Adm_Master_College_Student" E ON E."AMCST_Id" = D."AMCST_Id"
                WHERE A."ASMAY_Id" = p_ASMAY_Id::BIGINT AND A."MI_Id" = p_MI_Id::BIGINT 
                    AND A."ACAYC_ActiveFlag" = TRUE AND C."AMCO_ActiveFlag" = TRUE 
                    AND D."ACYST_ActiveFlag" = TRUE AND E."AMCST_SOL" = 'S' AND E."AMCST_ActiveFlag" = TRUE
                GROUP BY C."AMCO_Id", C."AMCO_CourseName", C."AMCO_Order"
                ORDER BY C."AMCO_Order"
            LOOP
                v_AMCOID_ID_no := rec_course."AMCO_Id"::TEXT;
                v_AMCOID_COURSENAME_no := rec_course