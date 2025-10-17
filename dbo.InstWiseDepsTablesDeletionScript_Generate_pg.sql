CREATE OR REPLACE FUNCTION "dbo"."InstWiseDepsTablesDeletionScript_Generate"(@MI_Id varchar(20))
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    @TbName varchar;
    @where varchar;
    @sqlcmd varchar := '';
    @crlf char(2) := chr(13) || chr(10);
    @child varchar(256);
    @parent varchar(256);
    @lvl int;
    @id int;
    @i int;
    @fk_object_id int;
    @TCRcount int;
    @child_col varchar;
    @parent_col varchar;
    @rnk int;
    @fetch_status int;
    rec_fk RECORD;
    rec_t RECORD;
    rec_c RECORD;
    rec_tables RECORD;
    rec_tmp RECORD;
    @t_table TEXT;

BEGIN

    DROP TABLE IF EXISTS "temp_tmp";
    DROP TABLE IF EXISTS "temp_t";

    CREATE TEMP TABLE "temp_tmp"("id" int, "tablename" varchar(256), "lvl" int, "ParentTable" varchar(256));
    CREATE TEMP TABLE "temp_t"("tablename" varchar(128));

    @where := 'WHERE ' || '"Master_Institution"."MI_Id"=' || @MI_Id || ' ';

    FOR rec_tables IN 
        SELECT DISTINCT "table_schema" || '.' || "table_name" AS "TableName" 
        FROM "information_schema"."tables" 
        WHERE "table_type" = 'BASE TABLE' 
        AND "table_schema" || '.' || "table_name" = 'dbo.Master_Institution'
    LOOP
        @TbName := rec_tables."TableName";

        INSERT INTO "temp_tmp" 
        SELECT * FROM "dbo"."USP_SearchFK"(@TbName, 1);

        IF COALESCE(@where, '') = '' THEN
            FOR rec_t IN 
                SELECT DISTINCT "tablename", "lvl" 
                FROM "temp_tmp" 
                ORDER BY "lvl" DESC
            LOOP
                @child := rec_t."tablename";
                @lvl := rec_t."lvl";

                @TCRcount := 0;
                SELECT COUNT(*) INTO @TCRcount FROM "temp_t" WHERE "tablename" = @child;

                IF @TCRcount = 0 THEN
                    INSERT INTO "temp_t" ("tablename") VALUES (@child);
                END IF;
            END LOOP;

        ELSE

            FOR rec_t IN 
                SELECT DISTINCT "lvl", "id" 
                FROM "temp_tmp" 
                ORDER BY "lvl" DESC
            LOOP
                @lvl := rec_t."lvl";
                @id := rec_t."id";
                @i := 0;

                IF @lvl = 0 THEN
                    SELECT 'DELETE FROM ' || "tablename" INTO @sqlcmd 
                    FROM "temp_tmp" 
                    WHERE "id" = @id;
                END IF;

                WHILE @i < @lvl LOOP

                    SELECT "tablename", "ParentTable" INTO @child, @parent
                    FROM "temp_tmp" 
                    WHERE "id" <= @id - @i AND "lvl" <= @lvl - @i 
                    ORDER BY "lvl" DESC, "id" DESC 
                    LIMIT 1;

                    FOR rec_fk IN 
                        SELECT DISTINCT "conindid" AS "fk_object_id"
                        FROM "pg_constraint" c
                        INNER JOIN "pg_class" pc ON c."conrelid" = pc."oid"
                        INNER JOIN "pg_class" pf ON c."confrelid" = pf."oid"
                        INNER JOIN "pg_namespace" ns ON pc."relnamespace" = ns."oid"
                        INNER JOIN "pg_namespace" nsf ON pf."relnamespace" = nsf."oid"
                        WHERE ns."nspname" || '.' || pc."relname" = @child
                        AND nsf."nspname" || '.' || pf."relname" = @parent
                        AND c."contype" = 'f'
                    LOOP
                        @fk_object_id := rec_fk."fk_object_id";

                        IF @i = 0 THEN
                            @sqlcmd := 'DELETE FROM ' || @child || ' A' || @crlf || 'INNER JOIN ' || @parent;
                        ELSE
                            @sqlcmd := @sqlcmd || @crlf || 'INNER JOIN ' || @parent;
                        END IF;

                        @rnk := 0;
                        FOR rec_c IN
                            WITH "C" AS (
                                SELECT DISTINCT 
                                    ns."nspname" || '.' || pc."relname" AS "child",
                                    pa."attname" AS "child_col",
                                    nsf."nspname" || '.' || pf."relname" AS "parent",
                                    fa."attname" AS "parent_col",
                                    ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS "rnk"
                                FROM "pg_constraint" c
                                INNER JOIN "pg_class" pc ON c."conrelid" = pc."oid"
                                INNER JOIN "pg_class" pf ON c."confrelid" = pf."oid"
                                INNER JOIN "pg_namespace" ns ON pc."relnamespace" = ns."oid"
                                INNER JOIN "pg_namespace" nsf ON pf."relnamespace" = nsf."oid"
                                INNER JOIN "pg_attribute" pa ON pa."attrelid" = pc."oid" AND pa."attnum" = ANY(c."conkey")
                                INNER JOIN "pg_attribute" fa ON fa."attrelid" = pf."oid" AND fa."attnum" = ANY(c."confkey")
                                WHERE c."conindid" = @fk_object_id
                            )
                            SELECT * FROM "C"
                        LOOP
                            @sqlcmd := @sqlcmd || CASE WHEN rec_c."rnk" = 1 THEN ' ON ' ELSE ' and ' END || 
                                       @child || '.' || rec_c."child_col" || '=' || @parent || '.' || rec_c."parent_col";
                        END LOOP;

                    END LOOP;

                    @i := @i + 1;
                END LOOP;

                RAISE NOTICE '%', @sqlcmd || @crlf || @where || ';';
                RAISE NOTICE '';

            END LOOP;

        END IF;

    END LOOP;

    DROP TABLE IF EXISTS "temp_tmp";
    DROP TABLE IF EXISTS "temp_t";

    RETURN;
END;
$$;