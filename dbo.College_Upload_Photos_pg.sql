CREATE OR REPLACE FUNCTION "dbo"."College_Upload_Photos"(p_MI_Id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMCST_Admno TEXT;
    studentdetails_rec RECORD;
BEGIN
    
    FOR studentdetails_rec IN 
        SELECT "AMCST_Admno" 
        FROM "CLG"."Adm_Master_College_Student" 
        WHERE "MI_Id" = p_MI_Id
    LOOP
        v_AMCST_Admno := studentdetails_rec."AMCST_Admno";
        
        UPDATE "CLG"."Adm_Master_College_Student" 
        SET "AMCST_StudentPhoto" = 'https://dcampusstrg.blob.core.windows.net/files/19/StudentProfilePics/' || v_AMCST_Admno || '.jpg'
        WHERE "MI_Id" = p_MI_Id 
        AND "AMCST_AdmNo" = v_AMCST_Admno;
        
    END LOOP;
    
    RETURN;
    
END;
$$;