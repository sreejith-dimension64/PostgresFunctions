CREATE OR REPLACE FUNCTION "dbo"."Alumnitestinsertion"(p_MI_ID VARCHAR(100))
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_MS_No VARCHAR(100);
    v_record RECORD;
BEGIN
    FOR v_record IN 
        SELECT B."ALSREG_MembershipNo", B.*
        FROM "Alumni_Master_Student_bkp" A
        INNER JOIN "ALU"."Alumni_Student_Registration" B 
            ON A."ALMST_Id" = B."ALMST_Id" 
            AND A."MI_Id" = B."MI_Id"
        WHERE A."MI_ID" = p_MI_ID
    LOOP
        v_MS_No := v_record."ALSREG_MembershipNo";
        
        MERGE INTO "Alumni_Master_Student_bkp" AS Target
        USING "Alumni_Student_bkp" AS Source
        ON Source."ALSREG_MembershipNo" = v_MS_No
        WHEN NOT MATCHED THEN
            INSERT("ALMST_Id", "MI_Id", "AMST_Id", "ASMAY_Id_Join", "ASMAY_Id_Left", 
                   "ALMST_FirstName", "ALMST_MiddleName", "ALMST_LastName", "ALMST_Date", 
                   "ALMST_RegistrationNo", "ALMST_AdmNo", "ALMST_Sex", "ALMST_DOB", 
                   "ALMST_DOBinwords", "ALMST_Age", "ASMCL_Id_Join", "ASMCL_Id_Left", 
                   "ALMST_BloodGroup")
            VALUES(Source."ALMST_Id", Source."MI_Id", Source."AMST_Id", Source."ASMAY_Id_Join", 
                   Source."ASMAY_Id_Left", Source."ALMST_FirstName", Source."ALMST_MiddleName", 
                   Source."ALMST_LastName", Source."ALMST_Date", Source."ALMST_RegistrationNo", 
                   Source."ALMST_AdmNo", Source."ALMST_Sex", Source."ALMST_DOB", 
                   Source."ALMST_DOBinwords", Source."ALMST_Age", Source."ASMCL_Id_Join", 
                   Source."ASMCL_Id_Left", Source."ALMST_BloodGroup")
        WHEN MATCHED THEN
            UPDATE SET
                "MI_Id" = Source."MI_Id",
                "AMST_Id" = Source."AMST_Id",
                "ASMAY_Id_Join" = Source."ASMAY_Id_Join",
                "ASMAY_Id_Left" = Source."ASMAY_Id_Left",
                "ALMST_FirstName" = Source."ALMST_FirstName",
                "ALMST_MiddleName" = Source."ALMST_MiddleName",
                "ALMST_LastName" = Source."ALMST_LastName",
                "ALMST_Date" = Source."ALMST_Date",
                "ALMST_RegistrationNo" = Source."ALMST_RegistrationNo",
                "ALMST_AdmNo" = Source."ALMST_AdmNo",
                "ALMST_Sex" = Source."ALMST_Sex",
                "ALMST_DOB" = Source."ALMST_DOB",
                "ALMST_DOBinwords" = Source."ALMST_DOBinwords",
                "ALMST_Age" = Source."ALMST_Age",
                "ASMCL_Id_Join" = Source."ASMCL_Id_Join",
                "ASMCL_Id_Left" = Source."ASMCL_Id_Left",
                "ALMST_BloodGroup" = Source."ALMST_BloodGroup";
    END LOOP;
    
    RETURN;
END;
$$;