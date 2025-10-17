CREATE OR REPLACE FUNCTION "dbo"."Fee_Student_Concession_Report"(
    "mid" TEXT,
    "ayamYear" TEXT,
    "groupids" TEXT,
    "termids" TEXT,
    "class" TEXT,
    "section" TEXT,
    "conditionFlag" TEXT,
    "type" TEXT,
    "concessiontype" TEXT,
    "report" TEXT
)
RETURNS TABLE(
    "StudentName" TEXT,
    "Admno" TEXT,
    "Class" TEXT,
    "Section" TEXT,
    "FeeGroup" TEXT,
    "FeeHead" TEXT,
    "Netamount" NUMERIC,
    "Concession" NUMERIC,
    "FSC_ConcessionReason" TEXT,
    "Balance" NUMERIC,
    "Paid" NUMERIC,
    "FMCC_ConcessionName" TEXT,
    "FEC_ConcessionReason" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "query" TEXT;
    "str1" TEXT;
BEGIN

    IF "report" = 'Student' THEN
        BEGIN

            IF ("section" = '0') AND ("class" = '0') THEN
                BEGIN
                    "str1" := ' ';
                END;
            ELSIF ("class" != '0') AND ("section" = '0') THEN
                BEGIN
                    "str1" := 'AND ("Adm_School_M_Class"."ASMCL_Id"=' || "class" || ')';
                END;
            ELSIF ("class" != '0') AND ("section" != '0') THEN
                BEGIN
                    "str1" := 'AND ("Adm_School_M_Class"."ASMCL_Id"=' || "class" || ')and ("Adm_School_M_Section"."ASMS_Id"=' || "section" || ')';
                END;
            END IF;

            IF "conditionFlag" = 'allr' THEN
                IF "type" = 'T' THEN
                    BEGIN
                        IF "concessiontype" = '0' THEN
                            BEGIN
                                "query" := 'SELECT DISTINCT COALESCE("Adm_M_Student"."AMST_FirstName", '''') ||'' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') 
|| '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''') AS "StudentName", "Adm_M_Student"."AMST_AdmNo" AS "Admno", 
"Adm_School_M_Class"."ASMCL_ClassName" AS "Class", "Adm_School_M_Section"."ASMC_SectionName" AS "Section", 
"Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("Fee_Student_Status"."FSS_NetAmount") 
AS "Netamount", SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "Concession", "Fee_Student_Concession"."FSC_ConcessionReason", sum("FSS_ToBePaid") as "Balance", NULL::TEXT AS "Paid", NULL::TEXT AS "FMCC_ConcessionName", NULL::TEXT AS "FEC_ConcessionReason"
FROM "Fee_Student_Status" INNER JOIN "Fee_Master_Head" INNER JOIN
"Fee_Student_Concession" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Concession"."FMH_Id" INNER JOIN
"Fee_T_Installment" INNER JOIN "Fee_Student_Concession_Installments" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Concession_Installments"."FTI_Id" ON "Fee_Student_Concession"."FSC_Id" = "Fee_Student_Concession_Installments"."FSCI_FSC_Id" INNER JOIN
"Adm_M_Student" INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN
"Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" ON 
"Fee_Student_Concession"."AMST_Id" = "Adm_M_Student"."AMST_Id" ON "Fee_Student_Status"."FTI_Id" = "Fee_Student_Concession_Installments"."FTI_Id" AND 
"Fee_Student_Status"."AMST_Id" = "Fee_Student_Concession"."AMST_Id" INNER JOIN
"Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" INNER JOIN
"Fee_Master_Terms_FeeHeads" ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" AND 
"Fee_T_Installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" AND 
"Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id"
WHERE ("Fee_Student_Status"."FMG_Id" IN (' || "groupids" || ')) AND ("Fee_Student_Status"."MI_Id" = ' || "mid" || ') AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ayamYear" || ') AND ("Fee_Student_Status"."ASMAY_Id" = ' || "ayamYear" || ') and ("Fee_Student_Concession"."ASMAY_Id" = ' || "ayamYear" || ') AND
("Fee_Student_Status"."FSS_ConcessionAmount" > 0) and ("Fee_Master_Terms_FeeHeads"."fmt_id" in (' || "termids" || ')) and ("Adm_M_Student"."AMST_Concession_Type" IN (SELECT "FMCC_ID" FROM "Fee_Master_Concession" WHERE "MI_Id"=' || "mid" || '))
GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", 
"Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Adm_M_Student"."AMST_AdmNo", 
"Fee_Master_Group"."FMG_GroupName", "Fee_Master_Head"."FMH_FeeName", "Fee_Student_Concession"."FSC_ConcessionReason"
ORDER BY "Class", "Section"';
                                RAISE NOTICE '%', "query";
                            END;
                        ELSE
                            BEGIN
                                "query" := 'SELECT DISTINCT COALESCE("Adm_M_Student"."AMST_FirstName", '''') ||'' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') 
|| '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''') AS "StudentName", "Adm_M_Student"."AMST_AdmNo" AS "Admno", 
"Adm_School_M_Class"."ASMCL_ClassName" AS "Class", "Adm_School_M_Section"."ASMC_SectionName" AS "Section", 
"Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("Fee_Student_Status"."FSS_NetAmount") 
AS "Netamount", SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "Concession", "Fee_Student_Concession"."FSC_ConcessionReason", NULL::NUMERIC AS "Balance", NULL::TEXT AS "Paid", NULL::TEXT AS "FMCC_ConcessionName", NULL::TEXT AS "FEC_ConcessionReason"
FROM "Fee_Student_Status" INNER JOIN "Fee_Master_Head" INNER JOIN
"Fee_Student_Concession" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Concession"."FMH_Id" INNER JOIN
"Fee_T_Installment" INNER JOIN "Fee_Student_Concession_Installments" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Concession_Installments"."FTI_Id" ON "Fee_Student_Concession"."FSC_Id" = "Fee_Student_Concession_Installments"."FSCI_FSC_Id" INNER JOIN
"Adm_M_Student" INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN
"Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" ON 
"Fee_Student_Concession"."AMST_Id" = "Adm_M_Student"."AMST_Id" ON "Fee_Student_Status"."FTI_Id" = "Fee_Student_Concession_Installments"."FTI_Id" AND 
"Fee_Student_Status"."AMST_Id" = "Fee_Student_Concession"."AMST_Id" INNER JOIN
"Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" INNER JOIN
"Fee_Master_Terms_FeeHeads" ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" AND 
"Fee_T_Installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" AND 
"Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id"
WHERE ("Fee_Student_Status"."FMG_Id" IN (' || "groupids" || ')) AND ("Fee_Student_Status"."MI_Id" = ' || "mid" || ') AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ayamYear" || ') AND ("Fee_Student_Status"."ASMAY_Id" = ' || "ayamYear" || ') and ("Fee_Student_Concession"."ASMAY_Id" = ' || "ayamYear" || ') AND
("Fee_Student_Status"."FSS_ConcessionAmount" > 0) and ("Fee_Master_Terms_FeeHeads"."fmt_id" in (' || "termids" || ')) and ("Adm_M_Student"."AMST_Concession_Type"=' || "concessiontype" || ')
GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", 
"Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Adm_M_Student"."AMST_AdmNo", 
"Fee_Master_Group"."FMG_GroupName", "Fee_Master_Head"."FMH_FeeName", "Fee_Student_Concession"."FSC_ConcessionReason"
ORDER BY "Class", "Section"';
                                RAISE NOTICE '%', "query";
                            END;
                        END IF;
                    END;
                ELSE
                    BEGIN
                        IF "concessiontype" = '0' THEN
                            BEGIN
                                "query" := 'SELECT DISTINCT COALESCE("Adm_M_Student"."AMST_FirstName", '''') ||'' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') 
|| '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''') AS "StudentName", "Adm_M_Student"."AMST_AdmNo" AS "Admno", 
"Adm_School_M_Class"."ASMCL_ClassName" AS "Class", "Adm_School_M_Section"."ASMC_SectionName" AS "Section", 
"Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("Fee_Student_Status"."FSS_NetAmount") 
AS "Netamount", SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "Concession", "Fee_Student_Concession"."FSC_ConcessionReason", NULL::NUMERIC AS "Balance", NULL::TEXT AS "Paid", NULL::TEXT AS "FMCC_ConcessionName", NULL::TEXT AS "FEC_ConcessionReason"
FROM "Fee_Student_Status" INNER JOIN "Fee_Master_Head" INNER JOIN
"Fee_Student_Concession" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Concession"."FMH_Id" INNER JOIN
"Fee_T_Installment" INNER JOIN "Fee_Student_Concession_Installments" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Concession_Installments"."FTI_Id" ON "Fee_Student_Concession"."FSC_Id" = "Fee_Student_Concession_Installments"."FSCI_FSC_Id" INNER JOIN
"Adm_M_Student" INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN
"Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" ON 
"Fee_Student_Concession"."AMST_Id" = "Adm_M_Student"."AMST_Id" ON "Fee_Student_Status"."FTI_Id" = "Fee_Student_Concession_Installments"."FTI_Id" AND 
"Fee_Student_Status"."AMST_Id" = "Fee_Student_Concession"."AMST_Id" INNER JOIN
"Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" INNER JOIN
"Fee_Master_Terms_FeeHeads" ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" AND 
"Fee_T_Installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" AND 
"Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id"
WHERE ("Fee_Student_Status"."FMG_Id" IN (' || "groupids" || ')) AND ("Fee_Student_Status"."MI_Id" = ' || "mid" || ') AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ayamYear" || ') AND ("Fee_Student_Status"."ASMAY_Id" = ' || "ayamYear" || ') and ("Fee_Student_Concession"."ASMAY_Id" = ' || "ayamYear" || ') AND
("Fee_Student_Status"."FSS_ConcessionAmount" > 0) and ("Adm_M_Student"."AMST_Concession_Type" IN (SELECT "FMCC_ID" FROM "Fee_Master_Concession" WHERE "MI_Id"=' || "mid" || '))
GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", 
"Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Adm_M_Student"."AMST_AdmNo", 
"Fee_Master_Group"."FMG_GroupName", "Fee_Master_Head"."FMH_FeeName", "Fee_Student_Concession"."FSC_ConcessionReason"
ORDER BY "Class", "Section"';
                            END;
                        ELSE
                            BEGIN
                                "query" := 'SELECT DISTINCT COALESCE("Adm_M_Student"."AMST_FirstName", '''') ||'' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') 
|| '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''') AS "StudentName", "Adm_M_Student"."AMST_AdmNo" AS "Admno", 
"Adm_School_M_Class"."ASMCL_ClassName" AS "Class", "Adm_School_M_Section"."ASMC_SectionName" AS "Section", 
"Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("Fee_Student_Status"."FSS_NetAmount") 
AS "Netamount", SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "Concession", "Fee_Student_Concession"."FSC_ConcessionReason", NULL::NUMERIC AS "Balance", NULL::TEXT AS "Paid", NULL::TEXT AS "FMCC_ConcessionName", NULL::TEXT AS "FEC_ConcessionReason"
FROM "Fee_Student_Status" INNER JOIN "Fee_Master_Head" INNER JOIN
"Fee_Student_Concession" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Concession"."FMH_Id" INNER JOIN
"Fee_T_Installment" INNER JOIN "Fee_Student_Concession_Installments" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Concession_Installments"."FTI_Id" ON "Fee_Student_Concession"."FSC_Id" = "Fee_Student_Concession_Installments"."FSCI_FSC_Id" INNER JOIN
"Adm_M_Student" INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN
"Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" ON 
"Fee_Student_Concession"."AMST_Id" = "Adm_M_Student"."AMST_Id" ON "Fee_Student_Status"."FTI_Id" = "Fee_Student_Concession_Installments"."FTI_Id" AND 
"Fee_Student_Status"."AMST_Id" = "Fee_Student_Concession"."AMST_Id" INNER JOIN
"Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" INNER JOIN
"Fee_Master_Terms_FeeHeads" ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" AND 
"Fee_T_Installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" AND 
"Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id"
WHERE ("Fee_Student_Status"."FMG_Id" IN (' || "groupids" || ')) AND ("Fee_Student_Status"."MI_Id" = ' || "mid" || ') AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ayamYear" || ') AND ("Fee_Student_Status"."ASMAY_Id" = ' || "ayamYear" || ') and ("Fee_Student_Concession"."ASMAY_Id" = ' || "ayamYear" || ') AND
("Fee_Student_Status"."FSS_ConcessionAmount" > 0) and ("Adm_M_Student"."AMST_Concession_Type"=' || "concessiontype" || ')
GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", 
"Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Adm_M_Student"."AMST_AdmNo", 
"Fee_Master_Group"."FMG_GroupName", "Fee_Master_Head"."FMH_FeeName", "Fee_Student_Concession"."FSC_ConcessionReason"
ORDER BY "Class", "Section"';
                            END;
                        END IF;
                    END;
                END IF;
            ELSIF "conditionFlag" = 'Indi' THEN
                IF "type" = 'T' THEN
                    BEGIN
                        IF "concessiontype" = '0' THEN
                            BEGIN
                                "query" := 'SELECT DISTINCT COALESCE("Adm_M_Student"."AMST_FirstName", '''') ||'' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') 
|| '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''') AS "StudentName" , "Adm_M_Student"."AMST_AdmNo" AS "Admno", 
"Adm_School_M_Class"."ASMCL_ClassName" AS "Class", "Adm_School_M_Section"."ASMC_SectionName" AS "Section", 
"Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("Fee_Student_Status"."FSS_NetAmount") 
AS "Netamount", SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "Concession", "Fee_Student_Concession"."FSC_ConcessionReason", NULL::NUMERIC AS "Balance", NULL::TEXT AS "Paid", NULL::TEXT AS "FMCC_ConcessionName", NULL::TEXT AS "FEC_ConcessionReason"
FROM "Fee_Student_Status" INNER JOIN "Fee_Master_Head" INNER JOIN
"Fee_Student_Concession" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Concession"."FMH_Id" INNER JOIN
"Fee_T_Installment" INNER JOIN "Fee_Student_Concession_Installments" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Concession_Installments"."FTI_Id" ON "Fee_Student_Concession"."FSC_Id" = "Fee_Student_Concession_Installments"."FSCI_FSC_Id" INNER JOIN
"Adm_M_Student" INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN
"Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS_Id" ON 
"Fee_Student_Concession"."AMST_Id" = "Adm_M_Student"."AMST_Id" ON "Fee_Student_Status"."FTI_Id" = "Fee_Student_Concession_Installments"."FTI_Id" AND 
"Fee_Student_Status"."AMST_Id" = "Fee_Student_Concession"."AMST_Id" INNER JOIN
"Fee_Master_Group" ON "Fee_Master_Group"."FMG_Id" = "Fee_Student_Status"."FMG_Id" INNER JOIN
"Fee_Master_Terms_FeeHeads" ON "Fee_Master_Head"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id" AND 
"Fee_T_Installment"."FTI_Id" = "Fee_Master_Terms_FeeHeads"."FTI_Id" AND 
"Fee_Student_Status"."FMH_Id" = "Fee_Master_Terms_FeeHeads"."FMH_Id"
WHERE ("Fee_Student_Status"."FMG_Id" IN (' || "groupids" || ')) AND ("Fee_Student_Status"."MI_Id" = ' || "mid" || ') AND ("Adm_School_Y_Student"."ASMAY_Id" = ' || "ayamYear" || ') AND ("Fee_Student_Status"."ASMAY_Id" = ' || "ayamYear" || ') and ("Fee_Student_Concession"."ASMAY_Id" = ' || "ayamYear" || ') AND
("Fee_Student_Status"."FSS_ConcessionAmount" > 0) ' || "str1" || ' and ("Fee_Master_Terms_FeeHeads"."fmt_id" in (' || "termids" || '))
and ("Adm_M_Student"."AMST_Concession_Type" IN (SELECT "FMCC_ID" FROM "Fee_Master_Concession" WHERE "MI_Id"=' || "mid" || '))
GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", 
"Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Adm_M_Student"."AMST_AdmNo", 
"Fee_Master_Group"."FMG_GroupName", "Fee_Master_Head"."FMH_FeeName", "Fee_Student_Concession"."FSC_ConcessionReason"
ORDER BY "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName"';
                            END;
                        ELSE
                            BEGIN
                                "query" := 'SELECT DISTINCT COALESCE("Adm_M_Student"."AMST_FirstName", '''') ||'' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') 
|| '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''') AS "StudentName" , "Adm_M_Student"."AMST_AdmNo" AS "Admno", 
"Adm_School_M_Class"."ASMCL_ClassName" AS "Class", "Adm_School_M_Section"."ASMC_SectionName" AS "Section", 
"Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("Fee_Student_Status"."FSS_NetAmount") 
AS "Netamount", SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "Concession", "Fee_Student_Concession"."FSC_ConcessionReason", NULL::NUMERIC AS "Balance", NULL::TEXT AS "Paid", NULL::TEXT AS "FMCC_ConcessionName", NULL::TEXT AS "FEC_ConcessionReason"
FROM "Fee_Student_Status" INNER JOIN "Fee_Master_Head" INNER JOIN
"Fee_Student_Concession" ON "Fee_Master_Head"."FMH_Id" = "Fee_Student_Concession"."FMH_Id" INNER JOIN
"Fee_T_Installment" INNER JOIN "Fee_Student_Concession_Installments" ON "Fee_T_Installment"."FTI_Id" = "Fee_Student_Concession_Installments"."FTI_Id" ON "Fee_Student_Concession"."FSC_Id" = "Fee_Student_Concession_Installments"."FSCI_FSC_Id" INNER JOIN
"Adm_M_Student" INNER JOIN "Adm_School_Y_Student" ON "Adm_M_Student"."AMST_Id" = "Adm_School_Y_Student"."AMST_Id" INNER JOIN
"Adm_School_M_Class" ON "Adm_School_Y_Student"."ASMCL_Id" = "Adm_School_M_Class"."ASMCL_Id" INNER JOIN
"Adm_School_M_Section" ON "Adm_School_Y_Student"."ASMS_Id" = "Adm_School_M_Section"."ASMS