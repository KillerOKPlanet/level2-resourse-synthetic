require("lib")
BOX_ID, REG_ID = 100420, 8
MAX_VALUE = 798.453
MIN_VALUE = 791.000
START_STAMP = get_UNIX_timestamp("2022-07-25 00:00:00")
END_STAMP = get_UNIX_timestamp("2022-08-03 18:00:00")
SPLIT = 100 -- into chunks for transaction commit statement
TIME_STEP=3600 -- seconds. get_timestamp_slices for level2 is default.


MANUAL_FACTOR = 1 -- bigger value will increase MAX_VALUE faster and then saturate at this value 



function noise ( i )
	return (math.sin(i))/noise_divisor
end


-- generate
dates, slices = get_timestamp_slices(START_STAMP, END_STAMP)
-- print(os.date(SQL_TIME_FORMAT,dates[1]) .. " " .. os.date(SQL_TIME_FORMAT,dates[slices]))
-- print("MIN_VALUE " .. MIN_VALUE)
-- print("slices " .. slices)

-- for printi=1,#dates do
--     print(os.date(SQL_TIME_FORMAT,dates[printi]))
-- end

tab = {}
for i,v in pairs(dates) do
--     print(i .. " " .. v)
	local var = i % 360 -- angles for sin. Sin frequency. 
	table.insert(tab, var)
end
-- tprint(tab)

start_value = MIN_VALUE
istep = (MAX_VALUE - MIN_VALUE)/(slices)

-- increase ND to avoid saturation (too fast reach of MAX_VALUE and 0 diff at the tail)
noise_divisor = math.ceil( math.ceil( 1/istep ) / ND_ROUND_TO  ) * ND_ROUND_TO;
noise_divisor = noise_divisor / MANUAL_FACTOR

print("START TRANSACTION;")
for i=slices, 1, -1 do -- reverse direction so that older at top (lower value to highest - at present time at bottom)

    headers(i)

    start_value = prev_val or start_value
    local step_up = ( istep + noise(i) )
    end_value = start_value + ( step_up  > 0 and  step_up  or 0)
    if end_value > MAX_VALUE then end_value = MAX_VALUE end -- saturation at MAX_VALUE. Increase noise_divisor to avoid.
    value = end_value - start_value
    timestamp = os.date(SQL_TIME_FORMAT, math.ceil(dates[i]))
    write(TABULATION.."(" .. BOX_ID .. "," .. REG_ID .. ",'" .. timestamp .. "'," .. value .. "," .. start_value .. "," .. end_value .. ")");
    if (i % SPLIT == 1) then print(";"); else print(","); end -- last in the chunk with semicolon
    
    prev_val = end_value
end
print("COMMIT;");
