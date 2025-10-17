CREATE OR REPLACE FUNCTION "dbo"."College_Student_Register_Report_New" (
    "@mi_id" TEXT, 
    "@asmay_id" TEXT, 
    "@amco_id" TEXT, 
    "@amb_id" TEXT, 
    "@amse_id" TEXT, 
    "@acms_id" TEXT,
    "@column" TEXT, 
    "@gender" TEXT, 
    "@ACQ_Id" TEXT
)
RETURNS SETOF RECORD
LANGUAGE plpgsql
AS $$
DECLARE 
    "@gender_" VARCHAR(20);
    "@NEWGENDERMALE" TEXT;
    "@NEWGENDERFEMALE" TEXT;
    "@NEWGENDEROTHERSMALE" TEXT;
    "@NEWGENDER" TEXT;
    "@sql" TEXT;
BEGIN 

    IF "@gender" != 'Male' AND "@gender" != 'Female' AND "@gender" != 'Other' THEN
        "@NEWGENDERMALE" := 'Male';
        "@NEWGENDERFEMALE" := 'Female';
        "@NEWGENDEROTHERSMALE" := 'other';
        "@NEWGENDER" := '' || "@NEWGENDERMALE" || '''' || ',''' || "@NEWGENDERFEMALE" || ''',''' || "@NEWGENDEROTHERSMALE" || '';
    ELSE
        "@NEWGENDER" := "@gender";
    END IF;

    /***************** IF BRANCH IS SELECTED AS 0 *****************************/
    IF "@amb_id" = '0' THEN
        
        "@sql" := 'SELECT ' || "@column" || ' FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = b."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = b."ACMS_Id"
        INNER JOIN "clg"."Adm_College_Quota" i ON i."ACQ_Id" = a."ACQ_Id"
        INNER JOIN "clg"."Adm_College_Quota_Category" j ON j."ACQC_Id" = a."ACQC_Id"  
        WHERE a."MI_Id" = ' || "@mi_id" || ' AND b."ASMAY_Id" = ' || "@asmay_id" || ' 
        AND a."ACQ_Id" IN (' || "@ACQ_Id" || ') AND b."AMCO_Id" IN (' || "@amco_id" || ')  
        AND b."AMB_ID" IN (SELECT "AMB_ID" FROM "CLG"."ADM_MASTER_BRANCH" WHERE "MI_ID" = ' || "@mi_id" || ' AND "AMB_ActiveFlag" = 1) 
        AND b."AMSE_ID" IN (' || "@amse_id" || ') AND b."ACMS_ID" IN (' || "@acms_id" || ') AND a."AMCST_Sex" IN (''' || "@NEWGENDER" || ''')';
        
        RETURN QUERY EXECUTE "@sql";
        
    /********************** IF BRANCH AND OTHER SELECTD ***********************************/
    ELSE
        
        "@sql" := 'SELECT ' || "@column" || ' FROM "clg"."Adm_Master_College_Student" a
        INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
        INNER JOIN "Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
        INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = b."AMCO_Id"
        INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = b."AMB_Id"
        INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = b."AMSE_Id"
        INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = b."ACMS_Id"
        INNER JOIN "clg"."Adm_College_Quota" i ON i."ACQ_Id" = a."ACQ_Id"
        INNER JOIN "clg"."Adm_College_Quota_Category" j ON j."ACQC_Id" = a."ACQC_Id"  
        WHERE a."MI_Id" = ' || "@mi_id" || ' AND b."ASMAY_Id" = ' || "@asmay_id" || ' 
        AND a."ACQ_Id" IN (' || "@ACQ_Id" || ') AND b."AMCO_Id" IN (' || "@amco_id" || ')  
        AND b."AMB_ID" IN (' || "@amb_id" || ') AND b."AMSE_ID" IN (' || "@amse_id" || ') AND b."ACMS_ID" IN (' || "@acms_id" || ') AND a."AMCST_Sex" IN (''' || "@NEWGENDER" || ''')';
        
        RETURN QUERY EXECUTE "@sql";
        
    END IF;

    RETURN;

END;
$$;