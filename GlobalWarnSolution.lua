-- Global Warn Solution by CoolD

SLASH_GWS1 = "/gws"

local realmName = GetRealmName()
local resultingName = "null"
local name = "null"
local unit = "null"
local count = 0

local noteFound = false

--the following will check notes for guys joining the group the player is in
local pattern = gsub(ERR_JOINED_GROUP_S, "%%s", "(.+)")
local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_SYSTEM")
frame:SetScript("OnEvent", function(self, event, message)
    name = strmatch(message, pattern)
    if name then
        if(string.find(name, "-")) then
            resultingName = name
            print(resultingName)
        else
            resultingName = name .. "-" .. realmName
            print(resultingName)
        end
        -- runs our findPlayerInDB method
        findPlayerInDB(resultingName)

        if noteFound then
            print("[" .. "|cffFF0000Global Warn Solution|r" .. "] " .. count .. " note(s) found for " .. resultingName .. ".")
            PlaySound(7355)
        else
            print("[" .. "|cffFF0000Global Warn Solution|r" .. "] " .. "No notes found for " .. resultingName .. ".")
        end
     end
end)

local function CheckHandler(msg, editBox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")

    if command == "checkgroup" then
        -- sets the correct unit for when we grab names
        if IsInGroup() then
            unit = "party"
        elseif IsInRaid() then
            unit = "raid"
        end

        --with the grabbed names, we make sure they have a realm,
        --and then pass it onto our findPlayerInDB method
        if IsInRaid() or IsInGroup() then
            -- loop through all the members in the group for their names
            for i = 1, GetNumGroupMembers() - 1 do
                -- get the name and realm of the group member for the current interation
                name = GetUnitName(unit .. i, true)
                -- if the name contains a "-" then we dont need to add realm
                if(string.find(name, "-")) then
                    resultingName = name
                    print(resultingName)
                else
                    -- but if their name does not contain a "-"
                    -- then this means that they are in the player's realm
                    -- so in this case we need to add the players realm to the users name 
                    resultingName = UnitName(unit .. i) .. "-" .. realmName
                end
                -- runs our findPlayerInDB method
                findPlayerInDB(resultingName)
            end

            --display information depending on notes being found
            if noteFound then
                print("[" .. "|cffFF0000Global Warn Solution|r" .. "] " .. count .. " notes found for your group.")
                PlaySound(7355)
            else
                print("[" .. "|cffFF0000Global Warn Solution|r" .. "] " .. "No notes found for your group.")
            end
        else
            print("[" .. "|cffFF0000Global Warn Solution|r" .. "] " .. "You are not in a group!")
        end -- end of the checkGroup command

    elseif command == "checkplayer" and rest ~= "" then
        -- individual checking of player notes
        findPlayerInDB(rest)
        if noteFound then
            print("[" .. "|cffFF0000Global Warn Solution|r" .. "] " .. count .. " note(s) found for " .. rest .. ".")
            PlaySound(7355)
        else
            print("[" .. "|cffFF0000Global Warn Solution|r" .. "] " .. "No notes found for " .. rest .. ".")
        end
    elseif command == "help" then
    --displays all the commands for the player
        print("[" .. "|cffFF0000Global Warn Solution|r" .. "] " .. "Commands: /gws help, /gws checkgroup, /gws checkplayer Name-Realm")
    else
    --if the user makes a typo, advise them to use /gws help
        print("[" .. "|cffFF0000Global Warn Solution|r" .. "] " .. "Invalid command arguments. See /gws help for command usage.")
    end -- end of checkplayer
end -- end of checkhandler

function findPlayerInDB(someone)
    --prints each instance where the name passed onto the method
    --is the same in the array in db_playernotes.lua
    noteFound = false
    count = 0
    for i = 1, table.getn(playerdata) do
        if playerdata[i][1] == someone then
            print("[" .. "|cffFF0000Global Warn Solution|r" .. "] " .. someone .. ": " .. playerdata[i][2])
            noteFound = true
            count = count + 1
        end
    end
end

SlashCmdList["GWS"] = CheckHandler