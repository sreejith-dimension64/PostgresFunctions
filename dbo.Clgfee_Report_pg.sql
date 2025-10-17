CREATE OR REPLACE FUNCTION "dbo"."Clgfee_Report" (
    p_MI_Id bigint,
    p_ASMAY_Id bigint,
    p_FMG_Id text,
    p_FMH_Id text
)
RETURNS TABLE (
    "AMCO_Id" bigint,
    "AMCO_CourseName" varchar(100),
    "AMB_Id" bigint,
    "AMB_BranchName" varchar(100),
    "ASME_Id" bigint,
    "AMSE_SEMName" varchar(200),
    "AStudentCount" bigint,
    "AFCSS_CurrentYrCharges" DECIMAL(18,0),
    "AFCSS_TotalCharges" DECIMAL(18,0),
    "AFCSS_ConcessionAmount" DECIMAL(18,0),
    "AFCSS_AdjustedAmount" DECIMAL(18,0),
    "AFCSS_WaivedAmount" DECIMAL(18,0),
    "ACollection" DECIMAL(18,0),
    "ACollectionAnyTime" DECIMAL(18,0),
    "AReceivable" DECIMAL(18,0),
    "AStudentDue" DECIMAL(18,0),
    "ACollegeDue" DECIMAL(18,0),
    "AOverallDue" DECIMAL(18,0)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_AMCO_Id bigint;
    v_AMCO_CourseName varchar(200);
    v_StudentCount varchar(200);
    v_AMSE_SEMName varchar(200);
    v_FCSS_CurrentYrCharges DECIMAL(18,0);
    v_FCSS_TotalCharges DECIMAL(18,0);
    v_FCSS_ConcessionAmount DECIMAL(18,0);
    v_FCSS_AdjustedAmount DECIMAL(18,0);
    v_FCSS_WaivedAmount DECIMAL(18,0);
    v_AMB_Id bigint;
    v_AMB_BranchName varchar(100);
    v_BStudentCount bigint;
    v_BFCSS_CurrentYrCharges DECIMAL(18,0);
    v_BFCSS_TotalCharges DECIMAL(18,0);
    v_BFCSS_ConcessionAmount DECIMAL(18,0);
    v_BFCSS_AdjustedAmount DECIMAL(18,0);
    v_BFCSS_WaivedAmount DECIMAL(18,0);
    v_AMSE_Id bigint;
    v_AStudentCount bigint;
    v_AFCSS_CurrentYrCharges DECIMAL(18,0);
    v_AFCSS_TotalCharges DECIMAL(18,0);
    v_AFCSS_ConcessionAmount DECIMAL(18,0);
    v_AFCSS_AdjustedAmount DECIMAL(18,0);
    v_AFCSS_WaivedAmount DECIMAL(18,0);
    v_Collection DECIMAL(18,0);
    v_CollectionAnyTime DECIMAL(18,0);
    v_Receivable DECIMAL(18,0);
    v_StudentDue DECIMAL(18,0);
    v_CollegeDue DECIMAL(18,0);
    v_OverallDue DECIMAL(18,0);
    v_BCollection DECIMAL(18,0);
    v_BCollectionAnyTime DECIMAL(18,0);
    v_BReceivable DECIMAL(18,0);
    v_BStudentDue DECIMAL(18,0);
    v_BCollegeDue DECIMAL(18,0);
    v_BOverallDue DECIMAL(18,0);
    v_ACollection DECIMAL(18,0);
    v_ACollectionAnyTime DECIMAL(18,0);
    v_AReceivable DECIMAL(18,0);
    v_AStudentDue DECIMAL(18,0);
    v_ACollegeDue DECIMAL(18,0);
    v_AOverallDue DECIMAL(18,0);
    rec_fees RECORD;
    rec_branch RECORD;
    rec_semester RECORD;
BEGIN

    DROP TABLE IF EXISTS "ClgStudentReport";
    
    CREATE TEMP TABLE "ClgStudentReport"(
        "AMCO_Id" bigint,
        "AMCO_CourseName" VARCHAR(100),
        "StudentCount" BIGINT,
        "FCSS_CurrentYrCharges" DECIMAL(18,0),
        "FCSS_TotalCharges" DECIMAL(18,0),
        "FCSS_ConcessionAmount" DECIMAL(18,0),
        "FCSS_AdjustedAmount" DECIMAL(18,0),
        "FCSS_WaivedAmount" DECIMAL(18,0),
        "Collection" DECIMAL(18,0),
        "CollectionAnyTime" DECIMAL(18,0),
        "Receivable" DECIMAL(18,0),
        "StudentDue" DECIMAL(18,0),
        "CollegeDue" DECIMAL(18,0),
        "OverallDue" DECIMAL(18,0)
    );

    DROP TABLE IF EXISTS "STUDENTBRANCH";
    
    CREATE TEMP TABLE "STUDENTBRANCH" (
        "AMCO_Id" bigint,
        "AMB_Id" bigint,
        "AMB_BranchName" varchar(100),
        "BStudentCount" bigint,
        "BFCSS_CurrentYrCharges" DECIMAL(18,0),
        "BFCSS_TotalCharges" DECIMAL(18,0),
        "BFCSS_ConcessionAmount" DECIMAL(18,0),
        "BFCSS_AdjustedAmount" DECIMAL(18,0),
        "BFCSS_WaivedAmount" DECIMAL(18,0),
        "BCollection" DECIMAL(18,0),
        "BCollectionAnyTime" DECIMAL(18,0),
        "BReceivable" DECIMAL(18,0),
        "BStudentDue" DECIMAL(18,0),
        "BCollegeDue" DECIMAL(18,0),
        "BOverallDue" DECIMAL(18,0)
    );

    DROP TABLE IF EXISTS "ASTUDENTFEES";
    
    CREATE TEMP TABLE "ASTUDENTFEES"(
        "AMCO_Id" bigint,
        "AMB_Id" bigint,
        "ASME_Id" bigint,
        "AStudentCount" bigint,
        "AMSE_SEMName" varchar(200),
        "AFCSS_CurrentYrCharges" DECIMAL(18,0),
        "AFCSS_TotalCharges" DECIMAL(18,0),
        "AFCSS_ConcessionAmount" DECIMAL(18,0),
        "AFCSS_AdjustedAmount" DECIMAL(18,0),
        "AFCSS_WaivedAmount" DECIMAL(18,0),
        "ACollection" DECIMAL(18,0),
        "ACollectionAnyTime" DECIMAL(18,0),
        "AReceivable" DECIMAL(18,0),
        "AStudentDue" DECIMAL(18,0),
        "ACollegeDue" DECIMAL(18,0),
        "AOverallDue" DECIMAL(18,0)
    );

    FOR v_AMCO_Id, v_AMCO_CourseName, v_StudentCount IN
        SELECT DISTINCT "AMCO"."AMCO_Id", "AMCO"."AMCO_CourseName", COUNT("AMCS"."AMCST_Id")::varchar
        FROM "CLG"."Adm_Master_College_Student" "AMCS"
        INNER JOIN "CLG"."Adm_College_Yearly_Student" "ACYS" ON "AMCS"."AMCST_Id" = "ACYS"."AMCST_Id" 
            AND "AMCS"."AMCST_SOL" = 'S' AND "AMCS"."AMCST_ActiveFlag" = 1 AND "ACYS"."ACYST_ActiveFlag" = 1 AND "AMCS"."MI_Id" = p_MI_Id
        INNER JOIN "CLG"."Adm_Master_Course" "AMCO" ON "AMCO"."MI_Id" = p_MI_Id AND "AMCO"."AMCO_Id" = "AMCS"."AMCO_Id" AND "AMCO"."AMCO_Id" = "ACYS"."AMCO_Id"
        WHERE "AMCS"."MI_Id" = p_MI_Id 
            AND "AMCO"."AMCO_Id" IN (
                SELECT DISTINCT "AMCO_Id" FROM "CLG"."Adm_College_AY_Course" "ACAC" 
                INNER JOIN "CLG"."Adm_College_AY_Course_Branch" "ACACB" ON "ACACB"."MI_Id" = p_MI_Id AND "ACACB"."ACAYC_Id" = "ACAC"."ACAYC_Id"
                WHERE "ACAC"."AMCO_Id" = "AMCO"."AMCO_Id" AND "ACAC"."MI_Id" = p_MI_Id AND "ACAC"."ASMAY_Id" = p_ASMAY_Id
            )
        GROUP BY "AMCO"."AMCO_Id", "AMCO"."AMCO_CourseName"
    LOOP

        EXECUTE format($sql$
            SELECT SUM("FCSS"."FCSS_CurrentYrCharges"), SUM("FCSS"."FCSS_TotalCharges"),
                SUM("FCSS"."FCSS_ConcessionAmount"), SUM("FCSS"."FCSS_AdjustedAmount"), SUM("FCSS"."FCSS_WaivedAmount"),
                SUM("FCSS"."FCSS_PaidAmount"), SUM("FCSS"."FCSS_FineAmount"), SUM("FCSS"."FCSS_ToBePaid"), 
                SUM("FCSS"."FCSS_OBArrearAmount"), SUM("FCSS"."FCSS_OBExcessAmount"), 
                (SUM("FCSS"."FCSS_OBArrearAmount") - SUM("FCSS"."FCSS_OBExcessAmount"))
            FROM "CLG"."Fee_College_Master_Amount" "FCMA"
            INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" "FCMAS" ON "FCMAS"."MI_Id" = %s AND "FCMAS"."FCMA_Id" = "FCMA"."FCMA_Id"
            INNER JOIN "CLG"."Fee_College_Student_Status" "FCSS" ON "FCSS"."MI_Id" = %s AND "FCSS"."FCMAS_Id" = "FCMAS"."FCMAS_Id"
            INNER JOIN "dbo"."Fee_Master_Group" "FMG" ON "FMG"."FMG_Id" = "FCSS"."FMG_Id" AND "FMG"."MI_Id" = %s
            WHERE "FCMA"."MI_Id" = %s AND "FCMA"."AMCO_Id" = %s AND "FCSS"."ASMAY_Id" = %s 
                AND "FCSS"."FMG_Id" IN (%s) AND "FCSS"."FMH_Id" IN (%s)
        $sql$, p_MI_Id, p_MI_Id, p_MI_Id, p_MI_Id, v_AMCO_Id, p_ASMAY_Id, p_FMG_Id, p_FMH_Id)
        INTO v_FCSS_CurrentYrCharges, v_FCSS_TotalCharges, v_FCSS_ConcessionAmount, v_FCSS_AdjustedAmount, 
             v_FCSS_WaivedAmount, v_Collection, v_CollectionAnyTime, v_Receivable, v_StudentDue, v_CollegeDue, v_OverallDue;

        IF v_FCSS_CurrentYrCharges IS NOT NULL THEN
            INSERT INTO "ClgStudentReport" ("AMCO_Id", "AMCO_CourseName", "StudentCount", "FCSS_CurrentYrCharges", "FCSS_TotalCharges", 
                "FCSS_ConcessionAmount", "FCSS_AdjustedAmount", "FCSS_WaivedAmount", "Collection", "CollectionAnyTime", 
                "Receivable", "StudentDue", "CollegeDue", "OverallDue")
            VALUES (v_AMCO_Id, v_AMCO_CourseName, v_StudentCount::bigint, v_FCSS_CurrentYrCharges, v_FCSS_TotalCharges, 
                v_FCSS_ConcessionAmount, v_FCSS_AdjustedAmount, v_FCSS_WaivedAmount, v_Collection, v_CollectionAnyTime, 
                v_Receivable, v_StudentDue, v_CollegeDue, v_OverallDue);

            FOR v_AMB_Id, v_AMB_BranchName, v_BStudentCount IN
                SELECT DISTINCT "AMCS"."AMB_Id", "AMB"."AMB_BranchName", COUNT("AMCS"."AMCST_Id")
                FROM "CLG"."Adm_Master_College_Student" "AMCS"
                INNER JOIN "CLG"."Adm_College_Yearly_Student" "ACYS" ON "AMCS"."AMCST_Id" = "ACYS"."AMCST_Id"
                    AND "AMCS"."AMCST_SOL" = 'S' AND "AMCS"."AMCST_ActiveFlag" = 1 AND "ACYS"."ACYST_ActiveFlag" = 1 AND "AMCS"."MI_Id" = p_MI_Id
                INNER JOIN "CLG"."Adm_Master_Course" "AMCO" ON "AMCO"."MI_Id" = p_MI_Id AND "AMCO"."AMCO_Id" = "AMCS"."AMCO_Id" AND "AMCO"."AMCO_Id" = "ACYS"."AMCO_Id"
                INNER JOIN "CLG"."Adm_Master_Branch" "AMB" ON "AMB"."AMB_Id" = "AMCS"."AMB_Id" AND "AMB"."MI_Id" = p_MI_Id
                WHERE "AMCS"."MI_Id" = p_MI_Id 
                    AND "AMCO"."AMCO_Id" IN (
                        SELECT DISTINCT "AMCO_Id" FROM "CLG"."Adm_College_AY_Course" "ACAC"
                        INNER JOIN "CLG"."Adm_College_AY_Course_Branch" "ACACB" ON "ACACB"."MI_Id" = p_MI_Id AND "ACACB"."ACAYC_Id" = "ACAC"."ACAYC_Id"
                        WHERE "ACAC"."AMCO_Id" = "AMCO"."AMCO_Id" AND "ACAC"."MI_Id" = p_MI_Id AND "ACAC"."ASMAY_Id" = p_ASMAY_Id
                    )
                    AND "AMB"."AMB_Id" IN (
                        SELECT DISTINCT "AMB_Id" FROM "CLG"."Adm_College_AY_Course_Branch" "ACACB" WHERE "ACACB"."MI_Id" = p_MI_Id
                    )
                    AND "AMCS"."AMCO_Id" = v_AMCO_Id AND "AMCS"."ASMAY_Id" = p_ASMAY_Id
                GROUP BY "AMCS"."AMB_Id", "AMB"."AMB_BranchName"
            LOOP

                EXECUTE format($sql$
                    SELECT SUM("FCSS"."FCSS_CurrentYrCharges"), SUM("FCSS"."FCSS_TotalCharges"),
                        SUM("FCSS"."FCSS_ConcessionAmount"), SUM("FCSS"."FCSS_AdjustedAmount"), SUM("FCSS"."FCSS_WaivedAmount"),
                        SUM("FCSS"."FCSS_PaidAmount"), SUM("FCSS"."FCSS_FineAmount"), SUM("FCSS"."FCSS_ToBePaid"),
                        SUM("FCSS"."FCSS_OBArrearAmount"), SUM("FCSS"."FCSS_OBExcessAmount"),
                        (SUM("FCSS"."FCSS_OBArrearAmount") - SUM("FCSS"."FCSS_OBExcessAmount"))
                    FROM "CLG"."Fee_College_Master_Amount" "FCMA"
                    INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" "FCMAS" ON "FCMAS"."MI_Id" = %s AND "FCMAS"."FCMA_Id" = "FCMA"."FCMA_Id"
                    INNER JOIN "CLG"."Fee_College_Student_Status" "FCSS" ON "FCSS"."MI_Id" = %s AND "FCSS"."FCMAS_Id" = "FCMAS"."FCMAS_Id"
                    INNER JOIN "dbo"."Fee_Master_Group" "FMG" ON "FMG"."FMG_Id" = "FCSS"."FMG_Id" AND "FMG"."MI_Id" = %s
                    WHERE "FCMA"."MI_Id" = %s AND "FCMA"."AMCO_Id" = %s AND "FCMA"."AMB_Id" = %s 
                        AND "FCSS"."ASMAY_Id" = %s AND "FCSS"."FMG_Id" IN (%s) AND "FCSS"."FMH_Id" IN (%s)
                $sql$, p_MI_Id, p_MI_Id, p_MI_Id, p_MI_Id, v_AMCO_Id, v_AMB_Id, p_ASMAY_Id, p_FMG_Id, p_FMH_Id)
                INTO v_BFCSS_CurrentYrCharges, v_BFCSS_TotalCharges, v_BFCSS_ConcessionAmount, v_BFCSS_AdjustedAmount,
                     v_BFCSS_WaivedAmount, v_BCollection, v_BCollectionAnyTime, v_BReceivable, v_BStudentDue, v_BCollegeDue, v_BOverallDue;

                IF v_BFCSS_CurrentYrCharges IS NOT NULL THEN
                    INSERT INTO "STUDENTBRANCH" ("AMCO_Id", "AMB_Id", "AMB_BranchName", "BStudentCount", "BFCSS_CurrentYrCharges",
                        "BFCSS_TotalCharges", "BFCSS_ConcessionAmount", "BFCSS_AdjustedAmount", "BFCSS_WaivedAmount",
                        "BCollection", "BCollectionAnyTime", "BReceivable", "BStudentDue", "BCollegeDue", "BOverallDue")
                    VALUES (v_AMCO_Id, v_AMB_Id, v_AMB_BranchName, v_BStudentCount, v_BFCSS_CurrentYrCharges,
                        v_BFCSS_TotalCharges, v_BFCSS_ConcessionAmount, v_BFCSS_AdjustedAmount, v_BFCSS_WaivedAmount,
                        v_BCollection, v_BCollectionAnyTime, v_BReceivable, v_BStudentDue, v_BCollegeDue, v_BOverallDue);

                    FOR v_AMSE_Id, v_AMSE_SEMName, v_AStudentCount IN
                        SELECT DISTINCT "AMSE"."AMSE_Id", "AMSE"."AMSE_SEMName", COUNT("AMCS"."AMCST_Id")
                        FROM "CLG"."Adm_Master_College_Student" "AMCS"
                        INNER JOIN "CLG"."Adm_College_Yearly_Student" "ACYS" ON "AMCS"."AMCST_Id" = "ACYS"."AMCST_Id"
                            AND "AMCS"."AMCST_SOL" = 'S' AND "AMCS"."AMCST_ActiveFlag" = 1 AND "ACYS"."ACYST_ActiveFlag" = 1 AND "AMCS"."MI_Id" = p_MI_Id
                        INNER JOIN "CLG"."Adm_Master_Course" "AMCO" ON "AMCO"."MI_Id" = p_MI_Id AND "AMCO"."AMCO_Id" = "AMCS"."AMCO_Id" AND "AMCO"."AMCO_Id" = "ACYS"."AMCO_Id"
                        INNER JOIN "CLG"."Adm_Master_Branch" "AMB" ON "AMB"."AMB_Id" = "AMCS"."AMB_Id" AND "AMB"."MI_Id" = p_MI_Id AND "AMB"."AMB_Id" = "ACYS"."AMB_Id"
                        INNER JOIN "dbo"."Adm_School_M_Academic_Year" "ASMAY" ON "ASMAY"."ASMAY_Id" = p_ASMAY_Id AND "ASMAY"."MI_Id" = p_MI_Id
                        INNER JOIN "CLG"."Adm_Master_Semester" "AMSE" ON "AMSE"."MI_Id" = p_MI_Id AND "AMSE"."AMSE_Id" = "ACYS"."AMSE_Id"
                        WHERE "AMCS"."MI_Id" = p_MI_Id 
                            AND "AMCO"."AMCO_Id" IN (
                                SELECT DISTINCT "AMCO_Id" FROM "CLG"."Adm_College_AY_Course" "ACAC"
                                INNER JOIN "CLG"."Adm_College_AY_Course_Branch" "ACACB" ON "ACACB"."MI_Id" = p_MI_Id AND "ACACB"."ACAYC_Id" = "ACAC"."ACAYC_Id"
                                WHERE "ACAC"."AMCO_Id" = "AMCO"."AMCO_Id" AND "ACAC"."MI_Id" = p_MI_Id AND "ACAC"."ASMAY_Id" = "AMCS"."ASMAY_Id"
                            )
                            AND "AMB"."AMB_Id" IN (
                                SELECT DISTINCT "AMB_Id" FROM "CLG"."Adm_College_AY_Course_Branch" "ACACB" WHERE "ACACB"."MI_Id" = p_MI_Id
                            )
                            AND "AMSE"."AMSE_Id" IN (
                                SELECT DISTINCT "AMSE_Id" FROM "CLG"."Adm_Course_Branch_Mapping" "ACBM"
                                INNER JOIN "CLG"."Adm_Course_Branch_Semester_Mapping" "ACBSM" ON "ACBSM"."AMCOBM_Id" = "ACBM"."AMCOBM_Id" 
                                    AND "ACBSM"."MI_Id" = p_MI_Id AND "ACBSM"."AMSE_Id" = "AMSE"."AMSE_Id" AND "ACBM"."AMCO_Id" = "AMCO"."AMCO_Id"
                            )
                            AND "AMCS"."AMCO_Id" = v_AMCO_Id AND "AMCS"."AMB_Id" = v_AMB_Id AND "AMCS"."ASMAY_Id" = p_ASMAY_Id
                        GROUP BY "AMSE"."AMSE_Id", "AMSE"."AMSE_SEMName"
                    LOOP

                        EXECUTE format($sql$
                            SELECT SUM("FCSS"."FCSS_CurrentYrCharges"), SUM("FCSS"."FCSS_TotalCharges"),
                                SUM("FCSS"."FCSS_ConcessionAmount"), SUM("FCSS"."FCSS_AdjustedAmount"), SUM("FCSS"."FCSS_WaivedAmount"),
                                SUM("FCSS"."FCSS_PaidAmount"), SUM("FCSS"."FCSS_FineAmount"), SUM("FCSS"."FCSS_ToBePaid"),
                                SUM("FCSS"."FCSS_OBArrearAmount"), SUM("FCSS"."FCSS_OBExcessAmount"),
                                (SUM("FCSS"."FCSS_OBArrearAmount") - SUM("FCSS"."FCSS_OBExcessAmount"))
                            FROM "CLG"."Fee_College_Master_Amount" "FCMA"
                            INNER JOIN "CLG"."Fee_College_Master_Amount_Semesterwise" "FCMAS" ON "FCMAS"."MI_Id" = %s 
                                AND "FCMAS"."FCMA_Id" = "FCMA"."FCMA_Id" AND "FCMAS"."AMSE_Id" = %s
                            INNER JOIN "CLG"."Fee_College_Student_Status" "FCSS" ON "FCSS"."MI_Id" = %s AND "FCSS"."FCMAS_Id" = "FCMAS"."FCMAS_Id"
                            INNER JOIN "dbo"."Fee_Master_Group" "FMG" ON "FMG"."FMG_Id" = "FCSS"."FMG_Id" AND "FMG"."MI_Id" = %s
                            WHERE "FCMA"."MI_Id" = %s AND "FCMA"."AMCO_Id" = %s AND "FCMA"."AMB_Id" = %s 
                                AND "FCMA"."ASMAY_Id" = %s AND "FCSS"."FMG_Id" IN (%s) AND "FCSS"."FMH_Id" IN (%s)
                        $sql$, p_MI_Id, v_AMSE_Id, p_MI_Id, p_MI_Id, p_MI_Id, v_AMCO_Id, v_AMB_Id, p_ASMAY_Id, p_FMG_Id, p_FMH_Id)
                        INTO v_AFCSS_CurrentYrCharges, v_AFCSS_TotalCharges, v_AFCSS_ConcessionAmount, v_AFCSS_AdjustedAmount,
                             v_AFCSS_WaivedAmount, v_ACollection, v_ACollectionAnyTime, v_AReceivable, v_AStudentDue, v_ACollegeDue, v_AOverallDue;

                        IF v_AFCSS_CurrentYrCharges IS NOT NULL THEN
                            INSERT INTO "ASTUDENTFEES" 
                            VALUES (v_AMCO_Id, v_AMB_Id, v_AMSE_Id, v_AStudentCount, v_AMSE_SEMName, v_AFCSS_CurrentYrCharges,
                                v_AFCSS_TotalCharges, v_AFCSS_ConcessionAmount, v_AFCSS_AdjustedAmount, v_AFCSS_WaivedAmount,
                                v_ACollection, v_ACollectionAnyTime, v_AReceivable, v_AStudentDue, v_ACollegeDue, v_AOverallDue);
                        END IF;

                    END LOOP;
                END IF;

            END LOOP;
        END IF;

    END LOOP;

    RETURN QUERY
    SELECT "Course"."AMCO_Id", "Course"."AMCO_CourseName", "Branch"."AMB_Id", "Branch"."AMB_BranchName", 
           "AYear"."ASME_Id", "AYear"."AMSE_SEMName", "AYear"."AStudentCount", "AYear"."AFCSS_CurrentYrCharges",
           "AYear"."AFCSS_TotalCharges", "AYear"."AFCSS_ConcessionAmount", "AYear"."AFCSS_AdjustedAmount",
           "AYear"."AFCSS_WaivedAmount", "AYear"."ACollection", "AYear"."ACollectionAnyTime", "AYear"."AReceivable",
           "AYear"."AStudentDue", "AYear"."ACollegeDue", "AYear"."AOverallDue"
    FROM "ClgStudentReport" "Course"
    INNER JOIN "STUDENTBRANCH" "Branch" ON "Course"."AMCO_Id" = "Branch"."AMCO_Id"
    INNER JOIN "ASTUDENTFEES" "AYear" ON "AYear"."AMCO_Id" = "Course"."AMCO_Id" AND "AYear"."AMB_Id" = "Branch"."AMB_Id";

END;
$$;