CREATE OR REPLACE FUNCTION "dbo"."Get_master_institution_proc"(
    p_MI_Id bigint,
    p_userid bigint
)
RETURNS TABLE(
    "MI_Id" bigint,
    "MI_Name" varchar
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_rolid bigint;
    v_rolname varchar;
    v_MO_Id bigint;
BEGIN
    SELECT "RoleId" INTO v_rolid 
    FROM "ApplicationUserRole" 
    WHERE "UserId" = p_userid;
    
    SELECT "Name" INTO v_rolname 
    FROM "ApplicationRole" 
    WHERE "id" = v_rolid;
    
    SELECT "MO_Id" INTO v_MO_Id 
    FROM "Master_Institution" 
    WHERE "MI_Id" = p_MI_Id;

    IF v_rolname = 'Staff' OR v_rolname = 'staff' THEN
        RETURN QUERY
        SELECT DISTINCT "Master_Institution"."MI_Id", "Master_Institution"."MI_Name" 
        FROM "Master_Institution" 
        INNER JOIN "IVRM_User_Login_Institutionwise" ON 
            "Master_Institution"."mi_id" = "IVRM_User_Login_Institutionwise"."mi_id"
        WHERE "IVRM_User_Login_Institutionwise"."id" = p_userid 
            AND "IVRM_User_Login_Institutionwise"."Activeflag" = 1 
            AND "Master_Institution"."MI_ActiveFlag" = 1 
        ORDER BY "Master_Institution"."MI_Name";
    ELSE
        RETURN QUERY
        SELECT DISTINCT "Master_Institution"."MI_Id", "Master_Institution"."MI_Name" 
        FROM "Master_Institution" 
        INNER JOIN "IVRM_User_Login_Institutionwise" ON 
            "Master_Institution"."mi_id" = "IVRM_User_Login_Institutionwise"."mi_id"
        WHERE "IVRM_User_Login_Institutionwise"."Activeflag" = 1 
            AND "Master_Institution"."MI_ActiveFlag" = 1 
        ORDER BY "Master_Institution"."MI_Name";
    END IF;
END;
$$;