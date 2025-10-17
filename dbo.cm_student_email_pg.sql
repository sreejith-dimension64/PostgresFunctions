CREATE OR REPLACE FUNCTION cm_student_email(p_UserId bigint)
RETURNS TABLE (
    "id" bigint,
    "UserName" varchar,
    "NormalizedUserName" varchar,
    "Email" varchar,
    "NormalizedEmail" varchar,
    "EmailConfirmed" boolean,
    "PasswordHash" text,
    "SecurityStamp" text,
    "ConcurrencyStamp" text,
    "PhoneNumber" varchar,
    "PhoneNumberConfirmed" boolean,
    "TwoFactorEnabled" boolean,
    "LockoutEnd" timestamp,
    "LockoutEnabled" boolean,
    "AccessFailedCount" integer
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM "ApplicationUser" WHERE "id" = p_UserId;
END;
$$;