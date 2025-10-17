CREATE OR REPLACE FUNCTION "dbo"."CLG_TTEmployee_class_sections"(
    "MI_Id" BIGINT,
    "ASMAY_Id" BIGINT,
    "HRME_Id" BIGINT,
    "TTMD_Id" BIGINT
)
RETURNS TABLE(
    "p_Days" VARCHAR,
    "period" VARCHAR,
    "ismS_SubjectName" VARCHAR,
    "asmcL_ClassName" TEXT,
    "ttmdpT_StartTime" TIME,
    "ttmdpT_EndTime" TIME
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT DISTINCT 
        f."TTMD_DayName" AS "p_Days",
        e."TTMP_PeriodName" AS "period",
        g."ISMS_SubjectName" AS "ismS_SubjectName",
        STRING_AGG(CONCAT(c."AMCO_CourseName", '-', d."AMB_BranchName", '-', j."AMSE_SEMName"), '/') AS "asmcL_ClassName",
        h."TTMDPT_StartTime" AS "ttmdpT_StartTime",
        h."TTMDPT_EndTime" AS "ttmdpT_EndTime"
    FROM "TT_Final_Generation" a 
    INNER JOIN "TT_Final_Generation_Detailed_College" b ON a."TTFG_Id" = b."TTFG_Id"
    INNER JOIN "CLG"."Adm_Master_Course" c ON c."AMCO_Id" = b."AMCO_Id"
    INNER JOIN "CLG"."Adm_Master_Branch" d ON d."AMB_Id" = b."AMB_Id"
    INNER JOIN "CLG"."Adm_Master_Semester" j ON j."AMSE_Id" = b."AMSE_Id"
    INNER JOIN "TT_Master_Period" e ON b."TTMP_Id" = e."TTMP_Id"
    INNER JOIN "TT_Master_Day" f ON b."TTMD_Id" = f."TTMD_Id"
    INNER JOIN "IVRM_Master_Subjects" g ON b."ISMS_Id" = g."ISMS_Id" AND a."MI_Id" = g."MI_Id"
    INNER JOIN "TT_Master_Day_Period_Time" h ON h."TTMP_Id" = e."TTMP_Id" 
        AND h."TTMD_Id" = f."TTMD_Id"
        AND h."TTMP_Id" = b."TTMP_Id" 
        AND h."TTMD_Id" = b."TTMD_Id" 
        AND h."TTMC_Id" = a."TTMC_Id"
    WHERE a."ASMAY_Id" = "ASMAY_Id" 
        AND a."MI_Id" = "MI_Id" 
        AND c."MI_Id" = "MI_Id" 
        AND d."AMB_ActiveFlag" = 1 
        AND b."HRME_Id" = "HRME_Id" 
        AND h."TTMD_Id" = "TTMD_Id"
        AND h."TTMDPT_ActiveFlag" = TRUE 
        AND c."AMCO_ActiveFlag" = 1 
        AND b."TTMD_Id" = "TTMD_Id" 
        AND h."ASMAY_Id" = "ASMAY_Id"
    GROUP BY f."TTMD_DayName", e."TTMP_PeriodName", h."TTMDPT_StartTime", h."TTMDPT_EndTime", g."ISMS_SubjectName"
    ORDER BY "period";
END;
$$;