CREATE OR REPLACE FUNCTION "dbo"."HR_Question_list_proc"(
    p_MI_Id bigint
)
RETURNS TABLE(
    "hrmfqnS_Id" bigint,
    "hrmfqnS_QuestionName" varchar
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT "HRMFQNS_Id" AS "hrmfqnS_Id", "hrmfqnS_QuestionName" 
    FROM "dbo"."HR_Master_Feedback_Qns" 
    WHERE "HRMFQNS_Id" NOT IN ( 
        SELECT DISTINCT "HRMFQNS_Id" 
        FROM "dbo"."HR_Master_Question_Option" 
        WHERE "MI_Id" = p_MI_Id 
    );
END;
$$;