CREATE OR REPLACE FUNCTION "dbo"."College_Feedback_Report_Details_New"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@Flag" TEXT,
    "@Type" TEXT
)
RETURNS TABLE(
    "miid" TEXT,
    "remarks" TEXT,
    "options" TEXT,
    "qid" BIGINT,
    "opid" BIGINT,
    "total" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "@quesid" TEXT;
    "@questionremarks" TEXT;
    "@questionorder" TEXT;
    "@optionid" TEXT;
    "@optionremarks" TEXT;
    "@optionorder" TEXT;
    "@count" BIGINT;
    "@id" TEXT;
    "questions_rec" RECORD;
    "options_rec" RECORD;
BEGIN
    DROP TABLE IF EXISTS "feedback_reporttemp1";
    
    CREATE TEMP TABLE "feedback_reporttemp1" (
        "miid" TEXT,
        "remarks" TEXT,
        "options" TEXT,
        "qid" BIGINT,
        "opid" BIGINT,
        "total" BIGINT
    );
    
    FOR "questions_rec" IN 
        SELECT DISTINCT c."FMQE_Id", c."FMQE_FeedbackQRemarks", c."FMQE_FQOrder" 
        FROM "Feedback_Type_Questions" a 
        INNER JOIN "Feedback_Master_Type" b ON a."FMTY_Id" = b."FMTY_Id"
        INNER JOIN "Feedback_Master_Questions" c ON c."FMQE_Id" = a."FMQE_Id"
        WHERE c."MI_Id" = "@MI_Id" 
        AND a."MI_Id" = "@MI_Id" 
        AND b."MI_Id" = "@MI_Id" 
        AND a."FMTQ_ActiveFlag" = 1 
        AND b."FMTY_ActiveFlag" = 1 
        AND c."FMQE_ActiveFlag" = 1
        AND a."FMTY_Id" = "@Type" 
        AND b."FMTY_StakeHolderFlag" = "@Flag" 
        ORDER BY c."FMQE_FQOrder"
    LOOP
        "@quesid" := "questions_rec"."FMQE_Id"::TEXT;
        "@questionremarks" := "questions_rec"."FMQE_FeedbackQRemarks";
        "@questionorder" := "questions_rec"."FMQE_FQOrder"::TEXT;
        
        FOR "options_rec" IN 
            SELECT c."FMOP_Id", c."FMOP_FeedbackOptions", c."FMOP_FOOrder"
            FROM "Feedback_Type_Options" a 
            INNER JOIN "Feedback_Master_Type" b ON a."FMTY_Id" = b."FMTY_Id"
            INNER JOIN "Feedback_Master_Options" c ON c."FMOP_Id" = a."FMOP_Id"
            WHERE c."MI_Id" = "@MI_Id" 
            AND a."MI_Id" = "@MI_Id" 
            AND b."MI_Id" = "@MI_Id" 
            AND a."FMTO_ActiveFlag" = 1 
            AND b."FMTY_ActiveFlag" = 1 
            AND c."FMOP_ActiveFlag" = 1
            AND a."FMTY_Id" = "@Type" 
            AND b."FMTY_StakeHolderFlag" = "@Flag" 
            ORDER BY c."FMOP_FOOrder"
        LOOP
            "@optionid" := "options_rec"."FMOP_Id"::TEXT;
            "@optionremarks" := "options_rec"."FMOP_FeedbackOptions";
            "@optionorder" := "options_rec"."FMOP_FOOrder"::TEXT;
            
            "@count" := 0;
            "@id" := NULL;
            
            SELECT COUNT(*), "FMOP_Id"::TEXT 
            INTO "@count", "@id"
            FROM "clg"."Feedback_College_Student_Transaction" 
            WHERE "MI_Id" = "@MI_Id" 
            AND "ASMAY_Id" = "@ASMAY_Id" 
            AND "FCSTR_StudParFlg" = "@Flag" 
            AND "FMTY_Id" = "@Type" 
            AND "FMQE_Id" = "@quesid" 
            AND "FMOP_Id" = "@optionid" 
            GROUP BY "FMOP_Id";
            
            "@count" := COALESCE("@count", 0);
            
            INSERT INTO "feedback_reporttemp1" 
            VALUES ("@MI_Id", "@questionremarks", "@optionremarks", "@quesid"::BIGINT, "@optionid"::BIGINT, "@count");
            
        END LOOP;
        
    END LOOP;
    
    RETURN QUERY SELECT * FROM "feedback_reporttemp1";
    
END;
$$;