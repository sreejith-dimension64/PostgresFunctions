CREATE OR REPLACE FUNCTION "dbo"."HL_Hostel_Student_Approval_Grid"(
    p_MI_Id bigint
)
RETURNS TABLE(
    "Student_Name" TEXT,
    "HLHSTGP_TypeFlg" VARCHAR,
    "HLHSTGP_GoingOutDate" DATE,
    "HLHSTGP_GoingOutTime" TIME,
    "HLHSTGP_Reason" TEXT,
    "HLHSTGP_ComingBackDate" DATE,
    "HLHSTGP_TotalDays" INTEGER,
    "HLHSTGP_ActiveFlg" BOOLEAN,
    "HLHSTGP_ComingBackTime" TIME,
    "HLHSTGPAPP_Remarks" TEXT,
    "HLHSTGPAPP_ActiveFlg" BOOLEAN,
    "HLHSTGP_Id" BIGINT,
    "AMCST_Id" BIGINT,
    "HLHSTGPAPP_Status" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        (COALESCE(a."AMCST_FirstName", '') || ' ' || COALESCE(a."AMCST_MiddleName", '') || ' ' || COALESCE(a."AMCST_LastName", ''))::TEXT AS "Student_Name",
        b."HLHSTGP_TypeFlg",
        b."HLHSTGP_GoingOutDate",
        b."HLHSTGP_GoingOutTime",
        b."HLHSTGP_Reason",
        b."HLHSTGP_ComingBackDate",
        b."HLHSTGP_TotalDays",
        b."HLHSTGP_ActiveFlg",
        b."HLHSTGP_ComingBackTime",
        c."HLHSTGPAPP_Remarks",
        c."HLHSTGPAPP_ActiveFlg",
        b."HLHSTGP_Id",
        a."AMCST_Id",
        c."HLHSTGPAPP_Status"
    FROM "CLG"."adm_master_college_student" a
    INNER JOIN "HL_Hostel_Student_Gatepass" b ON b."MI_Id" = b."MI_Id" AND a."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "HL_Hostel_Student_Gatepass_Approval" c ON c."HLHSTGP_Id" = b."HLHSTGP_Id"
    WHERE a."MI_Id" = p_MI_Id;
END;
$$;