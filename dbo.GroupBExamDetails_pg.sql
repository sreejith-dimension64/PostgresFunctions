CREATE OR REPLACE FUNCTION "dbo"."GroupBExamDetails"(
    p_MI_ID bigint,
    p_HRME_ID bigint
)
RETURNS TABLE(
    "HREMGBE_Id" bigint,
    "HRMEGB_Id" bigint,
    "HRMEGB_GroupBExamName" varchar,
    "HREMGBE_Year" varchar,
    "HREMGBE_GPFlg" boolean,
    "HREMGBE_Remarks" varchar,
    "HREMGBE_SubjectName" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        B."HREMGBE_Id",
        A."HRMEGB_Id",
        A."HRMEGB_GroupBExamName",
        COALESCE(B."HREMGBE_Year", '') AS "HREMGBE_Year",
        B."HREMGBE_GPFlg",
        COALESCE(B."HREMGBE_Remarks", '') AS "HREMGBE_Remarks",
        COALESCE(B."HREMGBE_SubjectName", '') AS "HREMGBE_SubjectName"
    FROM "HR_MasterExam_GroupB" A 
    LEFT OUTER JOIN "HR_Employee_GroupBExam" B 
        ON A."HRMEGB_Id" = B."HRMEGB_Id" 
        AND A."MI_Id" = B."MI_ID" 
        AND A."HRMEGB_ActiveFlg" = true 
        AND B."HREMGBE_ActiveFlg" = true 
        AND B."MI_Id" = p_MI_ID 
        AND B."HRME_Id" = p_HRME_ID;
END;
$$;