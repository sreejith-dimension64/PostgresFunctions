CREATE OR REPLACE FUNCTION "dbo"."GroupAExamDetails"(
    p_MI_ID bigint,
    p_HRME_ID bigint
)
RETURNS TABLE(
    "HREMGAE_Id" bigint,
    "HRMEGA_Id" bigint,
    "HRMEGA_GroupAExamName" VARCHAR,
    "HREMGAE_Year" VARCHAR,
    "HREMGAE_GPFlg" VARCHAR,
    "HREMGAE_Marks" VARCHAR,
    "HREMGAE_SubjectName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COALESCE("B"."HREMGAE_Id", 0) AS "HREMGAE_Id",
        "A"."HRMEGA_Id",
        "A"."HRMEGA_GroupAExamName",
        COALESCE("B"."HREMGAE_Year", '') AS "HREMGAE_Year",
        COALESCE("B"."HREMGAE_GPFlg", '') AS "HREMGAE_GPFlg",
        COALESCE("B"."HREMGAE_Marks", '') AS "HREMGAE_Marks",
        COALESCE("B"."HREMGAE_SubjectName", '') AS "HREMGAE_SubjectName"
    FROM "HR_MasterExam_GroupA" "A"
    LEFT OUTER JOIN "HR_Employee_GroupAExam" "B" 
        ON "A"."HRMEGA_Id" = "B"."HRMEGA_Id" 
        AND "A"."MI_Id" = "B"."MI_ID"
        AND "A"."HRMEGA_ActiveFlg" = 1 
        AND "B"."HREMGAE_ActiveFlg" = 1 
        AND "B"."MI_Id" = p_MI_ID 
        AND "B"."HRME_Id" = p_HRME_ID;
END;
$$;