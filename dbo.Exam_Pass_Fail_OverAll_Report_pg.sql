CREATE OR REPLACE FUNCTION "dbo"."Exam_Pass_Fail_OverAll_Report"(
    p_MI_id TEXT,
    p_asmay_id TEXT,
    p_asmcl_id TEXT,
    p_asms_id TEXT,
    p_flag TEXT,
    p_eme_id TEXT,
    p_amst_id TEXT,
    p_emca_id TEXT
)
RETURNS TABLE(
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "Strength" BIGINT,
    "Pass" BIGINT,
    "Fail" BIGINT,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    "AMST_FirstName" TEXT,
    "ISMS_SubjectName" VARCHAR,
    "Exam" VARCHAR,
    "ESTMPS_PassFailFlg" VARCHAR,
    "EME_ExamOrder" INTEGER,
    "ISMS_OrderFlag" INTEGER,
    "ESTMPS_ObtainedMarks" NUMERIC,
    "ESTMPS_MaxMarks" NUMERIC,
    "AMST_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_flag = 'all' THEN
        RETURN QUERY
        SELECT 
            (mailf.classname)::"varchar" AS "ASMCL_ClassName",
            (mailf.sectionname)::"varchar" AS "ASMC_SectionName",
            SUM(mailf."Strength") AS "Strength",
            SUM(mailf."Pass") AS "Pass",
            SUM(mailf."Fail") AS "Fail",
            mailf."ASMCL_Order",
            mailf."ASMC_Order",
            NULL::TEXT AS "AMST_FirstName",
            NULL::"varchar" AS "ISMS_SubjectName",
            NULL::"varchar" AS "Exam",
            NULL::"varchar" AS "ESTMPS_PassFailFlg",
            NULL::INTEGER AS "EME_ExamOrder",
            NULL::INTEGER AS "ISMS_OrderFlag",
            NULL::NUMERIC AS "ESTMPS_ObtainedMarks",
            NULL::NUMERIC AS "ESTMPS_MaxMarks",
            NULL::BIGINT AS "AMST_Id"
        FROM (
            SELECT 
                c."ASMCL_ClassName" AS classname,
                d."ASMC_SectionName" AS sectionname,
                c."ASMCL_Order" AS "ASMCL_Order",
                d."ASMC_Order" AS "ASMC_Order",
                COUNT(DISTINCT a."AMST_Id") AS "Strength",
                0::BIGINT AS "Pass",
                0::BIGINT AS "Fail"
            FROM "Adm_School_Y_Student" a 
            INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = a."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" d ON d."ASMS_Id" = a."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = a."ASMAY_Id"
            INNER JOIN "Exm"."Exm_Category_Class" f ON f."ASMAY_Id" = e."ASMAY_Id" AND f."ASMCL_Id" = c."ASMCL_Id" AND f."ASMS_Id" = d."ASMS_Id" AND f."ECAC_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_Master_Category" g ON g."EMCA_Id" = f."emca_id" AND g."EMCA_ActiveFlag" = 1
            WHERE b."MI_Id" = p_MI_id AND a."ASMAY_Id" = p_asmay_id AND "AMST_SOL" = 'S' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1 
                AND f."ASMAY_Id" = p_asmay_id AND f."EMCA_Id" = p_emca_id
            GROUP BY c."ASMCL_ClassName", d."ASMC_SectionName", c."ASMCL_Order", d."ASMC_Order"
            
            UNION ALL
            
            SELECT 
                d."ASMCL_ClassName" AS classname,
                e."ASMC_SectionName" AS sectionname,
                d."ASMCL_Order" AS "ASMCL_Order",
                e."ASMC_Order" AS "ASMC_Order",
                0::BIGINT AS "Strength",
                COUNT(a."ESTMP_Result") AS "Pass",
                0::BIGINT AS "Fail"
            FROM "exm"."Exm_Student_Marks_Process" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id"
            INNER JOIN "Exm"."Exm_Category_Class" g ON g."ASMAY_Id" = f."ASMAY_Id" AND g."ASMCL_Id" = d."ASMCL_Id" AND g."ASMS_Id" = e."ASMS_Id" AND g."ECAC_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_Master_Category" h ON h."EMCA_Id" = g."EMCA_Id" AND h."EMCA_ActiveFlag" = 1
            WHERE a."mi_id" = p_MI_id AND a."ASMAY_Id" = p_asmay_id AND "EME_Id" = p_eme_id AND b."ASMAY_Id" = p_asmay_id 
                AND a."ESTMP_Result" = 'PASS' AND "AMST_SOL" = 'S' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1 
                AND g."EMCA_Id" = p_emca_id AND g."ASMAY_Id" = p_asmay_id
            GROUP BY d."ASMCL_ClassName", e."ASMC_SectionName", d."ASMCL_Order", e."ASMC_Order"
            
            UNION ALL
            
            SELECT 
                d."ASMCL_ClassName" AS classname,
                e."ASMC_SectionName" AS sectionname,
                d."ASMCL_Order" AS "ASMCL_Order",
                e."ASMC_Order" AS "ASMC_Order",
                0::BIGINT AS "Strength",
                0::BIGINT AS "Pass",
                COUNT(a."ESTMP_Result") AS "Fail"
            FROM "exm"."Exm_Student_Marks_Process" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = a."AMST_Id"
            INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id"
            INNER JOIN "Exm"."Exm_Category_Class" g ON g."ASMAY_Id" = f."ASMAY_Id" AND g."ASMCL_Id" = d."ASMCL_Id" AND g."ASMS_Id" = e."ASMS_Id" AND g."ECAC_ActiveFlag" = 1
            INNER JOIN "Exm"."Exm_Master_Category" h ON h."EMCA_Id" = g."EMCA_Id" AND h."EMCA_ActiveFlag" = 1
            WHERE a."mi_id" = p_MI_id AND a."ASMAY_Id" = p_asmay_id AND "EME_Id" = p_eme_id AND b."ASMAY_Id" = p_asmay_id 
                AND a."ESTMP_Result" = 'Fail' AND "AMST_SOL" = 'S' AND "AMST_ActiveFlag" = 1 AND "AMAY_ActiveFlag" = 1 
                AND g."EMCA_Id" = p_emca_id AND g."ASMAY_Id" = p_asmay_id
            GROUP BY d."ASMCL_ClassName", e."ASMC_SectionName", d."ASMCL_Order", e."ASMC_Order"
        ) mailf
        GROUP BY mailf.classname, mailf.sectionname, mailf."ASMCL_Order", mailf."ASMC_Order"
        ORDER BY mailf."ASMCL_Order", mailf."ASMC_Order";
    END IF;

    IF p_flag = 'individual' THEN
        IF p_asms_id = '0' THEN
            RETURN QUERY
            SELECT 
                (mailf.classname)::"varchar" AS "ASMCL_ClassName",
                (mailf.sectionname)::"varchar" AS "ASMC_SectionName",
                SUM(mailf."Strength") AS "Strength",
                SUM(mailf."Pass") AS "Pass",
                SUM(mailf."Fail") AS "Fail",
                mailf."ASMCL_Order",
                mailf."ASMC_Order",
                NULL::TEXT AS "AMST_FirstName",
                NULL::"varchar" AS "ISMS_SubjectName",
                NULL::"varchar" AS "Exam",
                NULL::"varchar" AS "ESTMPS_PassFailFlg",
                NULL::INTEGER AS "EME_ExamOrder",
                NULL::INTEGER AS "ISMS_OrderFlag",
                NULL::NUMERIC AS "ESTMPS_ObtainedMarks",
                NULL::NUMERIC AS "ESTMPS_MaxMarks",
                NULL::BIGINT AS "AMST_Id"
            FROM (
                SELECT 
                    c."ASMCL_ClassName" AS classname,
                    d."ASMC_SectionName" AS sectionname,
                    c."ASMCL_Order" AS "ASMCL_Order",
                    d."ASMC_Order" AS "ASMC_Order",
                    COUNT(DISTINCT a."AMST_Id") AS "Strength",
                    0::BIGINT AS "Pass",
                    0::BIGINT AS "Fail"
                FROM "Adm_School_Y_Student" a 
                INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = a."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" d ON d."ASMS_Id" = a."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = b."ASMAY_Id"
                WHERE b."MI_Id" = p_MI_id AND a."ASMAY_Id" = p_asmay_id AND "AMST_SOL" = 'S' AND "AMST_ActiveFlag" = 1 
                    AND "AMAY_ActiveFlag" = 1 AND c."ASMCL_Id" = p_asmcl_id
                GROUP BY c."ASMCL_ClassName", d."ASMC_SectionName", c."ASMCL_Order", d."ASMC_Order"
                
                UNION ALL
                
                SELECT 
                    d."ASMCL_ClassName" AS classname,
                    e."ASMC_SectionName" AS sectionname,
                    d."ASMCL_Order" AS "ASMCL_Order",
                    e."ASMC_Order" AS "ASMC_Order",
                    0::BIGINT AS "Strength",
                    COUNT(a."ESTMP_Result") AS "Pass",
                    0::BIGINT AS "Fail"
                FROM "exm"."Exm_Student_Marks_Process" a
                INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = a."AMST_Id"
                INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id"
                WHERE a."mi_id" = p_MI_id AND a."ASMAY_Id" = p_asmay_id AND "EME_Id" = p_eme_id 
                    AND b."ASMAY_Id" = p_asmay_id AND a."ESTMP_Result" = 'PASS' AND d."ASMCL_Id" = p_asmcl_id
                GROUP BY d."ASMCL_ClassName", e."ASMC_SectionName", d."ASMCL_Order", e."ASMC_Order"
                
                UNION ALL
                
                SELECT 
                    d."ASMCL_ClassName" AS classname,
                    e."ASMC_SectionName" AS sectionname,
                    d."ASMCL_Order" AS "ASMCL_Order",
                    e."ASMC_Order" AS "ASMC_Order",
                    0::BIGINT AS "Strength",
                    0::BIGINT AS "Pass",
                    COUNT(a."ESTMP_Result") AS "Fail"
                FROM "exm"."Exm_Student_Marks_Process" a
                INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = a."AMST_Id"
                INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id"
                WHERE a."mi_id" = p_MI_id AND a."ASMAY_Id" = p_asmay_id AND "EME_Id" = p_eme_id 
                    AND b."ASMAY_Id" = p_asmay_id AND a."ESTMP_Result" = 'Fail' AND d."ASMCL_Id" = p_asmcl_id
                GROUP BY d."ASMCL_ClassName", e."ASMC_SectionName", d."ASMCL_Order", e."ASMC_Order"
            ) mailf
            GROUP BY mailf.classname, mailf.sectionname, mailf."ASMCL_Order", mailf."ASMC_Order"
            ORDER BY mailf."ASMCL_Order", mailf."ASMC_Order";
        ELSE
            RETURN QUERY
            SELECT 
                (mailf.classname)::"varchar" AS "ASMCL_ClassName",
                (mailf.sectionname)::"varchar" AS "ASMC_SectionName",
                SUM(mailf."Strength") AS "Strength",
                SUM(mailf."Pass") AS "Pass",
                SUM(mailf."Fail") AS "Fail",
                mailf."ASMCL_Order",
                mailf."ASMC_Order",
                NULL::TEXT AS "AMST_FirstName",
                NULL::"varchar" AS "ISMS_SubjectName",
                NULL::"varchar" AS "Exam",
                NULL::"varchar" AS "ESTMPS_PassFailFlg",
                NULL::INTEGER AS "EME_ExamOrder",
                NULL::INTEGER AS "ISMS_OrderFlag",
                NULL::NUMERIC AS "ESTMPS_ObtainedMarks",
                NULL::NUMERIC AS "ESTMPS_MaxMarks",
                NULL::BIGINT AS "AMST_Id"
            FROM (
                SELECT 
                    c."ASMCL_ClassName" AS classname,
                    d."ASMC_SectionName" AS sectionname,
                    c."ASMCL_Order" AS "ASMCL_Order",
                    d."ASMC_Order" AS "ASMC_Order",
                    COUNT(DISTINCT a."AMST_Id") AS "Strength",
                    0::BIGINT AS "Pass",
                    0::BIGINT AS "Fail"
                FROM "Adm_School_Y_Student" a 
                INNER JOIN "Adm_M_Student" b ON a."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_School_M_Class" c ON c."ASMCL_Id" = a."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" d ON d."ASMS_Id" = a."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = b."ASMAY_Id"
                WHERE b."MI_Id" = p_MI_id AND a."ASMAY_Id" = p_asmay_id AND "AMST_SOL" = 'S' AND "AMST_ActiveFlag" = 1 
                    AND "AMAY_ActiveFlag" = 1 AND c."ASMCL_Id" = p_asmcl_id AND d."ASMS_Id" = p_asms_id
                GROUP BY c."ASMCL_ClassName", d."ASMC_SectionName", c."ASMCL_Order", d."ASMC_Order"
                
                UNION ALL
                
                SELECT 
                    d."ASMCL_ClassName" AS classname,
                    e."ASMC_SectionName" AS sectionname,
                    d."ASMCL_Order" AS "ASMCL_Order",
                    e."ASMC_Order" AS "ASMC_Order",
                    0::BIGINT AS "Strength",
                    COUNT(a."ESTMP_Result") AS "Pass",
                    0::BIGINT AS "Fail"
                FROM "exm"."Exm_Student_Marks_Process" a
                INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = a."AMST_Id"
                INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id"
                WHERE a."mi_id" = p_MI_id AND a."ASMAY_Id" = p_asmay_id AND "EME_Id" = p_eme_id 
                    AND b."ASMAY_Id" = p_asmay_id AND a."ESTMP_Result" = 'PASS' AND d."ASMCL_Id" = p_asmcl_id AND e."ASMS_Id" = p_asms_id
                GROUP BY d."ASMCL_ClassName", e."ASMC_SectionName", d."ASMCL_Order", e."ASMC_Order"
                
                UNION ALL
                
                SELECT 
                    d."ASMCL_ClassName" AS classname,
                    e."ASMC_SectionName" AS sectionname,
                    d."ASMCL_Order" AS "ASMCL_Order",
                    e."ASMC_Order" AS "ASMC_Order",
                    0::BIGINT AS "Strength",
                    0::BIGINT AS "Pass",
                    COUNT(a."ESTMP_Result") AS "Fail"
                FROM "exm"."Exm_Student_Marks_Process" a
                INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
                INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = a."AMST_Id"
                INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id"
                INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id"
                INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id"
                WHERE a."mi_id" = p_MI_id AND a."ASMAY_Id" = p_asmay_id AND "EME_Id" = p_eme_id 
                    AND b."ASMAY_Id" = p_asmay_id AND a."ESTMP_Result" = 'Fail' AND d."ASMCL_Id" = p_asmcl_id AND e."ASMS_Id" = p_asms_id
                GROUP BY d."ASMCL_ClassName", e."ASMC_SectionName", d."ASMCL_Order", e."ASMC_Order"
            ) mailf
            GROUP BY mailf.classname, mailf.sectionname, mailf."ASMCL_Order", mailf."ASMC_Order"
            ORDER BY mailf."ASMCL_Order", mailf."ASMC_Order";
        END IF;
    END IF;

    IF p_flag = 'Studentwise' THEN
        IF p_asms_id::INTEGER > 0 THEN
            RETURN QUERY
            SELECT 
                NULL::"varchar" AS "ASMCL_ClassName",
                NULL::"varchar" AS "ASMC_SectionName",
                NULL::BIGINT AS "Strength",
                NULL::BIGINT AS "Pass",
                NULL::BIGINT AS "Fail",
                g."ASMCL_Order",
                h."ASMC_Order",
                (COALESCE(a."AMST_FirstName", '') || ' ' || COALESCE(a."AMST_MiddleName", '') || ' ' || COALESCE(a."AMST_LastName", '') || ' : ' || COALESCE(a."AMST_AdmNo", '')) AS "AMST_FirstName",
                f."ISMS_SubjectName",
                d."EME_ExamName" AS "Exam",
                e."ESTMPS_PassFailFlg",
                d."EME_ExamOrder",
                f."ISMS_OrderFlag",
                e."ESTMPS_ObtainedMarks",
                e."ESTMPS_MaxMarks",
                a."AMST_Id"
            FROM "Adm_M_Student" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            INNER JOIN "exm"."Exm_Student_Marks_Process_Subjectwise" e ON b."AMST_Id" = e."AMST_Id"
            INNER JOIN "exm"."Exm_Master_Exam" d ON d."EME_Id" = e."EME_Id"
            INNER JOIN "IVRM_Master_Subjects" f ON e."ISMS_Id" = f."ISMS_Id"
            INNER JOIN "Adm_School_M_Class" g ON g."ASMCL_Id" = b."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" h ON h."ASMS_Id" = b."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" i ON i."ASMAY_Id" = b."ASMAY_Id"
            WHERE a."MI_Id" = p_MI_id AND b."ASMAY_Id" = p_asmay_id AND b."ASMCL_Id" = p_asmcl_id AND b."ASMS_Id" = p_asms_id 
                AND e."ASMAY_Id" = p_asmay_id AND e."ASMCL_Id" = p_asmcl_id AND e."ASMS_Id" = p_asms_id 
                AND "ESTMPS_PassFailFlg" = 'Fail' AND e."EME_ID" = p_eme_id
            ORDER BY g."ASMCL_Order", h."ASMC_Order", "AMST_FirstName", f."ISMS_OrderFlag";
        ELSE
            RETURN QUERY
            SELECT 
                NULL::"varchar" AS "ASMCL_ClassName",
                NULL::"varchar" AS "ASMC_SectionName",
                NULL::BIGINT AS "Strength",
                NULL::BIGINT AS "Pass",
                NULL::BIGINT AS "Fail",
                g."ASMCL_Order",
                h."ASMC_Order",
                (COALESCE(a."AMST_FirstName", '') || ' ' || COALESCE(a."AMST_MiddleName", '') || ' ' || COALESCE(a."AMST_LastName", '') || ' : ' || COALESCE(a."AMST_AdmNo", '')) AS "AMST_FirstName",
                f."ISMS_SubjectName",
                d."EME_ExamName" AS "Exam",
                e."ESTMPS_PassFailFlg",
                d."EME_ExamOrder",
                f."ISMS_OrderFlag",
                e."ESTMPS_ObtainedMarks",
                e."ESTMPS_MaxMarks",
                a."AMST_Id"
            FROM "Adm_M_Student" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            INNER JOIN "exm"."Exm_Student_Marks_Process_Subjectwise" e ON b."AMST_Id" = e."AMST_Id"
            INNER JOIN "exm"."Exm_Master_Exam" d ON d."EME_Id" = e."EME_Id"
            INNER JOIN "IVRM_Master_Subjects" f ON e."ISMS_Id" = f."ISMS_Id"
            INNER JOIN "Adm_School_M_Class" g ON g."ASMCL_Id" = b."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" h ON h."ASMS_Id" = b."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" i ON i."ASMAY_Id" = b."ASMAY_Id"
            WHERE a."MI_Id" = p_MI_id AND b."ASMAY_Id" = p_asmay_id AND b."ASMCL_Id" = p_asmcl_id 
                AND e."ASMAY_Id" = p_asmay_id AND e."ASMCL_Id" = p_asmcl_id AND e."EME_ID" = p_eme_id 
                AND "ESTMPS_PassFailFlg" = 'Fail'
            ORDER BY g."ASMCL_Order", h."ASMC_Order", "AMST_FirstName", f."ISMS_OrderFlag";
        END IF;
    END IF;

    IF p_flag = 'Medical' THEN
        IF p_asms_id = '0' THEN
            RETURN QUERY
            SELECT 
                g."ASMCL_ClassName",
                h."ASMC_SectionName",
                NULL::BIGINT AS "Strength",
                NULL::BIGINT AS "Pass",
                NULL::BIGINT AS "Fail",
                g."ASMCL_Order",
                h."ASMC_Order",
                (COALESCE(a."AMST_FirstName", '') || ' ' || COALESCE(a."AMST_MiddleName", '') || ' ' || COALESCE(a."AMST_LastName", '') || ' : ' || COALESCE(a."AMST_AdmNo", '')) AS "AMST_FirstName",
                f."ISMS_SubjectName",
                NULL::"varchar" AS "Exam",
                NULL::"varchar" AS "ESTMPS_PassFailFlg",
                NULL::INTEGER AS "EME_ExamOrder",
                f."ISMS_OrderFlag",
                NULL::NUMERIC AS "ESTMPS_ObtainedMarks",
                NULL::NUMERIC AS "ESTMPS_MaxMarks",
                a."AMST_Id"
            FROM "Adm_M_Student" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            INNER JOIN "exm"."Exm_Student_Marks_Process_Subjectwise" e ON b."AMST_Id" = e."AMST_Id"
            INNER JOIN "exm"."Exm_Master_Exam" d ON d."EME_Id" = e."EME_Id"
            INNER JOIN "IVRM_Master_Subjects" f ON e."ISMS_Id" =