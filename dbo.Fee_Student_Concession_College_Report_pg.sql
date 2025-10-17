CREATE OR REPLACE FUNCTION "dbo"."Fee_Student_Concession_College_Report"(
    "mid" TEXT,
    "ayamYear" TEXT,
    "groupids" TEXT,
    "Instids" TEXT,
    "Course" TEXT,
    "Branch" TEXT,
    "Sem" TEXT,
    "conditionFlag" VARCHAR(100),
    "type" TEXT,
    "concessiontype" TEXT,
    "report" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
    "str1" TEXT;
BEGIN

    IF "report" = 'Student' THEN
    BEGIN

        IF "Sem" = '0' THEN
            "str1" := 'AND ("CLG"."Adm_Master_Course"."AMCO_Id"=' || "Course" || ') AND ("CLG"."Adm_Master_Branch"."AMB_Id"=' || "Branch" || ') ';
        ELSE
            "str1" := 'AND ("CLG"."Adm_Master_Course"."AMCO_Id"=' || "Course" || ') AND ("CLG"."Adm_Master_Branch"."AMB_Id"=' || "Branch" || ') and ("CLG"."Adm_Master_Semester"."AMSE_Id"=' || "Sem" || ')';
        END IF;

        IF "conditionFlag" = 'allr' THEN

            IF "type" = 'T' THEN
            BEGIN

                IF "concessiontype" = '0' THEN
                BEGIN

                    "query" := 'SELECT DISTINCT COALESCE("CLG"."Adm_Master_College_Student"."AMCST_FirstName", '''') ||'' '' || COALESCE("CLG"."Adm_Master_College_Student"."AMCST_MiddleName", '''') 
                    || '' '' || COALESCE("CLG"."Adm_Master_College_Student"."AMCST_LastName", '''') AS "StudentName", "CLG"."Adm_Master_College_Student"."AMCST_AdmNo" AS "Admno", 
                    "CLG"."Adm_Master_Course"."AMCO_CourseName" AS "Course","CLG"."Adm_Master_Branch"."AMB_BranchName" AS "BranchName","CLG"."Adm_Master_Semester"."AMSE_SEMName" AS "Semester", 
                    "dbo"."Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "dbo"."Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("CLG"."Fee_College_Student_Status"."FCSS_NetAmount") 
                    AS "Netamount", SUM("CLG"."Fee_College_Student_Status"."FCSS_ConcessionAmount") AS "Concession", "CLG"."Fee_College_Student_Status"."FCSC_ConcessionReason"
                    FROM "CLG"."Fee_College_Student_Status" 
                    INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "CLG"."Fee_College_Student_Concession"."FMH_Id"
                    INNER JOIN "CLG"."Fee_College_Student_Concession" ON "CLG"."Fee_College_Student_Status"."AMCST_Id" = "CLG"."Fee_College_Student_Concession"."AMCST_Id" AND "CLG"."Fee_College_Student_Status"."ASMAY_Id"="CLG"."Fee_College_Student_Concession"."ASMAY_Id" and "CLG"."Fee_College_Student_Status"."FCMAS_Id"="CLG"."Fee_College_Student_Concession"."FCMAS_Id"
                    INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id" = "CLG"."Fee_College_Student_Concession"."FTI_Id" 
                    INNER JOIN "CLG"."Fee_C_Student_Concession_Installments"  ON "CLG"."Fee_College_Student_Status"."FTI_Id" = "CLG"."Fee_C_Student_Concession_Installments"."FTI_Id"
                    AND  "CLG"."Fee_College_Student_Concession"."FCSC_Id" = "CLG"."Fee_C_Student_Concession_Installments"."FCSC_Id" 
                    INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Fee_College_Student_Concession"."AMCST_Id" = "CLG"."Adm_Master_College_Student"."AMCST_Id"
                    INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
                    INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_College_Yearly_Student"."AMB_Id" = "CLG"."Adm_Master_Course"."AMCO_Id" 
                    INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_College_Yearly_Student"."AMB_Id" = "CLG"."Adm_Master_Branch"."AMB_Id" 
                    INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_College_Yearly_Student"."AMSE_Id" = "CLG"."Adm_Master_Semester"."AMSE_Id" 
                    INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id" 
                    WHERE ("CLG"."Fee_College_Student_Status"."FMG_Id" IN (' || "groupids" || ')) AND ("CLG"."Fee_College_Student_Status"."MI_Id" = ' || "mid" || ') AND ("CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ayamYear" || ') AND   ("CLG"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ayamYear" || ') and ("CLG"."Fee_College_Student_Concession"."ASMAY_Id" = ' || "ayamYear" || ') AND
                    ("CLG"."Fee_College_Student_Status"."FCSS_ConcessionAmount" > 0) and ("dbo"."Fee_T_Installment"."FTI_Id" in (' || "Instids" || '))
                    GROUP BY "CLG"."Adm_Master_College_Student"."AMCST_FirstName", "CLG"."Adm_Master_College_Student"."AMCST_MiddleName", "CLG"."Adm_Master_College_Student"."AMCST_LastName", 
                    "CLG"."Adm_Master_Course"."AMCO_CourseName", "CLG"."Adm_Master_Branch"."AMB_BranchName", "CLG"."Adm_Master_Semester"."AMSE_SEMName", "CLG"."Adm_Master_College_Student"."AMCST_AdmNo", 
                    "dbo"."Fee_Master_Group"."FMG_GroupName", "dbo"."Fee_Master_Head"."FMH_FeeName", "CLG"."Fee_College_Student_Concession"."FCSC_ConcessionReason"
                    ORDER BY "Course","BranchName","Semester"';

                END;
                ELSE
                BEGIN

                    "query" := 'SELECT DISTINCT COALESCE("CLG"."Adm_Master_College_Student"."AMCST_FirstName", '''') ||'' '' || COALESCE("CLG"."Adm_Master_College_Student"."AMCST_MiddleName", '''') 
                    || '' '' || COALESCE("CLG"."Adm_Master_College_Student"."AMCST_LastName", '''') AS "StudentName", "CLG"."Adm_Master_College_Student"."AMCST_AdmNo" AS "Admno", 
                    "CLG"."Adm_Master_Course"."AMCO_CourseName" AS "Course","CLG"."Adm_Master_Branch"."AMB_BranchName" AS "BranchName","CLG"."Adm_Master_Semester"."AMSE_SEMName" AS "Semester", 
                    "dbo"."Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "dbo"."Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("CLG"."Fee_College_Student_Status"."FCSS_NetAmount") 
                    AS "Netamount", SUM("CLG"."Fee_College_Student_Status"."FCSS_ConcessionAmount") AS "Concession", "CLG"."Fee_College_Student_Concession"."FCSC_ConcessionReason"
                    FROM "CLG"."Fee_College_Student_Status" 
                    INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "CLG"."Fee_College_Student_Concession"."FMH_Id"
                    INNER JOIN "CLG"."Fee_College_Student_Concession" ON "dbo"."Fee_Master_Head"."FMH_Id" = "CLG"."Fee_College_Student_Concession"."FMH_Id" 
                    AND "CLG"."Fee_College_Student_Concession"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id" and "CLG"."Fee_College_Student_Concession"."FCMAS_Id" = "CLG"."Fee_College_Student_Status"."FCMAS_Id"
                    AND "CLG"."Fee_College_Student_Status"."AMCST_Id" = "CLG"."Fee_College_Student_Concession"."AMCST_Id" AND "CLG"."Fee_College_Student_Status"."ASMAY_Id" = "CLG"."Fee_College_Student_Concession"."ASMAY_Id" 
                    INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id"="CLG"."Fee_College_Student_Status"."FTI_Id"
                    INNER JOIN "CLG"."Fee_C_Student_Concession_Installments" ON "dbo"."Fee_T_Installment"."FTI_Id" = "CLG"."Fee_C_Student_Concession_Installments"."FTI_Id" AND  "CLG"."Fee_College_Student_Concession"."FCSC_Id" = "CLG"."Fee_C_Student_Concession_Installments"."FCSC_Id"  and "CLG"."Fee_College_Student_Status"."FTI_Id" = "CLG"."Fee_C_Student_Concession_Installments"."FTI_Id"
                    INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Fee_College_Student_Status"."AMCST_Id" = "CLG"."Fee_College_Student_Concession"."AMCST_Id" 
                    INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
                    INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = "CLG"."Adm_Master_Course"."AMCO_Id" 
                    INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_College_Yearly_Student"."AMB_Id" = "CLG"."Adm_Master_Branch"."AMB_Id" 
                    INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_College_Yearly_Student"."AMSE_Id" = "CLG"."Adm_Master_Semester"."AMSE_Id" 
                    INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id"
                    WHERE ("CLG"."Fee_College_Student_Status"."FMG_Id" IN (' || "groupids" || ')) AND ("CLG"."Fee_College_Student_Status"."MI_Id" = ' || "mid" || ') AND ("CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ayamYear" || ') AND   ("CLG"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ayamYear" || ') and ("CLG"."Fee_College_Student_Concession"."ASMAY_Id" = ' || "ayamYear" || ') AND
                    ("CLG"."Fee_College_Student_Status"."FCSS_ConcessionAmount" > 0) and ("dbo"."Fee_T_Installment"."FTI_Id" in (' || "Instids" || ')) and ("CLG"."Adm_Master_College_Student"."AMST_Concession_Type"=' || "concessiontype" || ')
                    GROUP BY "CLG"."Adm_Master_College_Student"."AMCST_FirstName", "CLG"."Adm_Master_College_Student"."AMCST_MiddleName", "CLG"."Adm_Master_College_Student"."AMCST_LastName", 
                    "CLG"."Adm_Master_Course"."AMCO_CourseName", "CLG"."Adm_Master_Semester"."AMSE_SEMName", "CLG"."Adm_Master_College_Student"."AMCST_AdmNo", 
                    "dbo"."Fee_Master_Group"."FMG_GroupName", "dbo"."Fee_Master_Head"."FMH_FeeName", "CLG"."Fee_College_Student_Concession"."FCSC_ConcessionReason"
                    ORDER BY "Course","BranchName","Semester"';

                END;
                END IF;

            END;
            ELSE
            BEGIN
                IF "concessiontype" = '0' THEN
                BEGIN

                    "query" := 'SELECT DISTINCT COALESCE("CLG"."Adm_Master_College_Student"."AMCST_FirstName", '''') ||'' '' || COALESCE("CLG"."Adm_Master_College_Student"."AMCST_MiddleName", '''') 
                    || '' '' || COALESCE("CLG"."Adm_Master_College_Student"."AMCST_LastName", '''') AS "StudentName", "CLG"."Adm_Master_College_Student"."AMCST_AdmNo" AS "Admno", 
                    "CLG"."Adm_Master_Course"."AMCO_CourseName" AS "Course","CLG"."Adm_Master_Branch"."AMB_BranchName" AS "BranchName","CLG"."Adm_Master_Semester"."AMSE_SEMName" AS "Semester",
                    "dbo"."Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "dbo"."Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("CLG"."Fee_College_Student_Status"."FCSS_NetAmount") 
                    AS "Netamount", SUM("CLG"."Fee_College_Student_Status"."FCSS_ConcessionAmount") AS "Concession", "CLG"."Fee_College_Student_Concession"."FCSC_ConcessionReason"
                    FROM "CLG"."Fee_College_Student_Status" 
                    INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "CLG"."Fee_College_Student_Concession"."FMH_Id"
                    INNER JOIN "CLG"."Fee_College_Student_Concession" ON "dbo"."Fee_Master_Head"."FMH_Id" = "CLG"."Fee_College_Student_Concession"."FMH_Id" 
                    AND "CLG"."Fee_College_Student_Concession"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id" and "CLG"."Fee_College_Student_Concession"."FCMAS_Id" = "CLG"."Fee_College_Student_Status"."FCMAS_Id"
                    AND "CLG"."Fee_College_Student_Status"."AMCST_Id" = "CLG"."Fee_College_Student_Concession"."AMCST_Id" AND "CLG"."Fee_College_Student_Status"."ASMAY_Id" = "CLG"."Fee_College_Student_Concession"."ASMAY_Id" 
                    INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id"="CLG"."Fee_College_Student_Status"."FTI_Id"
                    INNER JOIN "CLG"."Fee_C_Student_Concession_Installments" ON "dbo"."Fee_T_Installment"."FTI_Id" = "CLG"."Fee_C_Student_Concession_Installments"."FTI_Id" AND  "CLG"."Fee_College_Student_Concession"."FCSC_Id" = "CLG"."Fee_C_Student_Concession_Installments"."FCSC_Id"  and "CLG"."Fee_College_Student_Status"."FTI_Id" = "CLG"."Fee_C_Student_Concession_Installments"."FTI_Id"
                    INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Fee_College_Student_Status"."AMCST_Id" = "CLG"."Fee_College_Student_Concession"."AMCST_Id" 
                    INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
                    INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = "CLG"."Adm_Master_Course"."AMCO_Id" 
                    INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_College_Yearly_Student"."AMB_Id" = "CLG"."Adm_Master_Branch"."AMB_Id" 
                    INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_College_Yearly_Student"."AMSE_Id" = "CLG"."Adm_Master_Semester"."AMSE_Id" 
                    INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id"
                    WHERE ("CLG"."Fee_College_Student_Status"."FMG_Id" IN (' || "groupids" || ')) AND ("CLG"."Fee_College_Student_Status"."MI_Id" = ' || "mid" || ') AND ("CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ayamYear" || ') AND  ("CLG"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ayamYear" || ') and ("CLG"."Fee_College_Student_Concession"."ASMAY_Id" = ' || "ayamYear" || ') AND
                    ("CLG"."Fee_College_Student_Status"."FCSS_ConcessionAmount" > 0) 
                    GROUP BY "CLG"."Adm_Master_College_Student"."AMCST_FirstName", "CLG"."Adm_Master_College_Student"."AMCST_MiddleName", "CLG"."Adm_Master_College_Student"."AMCST_LastName", 
                    "CLG"."Adm_Master_Course"."AMCO_CourseName", "CLG"."Adm_Master_Semester"."AMSE_SEMName", "CLG"."Adm_Master_College_Student"."AMCST_AdmNo", 
                    "dbo"."Fee_Master_Group"."FMG_GroupName", "dbo"."Fee_Master_Head"."FMH_FeeName", "CLG"."Fee_College_Student_Concession"."FCSC_ConcessionReason"
                    ORDER BY "Course","BranchName","Semester"';

                END;
                ELSE
                BEGIN

                    "query" := 'SELECT DISTINCT COALESCE("CLG"."Adm_Master_College_Student"."AMCST_FirstName", '''') ||'' '' || COALESCE("CLG"."Adm_Master_College_Student"."AMCST_MiddleName", '''') 
                    || '' '' || COALESCE("CLG"."Adm_Master_College_Student"."AMCST_LastName", '''') AS "StudentName", "CLG"."Adm_Master_College_Student"."AMCST_AdmNo" AS "Admno", 
                    "CLG"."Adm_Master_Course"."AMCO_CourseName" AS "Course","CLG"."Adm_Master_Branch"."AMB_BranchName" AS "BranchName","CLG"."Adm_Master_Semester"."AMSE_SEMName" AS "Semester", 
                    "dbo"."Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "dbo"."Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("CLG"."Fee_College_Student_Status"."FCSS_NetAmount") 
                    AS "Netamount", SUM("CLG"."Fee_College_Student_Status"."FCSS_ConcessionAmount") AS "Concession", "CLG"."Fee_College_Student_Concession"."FCSC_ConcessionReason"
                    FROM "CLG"."Fee_College_Student_Status" 
                    INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "CLG"."Fee_College_Student_Concession"."FMH_Id"
                    INNER JOIN "CLG"."Fee_College_Student_Concession" ON "dbo"."Fee_Master_Head"."FMH_Id" = "CLG"."Fee_College_Student_Concession"."FMH_Id" 
                    AND "CLG"."Fee_College_Student_Concession"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id" and "CLG"."Fee_College_Student_Concession"."FCMAS_Id" = "CLG"."Fee_College_Student_Status"."FCMAS_Id"
                    AND "CLG"."Fee_College_Student_Status"."AMCST_Id" = "CLG"."Fee_College_Student_Concession"."AMCST_Id" AND "CLG"."Fee_College_Student_Status"."ASMAY_Id" = "CLG"."Fee_College_Student_Concession"."ASMAY_Id" 
                    INNER JOIN "dbo"."Fee_T_Installment" ON "dbo"."Fee_T_Installment"."FTI_Id"="CLG"."Fee_College_Student_Status"."FTI_Id"
                    INNER JOIN "CLG"."Fee_C_Student_Concession_Installments" ON "dbo"."Fee_T_Installment"."FTI_Id" = "CLG"."Fee_C_Student_Concession_Installments"."FTI_Id" AND  "CLG"."Fee_College_Student_Concession"."FCSC_Id" = "CLG"."Fee_C_Student_Concession_Installments"."FCSC_Id"  and "CLG"."Fee_College_Student_Status"."FTI_Id" = "CLG"."Fee_C_Student_Concession_Installments"."FTI_Id"
                    INNER JOIN "CLG"."Adm_Master_College_Student" ON "CLG"."Fee_College_Student_Status"."AMCST_Id" = "CLG"."Fee_College_Student_Concession"."AMCST_Id" 
                    INNER JOIN "CLG"."Adm_College_Yearly_Student" ON "CLG"."Adm_Master_College_Student"."AMCST_Id" = "CLG"."Adm_College_Yearly_Student"."AMCST_Id" 
                    INNER JOIN "CLG"."Adm_Master_Course" ON "CLG"."Adm_College_Yearly_Student"."AMCO_Id" = "CLG"."Adm_Master_Course"."AMCO_Id" 
                    INNER JOIN "CLG"."Adm_Master_Branch" ON "CLG"."Adm_College_Yearly_Student"."AMB_Id" = "CLG"."Adm_Master_Branch"."AMB_Id" 
                    INNER JOIN "CLG"."Adm_Master_Semester" ON "CLG"."Adm_College_Yearly_Student"."AMSE_Id" = "CLG"."Adm_Master_Semester"."AMSE_Id" 
                    INNER JOIN "dbo"."Fee_Master_Group" ON "dbo"."Fee_Master_Group"."FMG_Id" = "CLG"."Fee_College_Student_Status"."FMG_Id"
                    WHERE ("CLG"."Fee_College_Student_Status"."FMG_Id" IN (' || "groupids" || ')) AND ("CLG"."Fee_College_Student_Status"."MI_Id" = ' || "mid" || ') AND ("CLG"."Adm_College_Yearly_Student"."ASMAY_Id" = ' || "ayamYear" || ') AND  ("CLG"."Fee_College_Student_Status"."ASMAY_Id" = ' || "ayamYear" || ') and ("CLG"."Fee_College_Student_Concession"."ASMAY_Id" = ' || "ayamYear" || ') AND
                    ("CLG"."Fee_College_Student_Status"."FCSS_ConcessionAmount" > 0) and ("CLG"."Adm_Master_College_Student"."AMST_Concession_Type"=' || "concessiontype" || ')
                    GROUP BY "CLG"."Adm_Master_College_Student"."AMCST_FirstName", "CLG"."Adm_Master_College_Student"."AMCST_MiddleName", "CLG"."Adm_Master_College_Student"."AMCST_LastName", 
                    "CLG"."Adm_Master_Course"."AMCO_CourseName", "CLG"."Adm_Master_Semester"."AMSE_SEMName", "CLG"."Adm_Master_College_Student"."AMCST_AdmNo", 
                    "dbo"."Fee_Master_Group"."FMG_GroupName", "dbo"."Fee_Master_Head"."FMH_FeeName", "CLG"."Fee_College_Student_Concession"."FCSC_ConcessionReason"
                    ORDER BY "Course","BranchName","Semester"';

                END;
                END IF;
            END;
            END IF;

        ELSIF "conditionFlag" = 'Indi' THEN

            IF "type" = 'T' THEN
            BEGIN

                IF "concessiontype" = '0' THEN
                BEGIN

                    "query" := 'SELECT DISTINCT COALESCE("CLG"."Adm_Master_College_Student"."AMCST_FirstName", '''') ||'' '' || COALESCE("CLG"."Adm_Master_College_Student"."AMCST_MiddleName", '''') 
                    || '' '' || COALESCE("CLG"."Adm_Master_College_Student"."AMCST_LastName", '''') AS "StudentName" , "CLG"."Adm_Master_College_Student"."AMCST_AdmNo" AS "Admno", 
                    "CLG"."Adm_Master_Course"."AMCO_CourseName" AS "Course","CLG"."Adm_Master_Branch"."AMB_BranchName" AS "BranchName","CLG"."Adm_Master_Semester"."AMSE_SEMName" AS "Semester",
                    "dbo"."Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "dbo"."Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("CLG"."Fee_College_Student_Status"."FCSS_NetAmount") 
                    AS "Netamount", SUM("CLG"."Fee_College_Student_Status"."FCSS_ConcessionAmount") AS "Concession", "CLG"."Fee_College_Student_Concession"."FCSC_ConcessionReason"
                    FROM "CLG"."Fee_College_Student_Status" 
                    INNER JOIN "dbo"."Fee_Master_Head" ON "dbo"."Fee_Master_Head"."FMH_Id" = "CLG"."Fee_College_Student_Concession"."FMH_Id"
                    INNER JOIN "CLG"."Fee_College_Student_Concession" ON "dbo"."Fee_Master_Head"."FMH_Id" = "CLG"."Fee_College_Student_Concession"."FMH_Id" 
                    AND "CLG"."Fee_College_Student_Concession"