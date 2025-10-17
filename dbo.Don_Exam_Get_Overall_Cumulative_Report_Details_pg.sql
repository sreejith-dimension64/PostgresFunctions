CREATE OR REPLACE FUNCTION "dbo"."Don_Exam_Get_Overall_Cumulative_Report_Details"(
    "@MI_Id" TEXT,
    "@ASMAY_Id" TEXT,
    "@ASMCL_Id" TEXT,
    "@ASMS_Id" TEXT,
    "@FLAG" TEXT,
    "@EME_Id" TEXT
)
RETURNS SETOF record
LANGUAGE plpgsql
AS $$
DECLARE
    "@EYC_Id" BIGINT;
    "@EMCA_Id" BIGINT;
    "@ROUNDOFF_FLAG" BOOLEAN;
    "@EMPLOYEENAME" TEXT;
BEGIN
    "@EMPLOYEENAME" := '';
    
    SELECT "ExmConfig_RoundoffFlag" INTO "@ROUNDOFF_FLAG" 
    FROM "Exm"."Exm_Configuration" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT;

    SELECT DISTINCT "EMCA_Id" INTO "@EMCA_Id" 
    FROM "Exm"."Exm_Category_Class" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT 
        AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "ASMCL_Id" = "@ASMCL_Id"::BIGINT 
        AND "ASMS_Id" = "@ASMS_Id"::BIGINT 
        AND "ECAC_ActiveFlag" = 1;
        
    SELECT DISTINCT "EYC_Id" INTO "@EYC_Id" 
    FROM "Exm"."Exm_Yearly_Category" 
    WHERE "MI_Id" = "@MI_Id"::BIGINT 
        AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT 
        AND "EYC_ActiveFlg" = 1 
        AND "EMCA_Id" = "@EMCA_Id";

    IF "@FLAG" = '1' THEN
    
        SELECT (CASE WHEN "HRME_EmployeeFirstName" IS NULL OR "HRME_EmployeeFirstName" = '' THEN '' ELSE "HRME_EmployeeFirstName" END ||   
                CASE WHEN "HRME_EmployeeMiddleName" IS NULL OR "HRME_EmployeeMiddleName" = '' THEN '' ELSE ' ' || "HRME_EmployeeMiddleName"  END ||  
                CASE WHEN "HRME_EmployeeLastName" IS NULL OR "HRME_EmployeeLastName" = ''  THEN '' ELSE ' ' || "HRME_EmployeeLastName" END)
        INTO "@EMPLOYEENAME"
        FROM "IVRM_Master_ClassTeacher" A 
        INNER JOIN "HR_Master_Employee" B ON A."HRME_Id" = B."HRME_Id"  
        WHERE A."IMCT_ActiveFlag" = 1 
            AND B."HRME_ActiveFlag" = 1 
            AND B."HRME_LeftFlag" = 0 
            AND A."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND A."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND A."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND A."MI_Id" = "@MI_Id"::BIGINT
        LIMIT 1;

        RETURN QUERY
        SELECT DISTINCT A."AMST_Id", 
            (CASE WHEN "AMST_FirstName" IS NULL OR "AMST_FirstName" = '' THEN '' ELSE "AMST_FirstName" END ||   
             CASE WHEN "AMST_MiddleName" IS NULL OR "AMST_MiddleName" = '' THEN '' ELSE ' ' || "AMST_MiddleName"  END ||  
             CASE WHEN "AMST_LastName" IS NULL OR "AMST_LastName" = ''  THEN '' ELSE ' ' || "AMST_LastName" END) as studentname,   
            "AMST_AdmNo" as admno, 
            "AMAY_RollNo" as rollno, 
            "ASMCL_ClassName" as classname, 
            "ASMC_SectionName" as sectionname, 
            "AMST_RegistrationNo" as regno,  
            (CASE WHEN "AMST_FatherName" IS NULL OR "AMST_FatherName" = '' THEN '' ELSE "AMST_FatherName" END ||   
             CASE WHEN "AMST_FatherSurname" IS NULL OR "AMST_FatherSurname" = '' THEN '' ELSE ' ' || "AMST_FatherSurname"  END) as fathername,  
            (CASE WHEN "AMST_MotherName" IS NULL OR "AMST_MotherName" = '' THEN '' ELSE "AMST_MotherName" END ||   
             CASE WHEN "AMST_MotherSurname" IS NULL OR "AMST_MotherSurname" = '' THEN '' ELSE ' ' || "AMST_MotherSurname"  END) as mothername,  
            REPLACE(TO_CHAR("amst_dob", 'DD/MM/YYYY'), '/', '.') as dob, 
            "AMST_MobileNo" as mobileno,  
            (CASE WHEN "AMST_PerStreet" IS NULL OR "AMST_PerStreet" = '' THEN '' ELSE "AMST_PerStreet" END ||   
             CASE WHEN "AMST_PerArea" IS NULL OR "AMST_PerArea" = '' THEN '' ELSE ',' || "AMST_PerArea" END ||   
             CASE WHEN "AMST_PerCity" IS NULL OR "AMST_PerCity" = '' THEN '' ELSE ',' || "AMST_PerCity" END ||   
             CASE WHEN "AMST_PerAdd3" IS NULL OR "AMST_PerAdd3" = '' THEN '' ELSE ',' || "AMST_PerAdd3" END) as address,  
            "AMST_Photoname" as photoname, 
            COALESCE(I."SPCCMH_HouseName", '') as "SPCCMH_HouseName", 
            "@EMPLOYEENAME" as Classteacher  
        FROM "Adm_M_Student" A 
        INNER JOIN "Adm_School_Y_Student" B ON A."AMST_Id" = B."AMST_Id"  
        INNER JOIN "Adm_School_M_Academic_Year" C ON C."ASMAY_Id" = B."ASMAY_Id"  
        INNER JOIN "Adm_School_M_Class" D ON D."ASMCL_Id" = B."ASMCL_Id"  
        INNER JOIN "Adm_School_M_Section" E ON E."ASMS_Id" = B."ASMS_Id"  
        LEFT JOIN "SPC"."SPCC_Student_House" H ON H."AMST_Id" = A."AMST_Id" 
            AND H."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND H."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND H."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND H."SPCCMH_ActiveFlag" = 1  
        LEFT JOIN "SPC"."SPCC_Master_House" I ON I."SPCCMH_Id" = H."SPCCMH_Id" 
            AND I."SPCCMH_ActiveFlag" = 1 
            AND I."MI_Id" = "@MI_Id"::BIGINT  
        WHERE A."MI_Id" = "@MI_Id"::BIGINT 
            AND B."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND B."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND B."ASMS_Id" = "@ASMS_Id"::BIGINT  
        ORDER BY rollno;
        
    ELSIF "@FLAG" = '2' THEN
        RETURN QUERY
        SELECT a."AMST_Id",
            a."ISMS_Id" AS "ISMS_Id_Old",
            "ISMS_SubjectName" AS "ISMS_SubjectName_Old", 
            "EME_ExamName" as "EMPSG_GroupName",
            "ESTMPS_MaxMarks" as "ESTMPPSG_GroupMaxMarks",
            "ESTMPS_ObtainedMarks" as "ESTMPPSG_GroupObtMarks_Old",
            "EYCES_SubjectOrder" as "EMPS_SubjOrder",
            "EYCES_AplResultFlg" as "EMPS_AppToResultFlg",
            COALESCE("ESTMPS_ObtainedGrade", '') as "ESTMPPSG_GroupObtGrade",
            REPLACE("ESTMPS_GradePoints"::TEXT, '.00', '') as "ESTMPPSG_GradePoints", 
            "EME_ExamOrder" as grporder,
            "ESTMPS_PassFailFlg" as "ESTMPPS_PassFailFlg",
            "EME_ExamName" as "EMPSG_DisplayName",
            0::BIGINT as "ESG_Id",
            "ISMS_OrderFlag" as subjectgrporder,
            ''::TEXT as complusoryflag,
            a."ISMS_Id" AS "ISMS_Id",
            a."EME_Id"
        FROM "Exm"."Exm_Student_Marks_Process_Subjectwise" a
        INNER JOIN "Exm"."Exm_Master_Exam" b ON a."EME_Id" = b."EME_Id"
        INNER JOIN "IVRM_Master_Subjects" C ON C."ISMS_Id" = a."ISMS_Id"
        INNER JOIN "exm"."Exm_Yearly_Category" e ON e."ASMAY_Id" = a."ASMAY_Id" AND e."EMCA_Id" = "@EMCA_Id"
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" f ON f."EME_Id" = b."EME_Id" 
            AND f."EYC_Id" = e."EYC_Id" 
            AND f."EYC_Id" = "@EYC_Id"
        INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" g ON g."EYCE_Id" = f."EYCE_Id" 
            AND g."ISMS_Id" = a."ISMS_Id"
        WHERE b."EME_Id"::TEXT = ANY(STRING_TO_ARRAY("@EME_Id", ',')) 
            AND A."MI_Id" = "@MI_Id"::BIGINT 
            AND A."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND A."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND A."ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND a."EME_Id"::TEXT = ANY(STRING_TO_ARRAY("@EME_Id", ','));
            
    ELSIF "@FLAG" = '3' THEN
        RETURN QUERY
        SELECT DISTINCT d."ISMS_Id",
            "ISMS_SubjectName",
            "ISMS_SubjectCode",
            "EYCES_MarksDisplayFlg",
            "EYCES_GradeDisplayFlg",
            "EYCES_AplResultFlg",
            "EYCES_SubjectOrder"  
        FROM "exm"."Exm_Yearly_Category" a
        INNER JOIN "Exm"."Exm_Yearly_Category_Exams" b ON a."EYC_Id" = b."EYC_Id" 
        INNER JOIN "exm"."Exm_Yrly_Cat_Exams_Subwise" c ON c."EYCE_Id" = b."EYCE_Id"
        INNER JOIN "IVRM_Master_Subjects" d ON d."ISMS_Id" = c."ISMS_Id"
        WHERE a."EYC_Id" = "@EYC_Id" 
            AND a."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND a."EMCA_Id" = "@EMCA_Id" 
            AND b."EME_Id"::TEXT = ANY(STRING_TO_ARRAY("@EME_Id", ',')) 
        ORDER BY "EYCES_SubjectOrder";
        
    ELSIF "@FLAG" = '4' THEN
        RETURN QUERY
        SELECT DISTINCT "AMST_Id", 
            "MI_Id", 
            "ASMAY_Id", 
            "ASMCL_Id", 
            "ASMS_Id", 
            "EME_Id", 
            "ESTMP_TotalMaxMarks", 
            "ESTMP_TotalObtMarks", 
            "ESTMP_Percentage", 
            "ESTMP_TotalGrade", 
            "ESTMP_ClassRank", 
            "ESTMP_SectionRank", 
            "ESTMP_Result", 
            "ESTMP_BRPercentage", 
            "ESTMP_PublishToStudentFlg", 
            "ESTMP_GrandTotal", 
            "ESTMP_SectionPosition", 
            "ESTMP_ClassPosition", 
            "ESTMP_TotalConvertedMarks", 
            "ESTMP_TotalConverionMaxMarks", 
            "ESTMP_GradePoints", 
            "EMGD_Id", 
            "ESTMP_CreatedBy", 
            "ESTMP_UpdatedBy", 
            "ESTMP_Points", 
            "ESTMP_QRCode", 
            "ESTMP_ActiveFlg", 
            "ESTMP_PRFileName", 
            "ESTMP_HtmlTemplate"
        FROM "Exm"."Exm_Student_Marks_Process" 
        WHERE "ESTMP_ActiveFlg" = 1 
            AND "ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND "ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND "ASMS_Id" = "@ASMS_Id"::BIGINT 
            AND "EME_Id"::TEXT = ANY(STRING_TO_ARRAY("@EME_Id", ','));
            
    ELSIF "@FLAG" = '5' THEN
        RETURN QUERY
        SELECT DISTINCT "AMST_Id", 
            "ECSACTT_Score",
            b."ECT_Id" as "EME_Id",
            "ECACTA_Id" as "ISMS_Id" 
        FROM "exm"."Exm_CCE_Activities_Transaction" a
        INNER JOIN "exm"."Exm_CCE_TERMS" b ON a."ECT_Id" = b."ECT_Id" 
            AND b."EMCA_Id" = "@EMCA_Id"
        WHERE a."ECSACTT_ActiveFlag" = 1 
            AND b."ecT_Id"::TEXT = ANY(STRING_TO_ARRAY("@EME_Id", ',')) 
            AND a."MI_Id" = "@MI_Id"::BIGINT 
            AND a."ASMAY_Id" = "@ASMAY_Id"::BIGINT 
            AND a."ASMCL_Id" = "@ASMCL_Id"::BIGINT 
            AND a."ASMS_Id" = "@ASMS_Id"::BIGINT;
            
    ELSIF "@FLAG" = '6' THEN
        RETURN QUERY
        SELECT DISTINCT m."ecacT_Id",  
            n."ecactA_Id" as "ISMS_Id",  
            n."ecactA_SkillArea" AS "areaName",
            o."emgR_Id", 
            n."ecactA_SkillOrder" 
        FROM "Exm"."Exm_CCE_Activities" m
        INNER JOIN "Exm"."Exm_CCE_Activities_AREA_Mapping" o ON m."ECACT_Id" = o."ECACT_Id"
        INNER JOIN "Exm"."Exm_CCE_Activities_AREA" n ON n."ECACTA_Id" = o."ECACTA_Id"
        WHERE o."MI_Id" = "@MI_Id"::BIGINT 
            AND o."ECACTAM_ActiveFlag" = 1 
            AND o."ASMAY_Id" = "@ASMAY_Id"::BIGINT  
        ORDER BY n."ECACTA_SkillOrder";
        
    END IF;
    
    RETURN;
END;
$$;