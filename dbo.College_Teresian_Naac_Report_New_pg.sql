CREATE OR REPLACE FUNCTION "dbo"."College_Teresian_Naac_Report_New"(
    "p_mi_id" TEXT, 
    "p_asmay_id" TEXT, 
    "p_flag" TEXT, 
    "p_amco_id" TEXT DEFAULT NULL
)
RETURNS TABLE(
    result_data JSON
) 
LANGUAGE plpgsql
AS $$
DECLARE
    "v_query" TEXT;
    "v_query1" TEXT;
    "v_query2" TEXT;
    "v_female" TEXT;
    "v_male" TEXT;
    "v_AMCOC_Id" TEXT;
    "v_AMCOC_Name" TEXT;
    "v_AMCO_CourseName" TEXT;
    "v_AMCO_Id1" TEXT;
    "v_AMCO_Order" TEXT;
    "v_AMCO_NoOfYears" TEXT;
    "v_miid" TEXT;
    "v_ACSCD_SeatNos" TEXT;
    "v_alloted" TEXT;
    "v_sqlquery" TEXT;
    "v_PivotSelectColumnNames" TEXT;
    "v_PivotSelectColumnNames1" TEXT;
    "v_PivotColumnNames" TEXT;
    "cur_category" REFCURSOR;
    "cur_course" REFCURSOR;
