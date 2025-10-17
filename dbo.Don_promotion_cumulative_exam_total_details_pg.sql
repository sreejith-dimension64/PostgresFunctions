CREATE OR REPLACE FUNCTION "dbo"."Don_promotion_cumulative_exam_total_details"(
    p_MI_Id TEXT, 
    p_ASMAY_Id TEXT, 
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_FLAG TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT,
    "GROUPNAME" TEXT,
    "TOTALMAXMARKS" NUMERIC(18,2),
    "TOTALOBTAINEDMARKS" NUMERIC(18,2),
    "PERCENTAGEOBTAINED" NUMERIC(18,2),
    "POSITION" INTEGER,
    "GRANDTOTALOBRAINEDMARKS" TEXT,
    "ESTMP_POINTS" TEXT,
    "TOTALWORKINGDAYS" NUMERIC(18,2),
    "TOTALPRESENTDAYS" NUMERIC(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
  v_EMCA_Id BIGINT;
  v_EYC_Id BIGINT;
  v_COUNTEXAM BIGINT;
  v_GROUPNAME TEXT;
  v_COUNTATT BIGINT;
  v_GROUPNAMEATT TEXT;
  v_FROMDATE TIMESTAMP;
  v_TODATE TIMESTAMP;
  group_rec RECORD;
  att_rec RECORD;
BEGIN
  
  SELECT "EMCA_Id" INTO v_EMCA_Id 
  FROM "Exm"."Exm_Category_Class" 
  WHERE "MI_Id"=p_MI_Id::BIGINT AND "ASMAY_Id"=p_ASMAY_Id::BIGINT AND "ASMCL_Id"=p_ASMCL_Id::BIGINT 
    AND "ASMS_Id"=p_ASMS_Id::BIGINT AND "ECAC_ActiveFlag"=1;

  SELECT "EYC_Id" INTO v_EYC_Id 
  FROM "Exm"."Exm_Yearly_Category" 
  WHERE "MI_Id"=p_MI_Id::BIGINT AND "ASMAY_Id"=p_ASMAY_Id::BIGINT AND "EMCA_Id"=v_EMCA_Id AND "EYC_ActiveFlg"=1;

  IF p_FLAG='1' THEN
  
    DROP TABLE IF EXISTS "STJAMES_PROMOTION_CUMULATIVE_EXAM_TOTALMARKS_DETAILS";

    CREATE TEMP TABLE "STJAMES_PROMOTION_CUMULATIVE_EXAM_TOTALMARKS_DETAILS" (
        "AMST_Id" BIGINT, 
        "ASMAY_Id" BIGINT,
        "ASMCL_Id" BIGINT, 
        "ASMS_Id" BIGINT, 
        "GROUPNAME" TEXT, 
        "TOTALMAXMARKS" NUMERIC(18,2), 
        "TOTALOBTAINEDMARKS" NUMERIC(18,2), 
        "PERCENTAGEOBTAINED" NUMERIC(18,2), 
        "POSITION" INT, 
        "GRANDTOTALOBRAINEDMARKS" TEXT,
        "ESTMP_POINTS" TEXT
    );

    FOR group_rec IN 
        SELECT DISTINCT C."EMPSG_GroupName" as groupname, COUNT(DISTINCT D."EME_Id") as countexam
        FROM "Exm"."Exm_M_Promotion" A 
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" B ON A."EMP_Id"=B."EMP_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPS_Id"=B."EMPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id"=C."EMPSG_Id" AND D."EMPSGE_ActiveFlg"=1
        WHERE A."MI_Id"=p_MI_Id::BIGINT AND A."EYC_Id"=v_EYC_Id AND A."EMP_ActiveFlag"=1 
          AND B."EMPS_ActiveFlag"=1 AND C."EMPSG_ActiveFlag"=1
        GROUP BY C."EMPSG_GroupName" 
        HAVING COUNT(DISTINCT D."EME_Id")=1
    LOOP 
        v_GROUPNAME := group_rec.groupname;
        v_COUNTEXAM := group_rec.countexam;

        INSERT INTO "STJAMES_PROMOTION_CUMULATIVE_EXAM_TOTALMARKS_DETAILS"(
            "AMST_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "GROUPNAME", "TOTALMAXMARKS", "TOTALOBTAINEDMARKS", 
            "PERCENTAGEOBTAINED", "POSITION", "GRANDTOTALOBRAINEDMARKS", "ESTMP_POINTS"
        ) 
        SELECT 
            "AMST_Id", 
            "ASMAY_Id", 
            "ASMCL_Id", 
            "ASMS_Id",
            v_GROUPNAME, 
            "ESTMP_TotalMaxMarks", 
            "ESTMP_TotalObtMarks", 
            "ESTMP_Percentage", 
            "ESTMP_SectionPosition", 
            REPLACE(COALESCE(CAST("ESTMP_GrandTotal" as TEXT),''),'.00','') as "GRANDTOTAL", 
            (SELECT "EMPTSL_Points" 
             FROM "Exm"."Exm_Master_PointsSlab" 
             WHERE "EMPTSL_ActiveFlg"=1 
               AND (CAST("ESTMP_Percentage" as NUMERIC(18,2)) BETWEEN "EMPTSL_PercentFrom" AND "EMPTSL_PercentTo")
             LIMIT 1) AS "ESTMP_POINTS"
        FROM "Exm"."Exm_Student_Marks_Process" 
        WHERE "EME_Id" IN (
            SELECT DISTINCT D."EME_Id"
            FROM "Exm"."Exm_M_Promotion" A 
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" B ON A."EMP_Id"=B."EMP_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPS_Id"=B."EMPS_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id"=C."EMPSG_Id" AND D."EMPSGE_ActiveFlg"=1
            WHERE A."MI_Id"=p_MI_Id::BIGINT AND A."EYC_Id"=v_EYC_Id AND A."EMP_ActiveFlag"=1 
              AND B."EMPS_ActiveFlag"=1 AND C."EMPSG_ActiveFlag"=1 AND C."EMPSG_GroupName"=v_GROUPNAME
        )
        AND "ASMAY_Id"=p_ASMAY_Id::BIGINT AND "ASMCL_Id"=p_ASMCL_Id::BIGINT 
        AND "ASMS_Id"=p_ASMS_Id::BIGINT AND "MI_Id"=p_MI_Id::BIGINT;

    END LOOP;

    INSERT INTO "STJAMES_PROMOTION_CUMULATIVE_EXAM_TOTALMARKS_DETAILS"(
        "AMST_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "GROUPNAME", "TOTALMAXMARKS", "TOTALOBTAINEDMARKS", 
        "PERCENTAGEOBTAINED", "POSITION", "GRANDTOTALOBRAINEDMARKS", "ESTMP_POINTS"
    ) 
    SELECT 
        "AMST_Id", 
        "ASMAY_Id", 
        "ASMCL_Id", 
        "ASMS_Id",
        'Final Average', 
        "ESTMPP_TotalMaxMarks", 
        "ESTMPP_TotalObtMarks", 
        "ESTMPP_Percentage", 
        "ESTMPP_SectionPosition",
        REPLACE(COALESCE(CAST("ESTMPP_GrandTotal" as TEXT),''),'.00','') as "GRANDTOTAL",
        (SELECT "EMPTSL_Points" 
         FROM "Exm"."Exm_Master_PointsSlab" 
         WHERE "EMPTSL_ActiveFlg"=1 
           AND (CAST("ESTMPP_Percentage" as NUMERIC(18,2)) BETWEEN "EMPTSL_PercentFrom" AND "EMPTSL_PercentTo")
         LIMIT 1) AS "ESTMP_POINTS"
    FROM "Exm"."Exm_Student_MP_Promotion" 
    WHERE "ASMAY_Id"=p_ASMAY_Id::BIGINT AND "ASMCL_Id"=p_ASMCL_Id::BIGINT 
      AND "ASMS_Id"=p_ASMS_Id::BIGINT AND "MI_Id"=p_MI_Id::BIGINT;

    RETURN QUERY 
    SELECT 
        t."AMST_Id",
        t."ASMAY_Id",
        t."ASMCL_Id",
        t."ASMS_Id",
        t."GROUPNAME",
        t."TOTALMAXMARKS",
        t."TOTALOBTAINEDMARKS",
        t."PERCENTAGEOBTAINED",
        t."POSITION",
        t."GRANDTOTALOBRAINEDMARKS",
        t."ESTMP_POINTS",
        NULL::NUMERIC(18,2),
        NULL::NUMERIC(18,2)
    FROM "STJAMES_PROMOTION_CUMULATIVE_EXAM_TOTALMARKS_DETAILS" t;

  ELSIF p_FLAG='2' THEN

    DROP TABLE IF EXISTS "STJAMES_PROMOTION_CUMULATIVE_EXAM_ATTENDANCE_DETAILS";

    CREATE TEMP TABLE "STJAMES_PROMOTION_CUMULATIVE_EXAM_ATTENDANCE_DETAILS" (
        "AMST_Id" BIGINT, 
        "ASMAY_Id" BIGINT,
        "ASMCL_Id" BIGINT, 
        "ASMS_Id" BIGINT, 
        "GROUPNAME" TEXT, 
        "TOTALWORKINGDAYS" NUMERIC(18,2), 
        "TOTALPRESENTDAYS" NUMERIC(18,2), 
        "PERCENTAGEOBTAINED" NUMERIC(18,2)
    );

    FOR att_rec IN 
        SELECT DISTINCT C."EMPSG_GroupName" as groupname, COUNT(DISTINCT D."EME_Id") as countexam
        FROM "Exm"."Exm_M_Promotion" A 
        INNER JOIN "Exm"."Exm_M_Promotion_Subjects" B ON A."EMP_Id"=B."EMP_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPS_Id"=B."EMPS_Id"
        INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id"=C."EMPSG_Id" AND D."EMPSGE_ActiveFlg"=1
        WHERE A."MI_Id"=p_MI_Id::BIGINT AND A."EYC_Id"=v_EYC_Id AND A."EMP_ActiveFlag"=1 
          AND B."EMPS_ActiveFlag"=1 AND C."EMPSG_ActiveFlag"=1
        GROUP BY C."EMPSG_GroupName" 
        HAVING COUNT(DISTINCT D."EME_Id")=1
    LOOP 
        v_GROUPNAMEATT := att_rec.groupname;
        v_COUNTATT := att_rec.countexam;

        SELECT B."EYCE_AttendanceFromDate", B."EYCE_AttendanceToDate" 
        INTO v_FROMDATE, v_TODATE
        FROM "Exm"."Exm_Yearly_Category" A 
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" B ON A."EYC_Id"=B."EYC_Id" 
        WHERE "EME_Id" IN (
            SELECT DISTINCT D."EME_Id"
            FROM "Exm"."Exm_M_Promotion" A 
            INNER JOIN "Exm"."Exm_M_Promotion_Subjects" B ON A."EMP_Id"=B."EMP_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group" C ON C."EMPS_Id"=B."EMPS_Id"
            INNER JOIN "Exm"."Exm_M_Prom_Subj_Group_Exams" D ON D."EMPSG_Id"=C."EMPSG_Id" AND D."EMPSGE_ActiveFlg"=1
            WHERE A."MI_Id"=p_MI_Id::BIGINT AND A."EYC_Id"=v_EYC_Id AND A."EMP_ActiveFlag"=1 
              AND B."EMPS_ActiveFlag"=1 AND C."EMPSG_ActiveFlag"=1 AND C."EMPSG_GroupName"=v_GROUPNAMEATT
        )
        AND "ASMAY_Id"=p_ASMAY_Id::BIGINT AND B."EYC_Id"=v_EYC_Id 
        AND "MI_Id"=p_MI_Id::BIGINT AND B."EYCE_ActiveFlg"=1
        LIMIT 1;

        INSERT INTO "STJAMES_PROMOTION_CUMULATIVE_EXAM_ATTENDANCE_DETAILS"(
            "AMST_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "GROUPNAME", "TOTALWORKINGDAYS", "TOTALPRESENTDAYS", "PERCENTAGEOBTAINED"
        ) 
        SELECT 
            B."AMST_Id", 
            p_ASMAY_Id::BIGINT, 
            p_ASMCL_Id::BIGINT, 
            p_ASMS_Id::BIGINT,
            v_GROUPNAMEATT,
            SUM("ASA_ClassHeld"), 
            SUM("ASA_Class_Attended"),
            CAST(SUM("ASA_Class_Attended") * 100.0 / NULLIF(SUM("ASA_ClassHeld"), 0) AS NUMERIC(18,2))
        FROM "Adm_Student_Attendance" A 
        INNER JOIN "Adm_Student_Attendance_Students" B ON A."ASA_Id"=B."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id"=B."AMST_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_Id"=B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id"=C."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id"=C."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id"=C."ASMS_Id"   
        WHERE A."ASMAY_Id"=p_ASMAY_Id::BIGINT AND A."ASMCL_Id"=p_ASMCL_Id::BIGINT 
          AND A."ASMS_Id"=p_ASMS_Id::BIGINT AND A."ASA_Activeflag"=1 AND A."MI_Id"=p_MI_Id::BIGINT 
          AND C."ASMAY_Id"=p_ASMAY_Id::BIGINT AND C."ASMCL_Id"=p_ASMCL_Id::BIGINT AND C."ASMS_Id"=p_ASMS_Id::BIGINT   
          AND ((A."ASA_FromDate" BETWEEN v_FROMDATE AND v_TODATE) OR (A."ASA_ToDate" BETWEEN v_FROMDATE AND v_TODATE))
        GROUP BY B."AMST_Id";

    END LOOP;

    INSERT INTO "STJAMES_PROMOTION_CUMULATIVE_EXAM_ATTENDANCE_DETAILS"(
        "AMST_Id", "ASMAY_Id", "ASMCL_Id", "ASMS_Id", "GROUPNAME", "TOTALWORKINGDAYS", "TOTALPRESENTDAYS", "PERCENTAGEOBTAINED"
    ) 
    SELECT 
        B."AMST_Id", 
        p_ASMAY_Id::BIGINT, 
        p_ASMCL_Id::BIGINT, 
        p_ASMS_Id::BIGINT,
        'Final Average',
        SUM("ASA_ClassHeld"), 
        SUM("ASA_Class_Attended"),
        CAST(SUM("ASA_Class_Attended") * 100.0 / NULLIF(SUM("ASA_ClassHeld"), 0) AS NUMERIC(18,2))
    FROM "Adm_Student_Attendance" A 
    INNER JOIN "Adm_Student_Attendance_Students" B ON A."ASA_Id"=B."ASA_Id"
    INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id"=B."AMST_Id"
    INNER JOIN "Adm_M_Student" D ON D."AMST_Id"=B."AMST_Id"
    INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id"=C."ASMAY_Id"
    INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id"=C."ASMCL_Id"
    INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id"=C."ASMS_Id"   
    WHERE A."ASMAY_Id"=p_ASMAY_Id::BIGINT AND A."ASMCL_Id"=p_ASMCL_Id::BIGINT 
      AND A."ASMS_Id"=p_ASMS_Id::BIGINT AND A."ASA_Activeflag"=1 AND A."MI_Id"=p_MI_Id::BIGINT 
      AND C."ASMAY_Id"=p_ASMAY_Id::BIGINT AND C."ASMCL_Id"=p_ASMCL_Id::BIGINT AND C."ASMS_Id"=p_ASMS_Id::BIGINT  
    GROUP BY B."AMST_Id";

    RETURN QUERY 
    SELECT 
        t."AMST_Id",
        t."ASMAY_Id",
        t."ASMCL_Id",
        t."ASMS_Id",
        t."GROUPNAME",
        NULL::NUMERIC(18,2),
        NULL::NUMERIC(18,2),
        t."PERCENTAGEOBTAINED",
        NULL::INTEGER,
        NULL::TEXT,
        NULL::TEXT,
        t."TOTALWORKINGDAYS",
        t."TOTALPRESENTDAYS"
    FROM "STJAMES_PROMOTION_CUMULATIVE_EXAM_ATTENDANCE_DETAILS" t;

  END IF;

END;
$$;