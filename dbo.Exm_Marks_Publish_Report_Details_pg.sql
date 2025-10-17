CREATE OR REPLACE FUNCTION "Exm_Marks_Publish_Report_Details"(
    p_MI_Id TEXT, 
    p_ASMAY_Id TEXT, 
    p_ASMCL_Id TEXT, 
    p_ASMS_Id TEXT, 
    p_EME_Id TEXT
)
RETURNS TABLE(
    "ASMCL_Id" INTEGER,
    "ASMS_Id" INTEGER,
    "ASMAY_Id" INTEGER,
    "ASMCL_ClassName" VARCHAR,
    "ASMC_SectionName" VARCHAR,
    "ASMAY_Year" VARCHAR,
    "ASMCL_Order" INTEGER,
    "ASMC_Order" INTEGER,
    "ESTMP_PublishToStudentFlg" VARCHAR,
    "d" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF p_ASMS_Id::INTEGER > 0 THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."ASMCL_Id", 
            a."ASMS_Id", 
            a."ASMAY_Id", 
            f."ASMCL_ClassName", 
            g."ASMC_SectionName", 
            h."ASMAY_Year", 
            f."ASMCL_Order", 
            g."ASMC_Order",
            CASE WHEN e."ESTMP_PublishToStudentFlg" = 1 THEN 'Published' ELSE 'Not Published' END AS "ESTMP_PublishToStudentFlg",
            e."ESTMP_PublishToStudentFlg" AS "d"
        FROM "Exm"."Exm_Category_Class" a 
        INNER JOIN "Exm"."Exm_Master_Category" b ON a."EMCA_Id" = b."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category" c ON c."EMCA_Id" = b."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" d ON d."EYC_Id" = c."EYC_Id"
        LEFT JOIN "Exm"."Exm_Student_Marks_Process" e ON e."EME_Id" = d."EME_Id"
        INNER JOIN "Adm_School_M_Class" f ON f."ASMCL_Id" = a."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = a."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" h ON h."ASMAY_Id" = a."ASMAY_Id"
        WHERE a."ECAC_ActiveFlag" = 1 
            AND b."EMCA_ActiveFlag" = 1 
            AND c."EYC_ActiveFlg" = 1 
            AND d."EYCE_ActiveFlg" = 1 
            AND a."ASMAY_Id" = p_ASMAY_Id::INTEGER
            AND a."ASMCL_Id" = p_ASMCL_Id::INTEGER
            AND a."ASMS_Id" = p_ASMS_Id::INTEGER
            AND c."ASMAY_Id" = p_ASMAY_Id::INTEGER
            AND d."EME_Id" = p_EME_Id::INTEGER
            AND e."EME_Id" = p_EME_Id::INTEGER
            AND e."ASMAY_Id" = p_ASMAY_Id::INTEGER
            AND e."ASMCL_Id" = p_ASMCL_Id::INTEGER
            AND e."ASMS_Id" = p_ASMS_Id::INTEGER
            AND ((d."EYCE_MarksPublishDate" IS NULL AND e."ESTMP_PublishToStudentFlg" = 1)
                OR (d."EYCE_MarksPublishDate" IS NOT NULL AND e."ESTMP_PublishToStudentFlg" = 0 AND CURRENT_DATE >= CAST(d."EYCE_MarksPublishDate" AS DATE))
                OR (d."EYCE_MarksPublishDate" IS NOT NULL AND e."ESTMP_PublishToStudentFlg" = 1 AND CURRENT_DATE >= CAST(d."EYCE_MarksPublishDate" AS DATE)))
        ORDER BY f."ASMCL_Order", g."ASMC_Order";
    ELSE
        RETURN QUERY
        SELECT DISTINCT 
            a."ASMCL_Id", 
            a."ASMS_Id", 
            a."ASMAY_Id", 
            f."ASMCL_ClassName", 
            g."ASMC_SectionName", 
            h."ASMAY_Year", 
            f."ASMCL_Order", 
            g."ASMC_Order",
            CASE WHEN e."ESTMP_PublishToStudentFlg" = 1 THEN 'Published' ELSE 'Not Published' END AS "ESTMP_PublishToStudentFlg",
            e."ESTMP_PublishToStudentFlg" AS "d"
        FROM "Exm"."Exm_Category_Class" a 
        INNER JOIN "Exm"."Exm_Master_Category" b ON a."EMCA_Id" = b."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category" c ON c."EMCA_Id" = b."EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" d ON d."EYC_Id" = c."EYC_Id"
        LEFT JOIN "Exm"."Exm_Student_Marks_Process" e ON e."EME_Id" = d."EME_Id"
        INNER JOIN "Adm_School_M_Class" f ON f."ASMCL_Id" = a."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" g ON g."ASMS_Id" = a."ASMS_Id"
        INNER JOIN "Adm_School_M_Academic_Year" h ON h."ASMAY_Id" = a."ASMAY_Id"
        WHERE a."ECAC_ActiveFlag" = 1 
            AND b."EMCA_ActiveFlag" = 1 
            AND c."EYC_ActiveFlg" = 1 
            AND d."EYCE_ActiveFlg" = 1 
            AND a."ASMAY_Id" = p_ASMAY_Id::INTEGER
            AND a."ASMCL_Id" = p_ASMCL_Id::INTEGER
            AND c."ASMAY_Id" = p_ASMAY_Id::INTEGER
            AND d."EME_Id" = p_EME_Id::INTEGER
            AND e."EME_Id" = p_EME_Id::INTEGER
            AND e."ASMAY_Id" = p_ASMAY_Id::INTEGER
            AND e."ASMCL_Id" = p_ASMCL_Id::INTEGER
            AND ((d."EYCE_MarksPublishDate" IS NULL AND e."ESTMP_PublishToStudentFlg" = 1)
                OR (d."EYCE_MarksPublishDate" IS NOT NULL AND e."ESTMP_PublishToStudentFlg" = 0 AND CURRENT_DATE >= CAST(d."EYCE_MarksPublishDate" AS DATE))
                OR (d."EYCE_MarksPublishDate" IS NOT NULL AND e."ESTMP_PublishToStudentFlg" = 1 AND CURRENT_DATE >= CAST(d."EYCE_MarksPublishDate" AS DATE)))
        ORDER BY f."ASMCL_Order", g."ASMC_Order";
    END IF;

    RETURN;

END;
$$;