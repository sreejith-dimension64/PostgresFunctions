CREATE OR REPLACE FUNCTION "dbo"."Clg_Teresian_Report_Adied_Unadied_Stength_Report"(
    "p_Mi_Id" TEXT,
    "p_ASMAY_Id" TEXT,
    "p_evenorodd" TEXT
)
RETURNS TABLE(
    "MI_id" TEXT,
    "couse_id" TEXT,
    "course_name" TEXT,
    "branch_id" TEXT,
    "branch_name" TEXT,
    "I Year" TEXT,
    "II Year" TEXT,
    "III Year" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_course" TEXT;
    "v_courseid" TEXT;
    "v_courseorder" TEXT;
    "v_branch" TEXT;
    "v_branchid" TEXT;
    "v_branchorder" TEXT;
    "v_semester" TEXT;
    "v_semesterid" TEXT;
    "v_semesterorder" TEXT;
    "v_count" TEXT;
    "v_int" BIGINT;
    "v_rowcount" INTEGER;
BEGIN
    "v_int" := 0;

    DROP TABLE IF EXISTS "temp_clg_teresian_report_adied";

    CREATE TEMP TABLE "temp_clg_teresian_report_adied" (
        "MI_id" TEXT,
        "couse_id" TEXT,
        "course_name" TEXT,
        "branch_id" TEXT,
        "branch_name" TEXT,
        "I Year" TEXT,
        "II Year" TEXT,
        "III Year" TEXT
    );

    FOR "v_course", "v_courseid", "v_courseorder" IN
        SELECT "mc"."AMCO_CourseName", "mc"."AMCO_Id", "mc"."AMCO_Order"
        FROM "clg"."Adm_College_AY_Course" "yc"
        INNER JOIN "clg"."Adm_Master_Course" "mc" ON "yc"."AMCO_Id" = "mc"."amco_id"
        INNER JOIN "Adm_School_M_Academic_Year" "my" ON "my"."ASMAY_Id" = "yc"."ASMAY_Id"
        WHERE "yc"."ASMAY_Id" = "p_ASMAY_Id" AND "yc"."MI_Id" = "p_Mi_Id" AND "mc"."MI_Id" = "p_Mi_Id"
            AND "yc"."ACAYC_ActiveFlag" = 1 AND "mc"."AMCO_ActiveFlag" = 1
        ORDER BY "mc"."AMCO_Order"
    LOOP

        FOR "v_branch", "v_branchid", "v_branchorder" IN
            SELECT "mb"."AMB_BranchName", "mb"."AMB_Id", "mb"."AMB_Order"
            FROM "clg"."Adm_College_AY_Course" "yc"
            INNER JOIN "clg"."Adm_Master_Course" "mc" ON "yc"."AMCO_Id" = "mc"."amco_id"
            INNER JOIN "clg"."Adm_College_AY_Course_Branch" "ycb" ON "ycb"."ACAYC_Id" = "yc"."ACAYC_Id"
            INNER JOIN "clg"."Adm_Master_Branch" "mb" ON "ycb"."AMB_Id" = "mb"."AMB_Id"
            INNER JOIN "Adm_School_M_Academic_Year" "my" ON "my"."ASMAY_Id" = "yc"."ASMAY_Id"
            WHERE "yc"."ASMAY_Id" = "p_ASMAY_Id" AND "yc"."MI_Id" = "p_Mi_Id" AND "mc"."MI_Id" = "p_Mi_Id"
                AND "yc"."ACAYC_ActiveFlag" = 1 AND "mc"."AMCO_ActiveFlag" = 1 AND "yc"."AMCO_Id" = "v_courseid"
            ORDER BY "mb"."AMB_Order"
        LOOP

            "v_int" := 0;

            FOR "v_semester", "v_semesterid", "v_semesterorder" IN
                SELECT DISTINCT "mse"."AMSE_SEMName", "mse"."AMSE_Id", "mse"."AMSE_SEMOrder"
                FROM "clg"."Adm_College_AY_Course" "yc"
                INNER JOIN "clg"."Adm_Master_Course" "mc" ON "yc"."AMCO_Id" = "mc"."amco_id"
                INNER JOIN "clg"."Adm_College_AY_Course_Branch" "ycb" ON "ycb"."ACAYC_Id" = "yc"."ACAYC_Id"
                INNER JOIN "clg"."Adm_Master_Branch" "mb" ON "ycb"."AMB_Id" = "mb"."AMB_Id"
                INNER JOIN "clg"."Adm_College_AY_Course_Branch_Semester" "ycbs" ON "ycbs"."ACAYCB_Id" = "ycb"."ACAYCB_Id"
                INNER JOIN "clg"."Adm_Master_Semester" "mse" ON "mse"."AMSE_Id" = "ycbs"."AMSE_Id"
                INNER JOIN "Adm_School_M_Academic_Year" "my" ON "my"."ASMAY_Id" = "yc"."ASMAY_Id"
                WHERE "yc"."ASMAY_Id" = "p_ASMAY_Id" AND "yc"."MI_Id" = "p_Mi_Id" AND "mc"."MI_Id" = "p_Mi_Id"
                    AND "yc"."AMCO_Id" = "v_courseid" AND "ycb"."AMB_Id" = "v_branchid"
                    AND "yc"."ACAYC_ActiveFlag" = 1 AND "mc"."AMCO_ActiveFlag" = 1 AND "mb"."AMB_ActiveFlag" = 1
                    AND "mse"."AMSE_ActiveFlg" = 1 AND "mse"."AMSE_EvenOdd" = "p_evenorodd" AND "ycb"."ACAYCB_ActiveFlag" = 1
                    AND "ycbs"."ACAYCBS_ActiveFlag" = 1
                ORDER BY "mse"."AMSE_SEMOrder"
                LIMIT 100
            LOOP

                IF "v_int" = 0 THEN
                    INSERT INTO "temp_clg_teresian_report_adied" ("MI_id", "couse_id", "course_name", "branch_id", "branch_name")
                    VALUES ("p_Mi_Id", "v_courseid", "v_course", "v_branchid", "v_branch");
                END IF;

                "v_int" := "v_int" + 1;

                SELECT COUNT("ys"."AMCST_Id")::TEXT INTO "v_count"
                FROM "clg"."Adm_College_Yearly_Student" "ys"
                INNER JOIN "clg"."Adm_Master_College_Student" "ms" ON "ys"."AMCST_Id" = "ms"."AMCST_Id"
                INNER JOIN "clg"."Adm_Master_Course" "mc" ON "mc"."AMCO_Id" = "ys"."AMCO_Id"
                INNER JOIN "clg"."Adm_Master_Branch" "mb" ON "mb"."AMB_Id" = "ys"."AMB_Id"
                INNER JOIN "clg"."Adm_Master_Semester" "mse" ON "mse"."AMSE_Id" = "ys"."AMSE_Id"
                WHERE "ys"."ASMAY_Id" = "p_ASMAY_Id" AND "ms"."MI_Id" = "p_Mi_Id" AND "mse"."AMSE_EvenOdd" = "p_evenorodd"
                    AND "ys"."AMSE_Id" = "v_semesterid" AND "ys"."AMCO_Id" = "v_courseid" AND "ys"."AMB_Id" = "v_branchid"
                    AND "ms"."AMCST_SOL" = 'S' AND "ms"."AMCST_ActiveFlag" = 1 AND "ys"."ACYST_ActiveFlag" = 1
                GROUP BY "mc"."AMCO_CourseName", "mb"."AMB_BranchName", "mse"."AMSE_SEMName", "mc"."AMCO_Order", "mb"."AMB_Order", "mse"."AMSE_SEMOrder"
                ORDER BY "mc"."AMCO_Order", "mb"."AMB_Order", "mse"."AMSE_SEMOrder";

                GET DIAGNOSTICS "v_rowcount" = ROW_COUNT;

                IF "v_rowcount" > 0 THEN
                    IF "v_count" IS NULL THEN
                        IF "v_int" = 1 THEN
                            UPDATE "temp_clg_teresian_report_adied" SET "I Year" = '0'
                            WHERE "couse_id" = "v_courseid" AND "branch_id" = "v_branchid" AND "MI_id" = "p_Mi_Id";
                        ELSIF "v_int" = 2 THEN
                            UPDATE "temp_clg_teresian_report_adied" SET "II Year" = '0'
                            WHERE "couse_id" = "v_courseid" AND "branch_id" = "v_branchid" AND "MI_id" = "p_Mi_Id";
                        ELSIF "v_int" = 3 THEN
                            UPDATE "temp_clg_teresian_report_adied" SET "III Year" = '0'
                            WHERE "couse_id" = "v_courseid" AND "branch_id" = "v_branchid" AND "MI_id" = "p_Mi_Id";
                        END IF;
                    ELSE
                        IF "v_int" = 1 THEN
                            UPDATE "temp_clg_teresian_report_adied" SET "I Year" = "v_count"
                            WHERE "couse_id" = "v_courseid" AND "branch_id" = "v_branchid" AND "MI_id" = "p_Mi_Id";
                        ELSIF "v_int" = 2 THEN
                            UPDATE "temp_clg_teresian_report_adied" SET "II Year" = "v_count"
                            WHERE "couse_id" = "v_courseid" AND "branch_id" = "v_branchid" AND "MI_id" = "p_Mi_Id";
                        ELSIF "v_int" = 3 THEN
                            UPDATE "temp_clg_teresian_report_adied" SET "III Year" = "v_count"
                            WHERE "couse_id" = "v_courseid" AND "branch_id" = "v_branchid" AND "MI_id" = "p_Mi_Id";
                        END IF;
                    END IF;
                ELSE
                    IF "v_int" = 1 THEN
                        UPDATE "temp_clg_teresian_report_adied" SET "I Year" = '0'
                        WHERE "couse_id" = "v_courseid" AND "branch_id" = "v_branchid" AND "MI_id" = "p_Mi_Id";
                    ELSIF "v_int" = 2 THEN
                        UPDATE "temp_clg_teresian_report_adied" SET "II Year" = '0'
                        WHERE "couse_id" = "v_courseid" AND "branch_id" = "v_branchid" AND "MI_id" = "p_Mi_Id";
                    ELSIF "v_int" = 3 THEN
                        UPDATE "temp_clg_teresian_report_adied" SET "III Year" = '0'
                        WHERE "couse_id" = "v_courseid" AND "branch_id" = "v_branchid" AND "MI_id" = "p_Mi_Id";
                    END IF;
                END IF;

            END LOOP;

        END LOOP;

    END LOOP;

    RETURN QUERY SELECT * FROM "temp_clg_teresian_report_adied";

END;
$$;