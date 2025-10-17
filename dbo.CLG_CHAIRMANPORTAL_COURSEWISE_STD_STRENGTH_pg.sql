CREATE OR REPLACE FUNCTION "dbo"."CLG_CHAIRMANPORTAL_COURSEWISE_STD_STRENGTH"(
    p_MI_Id bigint,
    p_ASMAY_Id bigint
)
RETURNS TABLE(
    "AMCO_Id" bigint,
    "AMCO_CourseName" text,
    "AMCO_Order" integer,
    "stud_count" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT 
        "C"."AMCO_Id",
        "C"."AMCO_CourseName",
        "C"."AMCO_Order",
        COUNT(DISTINCT "B"."AMCST_Id") AS stud_count
    FROM "Clg"."Adm_Master_College_Student" AS "A"
    INNER JOIN "CLG"."Adm_College_Yearly_Student" AS "B" ON "A"."AMCST_Id" = "B"."AMCST_Id"
    INNER JOIN "CLG"."Adm_Master_Course" AS "C" ON "C"."AMCO_Id" = "B"."AMCO_Id"
    WHERE "A"."MI_Id" = p_MI_Id 
        AND "B"."ASMAY_Id" = p_ASMAY_Id
        AND "A"."AMCST_SOL" = 'S' 
        AND "A"."AMCST_ActiveFlag" = 1 
        AND "B"."ACYST_ActiveFlag" = 1 
        AND "C"."AMCO_ActiveFlag" = 1
    GROUP BY "C"."AMCO_Id", "C"."AMCO_CourseName", "C"."AMCO_Order";
END;
$$;