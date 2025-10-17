CREATE OR REPLACE FUNCTION "dbo"."Get_Electives_Report"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "Type" varchar(10),
    "EMCA_Id" int
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    "Group" varchar(50);
    "GroupNames" text;
    "query" text;
    "rec" RECORD;
BEGIN
    IF("Type" = 'All') THEN
        "GroupNames" := '';
        
        FOR "rec" IN 
            SELECT "EMG_GroupName" 
            FROM "exm"."Exm_Master_Group" 
            WHERE "MI_Id" = "Get_Electives_Report"."MI_Id" 
                AND "EMG_ActiveFlag" = 1 
                AND "EMG_ElectiveFlg" = 1
        LOOP
            "Group" := '"' || "rec"."EMG_GroupName" || '"';
            "GroupNames" := CONCAT("GroupNames", "Group", ',');
        END LOOP;
        
        "GroupNames" := SUBSTRING("GroupNames", 1, LENGTH("GroupNames") - 1);
        
        RAISE NOTICE 'Length: %', LENGTH("GroupNames");
        RAISE NOTICE 'GroupNames: %', "GroupNames";
        
        "query" := 'SELECT "AMST_Id","EMG_Id","ISMS_Id","Student_Name","AMST_AdmNo","AMST_MobileNo","AMST_emailId","ASMCL_ClassName","ASMC_SectionName",' || "GroupNames" || 
                   ' FROM crosstab(''SELECT "AMST_Id" || ''''|'''' || "EMG_Id"::text || ''''|'''' || "ISMS_Id"::text || ''''|'''' || "Student_Name" || ''''|'''' || "AMST_AdmNo" || ''''|'''' || COALESCE("AMST_MobileNo",'''''''') || ''''|'''' || COALESCE("AMST_emailId",'''''''') || ''''|'''' || "ASMCL_ClassName" || ''''|'''' || "ASMC_SectionName" || ''''|'''' || "ASMCL_Order"::text || ''''|'''' || "ASMC_Order"::text || ''''|'''' || "ISMS_OrderFlag"::text as rowkey, "EMG_GroupName", "ISMS_SubjectName" ' ||
                   'FROM (SELECT ab."Student_Name",ab."AMST_AdmNo",ab."AMST_MobileNo",ab."AMST_emailId",ab."ASMCL_ClassName",ab."ASMC_SectionName",bc."EMG_GroupName",bc."ISMS_SubjectName",ab."ASMCL_Order",ab."ASMC_Order",bc."ISMS_OrderFlag",ca."AMST_Id",ca."EMG_Id",ca."ISMS_Id" ' ||
                   'FROM (SELECT a."AMST_Id",(a."AMST_FirstName" || '''' '''' || a."AMST_MiddleName" || ''''  '''' || a."AMST_LastName") "Student_Name",a."AMST_AdmNo",a."AMST_MobileNo",a."AMST_emailId",b."ASMCL_Id",c."ASMCL_ClassName",b."ASMS_Id",d."ASMC_SectionName",c."ASMCL_Order",d."ASMC_Order" ' ||
                   'FROM "Adm_M_Student" a,"Adm_School_Y_Student" b,"Adm_School_M_Class" c,"Adm_School_M_Section" d ' ||
                   'WHERE a."MI_Id"=' || "Get_Electives_Report"."MI_Id"::text || ' AND a."AMST_SOL"=''''S'''' AND a."AMST_ActiveFlag"=1 AND b."ASMAY_Id"=' || "Get_Electives_Report"."ASMAY_Id"::text || ' AND b."AMAY_ActiveFlag"=1 AND b."AMST_Id"=a."AMST_Id" ' ||
                   'AND c."MI_Id"=' || "Get_Electives_Report"."MI_Id"::text || ' AND c."ASMCL_ActiveFlag"=1 AND c."ASMCL_Id"=b."ASMCL_Id" AND d."MI_Id"=' || "Get_Electives_Report"."MI_Id"::text || ' AND d."ASMC_ActiveFlag"=1 AND d."ASMS_Id"=b."ASMS_Id") ab, ' ||
                   '(SELECT a."EMG_Id",a."EMG_GroupName",b."ISMS_Id",c."ISMS_SubjectName",c."ISMS_OrderFlag" FROM "exm"."Exm_Master_Group" a,"exm"."Exm_Master_Group_Subjects" b,"IVRM_Master_Subjects" c ' ||
                   'WHERE a."MI_Id"=' || "Get_Electives_Report"."MI_Id"::text || ' AND a."EMG_ActiveFlag"=1 AND a."EMG_ElectiveFlg"=1 AND b."EMG_Id"=a."EMG_Id" AND "EMGS_ActiveFlag"=1 AND c."MI_Id"=' || "Get_Electives_Report"."MI_Id"::text || ' AND c."ISMS_ActiveFlag"=1 AND c."ISMS_Id"=b."ISMS_Id" AND c."ISMS_ExamFlag"=1) bc, ' ||
                   '(SELECT "AMST_Id","ASMCL_Id","ASMS_Id","EMG_Id","ISMS_Id" FROM "exm"."Exm_Studentwise_Subjects" WHERE "MI_Id"=' || "Get_Electives_Report"."MI_Id"::text || ' AND "ASMAY_Id"=' || "Get_Electives_Report"."ASMAY_Id"::text || ' AND "ESTSU_ActiveFlg"=1) ca ' ||
                   'WHERE ab."AMST_Id"=ca."AMST_Id" AND ab."ASMCL_Id"=ca."ASMCL_Id" AND ab."ASMS_Id"=ca."ASMS_Id" AND bc."EMG_Id"=ca."EMG_Id" AND bc."ISMS_Id"=ca."ISMS_Id") s ' ||
                   'ORDER BY "ASMCL_Order","ASMC_Order","ISMS_OrderFlag","AMST_Id","EMG_Id","ISMS_Id"'') AS ct(rowkey text, ' || "GroupNames" || ' text)';
        
        EXECUTE "query";
        
    ELSIF("Type" = 'Indi') THEN
        "GroupNames" := '';
        
        FOR "rec" IN 
            SELECT "EMG_GroupName" 
            FROM "exm"."Exm_Master_Group" a,
                 "exm"."Exm_Yearly_Category" b,
                 "exm"."Exm_Yearly_Category_Group" c  
            WHERE a."MI_Id" = "Get_Electives_Report"."MI_Id" 
                AND a."EMG_ActiveFlag" = 1 
                AND a."EMG_ElectiveFlg" = 1 
                AND b."MI_Id" = a."MI_Id" 
                AND b."ASMAY_Id" = "Get_Electives_Report"."ASMAY_Id" 
                AND b."EYC_ActiveFlg" = 1 
                AND b."EMCA_Id" = "Get_Electives_Report"."EMCA_Id" 
                AND c."EYC_Id" = b."EYC_Id" 
                AND c."EYCG_ActiveFlg" = 1 
                AND c."EMG_Id" = a."EMG_Id"
        LOOP
            "Group" := '"' || "rec"."EMG_GroupName" || '"';
            "GroupNames" := CONCAT("GroupNames", "Group", ',');
        END LOOP;
        
        "GroupNames" := SUBSTRING("GroupNames", 1, LENGTH("GroupNames") - 1);
        
        RAISE NOTICE 'Length: %', LENGTH("GroupNames");
        RAISE NOTICE 'GroupNames: %', "GroupNames";
        
        "query" := 'SELECT "AMST_Id","EMG_Id","ISMS_Id","Student_Name","AMST_AdmNo","AMST_MobileNo","AMST_emailId","ASMCL_ClassName","ASMC_SectionName",' || "GroupNames" || 
                   ' FROM crosstab(''SELECT "AMST_Id" || ''''|'''' || "EMG_Id"::text || ''''|'''' || "ISMS_Id"::text || ''''|'''' || "Student_Name" || ''''|'''' || "AMST_AdmNo" || ''''|'''' || COALESCE("AMST_MobileNo",'''''''') || ''''|'''' || COALESCE("AMST_emailId",'''''''') || ''''|'''' || "ASMCL_ClassName" || ''''|'''' || "ASMC_SectionName" || ''''|'''' || "ASMCL_Order"::text || ''''|'''' || "ASMC_Order"::text || ''''|'''' || "ISMS_OrderFlag"::text as rowkey, "EMG_GroupName", "ISMS_SubjectName" ' ||
                   'FROM (SELECT ab."Student_Name",ab."AMST_AdmNo",ab."AMST_MobileNo",ab."AMST_emailId",ab."ASMCL_ClassName",ab."ASMC_SectionName",bc."EMG_GroupName",bc."ISMS_SubjectName",ab."ASMCL_Order",ab."ASMC_Order",bc."ISMS_OrderFlag",ca."AMST_Id",ca."EMG_Id",ca."ISMS_Id" ' ||
                   'FROM (SELECT a."AMST_Id",(a."AMST_FirstName" || '''' '''' || a."AMST_MiddleName" || ''''  '''' || a."AMST_LastName") "Student_Name",a."AMST_AdmNo",a."AMST_MobileNo",a."AMST_emailId",b."ASMCL_Id",c."ASMCL_ClassName",b."ASMS_Id",d."ASMC_SectionName",c."ASMCL_Order",d."ASMC_Order" ' ||
                   'FROM "Adm_M_Student" a,"Adm_School_Y_Student" b,"Adm_School_M_Class" c,"Adm_School_M_Section" d,"exm"."Exm_Category_Class" e ' ||
                   'WHERE a."MI_Id"=' || "Get_Electives_Report"."MI_Id"::text || ' AND a."AMST_SOL"=''''S'''' AND a."AMST_ActiveFlag"=1 AND b."ASMAY_Id"=' || "Get_Electives_Report"."ASMAY_Id"::text || ' AND b."AMAY_ActiveFlag"=1 AND b."AMST_Id"=a."AMST_Id" ' ||
                   'AND c."MI_Id"=' || "Get_Electives_Report"."MI_Id"::text || ' AND c."ASMCL_ActiveFlag"=1 AND c."ASMCL_Id"=b."ASMCL_Id" AND d."MI_Id"=' || "Get_Electives_Report"."MI_Id"::text || ' AND d."ASMC_ActiveFlag"=1 AND d."ASMS_Id"=b."ASMS_Id" ' ||
                   'AND e."MI_Id"=a."MI_Id" AND e."ASMAY_Id"=b."ASMAY_Id" AND e."ECAC_ActiveFlag"=1 AND e."EMCA_Id"=' || "Get_Electives_Report"."EMCA_Id"::text || ' AND e."ASMCL_Id"=b."ASMCL_Id" AND e."ASMS_Id"=b."ASMS_Id") ab, ' ||
                   '(SELECT a."EMG_Id",a."EMG_GroupName",b."ISMS_Id",c."ISMS_SubjectName",c."ISMS_OrderFlag" FROM "exm"."Exm_Master_Group" a,"exm"."Exm_Master_Group_Subjects" b,"IVRM_Master_Subjects" c,"exm"."Exm_Yearly_Category" d,"exm"."Exm_Yearly_Category_Group" e ' ||
                   'WHERE a."MI_Id"=' || "Get_Electives_Report"."MI_Id"::text || ' AND a."EMG_ActiveFlag"=1 AND a."EMG_ElectiveFlg"=1 AND b."EMG_Id"=a."EMG_Id" AND "EMGS_ActiveFlag"=1 AND c."MI_Id"=' || "Get_Electives_Report"."MI_Id"::text || ' AND c."ISMS_ActiveFlag"=1 AND c."ISMS_Id"=b."ISMS_Id" AND c."ISMS_ExamFlag"=1 ' ||
                   'AND d."MI_Id"=a."MI_Id" AND d."ASMAY_Id"=' || "Get_Electives_Report"."ASMAY_Id"::text || ' AND d."EMCA_Id"=' || "Get_Electives_Report"."EMCA_Id"::text || ' AND d."EYC_ActiveFlg"=1 AND e."EYC_Id"=d."EYC_Id" AND e."EYCG_ActiveFlg"=1 AND e."EMG_Id"=a."EMG_Id") bc, ' ||
                   '(SELECT "AMST_Id",a."ASMCL_Id",a."ASMS_Id","EMG_Id","ISMS_Id" FROM "exm"."Exm_Studentwise_Subjects" a,"exm"."Exm_Category_Class" b ' ||
                   'WHERE a."MI_Id"=' || "Get_Electives_Report"."MI_Id"::text || ' AND a."ASMAY_Id"=' || "Get_Electives_Report"."ASMAY_Id"::text || ' AND "ESTSU_ActiveFlg"=1 AND b."MI_Id"=a."MI_Id" AND b."ASMAY_Id"=a."ASMAY_Id" AND b."EMCA_Id"=' || "Get_Electives_Report"."EMCA_Id"::text || ' AND b."ASMCL_Id"=a."ASMCL_Id" AND b."ASMS_Id"=a."ASMS_Id" AND b."ECAC_ActiveFlag"=1) ca ' ||
                   'WHERE ab."AMST_Id"=ca."AMST_Id" AND ab."ASMCL_Id"=ca."ASMCL_Id" AND ab."ASMS_Id"=ca."ASMS_Id" AND bc."EMG_Id"=ca."EMG_Id" AND bc."ISMS_Id"=ca."ISMS_Id") s ' ||
                   'ORDER BY "ASMCL_Order","ASMC_Order","ISMS_OrderFlag","AMST_Id","EMG_Id","ISMS_Id"'') AS ct(rowkey text, ' || "GroupNames" || ' text)';
        
        EXECUTE "query";
    END IF;
END;
$$;