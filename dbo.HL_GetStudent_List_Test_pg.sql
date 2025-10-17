CREATE OR REPLACE FUNCTION "HL_GetStudent_List_Test"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_Type text
)
RETURNS TABLE(
    "StudentId" bigint,
    "Studentname" text,
    "AMB_Id" bigint,
    "AMSE_Id" bigint,
    "HLHSREQC_Id" bigint,
    "HLMH_Id" bigint,
    "mobileNo" varchar,
    "emailId" varchar,
    "HLMH_Name" varchar,
    "HRMRM_RoomNo" varchar,
    "HLMRCA_RoomCategory" varchar,
    "Requested" timestamp
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF (p_Type = 'collegestudents') THEN
        RETURN QUERY
        SELECT DISTINCT 
            a."AMCST_Id" as "StudentId",
            CONCAT(COALESCE(a."AMCST_FirstName",''),'',COALESCE(a."AMCST_MiddleName",''),'',COALESCE(a."AMCST_LastName",'')) as "Studentname",
            b."AMB_Id",
            b."AMSE_Id",
            c."HLHSREQC_Id",
            d."HLMH_Id",
            a."AMCST_MobileNo" as "mobileNo",
            a."AMCST_emailId" as "emailId",
            d."HLMH_Name",
            f."HRMRM_RoomNo",
            e."HLMRCA_RoomCategory",
            c."HLHSREQC_RequestDate" as "Requested"
        FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "HL_Hostel_Student_Request_College" c ON c."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "HL_Master_Hostel" d ON d."HLMH_Id" = c."HLMH_Id"
        INNER JOIN "HL_Master_Room_Category" e ON e."HLMRCA_Id" = c."HLMRCA_Id"
        INNER JOIN "HL_Master_Room" f ON f."HLMH_Id" = c."HLMH_Id"
        WHERE a."MI_Id" = p_MI_Id 
            AND a."AMCST_ActiveFlag" = 1 
            AND a."AMCST_SOL" = 'S' 
            AND b."ASMAY_Id" = p_ASMAY_Id;
    END IF;

    RETURN;

END;
$$;