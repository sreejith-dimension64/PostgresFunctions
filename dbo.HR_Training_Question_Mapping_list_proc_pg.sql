
CREATE OR REPLACE FUNCTION "dbo"."HR_Training_Question_Mapping_list_proc"(
    p_MI_Id bigint
)
RETURNS TABLE(
    "hrtcR_Id" bigint,
    "hrtcR_PrgogramName" character varying
) 
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "HRTCR_Id" AS "hrtcR_Id",
        "HRTCR_PrgogramName" AS "hrtcR_PrgogramName" 
    FROM "dbo"."HR_Training_Create" 
    WHERE "HRTCR_Id" NOT IN (
        SELECT DISTINCT "HRTCR_Id" 
        FROM "dbo"."HR_Training_Question" 
        WHERE "MI_Id" = p_MI_Id
    );
END;
$$;