CREATE OR REPLACE FUNCTION "dbo"."College_Feedback_Report_CourseWise_ALumni"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_Flag TEXT,
    p_Type TEXT,
    p_FlagType TEXT,
    p_FMQE_Id TEXT,
    p_GraphType TEXT
)
RETURNS TABLE (
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
) 
LANGUAGE plpgsql
AS $$
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
    rec RECORD;
BEGIN

    IF p_FlagType='Yearwise' THEN
    
        DROP TABLE IF EXISTS temp_feedback_reporttemp_NEW;
        
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

        FOR rec IN 
            SELECT C."AMCO_Id", C."AMCO_CourseName", E."AMSE_Id", E."AMSE_Year", C."AMCO_Order", COUNT(*) AS COUNT
            FROM "CLG"."Alumni_College_Master_Student" A
            INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id"=A."AMCO_Left_Id"
            INNER JOIN "CLG"."Adm_Master_Branch" D ON D."AMB_Id"=A."AMB_Id_Left"
            INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id"=A."AMSE_Id_Left"
            INNER JOIN "Adm_School_M_Academic_Year" F ON A."ASMAY_Id_Left"=F."ASMAY_Id"
            WHERE A."ASMAY_Id_Left"=p_ASMAY_Id AND A."AMCO_Left_Id"=p_AMCO_Id
            GROUP BY C."AMCO_Id", C."AMCO_CourseName", E."AMSE_Id", E."AMSE_Year", C."AMCO_Order"
            ORDER BY C."AMCO_Order"
        LOOP
            v_AMCO_Id_NEW := rec."AMCO_Id"::TEXT;
            v_AMCO_CourseName := rec."AMCO_CourseName";
            v_AMSE_Id := rec."AMSE_Id"::TEXT;
            v_AMSE_SEMName := rec."AMSE_Year";
            v_AMCOID_Order := rec."AMCO_Order";
            v_COUNT := rec.COUNT;

            FOR rec IN 
                SELECT DISTINCT c."FMQE_Id", c."FMQE_FeedbackQRemarks", c."FMQE_FQOrder"
                FROM "Feedback_Type_Questions" A
                INNER JOIN "Feedback_Master_Type" B ON A."FMTY_Id"=B."FMTY_Id"
                INNER JOIN "Feedback_Master_Questions" C ON C."FMQE_Id"=A."FMQE_Id"
                WHERE C."MI_Id"=p_MI_Id AND A."MI_Id"=p_MI_Id AND B."MI_Id"=p_MI_Id 
                AND A."FMTQ_ActiveFlag"=true AND B."FMTY_ActiveFlag"=true AND C."FMQE_ActiveFlag"=true
                AND A."FMTY_Id"=p_Type AND B."FMTY_StakeHolderFlag"=p_Flag
                ORDER BY C."FMQE_FQOrder"
            LOOP
                v_QUESID := rec."FMQE_Id"::TEXT;
                v_QUESTIONREMARKS := rec."FMQE_FeedbackQRemarks";
                v_QUESTIONORDER := rec."FMQE_FQOrder"::TEXT;

                FOR rec IN 
                    SELECT DISTINCT c."FMOP_Id", c."FMOP_FeedbackOptions", c."FMOP_FOOrder"
                    FROM "Feedback_Type_Options" A
                    INNER JOIN "Feedback_Master_Type" B ON A."FMTY_Id"=B."FMTY_Id"
                    INNER JOIN "Feedback_Master_Options" C ON C."FMOP_Id"=A."FMOP_Id"
                    WHERE C."MI_Id"=p_MI_Id AND A."MI_Id"=p_MI_Id AND B."MI_Id"=p_MI_Id 
                    AND A."FMTO_ActiveFlag"=true AND B."FMTY_ActiveFlag"=true AND C."FMOP_ActiveFlag"=true
                    AND A."FMTY_Id"=p_Type AND B."FMTY_StakeHolderFlag"=p_Flag
                    ORDER BY C."FMOP_FOOrder"
                LOOP
                    v_OPTIONID := rec."FMOP_Id"::TEXT;
                    v_OPTIONREMARKS := rec."FMOP_FeedbackOptions";
                    v_OPTIONORDER := rec."FMOP_FOOrder"::TEXT;

                    v_countNEW := 0;
                    v_countNEW1 := 0;

                    SELECT COUNT(*), a."FMOP_Id"::TEXT
                    INTO v_countNEW1, v_id
                    FROM "CLG"."Feedback_College_Alumni_Transaction" a 
                    INNER JOIN "CLG"."Alumni_College_Student_Registration" b ON a."ALCSREG_Id"=b."ALCSREG_Id"
                    INNER JOIN "CLG"."Alumni_College_Master_Student" c ON b."AMCST_Id"=c."ALCMST_Id"
                    WHERE c."MI_Id"=p_MI_Id AND c."ASMAY_Id_Left"=p_ASMAY_Id
                    AND a."FMTY_Id"=p_Type AND a."FMQE_Id"=v_QUESID::BIGINT AND a."FMOP_Id"=v_OPTIONID::BIGINT 
                    AND c."AMCO_Left_Id"=v_AMCO_Id_NEW::BIGINT AND c."AMSE_Id_Left"=v_AMSE_Id::BIGINT
                    GROUP BY a."FMOP_Id";

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

        RETURN QUERY SELECT t.miid, t.amcoid, t.amseid, t.semnameyear, t.remarks, 
                            t.options, t.qid, t.opid, t.count, t.total, NULL::TEXT AS coursename
                     FROM temp_feedback_reporttemp_NEW t;

    ELSIF p_FlagType='Overall' THEN
    
        DROP TABLE IF EXISTS temp_feedback_reporttemp_NEW_DETAILS;
        
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

        FOR rec IN 
            SELECT C."AMCO_Id", C."AMCO_CourseName", C."AMCO_Order", COUNT(*) AS COUNT
            FROM "CLG"."Alumni_College_Master_Student" A
            INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id"=A."AMCO_Left_Id"
            INNER JOIN "CLG"."Adm_Master_Branch" D ON D."AMB_Id"=A."AMB_Id_Left"
            INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id"=A."AMSE_Id_Left"
            INNER JOIN "Adm_School_M_Academic_Year" F ON A."ASMAY_Id_Left"=F."ASMAY_Id"
            WHERE A."ASMAY_Id_Left"=p_ASMAY_Id AND A."AMCO_Left_Id"=p_AMCO_Id
            GROUP BY C."AMCO_Id", C."AMCO_CourseName", E."AMSE_Id", E."AMSE_Year", C."AMCO_Order"
            ORDER BY C."AMCO_Order"
        LOOP
            v_AMCO_Id_NEW := rec."AMCO_Id"::TEXT;
            v_AMCO_CourseName := rec."AMCO_CourseName";
            v_AMCOID_Order := rec."AMCO_Order";
            v_COUNT := rec.COUNT;

            FOR rec IN 
                SELECT DISTINCT c."FMQE_Id", c."FMQE_FeedbackQRemarks", c."FMQE_FQOrder"
                FROM "Feedback_Type_Questions" A
                INNER JOIN "Feedback_Master_Type" B ON A."FMTY_Id"=B."FMTY_Id"
                INNER JOIN "Feedback_Master_Questions" C ON C."FMQE_Id"=A."FMQE_Id"
                WHERE C."MI_Id"=p_MI_Id AND A."MI_Id"=p_MI_Id AND B."MI_Id"=p_MI_Id 
                AND A."FMTQ_ActiveFlag"=true AND B."FMTY_ActiveFlag"=true AND C."FMQE_ActiveFlag"=true
                AND A."FMTY_Id"=p_Type AND B."FMTY_StakeHolderFlag"=p_Flag
                ORDER BY C."FMQE_FQOrder"
            LOOP
                v_QUESID_NEW := rec."FMQE_Id"::TEXT;
                v_QUESTIONREMARKS_NEW := rec."FMQE_FeedbackQRemarks";
                v_QUESTIONORDER_NEW := rec."FMQE_FQOrder"::TEXT;

                FOR rec IN 
                    SELECT DISTINCT c."FMOP_Id", c."FMOP_FeedbackOptions", c."FMOP_FOOrder"
                    FROM "Feedback_Type_Options" A
                    INNER JOIN "Feedback_Master_Type" B ON A."FMTY_Id"=B."FMTY_Id"
                    INNER JOIN "Feedback_Master_Options" C ON C."FMOP_Id"=A."FMOP_Id"
                    WHERE C."MI_Id"=p_MI_Id AND A."MI_Id"=p_MI_Id AND B."MI_Id"=p_MI_Id 
                    AND A."FMTO_ActiveFlag"=true AND B."FMTY_ActiveFlag"=true AND C."FMOP_ActiveFlag"=true
                    AND A."FMTY_Id"=p_Type AND B."FMTY_StakeHolderFlag"=p_Flag
                    ORDER BY C."FMOP_FOOrder"
                LOOP
                    v_OPTIONID_NEW := rec."FMOP_Id"::TEXT;
                    v_OPTIONREMARKS_NEW := rec."FMOP_FeedbackOptions";
                    v_OPTIONORDER_NEW := rec."FMOP_FOOrder"::TEXT;

                    v_countNEW_NEW := 0;
                    v_countNEW1_NEW := 0;

                    SELECT COUNT(*), a."FMOP_Id"::TEXT
                    INTO v_countNEW1_NEW, v_id_NEW
                    FROM "CLG"."Feedback_College_Alumni_Transaction" a 
                    INNER JOIN "CLG"."Alumni_College_Student_Registration" b ON a."ALCSREG_Id"=b."ALCSREG_Id"
                    INNER JOIN "CLG"."Alumni_College_Master_Student" c ON b."AMCST_Id"=c."ALCMST_Id"
                    WHERE c."MI_Id"=p_MI_Id AND c."ASMAY_Id_Left"=p_ASMAY_Id
                    AND a."FMTY_Id"=p_Type AND a."FMQE_Id"=v_QUESID_NEW::BIGINT AND a."FMOP_Id"=v_OPTIONID_NEW::BIGINT 
                    AND c."AMCO_Left_Id"=v_AMCO_Id_NEW::BIGINT
                    GROUP BY a."FMOP_Id";

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

    ELSIF p_FlagType='question' THEN
    
        IF p_GraphType='columnper' THEN
        
            DROP TABLE IF EXISTS temp_feedback_reporttemp_NEW_DETAILS_QUESTION;
            
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

            FOR rec IN 
                SELECT DISTINCT C."AMCO_Id", C."AMCO_CourseName", C."AMCO_Order", COUNT(*) AS COUNT
                FROM "CLG"."Alumni_College_Master_Student" A
                INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id"=A."AMCO_Left_Id"
                INNER JOIN "CLG"."Adm_Master_Branch" D ON D."AMB_Id"=A."AMB_Id_Left"
                INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id"=A."AMSE_Id_Left"
                INNER JOIN "Adm_School_M_Academic_Year" F ON A."ASMAY_Id_Left"=F."ASMAY_Id"
                WHERE A."ASMAY_Id_Left"=p_ASMAY_Id AND A."MI_Id"=p_MI_Id
                GROUP BY C."AMCO_Id", C."AMCO_CourseName", E."AMSE_Id", E."AMSE_Year", C."AMCO_Order"
                ORDER BY C."AMCO_Order"
            LOOP
                v_AMCOID_ID := rec."AMCO_Id"::TEXT;
                v_AMCOID_COURSENAME := rec."AMCO_CourseName";
                v_AMCOID_ORDERNew := rec."AMCO_Order"::TEXT;
                v_COUNT := rec.COUNT;

                FOR rec IN 
                    SELECT DISTINCT c."FMQE_Id", c."FMQE_FeedbackQRemarks", c."FMQE_FQOrder"
                    FROM "Feedback_Type_Questions" A
                    INNER JOIN "Feedback_Master_Type" B ON A."FMTY_Id"=B."FMTY_Id"
                    INNER JOIN "Feedback_Master_Questions" C ON C."FMQE_Id"=A."FMQE_Id"
                    WHERE C."MI_Id"=p_MI_Id AND A."MI_Id"=p_MI_Id AND B."MI_Id"=p_MI_Id 
                    AND A."FMTQ_ActiveFlag"=true AND B."FMTY_ActiveFlag"=true AND C."FMQE_ActiveFlag"=true 
                    AND A."FMQE_Id"=p_FMQE_Id::BIGINT AND C."FMQE_Id"=p_FMQE_Id::BIGINT
                    AND A."FMTY_Id"=p_Type AND B."FMTY_StakeHolderFlag"=p_Flag
                    ORDER BY C."FMQE_FQOrder"
                LOOP
                    v_QUESTIONID := rec."FMQE_Id"::TEXT;
                    v_QUESTIONNAME := rec."FMQE_FeedbackQRemarks";
                    v_QUESTIONORDERNEW := rec."FMQE_FQOrder"::TEXT;

                    FOR rec IN 
                        SELECT DISTINCT c."FMOP_Id", c."FMOP_FeedbackOptions", c."FMOP_FOOrder"
                        FROM "Feedback_Type_Options" A
                        INNER JOIN "Feedback_Master_Type" B ON A."FMTY_Id"=B."FMTY_Id"
                        INNER JOIN "Feedback_Master_Options" C ON C."FMOP_Id"=A."FMOP_Id"
                        WHERE C."MI_Id"=p_MI_Id AND A."MI_Id"=p_MI_Id AND B."MI_Id"=p_MI_Id 
                        AND A."FMTO_ActiveFlag"=true AND B."FMTY_ActiveFlag"=true AND C."FMOP_ActiveFlag"=true
                        AND A."FMTY_Id"=p_Type AND B."FMTY_StakeHolderFlag"=p_Flag
                        ORDER BY C."FMOP_FOOrder"
                    LOOP
                        v_OPTIONIDNEW := rec."FMOP_Id"::TEXT;
                        v_OPTIONNAME := rec."FMOP_FeedbackOptions";
                        v_OPTIONORDERNEW := rec."FMOP_FOOrder"::TEXT;

                        v_countNEW_NEW1 := 0;
                        v_countNEW1_NEW1 := 0;

                        SELECT COUNT(*), a."FMOP_Id"::TEXT
                        INTO v_countNEW1_NEW1, v_id_NEW1
                        FROM "CLG"."Feedback_College_Alumni_Transaction" a 
                        INNER JOIN "CLG"."Alumni_College_Student_Registration" b ON a."ALCSREG_Id"=b."ALCSREG_Id"
                        INNER JOIN "CLG"."Alumni_College_Master_Student" c ON b."AMCST_Id"=c."ALCMST_Id"
                        WHERE c."MI_Id"=p_MI_Id AND c."ASMAY_Id_Left"=p_ASMAY_Id
                        AND a."FMTY_Id"=p_Type AND a."FMQE_Id"=v_QUESTIONID::BIGINT 
                        AND a."FMOP_Id"=v_OPTIONIDNEW::BIGINT AND c."AMCO_Left_Id"=v_AMCOID_ID::BIGINT
                        GROUP BY a."FMOP_Id";

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

        ELSIF p_GraphType='columnno' THEN
        
            DROP TABLE IF EXISTS temp_feedback_reporttemp_NEW_DETAILS_QUESTION_NO;
            
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

            FOR rec IN 
                SELECT DISTINCT C."AMCO_Id", C."AMCO_CourseName", C."AMCO_Order", COUNT(*) AS COUNT
                FROM "CLG"."Alumni_College_Master_Student" A
                INNER JOIN "CLG"."Adm_Master_Course" C ON C."AMCO_Id"=A."AMCO_Left_Id"
                INNER JOIN "CLG"."Adm_Master_Branch" D ON D."AMB_Id"=A."AMB_Id_Left"
                INNER JOIN "CLG"."Adm_Master_Semester" E ON E."AMSE_Id"=A."AMSE_Id_Left"
                INNER JOIN "Adm_School_M_Academic_Year" F ON A."ASMAY_Id_Left"=F."ASMAY_Id"
                WHERE A."ASMAY_Id_Left"=p_ASMAY_Id AND A."MI_Id"=p_MI_Id
                GROUP BY C."AMCO_Id", C."AMCO_CourseName", E."AMSE_Id", E."AMSE_Year", C."AMCO_Order"
                ORDER BY C."AMCO_Order"
            LOOP
                v_AMCOID_ID_no := rec."AMCO_Id"::TEXT;
                v_AMCOID_COURSENAME_no := rec."AMCO_CourseName";
                v_AMCOID_ORDERNew_no := rec."AMCO_Order"::TEXT;
                v_COUNT := rec.COUNT;

                FOR rec IN 
                    SELECT DISTINCT c."FMQE_Id", c."FMQE_FeedbackQRemarks", c."FMQE_FQOrder"
                    FROM "Feedback_Type_Questions" A
                    INNER JOIN "Feedback_Master_Type" B ON A."FMTY_Id"=B."FMTY_Id"
                    INNER JOIN "Feedback_Master_Questions" C ON C."FMQE_Id"=A."FMQE_Id"
                    WHERE C."MI_Id"=p_MI_Id AND A."MI_Id"=p_MI_Id AND B."MI_Id"=p_MI_Id 
                    AND A."FMTQ_ActiveFlag"=true AND B."FMTY_ActiveFlag"=true AND C."FMQE_ActiveFlag"=true 
                    AND A."FMQE_Id"=p_FMQE_Id::BIGINT AND C."FMQE_Id"=p_FMQE_Id::BIGINT
                    AND A."FMTY_Id"=p_Type AND B."FMTY_StakeHolderFlag"=p_Flag
                    ORDER BY C."FMQE_FQOrder"
                LOOP
                    v_QUESTIONID_no := rec."FMQE_Id"::TEXT;
                    v_QUESTIONNAME_no := rec."FMQE_FeedbackQRemarks";
                    v_QUESTIONORDERNEW_no := rec."FMQE_FQOrder"::TEXT;

                    FOR rec IN 
                        SELECT DISTINCT c."FMOP_Id", c."FMOP_FeedbackOptions", c."FMOP_FOOrder"
                        FROM "Feedback_Type_Options" A
                        INNER JOIN "Feedback_Master_Type" B ON A."FMTY_Id"=B."FMTY_Id"
                        INNER JOIN "Feedback_Master_Options" C ON C."FMOP_Id"=A."FMOP_Id"
                        WHERE C."MI_Id"=p_MI_Id AND A."MI_Id"=p_MI_Id AND B."MI_Id"=p_MI_Id 
                        AND A."FMTO_ActiveFlag"=true AND B."FMTY_ActiveFlag"=true AND C."FMOP_ActiveFlag"=true
                        AND A."FMTY_Id"=p_Type AND B."FMTY_StakeHolderFlag"=p_Flag
                        ORDER BY C."FMOP_FOOrder"
                    LOOP
                        v_OPTIONIDNEW_no := rec."FMOP_Id"::TEXT