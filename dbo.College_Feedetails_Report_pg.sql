CREATE OR REPLACE FUNCTION "dbo"."College_Feedetails_Report"(
    "amay_id" TEXT,
    "amco_id" TEXT,
    "amb_id" TEXT,
    "amse_id" TEXT,
    "asms_id" TEXT,
    "fmg_id" TEXT,
    "fmh_id" TEXT,
    "user_id" TEXT,
    "mi_id" TEXT
)
RETURNS TABLE(
    "regno" TEXT,
    "admno" TEXT,
    "amse_semname" TEXT,
    "dateofjoin" TEXT,
    "studentname" TEXT,
    "paid" NUMERIC,
    "balance" NUMERIC,
    "FYP_TransactionTypeFlag" TEXT,
    "FYP_Remarks" TEXT,
    "ACQ_QuotaName" TEXT,
    "AMCST_MobileNo" TEXT,
    "AMCST_ConStreet" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
BEGIN

    IF "amse_id" = '0' THEN
    
        "query" := 'SELECT DISTINCT "AMCST_RegistrationNo" AS regno, "AMCST_AdmNo" AS admno, 
            "amco_coursename" || '' '' || "amb_branchname" || '' '' || "amse_semname" AS amse_semname,
            TO_CHAR("amcst_date", ''DD/MM/YYYY'') AS dateofjoin,
            (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN '''' ELSE "AMCST_FirstName" END || 
            CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_MiddleName" END ||
            CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS studentname,
            SUM("FTCP_PaidAmount") AS paid, SUM("FCSS_TotalCharges") AS balance, "FYP_TransactionTypeFlag", "FYP_Remarks", "ACQ_QuotaName", "AMCST_MobileNo", "AMCST_ConStreet"
            FROM "clg"."Adm_College_Yearly_Student" a 
            INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
            INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
            INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
            INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
            INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
            INNER JOIN "clg"."Fee_College_Student_Status" g ON g."AMCST_Id" = a."AMCST_Id"
            INNER JOIN "clg"."Fee_Y_Payment_College_Student" h ON h."AMCST_Id" = g."AMCST_Id"
            INNER JOIN "clg"."Fee_Y_Payment" i ON i."FYP_Id" = h."FYP_Id"
            INNER JOIN "clg"."Fee_T_College_Payment" j ON j."FYP_Id" = i."FYP_Id" AND j."FCMAS_Id" = g."FCMAS_Id"
            INNER JOIN "clg"."Adm_College_Quota" k ON k."ACQ_Id" = b."ACQ_Id"
            WHERE a."AMB_Id" IN (' || "amb_id" || ') AND a."AMCO_Id" IN (' || "amco_id" || ') AND "FMG_Id" IN (' || "fmg_id" || ') AND "FMH_Id" IN (' || "fmh_id" || ')
            GROUP BY "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", "AMCST_RegistrationNo", "AMCST_AdmNo", "amco_coursename", "amb_branchname", "amse_semname", "amcst_date",
            "FYP_TransactionTypeFlag", "FYP_Remarks", "ACQ_QuotaName", "AMCST_MobileNo", "AMCST_ConStreet"';
    
    ELSE
    
        "query" := 'SELECT DISTINCT "AMCST_RegistrationNo" AS regno, "AMCST_AdmNo" AS admno, 
            "amco_coursename" || '' '' || "amb_branchname" || '' '' || "amse_semname" AS amse_semname,
            TO_CHAR("amcst_date", ''DD/MM/YYYY'') AS dateofjoin,
            (CASE WHEN "AMCST_FirstName" IS NULL OR "AMCST_FirstName" = '''' THEN '''' ELSE "AMCST_FirstName" END || 
            CASE WHEN "AMCST_MiddleName" IS NULL OR "AMCST_MiddleName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_MiddleName" END ||
            CASE WHEN "AMCST_LastName" IS NULL OR "AMCST_LastName" = '''' OR "AMCST_MiddleName" = ''0'' THEN '''' ELSE '' '' || "AMCST_LastName" END) AS studentname,
            SUM("FTCP_PaidAmount") AS paid, SUM("FCSS_TotalCharges") AS balance, "FYP_TransactionTypeFlag", "FYP_Remarks", "ACQ_QuotaName", "AMCST_MobileNo", "AMCST_ConStreet"
            FROM "clg"."Adm_College_Yearly_Student" a 
            INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
            INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
            INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
            INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
            INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
            INNER JOIN "clg"."Fee_College_Student_Status" g ON g."AMCST_Id" = a."AMCST_Id"
            INNER JOIN "clg"."Fee_Y_Payment_College_Student" h ON h."AMCST_Id" = g."AMCST_Id"
            INNER JOIN "clg"."Fee_Y_Payment" i ON i."FYP_Id" = h."FYP_Id"
            INNER JOIN "clg"."Fee_T_College_Payment" j ON j."FYP_Id" = i."FYP_Id" AND j."FCMAS_Id" = g."FCMAS_Id"
            INNER JOIN "clg"."Adm_College_Quota" k ON k."ACQ_Id" = b."ACQ_Id"
            WHERE a."AMB_Id" IN (' || "amb_id" || ') AND a."AMCO_Id" IN (' || "amco_id" || ') AND a."AMSE_Id" IN (' || "amse_id" || ') AND "FMG_Id" IN (' || "fmg_id" || ') AND "FMH_Id" IN (' || "fmh_id" || ')
            GROUP BY "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", "AMCST_RegistrationNo", "AMCST_AdmNo", "amco_coursename", "amb_branchname", "amse_semname", "amcst_date",
            "FYP_TransactionTypeFlag", "FYP_Remarks", "ACQ_QuotaName", "AMCST_MobileNo", "AMCST_ConStreet"';
    
    END IF;

    RETURN QUERY EXECUTE "query";

END;
$$;