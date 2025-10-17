CREATE OR REPLACE FUNCTION "dbo"."Adm_Student_Achivements_Report"(
    "AMST_Id" bigint,
    "ASMAY_Id" bigint,
    "Extracurricular" text,
    "ASTEC_Date" timestamp,
    "FileName" text,
    "FilePath" text,
    "USERID" bigint,
    "ASTEC_Id" bigint
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_ASTEC_Id bigint;
BEGIN
    v_ASTEC_Id := "ASTEC_Id";
    
    IF v_ASTEC_Id = 0 THEN
        INSERT INTO "Adm_Student_Achivements" (
            "AMST_Id",
            "ASTEC_Date",
            "ASTEC_Extracurricular",
            "ASTEC_ActiveFlg",
            "ASTEC_UpdatedBy",
            "ASTEC_CreatedBy",
            "ASTEC_CreatedDate",
            "ASTEC_UpdatedDate"
        )
        VALUES (
            "AMST_Id",
            "ASTEC_Date",
            "Extracurricular",
            1,
            "USERID",
            "USERID",
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        )
        RETURNING "ASTEC_Id" INTO v_ASTEC_Id;
        
        INSERT INTO "Adm_Student_Achivements_Documents" (
            "ASTEC_Id",
            "ASTECD_FileName",
            "ASTECD_FilePath",
            "ASTECD_ActiveFlg",
            "ASTECD_CreatedDate",
            "ASTECD_UpdatedDate",
            "ASTECD_CreatedBy",
            "ASTECD_UpdatedBy"
        )
        VALUES (
            v_ASTEC_Id,
            "FileName",
            "FilePath",
            1,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            "USERID",
            "USERID"
        );
    ELSE
        UPDATE "Adm_Student_Achivements"
        SET 
            "ASTEC_Date" = "ASTEC_Date",
            "ASTEC_Extracurricular" = "Extracurricular",
            "ASTEC_UpdatedDate" = CURRENT_TIMESTAMP
        WHERE "ASTEC_Id" = v_ASTEC_Id;
        
        UPDATE "Adm_Student_Achivements_Documents"
        SET 
            "ASTECD_FileName" = "FileName",
            "ASTECD_FilePath" = "FilePath",
            "ASTECD_UpdatedDate" = CURRENT_TIMESTAMP
        WHERE "ASTEC_Id" = v_ASTEC_Id;
    END IF;
    
    RETURN;
END;
$$;