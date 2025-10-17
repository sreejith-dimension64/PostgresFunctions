CREATE OR REPLACE FUNCTION "dbo"."College_Subject_Details"(
    "MI_Id" integer,
    "AMCO_Id" integer,
    "flag" text,
    "AMB_Id" integer,
    "AMSE_Id" integer,
    "ACSS_Id" integer,
    "ACST_Id" integer
)
RETURNS TABLE(
    "ismS_Id" integer,
    "ismS_SubjectName" character varying,
    "ismS_SubjectCode" character varying,
    "ismS_Max_Marks" numeric,
    "ismS_Min_Marks" numeric,
    "ismS_OrderFlag" integer,
    "emE_Id" integer,
    "emE_ExamName" character varying,
    "EME_ExamOrder" integer
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF "flag" = '1' THEN
        RETURN QUERY
        SELECT DISTINCT 
            j."ISMS_Id" as "ismS_Id",
            j."ISMS_SubjectName" as "ismS_SubjectName",
            j."ISMS_SubjectCode" as "ismS_SubjectCode",
            j."ISMS_Max_Marks" as "ismS_Max_Marks",
            j."ISMS_Min_Marks" as "ismS_Min_Marks",
            j."ISMS_OrderFlag" as "ismS_OrderFlag",
            NULL::integer as "emE_Id",
            NULL::character varying as "emE_ExamName",
            NULL::integer as "EME_ExamOrder"
        FROM "CLG"."Exm_Col_Yearly_Scheme" s
        JOIN "Clg"."Exm_Col_Yearly_Scheme_Group" k ON s."ECYS_Id" = k."ECYS_Id"
        JOIN "clg"."Exm_Col_Yearly_Scheme_Group_Subjects" l ON k."ECYSG_Id" = l."ECYSG_Id"
        JOIN "IVRM_Master_Subjects" j ON l."ISMS_Id" = j."ISMS_Id"
        WHERE s."AMCO_Id" = "AMCO_Id"
          AND s."AMB_Id" = "AMB_Id"
          AND s."AMSE_Id" = "AMSE_Id"
          AND s."ACSS_Id" = "ACSS_Id"
          AND s."ACST_Id" = "ACST_Id"
          AND s."MI_Id" = "MI_Id"
          AND s."ECYS_ActiveFlag" = 1
          AND k."ECYSG_ActiveFlag" = 1
          AND l."ECYSGS_ActiveFlag" = 1
        ORDER BY j."ISMS_OrderFlag";
    END IF;

    IF "flag" = '2' THEN
        RETURN QUERY
        SELECT DISTINCT 
            NULL::integer as "ismS_Id",
            NULL::character varying as "ismS_SubjectName",
            NULL::character varying as "ismS_SubjectCode",
            NULL::numeric as "ismS_Max_Marks",
            NULL::numeric as "ismS_Min_Marks",
            NULL::integer as "ismS_OrderFlag",
            b."emE_Id",
            b."emE_ExamName",
            b."EME_ExamOrder"
        FROM "clg"."Exm_Col_Yearly_Scheme_Exams" a
        INNER JOIN "Exm"."Exm_Master_Exam" b ON a."EME_Id" = b."EME_Id"
        WHERE a."AMCO_Id" = "AMCO_Id" 
          AND a."AMB_Id" = "AMB_Id" 
          AND a."AMSE_Id" = "AMSE_Id" 
          AND a."ACSS_Id" = "ACSS_Id" 
          AND a."ACST_Id" = "ACST_Id"
        ORDER BY b."EME_ExamOrder";
    END IF;

    RETURN;

END;
$$;