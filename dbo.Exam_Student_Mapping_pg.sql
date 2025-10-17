CREATE OR REPLACE FUNCTION "Exam_Student_Mapping" (
    p_MI_Id BIGINT,
    p_ASMAY_Id BIGINT,
    p_AMST_Id TEXT
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "EMG_Id" BIGINT,
    "ISMS_Id" BIGINT,
    "EMG_GroupName" VARCHAR,
    "ISMS_SubjectName" VARCHAR,
    "EME_ExamName" TEXT
) 
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT DISTINCT 
        a."AMST_Id", 
        a."EMG_Id", 
        a."ISMS_Id", 
        b."EMG_GroupName", 
        d."ISMS_SubjectName",
        COALESCE(
            (SELECT z."EME_ExamName" 
             FROM "exm"."exm_master_exam" z 
             WHERE z."EME_Id" = a."EME_Id" AND z."MI_Id" = p_MI_Id), 
            ''
        ) AS "EME_ExamName"
    FROM "Exm"."Exm_Studentwise_Subjects" a
    INNER JOIN "Exm"."Exm_Master_Group" b 
        ON b."MI_Id" = a."MI_Id" AND b."EMG_Id" = a."EMG_Id"
    INNER JOIN "IVRM_Master_Subjects" d 
        ON d."MI_Id" = a."MI_Id" AND d."ISMS_Id" = a."ISMS_Id"
    INNER JOIN "Adm_School_Y_Student" e 
        ON a."AMST_Id" = e."AMST_Id" 
        AND a."ASMAY_Id" = e."ASMAY_Id" 
        AND a."ASMCL_Id" = e."ASMCL_Id" 
        AND a."ASMS_Id" = e."ASMS_Id"
    INNER JOIN "Adm_M_Student" f 
        ON e."AMST_Id" = f."AMST_Id"
    WHERE 
        e."ASMAY_Id" = p_ASMAY_Id
        AND a."MI_Id" = p_MI_Id
        AND a."ESTSU_ElecetiveFlag" = 1
        AND a."ESTSU_ActiveFlg" = 1
        AND b."EMG_ActiveFlag" = 1
        AND b."EMG_ElectiveFlg" = 1
        AND d."ISMS_ActiveFlag" = 1
        AND d."ISMS_ExamFlag" = 1
        AND a."AMST_Id"::TEXT IN (
            SELECT TRIM(unnest(string_to_array(p_AMST_Id, ',')))
        )
    ORDER BY a."AMST_Id";

END;
$$;