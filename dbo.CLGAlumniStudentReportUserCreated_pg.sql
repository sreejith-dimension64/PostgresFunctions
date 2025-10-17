CREATE OR REPLACE FUNCTION "dbo"."CLGAlumniStudentReportUserCreated" (
    "MI_Id" TEXT,
    "asmay_id" TEXT,
    "amco_id" TEXT,
    "amb_id" TEXT,
    "amse_id" TEXT
)
RETURNS TABLE (
    "studentName" TEXT,
    "amcsT_Admno" TEXT,
    "amcsT_emailId" TEXT,
    "amcsT_MobileNo" TEXT,
    "AMCST_Id" BIGINT,
    "username" TEXT,
    "password" TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := 'SELECT stuyear."ALCMST_FirstName" as studentName,
                     stuyear."ALCMST_AdmNo" as amcsT_Admno,
                     stuyear."ALCMST_emailId" as amcsT_emailId,
                     stuyear."ALCMST_MobileNo" as amcsT_MobileNo,
                     stuyear."ALCMST_Id" as "AMCST_Id",
                     app."UserName" as username,
                     ''Password@123'' as password
              FROM "clg"."Alumni_College_Master_Student" stuyear 
              INNER JOIN "clg"."Adm_Master_Course" co ON co."AMCO_Id"=stuyear."AMCO_JOIN_Id" AND co."AMCO_Id"=stuyear."AMCO_JOIN_Id"
              INNER JOIN "clg"."Adm_Master_Branch" bo ON bo."AMB_Id"=stuyear."AMB_JOIN_Id" AND bo."AMB_Id"=stuyear."AMB_JOIN_Id"
              INNER JOIN "clg"."Adm_Master_Semester" sem ON sem."AMSE_Id"=stuyear."AMSE_JOIN_Id" AND sem."AMSE_Id"=stuyear."AMSE_JOIN_Id"
              INNER JOIN "Adm_School_M_Academic_Year" yer ON yer."ASMAY_Id"=stuyear."ASMAY_Id_Join" AND yer."ASMAY_Id"=stuyear."ASMAY_Id_Join"
              INNER JOIN "CLG"."Alumni_College_Student_Registration" reg ON reg."AMCST_Id"=stuyear."ALCMST_Id"
              INNER JOIN "CLG"."IVRM_College_User_Login_Alumni" userl ON reg."ALCSREG_Id"=userl."ALCSREG_Id"
              INNER JOIN "ApplicationUser" app ON app."Id"=userl."IVRMUL_Id"
              WHERE stuyear."ASMAY_Id_Left" = ' || "asmay_id" || '
                AND stuyear."AMCO_Left_Id" = ' || "amco_id" || ' 
                AND stuyear."AMB_Id_Left" IN (' || "amb_id" || ')
                AND stuyear."AMSE_Id_Left" IN (' || "amse_id" || ')';
    
    RETURN QUERY EXECUTE v_sql;
END;
$$;