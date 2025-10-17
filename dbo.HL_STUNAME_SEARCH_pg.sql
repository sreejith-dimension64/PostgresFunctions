CREATE OR REPLACE FUNCTION "dbo"."HL_STUNAME_SEARCH"(
    "MI_Id" bigint,
    "SearchByName" text,
    "ASMAY_Id" bigint,
    "AdmNo" varchar(100),
    "HRMRM_Id" bigint
)
RETURNS TABLE(
    "AMCST_Id" bigint,
    "AMCST_FirstName" text,
    "AMCST_AdmNo" varchar,
    "HRMRM_Id" bigint,
    "HLMRCA_Id" bigint,
    "HLMRCA_RoomCategory" text,
    "HRMF_FloorName" text,
    "HRMRM_RoomNo" varchar
)
LANGUAGE plpgsql
AS $$
BEGIN

RETURN QUERY
SELECT 
    "New"."AMCST_Id",
    "New"."AMCST_FullName" as "AMCST_FirstName",
    "New"."AMCST_AdmNo",
    "New"."HRMRM_Id",
    "New"."HLMRCA_Id",
    "New"."HLMRCA_RoomCategory",
    "New"."HRMF_FloorName",
    "New"."HRMRM_RoomNo"
FROM (
    SELECT 
        "A"."AMCST_Id",
        (COALESCE("A"."AMCST_FirstName",'') || ' ' || COALESCE("A"."AMCST_MiddleName",'') || ' ' || COALESCE("A"."AMCST_LastName",'')) AS "AMCST_FullName",
        "A"."AMCST_FirstName",
        "A"."AMCST_MiddleName",
        "A"."AMCST_LastName",
        "A"."AMCST_AdmNo",
        "B"."HRMRM_Id",
        "HMRC"."HLMRCA_Id",
        "HMRC"."HLMRCA_RoomCategory",
        "HMR"."HRMRM_RoomNo",
        "HMF"."HRMF_FloorName"
    FROM "CLG"."Adm_Master_College_Student" AS "A"
    INNER JOIN "HL_Hostel_Student_Allot_College" AS "B" ON "A"."AMCST_Id" = "B"."AMCST_Id"
    INNER JOIN "HL_Master_Room_Category" "HMRC" ON "HMRC"."HLMRCA_Id" = "B"."HLMRCA_Id"
    INNER JOIN "HL_Master_Room" "HMR" ON "HMR"."HLMRCA_Id" = "HMRC"."HLMRCA_Id" AND "HMR"."HRMRM_Id" = "B"."HRMRM_Id"
    INNER JOIN "HL_Master_Hostel" "HMH" ON "HMH"."HLMH_Id" = "B"."HLMH_Id"
    INNER JOIN "HL_Master_Floor" "HMF" ON "HMF"."HLMF_Id" = "HMR"."HLMF_Id"
    WHERE "A"."MI_Id" = "MI_Id" 
        AND "B"."ASMAY_Id" = "ASMAY_Id" 
        AND "B"."MI_Id" = "MI_Id" 
        AND "A"."AMCST_ActiveFlag" = 1 
        AND "B"."HLHSALTC_ActiveFlag" = 1 
        AND "A"."AMCST_ActiveFlag" = 1 
        AND "A"."AMCST_SOL" = 'S'
) AS "New"
WHERE (
    CASE 
        WHEN LENGTH("New"."AMCST_FullName") > 0 
        THEN TRIM(REPLACE("New"."AMCST_FullName", ' ', '')) 
        ELSE TRIM(REPLACE("New"."AMCST_FullName", ' ', '')) 
    END LIKE '%' || 
    CASE 
        WHEN LENGTH("SearchByName") > 0 
        THEN TRIM(REPLACE("SearchByName", ' ', '')) 
        ELSE TRIM(REPLACE("SearchByName", ' ', '')) 
    END || '%'
)
OR (TRIM("New"."AMCST_FirstName") LIKE '%' || TRIM("SearchByName") || '%' 
    OR TRIM("New"."AMCST_MiddleName") LIKE '%' || TRIM("SearchByName") || '%' 
    OR TRIM("New"."AMCST_LastName") LIKE '%' || TRIM("SearchByName") || '%')
OR "New"."AMCST_AdmNo" = "AdmNo" 
OR "New"."HRMRM_Id" = "HRMRM_Id";

END;
$$;