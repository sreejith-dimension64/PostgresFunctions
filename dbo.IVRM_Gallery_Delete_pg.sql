CREATE OR REPLACE FUNCTION "IVRM_Gallery_Delete" (
    p_MI_id BIGINT,
    p_IGA_Id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM "IVRM_Gallery_Programs" WHERE "IGA_Id" = p_IGA_Id;
    
    DELETE FROM "IVRM_Gallery_Photos" WHERE "IGA_Id" = p_IGA_Id;
    
    DELETE FROM "IVRM_Gallery_Class" WHERE "IGA_Id" = p_IGA_Id;
    
    DELETE FROM "IVRM_Gallery" WHERE "MI_Id" = p_MI_id AND "IGA_Id" = p_IGA_Id;
END;
$$;