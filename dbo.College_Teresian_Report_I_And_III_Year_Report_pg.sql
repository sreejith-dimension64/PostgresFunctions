CREATE OR REPLACE FUNCTION "dbo"."College_Teresian_Report_I_And_III_Year_Report"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_AMCO_Id TEXT,
    p_AMB_Id TEXT,
    p_AMSE_Id TEXT,
    p_Feegroup TEXT,
    p_category TEXT
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
    "acstpS_LanguagesTaken" TEXT,
    "annualincome" NUMERIC,
    "PaidAmount" NUMERIC,
    "FineAmount" NUMERIC,
    "AMCST_AadharNo" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
    v_sql1 TEXT;
    v_sql2 TEXT;
    v_sql3 TEXT;
    v_CourseName VARCHAR(100);
BEGIN

    DROP TABLE IF EXISTS "Clg_StudentPaidAmt_Temp1";
    DROP TABLE IF EXISTS "Clg_StudentFineAmt_Temp1";
    DROP TABLE IF EXISTS "Student_Fees_Details_Temp";

    SELECT "AMCO_CourseName" INTO v_CourseName 
    FROM "CLG"."Adm_Master_Course" 
    WHERE "AMCO_Id" = p_AMCO_Id::BIGINT AND "MI_Id" = p_MI_Id::BIGINT;

    IF (v_CourseName = 'BA' OR v_CourseName = 'BSc') THEN

        v_sql1 := 'CREATE TEMP TABLE "Clg_StudentPaidAmt_Temp1" AS 
        SELECT b."AMCST_Id",
        (COALESCE(b."AMCST_FirstName",'''') || '' '' || COALESCE(b."AMCST_MiddleName",'''') || '' '' || COALESCE(b."AMCST_LastName",'''')) AS "StudentName",
        b."AMCST_FatherName",
        b."AMCST_AdmNo",
        b."AMCST_RegistrationNo",
        h."FYP_ReceiptNo",
        h."FYP_ReceiptDate",
        COALESCE(Md."IMCC_CategoryName",'''') || ''/'' || COALESCE(MC."IMC_CasteName",'''') AS caste,
        b."AMCST_Sex" AS gender,
        d."AMB_BranchName" AS "ACSTPS_LanguagesTaken",
        b."AMCST_FatherAnnIncome" AS annualincome,
        SUM(COALESCE("CSS"."FCSS_PaidAmount", 0)) AS "PaidAmount",
        0 AS "FineAmount",
        b."AMCST_AadharNo"
        FROM "clg"."Adm_College_Yearly_Student" a 
        INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id" AND b."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id" AND c."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id" AND d."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id" AND e."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id" AND f."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "clg"."Fee_Y_Payment_College_Student" g ON g."AMCST_Id" = a."AMCST_Id" AND g."asmay_id" = ' || p_ASMAY_Id || '
        LEFT JOIN "clg"."Fee_Y_Payment" h ON h."FYP_Id" = g."FYP_Id" AND h."asmay_id" = ' || p_ASMAY_Id || ' AND h."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "clg"."Fee_T_College_Payment" i ON i."FYP_Id" = h."FYP_Id"
        LEFT JOIN "clg"."Fee_College_Master_Amount_Semesterwise" j ON j."FCMAS_Id" = i."FCMAS_Id" AND j."MI_Id" = ' || p_MI_Id || ' AND j."AMSE_Id" = ' || p_AMSE_Id || '
        LEFT JOIN "clg"."Fee_College_Master_Amount" k ON k."FCMA_Id" = j."FCMA_Id" AND k."asmay_id" = ' || p_ASMAY_Id || ' AND k."FMG_Id" IN (' || p_Feegroup || ') AND k."MI_Id" = ' || p_MI_Id || ' AND k."AMCO_Id" = ' || p_AMCO_Id || ' AND k."AMB_Id" = ' || p_AMB_Id || '
        LEFT JOIN "Fee_Master_Head" l ON l."FMH_Id" = k."FMH_Id" AND l."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "CLG"."Fee_College_Student_Status" "CSS" ON "CSS"."FCMAS_Id" = j."FCMAS_Id" AND "CSS"."FMG_Id" = k."FMG_Id" AND "CSS"."AMCST_Id" = a."AMCST_Id" AND "CSS"."FMH_Id" = l."FMH_Id" AND "CSS"."ASMAY_Id" = ' || p_ASMAY_Id || '
        INNER JOIN "IVRM_Master_Caste" MC ON MC."IMC_Id" = b."IMC_Id" AND MC."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "IVRM_Master_Caste_Category" Md ON Md."IMCC_Id" = b."IMCC_Id"
        INNER JOIN "clg"."Adm_College_Quota" Mf ON Mf."ACQ_Id" = b."ACQ_Id" AND Mf."MI_Id" = ' || p_MI_Id || '
        WHERE a."asmay_id" = ' || p_ASMAY_Id || ' AND a."AMCO_Id" = ' || p_AMCO_Id || ' AND a."AMB_Id" = ' || p_AMB_Id || ' AND a."AMSE_Id" = ' || p_AMSE_Id || ' AND a."ACYST_ActiveFlag" = true
        GROUP BY b."AMCST_Id", b."AMCST_FirstName", b."AMCST_MiddleName", b."AMCST_LastName", b."AMCST_FatherName", b."AMCST_AdmNo", b."AMCST_RegistrationNo", h."FYP_ReceiptNo", h."FYP_ReceiptDate", b."AMCST_FatherAnnIncome", Md."IMCC_CategoryName", MC."IMC_CasteName", b."AMCST_Sex", d."AMB_BranchName", b."AMCST_AadharNo"';

        EXECUTE v_sql1;

        v_sql2 := 'CREATE TEMP TABLE "Clg_StudentFineAmt_Temp1" AS 
        SELECT b."AMCST_Id",
        (COALESCE(b."AMCST_FirstName",'''') || '' '' || COALESCE(b."AMCST_MiddleName",'''') || '' '' || COALESCE(b."AMCST_LastName",'''')) AS "StudentName",
        b."AMCST_FatherName",
        b."AMCST_AdmNo",
        b."AMCST_RegistrationNo",
        h."FYP_ReceiptNo",
        h."FYP_ReceiptDate",
        COALESCE(Md."IMCC_CategoryName",'''') || ''/'' || COALESCE(MC."IMC_CasteName",'''') AS caste,
        b."AMCST_Sex" AS gender,
        d."AMB_BranchName" AS "ACSTPS_LanguagesTaken",
        b."AMCST_FatherAnnIncome" AS annualincome,
        0 AS "PaidAmount",
        SUM(i."FTCP_FineAmount") AS "FineAmount",
        b."AMCST_AadharNo"
        FROM "clg"."Adm_College_Yearly_Student" a 
        INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id" AND b."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id" AND c."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id" AND d."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id" AND e."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id" AND f."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "clg"."Fee_Y_Payment_College_Student" g ON g."AMCST_Id" = a."AMCST_Id" AND g."asmay_id" = ' || p_ASMAY_Id || '
        LEFT JOIN "clg"."Fee_Y_Payment" h ON h."FYP_Id" = g."FYP_Id" AND h."asmay_id" = ' || p_ASMAY_Id || ' AND h."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "clg"."Fee_T_College_Payment" i ON i."FYP_Id" = h."FYP_Id"
        LEFT JOIN "clg"."Fee_College_Master_Amount_Semesterwise" j ON j."FCMAS_Id" = i."FCMAS_Id" AND j."MI_Id" = ' || p_MI_Id || ' AND j."AMSE_Id" = ' || p_AMSE_Id || '
        LEFT JOIN "clg"."Fee_College_Master_Amount" k ON k."FCMA_Id" = j."FCMA_Id" AND k."asmay_id" = ' || p_ASMAY_Id || ' AND k."FMG_Id" IN (' || p_Feegroup || ') AND k."AMCO_Id" = ' || p_AMCO_Id || ' AND k."AMB_Id" = ' || p_AMB_Id || ' AND k."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "Fee_Master_Head" l ON l."FMH_Id" = k."FMH_Id" AND l."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "CLG"."Fee_College_Student_Status" "CSS" ON "CSS"."FCMAS_Id" = j."FCMAS_Id" AND "CSS"."FMG_Id" = k."FMG_Id" AND "CSS"."AMCST_Id" = a."AMCST_Id" AND "CSS"."FMH_Id" = l."FMH_Id" AND "CSS"."ASMAY_Id" = ' || p_ASMAY_Id || '
        INNER JOIN "IVRM_Master_Caste" MC ON MC."IMC_Id" = b."IMC_Id" AND MC."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "IVRM_Master_Caste_Category" Md ON Md."IMCC_Id" = b."IMCC_Id"
        INNER JOIN "clg"."Adm_College_Quota" Mf ON Mf."ACQ_Id" = b."ACQ_Id" AND Mf."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "clg"."Adm_College_Student_PrevSchool" Me ON Me."AMCST_Id" = b."AMCST_Id"
        WHERE a."asmay_id" = ' || p_ASMAY_Id || ' AND a."AMCO_Id" = ' || p_AMCO_Id || ' AND a."AMB_Id" = ' || p_AMB_Id || ' AND a."AMSE_Id" = ' || p_AMSE_Id || ' AND a."ACYST_ActiveFlag" = true AND "CSS"."FMH_Id" = 155 AND l."FMH_Id" = 155
        GROUP BY b."AMCST_Id", b."AMCST_FirstName", b."AMCST_MiddleName", b."AMCST_LastName", b."AMCST_FatherName", b."AMCST_AdmNo", b."AMCST_RegistrationNo", h."FYP_ReceiptNo", h."FYP_ReceiptDate", "ACSTPS_LanguagesTaken", b."AMCST_FatherAnnIncome", Md."IMCC_CategoryName", MC."IMC_CasteName", b."AMCST_Sex", d."AMB_BranchName", b."AMCST_AadharNo"
        HAVING SUM(i."FTCP_FineAmount") > 0';

        EXECUTE v_sql2;

        UPDATE "Clg_StudentPaidAmt_Temp1" T 
        SET "FineAmount" = S."FineAmount" 
        FROM "Clg_StudentFineAmt_Temp1" S 
        WHERE T."AMCST_Id" = S."AMCST_Id";

        CREATE TEMP TABLE "Student_Fees_Details_Temp" AS 
        SELECT DISTINCT "StudentName", "AMCST_FatherName", "AMCST_AdmNo", "AMCST_RegistrationNo", "FYP_ReceiptNo", 
        MIN("FYP_ReceiptDate") AS "FYP_ReceiptDate", caste, gender, "ACSTPS_LanguagesTaken" AS "acstpS_LanguagesTaken", 
        annualincome, "PaidAmount", "FineAmount", "AMCST_AadharNo" 
        FROM "Clg_StudentPaidAmt_Temp1" 
        WHERE ("PaidAmount" <> 0 OR "PaidAmount" IS NULL)
        GROUP BY "StudentName", "AMCST_FatherName", "AMCST_AdmNo", "AMCST_RegistrationNo", "FYP_ReceiptNo", caste, gender, "ACSTPS_LanguagesTaken", annualincome, "PaidAmount", "FineAmount", "AMCST_AadharNo";

    ELSIF (v_CourseName = 'BCOM' OR v_CourseName = 'BBA') THEN

        v_sql1 := 'CREATE TEMP TABLE "Clg_StudentPaidAmt_Temp1" AS 
        SELECT b."AMCST_Id",
        (COALESCE(b."AMCST_FirstName",'''') || '' '' || COALESCE(b."AMCST_MiddleName",'''') || '' '' || COALESCE(b."AMCST_LastName",'''')) AS "StudentName",
        b."AMCST_FatherName",
        b."AMCST_AdmNo",
        b."AMCST_RegistrationNo",
        h."FYP_ReceiptNo",
        h."FYP_ReceiptDate",
        COALESCE(Md."IMCC_CategoryName",'''') || ''/'' || COALESCE(MC."IMC_CasteName",'''') AS caste,
        b."AMCST_Sex" AS gender,
        (c."AMCO_CourseName" || '' '' || ''subjects as per university syllabus '') AS "ACSTPS_LanguagesTaken",
        b."AMCST_FatherAnnIncome" AS annualincome,
        SUM(COALESCE("CSS"."FCSS_PaidAmount", 0)) AS "PaidAmount",
        0 AS "FineAmount",
        b."AMCST_AadharNo"
        FROM "clg"."Adm_College_Yearly_Student" a 
        INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id" AND b."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id" AND c."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id" AND d."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id" AND e."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id" AND f."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "clg"."Fee_Y_Payment_College_Student" g ON g."AMCST_Id" = a."AMCST_Id" AND g."asmay_id" = ' || p_ASMAY_Id || '
        LEFT JOIN "clg"."Fee_Y_Payment" h ON h."FYP_Id" = g."FYP_Id" AND h."asmay_id" = ' || p_ASMAY_Id || ' AND h."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "clg"."Fee_T_College_Payment" i ON i."FYP_Id" = h."FYP_Id"
        LEFT JOIN "clg"."Fee_College_Master_Amount_Semesterwise" j ON j."FCMAS_Id" = i."FCMAS_Id" AND j."MI_Id" = ' || p_MI_Id || ' AND j."AMSE_Id" = ' || p_AMSE_Id || '
        LEFT JOIN "clg"."Fee_College_Master_Amount" k ON k."FCMA_Id" = j."FCMA_Id" AND k."asmay_id" = ' || p_ASMAY_Id || ' AND k."FMG_Id" IN (' || p_Feegroup || ') AND k."MI_Id" = ' || p_MI_Id || ' AND k."AMCO_Id" = ' || p_AMCO_Id || ' AND k."AMB_Id" = ' || p_AMB_Id || '
        LEFT JOIN "Fee_Master_Head" l ON l."FMH_Id" = k."FMH_Id" AND l."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "CLG"."Fee_College_Student_Status" "CSS" ON "CSS"."FCMAS_Id" = j."FCMAS_Id" AND "CSS"."FMG_Id" = k."FMG_Id" AND "CSS"."AMCST_Id" = a."AMCST_Id" AND "CSS"."FMH_Id" = l."FMH_Id" AND "CSS"."ASMAY_Id" = ' || p_ASMAY_Id || '
        INNER JOIN "IVRM_Master_Caste" MC ON MC."IMC_Id" = b."IMC_Id" AND MC."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "IVRM_Master_Caste_Category" Md ON Md."IMCC_Id" = b."IMCC_Id"
        INNER JOIN "clg"."Adm_College_Quota" Mf ON Mf."ACQ_Id" = b."ACQ_Id" AND Mf."MI_Id" = ' || p_MI_Id || '
        WHERE a."asmay_id" = ' || p_ASMAY_Id || ' AND a."AMCO_Id" = ' || p_AMCO_Id || ' AND a."AMB_Id" = ' || p_AMB_Id || ' AND a."AMSE_Id" = ' || p_AMSE_Id || ' AND a."ACYST_ActiveFlag" = true
        GROUP BY b."AMCST_Id", b."AMCST_FirstName", b."AMCST_MiddleName", b."AMCST_LastName", b."AMCST_FatherName", b."AMCST_AdmNo", b."AMCST_RegistrationNo", h."FYP_ReceiptNo", h."FYP_ReceiptDate", b."AMCST_FatherAnnIncome", Md."IMCC_CategoryName", MC."IMC_CasteName", b."AMCST_Sex", c."AMCO_CourseName", b."AMCST_AadharNo"';

        EXECUTE v_sql1;

        v_sql2 := 'CREATE TEMP TABLE "Clg_StudentFineAmt_Temp1" AS 
        SELECT b."AMCST_Id",
        (COALESCE(b."AMCST_FirstName",'''') || '' '' || COALESCE(b."AMCST_MiddleName",'''') || '' '' || COALESCE(b."AMCST_LastName",'''')) AS "StudentName",
        b."AMCST_FatherName",
        b."AMCST_AdmNo",
        b."AMCST_RegistrationNo",
        h."FYP_ReceiptNo",
        h."FYP_ReceiptDate",
        COALESCE(Md."IMCC_CategoryName",'''') || ''/'' || COALESCE(MC."IMC_CasteName",'''') AS caste,
        b."AMCST_Sex" AS gender,
        (c."AMCO_CourseName" || '' '' || ''subjects as per university syllabus '') AS "ACSTPS_LanguagesTaken",
        b."AMCST_FatherAnnIncome" AS annualincome,
        0 AS "PaidAmount",
        SUM(COALESCE(i."FTCP_FineAmount", 0)) AS "FineAmount",
        b."AMCST_AadharNo"
        FROM "clg"."Adm_College_Yearly_Student" a 
        INNER JOIN "clg"."Adm_Master_College_Student" b ON a."AMCST_Id" = b."AMCST_Id" AND b."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id" AND c."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id" AND d."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "clg"."Adm_Master_Semester" e ON e."AMSE_Id" = a."AMSE_Id" AND e."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "Adm_School_M_Academic_Year" f ON f."ASMAY_Id" = a."ASMAY_Id" AND f."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "clg"."Fee_Y_Payment_College_Student" g ON g."AMCST_Id" = a."AMCST_Id" AND g."asmay_id" = ' || p_ASMAY_Id || '
        LEFT JOIN "clg"."Fee_Y_Payment" h ON h."FYP_Id" = g."FYP_Id" AND h."asmay_id" = ' || p_ASMAY_Id || ' AND h."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "clg"."Fee_T_College_Payment" i ON i."FYP_Id" = h."FYP_Id"
        LEFT JOIN "clg"."Fee_College_Master_Amount_Semesterwise" j ON j."FCMAS_Id" = i."FCMAS_Id" AND j."MI_Id" = ' || p_MI_Id || ' AND j."AMSE_Id" = ' || p_AMSE_Id || '
        LEFT JOIN "clg"."Fee_College_Master_Amount" k ON k."FCMA_Id" = j."FCMA_Id" AND k."asmay_id" = ' || p_ASMAY_Id || ' AND k."FMG_Id" IN (' || p_Feegroup || ') AND h."MI_Id" = ' || p_MI_Id || ' AND k."AMB_Id" = ' || p_AMB_Id || ' AND k."AMCO_Id" = ' || p_AMCO_Id || '
        LEFT JOIN "Fee_Master_Head" l ON l."FMH_Id" = k."FMH_Id" AND l."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "CLG"."Fee_College_Student_Status" "CSS" ON "CSS"."FCMAS_Id" = j."FCMAS_Id" AND "CSS"."FMG_Id" = k."FMG_Id" AND "CSS"."AMCST_Id" = a."AMCST_Id" AND "CSS"."FMH_Id" = l."FMH_Id" AND "CSS"."ASMAY_Id" = ' || p_ASMAY_Id || '
        INNER JOIN "IVRM_Master_Caste" MC ON MC."IMC_Id" = b."IMC_Id" AND MC."MI_Id" = ' || p_MI_Id || '
        INNER JOIN "IVRM_Master_Caste_Category" Md ON Md."IMCC_Id" = b."IMCC_Id"
        INNER JOIN "clg"."Adm_College_Quota" Mf ON Mf."ACQ_Id" = b."ACQ_Id" AND Mf."MI_Id" = ' || p_MI_Id || '
        LEFT JOIN "clg"."Adm_College_Student_PrevSchool" Me ON Me."AMCST_Id" = b."AMCST_Id"
        WHERE a."asmay_id" = ' || p_ASMAY_Id || ' AND a."AMCO_Id" = ' || p_AMCO_Id || ' AND a."AMB_Id" = ' || p_AMB_Id || ' AND a."AMSE_Id" = ' || p_AMSE_Id || ' AND a."ACYST_ActiveFlag" = true AND "CSS"."FMH_Id" = 155 AND l."FMH_Id" = 155
        GROUP BY b."AMCST_Id", b."AMCST_FirstName", b."AMCST_MiddleName", b."AMCST_LastName", b."AMCST_FatherName", b."AMCST_AdmNo", b."AMCST_RegistrationNo", h."FYP_ReceiptNo", h."FYP_ReceiptDate", "ACSTPS_LanguagesTaken", b."AMCST_FatherAnnIncome", Md."IMCC_CategoryName", MC."IMC_CasteName", b."AMCST_Sex", c."AMCO_CourseName", b."AMCST_AadharNo"
        HAVING SUM(i."FTCP_FineAmount") > 0';

        EXECUTE v_sql2;

        UPDATE "Clg_StudentPaidAmt_Temp1" T 
        SET "FineAmount" = S."FineAmount" 
        FROM "Clg_StudentFineAmt_Temp1" S 
        WHERE T."AMCST_Id" = S."AMCST_Id";

        CREATE TEMP TABLE "Student_Fees_Details_Temp" AS 
        SELECT DISTINCT "StudentName", "AMCST_FatherName", "AMCST_AdmNo", "AMCST_RegistrationNo", "FYP_ReceiptNo", 
        MIN("FYP_ReceiptDate") AS "FYP_ReceiptDate", caste, gender, "ACSTPS_LanguagesTaken" AS "acstpS_LanguagesTaken", 
        annualincome, "PaidAmount", "FineAmount", "AMCST_AadharNo" 
        FROM "Clg_StudentPaidAmt_Temp1" 
        WHERE ("PaidAmount" <> 0 OR "PaidAmount" IS NULL)
        GROUP BY "StudentName", "AMCST_FatherName", "AMCST_AdmNo", "AMCST_RegistrationNo", "FYP_ReceiptNo", caste, gender, "ACSTPS_LanguagesTaken", annualincome, "PaidAmount", "FineAmount", "AMCST_AadharNo";

    END IF;

    RETURN QUERY SELECT * FROM "Student_Fees_Details_Temp";

END;
$$;