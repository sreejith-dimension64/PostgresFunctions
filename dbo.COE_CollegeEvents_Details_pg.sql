CREATE OR REPLACE FUNCTION "dbo"."COE_CollegeEvents_Details"(
    "MI_Id" bigint,
    "ASMAY_Id" bigint,
    "AMCST_Id" bigint,
    "Typeflg" text
)
RETURNS TABLE(
    "COEME_Id" bigint,
    "COEME_EventName" text,
    "COEME_EventDesc" text,
    "COEE_EStartDate" timestamp,
    "COEE_EEndDate" timestamp,
    "COEE_ReminderDate" timestamp,
    "ASMAY_Id" bigint
)
LANGUAGE plpgsql
AS $$
BEGIN

    IF("Typeflg" = 'Monthwise') THEN
    
        RETURN QUERY
        SELECT DISTINCT m."COEME_Id", m."COEME_EventName", m."COEME_EventDesc", n."COEE_EStartDate", n."COEE_EEndDate", n."COEE_ReminderDate", o."ASMAY_Id"
        FROM "coe"."COE_Master_Events" m 
        INNER JOIN "coe"."COE_Events" n ON m."COEME_Id" = n."COEME_Id"
        INNER JOIN "COE_Events_CourseBranch" y ON y."COEE_Id" = n."COEE_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" o ON o."AMCO_Id" = y."AMCO_Id" AND o."AMB_Id" = y."AMB_Id" AND EXTRACT(MONTH FROM n."COEE_EStartDate") = EXTRACT(MONTH FROM CURRENT_TIMESTAMP)
        WHERE n."MI_Id" = "MI_Id" AND o."ASMAY_Id" = "ASMAY_Id" AND o."AMCST_Id" = "AMCST_Id"
        ORDER BY "COEME_Id";
    
    ELSIF("Typeflg" = 'Yearwise') THEN
    
        RETURN QUERY
        SELECT DISTINCT m."COEME_Id", m."COEME_EventName", m."COEME_EventDesc", n."COEE_EStartDate", n."COEE_EEndDate", n."COEE_ReminderDate", o."ASMAY_Id"
        FROM "coe"."COE_Master_Events" m 
        INNER JOIN "coe"."COE_Events" n ON m."COEME_Id" = n."COEME_Id"
        INNER JOIN "COE_Events_CourseBranch" y ON y."COEE_Id" = n."COEE_Id"
        INNER JOIN "clg"."Adm_College_Yearly_Student" o ON o."AMCO_Id" = y."AMCO_Id" AND o."AMB_Id" = y."AMB_Id"
        WHERE n."MI_Id" = "MI_Id" AND o."ASMAY_Id" = "ASMAY_Id" AND o."AMCST_Id" = "AMCST_Id"
        ORDER BY "COEE_EStartDate" DESC;
    
    END IF;

END;
$$;