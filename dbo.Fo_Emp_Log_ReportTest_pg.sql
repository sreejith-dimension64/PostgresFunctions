CREATE OR REPLACE FUNCTION "dbo"."Fo_Emp_Log_ReportTest"(
    "date" VARCHAR(10),
    "month" VARCHAR(2),
    "year" VARCHAR(4),
    "fromdate" VARCHAR(10),
    "todate" VARCHAR(10),
    "miid" BIGINT,
    "multiplehrmeid" VARCHAR(2000),
    "punchtype" VARCHAR(10)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    "content" VARCHAR(500);
    "content1" VARCHAR(500);
    "cchrme" VARCHAR(500);
    "query" TEXT;
    "dynamic" TEXT;
    "content_LE" TEXT;
BEGIN
    PERFORM "dbo"."Fo_Emp_Log_ReportTest"('','','','2018-08-01','2018-08-25',6,'16,17,19,70,71,72,73,74,75,76,78,79,80,81,82,84,85,86,87,88,89,91,92,93,94,95,96,98,164,165,166,167,171,172,174,175,176,177,178,179,180,181,183,184,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,208,209,213,259,387,414,432,435,436,440,441,443,444,445,446,449,450,451,452,455,456,457,459,460,461,463,464,465,466,467,468,470,490,492,493,494,495,497,673,743,745,748,750,756,757,759,760,761,763,765,766,768,769,771,773,774,776,777,779,781,782,783,785,786,788,789,790,792,793,795,798,799,800,801,810,811,813,814,816,818,820,821,823,824,826,827,829,832,834,835,836,837,838,839,840,841,842,843,844,845,846,847,848,849,850,851,852,853,854,855,856,857,858,860,861,862,863,864,865,866,867,868,869,870,871,872,873,875,876,877,878,879,880,881,882,883,884,885,886,887,888,890,891,892,893,894,915,1140,1165,1166,1167,1168,1169,1170,1172,1175,1176,1177,1178,1179,1182,1183,1184,1187,1188,1189,1190,1193,1194,1195,1196,1197,1198,1199,1200,1201,1202,1210,1249,1250,1251,1252,1253,1254,1255,1256,1263,1286,1288,1289,1290,1291,1302,1304,1314,1320','late');
    
    PERFORM "dbo"."Fo_Emp_Log_ReportTest"('','','','2018-03-01','2018-03-30',4,'7,9,10,20,21,22,23,24,25,26,27,28,29,30,31,33,34,35,36,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,56,57,58,59,60,61,62,63,64,65,66,67,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,258,260,261,262,263,264,265,266,267,268,270,271,272,273,274,275,276,277,278,279,280,281,282,283,288,289,290,291,294,297,298,299,302,303,304,305,306,307,308,309,310,311,313,314,315,317,319,320,322,323,324,325,326,327,328,329,330,331,332,333,334,335,336,337,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,357,358,359,360,361,362,364,365,366,367,370,371,372,399,403,409,410,411,412,431,434,471,472,473,474,475,477,478,479,481,482,483,484,485,486,487,534,537,538,539,540,541,542,543,544,545,546,547,548,549,550,551,552,553,554,555,556,557,558,559,560,561,562,563,564,565,566,567,568,569,570,571,572,573,574,575,576,577,578,579,580,581,582,583,584,585,586,587,588,589,590,591,592,593,594,595,596,597,598,599,600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,636,637,638,639,640,641,642,643,644,645,646,647,648,649,650,651,652,653,654,655,656,657,658,659,660,661,662,663,664,665,666,667,668,669,670,671,672,674,675,676,677,678,679,680,681,682,683,684,685,686,687,688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,705,711,714,716,720,725,730,735,738,747,751,764,775,784,787,803,817,819,822,828,830,833,1134,1139,1141,1142,1143,1144,1145,1146,1147,1148,1149,1150,1151,1153,1154,1155,1156,1157,1158,1159,1160,1161,1162,1163,1203,1204,1205,1207,1208,1209,1215,1216,1217,1218,1219,1220,1221,1222,1223,1224,1234,1257,1258,1260,1261,1262,1271,1272,1274,1283,1294,1295,1296,1297,1298,1299,1302,1303,1304,1305,1306,1307,1308,1310','LIEO');
    
    PERFORM "dbo"."Fo_Emp_Log_ReportTest"('','','','2018-03-01','2018-03-30',4,'7,9,10,20,21,22,23,24,25,26,27,28,29,30,31,33,34,35,36,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,56,57,58,59,60,61,62,63,64,65,66,67,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,258,260,261,262,263,264,265,266,267,268,270,271,272,273,274,275,276,277,278,279,280,281,282,283,288,289,290,291,294,297,298,299,302,303,304,305,306,307,308,309,310,311,313,314,315,317,319,320,322,323,324,325,326,327,328,329,330,331,332,333,334,335,336,337,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,357,358,359,360,361,362,364,365,366,367,370,371,372,399,403,409,410,411,412,431,434,471,472,473,474,475,477,478,479,481,482,483,484,485,486,487,534,537,538,539,540,541,542,543,544,545,546,547,548,549,550,551,552,553,554,555,556,557,558,559,560,561,562,563,564,565,566,567,568,569,570,571,572,573,574,575,576,577,578,579,580,581,582,583,584,585,586,587,588,589,590,591,592,593,594,595,596,597,598,599,600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,636,637,638,639,640,641,642,643,644,645,646,647,648,649,650,651,652,653,654,655,656,657,658,659,660,661,662,663,664,665,666,667,668,669,670,671,672,674,675,676,677,678,679,680,681,682,683,684,685,686,687,688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,705,711,714,716,720,725,730,735,738,747,751,764,775,784,787,803,817,819,822,828,830,833,1134,1139,1141,1142,1143,1144,1145,1146,1147,1148,1149,1150,1151,1153,1154,1155,1156,1157,1158,1159,1160,1161,1162,1163,1203,1204,1205,1207,1208,1209,1215,1216,1217,1218,1219,1220,1221,1222,1223,1224,1234,1257,1258,1260,1261,1262,1271,1272,1274,1283,1294,1295,1296,1297,1298,1299,1302,1303,1304,1305,1306,1307,1308,1310','early');
    
    PERFORM "dbo"."Fo_Emp_Log_ReportTest"('','','','2018-03-01','2018-03-30',4,'7,9,10,20,21,22,23,24,25,26,27,28,29,30,31,33,34,35,36,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,56,57,58,59,60,61,62,63,64,65,66,67,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,258,260,261,262,263,264,265,266,267,268,270,271,272,273,274,275,276,277,278,279,280,281,282,283,288,289,290,291,294,297,298,299,302,303,304,305,306,307,308,309,310,311,313,314,315,317,319,320,322,323,324,325,326,327,328,329,330,331,332,333,334,335,336,337,340,341,342,343,344,345,346,347,348,349,350,351,352,353,354,357,358,359,360,361,362,364,365,366,367,370,371,372,399,403,409,410,411,412,431,434,471,472,473,474,475,477,478,479,481,482,483,484,485,486,487,534,537,538,539,540,541,542,543,544,545,546,547,548,549,550,551,552,553,554,555,556,557,558,559,560,561,562,563,564,565,566,567,568,569,570,571,572,573,574,575,576,577,578,579,580,581,582,583,584,585,586,587,588,589,590,591,592,593,594,595,596,597,598,599,600,601,602,603,604,605,606,607,608,609,610,611,612,613,614,615,616,617,618,619,620,621,622,623,624,625,626,627,628,629,630,631,632,633,634,635,636,637,638,639,640,641,642,643,644,645,646,647,648,649,650,651,652,653,654,655,656,657,658,659,660,661,662,663,664,665,666,667,668,669,670,671,672,674,675,676,677,678,679,680,681,682,683,684,685,686,687,688,689,690,691,692,693,694,695,696,697,698,699,700,701,702,705,711,714,716,720,725,730,735,738,747,751,764,775,784,787,803,817,819,822,828,830,833,1134,1139,1141,1142,1143,1144,1145,1146,1147,1148,1149,1150,1151,1153,1154,1155,1156,1157,1158,1159,1160,1161,1162,1163,1203,1204,1205,1207,1208,1209,1215,1216,1217,1218,1219,1220,1221,1222,1223,1224,1234,1257,1258,1260,1261,1262,1271,1272,1274,1283,1294,1295,1296,1297,1298,1299,1302,1303,1304,1305,1306,1307,1308,1310','punch');

    IF "fromdate" != '' AND "todate" != '' THEN
        "content" := ' TO_CHAR("punchdate", ''YYYY-MM-DD'') BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''';
    ELSIF "month" != '' AND "year" != '' THEN
        "content" := ' EXTRACT(MONTH FROM "punchdate") = ''' || "month" || ''' AND EXTRACT(YEAR FROM "punchdate") = ''' || "year" || '''';
    ELSIF "date" != '' THEN
        "content" := ' TO_CHAR("punchdate", ''YYYY-MM-DD'') = ''' || "date" || '''';
    ELSE
        "content" := '';
    END IF;

    IF "fromdate" != '' AND "todate" != '' THEN
        "content1" := ' TO_CHAR("FOEP_PunchDate", ''YYYY-MM-DD'') BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''';
    ELSIF "month" != '' AND "year" != '' THEN
        "content1" := ' EXTRACT(MONTH FROM "FOEP_PunchDate") = ''' || "month" || ''' AND EXTRACT(YEAR FROM "FOEP_PunchDate") = ''' || "year" || '''';
    ELSIF "date" != '' THEN
        "content1" := ' TO_CHAR("FOEP_PunchDate", ''YYYY-MM-DD'') = ''' || "date" || '''';
    ELSE
        "content1" := '';
    END IF;

    IF "fromdate" != '' AND "todate" != '' THEN
        "content_LE" := ' TO_CHAR("FOEP_PunchDate", ''YYYY-MM-DD'') BETWEEN ''' || "fromdate" || ''' AND ''' || "todate" || '''';
    END IF;

    IF "punchtype" = 'punch' THEN
        "query" := 'SELECT DISTINCT Oa.*, TO_CHAR(ob."punchdate", ''DD-MM-YYYY'') AS "punchdate", ob."intime", EXTRACT(DAY FROM ob."punchdate") AS "punchday", ob."outtime", ("dbo"."getdatediff"("intime", "outtime")) AS "workingtime" ' ||
                   'FROM (SELECT a."HRME_Id", a."HRME_EmployeeCode" AS "ecode", ' ||
                   '(COALESCE(a."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(a."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(a."HRME_EmployeeLastName", '''')) AS "ename", ' ||
                   'b."HRMD_DepartmentName" AS "depname", c."HRMDES_DesignationName" AS "desgname", d."HRMGT_EmployeeGroupType" AS "gtype" ' ||
                   'FROM "HR_Master_Employee" a, "HR_Master_Department" b, "HR_Master_Designation" c, "HR_Master_GroupType" d ' ||
                   'WHERE a."HRMD_Id" = b."HRMD_Id" AND a."HRMGT_Id" = d."HRMGT_Id" AND a."HRMDES_Id" = c."HRMDES_Id" AND a."MI_Id" = ' || "miid"::VARCHAR || ' AND a."HRME_Id" IN (' || "multiplehrmeid" || ')) Oa, ' ||
                   '(SELECT p."FOEP_PunchDate" AS "punchdate", p."FOEP_PunchDate" AS "punchday", MIN(pd."FOEPD_PunchTime") AS "intime", MAX(pd1."FOEPD_PunchTime") AS "outtime", p."HRME_Id" ' ||
                   'FROM "fo"."FO_Emp_Punch" p ' ||
                   'INNER JOIN "fo"."FO_Emp_Punch_Details" pd ON p."FOEP_Id" = pd."FOEP_Id" AND pd."FOEPD_InOutFlg" = ''I'' ' ||
                   'LEFT JOIN "fo"."FO_Emp_Punch_Details" pd1 ON p."FOEP_Id" = pd1."FOEP_Id" AND pd1."FOEPD_InOutFlg" = ''O'' ' ||
                   'WHERE p."FOEP_Flag" = TRUE AND pd."FOEPD_Flag" = TRUE GROUP BY p."FOEP_PunchDate", p."HRME_Id") Ob ' ||
                   'WHERE Oa."HRME_Id" = Ob."HRME_Id" AND ' || "content" || ' ORDER BY "HRME_Id", "punchdate", "HRMGT_EmployeeGroupType"';
        
        EXECUTE "query";
        
    ELSIF "punchtype" = 'late' THEN
        "query" := 'SELECT DISTINCT c."FOHWDT_Id", f."HRME_Id", f."HRME_EmployeeCode" AS "ecode", ' ||
                   '(COALESCE(f."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(f."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(f."HRME_EmployeeLastName", '''')) AS "ename", ' ||
                   'g."HRMD_DepartmentName" AS "depname", h."HRMDES_DesignationName" AS "desgname", i."HRMGT_EmployeeGroupType" AS "gtype", ' ||
                   '(SELECT MIN(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) AS "intime", ' ||
                   'b."FOEP_Id", c."FOEST_IHalfLoginTime" AS "actualtime", c."FOEST_DelayPerShiftHrMin" AS "relaxtime", ' ||
                   '"dbo"."getdatediff"("dbo"."mintotime"(("dbo"."getonlymin"(c."FOEST_IHalfLoginTime"))), j."FOEPD_PunchTime") AS "lateby", ' ||
                   'CAST("FOEP_PunchDate" AS DATE) AS "punchdate", EXTRACT(DAY FROM "FOEP_PunchDate") AS "punchday" ' ||
                   'FROM "fo"."FO_Emp_Punch_Details" a ' ||
                   'INNER JOIN "fo"."FO_Emp_Punch" b ON a."FOEP_Id" = b."FOEP_Id" AND b."MI_Id" = ' || "miid"::VARCHAR || ' AND a."MI_Id" = ' || "miid"::VARCHAR || ' ' ||
                   'INNER JOIN "fo"."FO_Emp_Punch_Details" j ON a."FOEP_Id" = j."FOEP_Id" AND j."MI_Id" = ' || "miid"::VARCHAR || ' ' ||
                   'INNER JOIN "fo"."FO_Emp_Shifts_Timings" c ON c."HRME_Id" = b."HRME_Id" AND c."MI_Id" = ' || "miid"::VARCHAR || ' ' ||
                   'INNER JOIN "dbo"."HR_Master_Employee" f ON f."HRME_Id" = c."HRME_Id" AND f."MI_Id" = ' || "miid"::VARCHAR || ' ' ||
                   'INNER JOIN "dbo"."HR_Master_Department" g ON g."HRMD_Id" = f."HRMD_Id" AND g."MI_Id" = ' || "miid"::VARCHAR || ' ' ||
                   'INNER JOIN "dbo"."HR_Master_Designation" h ON h."HRMDES_Id" = f."HRMDES_Id" AND h."MI_Id" = ' || "miid"::VARCHAR || ' ' ||
                   'INNER JOIN "dbo"."HR_Master_GroupType" i ON i."HRMGT_Id" = f."HRMGT_Id" AND i."MI_Id" = ' || "miid"::VARCHAR || ' ' ||
                   'INNER JOIN "fo"."FO_Master_HolidayWorkingDay_Dates" d ON CAST(b."FOEP_PunchDate" AS DATE) = CAST(d."FOMHWDD_FromDate" AS DATE) AND d."MI_Id" = ' || "miid"::VARCHAR || ' ' ||
                   'WHERE (SELECT "dbo"."getonlymin"(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) > ' ||
                   '"dbo"."getonlymin"("FOEST_IHalfLoginTime") + "dbo"."getonlymin"("FOEST_DelayPerShiftHrMin") ' ||
                   'AND j."FOEPD_InOutFlg" = ''I'' AND j."FOEPD_Flag" = TRUE ' ||
                   'AND f."MI_Id" = ' || "miid"::VARCHAR || ' AND ' || "content1" || ' AND F."HRME_Id" IN (' || "multiplehrmeid" || ') AND c."FOHWDT_Id" = d."FOHWDT_Id" ' ||
                   'GROUP BY "FOEP_PunchDate", c."FOHWDT_Id", f."HRME_Id", "HRME_EmployeeCode", "HRMD_DepartmentName", "HRMDES_DesignationName", "HRMGT_EmployeeGroupType", ' ||
                   '"FOEP_PunchDate", c."FOEST_IHalfLoginTime", j."FOEPD_PunchTime", f."MI_Id", b."FOEP_Id", "FOEST_IHalfLoginTime", "FOEST_DelayPerShiftHrMin", j."FOEPD_PunchTime", ' ||
                   '"HRME_EmployeeFirstName", "HRME_EmployeeMiddleName", "HRME_EmployeeLastName"';
        
        EXECUTE "query";
        
    ELSIF "punchtype" = 'early' THEN
        "query" := 'WITH cte AS (SELECT DISTINCT Oa.*, TO_CHAR(ob."punchdate", ''YYYY-MM-DD'') AS "punchdate", EXTRACT(DAY FROM ob."punchdate") AS "punchday", ' ||
                   'ob."outtime", ob."actualtime", ob."relaxtime", ob."earlyby" FROM ' ||
                   '(SELECT a."HRME_Id", a."HRME_EmployeeCode" AS "ecode", (COALESCE(a."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(a."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(a."HRME_EmployeeLastName", '''')) AS "ename", ' ||
                   'b."HRMD_DepartmentName" AS "depname", c."HRMDES_DesignationName" AS "desgname", d."HRMGT_EmployeeGroupType" AS "gtype" ' ||
                   'FROM "HR_Master_Employee" a, "HR_Master_Department" b, "HR_Master_Designation" c, "HR_Master_GroupType" d ' ||
                   'WHERE a."HRMD_Id" = b."HRMD_Id" AND a."HRMGT_Id" = d."HRMGT_Id" AND a."HRMDES_Id" = c."HRMDES_Id" AND a."MI_Id" = ' || "miid"::VARCHAR || ' AND a."HRME_Id" IN (' || "multiplehrmeid" || ')) Oa, ' ||
                   '(SELECT b."HRME_Id", b."FOEP_PunchDate" AS "punchdate", b."FOEP_PunchDate" AS "punchday", a."outtime", c."FOEST_IIHalfLogoutTime" AS "actualtime", ' ||
                   'c."FOEST_EarlyPerShiftHrMin" AS "relaxtime", "dbo"."getdatediff"(a."outtime", c."FOEST_IIHalfLogoutTime") AS "earlyby" FROM ' ||
                   '(SELECT MAX("FOEPD_PunchTime") AS "outtime", "FOEP_Id" FROM "fo"."FO_Emp_Punch_Details" ' ||
                   'WHERE "FOEPD_InOutFlg" = ''O'' AND "FOEPD_Flag" = TRUE GROUP BY "FOEP_Id") a, "fo"."FO_Emp_Punch" b, "fo"."FO_Emp_Shifts_Timings" c, ' ||
                   '"fo"."FO_Master_HolidayWorkingDay_Dates" x, "fo"."FO_Master_HolidayWorkingDay" z ' ||
                   'WHERE a."FOEP_Id" = b."FOEP_Id" AND x."FOHWDT_Id" = c."FOHWDT_Id" AND c."FOHWDT_Id" = z."FOHWDT_Id" ' ||
                   'AND TO_CHAR(x."FOMHWDD_FromDate", ''DD-MM-YYYY'') = TO_CHAR(b."FOEP_PunchDate", ''DD-MM-YYYY'') ' ||
                   'AND b."HRME_Id" = c."HRME_Id" AND b."FOEP_Flag" = TRUE AND b."MI_Id" = ' || "miid"::VARCHAR || ' ' ||
                   'AND "outtime" < CAST(c."FOEST_IIHalfLogoutTime" AS TIMESTAMP) - c."FOEST_EarlyPerShiftHrMin") Ob ' ||
                   'WHERE Oa."HRME_Id" = Ob."HRME_Id") ' ||
                   'SELECT "HRME_Id", "ecode", "ename", "depname", "desgname", "gtype", "punchdate", "outtime", "actualtime", "relaxtime", ' ||
                   '(CASE WHEN EXTRACT(EPOCH FROM ("actualtime"::TIMESTAMP - "outtime"::TIMESTAMP))/60 > CAST(RIGHT("relaxtime", 2) AS INTEGER) THEN "earlyby" ELSE '''' END) AS "earlyby" ' ||
                   'FROM CTE WHERE ' || "content" || ' ORDER BY "HRME_Id", "punchdate"';
        
        EXECUTE "query";
        
    ELSIF "punchtype" = 'LIEO' THEN
        "dynamic" := 'SELECT DISTINCT f."HRME_Id", f."HRME_EmployeeCode" AS "ecode", ' ||
                     '(COALESCE(f."HRME_EmployeeFirstName", '''') || '' '' || COALESCE(f."HRME_EmployeeMiddleName", '''') || '' '' || COALESCE(f."HRME_EmployeeLastName", '''')) AS "ename", ' ||
                     'g."HRMD_DepartmentName" AS "depname", h."HRMDES_DesignationName" AS "desgname", i."HRMGT_EmployeeGroupType" AS "gtype", ' ||
                     'CAST("FOEP_PunchDate" AS DATE) AS "punchdate", EXTRACT(DAY FROM "FOEP_PunchDate") AS "punchday", ' ||
                     '(SELECT MIN(ed."FOEPD_PunchTime") FROM "fo"."FO_Emp_Punch_details" ed WHERE ed."foep_id" = b."FOEP_Id" LIMIT 1) AS "punchtime", ' ||
                     'c."FOEST_IHalfLoginTime" AS "actualtime", c."FOEST_DelayPerShiftHrMin" AS "relaxtime", ' ||
                     '"dbo"."getdatediff"("dbo"."mintotime"(("dbo"."getonlymin"(c."FOEST_IHalfLoginTime"))), j."FOEPD_PunchTime") AS "lateby", ''00:00'' AS "earlyby", j."FOEPD_InOutFlg" ' ||
                     'FROM "fo"."FO_Emp_Punch_Details" a ' ||
                     'INNER JOIN "fo"."FO_Emp_Punch" b ON a."FOEP_Id" = b."