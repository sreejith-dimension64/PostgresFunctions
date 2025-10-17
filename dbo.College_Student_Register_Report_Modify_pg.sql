CREATE OR REPLACE FUNCTION "dbo"."College_Student_Register_Report_Modify" (
    "p_mi_id" TEXT, 
    "p_asmay_id" TEXT, 
    "p_amco_id" TEXT, 
    "p_amb_id" TEXT, 
    "p_amse_id" TEXT, 
    "p_acms_id" TEXT,
    "p_column" TEXT, 
    "p_gender" TEXT, 
    "p_ACQ_Id" TEXT,
    "p_Flag" TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "v_gender_" VARCHAR(20);
    "v_NEWGENDERMALE" TEXT;
    "v_NEWGENDERFEMALE" TEXT;
    "v_NEWGENDEROTHERSMALE" TEXT;
    "v_NEWGENDER" TEXT;
    "v_sql" TEXT;
BEGIN
    
    IF "p_gender" != 'Male' AND "p_gender" != 'Female' AND "p_gender" != 'Other' THEN
        "v_NEWGENDERMALE" := 'Male';
        "v_NEWGENDERFEMALE" := 'Female';
        "v_NEWGENDEROTHERSMALE" := 'other';
        "v_NEWGENDER" := '' || "v_NEWGENDERMALE" || '''' || ',''' || "v_NEWGENDERFEMALE" || ''',''' || "v_NEWGENDEROTHERSMALE" || '';
    ELSE
        "v_NEWGENDER" := "p_gender";
    END IF;

    IF "p_Flag" = 'Total' THEN
        
        IF "p_amb_id" = '0' THEN
            
            "v_sql" := 'SELECT ' || "p_column" || ' FROM "clg"."Adm_Master_College_Student" a
INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
INNER JOIN "Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = b."AMCO_Id"
INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = b."AMB_Id"
INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = b."AMSE_Id"
INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = b."ACMS_Id"
INNER JOIN "clg"."Adm_College_Quota" i ON i."ACQ_Id"=a."ACQ_Id"
INNER JOIN "clg"."Adm_College_Quota_Category" j ON j."ACQC_Id"=a."ACQC_Id"
LEFT JOIN "clg"."Adm_College_Student_PrevSchool" pr ON pr."AMCST_Id"=b."AMCST_Id"
LEFT OUTER JOIN "clg"."Adm_College_Student_Guardian" ga ON ga."AMCST_Id"=b."AMCST_Id"
LEFT OUTER JOIN "IVRM_Master_Country" co ON co."IVRMMC_Id"=a."AMCST_Nationality"
LEFT OUTER JOIN "IVRM_MAster_State" dda ON dda."IVRMMC_Id"=co."IVRMMC_Id" AND dda."IVRMMS_Id"=a."AMCST_PerState"
LEFT OUTER JOIN "IVRM_Master_Caste_Category" cc ON cc."IMCC_Id" = a."IMCC_Id"
LEFT OUTER JOIN "IVRM_Master_Caste" ca ON cc."IMCC_Id"=ca."IMCC_Id" AND ca."IMC_Id"=a."IMC_Id"
LEFT OUTER JOIN "IVRM_Master_Religion" ra ON ra."IVRMMR_Id"=a."IVRMMR_Id"
WHERE a."MI_Id" = ' || "p_mi_id" || ' AND b."ASMAY_Id" = ' || "p_asmay_id" || ' 
AND a."ACQ_Id" IN (' || "p_ACQ_Id" || ') AND b."AMCO_Id" IN (' || "p_amco_id" || ') AND a."AMCST_SOL"=''S'' AND a."AMCST_ACTIVEFLAG"=1 AND b."ACYST_ActiveFlag"=1
AND b."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."Adm_Master_Branch" WHERE "MI_ID"=' || "p_mi_id" || ' AND "AMB_ActiveFlag"=1 ) 
AND b."AMSE_ID" IN (' || "p_amse_id" || ') AND b."ACMS_ID" IN (' || "p_acms_id" || ') AND a."AMCST_Sex" IN (''' || "v_NEWGENDER" || ''')';
            
            EXECUTE "v_sql";
            
        ELSE
            
            "v_sql" := 'SELECT ' || "p_column" || ' FROM "clg"."Adm_Master_College_Student" a
INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
INNER JOIN "Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = b."AMCO_Id"
INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = b."AMB_Id"
INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = b."AMSE_Id"
INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = b."ACMS_Id"
INNER JOIN "clg"."Adm_College_Quota" i ON i."ACQ_Id"=a."ACQ_Id"
INNER JOIN "clg"."Adm_College_Quota_Category" j ON j."ACQC_Id"=a."ACQC_Id"
LEFT JOIN "clg"."Adm_College_Student_PrevSchool" pr ON pr."AMCST_Id"=b."AMCST_Id"
LEFT JOIN "IVRM_Master_Country" co ON co."IVRMMC_Id"=a."AMCST_Nationality"
LEFT JOIN "IVRM_MAster_State" dda ON dda."IVRMMC_Id"=co."IVRMMC_Id" AND dda."IVRMMS_Id"=a."AMCST_PerState"
LEFT JOIN "IVRM_Master_Caste_Category" cc ON cc."IMCC_Id" = a."IMCC_Id"
LEFT JOIN "IVRM_Master_Caste" ca ON cc."IMCC_Id"=ca."IMCC_Id" AND ca."IMC_Id"=a."IMC_Id"
WHERE a."MI_Id" = ' || "p_mi_id" || ' AND b."ASMAY_Id" = ' || "p_asmay_id" || ' 
AND a."ACQ_Id" IN (' || "p_ACQ_Id" || ') AND b."AMCO_Id" IN (' || "p_amco_id" || ') AND a."AMCST_SOL"=''S'' AND a."AMCST_ACTIVEFLAG"=1 AND b."ACYST_ActiveFlag"=1
AND b."AMB_ID" IN (' || "p_amb_id" || ') AND b."AMSE_ID" IN (' || "p_amse_id" || ') AND b."ACMS_ID" IN (' || "p_acms_id" || ') AND a."AMCST_Sex" IN (''' || "v_NEWGENDER" || ''')';
            
            EXECUTE "v_sql";
            
        END IF;
        
    ELSIF "p_Flag" = 'New' THEN
        
        IF "p_amb_id" = '0' THEN
            
            "v_sql" := 'SELECT ' || "p_column" || ' FROM "clg"."Adm_Master_College_Student" a
INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
INNER JOIN "Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = b."AMCO_Id"
INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = b."AMB_Id"
INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = b."AMSE_Id"
INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = b."ACMS_Id"
INNER JOIN "clg"."Adm_College_Quota" i ON i."ACQ_Id"=a."ACQ_Id"
INNER JOIN "clg"."Adm_College_Quota_Category" j ON j."ACQC_Id"=a."ACQC_Id"
LEFT JOIN "clg"."Adm_College_Student_PrevSchool" pr ON pr."AMCST_Id"=b."AMCST_Id"
LEFT JOIN "IVRM_Master_Country" co ON co."IVRMMC_Id"=a."AMCST_Nationality"
LEFT JOIN "IVRM_MAster_State" dda ON dda."IVRMMC_Id"=co."IVRMMC_Id" AND dda."IVRMMS_Id"=a."AMCST_PerState"
LEFT JOIN "IVRM_Master_Caste_Category" cc ON cc."IMCC_Id" = a."IMCC_Id"
LEFT JOIN "IVRM_Master_Caste" ca ON cc."IMCC_Id"=ca."IMCC_Id" AND ca."IMC_Id"=a."IMC_Id"
WHERE a."MI_Id" = ' || "p_mi_id" || ' AND b."ASMAY_Id" = ' || "p_asmay_id" || ' 
AND a."ACQ_Id" IN (' || "p_ACQ_Id" || ') AND b."AMCO_Id" IN (' || "p_amco_id" || ') AND a."AMCST_SOL"=''S'' AND a."AMCST_ACTIVEFLAG"=1 AND b."ACYST_ActiveFlag"=1
AND b."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."Adm_Master_Branch" WHERE "MI_ID"=' || "p_mi_id" || ' AND "AMB_ActiveFlag"=1 ) 
AND b."AMSE_ID" IN (' || "p_amse_id" || ') AND b."ACMS_ID" IN (' || "p_acms_id" || ') AND a."AMCST_Sex" IN (''' || "v_NEWGENDER" || ''')';
            
            EXECUTE "v_sql";
            
        ELSE
            
            "v_sql" := 'SELECT ' || "p_column" || ' FROM "clg"."Adm_Master_College_Student" a
INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
INNER JOIN "Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = b."AMCO_Id"
INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = b."AMB_Id"
INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = b."AMSE_Id"
INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = b."ACMS_Id"
INNER JOIN "clg"."Adm_College_Quota" i ON i."ACQ_Id"=a."ACQ_Id"
INNER JOIN "clg"."Adm_College_Quota_Category" j ON j."ACQC_Id"=a."ACQC_Id"
LEFT JOIN "clg"."Adm_College_Student_PrevSchool" pr ON pr."AMCST_Id"=b."AMCST_Id"
LEFT JOIN "IVRM_Master_Country" co ON co."IVRMMC_Id"=a."AMCST_Nationality"
LEFT JOIN "IVRM_MAster_State" dda ON dda."IVRMMC_Id"=co."IVRMMC_Id" AND dda."IVRMMS_Id"=a."AMCST_PerState"
LEFT JOIN "IVRM_Master_Caste_Category" cc ON cc."IMCC_Id" = a."IMCC_Id"
LEFT JOIN "IVRM_Master_Caste" ca ON cc."IMCC_Id"=ca."IMCC_Id" AND ca."IMC_Id"=a."IMC_Id"
WHERE a."MI_Id" = ' || "p_mi_id" || ' AND a."ASMAY_Id" = ' || "p_asmay_id" || ' 
AND a."ACQ_Id" IN (' || "p_ACQ_Id" || ') AND a."AMCO_Id" IN (' || "p_amco_id" || ') AND a."AMCST_SOL"=''S'' AND a."AMCST_ACTIVEFLAG"=1 AND b."ACYST_ActiveFlag"=1
AND a."AMB_ID" IN (' || "p_amb_id" || ') AND a."AMSE_ID" IN (' || "p_amse_id" || ') AND b."ACMS_ID" IN (' || "p_acms_id" || ') AND a."AMCST_Sex" IN (''' || "v_NEWGENDER" || ''')';
            
            EXECUTE "v_sql";
            
        END IF;
        
    ELSIF "p_Flag" = 'Deactive' THEN
        
        IF "p_amb_id" = '0' THEN
            
            "v_sql" := 'SELECT ' || "p_column" || ' FROM "clg"."Adm_Master_College_Student" a
INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
INNER JOIN "Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = b."AMCO_Id"
INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = b."AMB_Id"
INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = b."AMSE_Id"
INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = b."ACMS_Id"
INNER JOIN "clg"."Adm_College_Quota" i ON i."ACQ_Id"=a."ACQ_Id"
INNER JOIN "clg"."Adm_College_Quota_Category" j ON j."ACQC_Id"=a."ACQC_Id"
LEFT JOIN "clg"."Adm_College_Student_PrevSchool" pr ON pr."AMCST_Id"=b."AMCST_Id"
LEFT JOIN "IVRM_Master_Country" co ON co."IVRMMC_Id"=a."AMCST_Nationality"
LEFT JOIN "IVRM_MAster_State" dda ON dda."IVRMMC_Id"=co."IVRMMC_Id" AND dda."IVRMMS_Id"=a."AMCST_PerState"
LEFT JOIN "IVRM_Master_Caste_Category" cc ON cc."IMCC_Id" = a."IMCC_Id"
LEFT JOIN "IVRM_Master_Caste" ca ON cc."IMCC_Id"=ca."IMCC_Id" AND ca."IMC_Id"=a."IMC_Id"
WHERE a."MI_Id" = ' || "p_mi_id" || ' AND b."ASMAY_Id" = ' || "p_asmay_id" || ' 
AND a."ACQ_Id" IN (' || "p_ACQ_Id" || ') AND b."AMCO_Id" IN (' || "p_amco_id" || ') AND a."AMCST_SOL"=''D'' AND a."AMCST_ACTIVEFLAG"=1 AND b."ACYST_ActiveFlag"=1
AND b."AMB_ID" IN (SELECT "AMB_ID" FROM "clg"."Adm_Master_Branch" WHERE "MI_ID"=' || "p_mi_id" || ' AND "AMB_ActiveFlag"=1 ) 
AND b."AMSE_ID" IN (' || "p_amse_id" || ') AND b."ACMS_ID" IN (' || "p_acms_id" || ') AND a."AMCST_Sex" IN (''' || "v_NEWGENDER" || ''')';
            
            EXECUTE "v_sql";
            
        ELSE
            
            "v_sql" := 'SELECT ' || "p_column" || ' FROM "clg"."Adm_Master_College_Student" a
INNER JOIN "clg"."Adm_College_Yearly_Student" b ON a."AMCST_Id" = b."AMCST_Id"
INNER JOIN "Adm_School_M_Academic_Year" c ON b."ASMAY_Id" = c."ASMAY_Id"
INNER JOIN "clg"."Adm_Master_Course" e ON e."AMCO_Id" = b."AMCO_Id"
INNER JOIN "clg"."Adm_Master_Branch" f ON f."AMB_Id" = b."AMB_Id"
INNER JOIN "clg"."Adm_Master_Semester" g ON g."AMSE_Id" = b."AMSE_Id"
INNER JOIN "clg"."Adm_College_Master_Section" h ON h."ACMS_Id" = b."ACMS_Id"
INNER JOIN "clg"."Adm_College_Quota" i ON i."ACQ_Id"=a."ACQ_Id"
INNER JOIN "clg"."Adm_College_Quota_Category" j ON j."ACQC_Id"=a."ACQC_Id"
LEFT JOIN "clg"."Adm_College_Student_PrevSchool" pr ON pr."AMCST_Id"=b."AMCST_Id"
LEFT JOIN "IVRM_Master_Country" co ON co."IVRMMC_Id"=a."AMCST_Nationality"
LEFT JOIN "IVRM_MAster_State" dda ON dda."IVRMMC_Id"=co."IVRMMC_Id" AND dda."IVRMMS_Id"=a."AMCST_PerState"
LEFT JOIN "IVRM_Master_Caste_Category" cc ON cc."IMCC_Id" = a."IMCC_Id"
LEFT JOIN "IVRM_Master_Caste" ca ON cc."IMCC_Id"=ca."IMCC_Id" AND ca."IMC_Id"=a."IMC_Id"
WHERE a."MI_Id" = ' || "p_mi_id" || ' AND b."ASMAY_Id" = ' || "p_asmay_id" || ' 
AND a."ACQ_Id" IN (' || "p_ACQ_Id" || ') AND b."AMCO_Id" IN (' || "p_amco_id" || ') AND a."AMCST_SOL"=''D'' AND a."AMCST_ACTIVEFLAG"=1 AND b."ACYST_ActiveFlag"=1
AND b."AMB_ID" IN (' || "p_amb_id" || ') AND b."AMSE_ID" IN (' || "p_amse_id" || ') AND b."ACMS_ID" IN (' || "p_acms_id" || ') AND a."AMCST_Sex" IN (''' || "v_NEWGENDER" || ''')';
            
            EXECUTE "v_sql";
            
        END IF;
        
    END IF;

    RETURN;
    
END;
$$;