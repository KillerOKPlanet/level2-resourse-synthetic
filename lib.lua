ND_ROUND_TO = 10 -- to be sligtly bigger then it should. Bigger value decrease slope.
-- debug helpers
-- function tprint(printable)
-- 	for el = 1, #printable do
-- 		print(printable[el])
-- 	end
-- end
--
TABULATION="	"
SQL_TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

function get_UNIX_timestamp(timeToConvert)
    -- local timeToConvert = "2011-12-21 13:30:59"
local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
local runyear, runmonth, runday, runhour, runminute, runseconds = timeToConvert:match(pattern)
local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
return convertedTimestamp
end
write = io.write
function get_timestamp_slices(st, fin)
	local t = {}
		
	for i=fin,st,-TIME_STEP do
		table.insert(t,i)
	end
	return t, #t
end

function headers( i )
    if (i==slices or i%SPLIT==0) then -- first and every SPLIT repeat
        print("INSERT INTO ")
        print(TABULATION.."box_meters_hours(box_id, reg_id, timestamp, value, start_value, end_value)")
        print("VALUES");
    end
end
