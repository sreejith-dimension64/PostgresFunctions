CREATE OR REPLACE FUNCTION "ADM_Student_LongAbsenteeslist_proc"(
    "MI_ID" TEXT,
    "ASMAY_ID" TEXT,
    "ASMCL_ID" TEXT,
    "ASMS_ID" TEXT,
    "FROMDATE" VARCHAR(10),
    "TODATE" VARCHAR(10),
    "NUM" INT
)
RETURNS TABLE(
    "STUDENTID" BIGINT,
    "STUDENTNAME" TEXT,
    "ADMISSION_NUMBER" TEXT,
    "MOBILENUMBER" BIGINT,
    "ASMCL_ClassName" TEXT,
    "ASMC_SectionName" TEXT,
    "ASMCL_Id" BIGINT,
    "ASMS_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "AMST_ID" BIGINT;
    "ROWCOUNT" INT;
    "TOTALROWCOUNT" INT;
    "CreatedDate" DATE;
    "DYNAMIC" TEXT;
    "ASMCL_ID1" TEXT;
    "ASMS_ID1" TEXT;
    "I" INT;
    student_rec RECORD;
BEGIN

    DROP TABLE IF EXISTS "ABSENTEESSTUDENTDATA_TEMP";
    
    CREATE TEMP TABLE "STUDENT_TEMP"(
        "STUDENTID" BIGINT,
        "STUDENTNAME" TEXT,
        "ADMISSION_NUMBER" TEXT,
        "MOBILENUMBER" BIGINT,
        "ASMCL_ClassName" TEXT,
        "ASMC_SectionName" TEXT,
        "ASMCL_Id" BIGINT,
        "ASMS_Id" BIGINT
    );

    "DYNAMIC" := '
    CREATE TEMP TABLE "ABSENTEESSTUDENTDATA_TEMP" AS
    Select DISTINCT B."AMST_Id", CAST(A."CreatedDate" AS DATE) as "CreatedDate", A."ASMCL_Id", A."ASMS_Id"
    from "Adm_Student_Attendance" A
    Inner Join "Adm_Student_Attendance_Students" B ON A."ASA_Id"=B."ASA_Id"
    Inner Join "Adm_M_Student" C ON C."AMST_Id"=B."AMST_Id"
    Inner Join "Adm_School_Y_Student" D ON D."AMST_Id"=B."AMST_Id" AND A."MI_Id"=A."MI_Id" AND D."ASMAY_Id"=A."ASMAY_Id" AND D."ASMCL_Id"=A."ASMCL_Id" 
    AND D."ASMS_Id"=A."ASMS_Id" 
    WHERE A."ASA_FromDate" between ''' || "FROMDATE" || ''' and ''' || "TODATE" || ''' and A."MI_ID"=' || "MI_ID" || ' and A."ASMAY_Id"=' || "ASMAY_ID" || ' 
    and A."ASMCL_Id" IN (' || "ASMCL_ID" || ') and A."ASMS_Id" IN (' || "ASMS_ID" || ') AND C."AMST_ActiveFlag"=1 AND C."AMST_SOL"=''S'' AND B."ASA_AttendanceFlag"=''Absent''';
    
    EXECUTE "DYNAMIC";

    FOR student_rec IN 
        SELECT "AMST_Id", "CreatedDate", "ASMCL_Id", "ASMS_Id" FROM "ABSENTEESSTUDENTDATA_TEMP"
    LOOP
        "AMST_ID" := student_rec."AMST_Id";
        "CreatedDate" := student_rec."CreatedDate";
        "ASMCL_ID1" := student_rec."ASMCL_Id"::TEXT;
        "ASMS_ID1" := student_rec."ASMS_Id"::TEXT;
        
        "I" := 0;
        "TOTALROWCOUNT" := 0;

        WHILE ("CreatedDate" <= "TODATE"::DATE AND "I" <= "NUM") LOOP
            
            SELECT COUNT(DISTINCT *) INTO "ROWCOUNT"
            from "Adm_Student_Attendance" A
            Inner Join "Adm_Student_Attendance_Students" B ON A."ASA_Id"=B."ASA_Id"
            WHERE A."ASA_FromDate"="CreatedDate" and "MI_ID"="MI_ID" and "ASMAY_Id"="ASMAY_ID" and "ASMCL_Id"="ASMCL_ID1"::BIGINT
            and "ASMS_Id"="ASMS_ID1"::BIGINT and "AMST_Id"="AMST_ID" AND "ASA_AttendanceFlag"='Absent';

            "I" := "I" + 1;
            "CreatedDate" := "CreatedDate" + INTERVAL '1 day';

            IF ("ROWCOUNT" > 0) THEN
                "TOTALROWCOUNT" := "TOTALROWCOUNT" + "ROWCOUNT";
            ELSE
                EXIT;
            END IF;

        END LOOP;

        RAISE NOTICE '% AS TOTALROWCOUNT', "TOTALROWCOUNT";
        RAISE NOTICE '% AS NUM', "NUM";

        IF ("TOTALROWCOUNT" = "NUM") THEN
            INSERT INTO "STUDENT_TEMP"
            SELECT A."AMST_ID", CONCAT(A."AMST_FirstName", ' ', A."AMST_MiddleName", ' ', A."AMST_LastName"), A."AMST_AdmNo", A."AMST_MobileNo",
            B."ASMCL_ClassName", C."ASMC_SectionName", B."ASMCL_Id", C."ASMS_Id"
            FROM "Adm_M_Student" A
            INNER JOIN "Adm_School_M_Class" B ON B."ASMCL_Id"="ASMCL_ID1"::BIGINT
            INNER JOIN "Adm_School_M_Section" C ON C."ASMS_Id"="ASMS_ID1"::BIGINT
            WHERE "AMST_Id"="AMST_ID";
        END IF;

    END LOOP;

    RETURN QUERY SELECT * FROM "STUDENT_TEMP";
    
    DROP TABLE IF EXISTS "STUDENT_TEMP";
    DROP TABLE IF EXISTS "ABSENTEESSTUDENTDATA_TEMP";

END;
$$;