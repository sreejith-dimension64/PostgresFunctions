CREATE OR REPLACE FUNCTION "dbo"."Exam_Topper_List_Report"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_ASMCL_Id" TEXT,
    "p_ASMS_Id" TEXT,
    "p_EME_Id" TEXT,
    "p_EMEFlag" TEXT,
    "p_Subjectflag" TEXT,
    "p_conditionflag" TEXT,
    "p_top" TEXT,
    "p_ISMS_Id" TEXT
)
RETURNS TABLE(
    "amsT_FirstName" TEXT,
    "amsT_AdmNo" TEXT,
    "asmcL_ClassName" TEXT,
    "asmC_SectionName" TEXT,
    "estmP_SectionRank" NUMERIC,
    "estmP_TotalMaxMarks" NUMERIC,
    "estmP_TotalObtMarks" NUMERIC,
    "estmP_Percentage" NUMERIC,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    "EME_ExamOrder" INTEGER,
    "EME_ExamName" TEXT,
    "estmpS_ObtainedMarks" NUMERIC,
    "estmpS_MaxMarks" NUMERIC,
    "estmpS_SectionHighest" NUMERIC,
    "RNO" BIGINT
)
LANGUAGE plpgsql
AS $$
BEGIN
    
    IF "p_conditionflag"::INTEGER = 1 THEN
        
        IF "p_EMEFlag"::INTEGER = 0 AND "p_Subjectflag"::INTEGER = 0 THEN
            
            RETURN QUERY
            SELECT 
                (COALESCE(c."AMST_FirstName",'') || ' ' || COALESCE(c."AMST_MiddleName",'') || ' ' || COALESCE(c."AMST_LastName",''))::TEXT AS "amsT_FirstName",
                c."AMST_AdmNo"::TEXT AS "amsT_AdmNo",
                d."ASMCL_ClassName"::TEXT,
                e."ASMC_SectionName"::TEXT,
                a."ESTMP_SectionRank",
                a."ESTMP_TotalMaxMarks",
                a."ESTMP_TotalObtMarks",
                a."ESTMP_Percentage",
                d."ASMCL_Order",
                e."ASMC_Order",
                g."EME_ExamOrder",
                g."EME_ExamName"::TEXT,
                NULL::NUMERIC AS "estmpS_ObtainedMarks",
                NULL::NUMERIC AS "estmpS_MaxMarks",
                NULL::NUMERIC AS "estmpS_SectionHighest",
                NULL::BIGINT AS "RNO"
            FROM "exm"."Exm_Student_Marks_Process" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id" AND a."ASMCL_Id" = d."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id" AND e."ASMS_Id" = a."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id" AND f."ASMAY_Id" = a."ASMAY_Id"
            INNER JOIN "exm"."Exm_Master_Exam" g ON g."EME_Id" = a."EME_Id"
            WHERE c."AMST_SOL" = 'S' 
                AND c."AMST_ActiveFlag" = TRUE 
                AND f."AMAY_ActiveFlag" = TRUE 
                AND c."MI_Id"::TEXT = "p_MI_Id" 
                AND a."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
                AND b."ASMAY_Id"::TEXT = "p_ASMAY_Id"
                AND a."ESTMP_SectionRank" <= "p_top"::INTEGER 
                AND a."ESTMP_SectionRank" != 0 
                AND a."ASMCL_Id"::TEXT = "p_ASMCL_Id" 
                AND b."ASMCL_Id"::TEXT = "p_ASMCL_Id"
            ORDER BY d."ASMCL_Order", e."ASMC_Order", a."ESTMP_SectionRank", "amsT_FirstName";
            
        ELSIF "p_EMEFlag"::INTEGER != 0 AND "p_Subjectflag"::INTEGER != 0 THEN
            
            RETURN QUERY
            SELECT * FROM (
                SELECT 
                    "Marks"."amsT_FirstName",
                    NULL::TEXT AS "amsT_AdmNo",
                    "Marks"."asmcL_ClassName",
                    "Marks"."asmC_SectionName",
                    NULL::NUMERIC AS "estmP_SectionRank",
                    NULL::NUMERIC AS "estmP_TotalMaxMarks",
                    NULL::NUMERIC AS "estmP_TotalObtMarks",
                    NULL::NUMERIC AS "estmP_Percentage",
                    "Marks"."ASMCL_Order",
                    "Marks"."ASMC_Order",
                    "Marks"."EME_ExamOrder",
                    "Marks"."EME_ExamName",
                    "Marks"."estmpS_ObtainedMarks",
                    "Marks"."estmpS_MaxMarks",
                    "Marks"."estmpS_SectionHighest",
                    ROW_NUMBER() OVER (PARTITION BY "Marks"."asmcL_ClassName", "Marks"."asmC_SectionName" ORDER BY "Marks"."estmpS_ObtainedMarks" DESC) AS "RNO"
                FROM (
                    SELECT 
                        (COALESCE(c."AMST_FirstName",'') || ' ' || COALESCE(c."AMST_MiddleName",'') || ' ' || COALESCE(c."AMST_LastName",''))::TEXT AS "amsT_FirstName",
                        d."ASMCL_ClassName"::TEXT,
                        e."ASMC_SectionName"::TEXT,
                        d."ASMCL_Order",
                        e."ASMC_Order",
                        g."EME_ExamOrder",
                        g."EME_ExamName"::TEXT,
                        c."AMST_AdmNo"::TEXT AS "amsT_AdmNo",
                        MAX(a."ESTMPS_ObtainedMarks") AS "estmpS_ObtainedMarks",
                        a."ESTMPS_MaxMarks" AS "estmpS_MaxMarks",
                        a."ESTMPS_SectionHighest" AS "estmpS_SectionHighest"
                    FROM "exm"."Exm_Student_Marks_Process_subjectwise" a
                    INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
                    INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id"
                    INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id" AND a."ASMCL_Id" = d."ASMCL_Id"
                    INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id" AND e."ASMS_Id" = a."ASMS_Id"
                    INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id" AND f."ASMAY_Id" = a."ASMAY_Id"
                    INNER JOIN "exm"."Exm_Master_Exam" g ON g."EME_Id" = a."EME_Id"
                    WHERE c."AMST_SOL" = 'S' 
                        AND c."AMST_ActiveFlag" = TRUE 
                        AND f."AMAY_ActiveFlag" = TRUE 
                        AND c."MI_Id"::TEXT = "p_MI_Id" 
                        AND a."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
                        AND b."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
                        AND a."ASMCL_Id"::TEXT = "p_ASMCL_Id" 
                        AND b."ASMCL_Id"::TEXT = "p_ASMCL_Id" 
                        AND a."EME_Id"::TEXT = "p_EME_Id"
                        AND a."ISMS_Id"::TEXT = "p_ISMS_Id"
                    GROUP BY d."ASMCL_ClassName", e."ASMC_SectionName", d."ASMCL_Order", e."ASMC_Order", g."EME_ExamOrder", g."EME_ExamName", 
                             c."AMST_FirstName", c."AMST_MiddleName", c."AMST_LastName", a."ESTMPS_MaxMarks", a."ESTMPS_SectionHighest", c."AMST_AdmNo"
                    ORDER BY d."ASMCL_Order", e."ASMC_Order", "amsT_FirstName"
                ) AS "Marks"
            ) AS "NEW" 
            WHERE "NEW"."RNO" <= "p_top"::INTEGER;
            
        ELSIF "p_EMEFlag"::INTEGER != 0 AND "p_Subjectflag"::INTEGER = 0 THEN
            
            RETURN QUERY
            SELECT 
                (COALESCE(c."AMST_FirstName",'') || ' ' || COALESCE(c."AMST_MiddleName",'') || ' ' || COALESCE(c."AMST_LastName",''))::TEXT AS "amsT_FirstName",
                c."AMST_AdmNo"::TEXT AS "amsT_AdmNo",
                d."ASMCL_ClassName"::TEXT,
                e."ASMC_SectionName"::TEXT,
                a."ESTMP_SectionRank",
                a."ESTMP_TotalMaxMarks",
                a."ESTMP_TotalObtMarks",
                a."ESTMP_Percentage",
                d."ASMCL_Order",
                e."ASMC_Order",
                g."EME_ExamOrder",
                g."EME_ExamName"::TEXT,
                NULL::NUMERIC AS "estmpS_ObtainedMarks",
                NULL::NUMERIC AS "estmpS_MaxMarks",
                NULL::NUMERIC AS "estmpS_SectionHighest",
                NULL::BIGINT AS "RNO"
            FROM "exm"."Exm_Student_Marks_Process" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id" AND a."ASMCL_Id" = d."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id" AND e."ASMS_Id" = a."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id" AND f."ASMAY_Id" = a."ASMAY_Id"
            INNER JOIN "exm"."Exm_Master_Exam" g ON g."EME_Id" = a."EME_Id"
            WHERE c."AMST_SOL" = 'S' 
                AND c."AMST_ActiveFlag" = TRUE 
                AND f."AMAY_ActiveFlag" = TRUE 
                AND c."MI_Id"::TEXT = "p_MI_Id" 
                AND a."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
                AND b."ASMAY_Id"::TEXT = "p_ASMAY_Id"
                AND a."ESTMP_SectionRank" <= "p_top"::INTEGER 
                AND a."ESTMP_SectionRank" != 0 
                AND a."ASMCL_Id"::TEXT = "p_ASMCL_Id" 
                AND b."ASMCL_Id"::TEXT = "p_ASMCL_Id" 
                AND a."EME_Id"::TEXT = "p_EME_Id"
            ORDER BY d."ASMCL_Order", e."ASMC_Order", a."ESTMP_SectionRank", "amsT_FirstName";
            
        ELSIF "p_EMEFlag"::INTEGER = 0 AND "p_Subjectflag"::INTEGER != 0 THEN
            
            RETURN QUERY
            SELECT 
                (COALESCE(c."AMST_FirstName",'') || ' ' || COALESCE(c."AMST_MiddleName",'') || ' ' || COALESCE(c."AMST_LastName",''))::TEXT AS "studentname",
                NULL::TEXT AS "amsT_AdmNo",
                d."ASMCL_ClassName"::TEXT,
                e."ASMC_SectionName"::TEXT,
                a."ESTMP_SectionRank",
                a."ESTMP_TotalMaxMarks",
                a."ESTMP_TotalObtMarks",
                NULL::NUMERIC AS "estmP_Percentage",
                d."ASMCL_Order",
                e."ASMC_Order",
                g."EME_ExamOrder",
                g."EME_ExamName"::TEXT,
                NULL::NUMERIC AS "estmpS_ObtainedMarks",
                NULL::NUMERIC AS "estmpS_MaxMarks",
                NULL::NUMERIC AS "estmpS_SectionHighest",
                NULL::BIGINT AS "RNO"
            FROM "exm"."Exm_Student_Marks_Process" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id" AND a."ASMCL_Id" = d."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id" AND e."ASMS_Id" = a."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id" AND f."ASMAY_Id" = a."ASMAY_Id"
            INNER JOIN "exm"."Exm_Master_Exam" g ON g."EME_Id" = a."EME_Id"
            WHERE c."AMST_SOL" = 'S' 
                AND c."AMST_ActiveFlag" = TRUE 
                AND f."AMAY_ActiveFlag" = TRUE 
                AND c."MI_Id"::TEXT = "p_MI_Id" 
                AND a."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
                AND b."ASMAY_Id"::TEXT = "p_ASMAY_Id"
                AND a."ESTMP_SectionRank" <= "p_top"::INTEGER 
                AND a."ESTMP_SectionRank" != 0 
                AND a."ASMCL_Id"::TEXT = "p_ASMCL_Id" 
                AND b."ASMCL_Id"::TEXT = "p_ASMCL_Id"
            ORDER BY d."ASMCL_Order", e."ASMC_Order", "studentname";
            
        END IF;
        
    ELSIF "p_conditionflag"::INTEGER = 2 THEN
        
        IF "p_EMEFlag"::INTEGER = 0 AND "p_Subjectflag"::INTEGER = 0 THEN
            
            RETURN QUERY
            SELECT 
                (COALESCE(c."AMST_FirstName",'') || ' ' || COALESCE(c."AMST_MiddleName",'') || ' ' || COALESCE(c."AMST_LastName",''))::TEXT AS "studentname",
                NULL::TEXT AS "amsT_AdmNo",
                d."ASMCL_ClassName"::TEXT,
                e."ASMC_SectionName"::TEXT,
                a."ESTMP_SectionRank",
                a."ESTMP_TotalMaxMarks",
                a."ESTMP_TotalObtMarks",
                NULL::NUMERIC AS "estmP_Percentage",
                d."ASMCL_Order",
                e."ASMC_Order",
                g."EME_ExamOrder",
                g."EME_ExamName"::TEXT,
                NULL::NUMERIC AS "estmpS_ObtainedMarks",
                NULL::NUMERIC AS "estmpS_MaxMarks",
                NULL::NUMERIC AS "estmpS_SectionHighest",
                NULL::BIGINT AS "RNO"
            FROM "exm"."Exm_Student_Marks_Process" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id" AND a."ASMCL_Id" = d."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id" AND e."ASMS_Id" = a."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id" AND f."ASMAY_Id" = a."ASMAY_Id"
            INNER JOIN "exm"."Exm_Master_Exam" g ON g."EME_Id" = a."EME_Id"
            WHERE c."AMST_SOL" = 'S' 
                AND c."AMST_ActiveFlag" = TRUE 
                AND f."AMAY_ActiveFlag" = TRUE 
                AND c."MI_Id"::TEXT = "p_MI_Id" 
                AND a."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
                AND b."ASMAY_Id"::TEXT = "p_ASMAY_Id"
                AND a."ESTMP_SectionRank" <= "p_top"::INTEGER 
                AND a."ESTMP_SectionRank" != 0 
                AND a."ASMCL_Id"::TEXT = "p_ASMCL_Id" 
                AND b."ASMCL_Id"::TEXT = "p_ASMCL_Id" 
                AND a."ASMS_Id"::TEXT = "p_ASMS_Id" 
                AND b."ASMS_Id"::TEXT = "p_ASMS_Id"
            ORDER BY d."ASMCL_Order", e."ASMC_Order", "studentname";
            
        ELSIF "p_EMEFlag"::INTEGER != 0 AND "p_Subjectflag"::INTEGER != 0 THEN
            
            RETURN QUERY
            SELECT * FROM (
                SELECT 
                    "Marks"."amsT_FirstName",
                    NULL::TEXT AS "amsT_AdmNo",
                    "Marks"."asmcL_ClassName",
                    "Marks"."asmC_SectionName",
                    NULL::NUMERIC AS "estmP_SectionRank",
                    NULL::NUMERIC AS "estmP_TotalMaxMarks",
                    NULL::NUMERIC AS "estmP_TotalObtMarks",
                    NULL::NUMERIC AS "estmP_Percentage",
                    "Marks"."ASMCL_Order",
                    "Marks"."ASMC_Order",
                    "Marks"."EME_ExamOrder",
                    "Marks"."EME_ExamName",
                    "Marks"."estmpS_ObtainedMarks",
                    "Marks"."estmpS_MaxMarks",
                    "Marks"."estmpS_SectionHighest",
                    ROW_NUMBER() OVER (PARTITION BY "Marks"."asmcL_ClassName", "Marks"."asmC_SectionName" ORDER BY "Marks"."estmpS_ObtainedMarks" DESC) AS "RNO"
                FROM (
                    SELECT 
                        (COALESCE(c."AMST_FirstName",'') || ' ' || COALESCE(c."AMST_MiddleName",'') || ' ' || COALESCE(c."AMST_LastName",''))::TEXT AS "amsT_FirstName",
                        d."ASMCL_ClassName"::TEXT,
                        e."ASMC_SectionName"::TEXT,
                        d."ASMCL_Order",
                        e."ASMC_Order",
                        g."EME_ExamOrder",
                        g."EME_ExamName"::TEXT,
                        c."AMST_AdmNo"::TEXT AS "amsT_AdmNo",
                        MAX(a."ESTMPS_ObtainedMarks") AS "estmpS_ObtainedMarks",
                        a."ESTMPS_MaxMarks" AS "estmpS_MaxMarks",
                        a."ESTMPS_SectionHighest" AS "estmpS_SectionHighest"
                    FROM "exm"."Exm_Student_Marks_Process_subjectwise" a
                    INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
                    INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id"
                    INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id" AND a."ASMCL_Id" = d."ASMCL_Id"
                    INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id" AND e."ASMS_Id" = a."ASMS_Id"
                    INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id" AND f."ASMAY_Id" = a."ASMAY_Id"
                    INNER JOIN "exm"."Exm_Master_Exam" g ON g."EME_Id" = a."EME_Id"
                    WHERE c."AMST_SOL" = 'S' 
                        AND c."AMST_ActiveFlag" = TRUE 
                        AND f."AMAY_ActiveFlag" = TRUE 
                        AND c."MI_Id"::TEXT = "p_MI_Id" 
                        AND a."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
                        AND b."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
                        AND a."ASMCL_Id"::TEXT = "p_ASMCL_Id" 
                        AND b."ASMCL_Id"::TEXT = "p_ASMCL_Id" 
                        AND a."ASMS_Id"::TEXT = "p_ASMS_Id" 
                        AND a."EME_Id"::TEXT = "p_EME_Id"
                        AND a."ISMS_Id"::TEXT = "p_ISMS_Id"
                    GROUP BY d."ASMCL_ClassName", e."ASMC_SectionName", d."ASMCL_Order", e."ASMC_Order", g."EME_ExamOrder", g."EME_ExamName", 
                             c."AMST_FirstName", c."AMST_MiddleName", c."AMST_LastName", a."ESTMPS_MaxMarks", a."ESTMPS_SectionHighest", c."AMST_AdmNo"
                    ORDER BY d."ASMCL_Order", e."ASMC_Order", "amsT_FirstName"
                ) AS "Marks"
            ) AS "NEW" 
            WHERE "NEW"."RNO" <= "p_top"::INTEGER;
            
        ELSIF "p_EMEFlag"::INTEGER != 0 AND "p_Subjectflag"::INTEGER = 0 THEN
            
            RETURN QUERY
            SELECT 
                (COALESCE(c."AMST_FirstName",'') || ' ' || COALESCE(c."AMST_MiddleName",'') || ' ' || COALESCE(c."AMST_LastName",''))::TEXT AS "amsT_FirstName",
                c."AMST_AdmNo"::TEXT AS "amsT_AdmNo",
                d."ASMCL_ClassName"::TEXT,
                e."ASMC_SectionName"::TEXT,
                a."ESTMP_SectionRank",
                a."ESTMP_TotalMaxMarks",
                a."ESTMP_TotalObtMarks",
                a."ESTMP_Percentage",
                d."ASMCL_Order",
                e."ASMC_Order",
                g."EME_ExamOrder",
                g."EME_ExamName"::TEXT,
                NULL::NUMERIC AS "estmpS_ObtainedMarks",
                NULL::NUMERIC AS "estmpS_MaxMarks",
                NULL::NUMERIC AS "estmpS_SectionHighest",
                NULL::BIGINT AS "RNO"
            FROM "exm"."Exm_Student_Marks_Process" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_School_M_Class" d ON d."ASMCL_Id" = b."ASMCL_Id" AND a."ASMCL_Id" = d."ASMCL_Id"
            INNER JOIN "Adm_School_M_Section" e ON e."ASMS_Id" = b."ASMS_Id" AND e."ASMS_Id" = a."ASMS_Id"
            INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = b."ASMAY_Id" AND f."ASMAY_Id" = a."ASMAY_Id"
            INNER JOIN "exm"."Exm_Master_Exam" g ON g."EME_Id" = a."EME_Id"
            WHERE c."AMST_SOL" = 'S' 
                AND c."AMST_ActiveFlag" = TRUE 
                AND f."AMAY_ActiveFlag" = TRUE 
                AND c."MI_Id"::TEXT = "p_MI_Id" 
                AND a."ASMAY_Id"::TEXT = "p_ASMAY_Id" 
                AND b."ASMAY_Id"::TEXT = "p_ASMAY_Id"
                AND a."ESTMP_SectionRank" <= "p_top"::INTEGER 
                AND a."ESTMP_SectionRank" != 0 
                AND a."ASMCL_Id"::TEXT = "p_ASMCL_Id" 
                AND b."ASMCL_Id"::TEXT = "p_ASMCL_Id" 
                AND a."ASMS_Id"::TEXT = "p_ASMS_Id" 
                AND b."ASMS_Id"::TEXT = "p_ASMS_Id" 
                AND a."EME_Id"::TEXT = "p_EME_Id"
            ORDER BY d."ASMCL_Order", e."ASMC_Order", a."ESTMP_SectionRank", "amsT_FirstName";
            
        ELSIF "p_EMEFlag"::INTEGER = 0 AND "p_Subjectflag"::INTEGER != 0 THEN
            
            RETURN QUERY
            SELECT 
                (COALESCE(c."AMST_FirstName",'') || ' ' || COALESCE(c."AMST_MiddleName",'') || ' ' || COALESCE(c."AMST_LastName",''))::TEXT AS "studentname",
                NULL::TEXT AS "amsT_AdmNo",
                d."ASMCL_ClassName"::TEXT,
                e."ASMC_SectionName"::TEXT,
                a."ESTMP_SectionRank",
                a."ESTMP_TotalMaxMarks",
                a."ESTMP_TotalObtMarks",
                NULL::NUMERIC AS "estmP_Percentage",
                d."ASMCL_Order",
                e."ASMC_Order",
                g."EME_ExamOrder",
                g."EME_ExamName"::TEXT,
                NULL::NUMERIC AS "estmpS_ObtainedMarks",
                NULL::NUMERIC AS "estmpS_MaxMarks",
                NULL::NUMERIC AS "estmpS_SectionHighest",
                NULL::BIGINT AS "RNO"
            FROM "exm"."Exm_Student_Marks_Process" a
            INNER JOIN "Adm_School_Y_Student" b ON a."AMST_Id" = b."AMST_Id"
            INNER JOIN "Adm_M_Student" c ON c."AMST_Id" = b."AMST_Id"
            INNER