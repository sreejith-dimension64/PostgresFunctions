CREATE OR REPLACE FUNCTION "dbo"."HR_Emploan_TotalAmount_Report"(
    p_mi_id BIGINT,
    p_hrmeid BIGINT,
    p_Month TEXT,
    p_Year BIGINT,
    p_HRMDES_Id TEXT
)
RETURNS TABLE(
    "hreLT_Month" VARCHAR(15),
    "hreLT_Year" BIGINT,
    "TotalBalanceForPrivouseMonth" DECIMAL(18,2),
    "TotalhreL_LoanAmount" DECIMAL(18,2),
    "TotalhreLT_LoanAmount" DECIMAL(18,2),
    "ToatlPaidAmount" DECIMAL(18,2)
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_HRME_Id BIGINT;
    v_HREL_Id BIGINT;
    v_HRELT_Id BIGINT;
    v_HRELT_Month TEXT;
    v_HRELT_Year BIGINT;
    v_HRELAPD_ToDate TIMESTAMP;
    v_HRELT_LoanAmount DECIMAL(18,2);
    v_PaidAmount DECIMAL(18,2);
    v_query1 TEXT;
    v_count BIGINT;
    v_query TEXT;
    rec_loan RECORD;
    rec_emp RECORD;
BEGIN

    DROP TABLE IF EXISTS "temploanreport";
    DROP TABLE IF EXISTS "loanreportinsert";

    CREATE TEMP TABLE "loanreportinsert"(
        "HREL_Id" BIGINT,
        "HRME_Id" BIGINT,
        "PaidAmount" DECIMAL(18,2),
        "HRELT_Month" VARCHAR(15),
        "HRELT_Year" BIGINT
    );

    CREATE TEMP TABLE "temploanreport"(
        "HRME_Id" BIGINT,
        "HREL_Id" BIGINT
    );

    v_query1 := 'INSERT INTO temploanreport
        SELECT a."HRME_Id", c."HREL_Id"
        FROM "HR_Master_Employee" a 
        INNER JOIN "HR_Emp_Loan" c ON c."HRME_Id" = a."HRME_Id"  
        INNER JOIN "HR_Emp_Loan_Transaction" d ON c."HREL_Id" = d."HREL_Id" AND c."HRME_Id" = d."HRME_Id" 
        WHERE a."MI_Id" = ' || p_mi_id || ' AND d."HRELT_Month" = ''' || p_Month || ''' AND d."HRELT_Year" = ' || p_Year || ' AND "HREL_ActiveFlag" = 1';

    EXECUTE v_query1;

    FOR rec_emp IN 
        SELECT "HRME_Id", "HREL_Id" FROM "temploanreport"
    LOOP
        v_HRME_Id := rec_emp."HRME_Id";
        v_HREL_Id := rec_emp."HREL_Id";

        v_PaidAmount := 0;
        v_count := 0;

        FOR rec_loan IN
            SELECT a."HRELT_Id", a."HRELT_LoanAmount", a."HRELT_Month", a."HRELT_Year"
            FROM "HR_Emp_Loan_Transaction" a
            INNER JOIN "IVRM_Month" b ON a."HRELT_Month" = b."IVRM_Month_Name" 
            WHERE "HREL_Id" = v_HREL_Id
            ORDER BY a."HRELT_Year", b."IVRM_Month_Id"
        LOOP
            v_HRELT_Id := rec_loan."HRELT_Id";
            v_HRELT_LoanAmount := rec_loan."HRELT_LoanAmount";
            v_HRELT_Month := rec_loan."HRELT_Month";
            v_HRELT_Year := rec_loan."HRELT_Year";

            IF (v_HRELT_Month = p_Month AND v_HRELT_Year = p_Year) THEN
                EXIT;
            ELSE
                v_count := v_count + 1;
                v_PaidAmount := v_PaidAmount + v_HRELT_LoanAmount;
            END IF;

        END LOOP;

        INSERT INTO "loanreportinsert" VALUES(v_HREL_Id, v_HRME_Id, v_PaidAmount, p_Month, p_Year);

    END LOOP;

    IF (p_hrmeid > 0) THEN

        RETURN QUERY
        SELECT 
            d."HRELT_Month"::VARCHAR(15) AS "hreLT_Month",
            d."HRELT_Year" AS "hreLT_Year",
            SUM(c."HREL_LoanAmount" - b."PaidAmount") AS "TotalBalanceForPrivouseMonth",
            SUM(c."HREL_LoanAmount") AS "TotalhreL_LoanAmount",
            SUM(d."HRELT_LoanAmount") AS "TotalhreLT_LoanAmount",
            SUM(b."PaidAmount") AS "ToatlPaidAmount"
        FROM "HR_Master_Employee" a 
        INNER JOIN "loanreportinsert" b ON a."HRME_Id" = b."HRME_Id"  
        INNER JOIN "HR_Emp_Loan" c ON c."HRME_Id" = a."HRME_Id" AND c."HREL_Id" = b."HREL_Id"
        INNER JOIN "HR_Emp_Loan_Transaction" d ON c."HREL_Id" = d."HREL_Id" AND c."HRME_Id" = d."HRME_Id"  
        INNER JOIN "HR_Master_Loan" e ON e."HRMLN_Id" = c."HRMLN_Id"  
        INNER JOIN "IVRM_Month" f ON f."IVRM_Month_Name" = d."HRELT_Month"  
        WHERE a."MI_Id" = p_mi_id AND d."HRELT_Month" = p_Month AND d."HRELT_Year" = p_Year 
        AND a."HRME_Id" = p_hrmeid
        GROUP BY d."HRELT_Month", d."HRELT_Year";

    ELSE

        v_query := 'SELECT 
            d."HRELT_Month"::VARCHAR(15) AS "hrelT_Month",
            d."HRELT_Year" AS "hrelT_Year",
            SUM(c."HREL_LoanAmount" - b."PaidAmount") AS "TotalBalanceForPrivouseMonth", 
            SUM(c."HREL_LoanAmount") AS "TotalhreL_LoanAmount",
            SUM(d."HRELT_LoanAmount") AS "TotalhreLT_LoanAmount",
            SUM(b."PaidAmount") AS "ToatlPaidAmount"
            FROM "HR_Master_Employee" a 
            INNER JOIN loanreportinsert b ON a."HRME_Id" = b."HRME_Id"  
            INNER JOIN "HR_Emp_Loan" c ON c."HRME_Id" = a."HRME_Id" AND c."HREL_Id" = b."HREL_Id"
            INNER JOIN "HR_Emp_Loan_Transaction" d ON c."HREL_Id" = d."HREL_Id" AND c."HRME_Id" = d."HRME_Id"  
            INNER JOIN "HR_Master_Loan" e ON e."HRMLN_Id" = c."HRMLN_Id"  
            INNER JOIN "IVRM_Month" f ON f."IVRM_Month_Name" = d."HRELT_Month"  
            WHERE a."MI_Id" = ' || p_mi_id || ' AND d."HRELT_Month" = ''' || p_Month || ''' AND d."HRELT_Year" = ' || p_Year || '
            GROUP BY d."HRELT_Month", d."HRELT_Year"';

        RETURN QUERY EXECUTE v_query;

    END IF;

    DROP TABLE IF EXISTS "temploanreport";
    DROP TABLE IF EXISTS "loanreportinsert";

    RETURN;

END;
$$;