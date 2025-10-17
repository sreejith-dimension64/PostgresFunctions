CREATE OR REPLACE FUNCTION "dbo"."CLGAlumniStudentReportUser"(
    "MI_Id" TEXT,
    "asmay_id" TEXT,
    "amco_id" TEXT,
    "amb_id" TEXT,
    "amse_id" TEXT
)
RETURNS TABLE(
    "studentName" VARCHAR,
    "amcsT_Admno" VARCHAR,
    "ALCMST_DOB" TIMESTAMP,
    "ALCMST_Sex" VARCHAR,
    "ALCMST_emailId" VARCHAR,
    "ALCMST_MobileNo" VARCHAR,
    "ALCMST_BloodGroup" VARCHAR,
    "ALCMST_FatherName" VARCHAR,
    "ALCMST_MotherName" VARCHAR,
    "amcO_CourseName" VARCHAR,
    "amB_BranchName" VARCHAR,
    "amsE_SEMName" VARCHAR,
    "AMCST_Id" BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
    "sql" TEXT;
BEGIN
    "sql" := 'SELECT stuyear."ALCMST_FirstName" as "studentName", stuyear."ALCMST_AdmNo" as "amcsT_Admno", stuyear."ALCMST_DOB", stuyear."ALCMST_Sex", stuyear."ALCMST_emailId", stuyear."ALCMST_MobileNo", stuyear."ALCMST_BloodGroup", stuyear."ALCMST_FatherName", stuyear."ALCMST_MotherName", co."amcO_CourseName", bo."amB_BranchName", sem."amsE_SEMName", stuyear."ALCMST_Id" as "AMCST_Id"
    FROM "clg"."Alumni_College_Master_Student" stuyear
    INNER JOIN "clg"."Adm_Master_Course" co ON co."AMCO_Id" = stuyear."AMCO_JOIN_Id" AND co."AMCO_Id" = stuyear."AMCO_JOIN_Id"
    INNER JOIN "clg"."Adm_Master_Branch" bo ON bo."AMB_Id" = stuyear."AMB_JOIN_Id" AND bo."AMB_Id" = stuyear."AMB_JOIN_Id"
    INNER JOIN "clg"."Adm_Master_Semester" sem ON sem."AMSE_Id" = stuyear."AMSE_JOIN_Id" AND sem."AMSE_Id" = stuyear."AMSE_JOIN_Id"
    INNER JOIN "Adm_School_M_Academic_Year" yer ON yer."ASMAY_Id" = stuyear."ASMAY_Id_Join" AND yer."ASMAY_Id" = stuyear."ASMAY_Id_Join"
    WHERE stuyear."ASMAY_Id_Left" = ' || "asmay_id" || '
    AND stuyear."AMCO_Left_Id" = ' || "amco_id" || '
    AND stuyear."AMB_Id_Left" IN (' || "amb_id" || ')
    AND stuyear."AMSE_Id_Left" IN (' || "amse_id" || ')
    AND stuyear."ALCMST_Id" NOT IN (SELECT "AMCST_Id" FROM "CLG"."Alumni_College_Student_Registration" WHERE "MI_Id" = ' || "MI_Id" || ')';

    RETURN QUERY EXECUTE "sql";
END;
$$;