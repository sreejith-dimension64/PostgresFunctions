CREATE OR REPLACE FUNCTION "dbo"."HHS_Get_Exam_Attendance"(
    p_MI_Id TEXT,
    p_ASMAY_Id TEXT,
    p_ASMCL_Id TEXT,
    p_ASMS_Id TEXT,
    p_AMST_Id TEXT
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "TOTALWORKINGDAYS" DECIMAL(18,2),
    "PRESENTDAYS" DECIMAL(18,2),
    "EME_Id" INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_EYC_Id BIGINT;
    v_EMCA_Id BIGINT;
    v_FROMDATE TIMESTAMP;
    v_TODATE TIMESTAMP;
    v_EME_Id INTEGER;
    rec RECORD;
BEGIN
    
    SELECT "EMCA_Id" INTO v_EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "ASMCL_Id" = p_ASMCL_Id 
        AND "ASMS_Id" = p_ASMS_Id
        AND "ECAC_ActiveFlag" = 1;
    
    SELECT "EYC_Id" INTO v_EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = p_MI_Id 
        AND "ASMAY_Id" = p_ASMAY_Id 
        AND "EMCA_Id" = v_EMCA_Id 
        AND "EYC_ActiveFlg" = 1;
    
    DROP TABLE IF EXISTS "HHS_Temp_Exan_Report_ATTENDANCE_Details";
    
    CREATE TEMP TABLE "HHS_Temp_Exan_Report_ATTENDANCE_Details" (
        "AMST_Id" BIGINT,
        "TOTALWORKINGDAYS" DECIMAL(18,2),
        "PRESENTDAYS" DECIMAL(18,2),
        "EME_Id" INTEGER
    );
    
    FOR rec IN 
        SELECT DISTINCT d."EYCE_AttendanceFromDate", d."EYCE_AttendanceToDate", d."EME_Id"
        FROM "exm"."Exm_Yearly_Category" a
        INNER JOIN "exm"."Exm_Master_Category" b ON a."EMCA_Id" = b."EMCA_Id"
        INNER JOIN "exm"."Exm_Category_Class" c ON c."EMCA_Id" = a."EMCA_Id" AND c."EMCA_Id" = b."EMCA_Id"
        INNER JOIN "exm"."Exm_Yearly_Category_Exams" d ON d."EYC_Id" = a."EYC_Id"
        INNER JOIN "Adm_School_M_Academic_Year" e ON e."ASMAY_Id" = a."ASMAY_Id"
        WHERE a."ASMAY_Id" = p_ASMAY_Id 
            AND c."ASMCL_Id" = p_ASMCL_Id 
            AND c."ASMS_Id" = p_ASMS_Id 
            AND c."ASMAY_Id" = p_ASMAY_Id 
            AND b."MI_Id" = p_MI_Id
            AND a."EYC_ActiveFlg" = 1 
            AND b."EMCA_ActiveFlag" = 1 
            AND c."ECAC_ActiveFlag" = 1 
            AND d."EYCE_ActiveFlg" = 1 
            AND e."Is_Active" = 1
            AND d."EME_Id" IN (
                SELECT DISTINCT "EME_Id" 
                FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" 
                WHERE "AMST_Id" = p_AMST_Id 
                    AND "ASMAY_Id" = p_ASMAY_Id 
                    AND "ASMCL_Id" = p_ASMCL_Id
                    AND "ASMS_Id" = p_ASMS_Id 
                    AND "MI_Id" = p_MI_Id
            )
    LOOP
        v_FROMDATE := rec."EYCE_AttendanceFromDate";
        v_TODATE := rec."EYCE_AttendanceToDate";
        v_EME_Id := rec."EME_Id";
        
        INSERT INTO "HHS_Temp_Exan_Report_ATTENDANCE_Details" ("AMST_Id", "TOTALWORKINGDAYS", "PRESENTDAYS", "EME_Id")
        SELECT B."AMST_Id", 
               SUM(A."ASA_ClassHeld") AS TOTALWORKINGDAYS, 
               SUM(B."ASA_Class_Attended") AS PRESENTDAYS,
               v_EME_Id
        FROM "Adm_Student_Attendance" A 
        INNER JOIN "Adm_Student_Attendance_Students" B ON A."ASA_Id" = B."ASA_Id"
        INNER JOIN "Adm_School_Y_Student" C ON C."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_M_Student" D ON D."AMST_Id" = B."AMST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" E ON E."ASMAY_Id" = C."ASMAY_Id"
        INNER JOIN "Adm_School_M_Class" F ON F."ASMCL_Id" = C."ASMCL_Id"
        INNER JOIN "Adm_School_M_Section" G ON G."ASMS_Id" = C."ASMS_Id"
        WHERE A."ASMAY_Id" = p_ASMAY_Id 
            AND A."ASMCL_Id" = p_ASMCL_Id 
            AND A."ASMS_Id" = p_ASMS_Id 
            AND A."ASA_Activeflag" = 1 
            AND A."MI_Id" = p_MI_Id
            AND C."ASMAY_Id" = p_ASMAY_Id 
            AND C."ASMCL_Id" = p_ASMCL_Id 
            AND C."ASMS_Id" = p_ASMS_Id
            AND (A."ASA_FromDate" BETWEEN v_FROMDATE AND v_TODATE) 
            AND B."AMST_Id" = p_AMST_Id
        GROUP BY B."AMST_Id";
        
    END LOOP;
    
    RETURN QUERY 
    SELECT t."AMST_Id", t."TOTALWORKINGDAYS", t."PRESENTDAYS", t."EME_Id"
    FROM "HHS_Temp_Exan_Report_ATTENDANCE_Details" t;
    
END;
$$;