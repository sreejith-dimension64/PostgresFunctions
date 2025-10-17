CREATE OR REPLACE FUNCTION "Exm"."EXM_CATEGORY_DETAILS"(
    p_EYC_ID BIGINT,
    p_MI_ID BIGINT
)
RETURNS TABLE(
    "EMCA_CategoryName" TEXT,
    "EYC_ExamStartDate" TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT  
        "A"."EMCA_CategoryName",
        "B"."EYC_ExamStartDate"
    FROM "Exm"."Exm_Master_Category" "A" 
    INNER JOIN "Exm"."Exm_Yearly_Category" "B"
        ON "A"."EMCA_Id" = "B"."EMCA_Id"
    INNER JOIN "Exm"."Exm_Yearly_Category_Group" "C" 
        ON "C"."EYC_Id" = "B"."EYC_Id" 
    INNER JOIN "Exm"."Exm_Yearly_Category_Group_Subjects" "D" 
        ON "D"."EYCG_Id" = "C"."EYCG_Id"
    INNER JOIN "Exm"."Exm_Yearly_Category_Exams" "E" 
        ON "E"."EYC_Id" = "B"."EYC_Id"
    WHERE "B"."EYC_ID" = p_EYC_ID 
        AND "A"."MI_Id" = p_MI_ID;
END;
$$;