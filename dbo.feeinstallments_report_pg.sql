CREATE OR REPLACE FUNCTION "dbo"."feeinstallments_report" (
    "ASMAY_ID" VARCHAR(100),
    "amc_id" VARCHAR(100),
    "FTI_id" TEXT,
    "amscl_id" VARCHAR(100),
    "amsc_id" VARCHAR(100),
    "type" TEXT,
    "groupid" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "amst_id" VARCHAR(100);
    "fti_loop" TEXT;
    "amst_name" TEXT;
    "amst_class" TEXT;
    "amst_section" TEXT;
    "fti_id_new" TEXT;
    "monthyearsd" TEXT;
    "monthids1" TEXT;
    "cols" TEXT;
    "temp" BIGINT;
    "waivedoff" TEXT;
    "netamount" TEXT;
    "paidamount" TEXT;
    "balance" TEXT;
    "concession" TEXT;
    "fine" TEXT;
    "waive" TEXT;
    "paid" TEXT;
    "blc" TEXT;
    "net" TEXT;
    "con" TEXT;
    "fn" TEXT;
    "sqlText" VARCHAR(500);
    "getclname" VARCHAR(500);
    "clmnset" TEXT;
    "temp1" BIGINT;
    "alter" BIGINT;
    "dyncolumn" TEXT;
    "dyn" BIGINT;
    "dyncol" TEXT;
    "query" TEXT;
    "ids" BIGINT;
    "sql" TEXT;
    "sql4" TEXT;
    "inst_id" TEXT;
    "sql1" TEXT;
    "sql3" TEXT;
    "rec_student" RECORD;
    "rec_installment" RECORD;
    "rec_column" RECORD;
BEGIN
    "temp" := 0;
    "waive" := 'waivedoff';
    "paid" := 'paid';
    "blc" := 'balance';
    "net" := 'netamount';
    "con" := 'concession';
    "fn" := 'fine';
    "alter" := 0;
    "dyn" := 0;
    "ids" := 0;

    "fti_id_new" := '';
    
    FOR "rec_column" IN 
        SELECT "FTI_Id" FROM "dbo"."Fee_T_Installment" 
        WHERE "FTI_Id" IN (SELECT DISTINCT "FTI_Id" FROM "dbo"."Fee_Student_Status" WHERE "asmay_id" = "ASMAY_ID")
    LOOP
        IF "ids" = 0 THEN
            "fti_id_new" := "rec_column"."FTI_Id"::TEXT;
            "ids" := "ids" + 1;
        ELSE
            "fti_id_new" := "fti_id_new" || ',' || "rec_column"."FTI_Id"::TEXT;
        END IF;
    END LOOP;

    IF "type" = 'Class' THEN
        FOR "rec_student" IN
            SELECT DISTINCT "dbo"."Adm_M_Student"."AMST_FirstName" || ' ' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '') || ' ' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '') AS "Name", 
                   "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", "dbo"."Adm_M_Student"."AMST_Id" 
            FROM "dbo"."Adm_M_Category" 
            INNER JOIN "dbo"."Adm_School_M_Class_Category" ON "dbo"."Adm_M_Category"."AMC_Id" = "dbo"."Adm_School_M_Class_Category"."AMC_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class_Category"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id" 
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
            WHERE "dbo"."Adm_M_Student"."AMST_SOL" = 'S'
        LOOP
            "amst_name" := "rec_student"."Name";
            "amst_class" := "rec_student"."ASMCL_ClassName";
            "amst_section" := "rec_student"."ASMC_SectionName";
            "amst_id" := "rec_student"."AMST_Id"::TEXT;
            
            "temp" := 0;
            
            FOR "rec_installment" IN EXECUTE
                'SELECT "Amst_Id", "fti_id", SUM("FSS_NetAmount") as netamount, SUM("FSS_PaidAmount") as paidamount, 
                        SUM("FSS_ToBePaid") as balance, SUM("FSS_ConcessionAmount") as concession, 
                        SUM("FSS_FineAmount") as fine, SUM("FSS_WaivedAmount") as waivedoff  
                 FROM "dbo"."fee_student_status" 
                 WHERE "Amst_Id" = ' || "amst_id" || ' AND "fti_Id" IN (' || "fti_id_new" || ') 
                 GROUP BY "Amst_Id", "fti_id"'
            LOOP
                "netamount" := "rec_installment"."netamount"::TEXT;
                "paidamount" := "rec_installment"."paidamount"::TEXT;
                "balance" := "rec_installment"."balance"::TEXT;
                "concession" := "rec_installment"."concession"::TEXT;
                "fine" := "rec_installment"."fine"::TEXT;
                "waivedoff" := "rec_installment"."waivedoff"::TEXT;
                
                IF "temp" = 0 THEN
                    IF "temp1" > 0 THEN
                        "temp1" := 1;
                    ELSE
                        "temp1" := 0;
                    END IF;
                    
                    IF "temp1" = 0 THEN
                        DROP TABLE IF EXISTS "temp_installment";
                        CREATE TABLE "temp_installment"(
                            "amst_id" BIGINT NULL, 
                            "netamount" TEXT NULL,
                            "paidamount" TEXT NULL,
                            "balance" TEXT NULL,
                            "concession" TEXT NULL,
                            "fine" TEXT NULL,
                            "waivedoff" TEXT NULL
                        );
                        "temp1" := "temp1" + 1;
                        "alter" := 1;
                    END IF;
                    
                    EXECUTE 'INSERT INTO "temp_installment"("amst_id","netamount","paidamount","balance","concession","fine","waivedoff") 
                             VALUES (' || "amst_id" || ',' || quote_literal("netamount") || ',' || quote_literal("paidamount") || ',' || 
                             quote_literal("balance") || ',' || quote_literal("concession") || ',' || quote_literal("fine") || ',' || 
                             quote_literal("waivedoff") || ')';
                    "temp" := "temp" + 1;
                ELSIF "temp" > 0 THEN
                    "waive" := "waive" || "temp"::VARCHAR;
                    "paid" := "paid" || "temp"::VARCHAR;
                    "blc" := "blc" || "temp"::VARCHAR;
                    "net" := "net" || "temp"::VARCHAR;
                    "fn" := "fn" || "temp"::VARCHAR;
                    "con" := "con" || "temp"::VARCHAR;
                    
                    IF "alter" = 1 THEN
                        "sqlText" := 'ALTER TABLE "temp_installment" ADD "' || "net" || '" VARCHAR(50), 
                                      ADD "' || "paid" || '" VARCHAR(50), ADD "' || "blc" || '" VARCHAR(50), 
                                      ADD "' || "con" || '" VARCHAR(50), ADD "' || "fn" || '" VARCHAR(50), 
                                      ADD "' || "waive" || '" VARCHAR(50)';
                        EXECUTE "sqlText";
                    END IF;
                    
                    FOR "rec_column" IN 
                        SELECT "column_name" FROM "information_schema"."columns" 
                        WHERE "table_name" = 'temp_installment' 
                        AND "column_name" IN ("waive", "paid", "blc", "net", "con", "fn") 
                        ORDER BY "ordinal_position" DESC LIMIT 6
                    LOOP
                        "getclname" := "rec_column"."column_name";
                        
                        IF "getclname" = "net" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "netamount" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        ELSIF "getclname" = "paid" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "paidamount" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        ELSIF "getclname" = "blc" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "balance" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        ELSIF "getclname" = "con" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "concession" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        ELSIF "getclname" = "fn" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "fine" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        ELSIF "getclname" = "waive" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "waivedoff" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        END IF;
                    END LOOP;
                    
                    "temp" := "temp" + 1;
                END IF;
            END LOOP;
            
            "waive" := 'waivedoff';
            "paid" := 'paid';
            "blc" := 'balance';
            "net" := 'netamount';
            "con" := 'concession';
            "fn" := 'fine';
            "alter" := 0;
        END LOOP;
    ELSIF "type" = 'Category' THEN
        FOR "rec_student" IN
            SELECT DISTINCT "dbo"."Adm_M_Student"."AMST_FirstName" || ' ' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '') || ' ' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '') AS "Name", 
                   "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", "dbo"."Adm_M_Student"."AMST_Id"
            FROM "dbo"."Adm_School_Y_Student" 
            INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_Y_Student"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "dbo"."Adm_School_M_Class_Category" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_M_Class_Category"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_M_Category" ON "dbo"."Adm_School_M_Class_Category"."AMC_Id" = "dbo"."Adm_M_Category"."AMC_Id"
            WHERE "dbo"."Adm_M_Student"."ASMAY_Id" = "ASMAY_ID" AND "dbo"."Adm_M_Category"."AMC_Id" = "amc_id" 
            AND "dbo"."Adm_M_Student"."AMST_SOL" = 'S'
            GROUP BY "dbo"."Adm_M_Student"."AMST_FirstName", "dbo"."Adm_M_Student"."AMST_MiddleName", "dbo"."Adm_M_Student"."AMST_LastName", 
                     "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", 
                     "dbo"."Adm_School_Y_Student"."ASMCL_Id", "dbo"."Adm_M_Student"."ASMAY_Id", "dbo"."Adm_M_Student"."AMST_Id", "dbo"."Adm_M_Student"."AMST_SOL"
        LOOP
            "amst_name" := "rec_student"."Name";
            "amst_class" := "rec_student"."ASMCL_ClassName";
            "amst_section" := "rec_student"."ASMC_SectionName";
            "amst_id" := "rec_student"."AMST_Id"::TEXT;
            
            "temp" := 0;
            "fti_loop" := "FTI_id";
            
            FOR "rec_installment" IN EXECUTE
                'SELECT "Amst_Id", "fti_id", SUM("FSS_NetAmount") as netamount, SUM("FSS_PaidAmount") as paidamount, 
                        SUM("FSS_ToBePaid") as balance, SUM("FSS_ConcessionAmount") as concession, 
                        SUM("FSS_FineAmount") as fine, SUM("FSS_WaivedAmount") as waivedoff  
                 FROM "dbo"."fee_student_status" 
                 WHERE "Amst_Id" = ' || "amst_id" || ' AND "fti_Id" IN (' || "fti_loop" || ') 
                 GROUP BY "Amst_Id", "fti_id"'
            LOOP
                "netamount" := "rec_installment"."netamount"::TEXT;
                "paidamount" := "rec_installment"."paidamount"::TEXT;
                "balance" := "rec_installment"."balance"::TEXT;
                "concession" := "rec_installment"."concession"::TEXT;
                "fine" := "rec_installment"."fine"::TEXT;
                "waivedoff" := "rec_installment"."waivedoff"::TEXT;
                
                IF "temp" = 0 THEN
                    IF "temp1" > 0 THEN
                        "temp1" := 1;
                    ELSE
                        "temp1" := 0;
                    END IF;
                    
                    IF "temp1" = 0 THEN
                        DROP TABLE IF EXISTS "temp_installment";
                        CREATE TABLE "temp_installment"(
                            "amst_id" BIGINT NULL, 
                            "netamount" TEXT NULL,
                            "paidamount" TEXT NULL,
                            "balance" TEXT NULL,
                            "concession" TEXT NULL,
                            "fine" TEXT NULL,
                            "waivedoff" TEXT NULL
                        );
                        "temp1" := "temp1" + 1;
                        "alter" := 1;
                    END IF;
                    
                    EXECUTE 'INSERT INTO "temp_installment"("amst_id","netamount","paidamount","balance","concession","fine","waivedoff") 
                             VALUES (' || "amst_id" || ',' || quote_literal("netamount") || ',' || quote_literal("paidamount") || ',' || 
                             quote_literal("balance") || ',' || quote_literal("concession") || ',' || quote_literal("fine") || ',' || 
                             quote_literal("waivedoff") || ')';
                    "temp" := "temp" + 1;
                ELSIF "temp" > 0 THEN
                    "waive" := "waive" || "temp"::VARCHAR;
                    "paid" := "paid" || "temp"::VARCHAR;
                    "blc" := "blc" || "temp"::VARCHAR;
                    "net" := "net" || "temp"::VARCHAR;
                    "fn" := "fn" || "temp"::VARCHAR;
                    "con" := "con" || "temp"::VARCHAR;
                    
                    IF "alter" = 1 THEN
                        "sqlText" := 'ALTER TABLE "temp_installment" ADD "' || "net" || '" VARCHAR(50), 
                                      ADD "' || "paid" || '" VARCHAR(50), ADD "' || "blc" || '" VARCHAR(50), 
                                      ADD "' || "con" || '" VARCHAR(50), ADD "' || "fn" || '" VARCHAR(50), 
                                      ADD "' || "waive" || '" VARCHAR(50)';
                        EXECUTE "sqlText";
                    END IF;
                    
                    FOR "rec_column" IN 
                        SELECT "column_name" FROM "information_schema"."columns" 
                        WHERE "table_name" = 'temp_installment' 
                        AND "column_name" IN ("waive", "paid", "blc", "net", "con", "fn") 
                        ORDER BY "ordinal_position" DESC LIMIT 6
                    LOOP
                        "getclname" := "rec_column"."column_name";
                        
                        IF "getclname" = "net" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "netamount" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        ELSIF "getclname" = "paid" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "paidamount" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        ELSIF "getclname" = "blc" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "balance" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        ELSIF "getclname" = "con" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "concession" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        ELSIF "getclname" = "fn" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "fine" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        ELSIF "getclname" = "waive" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "waivedoff" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        END IF;
                    END LOOP;
                    
                    "temp" := "temp" + 1;
                END IF;
            END LOOP;
            
            "waive" := 'waivedoff';
            "paid" := 'paid';
            "blc" := 'balance';
            "net" := 'netamount';
            "con" := 'concession';
            "fn" := 'fine';
            "alter" := 0;
        END LOOP;
    ELSE
        FOR "rec_student" IN
            SELECT DISTINCT "dbo"."Adm_M_Student"."AMST_FirstName" || ' ' || COALESCE("dbo"."Adm_M_Student"."AMST_MiddleName", '') || ' ' || COALESCE("dbo"."Adm_M_Student"."AMST_LastName", '') AS "Name", 
                   "dbo"."Adm_School_M_Class"."ASMCL_ClassName", "dbo"."Adm_School_M_Section"."ASMC_SectionName", "dbo"."Adm_M_Student"."AMST_Id"
            FROM "dbo"."Adm_M_Category" 
            INNER JOIN "dbo"."Adm_School_M_Class_Category" ON "dbo"."Adm_M_Category"."AMC_Id" = "dbo"."Adm_School_M_Class_Category"."AMC_Id"
            INNER JOIN "dbo"."Adm_School_M_Class" ON "dbo"."Adm_School_M_Class_Category"."ASMCL_Id" = "dbo"."Adm_School_M_Class"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_School_Y_Student" ON "dbo"."Adm_School_M_Class"."ASMCL_Id" = "dbo"."Adm_School_Y_Student"."ASMCL_Id"
            INNER JOIN "dbo"."Adm_M_Student" ON "dbo"."Adm_School_Y_Student"."AMST_Id" = "dbo"."Adm_M_Student"."AMST_Id"
            INNER JOIN "dbo"."Adm_School_M_Section" ON "dbo"."Adm_School_Y_Student"."ASMS_Id" = "dbo"."Adm_School_M_Section"."ASMS_Id"
            INNER JOIN "dbo"."Fee_Master_Student_Group" ON "dbo"."Adm_M_Student"."AMST_Id" = "dbo"."Fee_Master_Student_Group"."AMST_Id"
            WHERE "dbo"."Adm_M_Student"."AMST_SOL" = 'S' 
            AND "dbo"."Fee_Master_Student_Group"."FMG_Id" = "groupid" 
            AND "dbo"."Adm_M_Student"."ASMAY_Id" = "ASMAY_ID"
        LOOP
            "amst_name" := "rec_student"."Name";
            "amst_class" := "rec_student"."ASMCL_ClassName";
            "amst_section" := "rec_student"."ASMC_SectionName";
            "amst_id" := "rec_student"."AMST_Id"::TEXT;
            
            "temp" := 0;
            "fti_loop" := "FTI_id";
            
            FOR "rec_installment" IN EXECUTE
                'SELECT "Amst_Id", "fti_id", SUM("FSS_NetAmount") as netamount, SUM("FSS_PaidAmount") as paidamount, 
                        SUM("FSS_ToBePaid") as balance, SUM("FSS_ConcessionAmount") as concession, 
                        SUM("FSS_FineAmount") as fine, SUM("FSS_WaivedAmount") as waivedoff  
                 FROM "dbo"."fee_student_status" 
                 WHERE "Amst_Id" = ' || "amst_id" || ' AND "fti_Id" IN (' || "fti_loop" || ') 
                 GROUP BY "Amst_Id", "fti_id"'
            LOOP
                "netamount" := "rec_installment"."netamount"::TEXT;
                "paidamount" := "rec_installment"."paidamount"::TEXT;
                "balance" := "rec_installment"."balance"::TEXT;
                "concession" := "rec_installment"."concession"::TEXT;
                "fine" := "rec_installment"."fine"::TEXT;
                "waivedoff" := "rec_installment"."waivedoff"::TEXT;
                
                IF "temp" = 0 THEN
                    IF "temp1" > 0 THEN
                        "temp1" := 1;
                    ELSE
                        "temp1" := 0;
                    END IF;
                    
                    IF "temp1" = 0 THEN
                        DROP TABLE IF EXISTS "temp_installment";
                        CREATE TABLE "temp_installment"(
                            "amst_id" BIGINT NULL, 
                            "netamount" TEXT NULL,
                            "paidamount" TEXT NULL,
                            "balance" TEXT NULL,
                            "concession" TEXT NULL,
                            "fine" TEXT NULL,
                            "waivedoff" TEXT NULL
                        );
                        "temp1" := "temp1" + 1;
                        "alter" := 1;
                    END IF;
                    
                    EXECUTE 'INSERT INTO "temp_installment"("amst_id","netamount","paidamount","balance","concession","fine","waivedoff") 
                             VALUES (' || "amst_id" || ',' || quote_literal("netamount") || ',' || quote_literal("paidamount") || ',' || 
                             quote_literal("balance") || ',' || quote_literal("concession") || ',' || quote_literal("fine") || ',' || 
                             quote_literal("waivedoff") || ')';
                    "temp" := "temp" + 1;
                ELSIF "temp" > 0 THEN
                    "waive" := "waive" || "temp"::VARCHAR;
                    "paid" := "paid" || "temp"::VARCHAR;
                    "blc" := "blc" || "temp"::VARCHAR;
                    "net" := "net" || "temp"::VARCHAR;
                    "fn" := "fn" || "temp"::VARCHAR;
                    "con" := "con" || "temp"::VARCHAR;
                    
                    IF "alter" = 1 THEN
                        "sqlText" := 'ALTER TABLE "temp_installment" ADD "' || "net" || '" VARCHAR(50), 
                                      ADD "' || "paid" || '" VARCHAR(50), ADD "' || "blc" || '" VARCHAR(50), 
                                      ADD "' || "con" || '" VARCHAR(50), ADD "' || "fn" || '" VARCHAR(50), 
                                      ADD "' || "waive" || '" VARCHAR(50)';
                        EXECUTE "sqlText";
                    END IF;
                    
                    FOR "rec_column" IN 
                        SELECT "column_name" FROM "information_schema"."columns" 
                        WHERE "table_name" = 'temp_installment' 
                        AND "column_name" IN ("waive", "paid", "blc", "net", "con", "fn") 
                        ORDER BY "ordinal_position" DESC LIMIT 6
                    LOOP
                        "getclname" := "rec_column"."column_name";
                        
                        IF "getclname" = "net" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "netamount" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        ELSIF "getclname" = "paid" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "paidamount" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        ELSIF "getclname" = "blc" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "balance" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        ELSIF "getclname" = "con" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "concession" || ' WHERE "amst_id" = ' || "amst_id"::TEXT;
                            EXECUTE "clmnset";
                        ELSIF "getclname" = "fn" THEN
                            "clmnset" := 'UPDATE "temp_installment" SET "' || "getclname" || '" = ' || "fine" || ' WHERE "