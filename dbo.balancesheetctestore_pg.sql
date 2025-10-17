CREATE OR REPLACE FUNCTION balancesheetctestore (p_FAMGRP_Id bigint)
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    DROP TABLE IF EXISTS "Balancesheetlastlevel12";

    CREATE TABLE "Balancesheetlastlevel12" AS
    WITH RECURSIVE "MyCTE" AS
    (
        SELECT *
        FROM "Balancesheettemp"
        WHERE "FAMGRP_Id" = 49

        UNION ALL
        
        SELECT t2.*
        FROM "Balancesheettemp" AS t2
        INNER JOIN "MyCTE" AS M ON t2."FAMGRP_ParentId" = M."FAMGRP_Id"
    )
    SELECT * FROM "MyCTE";

END;
$$;