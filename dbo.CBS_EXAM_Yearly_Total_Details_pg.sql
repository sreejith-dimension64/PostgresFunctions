CREATE OR REPLACE FUNCTION "dbo"."CBS_EXAM_Yearly_Total_Details"(
    @MI_Id TEXT,
    @ASMAY_Id TEXT,
    @ASMCL_Id TEXT,
    @ASMS_Id TEXT,
    @AMST_Id TEXT
)
RETURNS TABLE (
    "AMST_Id" BIGINT,
    "TotalPercentage" NUMERIC(18,2),
    "ESTMPPSG_GroupObtMarks" NUMERIC(18,2),
    "YeralyGroupObtMarks" NUMERIC(18,2)
)
LANGUAGE plpgsql
AS $$
DECLARE
    @EYC_Id BIGINT;
    @EMCA_Id BIGINT;
    @ExmConfig_RankingMethod VARCHAR(50);
    @ESG_Id BIGINT;
    @AMST_IdBack BIGINT;
    @EMPS_SubjOrder BIGINT;
    @EMP_Id BIGINT;
    @EMPS_ConvertForMarks NUMERIC(18,2);
BEGIN
    SELECT "EMCA_Id" INTO @EMCA_Id 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = @MI_Id 
        AND "ASMAY_Id" = @ASMAY_Id 
        AND "ASMCL_Id" = @ASMCL_Id 
        AND "ASMS_Id" = @ASMS_Id
        AND "ECAC_ActiveFlag" = 1;
    
    SELECT "EYC_Id" INTO @EYC_Id 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = @MI_Id 
        AND "ASMAY_Id" = @ASMAY_Id 
        AND "EMCA_Id" = @EMCA_Id 
        AND "EYC_ActiveFlg" = 1;
    
    SELECT "EMP_Id" INTO @EMP_Id 
    FROM "Exm"."Exm_M_Promotion" 
    WHERE "MI_Id" = @MI_Id 
        AND "EMP_ActiveFlag" = 1 
        AND "EYC_Id" = @EYC_Id;
    
    RETURN QUERY
    SELECT DISTINCT 
        a."AMST_Id",
        CAST((SUM(a."YeralyGroupObtMarks") / NULLIF(SUM(c."EMPS_ConvertForMarks"), 0) * 100) AS NUMERIC(18,2)) AS "TotalPercentage",
        SUM(a."ESTMPPSG_GroupObtMarks") AS "ESTMPPSG_GroupObtMarks",
        SUM(a."YeralyGroupObtMarks") AS "YeralyGroupObtMarks"
    FROM "CBSE_MarksTemp_StudentDetails" a
    INNER JOIN "Exm"."Exm_Stu_MP_Promo_Subjectwise" b 
        ON a."AMST_Id" = b."AMST_Id"
        AND b."ASMAY_Id" = @ASMAY_Id 
        AND b."ASMCL_Id" = @ASMCL_Id 
        AND b."ASMS_Id" = @ASMS_Id
        AND a."ISMS_Id" = b."ISMS_Id"
    INNER JOIN "Exm"."Exm_M_Promotion_Subjects" c 
        ON c."ISMS_Id" = b."ISMS_Id" 
        AND c."EMP_Id" = @EMP_Id
        AND a."ISMS_Id" = c."ISMS_Id"
    WHERE a."AMST_Id" IN (SELECT "AMST_Id" FROM "NDS_Temp_StudentDetails_Amstids")
        AND a."GropuFlag" = 0
    GROUP BY a."AMST_Id";
    
    RETURN;
END;
$$;