CREATE OR REPLACE FUNCTION "dbo"."College_Attendance_preview_save_dates"(
    "@MI_Id" TEXT,
    "@asmay_id" TEXT,
    "@amco_id" TEXT,
    "@amb_id" TEXT,
    "@amse_id" TEXT,
    "@acms_id" TEXT
)
RETURNS TABLE(
    "ACSA_Id" BIGINT,
    "ISMS_SubjectName" TEXT,
    "TTMP_PeriodName" TEXT,
    "ACSA_AttendanceDate" TIMESTAMP,
    "ISMS_OrderFlag" INTEGER,
    "TTMP_Id" BIGINT,
    "TotalPresent" BIGINT,
    "totalabsent" BIGINT,
    "totalcount" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "WHERECONDITIONFORBRANCH" TEXT;
    "WHERECONDITIONFORSECTION" TEXT;
    "SETQUERY" TEXT;
BEGIN

    IF "@amb_id" = '0' THEN
        "WHERECONDITIONFORBRANCH" := 'SELECT DISTINCT "AMB_Id" FROM "CLG"."Adm_Master_Branch" WHERE "MI_Id"=' || "@MI_Id" || ' AND "AMB_ActiveFlag"=1';
    ELSE
        "WHERECONDITIONFORBRANCH" := 'SELECT DISTINCT "AMB_Id" FROM "CLG"."Adm_Master_Branch" WHERE "MI_Id"=' || "@MI_Id" || ' AND "AMB_ActiveFlag"=1 AND "AMB_Id"=' || "@amb_id" || '';
    END IF;

    IF "@acms_id" = '0' THEN
        "WHERECONDITIONFORSECTION" := 'SELECT DISTINCT "ACMS_Id" FROM "CLG"."Adm_College_Master_Section" WHERE "MI_Id"=' || "@MI_Id" || ' AND "ACMS_ActiveFlag"=1';
    ELSE
        "WHERECONDITIONFORSECTION" := 'SELECT DISTINCT "ACMS_Id" FROM "CLG"."Adm_College_Master_Section" WHERE "MI_Id"=' || "@MI_Id" || ' AND "ACMS_ActiveFlag"=1 AND "ACMS_Id"=' || "@acms_id" || ' ';
    END IF;

    "SETQUERY" := '
    SELECT DISTINCT a."ACSA_Id", 
           (COALESCE(j."ISMS_SubjectName", '''') || '':'' || COALESCE(j."isms_subjectcode", '''')) AS "ISMS_SubjectName",
           k."TTMP_PeriodName",
           a."ACSA_AttendanceDate",
           j."ISMS_OrderFlag",
           c."TTMP_Id",
           SUM(b."ACSAS_ClassAttended") AS "TotalPresent",
           (COUNT(b."ACSAS_ClassAttended") - SUM(b."ACSAS_ClassAttended")) AS "totalabsent",
           COUNT(b."ACSAS_ClassAttended") AS "totalcount"
    FROM "clg"."Adm_College_Student_Attendance" a
    INNER JOIN "clg"."Adm_College_Student_Attendance_Students" b ON a."ACSA_Id" = b."ACSA_Id"
    INNER JOIN "clg"."Adm_College_Student_Attendance_Periodwise" c ON c."ACSA_Id" = a."ACSA_Id"
    INNER JOIN "clg"."Adm_College_Yearly_Student" d ON d."AMCST_Id" = b."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_College_Student" e ON e."AMCST_Id" = d."AMCST_Id"
    INNER JOIN "clg"."Adm_Master_Course" f ON f."AMCO_Id" = d."AMCO_Id" AND f."AMCO_Id" = a."AMCO_Id"
    INNER JOIN "clg"."Adm_Master_Branch" g ON g."amb_id" = d."amb_id" AND g."amb_id" = a."amb_id"
    INNER JOIN "clg"."Adm_Master_Semester" h ON h."AMSE_Id" = d."AMSE_Id" AND h."AMSE_Id" = a."AMSE_Id"
    INNER JOIN "clg"."Adm_College_Master_Section" i ON i."ACMS_Id" = d."ACMS_Id" AND i."ACMS_Id" = a."ACMS_Id"
    INNER JOIN "IVRM_Master_Subjects" j ON j."ISMS_Id" = a."ISMS_Id"
    INNER JOIN "TT_Master_Period" k ON k."TTMP_Id" = c."TTMP_Id"
    WHERE d."AMCO_Id" = ' || "@amco_id" || ' AND a."AMCO_Id" = ' || "@amco_id" || '
    AND d."AMB_Id" IN (' || "WHERECONDITIONFORBRANCH" || ')
    AND a."AMB_Id" IN (' || "WHERECONDITIONFORBRANCH" || ')
    AND a."AMSE_Id" = ' || "@amse_id" || '
    AND d."AMSE_Id" = ' || "@amse_id" || '
    AND a."ACMS_Id" IN (' || "WHERECONDITIONFORSECTION" || ')
    AND d."ACMS_Id" IN (' || "WHERECONDITIONFORSECTION" || ')
    AND a."ASMAY_Id" = ' || "@asmay_id" || ' AND d."ASMAY_Id" = ' || "@asmay_id" || ' 
    AND a."ACSA_ActiveFlag" = 1 AND a."MI_Id" = ' || "@MI_Id" || ' AND e."MI_Id" = ' || "@MI_Id" || '
    GROUP BY a."ACSA_Id", j."ISMS_SubjectName", k."TTMP_PeriodName", a."ACSA_AttendanceDate", j."ISMS_OrderFlag", c."TTMP_Id", j."isms_subjectcode"
    ORDER BY a."ACSA_AttendanceDate", j."ISMS_OrderFlag", c."TTMP_Id"';

    RETURN QUERY EXECUTE "SETQUERY";

END;
$$;