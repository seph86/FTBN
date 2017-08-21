event = require("event")
io = require("io")
--tunnel = require("component").tunnel
serialization = require("serialization")
keyboard = require("keyboard")
debug = require("component").debug
unicode = require("unicode")
print_m = require("print_m")

local args = {...}

function processMessage(_,_,_,_,_,sender,message,opt1)

  --verify
  if TeamAddrTranslate[sender] ~= nil and message == "itemReceived" then
    senderAddr = sender
    sender = TeamAddrTranslate[sender]
    event.push("test_item",opt1,sender)
  elseif sender == "@" and message == "useCrystalTrigger" then
    
  else
    return
  end

  --print("Message received from: "..sender.." - "..message)

end

test_item = require("test_item")

if args[1] == "release" or args[1] == "reset" then

  --unload packages
  package.loaded.test_item = nil

  event.ignore("test_item", test_item)
  event.ignore("debug_message",processMessage)
end

if args[1] == "release" then
  -- Quit without initializing
  return
end

_G.TeamQuestProgress = {}
_G.TeamQuestProgress["Team1"] = { ["TeamName"]="Air",["Difficulty"]=1,["Time"]=0,["Gamemode"]=0,["Addr"]="0059601e-574d-4d5f-8bc8-48ec9cb420cf" }
_G.TeamQuestProgress["Team2"] = { ["TeamName"]="Water",["Difficulty"]=0,["Time"]=0,["Gamemode"]=0 }
_G.TeamQuestProgress["Team3"] = { ["TeamName"]="Earth",["Difficulty"]=0,["Time"]=0,["Gamemode"]=0 }
_G.TeamQuestProgress["Team4"] = { ["TeamName"]="Fire",["Difficulty"]=0,["Time"]=0,["Gamemode"]=0 }

_G.TeamAddrTranslate = {[_G.TeamQuestProgress["Team1"].Addr]="Team1"}

_G.QuestItems = {}

_G.QuestNameMapping = {"0x03b1","0x03b2","0x03b3","0x03b4","0x03b5","0x03b6","0x03b7","0x03b8","0x03b9","0x03ba","0x03bb","0x03bc","0x03bd","0x03be","0x03bf","0x266a","0x2b1b","0x2299","0x263e","0x23cf","0x2b1c","0x262f","0x262e","Au","Ag","Cu","Fe","Pb","Al","♥","♣","♦","♠ I","♠ II","♠ III","♠ IV"}

--Load Quests
print_m("Loading quests...")
local questFile = io.open("/usr/var/quests.tbl")
_G.QuestItems = serialization.unserialize(questFile:read("*a"))
questFile:close()

--Load Team Progress
print_m("Loading teams...")
local teamFile = io.open("/usr/var/teams.tbl")
if teamFile == nil then
  -- loadDifficulty("Team1",2)
  -- loadDifficulty("Team2",1)
  -- loadDifficulty("Team3",1)
  -- loadDifficulty("Team4",1)
  teamFile = io.open("/usr/var/teams.tbl","w")
  teamFile:write(serialization.serialize(_G.TeamQuestProgress))
  teamFile:close()
else
  -- Do not load the old table if reset switch is set.
  if args[1] ~= "reset" then 
    _G.TeamQuestProgress = serialization.unserialize(teamFile:read("*a"))
  end
  teamFile:close()
end

--configQuestCrystals("Team1")

event.listen("debug_message",processMessage)
event.listen("test_item", test_item)


-- function loadDifficulty(teamNumber, difficulty)

  -- --Set difficulty
  -- TeamQuestProgress[teamNumber].Difficulty = difficulty

  -- --Construct Progress Table from QuestItems list
  -- for i,v in pairs(QuestItems[difficulty]) do
    -- if type(i) == "string" then
      -- if TeamQuestProgress[teamNumber][v[1]] == nil then
        -- TeamQuestProgress[teamNumber][v[1]] = {["Timeout"]=0}
      -- end
      -- TeamQuestProgress[teamNumber][v[1]][v[4]] = {["Current"]=0,["Target"]=v[3]}
    -- end
  -- end

-- end


-- Used to configure command blocks to imprint quest info to the Knowledge Crystal
-- function configQuestCrystal(teamNumber, questNumber)

      -- temp = "["
      -- for k=1,QuestItems[TeamQuestProgress[teamNumber].Difficulty][questNumber].SubQuests do
        -- --Key to refer back to QuestItems
        -- questRef = QuestItems[TeamQuestProgress[teamNumber].Difficulty][questNumber][k]
        -- print(questRef)
        -- temp = temp.."\\\"§3"..QuestItems[ TeamQuestProgress[teamNumber].Difficulty ][questRef][2].." "
        -- --Is current >= requirement
        -- if TeamQuestProgress[teamNumber][questNumber][k].Current >= TeamQuestProgress[teamNumber][questNumber][k].Target then
          -- temp = temp.."§a("
        -- else
          -- temp = temp.."§c("
        -- end
        -- temp = temp .. TeamQuestProgress[teamNumber][questNumber][k].Current .. "\\" .. TeamQuestProgress[teamNumber][questNumber][k].Target .. ")\\\""
        -- --is not last item
        -- if k < QuestItems[TeamQuestProgress[teamNumber].Difficulty][questNumber].SubQuests then
          -- temp = temp..","
        -- end
      -- end
      -- temp = temp .. "]"
      -- debug.runCommand("execute @e[tag=Quest"..questNumber.."] ~ ~ ~ blockdata ~ 65 ~ {Command:\"execute @e[tag=Quest"..questNumber.."] ~ ~ ~ replaceitem entity @a[r=1,score_CrystalTimer_min=20] slot.weapon.mainhand minecraft:carrot_on_a_stick 1 1 {Unbreakable:1b,HideFlags:4,display:{Name:Quest "..translateQuestNumberToString(questNumber)..",Lore:"..temp.."}}\"}")

-- -- End configQuestCrystals
-- end

-- function configQuestCrystals(teamNumber)

  -- for i=1,32 do
    -- configQuestCrystal(teamNumber,i)
  -- end

-- end


-- Because the QuestNameMapping array contains both UTF8 code and ascii
--  characters, we need to be able to identify which is which and
--  return the appropriate string
-- function translateQuestNumberToString(questNumber)
  -- if string.sub(QuestNameMapping[questNumber],1,1) == "0" then -- Is UTF8 encoded
    -- return unicode.char(QuestNameMapping[questNumber])
  -- else -- Is normal ascii encoded
    -- return QuestNameMapping[questNumber] 
  -- end
-- end

-- start()