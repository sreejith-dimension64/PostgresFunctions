CREATE OR REPLACE FUNCTION "dbo"."Exm_P_Stud_Report_263"(
    "MI_Id" TEXT,
    "ASMAY_Id" TEXT
)
RETURNS TABLE(
    "AMB_BranchName" VARCHAR,
    "AMB_BranchCode" VARCHAR,
    "ASMAY_Id" BIGINT,
    "AMB_Id" BIGINT,
    "passStudent" BIGINT,
    "totalStudent" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sqldync" TEXT;
BEGIN

    "sqldync" := '
    SELECT "AMB_BranchName","AMB_BranchCode","new1"."ASMAY_Id","s"."AMB_Id","passStudent",COUNT("S"."AMCST_Id") as "totalStudent" 
    FROM (
        SELECT "AMB_BranchName","AMB_BranchCode","ASMAY_Id","AMB_Id",COUNT("AMCST_Id") as "passStudent" 
        FROM (
            SELECT DISTINCT "b"."AMB_BranchName","b"."AMB_BranchCode","a"."AMB_Id","a"."AMCO_Id","a"."ASMAY_Id","a"."AMCST_Id" 
            FROM "CLG"."Exm_Col_Student_Marks_Process" "a" 
            INNER JOIN "CLG"."Adm_Master_Branch" "b" ON "a"."MI_Id"="b"."MI_Id" AND "a"."AMB_Id"="b"."AMB_Id"  
            WHERE "a"."MI_Id" IN(' || "MI_Id" || ') AND "a"."ASMAY_Id" IN(' || "ASMAY_Id" || ') AND "ECSTMP_Result"=''Pass''
            AND "EME_Id" IN (SELECT "EME_Id" FROM "Exm"."Exm_Master_Exam" WHERE "MI_Id" IN(' || "MI_Id" || ') AND "EME_FinalExamFlag"=true)
        ) "New" 
        GROUP BY "AMB_BranchName","AMB_BranchCode","ASMAY_Id","AMB_Id"
    ) "new1" 
    INNER JOIN "CLG"."Exm_Col_Student_Marks_Process" "S" ON "S"."ASMAY_Id"="new1"."ASMAY_Id" AND "S"."AMB_Id"="new1"."AMB_Id" 
    AND "EME_Id" IN (SELECT "EME_Id" FROM "Exm"."Exm_Master_Exam" WHERE "MI_Id" IN(' || "MI_Id" || ') AND "EME_FinalExamFlag"=true)
    GROUP BY "AMB_BranchName","new1"."ASMAY_Id","AMB_BranchCode","passStudent","s"."AMB_Id"';

    RETURN QUERY EXECUTE "sqldync";

END;
$$;