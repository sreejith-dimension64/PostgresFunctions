CREATE OR REPLACE FUNCTION "dbo"."College_Teresian_Naac_Report"(
    "mi_id" TEXT,
    "asmay_id" TEXT,
    "flag" TEXT,
    "amco_id" TEXT DEFAULT NULL
)
RETURNS SETOF REFCURSOR
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
    "query1" TEXT;
    "query2" TEXT;
    "female" TEXT;
    "male" TEXT;
    ref1 REFCURSOR;
    ref2 REFCURSOR;
    ref3 REFCURSOR;
BEGIN

    "female" := 'Female';
    "male" := 'Male';

    IF "flag" = 'StdAdm' THEN
    
        "query" := 'SELECT d."ACQC_Id" , d."ACQC_CategoryName", count(*) as "No_of_Seats", a."AMCST_Sex", c."ASMAY_Id", c."ASMAY_Year" 
                    FROM "clg"."Adm_Master_College_Student" a
                    INNER JOIN "Adm_School_M_Academic_Year" c ON a."ASMAY_Id" = c."ASMAY_Id"
                    INNER JOIN "clg"."Adm_College_Quota_Category" d ON d."ACQC_Id" = a."ACQC_Id"
                    INNER JOIN "clg"."Adm_College_Quota" e ON e."ACQ_Id" = a."ACQ_Id"
                    WHERE a."MI_Id" = ' || "mi_id" || ' AND a."ASMAY_Id" IN (' || "asmay_id" || ') AND "AMCST_Sex" = ''' || "female" || '''
                    GROUP BY d."ACQC_Id", d."ACQC_CategoryName", a."AMCST_Sex", c."ASMAY_Id", c."ASMAY_Year"
                    UNION
                    SELECT d."ACQC_Id" , d."ACQC_CategoryName", count(*) as "No_of_Seats", a."AMCST_Sex", c."ASMAY_Id", c."ASMAY_Year" 
                    FROM "clg"."Adm_Master_College_Student" a
                    INNER JOIN "Adm_School_M_Academic_Year" c ON a."ASMAY_Id" = c."ASMAY_Id"
                    INNER JOIN "clg"."Adm_College_Quota_Category" d ON d."ACQC_Id" = a."ACQC_Id"
                    INNER JOIN "clg"."Adm_College_Quota" e ON e."ACQ_Id" = a."ACQ_Id"
                    WHERE a."MI_Id" = ' || "mi_id" || ' AND a."ASMAY_Id" IN (' || "asmay_id" || ') AND "AMCST_Sex" = ''' || "male" || '''
                    GROUP BY d."ACQC_Id", d."ACQC_CategoryName", a."AMCST_Sex", c."ASMAY_Id", c."ASMAY_Year"';
    
    END IF;

    IF "flag" = 'CatStd' THEN
    
        "query" := 'SELECT d."ACQC_Id" , d."ACQC_CategoryName", count(*) as "No_of_Seats", a."AMCST_Sex", b."ASMAY_Id", c."ASMAY_Year" 
                    FROM "clg"."Adm_Master_College_Student" a
                    INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                    INNER JOIN "Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
                    INNER JOIN "clg"."Adm_College_Quota_Category" d ON d."ACQC_Id" = a."ACQC_Id"
                    INNER JOIN "clg"."Adm_College_Quota" e ON e."ACQ_Id" = a."ACQ_Id"
                    WHERE a."MI_Id" = ' || "mi_id" || ' AND b."ASMAY_Id" IN (' || "asmay_id" || ')
                    GROUP BY d."ACQC_Id", d."ACQC_CategoryName", a."AMCST_Sex", b."ASMAY_Id", c."ASMAY_Year"';
    
    END IF;

    IF "flag" = 'ProgOffer' THEN
    
        "query" := 'SELECT e."AMCO_Id", d."AMCOC_Name", e."AMCO_CourseName", e."AMCO_NoOfYears",
                    (SELECT Count(a."AMCST_Id") FROM "clg"."Adm_Master_College_Student" a
                     INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                     INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                     INNER JOIN "clg"."Adm_Master_Semester" f ON f."AMSE_Id" = a."AMSE_Id"
                     WHERE a."MI_Id" = ' || "mi_id" || ' AND a."ASMAY_Id" IN (' || "asmay_id" || ') AND a."AMCO_Id" = e."AMCO_Id") as "Std_Approve",
                    (SELECT Count(b."AMCST_Id") FROM "clg"."Adm_Master_College_Student" a
                     INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                     INNER JOIN "clg"."Adm_Master_Course" c ON c."AMCO_Id" = a."AMCO_Id"
                     INNER JOIN "clg"."Adm_Master_Branch" d ON d."AMB_Id" = a."AMB_Id"
                     INNER JOIN "clg"."Adm_Master_Semester" f ON f."AMSE_Id" = a."AMSE_Id"
                     WHERE a."MI_Id" = ' || "mi_id" || ' AND a."ASMAY_Id" IN (' || "asmay_id" || ') AND a."AMCO_Id" = e."AMCO_Id") as "No_of_Adm"
                    FROM "clg"."Adm_Master_College_Student" a
                    INNER JOIN "clg"."Adm_Course_Category_Mapping" b ON b."AMCO_Id" = a."AMCO_Id"
                    INNER JOIN "clg"."Adm_College_Seat_Distribution" c ON c."AMCO_Id" = a."AMCO_Id"
                    INNER JOIN "clg"."Adm_Master_College_Category" d ON d."AMCOC_Id" = a."AMCOC_Id"
                    INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = a."AMCO_Id"
                    INNER JOIN "clg"."Adm_College_Yearly_Student" f ON f."AMCST_Id" = a."AMCST_Id"
                    WHERE a."MI_Id" = ' || "mi_id" || ' AND a."ASMAY_Id" IN (' || "asmay_id" || ')
                    GROUP BY e."AMCO_Id", d."AMCOC_Name", e."AMCO_CourseName", e."AMCO_NoOfYears"';
    
    END IF;

    IF "flag" = 'DeptList' THEN
    
        "query" := 'SELECT e."AMCOC_Id", e."AMCOC_Name", b."AMB_BranchName", b."AMB_Id" , c."AMCO_Id",
                    (SELECT m."AMCO_CourseName" FROM "clg"."Adm_Master_Course" m
                     INNER JOIN "clg"."Adm_Course_Branch_Mapping" n ON n."AMCO_Id" = m."AMCO_Id"
                     WHERE n."AMB_Id" = a."AMB_Id") as "Course",
                    (SELECT Count(DISTINCT a."AMB_Id") as "No_of_dept" FROM "clg"."Adm_Master_Branch" a
                     INNER JOIN "clg"."Adm_Course_Branch_Mapping" b ON a."AMB_Id" = b."AMB_Id"
                     WHERE b."AMCO_Id" = c."AMCO_Id") as "No_of_dept"
                    FROM "clg"."Adm_Course_Branch_Mapping" a
                    INNER JOIN "clg"."Adm_Master_Branch" b ON a."AMB_Id" = b."AMB_Id"
                    INNER JOIN "clg"."Adm_Master_Course" c ON a."AMCO_Id" = c."AMCO_Id"
                    INNER JOIN "clg"."Adm_Course_Category_Mapping" d ON d."AMCO_Id" = c."AMCO_Id"
                    INNER JOIN "clg"."Adm_Master_College_Category" e ON e."AMCOC_Id" = d."AMCOC_Id"
                    INNER JOIN "clg"."Adm_Master_College_Student" f ON f."MI_Id" = a."MI_Id"
                    WHERE a."MI_Id" = ' || "mi_id" || ' AND f."ASMAY_Id" IN (' || "asmay_id" || ')
                    GROUP BY c."AMCO_Id", e."AMCOC_Id", b."AMB_BranchName", a."AMB_Id", e."AMCOC_Name", b."AMB_Id"
                    ORDER BY e."AMCOC_Id"';

        "query1" := 'SELECT DISTINCT m."AMCO_Id", m."AMCO_CourseName", o."AMB_BranchName" 
                     FROM "clg"."Adm_Master_Course" m
                     INNER JOIN "clg"."Adm_Course_Branch_Mapping" n ON n."AMCO_Id" = m."AMCO_Id"
                     INNER JOIN "clg"."Adm_Master_Branch" o ON o."AMB_Id" = n."AMB_Id"
                     WHERE m."MI_Id" = ' || "mi_id";
    
    END IF;

    IF "flag" = 'StdEnrol' THEN
    
        "query" := 'SELECT d."ACQ_Id" , d."ACQ_QuotaName", e."AMCOC_Name", count(*) as "No_of_Seats", e."AMCOC_Id" 
                    FROM "clg"."Adm_Master_College_Student" a
                    INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                    INNER JOIN "Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
                    INNER JOIN "clg"."Adm_College_Quota" d ON d."ACQ_Id" = a."ACQ_Id"
                    INNER JOIN "clg"."Adm_Master_College_Category" e ON e."AMCOC_Id" = a."AMCOC_Id"
                    WHERE a."MI_Id" = ' || "mi_id" || ' AND b."ASMAY_Id" IN (' || "asmay_id" || ')
                    GROUP BY e."AMCOC_Id", d."ACQ_QuotaName", e."AMCOC_Name", d."ACQ_Id"
                    ORDER BY d."ACQ_Id"';

        "query1" := 'SELECT DISTINCT d."ACQ_Id" , d."ACQ_QuotaName", e."AMCOC_Name", e."AMCOC_Id" 
                     FROM "clg"."Adm_Master_College_Student" a
                     INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                     INNER JOIN "Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
                     INNER JOIN "clg"."Adm_College_Quota" d ON d."ACQ_Id" = a."ACQ_Id"
                     INNER JOIN "clg"."Adm_Master_College_Category" e ON e."AMCOC_Id" = a."AMCOC_Id"
                     WHERE a."MI_Id" = ' || "mi_id" || ' AND b."ASMAY_Id" IN (' || "asmay_id" || ')
                     GROUP BY d."ACQ_QuotaName", d."ACQ_Id", e."AMCOC_Name", e."AMCOC_Id" 
                     ORDER BY d."ACQ_Id"';

        "query2" := 'SELECT DISTINCT e."AMCOC_Name", e."AMCOC_Id" 
                     FROM "clg"."Adm_Master_College_Student" a
                     INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
                     INNER JOIN "Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
                     INNER JOIN "clg"."Adm_Master_College_Category" e ON e."AMCOC_Id" = a."AMCOC_Id"
                     WHERE a."MI_Id" = ' || "mi_id" || ' AND b."ASMAY_Id" IN (' || "asmay_id" || ')
                     GROUP BY e."AMCOC_Id", e."AMCOC_Name" 
                     ORDER BY e."AMCOC_Id"';
    
    END IF;

    IF "flag" = 'StdEnrol' OR "flag" = 'DeptList' THEN
        OPEN ref1 FOR EXECUTE "query";
        RETURN NEXT ref1;
        
        OPEN ref2 FOR EXECUTE "query1";
        RETURN NEXT ref2;
        
        OPEN ref3 FOR EXECUTE "query2";
        RETURN NEXT ref3;
    ELSE
        OPEN ref1 FOR EXECUTE "query";
        RETURN NEXT ref1;
    END IF;

    RETURN;
END;
$$;