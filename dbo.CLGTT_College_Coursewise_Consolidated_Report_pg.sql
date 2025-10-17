CREATE OR REPLACE FUNCTION "dbo"."CLGTT_College_Coursewise_Consolidated_Report"(
    IN "MI_Id" bigint,
    IN "ASMAY_Id" bigint,
    IN "TTMC_Id" bigint,
    IN "AMCO_Id" bigint,
    IN "AMB_Id" bigint,
    IN "AMSE_Id" bigint,
    IN "ACMS_Id" bigint
)
RETURNS TABLE(
    "ISMS_Id" bigint,
    "ISMS_SubjectName" text,
    "TTMD_Id" bigint,
    "PCOUNT" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "NEW"."ISMS_Id",
        "NEW"."ISMS_SubjectName",
        "NEW"."TTMD_Id",
        SUM("NEW"."PCOUNT") AS "PCOUNT" 
    FROM (
        SELECT DISTINCT 
            "IMS"."ISMS_Id",
            "IMS"."ISMS_SubjectName",
            "D"."TTMD_Id",
            COUNT(DISTINCT "D"."TTMP_Id") AS "PCOUNT"
        FROM "dbo"."TT_Final_Generation_Detailed_College" "D"
        INNER JOIN "dbo"."TT_Final_Generation" "FG" ON "FG"."TTFG_Id" = "D"."TTFG_Id"
        INNER JOIN "CLG"."Adm_Master_Course" "UY" ON "UY"."AMCO_Id" = "D"."AMCO_Id"
        INNER JOIN "CLG"."Adm_Master_Branch" "UJ" ON "UJ"."AMB_Id" = "D"."AMB_Id"
        INNER JOIN "CLG"."Adm_Master_Semester" "UK" ON "UK"."AMSE_Id" = "D"."AMSE_Id"
        INNER JOIN "dbo"."TT_Master_Category" "UU" ON "UU"."TTMC_Id" = "FG"."TTMC_Id"
        INNER JOIN "CLG"."Adm_College_Master_Section" "UP" ON "UP"."ACMS_Id" = "D"."ACMS_Id"
        INNER JOIN "dbo"."IVRM_Master_Subjects" "IMS" ON "IMS"."ISMS_Id" = "D"."ISMS_Id"
        WHERE "FG"."MI_Id" = "MI_Id" 
            AND "FG"."ASMAY_Id" = "ASMAY_Id" 
            AND "D"."AMCO_Id" = "AMCO_Id" 
            AND "D"."AMB_Id" = "AMB_Id" 
            AND "D"."AMSE_Id" = "AMSE_Id" 
            AND "D"."ACMS_Id" = "ACMS_Id"
        GROUP BY "IMS"."ISMS_Id", "IMS"."ISMS_SubjectName", "D"."TTMD_Id"
    ) AS "NEW" 
    GROUP BY "NEW"."ISMS_Id", "NEW"."ISMS_SubjectName", "NEW"."TTMD_Id";
    
    RETURN;
END;
$$;