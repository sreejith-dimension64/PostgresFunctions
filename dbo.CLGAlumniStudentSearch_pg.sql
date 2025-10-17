CREATE OR REPLACE FUNCTION "dbo"."CLGAlumniStudentSearch"(
    "Where" TEXT,
    "MI_Id" TEXT,
    "asmay_id" TEXT,
    "amco_id" TEXT,
    "amb_id" TEXT,
    "amse_id" TEXT
)
RETURNS TABLE(
    "ALCMST_FirstName" VARCHAR,
    "ALCMST_MiddleName" VARCHAR,
    "ALCMST_LastName" VARCHAR,
    "ALCMST_AdmNo" VARCHAR,
    "ALCMST_DOB" DATE,
    "ALCMST_Sex" VARCHAR,
    "ALCMST_emailId" VARCHAR,
    "ALCMST_MobileNo" VARCHAR,
    "ALCMST_BloodGroup" VARCHAR,
    "ALCMST_FatherName" VARCHAR,
    "ALCMST_MotherName" VARCHAR,
    "AMCO_CourseName" VARCHAR,
    "AMB_BranchName" VARCHAR,
    "AMSE_SEMName" VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_sql TEXT;
BEGIN
    v_sql := 'SELECT stuyear."ALCMST_FirstName",stuyear."ALCMST_MiddleName",stuyear."ALCMST_LastName",stuyear."ALCMST_AdmNo",stuyear."ALCMST_DOB",stuyear."ALCMST_Sex",stuyear."ALCMST_emailId",stuyear."ALCMST_MobileNo",stuyear."ALCMST_BloodGroup",stuyear."ALCMST_FatherName",stuyear."ALCMST_MotherName",co."AMCO_CourseName",bo."AMB_BranchName",sem."AMSE_SEMName"
 FROM "clg"."Alumni_College_Master_Student" stuyear 
INNER JOIN "clg"."Adm_Master_Course" co ON co."AMCO_Id"=stuyear."AMCO_JOIN_Id" AND co."AMCO_Id"=stuyear."AMCO_JOIN_Id"
INNER JOIN "clg"."Adm_Master_Branch" bo ON bo."AMB_Id"=stuyear."AMB_JOIN_Id" AND bo."AMB_Id"=stuyear."AMB_JOIN_Id"
INNER JOIN "clg"."Adm_Master_Semester" sem ON sem."AMSE_Id"=stuyear."AMSE_JOIN_Id" AND sem."AMSE_Id"=stuyear."AMSE_JOIN_Id"
INNER JOIN "Adm_School_M_Academic_Year" yer ON yer."ASMAY_Id"=stuyear."ASMAY_Id_Join" AND yer."ASMAY_Id"=stuyear."ASMAY_Id_Join"
WHERE stuyear."ASMAY_Id_Left" =' || "asmay_id" || '
AND stuyear."AMCO_Left_Id"=' || "amco_id" || ' 
AND stuyear."AMB_Id_Left" IN (' || "amb_id" || ') AND stuyear."AMSE_Id_Left" IN (' || "amse_id" || ') AND ' || "Where";

    RETURN QUERY EXECUTE v_sql;
END;
$$;