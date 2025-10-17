CREATE OR REPLACE FUNCTION "dbo"."College_Category_seat_distribution" (
    "mi_id" bigint, 
    "asmay_id" bigint, 
    "amco_id" bigint, 
    "amse_id" bigint, 
    "amb_id" bigint, 
    "acq_id" varchar(50)
)
RETURNS TABLE (
    "ACSCD_SeatNos" bigint,
    "ACQ_Id" bigint,
    "ACQ_QuotaName" varchar,
    "ACQC_CategoryName" varchar,
    "AMCO_CourseName" varchar,
    "AMB_Id" bigint,
    "AMB_BranchName" varchar,
    "AMSE_SEMName" varchar,
    "admitted_seats" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY EXECUTE 
    'SELECT a."ACSCD_SeatNos", b."ACQ_Id", b."ACQ_QuotaName", g."ACQC_CategoryName", c."AMCO_CourseName", d."AMB_Id", d."AMB_BranchName", f."AMSE_SEMName", COUNT(*) as admitted_seats 
    FROM "clg"."Adm_Master_College_Student" z
    INNER JOIN "clg"."Adm_College_Seat_Distribution" a ON a."AMB_Id" = z."AMB_Id"
    INNER JOIN "clg"."Adm_College_Quota" b ON a."ACQ_Id" = b."ACQ_Id"
    INNER JOIN "clg"."Adm_Master_Course" c ON a."AMCO_Id" = c."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" d ON a."AMB_Id" = d."AMB_Id"
    INNER JOIN "clg"."Adm_Master_Semester" f ON f."AMSE_Id" = a."AMSE_Id"
    INNER JOIN "clg"."Adm_College_Quota_Category" g ON g."ACQC_Id" = z."ACQC_Id"
    WHERE a."MI_Id" = ' || "mi_id" || ' AND a."ASMAY_Id" = ' || "asmay_id" || ' AND a."AMCO_Id" = ' || "amco_id" || ' AND a."AMSE_Id" = ' || "amse_id" || ' AND a."AMB_Id" = ' || "amb_id" || ' AND a."ACQ_Id" IN (' || "acq_id" || ') AND z."AMCO_Id" = c."AMCO_Id" AND z."AMSE_Id" = f."AMSE_Id" AND z."AMB_Id" = d."AMB_Id" 
    AND b."ACQ_Id" = z."ACQ_Id"
    GROUP BY b."ACQ_Id", a."ACSCD_SeatNos", b."ACQ_QuotaName", c."AMCO_CourseName", d."AMB_BranchName", f."AMSE_SEMName", d."AMB_Id", g."ACQC_CategoryName"';
END;
$$;