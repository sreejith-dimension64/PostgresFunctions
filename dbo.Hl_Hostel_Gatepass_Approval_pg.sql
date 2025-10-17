CREATE OR REPLACE FUNCTION "Hl_Hostel_Gatepass_Approval"(
    "CameBackDate" VARCHAR(300),
    "ComingBackTime" VARCHAR(300)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "AMCST_Id" BIGINT;
    "Totaldays" BIGINT;
    "HLHSTGP_Id" BIGINT;
    "count" BIGINT;
    "HLHSTGPAPP_Id" BIGINT;
    "Id" BIGINT;
    "HLHSTGPAPP_Remarks" TEXT;
    "userid" BIGINT;
    "HLHSTGP_GoingOutDate" TIMESTAMP;
    "HLHSTGP_ComingBackDate" TIMESTAMP;
    "HLHSTGP_GoingOutTime" VARCHAR(300);
    "HLHSTGP_CameBackTime" VARCHAR(300);
BEGIN

    SELECT EXTRACT(DAY FROM ("HLHSTGP_ComingBackDate" - "HLHSTGP_GoingOutDate"))
    INTO "Totaldays"
    FROM "HL_Hostel_Student_Gatepass"
    WHERE "AMCST_Id" = "AMCST_Id";

    INSERT INTO "HL_Hostel_Student_Gatepass_Approval"(
        "HLHSTGPAPP_Id",
        "HLHSTGP_Id",
        "Id",
        "HLHSTGPAPP_Remarks",
        "HLHSTGPAPP_ActiveFlg",
        "HLHSTGPAPP_CreatedBy",
        "HLHSTGPAPP_UpdatedBy",
        "HLHSTGPAPP_CreatedDate",
        "HLHSTGPAPP_UpdatedDate"
    )
    VALUES (
        "HLHSTGPAPP_Id",
        "HLHSTGP_Id",
        "Id",
        'Approved',
        1,
        "userid",
        "userid",
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    );

    IF ("count" > 0) THEN

        UPDATE "HL_Hostel_Student_Gatepass"
        SET "HLHSTGP_ComingBackDate" = "HLHSTGP_ComingBackDate",
            "HLHSTGP_CameBackTime" = "HLHSTGP_CameBackTime",
            "HLHSTGP_TotalDays" = "Totaldays"
        WHERE "HLHSTGP_Id" = "HLHSTGP_Id";

    END IF;

END;
$$;