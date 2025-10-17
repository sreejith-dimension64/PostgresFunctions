CREATE OR REPLACE FUNCTION "Exam_ExamWiseStudetsPublishDetails"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_EME_Id TEXT,
    p_Type TEXT,
    p_PromotionFlg BOOLEAN
)
RETURNS TABLE(
    "StudentName" TEXT,
    "AMST_AdmNo" VARCHAR,
    "ESTMP_PublishToStudentFlg" BOOLEAN
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_Sqldynamic TEXT;
BEGIN
    IF (p_PromotionFlg = FALSE) THEN
        
        IF (p_Type = 'All') THEN
            
            v_Sqldynamic := '
            SELECT COALESCE("AMST_FirstName",'''') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''') AS "StudentName",
                   "AMST_AdmNo",
                   "ESMP"."ESTMP_PublishToStudentFlg"
            FROM "Exm"."Exm_Student_Marks_Process" "ESMP"
            INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "ESMP"."ASMAY_Id" 
                AND "ESMP"."ASMCL_Id" = "ASYS"."ASMCL_Id" 
                AND "ESMP"."ASMS_Id" = "ASYS"."ASMS_Id"
            INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
            WHERE "ESMP"."MI_Id" IN (' || p_MI_Id || ') 
                AND "ESMP"."ASMAY_Id" IN (' || p_ASMAY_Id || ') 
                AND "ESMP"."ASMCL_Id" IN (' || p_ASMCL_Id || ') 
                AND "ESMP"."ASMS_Id" IN (' || p_ASMS_Id || ') 
                AND "ESMP"."EME_Id" IN (' || p_EME_Id || ')';
                
        END IF;
        
        IF (p_Type = 'Published') THEN
            
            v_Sqldynamic := '
            SELECT COALESCE("AMST_FirstName",'''') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''') AS "StudentName",
                   "AMST_AdmNo",
                   "ESMP"."ESTMP_PublishToStudentFlg"
            FROM "Exm"."Exm_Student_Marks_Process" "ESMP"
            INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "ESMP"."ASMAY_Id" 
                AND "ESMP"."ASMCL_Id" = "ASYS"."ASMCL_Id" 
                AND "ESMP"."ASMS_Id" = "ASYS"."ASMS_Id"
            INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
            WHERE "ESMP"."MI_Id" IN (' || p_MI_Id || ') 
                AND "ESMP"."ASMAY_Id" IN (' || p_ASMAY_Id || ') 
                AND "ESMP"."ASMCL_Id" IN (' || p_ASMCL_Id || ') 
                AND "ESMP"."ASMS_Id" IN (' || p_ASMS_Id || ') 
                AND "ESMP"."EME_Id" IN (' || p_EME_Id || ') 
                AND "ESTMP_PublishToStudentFlg" = TRUE';
                
        END IF;
        
        IF (p_Type = 'NotPublished') THEN
            
            v_Sqldynamic := '
            SELECT COALESCE("AMST_FirstName",'''') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''') AS "StudentName",
                   "AMST_AdmNo",
                   "ESMP"."ESTMP_PublishToStudentFlg"
            FROM "Exm"."Exm_Student_Marks_Process" "ESMP"
            INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "ESMP"."ASMAY_Id" 
                AND "ESMP"."ASMCL_Id" = "ASYS"."ASMCL_Id" 
                AND "ESMP"."ASMS_Id" = "ASYS"."ASMS_Id"
            INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
            WHERE "ESMP"."MI_Id" IN (' || p_MI_Id || ') 
                AND "ESMP"."ASMAY_Id" IN (' || p_ASMAY_Id || ') 
                AND "ESMP"."ASMCL_Id" IN (' || p_ASMCL_Id || ') 
                AND "ESMP"."ASMS_Id" IN (' || p_ASMS_Id || ') 
                AND "ESMP"."EME_Id" IN (' || p_EME_Id || ') 
                AND "ESTMP_PublishToStudentFlg" = FALSE';
                
        END IF;
        
    ELSE
        
        IF (p_PromotionFlg = TRUE) THEN
            
            IF (p_Type = 'All') THEN
                
                v_Sqldynamic := '
                SELECT COALESCE("AMST_FirstName",'''') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''') AS "StudentName",
                       "AMST_AdmNo",
                       "ESMP"."ESTMPP_PublishToStudentFlg" AS "ESTMP_PublishToStudentFlg"
                FROM "Exm"."Exm_Student_MP_Promotion" "ESMP"
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "ESMP"."ASMAY_Id" 
                    AND "ESMP"."ASMCL_Id" = "ASYS"."ASMCL_Id" 
                    AND "ESMP"."ASMS_Id" = "ASYS"."ASMS_Id"
                INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
                WHERE "ESMP"."MI_Id" IN (' || p_MI_Id || ') 
                    AND "ESMP"."ASMAY_Id" IN (' || p_ASMAY_Id || ') 
                    AND "ESMP"."ASMCL_Id" IN (' || p_ASMCL_Id || ') 
                    AND "ESMP"."ASMS_Id" IN (' || p_ASMS_Id || ')';
                    
            END IF;
            
            IF (p_Type = 'Published') THEN
                
                v_Sqldynamic := '
                SELECT COALESCE("AMST_FirstName",'''') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''') AS "StudentName",
                       "AMST_AdmNo",
                       "ESMP"."ESTMPP_PublishToStudentFlg" AS "ESTMP_PublishToStudentFlg"
                FROM "Exm"."Exm_Student_MP_Promotion" "ESMP"
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "ESMP"."ASMAY_Id" 
                    AND "ESMP"."ASMCL_Id" = "ASYS"."ASMCL_Id" 
                    AND "ESMP"."ASMS_Id" = "ASYS"."ASMS_Id"
                INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
                WHERE "ESMP"."MI_Id" IN (' || p_MI_Id || ') 
                    AND "ESMP"."ASMAY_Id" IN (' || p_ASMAY_Id || ') 
                    AND "ESMP"."ASMCL_Id" IN (' || p_ASMCL_Id || ') 
                    AND "ESMP"."ASMS_Id" IN (' || p_ASMS_Id || ') 
                    AND "ESTMPP_PublishToStudentFlg" = TRUE';
                    
            END IF;
            
            IF (p_Type = 'NotPublished') THEN
                
                v_Sqldynamic := '
                SELECT COALESCE("AMST_FirstName",'''') || '' '' || COALESCE("AMST_MiddleName",'''') || '' '' || COALESCE("AMST_LastName",'''') AS "StudentName",
                       "AMST_AdmNo",
                       "ESMP"."ESTMPP_PublishToStudentFlg" AS "ESTMP_PublishToStudentFlg"
                FROM "Exm"."Exm_Student_MP_Promotion" "ESMP"
                INNER JOIN "Adm_School_Y_Student" "ASYS" ON "ASYS"."ASMAY_Id" = "ESMP"."ASMAY_Id" 
                    AND "ESMP"."ASMCL_Id" = "ASYS"."ASMCL_Id" 
                    AND "ESMP"."ASMS_Id" = "ASYS"."ASMS_Id"
                INNER JOIN "Adm_M_Student" "AMS" ON "AMS"."AMST_Id" = "ASYS"."AMST_Id"
                WHERE "ESMP"."MI_Id" IN (' || p_MI_Id || ') 
                    AND "ESMP"."ASMAY_Id" IN (' || p_ASMAY_Id || ') 
                    AND "ESMP"."ASMCL_Id" IN (' || p_ASMCL_Id || ') 
                    AND "ESMP"."ASMS_Id" IN (' || p_ASMS_Id || ') 
                    AND "ESTMPP_PublishToStudentFlg" = FALSE';
                    
            END IF;
            
        END IF;
        
    END IF;
    
    RETURN QUERY EXECUTE v_Sqldynamic;
    
END;
$$;