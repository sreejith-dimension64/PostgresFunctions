CREATE OR REPLACE FUNCTION "dbo"."CLG_Exam_Month_End_Report" (
    "@mi_id" bigint, 
    "@asmay_id" bigint, 
    "@eme_id" bigint
)
RETURNS TABLE (
    "Course" VARCHAR,
    "Pass" BIGINT,
    "Fail" BIGINT,
    "AMCO_Order" INTEGER
)
LANGUAGE plpgsql
AS $$
BEGIN

    RETURN QUERY
    SELECT 
        (mailf."AMCO_CourseName") AS "Course", 
        SUM(mailf."Pass") AS "Pass",      
        SUM(mailf."Fail") AS "Fail",
        mailf."AMCO_Order"
    FROM (
        SELECT 
            b."AMCO_CourseName",
            b."AMCO_Order",
            e."AMB_BranchName",
            "AMSE_SEMName",
            "ACMS_SectionName",
            COUNT(a."ECSTMP_Result") AS "Pass", 
            0 AS "Fail"
        FROM "CLG"."Exm_Col_Student_Marks_Process" a 
        INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "CLG"."Adm_Master_Course" b ON a."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" e ON e."AMB_Id" = a."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" s ON s."AMSE_Id" = a."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" se ON se."ACMS_Id" = a."ACMS_Id"
        INNER JOIN "exm"."Exm_Master_Exam" d ON d."EME_Id" = a."EME_Id"
        WHERE a."mi_id" = "@mi_id" 
            AND a."ASMAY_Id" = "@asmay_id" 
            AND a."EME_Id" = "@eme_id" 
            AND a."ECSTMP_Result" = 'PASS'
        GROUP BY b."AMCO_CourseName", b."AMCO_Order", e."AMB_BranchName", "AMSE_SEMName", "ACMS_SectionName"
        
        UNION ALL
        
        SELECT 
            b."AMCO_CourseName",
            b."AMCO_Order",
            e."AMB_BranchName",
            "AMSE_SEMName",
            "ACMS_SectionName",
            0 AS "Pass",
            COUNT(a."ECSTMP_Result") AS "Fail"
        FROM "CLG"."Exm_Col_Student_Marks_Process" a
        INNER JOIN "Adm_School_M_Academic_Year" c ON c."ASMAY_Id" = a."ASMAY_Id"
        INNER JOIN "CLG"."Adm_Master_Course" b ON a."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" e ON e."AMB_Id" = a."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" s ON s."AMSE_Id" = a."AMSE_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" se ON se."ACMS_Id" = a."ACMS_Id"
        INNER JOIN "exm"."Exm_Master_Exam" d ON d."EME_Id" = a."EME_Id"
        WHERE a."mi_id" = "@mi_id" 
            AND a."ASMAY_Id" = "@asmay_id" 
            AND a."EME_Id" = "@eme_id" 
            AND a."ECSTMP_Result" = 'Fail'
        GROUP BY b."AMCO_CourseName", b."AMCO_Order", e."AMB_BranchName", "AMSE_SEMName", "ACMS_SectionName"
    ) mailf 
    GROUP BY mailf."AMCO_CourseName", mailf."AMCO_Order" 
    ORDER BY mailf."AMCO_Order";

END;
$$;