CREATE OR REPLACE FUNCTION "dbo"."ISM_TaskCreation_AutoGenerateNo"(
    "p_MI_Id" bigint,
    "p_ASMAY_Id" bigint,
    OUT "p_TaskGenNo" varchar(500)
)
RETURNS varchar(500)
LANGUAGE plpgsql
AS $$
DECLARE
    "v_Prefixname" varchar(150);
    "v_Suffixname" varchar(150);
    "v_Rowcount" bigint;
    "v_TaskNo" bigint;
    "v_K" int;
BEGIN
    "v_Prefixname" := 'TASK';
    "v_TaskNo" := 0;

    SELECT count(*) INTO "v_Rowcount" 
    FROM "ISM_TaskCreation" 
    WHERE "MI_Id" = "p_MI_Id";

    SELECT "ASMAY_Year" INTO "v_Suffixname" 
    FROM "Adm_School_M_Academic_Year" 
    WHERE "MI_Id" = "p_MI_Id" AND "ASMAY_Id" = "p_ASMAY_Id";

    IF ("v_Rowcount" > 0) THEN
        SELECT MAX(CAST(REPLACE(REPLACE(REVERSE(SUBSTRING(REVERSE("ISMTCR_TaskNo"), 
            POSITION('/' IN REVERSE("ISMTCR_TaskNo")) + 1, 
            LENGTH("ISMTCR_TaskNo"))), "v_Prefixname", ''), '/', '') AS bigint)) 
        INTO "v_TaskNo"
        FROM "ISM_TaskCreation" 
        WHERE "MI_Id" = "p_MI_Id";

        "v_K" := COALESCE("v_TaskNo", 0) + 1;
    ELSE
        "v_K" := 100;
    END IF;

    "p_TaskGenNo" := "v_Prefixname" || '/' || CAST("v_K" AS varchar(20)) || '/' || "v_Suffixname";

    RAISE NOTICE '%', "p_TaskGenNo";

    RETURN;
END;
$$;