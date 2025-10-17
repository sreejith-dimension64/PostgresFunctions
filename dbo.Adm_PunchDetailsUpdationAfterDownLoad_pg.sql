CREATE OR REPLACE FUNCTION "dbo"."Adm_PunchDetailsUpdationAfterDownLoad"(
    "p_MI_Id" bigint,
    "p_FromDate" date,
    "p_ToDate" date
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Rno" int;
    "v_ASPU_Id" bigint;
    "v_AMST_Id" bigint;
    "v_ASPU_PunchDate" date;
    "v_ASPUD_Id" bigint;
    "v_ASPU_Id_PD" bigint;
    "v_ASPUD_PunchTime" varchar(50);
    "rec_StudentWisePunchDates" RECORD;
    "rec_StudentDateWisePunchDateDails" RECORD;
BEGIN
    "v_Rno" := 0;

    FOR "rec_StudentWisePunchDates" IN
        SELECT "ASPU_Id", "AMST_Id", CAST("ASPU_PunchDate" AS date) AS "ASPU_PunchDate"
        FROM "Adm_Student_Punch"
        WHERE "MI_Id" = "p_MI_Id" 
            AND CAST("ASPU_PunchDate" AS date) BETWEEN "p_FromDate" AND "p_ToDate"
        ORDER BY "AMST_Id", "ASPU_PunchDate"
    LOOP
        "v_ASPU_Id" := "rec_StudentWisePunchDates"."ASPU_Id";
        "v_AMST_Id" := "rec_StudentWisePunchDates"."AMST_Id";
        "v_ASPU_PunchDate" := "rec_StudentWisePunchDates"."ASPU_PunchDate";

        FOR "rec_StudentDateWisePunchDateDails" IN
            SELECT DISTINCT "ASPUD_Id", 
                "ASPU_Id", 
                "ASPUD_PunchTime",
                ROW_NUMBER() OVER(PARTITION BY "ASPU_Id" ORDER BY "ASPUD_PunchTime" ASC) AS "Rno"
            FROM "Adm_Student_Punch_Details"
            WHERE "ASPU_Id" = "v_ASPU_Id"
        LOOP
            "v_ASPUD_Id" := "rec_StudentDateWisePunchDateDails"."ASPUD_Id";
            "v_ASPU_Id_PD" := "rec_StudentDateWisePunchDateDails"."ASPU_Id";
            "v_ASPUD_PunchTime" := "rec_StudentDateWisePunchDateDails"."ASPUD_PunchTime";
            "v_Rno" := "rec_StudentDateWisePunchDateDails"."Rno";

            IF ("v_Rno" % 2 = 0) THEN
                RAISE NOTICE 'remainder is zero So punch is O';
                UPDATE "Adm_Student_Punch_Details" 
                SET "ASPUD_InOutFlg" = 'O' 
                WHERE "ASPUD_Id" = "v_ASPUD_Id";
            ELSE
                RAISE NOTICE 'remainder is 1 So punch is I';
                UPDATE "Adm_Student_Punch_Details" 
                SET "ASPUD_InOutFlg" = 'I' 
                WHERE "ASPUD_Id" = "v_ASPUD_Id";
            END IF;

        END LOOP;

    END LOOP;

    RETURN;
END;
$$;