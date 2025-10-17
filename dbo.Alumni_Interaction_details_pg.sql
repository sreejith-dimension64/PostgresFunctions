CREATE OR REPLACE FUNCTION "dbo"."Alumni_Interaction_details"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_userflag varchar(30)
)
RETURNS TABLE (
    id bigint,
    name varchar
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_userflag = 'SameBatch' THEN
        RETURN QUERY
        SELECT 
            "ALMST_Id", 
            (COALESCE("ALMST_FirstName", '') || COALESCE("ALMST_MiddleName", '') || COALESCE("ALMST_LastName", '')) AS alumniname 
        FROM "ALU"."Alumni_Master_Student" 
        WHERE "MI_Id" = p_MI_Id AND "ASMAY_Id_Left" = p_ASMAY_Id;
    END IF;
    
    IF p_userflag = 'AllBatch' THEN
        RETURN QUERY
        SELECT 
            "ALMST_Id", 
            (COALESCE("ALMST_FirstName", '') || COALESCE("ALMST_MiddleName", '') || COALESCE("ALMST_LastName", '')) AS alumniname 
        FROM "ALU"."Alumni_Master_Student" 
        WHERE "MI_Id" = p_MI_Id;
    END IF;
    
    IF p_userflag = 'Teachers' THEN
        RETURN QUERY
        SELECT 
            "HRME_Id", 
            (COALESCE("HRME_EmployeeFirstName", '') || COALESCE("HRME_EmployeeMiddleName", '') || COALESCE("HRME_EmployeeMiddleName", '')) AS employeename  
        FROM "HR_Master_Employee" 
        WHERE "MI_Id" = p_MI_Id;
    END IF;
    
    RETURN;
END;
$$;