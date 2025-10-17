CREATE OR REPLACE FUNCTION "dbo"."College_Teresian_Report_I_And_II_Year_Report"(
    "p_MI_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_AMCO_Id" TEXT,
    "p_AMB_Id" TEXT,
    "p_AMSE_Id" TEXT,
    "p_Feegroup" TEXT,
    "p_category" TEXT
)
RETURNS TABLE(
    "StudentName" TEXT,
    "AMCST_FatherName" TEXT,
    "AMCST_AdmNo" TEXT,
    "AMCST_RegistrationNo" TEXT,
    "FYP_ReceiptNo" TEXT,
    "FYP_ReceiptDate" TIMESTAMP,
    "caste" TEXT,
    "gender" TEXT,
    "ACSTPS_LanguagesTaken" TEXT,
    "annualincome" NUMERIC,
    "PaidAmount" NUMERIC,
    "FineAmount" NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_sql" TEXT;
BEGIN
    "v_sql" := 'WITH cte AS (
        SELECT 
            (COALESCE("AMCST_FirstName",'''') || '' '' || COALESCE("AMCST_MiddleName",'''') || '' '' || COALESCE("AMCST_LastName",'''')) AS "StudentName",
            "AMCST_FatherName",
            "AMCST_AdmNo",
            "AMCST_RegistrationNo",
            "FYP_ReceiptNo",
            "FYP_ReceiptDate",
            COALESCE("IMCC_CategoryName",'''') || ''/'' || COALESCE("IMC_CasteName",'''') AS caste,
            "AMCST_Sex" AS gender,
            '''' AS "ACSTPS_LanguagesTaken",
            b."AMCST_FatherAnnIncome" AS annualincome,
            SUM("FCSS_PaidAmount") AS "PaidAmount",
            0 AS "FineAmount"
        FROM "clg"."Adm_College_Yearly_Student" a
        INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "clg"."Fee_Y_Payment_College_Student" g ON g."AMCST_Id" = a."AMCST_Id"
        INNER JOIN "clg"."Fee_Y_Payment" h ON h."FYP_Id" = g."FYP_Id"
        INNER JOIN "clg"."Fee_T_College_Payment" i ON i."FYP_Id" = h."FYP_Id"
        INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" j ON j."FCMAS_Id" = i."FCMAS_Id"
        INNER JOIN "clg"."Fee_College_Master_Amount" k ON k."FCMA_Id" = j."FCMA_Id"
        INNER JOIN "Fee_Master_Head" l ON l."FMH_Id" = k."FMH_Id"
        INNER JOIN "clg"."Fee_College_Student_Status" "CSS" ON "CSS"."FCMAS_Id" = j."FCMAS_Id" AND "CSS"."AMCST_Id" = a."AMCST_Id"
        INNER JOIN "IVRM_Master_Caste" "MC" ON "MC"."IMC_Id" = b."IMC_Id"
        INNER JOIN "IVRM_Master_Caste_Category" "Md" ON "Md"."IMCC_Id" = b."IMCC_Id"
        INNER JOIN "clg"."Adm_College_Quota" "Mf" ON "Mf"."ACQ_Id" = b."ACQ_Id"
        WHERE a."AMCO_Id" = ' || "p_AMCO_Id" || ' 
            AND a."AMB_Id" = ' || "p_AMB_Id" || ' 
            AND a."AMSE_Id" = ' || "p_AMSE_Id" || ' 
            AND k."FMG_Id" IN (' || "p_Feegroup" || ')
        GROUP BY 
            "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", "AMCST_FatherName",
            "AMCST_AdmNo", "AMCST_RegistrationNo", "FYP_ReceiptNo", "FYP_ReceiptDate",
            b."AMCST_FatherAnnIncome", "IMCC_CategoryName", "IMC_CasteName", "AMCST_Sex"
        
        UNION
        
        SELECT 
            (COALESCE("AMCST_FirstName",'''') || '' '' || COALESCE("AMCST_MiddleName",'''') || '' '' || COALESCE("AMCST_LastName",'''')) AS "StudentName",
            "AMCST_FatherName",
            "AMCST_AdmNo",
            "AMCST_RegistrationNo",
            "FYP_ReceiptNo",
            "FYP_ReceiptDate",
            COALESCE("IMCC_CategoryName",'''') || ''/'' || COALESCE("IMC_CasteName",'''') AS caste,
            "AMCST_Sex" AS gender,
            '''' AS "ACSTPS_LanguagesTaken",
            b."AMCST_FatherAnnIncome" AS annualincome,
            0 AS "PaidAmount",
            SUM("FCSS_PaidAmount") AS "FineAmount"
        FROM "clg"."Adm_College_Yearly_Student" a
        INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id"
        INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "clg"."Fee_Y_Payment_College_Student" g ON g."AMCST_Id" = a."AMCST_Id"
        INNER JOIN "clg"."Fee_Y_Payment" h ON h."FYP_Id" = g."FYP_Id"
        INNER JOIN "clg"."Fee_T_College_Payment" i ON i."FYP_Id" = h."FYP_Id"
        INNER JOIN "clg"."Fee_College_Master_Amount_Semesterwise" j ON j."FCMAS_Id" = i."FCMAS_Id"
        INNER JOIN "clg"."Fee_College_Master_Amount" k ON k."FCMA_Id" = j."FCMA_Id"
        INNER JOIN "Fee_Master_Head" l ON l."FMH_Id" = k."FMH_Id"
        INNER JOIN "clg"."Fee_College_Student_Status" "CSS" ON "CSS"."FCMAS_Id" = j."FCMAS_Id" AND "CSS"."AMCST_Id" = a."AMCST_Id"
        INNER JOIN "IVRM_Master_Caste" "MC" ON "MC"."IMC_Id" = b."IMC_Id"
        INNER JOIN "IVRM_Master_Caste_Category" "Md" ON "Md"."IMCC_Id" = b."IMCC_Id"
        INNER JOIN "clg"."Adm_College_Quota" "Mf" ON "Mf"."ACQ_Id" = b."ACQ_Id"
        LEFT JOIN "clg"."Adm_College_Student_PrevSchool" "Me" ON "Me"."AMCST_Id" = b."AMCST_Id"
        WHERE a."AMCO_Id" = ' || "p_AMCO_Id" || ' 
            AND a."AMB_Id" = ' || "p_AMB_Id" || ' 
            AND a."AMSE_Id" = ' || "p_AMSE_Id" || ' 
            AND k."FMG_Id" IN (' || "p_Feegroup" || ')
            AND "CSS"."FMH_Id" = 155 
            AND l."FMH_Id" = 155
        GROUP BY 
            "AMCST_FirstName", "AMCST_MiddleName", "AMCST_LastName", "AMCST_FatherName",
            "AMCST_AdmNo", "AMCST_RegistrationNo", "FYP_ReceiptNo", "FYP_ReceiptDate", "ACSTPS_LanguagesTaken",
            b."AMCST_FatherAnnIncome", "IMCC_CategoryName", "IMC_CasteName", "AMCST_Sex"
    )
    SELECT 
        "StudentName",
        "AMCST_FatherName",
        "AMCST_AdmNo",
        "AMCST_RegistrationNo",
        "FYP_ReceiptNo",
        MIN("FYP_ReceiptDate") AS "FYP_ReceiptDate",
        caste,
        gender,
        "ACSTPS_LanguagesTaken",
        annualincome,
        "PaidAmount",
        "FineAmount"
    FROM cte 
    WHERE "PaidAmount" <> 0
    GROUP BY 
        "StudentName", "AMCST_FatherName", "AMCST_AdmNo", "AMCST_RegistrationNo", 
        "FYP_ReceiptNo", caste, gender, "ACSTPS_LanguagesTaken", annualincome, 
        "PaidAmount", "FineAmount"';
    
    RETURN QUERY EXECUTE "v_sql";
END;
$$;