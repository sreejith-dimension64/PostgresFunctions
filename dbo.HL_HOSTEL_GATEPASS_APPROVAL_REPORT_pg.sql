CREATE OR REPLACE FUNCTION "HL_HOSTEL_GATEPASS_APPROVAL_REPORT"(
    p_AMCST_Id bigint,
    p_fromdate TEXT,
    p_todate TEXT
)
RETURNS TABLE(
    "AMCST_Id" bigint,
    "AMCST_FirstName" TEXT,
    "HLHSTGP_Id" bigint,
    "HLHSTGP_GoingOutDate" TIMESTAMP,
    "HLHSTGP_GoingOutTime" TIME,
    "HLHSTGP_ComingBackDate" TIMESTAMP,
    "HLHSTGP_ComingBackTime" TIME,
    "HLHSTGP_Reason" TEXT,
    "HLHSTGPAPP_Id" bigint,
    "HLHSTGPAPP_Remarks" TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        b."AMCST_Id",
        CONCAT(COALESCE(b."AMCST_FirstName",''),'',COALESCE(b."AMCST_MiddleName",''),'',COALESCE(b."AMCST_LastName",'')) as "AMCST_FirstName",
        a."HLHSTGP_Id",
        a."HLHSTGP_GoingOutDate",
        a."HLHSTGP_GoingOutTime",
        a."HLHSTGP_ComingBackDate",
        a."HLHSTGP_ComingBackTime",
        a."HLHSTGP_Reason",
        g."HLHSTGPAPP_Id",
        g."HLHSTGPAPP_Remarks"
    FROM "HL_Hostel_Student_Gatepass" a 
    INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_College_Yearly_Student" c ON c."AMCST_Id" = a."AMCST_Id" AND c."AMCST_ActiveFlag" = 1
    INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = c."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = c."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Semester" f ON f."AMSE_Id" = c."AMSE_Id"
    INNER JOIN "HL_Hostel_Student_Gatepass_Approval" g ON g."HLHSTGP_Id" = a."HLHSTGP_Id"
    INNER JOIN "ApplicationUser" h ON h."Id" = g."Id"
    WHERE a."AMCST_Id" = p_AMCST_Id 
        AND CAST(a."HLHSTGP_GoingOutDate" AS DATE) BETWEEN CAST(p_fromdate AS DATE) AND CAST(p_todate AS DATE);
    
    RETURN;
END;
$$;