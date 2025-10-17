CREATE OR REPLACE FUNCTION "dbo"."GetStudentDataByAdecmicYearClassSectionBatchwise"(
    p_yearid TEXT,
    p_miid VARCHAR(100),
    p_id TEXT,
    p_asmcl_id TEXT,
    p_asms_id TEXT,
    p_asab_id TEXT
)
RETURNS TABLE(
    "AMST_Id" BIGINT,
    "studentname" TEXT,
    "AMST_AdmNo" TEXT,
    "AMAY_RollNo" BIGINT,
    "AMST_Sex" TEXT,
    "amsT_RegistrationNo" TEXT
) AS $$
DECLARE
    v_flag VARCHAR(100);
BEGIN
    v_flag := 'S';

    IF p_id = '1' THEN  -- for gender asc
        IF p_asms_id = '0' THEN
            RETURN QUERY
            SELECT MAX(mstd."AMST_Id")::BIGINT AS "AMST_Id", 
                   MAX(CASE WHEN mstd."AMST_FirstName" IS NULL OR mstd."AMST_FirstName" = '' THEN '' ELSE mstd."AMST_FirstName" END ||
                   CASE WHEN mstd."AMST_MiddleName" IS NULL OR mstd."AMST_MiddleName" = '' OR mstd."AMST_MiddleName" = '0' THEN '' ELSE ' ' || mstd."AMST_MiddleName" END ||
                   CASE WHEN mstd."AMST_LastName" IS NULL OR mstd."AMST_LastName" = '' OR mstd."AMST_LastName" = '0' THEN '' ELSE ' ' || mstd."AMST_LastName" END) AS "studentname",
                   MAX(mstd."AMST_AdmNo") AS "AMST_AdmNo",
                   MAX(ystd."AMAY_RollNo")::BIGINT AS "AMAY_RollNo",
                   mstd."AMST_Sex",
                   MAX(mstd."amsT_RegistrationNo") AS "amsT_RegistrationNo"
            FROM "Adm_M_Student" mstd
            LEFT JOIN "Adm_School_Y_Student" ystd ON ystd."AMST_Id" = mstd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch_Students" a ON a."AMST_Id" = ystd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch" b ON b."ASASB_Id" = a."ASASB_Id"
            WHERE ystd."ASMAY_Id" = p_yearid AND ystd."ASMCL_Id" = p_asmcl_id AND mstd."AMST_ActiveFlag" = 1 
                  AND mstd."MI_Id" = p_miid AND mstd."AMST_SOL" = v_flag AND mstd."AMST_Date" <= CURRENT_TIMESTAMP 
                  AND ystd."AMAY_ActiveFlag" = 1 AND b."ASMAY_Id" = p_yearid AND b."ASMCL_Id" = p_asmcl_id 
                  AND b."ASMS_Id" = p_asms_id AND b."ASASB_Id" = p_asab_id
            GROUP BY mstd."AMST_Id", mstd."AMST_Sex"
            ORDER BY mstd."AMST_Sex" ASC;
        ELSE
            RETURN QUERY
            SELECT MAX(mstd."AMST_Id")::BIGINT AS "AMST_Id",
                   MAX(CASE WHEN mstd."AMST_FirstName" IS NULL OR mstd."AMST_FirstName" = '' THEN '' ELSE mstd."AMST_FirstName" END ||
                   CASE WHEN mstd."AMST_MiddleName" IS NULL OR mstd."AMST_MiddleName" = '' OR mstd."AMST_MiddleName" = '0' THEN '' ELSE ' ' || mstd."AMST_MiddleName" END ||
                   CASE WHEN mstd."AMST_LastName" IS NULL OR mstd."AMST_LastName" = '' OR mstd."AMST_LastName" = '0' THEN '' ELSE ' ' || mstd."AMST_LastName" END) AS "studentname",
                   MAX(mstd."AMST_AdmNo") AS "AMST_AdmNo",
                   MAX(ystd."AMAY_RollNo")::BIGINT AS "AMAY_RollNo",
                   mstd."AMST_Sex",
                   MAX(mstd."amsT_RegistrationNo") AS "amsT_RegistrationNo"
            FROM "Adm_M_Student" mstd
            LEFT JOIN "Adm_School_Y_Student" ystd ON ystd."AMST_Id" = mstd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch_Students" a ON a."AMST_Id" = ystd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch" b ON b."ASASB_Id" = a."ASASB_Id"
            WHERE ystd."ASMAY_Id" = p_yearid AND ystd."ASMCL_Id" = p_asmcl_id AND ystd."ASMS_Id" = p_asms_id 
                  AND mstd."AMST_ActiveFlag" = 1 AND mstd."MI_Id" = p_miid AND mstd."AMST_SOL" = v_flag 
                  AND mstd."AMST_Date" <= CURRENT_TIMESTAMP AND ystd."AMAY_ActiveFlag" = 1 AND b."ASMAY_Id" = p_yearid 
                  AND b."ASMCL_Id" = p_asmcl_id AND b."ASMS_Id" = p_asms_id AND b."ASASB_Id" = p_asab_id
            GROUP BY mstd."AMST_Id", mstd."AMST_Sex"
            ORDER BY mstd."AMST_Sex" ASC;
        END IF;

    ELSIF p_id = '2' THEN  -- for gender desc
        IF p_asms_id = '0' THEN
            RETURN QUERY
            SELECT MAX(mstd."AMST_Id")::BIGINT AS "AMST_Id",
                   MAX(CASE WHEN mstd."AMST_FirstName" IS NULL OR mstd."AMST_FirstName" = '' THEN '' ELSE mstd."AMST_FirstName" END ||
                   CASE WHEN mstd."AMST_MiddleName" IS NULL OR mstd."AMST_MiddleName" = '' OR mstd."AMST_MiddleName" = '0' THEN '' ELSE ' ' || mstd."AMST_MiddleName" END ||
                   CASE WHEN mstd."AMST_LastName" IS NULL OR mstd."AMST_LastName" = '' OR mstd."AMST_LastName" = '0' THEN '' ELSE ' ' || mstd."AMST_LastName" END) AS "studentname",
                   MAX(mstd."AMST_AdmNo") AS "AMST_AdmNo",
                   MAX(ystd."AMAY_RollNo")::BIGINT AS "AMAY_RollNo",
                   mstd."AMST_Sex",
                   MAX(mstd."amsT_RegistrationNo") AS "amsT_RegistrationNo"
            FROM "Adm_M_Student" mstd
            LEFT JOIN "Adm_School_Y_Student" ystd ON ystd."AMST_Id" = mstd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch_Students" a ON a."AMST_Id" = ystd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch" b ON b."ASASB_Id" = a."ASASB_Id"
            WHERE ystd."ASMAY_Id" = p_yearid AND ystd."ASMCL_Id" = p_asmcl_id AND mstd."AMST_ActiveFlag" = 1 
                  AND mstd."MI_Id" = p_miid AND mstd."AMST_SOL" = v_flag AND mstd."AMST_Date" <= CURRENT_TIMESTAMP 
                  AND ystd."AMAY_ActiveFlag" = 1 AND b."ASMAY_Id" = p_yearid AND b."ASMCL_Id" = p_asmcl_id 
                  AND b."ASMS_Id" = p_asms_id AND b."ASASB_Id" = p_asab_id
            GROUP BY mstd."AMST_Id", mstd."AMST_Sex"
            ORDER BY mstd."AMST_Sex" DESC;
        ELSE
            RETURN QUERY
            SELECT MAX(mstd."AMST_Id")::BIGINT AS "AMST_Id",
                   MAX(CASE WHEN mstd."AMST_FirstName" IS NULL OR mstd."AMST_FirstName" = '' THEN '' ELSE mstd."AMST_FirstName" END ||
                   CASE WHEN mstd."AMST_MiddleName" IS NULL OR mstd."AMST_MiddleName" = '' OR mstd."AMST_MiddleName" = '0' THEN '' ELSE ' ' || mstd."AMST_MiddleName" END ||
                   CASE WHEN mstd."AMST_LastName" IS NULL OR mstd."AMST_LastName" = '' OR mstd."AMST_LastName" = '0' THEN '' ELSE ' ' || mstd."AMST_LastName" END) AS "studentname",
                   MAX(mstd."AMST_AdmNo") AS "AMST_AdmNo",
                   MAX(ystd."AMAY_RollNo")::BIGINT AS "AMAY_RollNo",
                   mstd."AMST_Sex",
                   MAX(mstd."amsT_RegistrationNo") AS "amsT_RegistrationNo"
            FROM "Adm_M_Student" mstd
            LEFT JOIN "Adm_School_Y_Student" ystd ON ystd."AMST_Id" = mstd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch_Students" a ON a."AMST_Id" = ystd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch" b ON b."ASASB_Id" = a."ASASB_Id"
            WHERE ystd."ASMAY_Id" = p_yearid AND ystd."ASMCL_Id" = p_asmcl_id AND ystd."ASMS_Id" = p_asms_id 
                  AND mstd."AMST_ActiveFlag" = 1 AND mstd."MI_Id" = p_miid AND mstd."AMST_SOL" = v_flag 
                  AND mstd."AMST_Date" <= CURRENT_TIMESTAMP AND ystd."AMAY_ActiveFlag" = 1 AND b."ASMAY_Id" = p_yearid 
                  AND b."ASMCL_Id" = p_asmcl_id AND b."ASMS_Id" = p_asms_id AND b."ASASB_Id" = p_asab_id
            GROUP BY mstd."AMST_Id", mstd."AMST_Sex"
            ORDER BY mstd."AMST_Sex" DESC;
        END IF;

    ELSIF p_id = '3' THEN  -- for roll no
        IF p_asms_id = '0' THEN
            RETURN QUERY
            SELECT MAX(mstd."AMST_Id")::BIGINT AS "AMST_Id",
                   MAX(CASE WHEN mstd."AMST_FirstName" IS NULL OR mstd."AMST_FirstName" = '' THEN '' ELSE mstd."AMST_FirstName" END ||
                   CASE WHEN mstd."AMST_MiddleName" IS NULL OR mstd."AMST_MiddleName" = '' OR mstd."AMST_MiddleName" = '0' THEN '' ELSE ' ' || mstd."AMST_MiddleName" END ||
                   CASE WHEN mstd."AMST_LastName" IS NULL OR mstd."AMST_LastName" = '' OR mstd."AMST_LastName" = '0' THEN '' ELSE ' ' || mstd."AMST_LastName" END) AS "studentname",
                   MAX(mstd."AMST_AdmNo") AS "AMST_AdmNo",
                   MAX(ystd."AMAY_RollNo")::BIGINT AS "AMAY_RollNo",
                   NULL::TEXT AS "AMST_Sex",
                   MAX(mstd."amsT_RegistrationNo") AS "amsT_RegistrationNo"
            FROM "Adm_M_Student" mstd
            LEFT JOIN "Adm_School_Y_Student" ystd ON ystd."AMST_Id" = mstd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch_Students" a ON a."AMST_Id" = ystd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch" b ON b."ASASB_Id" = a."ASASB_Id"
            WHERE ystd."ASMAY_Id" = p_yearid AND ystd."ASMCL_Id" = p_asmcl_id AND mstd."AMST_ActiveFlag" = 1 
                  AND mstd."MI_Id" = p_miid AND mstd."AMST_SOL" = v_flag AND mstd."AMST_Date" <= CURRENT_TIMESTAMP 
                  AND ystd."AMAY_ActiveFlag" = 1 AND b."ASMAY_Id" = p_yearid AND b."ASMCL_Id" = p_asmcl_id 
                  AND b."ASMS_Id" = p_asms_id AND b."ASASB_Id" = p_asab_id
            GROUP BY mstd."AMST_Id", ystd."AMAY_RollNo"
            ORDER BY ystd."AMAY_RollNo";
        ELSE
            RETURN QUERY
            SELECT MAX(mstd."AMST_Id")::BIGINT AS "AMST_Id",
                   MAX(CASE WHEN mstd."AMST_FirstName" IS NULL OR mstd."AMST_FirstName" = '' THEN '' ELSE mstd."AMST_FirstName" END ||
                   CASE WHEN mstd."AMST_MiddleName" IS NULL OR mstd."AMST_MiddleName" = '' OR mstd."AMST_MiddleName" = '0' THEN '' ELSE ' ' || mstd."AMST_MiddleName" END ||
                   CASE WHEN mstd."AMST_LastName" IS NULL OR mstd."AMST_LastName" = '' OR mstd."AMST_LastName" = '0' THEN '' ELSE ' ' || mstd."AMST_LastName" END) AS "studentname",
                   MAX(mstd."AMST_AdmNo") AS "AMST_AdmNo",
                   MAX(ystd."AMAY_RollNo")::BIGINT AS "AMAY_RollNo",
                   NULL::TEXT AS "AMST_Sex",
                   MAX(mstd."amsT_RegistrationNo") AS "amsT_RegistrationNo"
            FROM "Adm_M_Student" mstd
            LEFT JOIN "Adm_School_Y_Student" ystd ON ystd."AMST_Id" = mstd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch_Students" a ON a."AMST_Id" = ystd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch" b ON b."ASASB_Id" = a."ASASB_Id"
            WHERE ystd."ASMAY_Id" = p_yearid AND ystd."ASMCL_Id" = p_asmcl_id AND ystd."ASMS_Id" = p_asms_id 
                  AND mstd."AMST_ActiveFlag" = 1 AND mstd."MI_Id" = p_miid AND mstd."AMST_SOL" = v_flag 
                  AND mstd."AMST_Date" <= CURRENT_TIMESTAMP AND ystd."AMAY_ActiveFlag" = 1 AND b."ASMAY_Id" = p_yearid 
                  AND b."ASMCL_Id" = p_asmcl_id AND b."ASMS_Id" = p_asms_id AND b."ASASB_Id" = p_asab_id
            GROUP BY mstd."AMST_Id", ystd."AMAY_RollNo"
            ORDER BY ystd."AMAY_RollNo";
        END IF;

    ELSIF p_id = '4' THEN  -- for name asc
        IF p_asms_id = '0' THEN
            RETURN QUERY
            SELECT MAX(mstd."AMST_Id")::BIGINT AS "AMST_Id",
                   MAX(CASE WHEN mstd."AMST_FirstName" IS NULL OR mstd."AMST_FirstName" = '' THEN '' ELSE mstd."AMST_FirstName" END ||
                   CASE WHEN mstd."AMST_MiddleName" IS NULL OR mstd."AMST_MiddleName" = '' OR mstd."AMST_MiddleName" = '0' THEN '' ELSE ' ' || mstd."AMST_MiddleName" END ||
                   CASE WHEN mstd."AMST_LastName" IS NULL OR mstd."AMST_LastName" = '' OR mstd."AMST_LastName" = '0' THEN '' ELSE ' ' || mstd."AMST_LastName" END) AS "studentname",
                   MAX(mstd."AMST_AdmNo") AS "AMST_AdmNo",
                   MAX(ystd."AMAY_RollNo")::BIGINT AS "AMAY_RollNo",
                   NULL::TEXT AS "AMST_Sex",
                   MAX(mstd."amsT_RegistrationNo") AS "amsT_RegistrationNo"
            FROM "Adm_M_Student" mstd
            LEFT JOIN "Adm_School_Y_Student" ystd ON ystd."AMST_Id" = mstd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch_Students" a ON a."AMST_Id" = ystd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch" b ON b."ASASB_Id" = a."ASASB_Id"
            WHERE ystd."ASMAY_Id" = p_yearid AND ystd."ASMCL_Id" = p_asmcl_id AND mstd."AMST_ActiveFlag" = 1 
                  AND mstd."MI_Id" = p_miid AND mstd."AMST_SOL" = v_flag AND mstd."AMST_Date" <= CURRENT_TIMESTAMP 
                  AND ystd."AMAY_ActiveFlag" = 1 AND b."ASMAY_Id" = p_yearid AND b."ASMCL_Id" = p_asmcl_id 
                  AND b."ASMS_Id" = p_asms_id AND b."ASASB_Id" = p_asab_id
            GROUP BY mstd."AMST_Id"
            ORDER BY "studentname" ASC;
        ELSE
            RETURN QUERY
            SELECT MAX(mstd."AMST_Id")::BIGINT AS "AMST_Id",
                   MAX(CASE WHEN mstd."AMST_FirstName" IS NULL OR mstd."AMST_FirstName" = '' THEN '' ELSE mstd."AMST_FirstName" END ||
                   CASE WHEN mstd."AMST_MiddleName" IS NULL OR mstd."AMST_MiddleName" = '' OR mstd."AMST_MiddleName" = '0' THEN '' ELSE ' ' || mstd."AMST_MiddleName" END ||
                   CASE WHEN mstd."AMST_LastName" IS NULL OR mstd."AMST_LastName" = '' OR mstd."AMST_LastName" = '0' THEN '' ELSE ' ' || mstd."AMST_LastName" END) AS "studentname",
                   MAX(mstd."AMST_AdmNo") AS "AMST_AdmNo",
                   MAX(ystd."AMAY_RollNo")::BIGINT AS "AMAY_RollNo",
                   NULL::TEXT AS "AMST_Sex",
                   MAX(mstd."amsT_RegistrationNo") AS "amsT_RegistrationNo"
            FROM "Adm_M_Student" mstd
            LEFT JOIN "Adm_School_Y_Student" ystd ON ystd."AMST_Id" = mstd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch_Students" a ON a."AMST_Id" = ystd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch" b ON b."ASASB_Id" = a."ASASB_Id"
            WHERE ystd."ASMAY_Id" = p_yearid AND ystd."ASMCL_Id" = p_asmcl_id AND ystd."ASMS_Id" = p_asms_id 
                  AND mstd."AMST_ActiveFlag" = 1 AND mstd."MI_Id" = p_miid AND mstd."AMST_SOL" = v_flag 
                  AND mstd."AMST_Date" <= CURRENT_TIMESTAMP AND ystd."AMAY_ActiveFlag" = 1 AND b."ASMAY_Id" = p_yearid 
                  AND b."ASMCL_Id" = p_asmcl_id AND b."ASMS_Id" = p_asms_id AND b."ASASB_Id" = p_asab_id
            GROUP BY mstd."AMST_Id"
            ORDER BY "studentname" ASC;
        END IF;

    ELSIF p_id = '5' THEN  -- for name desc
        IF p_asms_id = '0' THEN
            RETURN QUERY
            SELECT MAX(mstd."AMST_Id")::BIGINT AS "AMST_Id",
                   MAX(CASE WHEN mstd."AMST_FirstName" IS NULL OR mstd."AMST_FirstName" = '' THEN '' ELSE mstd."AMST_FirstName" END ||
                   CASE WHEN mstd."AMST_MiddleName" IS NULL OR mstd."AMST_MiddleName" = '' OR mstd."AMST_MiddleName" = '0' THEN '' ELSE ' ' || mstd."AMST_MiddleName" END ||
                   CASE WHEN mstd."AMST_LastName" IS NULL OR mstd."AMST_LastName" = '' OR mstd."AMST_LastName" = '0' THEN '' ELSE ' ' || mstd."AMST_LastName" END) AS "studentname",
                   MAX(mstd."AMST_AdmNo") AS "AMST_AdmNo",
                   MAX(ystd."AMAY_RollNo")::BIGINT AS "AMAY_RollNo",
                   NULL::TEXT AS "AMST_Sex",
                   MAX(mstd."amsT_RegistrationNo") AS "amsT_RegistrationNo"
            FROM "Adm_M_Student" mstd
            LEFT JOIN "Adm_School_Y_Student" ystd ON ystd."AMST_Id" = mstd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch_Students" a ON a."AMST_Id" = ystd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch" b ON b."ASASB_Id" = a."ASASB_Id"
            WHERE ystd."ASMAY_Id" = p_yearid AND ystd."ASMCL_Id" = p_asmcl_id AND mstd."AMST_ActiveFlag" = 1 
                  AND mstd."MI_Id" = p_miid AND mstd."AMST_SOL" = v_flag AND mstd."AMST_Date" <= CURRENT_TIMESTAMP 
                  AND ystd."AMAY_ActiveFlag" = 1 AND b."ASMAY_Id" = p_yearid AND b."ASMCL_Id" = p_asmcl_id 
                  AND b."ASMS_Id" = p_asms_id AND b."ASASB_Id" = p_asab_id
            GROUP BY mstd."AMST_Id"
            ORDER BY "studentname" DESC;
        ELSE
            RETURN QUERY
            SELECT MAX(mstd."AMST_Id")::BIGINT AS "AMST_Id",
                   MAX(CASE WHEN mstd."AMST_FirstName" IS NULL OR mstd."AMST_FirstName" = '' THEN '' ELSE mstd."AMST_FirstName" END ||
                   CASE WHEN mstd."AMST_MiddleName" IS NULL OR mstd."AMST_MiddleName" = '' OR mstd."AMST_MiddleName" = '0' THEN '' ELSE ' ' || mstd."AMST_MiddleName" END ||
                   CASE WHEN mstd."AMST_LastName" IS NULL OR mstd."AMST_LastName" = '' OR mstd."AMST_LastName" = '0' THEN '' ELSE ' ' || mstd."AMST_LastName" END) AS "studentname",
                   MAX(mstd."AMST_AdmNo") AS "AMST_AdmNo",
                   MAX(ystd."AMAY_RollNo")::BIGINT AS "AMAY_RollNo",
                   NULL::TEXT AS "AMST_Sex",
                   MAX(mstd."amsT_RegistrationNo") AS "amsT_RegistrationNo"
            FROM "Adm_M_Student" mstd
            LEFT JOIN "Adm_School_Y_Student" ystd ON ystd."AMST_Id" = mstd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch_Students" a ON a."AMST_Id" = ystd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch" b ON b."ASASB_Id" = a."ASASB_Id"
            WHERE ystd."ASMAY_Id" = p_yearid AND ystd."ASMCL_Id" = p_asmcl_id AND ystd."ASMS_Id" = p_asms_id 
                  AND mstd."AMST_ActiveFlag" = 1 AND mstd."MI_Id" = p_miid AND mstd."AMST_SOL" = v_flag 
                  AND mstd."AMST_Date" <= CURRENT_TIMESTAMP AND ystd."AMAY_ActiveFlag" = 1 AND b."ASMAY_Id" = p_yearid 
                  AND b."ASMCL_Id" = p_asmcl_id AND b."ASMS_Id" = p_asms_id AND b."ASASB_Id" = p_asab_id
            GROUP BY mstd."AMST_Id"
            ORDER BY "studentname" DESC;
        END IF;

    ELSIF p_id = '6' THEN  -- for regno
        IF p_asms_id = '0' THEN
            RETURN QUERY
            SELECT MAX(mstd."AMST_Id")::BIGINT AS "AMST_Id",
                   MAX(CASE WHEN mstd."AMST_FirstName" IS NULL OR mstd."AMST_FirstName" = '' THEN '' ELSE mstd."AMST_FirstName" END ||
                   CASE WHEN mstd."AMST_MiddleName" IS NULL OR mstd."AMST_MiddleName" = '' OR mstd."AMST_MiddleName" = '0' THEN '' ELSE ' ' || mstd."AMST_MiddleName" END ||
                   CASE WHEN mstd."AMST_LastName" IS NULL OR mstd."AMST_LastName" = '' OR mstd."AMST_LastName" = '0' THEN '' ELSE ' ' || mstd."AMST_LastName" END) AS "studentname",
                   MAX(mstd."AMST_AdmNo") AS "AMST_AdmNo",
                   MAX(ystd."AMAY_RollNo")::BIGINT AS "AMAY_RollNo",
                   NULL::TEXT AS "AMST_Sex",
                   mstd."amsT_RegistrationNo" AS "amsT_RegistrationNo"
            FROM "Adm_M_Student" mstd
            LEFT JOIN "Adm_School_Y_Student" ystd ON ystd."AMST_Id" = mstd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch_Students" a ON a."AMST_Id" = ystd."AMST_Id"
            INNER JOIN "Adm_School_Attendance_Subject_Batch" b ON b."ASASB_Id" = a."ASASB_Id"
            WHERE ystd."ASMAY_Id" = p_yearid AND ystd."ASMC