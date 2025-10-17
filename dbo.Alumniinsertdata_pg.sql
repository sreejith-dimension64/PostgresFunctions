CREATE OR REPLACE FUNCTION "dbo"."Alumniinsertdata"(p_MI_ID VARCHAR(100))
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_MS_No VARCHAR(100);
    v_msno1 VARCHAR(100);
    v_msno2 VARCHAR(100);
    v_cursor_record RECORD;
BEGIN
    FOR v_cursor_record IN 
        SELECT B."ALSREG_MembershipNo"
        FROM "ALU"."Alumni_Master_Student" A
        INNER JOIN "ALU"."Alumni_Student_Registration" B 
            ON A."ALMST_Id" = B."ALMST_Id" AND A."MI_Id" = B."MI_Id"
        WHERE A."MI_ID" = p_MI_ID
    LOOP
        v_MS_No := v_cursor_record."ALSREG_MembershipNo";
        
        v_msno1 := (SELECT "ALSREG_MembershipNo" 
                    FROM "ALU"."Alumni_Student_Registration" 
                    WHERE "ALSREG_MembershipNo" = v_MS_No 
                    LIMIT 1);
        
        v_msno2 := (SELECT "ALSREG_MembershipNo" 
                    FROM "Newtable" 
                    WHERE "ALSREG_MembershipNo" = v_MS_No 
                    LIMIT 1);
        
        IF v_MS_No = v_msno1 AND v_MS_No = v_msno2 THEN
            
            MERGE INTO "ALU"."Alumni_Master_Student" AS Target
            USING "Newtable" AS Source
            ON Source."ALSREG_MembershipNo" = Target."ALSREG_MembershipNo"
            
            WHEN NOT MATCHED THEN
                INSERT ("ALMST_FirstName", "ASMCL_Id_Join", "ASMCL_Id_Left", "ALMST_BloodGroup", 
                        "ALMST_PerStreet", "ALMST_PerArea", "ALMST_PerCity", "ALMST_PerAdd3", 
                        "ALMST_PerState", "IVRMMC_Id", "ALMST_PerPincode", "ALMST_ConStreet", 
                        "ALMST_ConArea", "ALMST_ConAdd3", "ALMST_ConCity", "ALMST_Village", 
                        "ALMST_Taluk", "ALMST_District", "ALMST_ConState", "ALMST_FatherName", 
                        "ALMST_MembershipCategory", "ALMST_FullAddess")
                VALUES (Source."Alumni_Name", Source."Batch", Source."Membership_Category", 
                        Source."FatherName", Source."ClassJoined", Source."ClassLeft", 
                        Source."JoinedYear", Source."LeftYear", Source."DOB", Source."EmailID", 
                        Source."MobileNo", Source."PhoneNo", Source."BloodGroup", Source."District", 
                        Source."Pincode", Source."State", Source."Country", Source."FullAddress", 
                        Source."Qualification", Source."Profession", Source."Achievement", 
                        Source."Remarks")
            
            WHEN MATCHED THEN 
                UPDATE SET
                    "EmailID" = Source."EmailID",
                    "FullAddress" = Source."FullAddress",
                    "MobileNo" = Source."MobileNo",
                    "PhoneNo" = Source."PhoneNo",
                    "BloodGroup" = Source."BloodGroup",
                    "District" = Source."District",
                    "Pincode" = Source."Pincode",
                    "State" = Source."State",
                    "Country" = Source."Country",
                    "Qualification" = Source."Qualification",
                    "Profession" = Source."Profession",
                    "Achievement" = Source."Achievement",
                    "Remarks" = Source."Remarks";
        END IF;
    END LOOP;
    
    RETURN;
END;
$$;