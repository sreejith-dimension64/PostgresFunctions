CREATE OR REPLACE FUNCTION "dbo"."Fee_Student_Concession_Report_new"(
    "p_mid" TEXT,
    "p_ayamYear" TEXT,
    "p_groupids" TEXT,
    "p_termids" TEXT,
    "p_class" TEXT,
    "p_section" TEXT,
    "p_conditionFlag" VARCHAR(100),
    "p_type" TEXT,
    "p_concessiontype" TEXT,
    "p_report" TEXT
)
RETURNS VOID AS $$
DECLARE
    "v_query" TEXT;
    "v_str1" TEXT;
BEGIN

    IF "p_report" = 'Student' THEN
        
        IF "p_section" = '0' THEN
            "v_str1" := 'AND ("Adm_School_M_Class"."ASMCL_Id" IN (' || "p_class" || '))';
        ELSE
            "v_str1" := 'AND ("Adm_School_M_Class"."ASMCL_Id" IN (' || "p_class" || ')) AND ("Adm_School_M_Section"."ASMS_Id" IN (' || "p_section" || '))';
        END IF;

        IF "p_conditionFlag" = 'allr' THEN
            
            IF "p_type" = 'T' THEN
                
                IF "p_concessiontype" = '0' THEN
                    "v_query" := 'SELECT DISTINCT COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') 
                    || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''') AS "StudentName", "Adm_M_Student"."AMST_AdmNo" AS "Admno", 
                    "Adm_School_M_Class"."ASMCL_ClassName" AS "Class", "Adm_School_M_Section"."ASMC_SectionName" AS "Section", 
                    "Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("Fee_Student_Status"."FSS_NetAmount") 
                    AS "Netamount", SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "Concession", "Fee_Student_Concession"."FSC_ConcessionReason"
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
                    WHERE ("Fee_Student_Status"."FMG_Id" IN (' || "p_groupids" || ')) AND ("Fee_Student_Status"."MI_Id" IN (' || "p_mid" || ')) AND ("Adm_School_Y_Student"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND ("Fee_Student_Status"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND ("Fee_Student_Concession"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND
                    ("Fee_Student_Status"."FSS_ConcessionAmount" > 0) AND ("Fee_Master_Terms_FeeHeads"."fmt_id" IN (' || "p_termids" || '))
                    GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", 
                    "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Adm_M_Student"."AMST_AdmNo", 
                    "Fee_Master_Group"."FMG_GroupName", "Fee_Master_Head"."FMH_FeeName", "Fee_Student_Concession"."FSC_ConcessionReason"
                    ORDER BY "Class", "Section"';
                ELSE
                    "v_query" := 'SELECT DISTINCT COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') 
                    || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''') AS "StudentName", "Adm_M_Student"."AMST_AdmNo" AS "Admno", 
                    "Adm_School_M_Class"."ASMCL_ClassName" AS "Class", "Adm_School_M_Section"."ASMC_SectionName" AS "Section", 
                    "Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("Fee_Student_Status"."FSS_NetAmount") 
                    AS "Netamount", SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "Concession", "Fee_Student_Concession"."FSC_ConcessionReason"
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
                    WHERE ("Fee_Student_Status"."FMG_Id" IN (' || "p_groupids" || ')) AND ("Fee_Student_Status"."MI_Id" IN (' || "p_mid" || ')) AND ("Adm_School_Y_Student"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND ("Fee_Student_Status"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND ("Fee_Student_Concession"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND
                    ("Fee_Student_Status"."FSS_ConcessionAmount" > 0) AND ("Fee_Master_Terms_FeeHeads"."fmt_id" IN (' || "p_termids" || ')) AND ("Adm_M_Student"."AMST_Concession_Type" IN (' || "p_concessiontype" || '))
                    GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", 
                    "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Adm_M_Student"."AMST_AdmNo", 
                    "Fee_Master_Group"."FMG_GroupName", "Fee_Master_Head"."FMH_FeeName", "Fee_Student_Concession"."FSC_ConcessionReason"
                    ORDER BY "Class", "Section"';
                END IF;
            ELSE
                IF "p_concessiontype" = '0' THEN
                    "v_query" := 'SELECT DISTINCT COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') 
                    || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''') AS "StudentName", "Adm_M_Student"."AMST_AdmNo" AS "Admno", 
                    "Adm_School_M_Class"."ASMCL_ClassName" AS "Class", "Adm_School_M_Section"."ASMC_SectionName" AS "Section", 
                    "Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("Fee_Student_Status"."FSS_NetAmount") 
                    AS "Netamount", SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "Concession", "Fee_Student_Concession"."FSC_ConcessionReason"
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
                    WHERE ("Fee_Student_Status"."FMG_Id" IN (' || "p_groupids" || ')) AND ("Fee_Student_Status"."MI_Id" IN (' || "p_mid" || ')) AND ("Adm_School_Y_Student"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND ("Fee_Student_Status"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND ("Fee_Student_Concession"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND
                    ("Fee_Student_Status"."FSS_ConcessionAmount" > 0) 
                    GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", 
                    "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Adm_M_Student"."AMST_AdmNo", 
                    "Fee_Master_Group"."FMG_GroupName", "Fee_Master_Head"."FMH_FeeName", "Fee_Student_Concession"."FSC_ConcessionReason"
                    ORDER BY "Class", "Section"';
                ELSE
                    "v_query" := 'SELECT DISTINCT COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') 
                    || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''') AS "StudentName", "Adm_M_Student"."AMST_AdmNo" AS "Admno", 
                    "Adm_School_M_Class"."ASMCL_ClassName" AS "Class", "Adm_School_M_Section"."ASMC_SectionName" AS "Section", 
                    "Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("Fee_Student_Status"."FSS_NetAmount") 
                    AS "Netamount", SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "Concession", "Fee_Student_Concession"."FSC_ConcessionReason"
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
                    WHERE ("Fee_Student_Status"."FMG_Id" IN (' || "p_groupids" || ')) AND ("Fee_Student_Status"."MI_Id" IN (' || "p_mid" || ')) AND ("Adm_School_Y_Student"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND ("Fee_Student_Status"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND ("Fee_Student_Concession"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND
                    ("Fee_Student_Status"."FSS_ConcessionAmount" > 0) AND ("Adm_M_Student"."AMST_Concession_Type" IN (' || "p_concessiontype" || '))
                    GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", 
                    "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Adm_M_Student"."AMST_AdmNo", 
                    "Fee_Master_Group"."FMG_GroupName", "Fee_Master_Head"."FMH_FeeName", "Fee_Student_Concession"."FSC_ConcessionReason"
                    ORDER BY "Class", "Section"';
                END IF;
            END IF;

        ELSIF "p_conditionFlag" = 'Indi' THEN
            
            IF "p_type" = 'T' THEN
                
                IF "p_concessiontype" = '0' THEN
                    "v_query" := 'SELECT DISTINCT COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') 
                    || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''') AS "StudentName", "Adm_M_Student"."AMST_AdmNo" AS "Admno", 
                    "Adm_School_M_Class"."ASMCL_ClassName" AS "Class", "Adm_School_M_Section"."ASMC_SectionName" AS "Section", 
                    "Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("Fee_Student_Status"."FSS_NetAmount") 
                    AS "Netamount", SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "Concession", "Fee_Student_Concession"."FSC_ConcessionReason"
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
                    WHERE ("Fee_Student_Status"."FMG_Id" IN (' || "p_groupids" || ')) AND ("Fee_Student_Status"."MI_Id" IN (' || "p_mid" || ')) AND ("Adm_School_Y_Student"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND ("Fee_Student_Status"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND ("Fee_Student_Concession"."ASMAY_Id" IN (' || "p_ayamYear" || ')) AND
                    ("Fee_Student_Status"."FSS_ConcessionAmount" > 0) ' || "v_str1" || ' AND ("Fee_Master_Terms_FeeHeads"."fmt_id" IN (' || "p_termids" || '))
                    GROUP BY "Adm_M_Student"."AMST_FirstName", "Adm_M_Student"."AMST_MiddleName", "Adm_M_Student"."AMST_LastName", 
                    "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName", "Adm_M_Student"."AMST_AdmNo", 
                    "Fee_Master_Group"."FMG_GroupName", "Fee_Master_Head"."FMH_FeeName", "Fee_Student_Concession"."FSC_ConcessionReason"
                    ORDER BY "Adm_School_M_Class"."ASMCL_ClassName", "Adm_School_M_Section"."ASMC_SectionName"';
                ELSE
                    "v_query" := 'SELECT DISTINCT COALESCE("Adm_M_Student"."AMST_FirstName", '''') || '' '' || COALESCE("Adm_M_Student"."AMST_MiddleName", '''') 
                    || '' '' || COALESCE("Adm_M_Student"."AMST_LastName", '''') AS "StudentName", "Adm_M_Student"."AMST_AdmNo" AS "Admno", 
                    "Adm_School_M_Class"."ASMCL_ClassName" AS "Class", "Adm_School_M_Section"."ASMC_SectionName" AS "Section", 
                    "Fee_Master_Group"."FMG_GroupName" AS "FeeGroup", "Fee_Master_Head"."FMH_FeeName" AS "FeeHead", SUM("Fee_Student_Status"."FSS_NetAmount") 
                    AS "Netamount", SUM("Fee_Student_Status"."FSS_ConcessionAmount") AS "Concession", "Fee_Student_Concession"."FSC_ConcessionReason"
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
                    WHERE ("Fee_Student_Status"."FMG_Id" IN (' || "p_groupids" || ')) AND ("Fee_Student_Status"."MI_Id" IN (' || "p_mid" || ')) AND ("Adm_School_Y_Student