BEGIN

    "v_female" := 'Female';
    "v_male" := 'Male';

    IF "p_flag" = 'StdAdm' THEN
    
        "v_query" := 'SELECT "ACQC_Id", "ACQC_CategoryName", SUM("da"."M_S") AS "Male", SUM("da"."F_S") AS "Female", "ASMAY_Id", "ASMAY_Year", "ASMAY_Order" 
        FROM (
            (SELECT "d"."ACQC_Id", "d"."ACQC_CategoryName", 0 AS "M_S", COUNT(*) AS "F_S", "c"."ASMAY_Id", "c"."ASMAY_Year", "ASMAY_Order"
            FROM "clg"."Adm_Master_College_Student" "a" 
            INNER JOIN "Adm_School_M_Academic_Year" "c" ON "a"."ASMAY_Id" = "c"."ASMAY_Id"
            INNER JOIN "clg"."Adm_College_Quota_Category" "d" ON "d"."ACQC_Id" = "a"."ACQC_Id"
            INNER JOIN "clg"."Adm_College_Quota" "e" ON "e"."ACQ_Id" = "a"."ACQ_Id"
            WHERE "a"."MI_Id" = ' || "p_mi_id" || ' AND "a"."ASMAY_Id" IN (' || "p_asmay_id" || ') AND "AMCST_Sex" = ''Female'' AND "amcst_sol" = ''S'' AND "amcst_activeflag" = 1
            GROUP BY "d"."ACQC_Id", "d"."ACQC_CategoryName", "c"."ASMAY_Id", "c"."ASMAY_Year", "ASMAY_Order")
            
            UNION
            
            (SELECT "d"."ACQC_Id", "d"."ACQC_CategoryName", COUNT(*) AS "M_S", 0 AS "F_S", "c"."ASMAY_Id", "c"."ASMAY_Year", "ASMAY_Order"
            FROM "clg"."Adm_Master_College_Student" "a"
            INNER JOIN "Adm_School_M_Academic_Year" "c" ON "a"."ASMAY_Id" = "c"."ASMAY_Id"
            INNER JOIN "clg"."Adm_College_Quota_Category" "d" ON "d"."ACQC_Id" = "a"."ACQC_Id"
            INNER JOIN "clg"."Adm_College_Quota" "e" ON "e"."ACQ_Id" = "a"."ACQ_Id"
            WHERE "a"."MI_Id" = ' || "p_mi_id" || ' AND "a"."ASMAY_Id" IN (' || "p_asmay_id" || ') AND "AMCST_Sex" = ''Male'' AND "amcst_sol" = ''S'' AND "amcst_activeflag" = 1
            GROUP BY "d"."ACQC_Id", "d"."ACQC_CategoryName", "c"."ASMAY_Id", "c"."ASMAY_Year", "ASMAY_Order")
        ) AS "da" 
        GROUP BY "da"."ACQC_Id", "da"."ACQC_CategoryName", "da"."ASMAY_Id", "da"."ASMAY_Year", "ASMAY_Order" 
        ORDER BY "ACQC_Id", "ASMAY_Order" LIMIT 100';
        
    END IF;

    IF "p_flag" = 'CatStd' THEN
    
        "v_query" := 'SELECT "d"."ACQC_Id", "d"."ACQC_CategoryName", COUNT(*) AS "No_of_Seats", "a"."AMCST_Sex", "b"."ASMAY_Id", "c"."ASMAY_Year"
        FROM "clg"."Adm_Master_College_Student" "a"
        INNER JOIN "clg"."Adm_College_Yearly_Student" "b" ON "a"."AMCST_Id" = "b"."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" "c" ON "b"."ASMAY_Id" = "c"."ASMAY_Id"
        INNER JOIN "clg"."Adm_College_Quota_Category" "d" ON "d"."ACQC_Id" = "a"."ACQC_Id"
        INNER JOIN "clg"."Adm_College_Quota" "e" ON "e"."ACQ_Id" = "a"."ACQ_Id"
        WHERE "a"."MI_Id" = ' || "p_mi_id" || ' AND "b"."ASMAY_Id" IN (' || "p_asmay_id" || ') AND "amcst_sol" = ''S'' AND "amcst_activeflag" = 1
        GROUP BY "d"."ACQC_Id", "d"."ACQC_CategoryName", "a"."AMCST_Sex", "b"."ASMAY_Id", "c"."ASMAY_Year"';
        
    END IF;

    IF "p_flag" = 'ProgOffer' THEN
    
        DELETE FROM "Temp_NaccReport" WHERE "Miid" = "p_mi_id";
        
        CREATE TABLE IF NOT EXISTS "Temp_NaccReport" (
            "Miid" TEXT, 
            "catgory" TEXT, 
            "coursename" TEXT, 
            "duration" TEXT, 
            "medium" TEXT, 
            "noofseatsan" TEXT, 
            "alloted" TEXT
        );
        
        OPEN "cur_category" FOR
        SELECT "AMCOC_Id", "AMCOC_Name" 
        FROM "clg"."Adm_Master_College_Category" 
        WHERE "mi_id" = "p_mi_id" AND "ACMC_ActiveFlag" = 1;
        
        LOOP
            FETCH "cur_category" INTO "v_AMCOC_Id", "v_AMCOC_Name";
            EXIT WHEN NOT FOUND;
            
            OPEN "cur_course" FOR
            SELECT "c"."AMCO_CourseName", "c"."AMCO_Id", "c"."AMCO_Order", "c"."AMCO_NoOfYears"
            FROM "clg"."Adm_Master_College_Category" "a" 
            INNER JOIN "clg"."Adm_Course_Category_Mapping" "b" ON "a"."AMCOC_Id" = "b"."AMCOC_Id"
            INNER JOIN "clg"."Adm_Master_Course" "c" ON "c"."AMCO_Id" = "b"."AMCO_Id"
            WHERE "b"."AMCOC_Id" = "v_AMCOC_Id" AND "b"."AMCOCM_ActiveFlg" = 1
            ORDER BY "c"."AMCO_Order";
            
            LOOP
                FETCH "cur_course" INTO "v_AMCO_CourseName", "v_AMCO_Id1", "v_AMCO_Order", "v_AMCO_NoOfYears";
                EXIT WHEN NOT FOUND;
                
                SELECT SUM("ACSCD_SeatNos")::TEXT INTO "v_ACSCD_SeatNos"
                FROM "clg"."Adm_College_Seat_Distribution"
                WHERE "ASMAY_Id" = "p_asmay_id" AND "AMCO_Id" = "v_AMCO_Id1"
                AND "AMSE_Id" IN (
                    SELECT "AMSE_Id" FROM "clg"."Adm_Master_Semester" 
                    WHERE "MI_Id" = "p_mi_id" LIMIT 1
                );
                
                SELECT COUNT(*)::TEXT INTO "v_alloted"
                FROM "clg"."Adm_Master_College_Student"
                INNER JOIN "Adm_School_M_Academic_Year" ON "Adm_School_M_Academic_Year"."asmay_id" = "clg"."Adm_Master_College_Student"."asmay_id"
                INNER JOIN "clg"."Adm_Master_Course" ON "clg"."Adm_Master_Course"."AMCO_Id" = "Adm_Master_College_Student"."AMCO_Id"
                WHERE "Adm_School_M_Academic_Year"."asmay_id" = "p_asmay_id" 
                AND "AMCST_SOL" = 's' 
                AND "clg"."Adm_Master_College_Student"."AMCO_Id" = "v_AMCO_Id1";
                
                INSERT INTO "Temp_NaccReport" VALUES("p_mi_id", "v_AMCOC_Name", "v_AMCO_CourseName", "v_AMCO_NoOfYears", 'English', "v_ACSCD_SeatNos", "v_alloted");
                
            END LOOP;
            CLOSE "cur_course";
            
        END LOOP;
        CLOSE "cur_category";
        
        RETURN QUERY SELECT row_to_json("t")::JSON FROM (SELECT * FROM "Temp_NaccReport" WHERE "Miid" = "p_mi_id") "t";
        RETURN;
        
    END IF;

    IF "p_flag" = 'DeptList' THEN
    
        DROP TABLE IF EXISTS "temp122";
        
        CREATE TEMP TABLE "temp122" AS
        SELECT "c"."AMCO_CourseName", "d"."AMB_BranchName", "c"."AMCO_Order", "d"."AMB_Order"
        FROM "clg"."Adm_College_AY_Course" "a" 
        INNER JOIN "clg"."Adm_College_AY_Course_Branch" "b" ON "a"."ACAYC_Id" = "b"."ACAYC_Id"
        INNER JOIN "clg"."Adm_Master_Course" "c" ON "c"."AMCO_Id" = "a"."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" "d" ON "d"."AMB_Id" = "b"."AMB_Id"
        WHERE "a"."ASMAY_Id" = "p_asmay_id" AND "a"."MI_Id" = "p_mi_id" 
        AND "a"."ACAYC_ActiveFlag" = 1 AND "b"."ACAYCB_ActiveFlag" = 1 
        AND "c"."AMCO_ActiveFlag" = 1 AND "d"."AMB_ActiveFlag" = 1
        ORDER BY "c"."AMCO_Order", "d"."AMB_Order";
        
        "v_query" := 'SELECT COUNT("AMB_BranchName") AS "no_of_dept", "B"."AMCO_CourseName" AS "amcO_CourseName",
        STRING_AGG("A"."AMB_BranchName", '', '') AS "branchname"
        FROM "temp122" "A"
        INNER JOIN "temp122" "B" ON "A"."AMCO_CourseName" = "B"."AMCO_CourseName"
        GROUP BY "B"."AMCO_CourseName"';
        
    END IF;

    IF "p_flag" = 'StdEnrol' THEN
    
        SELECT STRING_AGG(DISTINCT '''' || "AMCOC_Name" || '''', ',') INTO "v_PivotColumnNames"
        FROM (
            SELECT DISTINCT "AMCOC_Id", "AMCOC_Name" 
            FROM "clg"."Adm_Master_College_Category" 
            WHERE "Mi_id" = "p_mi_id" 
            ORDER BY "AMCOC_Id" LIMIT 100
        ) AS "PVColumns";
        
        SELECT STRING_AGG(DISTINCT 'COALESCE("' || "AMCOC_Name" || '", 0) AS "' || "AMCOC_Name" || '"', ',') INTO "v_PivotSelectColumnNames"
        FROM (
            SELECT DISTINCT "AMCOC_Id", "AMCOC_Name" 
            FROM "clg"."Adm_Master_College_Category" 
            WHERE "Mi_id" = "p_mi_id" 
            ORDER BY "AMCOC_Id" LIMIT 100
        ) AS "PVSelctedColumns";
        
        SELECT STRING_AGG(DISTINCT '"' || "AMCOC_Name" || '"', ' + ') INTO "v_PivotSelectColumnNames1"
        FROM (
            SELECT DISTINCT "AMCOC_Id", "AMCOC_Name" 
            FROM "clg"."Adm_Master_College_Category" 
            WHERE "Mi_id" = "p_mi_id" 
            ORDER BY "AMCOC_Id" LIMIT 100
        ) AS "PVSelctedColumns";
        
        "v_query" := 'SELECT DISTINCT "ACQ_QuotaName", "ACQ_Id", ' || "v_PivotSelectColumnNames" || ' FROM (
            SELECT DISTINCT "ACQ_QuotaName", "ACQ_Id", ' || "v_PivotSelectColumnNames" || ' FROM
            (SELECT "ACQ_QuotaName", "c"."AMCOC_Name", "h"."ACQ_Id", COUNT(*) AS "total"
            FROM "clg"."Adm_Master_College_Student" "a"
            INNER JOIN "clg"."Adm_College_Yearly_Student" "b" ON "a"."AMCST_Id" = "b"."AMCST_Id"
            INNER JOIN "clg"."Adm_Master_College_Category" "c" ON "c"."AMCOC_Id" = "a"."AMCOC_Id"
            INNER JOIN "clg"."Adm_Master_Course" "d" ON "d"."AMCO_Id" = "b"."AMCO_Id"
            INNER JOIN "clg"."Adm_Master_Branch" "e" ON "e"."AMB_Id" = "b"."AMB_Id"
            INNER JOIN "clg"."Adm_Master_Semester" "f" ON "f"."AMSE_Id" = "b"."AMSE_Id"
            INNER JOIN "clg"."Adm_College_Master_Section" "g" ON "g"."ACMS_Id" = "b"."ACMS_Id"
            INNER JOIN "clg"."Adm_College_Quota" "h" ON "h"."ACQ_Id" = "a"."ACQ_Id"
            WHERE "a"."AMCST_SOL" = ''S'' AND "a"."Mi_id" = ' || "p_mi_id" || ' 
            AND "a"."AMCST_ActiveFlag" = 1 AND "b"."ACYST_ActiveFlag" = 1 
            AND "b"."ASMAY_Id" IN (' || "p_asmay_id" || ')
            GROUP BY "ACQ_QuotaName", "c"."AMCOC_Name", "h"."ACQ_Id", "c"."AMCOC_Id") AS "a"
            -- Note: PostgreSQL CROSSTAB would be needed for proper pivoting
            ) AS "New"
            GROUP BY "ACQ_QuotaName", "ACQ_Id", ' || "v_PivotColumnNames" || ' ORDER BY "acq_id" LIMIT 100';
            
    END IF;

    IF "p_flag" = 'CasteRep' THEN
    
        "v_query" := 'SELECT "IVRMMR_Name", "IMCC_CategoryName", "ASMAY_Year", 
        SUM("f_s") AS "girls", SUM("m_s") AS "boys", (SUM("f_s") + SUM("m_s")) AS "total", 
        "IVRMMR_Id", "IMCC_Id", "AMSE_Year" FROM (
            SELECT "IVRMMR_Name", "e"."IMCC_CategoryName", "ASMAY_Year", COUNT(*) AS "F_S", 0 AS "M_S",
            "c"."IVRMMR_Id", "e"."IMCC_Id", "AMSE_Year"
            FROM "clg"."Adm_Master_College_Student" "a"
            INNER JOIN "clg"."Adm_College_Yearly_Student" "f" ON "f"."AMCST_Id" = "a"."AMCST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" "b" ON "b"."ASMAY_Id" = "f"."ASMAY_Id"
            INNER JOIN "clg"."Adm_Master_Course" "g" ON "g"."AMCO_Id" = "f"."AMCO_Id"
            INNER JOIN "clg"."Adm_Master_Branch" "h" ON "h"."AMB_Id" = "f"."AMB_Id"
            INNER JOIN "clg"."Adm_Master_Semester" "i" ON "i"."AMSE_Id" = "f"."AMSE_Id"
            INNER JOIN "IVRM_Master_Religion" "c" ON "c"."IVRMMR_Id" = "a"."IVRMMR_Id"
            LEFT JOIN "IVRM_Master_Caste" "d" ON "d"."IMC_Id" = "a"."IMC_Id"
            LEFT JOIN "IVRM_Master_Caste_Category" "e" ON "e"."IMCC_Id" = "d"."IMCC_Id" AND "e"."IMCC_Id" = "a"."IMCC_Id"
            WHERE "a"."Mi_id" = ' || "p_mi_id" || ' AND "a"."ASMAY_Id" IN (' || "p_asmay_id" || ') 
            AND "a"."AMCO_Id" = ' || COALESCE("p_amco_id", 'NULL') || ' 
            AND "AMCST_SOL" = ''S'' AND "AMCST_ActiveFlag" = 1 AND "f"."ACYST_ActiveFlag" = 1
            AND "f"."AMSE_Id" IN (SELECT "AMSE_Id" FROM "clg"."Adm_Master_Semester" WHERE "Mi_id" = ' || "p_mi_id" || ')
            AND "AMCST_Sex" = ''Female''
            GROUP BY "IVRMMR_Name", "d"."IMC_CasteName", "e"."IMCC_CategoryName", "ASMAY_Year", 
            "c"."IVRMMR_Id", "d"."IMC_Id", "e"."IMCC_Id", "AMSE_Year"
            
            UNION ALL
            
            SELECT "IVRMMR_Name", "e"."IMCC_CategoryName", "ASMAY_Year", 0 AS "F_S", COUNT(*) AS "M_S",
            "c"."IVRMMR_Id", "e"."IMCC_Id", "AMSE_Year"
            FROM "clg"."Adm_Master_College_Student" "a"
            INNER JOIN "clg"."Adm_College_Yearly_Student" "f" ON "f"."AMCST_Id" = "a"."AMCST_Id"
            INNER JOIN "Adm_School_M_Academic_Year" "b" ON "b"."ASMAY_Id" = "f"."ASMAY_Id"
            INNER JOIN "clg"."Adm_Master_Course" "g" ON "g"."AMCO_Id" = "f"."AMCO_Id"
            INNER JOIN "clg"."Adm_Master_Branch" "h" ON "h"."AMB_Id" = "f"."AMB_Id"
            INNER JOIN "clg"."Adm_Master_Semester" "i" ON "i"."AMSE_Id" = "f"."AMSE_Id"
            INNER JOIN "IVRM_Master_Religion" "c" ON "c"."IVRMMR_Id" = "a"."IVRMMR_Id"
            LEFT JOIN "IVRM_Master_Caste" "d" ON "d"."IMC_Id" = "a"."IMC_Id"
            LEFT JOIN "IVRM_Master_Caste_Category" "e" ON "e"."IMCC_Id" = "d"."IMCC_Id" AND "e"."IMCC_Id" = "a"."IMCC_Id"
            WHERE "a"."Mi_id" = ' || "p_mi_id" || ' AND "a"."ASMAY_Id" IN (' || "p_asmay_id" || ') 
            AND "a"."AMCO_Id" = ' || COALESCE("p_amco_id", 'NULL') || ' 
            AND "AMCST_SOL" = ''S'' AND "AMCST_ActiveFlag" = 1 AND "f"."ACYST_ActiveFlag" = 1
            AND "f"."AMSE_Id" IN (SELECT "AMSE_Id" FROM "clg"."Adm_Master_Semester" WHERE "Mi_id" = ' || "p_mi_id" || ')
            AND "AMCST_Sex" = ''Male''
            GROUP BY "IVRMMR_Name", "d"."IMC_CasteName", "e"."IMCC_CategoryName", "ASMAY_Year", 
            "c"."IVRMMR_Id", "d"."IMC_Id", "e"."IMCC_Id", "AMSE_Year"
        ) AS "d"
        GROUP BY "IVRMMR_Name", "IMCC_CategoryName", "ASMAY_Year", "IVRMMR_Id", "IMCC_Id", "AMSE_Year"
        ORDER BY "AMSE_Year", "IVRMMR_Id", "IMCC_Id" LIMIT 100';
        
    END IF;

    IF "p_flag" != 'ProgOffer' THEN
        RETURN QUERY EXECUTE "v_query";
    END IF;

END;
$$;