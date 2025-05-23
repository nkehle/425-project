-- SETUP FOR CAPTURED VALUES
-- For captured key = "1E:60:DF:9D"
local count = 0                -- number of guesses
local UID0_lower_nibble = 0x0E -- only use lower nibble
local UID2 = 0xDF              -- third byte
local UID3 = 0x9D              -- fourth byte


--BATCH #1 MF KEYS
local target_uid = "1E:60:DF:9D"
--local target_uid = "CE:E8:DF:9D"
--local target_uid = "6E:34:E0:9D"

local function check_key(uid)

  -- command: hf mf chk <sector> <A|B> <12-digit-hex-key>
  local cmd = string.format("hf mf sim %s", uid)
  local result = core.console(cmd)

  -- if a key is found write it to a file, and add the timestamp

  -- TODO need to figure out what to do with this value
  if string.match(result, "....") then
      --local file = io.open("found_key.txt", "w")
      local timestamp = os.date("%Y-%m-%d %H:%M:%S") -- mark the time
      --file:write("[" .. timestamp .. "] Valid UID found: ", uid, "\n")
      --file:close()
      print("[" .. timestamp .. "] Valid UID found: ", uid, "\n")

      return true
  end
  return false
end


-- only need the upper nibble
for b1 = 0, 15 do
  -- check all values for second bytes
  for b2 = 0, 255 do

    -- ping-pong search around UID2 // MAX OF 10 for now 
    for offset = 0, 10 do

      local b3_val
      if offset % 2 == 0 then
        -- Even offset: go positive (UID2 + 0, +1, +2, ...)
        b3_val = UID2 + (offset // 2)
      else
        -- Odd offset: go negative (UID2 -1, -2, -3, ...)
        b3_val = UID2 - ((offset + 1) // 2)
      end

      if b3_val < 0 or b3_val > 255 then
        goto continue
      end


      local byte1 = (b1 << 4) | UID0_lower_nibble
      local uid = string.format("%02X:%02X:%02X:%02X", byte1, b2, b3_val, UID3)
      count = count + 1

      print("[" .. count .. "] Trying UID: " .. uid)

      
      -- Convert to MIFARE key format
      local mifare_uid = string.format("%02X%02X%02X%02X", byte1, b2, b3_val, UID3)

      
      if check_key(mifare_uid) then
        return
      end

      ::continue::
    end
  end
end


