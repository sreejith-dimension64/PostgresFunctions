CREATE OR REPLACE FUNCTION "dbo"."Don_Exam_PromotionCumulative_SubjectList"(
    "@MI_Id" VARCHAR,
    "@ASMAY_Id" VARCHAR,
    "@ASMCL_Id" VARCHAR,
    "@ASMS_Id" VARCHAR
)
RETURNS TABLE (
    "subid" BIGINT,
    "subjectname" TEXT,
    "subjectorder_new" BIGINT,
    "subjectorder" INTEGER,
    "EYCES_AplResultFlg" BOOLEAN,
    "ISMS_SubjectCode" VARCHAR,
    "complusoryflag" TEXT
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_subid BIGINT;
    v_subjectname TEXT;
    v_subjectorder INTEGER;
    v_esgid INTEGER;
    v_amst_id BIGINT;
    v_emeid BIGINT;
    v_eme_idNew BIGINT;
    v_Actsubordercount BIGINT;
    v_EYCES_AplResultFlg BOOLEAN;
    v_complusoryflag TEXT;
    v_ESG_Id_S BIGINT;
    v_newsuborder BIGINT;
    v_Actsuborder BIGINT;
    subject_rec RECORD;
    groupid_rec RECORD;
BEGIN
    
    DROP TABLE IF EXISTS "GroupwisePromotionCumulativeSubjectsOrder_Temp";
    
    CREATE TEMP TABLE "GroupwisePromotionCumulativeSubjectsOrder_Temp" (
        "subid" BIGINT,
        "subjectname" TEXT,
        "subjectorder" INTEGER,
        "ESG_Id" BIGINT,
        "subjectorder_new" BIGINT,
        "EYCES_AplResultFlg" BOOLEAN,
        "complusoryflag" TEXT
    );
    
    FOR subject_rec IN 
        SELECT DISTINCT "ISMS_IdNew", "ISMS_SubjectNameNew", "EMPS_SubjOrder", "ESG_Id", "EMPS_AppToResultFlg", "complusoryflag" 
        FROM "stjames_temp_cumulative_promotion_details"
        ORDER BY "EMPS_SubjOrder"
    LOOP
        v_subid := subject_rec."ISMS_IdNew";
        v_subjectname := subject_rec."ISMS_SubjectNameNew";
        v_subjectorder := subject_rec."EMPS_SubjOrder";
        v_esgid := subject_rec."ESG_Id";
        v_EYCES_AplResultFlg := subject_rec."EMPS_AppToResultFlg";
        v_complusoryflag := subject_rec."complusoryflag";
        
        INSERT INTO "GroupwisePromotionCumulativeSubjectsOrder_Temp" 
        VALUES(v_subid, v_subjectname, v_subjectorder, v_esgid, 0, v_EYCES_AplResultFlg, v_complusoryflag);
    END LOOP;
    
    FOR groupid_rec IN 
        SELECT DISTINCT "esg_id" 
        FROM "GroupwisePromotionCumulativeSubjectsOrder_Temp" 
        WHERE "ESG_Id" <> 0
    LOOP
        v_ESG_Id_S := groupid_rec."esg_id";
        
        SELECT COUNT("subjectorder") INTO v_Actsubordercount
        FROM "GroupwisePromotionCumulativeSubjectsOrder_Temp" 
        WHERE "ESG_Id" = v_ESG_Id_S;
        
        SELECT "subjectorder" INTO v_newsuborder
        FROM (
            SELECT "esg_id", "subjectorder", 
                   ROW_NUMBER() OVER(PARTITION BY "esg_id" ORDER BY "esg_id") AS "RNo"
            FROM "GroupwisePromotionCumulativeSubjectsOrder_Temp" 
            WHERE "esg_id" <> 0 AND "esg_id" = v_ESG_Id_S
        ) AS "New"
        WHERE "RNo" = v_Actsubordercount - 1 AND "esg_id" = v_ESG_Id_S;
        
        SELECT MAX("subjectorder") INTO v_Actsuborder
        FROM "GroupwisePromotionCumulativeSubjectsOrder_Temp" 
        WHERE "ESG_Id" = v_ESG_Id_S;
        
        UPDATE "GroupwisePromotionCumulativeSubjectsOrder_Temp" 
        SET "subjectorder_new" = v_newsuborder 
        WHERE "ESG_Id" = v_ESG_Id_S AND "subjectorder" = v_Actsuborder;
    END LOOP;
    
    UPDATE "GroupwisePromotionCumulativeSubjectsOrder_Temp" 
    SET "subjectorder_new" = "subjectorder" 
    WHERE "subjectorder_new" = 0;
    
    RETURN QUERY
    SELECT DISTINCT 
        a."subid",
        a."subjectname",
        a."subjectorder_new",
        a."subjectorder",
        a."EYCES_AplResultFlg",
        b."ISMS_SubjectCode",
        a."complusoryflag"
    FROM "GroupwisePromotionCumulativeSubjectsOrder_Temp" a 
    LEFT JOIN "IVRM_Master_Subjects" b ON a."subid" = b."ISMS_Id"
    ORDER BY a."subjectorder_new";
    
END;
$$;