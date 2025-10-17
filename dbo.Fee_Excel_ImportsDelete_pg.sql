CREATE OR REPLACE FUNCTION "Fee_Excel_ImportsDelete"(p_FEIPST_Id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN

UPDATE "Fee_Excel_Imports_Pending_Students" 
SET "FEIPST_ActiveFlg" = 0 
WHERE "FEIPST_Id" = p_FEIPST_Id;

END;
$$;