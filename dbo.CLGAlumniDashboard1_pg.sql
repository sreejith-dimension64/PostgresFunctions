CREATE OR REPLACE FUNCTION "dbo"."CLGAlumniDashboard1"(
    "MI_Id" TEXT
)
RETURNS TABLE(
    "BATCHES" VARCHAR,
    "NOofstudents" BIGINT,
    "AMCO_CourseName" VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN 
    RETURN QUERY
    SELECT 
        "dbo"."Adm_School_M_Academic_Year"."ASMAY_Year" AS "BATCHES",
        COUNT("CLG"."Alumni_College_Master_Student"."ALCMST_Id") AS "NOofstudents",
        "cousrename"."AMCO_CourseName"
    FROM 
        "CLG"."Alumni_College_Master_Student"
    INNER JOIN 
        "dbo"."Adm_School_M_Academic_Year" ON 
        "CLG"."Alumni_College_Master_Student"."ASMAY_Id_Left" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"
    INNER JOIN 
        "CLG"."Adm_College_AY_Course" AS "cousre" ON 
        "cousre"."ASMAY_Id" = "dbo"."Adm_School_M_Academic_Year"."ASMAY_Id"
    INNER JOIN
        "CLG"."Adm_Master_Course" AS "cousrename" ON 
        "cousrename"."AMCO_Id" = "cousre"."AMCO_Id" 
        AND "CLG"."Alumni_College_Master_Student"."AMCO_Left_Id" = "cousre"."AMCO_Id"
    WHERE 
        "CLG"."Alumni_College_Master_Student"."MI_Id" = "MI_Id"
    GROUP BY 
        "dbo"."Adm_School_M_Academic_Year"."ASMAY_Year",
        "cousrename"."AMCO_CourseName"
    ORDER BY 
        "dbo"."Adm_School_M_Academic_Year"."ASMAY_Year" DESC;
END;
$$;