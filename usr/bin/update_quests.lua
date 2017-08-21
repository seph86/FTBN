io = require("io")
md5 = require("component").data.md5
shell = require("shell")
serialization = require("serialization")

-- Dumb split string parser
function SplitString(s)
  s = s .. "," --append ending "," for later gmatch
  result = {}
  for item in s:gmatch("(.-),") do
    table.insert(result,item)
  end
  return result
end

shell.execute("wget -qf https://docs.google.com/spreadsheets/d/1MzK6OMqq584pwed3JO7MC8BnZHdXjkX11RxigrvvC8k/export?format=csv&gid=1289779869 /tmp/export.csv")

downloadedQuestsFile = io.open("/tmp/export.csv")
downloadedHash = md5(downloadedQuestsFile:read("*a"))

questsHashFile = io.open("/usr/var/quests.md5","rb")
questsHash = questsHashFile:read(16)
questsHashFile:close()

if downloadedHash ~= questsHash then
  print("Updated Quests found, updating")

  --Seek back to start of downloadedQuestFile
  downloadedQuestsFile:seek("set",0)

  --Update file  
  questsHashFile = io.open("/usr/var/quests.md5","wb")
  questsHashFile:write(downloadedHash)
  questsHashFile:close()

  -- Standard locals
  local questNumber,easyCount,normalCount,HardCount,hiddenCount;

  local lineNumber = 1

  -- Construct QuestItems Table {easy, normal, hard, hidden}
  local QuestItems = {{},{},{},{}}

  -- Construct Quests Table {easy, normal, hard, hidden}
  local Quests = {{},{},{},{}} 

  for line in downloadedQuestsFile:lines() do

    --print(line)

    line = SplitString(line)

    --Skip certain lines
    if line[1] ~= "Quest" and line[1] ~= "SK" then
      
      -- Set/Reset locals
      if line[1] ~= "" then
        questNumber = tonumber(line[1])
        easyCount,normalCount,hardCount,hiddenCount = 0,0,0,0
      end

      --TEMPORARY ========================================================
      if questNumber > 32 then break end

      --Check for Easy Quest or Hidden Quest
      if line[4] ~= "" then
        
        --Check if this belongs to the hidden quest line
        if questNumber > 32 then  

          hiddenCount = hiddenCount + 1

        else --Is an Easy Quest

          easyCount = easyCount + 1
          QuestItems[1][line[5].."_"..line[6]] = {questNumber, line[4], tonumber(line[7]), easyCount}
          if QuestItems[1][questNumber] == nil then
            QuestItems[1][questNumber] = {["SubQuests"]=0}
          end
          QuestItems[1][questNumber].SubQuests = easyCount
          QuestItems[1][questNumber][easyCount] = line[5].."_"..line[6]

        end

      end

      --Check for Normal Quest
      if line[8] ~= "" then
        normalCount = normalCount + 1
        QuestItems[2][line[9].."_"..line[10]] = {questNumber, line[8], tonumber(line[11]), normalCount}
        if QuestItems[2][questNumber] == nil then
          QuestItems[2][questNumber] = {["SubQuests"]=0}
        end
        QuestItems[2][questNumber].SubQuests = normalCount
        QuestItems[2][questNumber][normalCount] = line[9].."_"..line[10]
      end

      --Check for Hard Quest
      if line[12] ~= "" then
        --print(table.concat(line,","))
        hardCount = hardCount + 1
        QuestItems[3][line[13].."_"..line[14]] = {questNumber, line[12], tonumber(line[15]), hardCount}
        if QuestItems[3][questNumber] == nil then
          QuestItems[3][questNumber] = {["SubQuests"]=0}
        end
        QuestItems[3][questNumber].SubQuests = hardCount
        QuestItems[3][questNumber][hardCount] = line[13].."_"..line[14]
      end

    end

    lineNumber = lineNumber + 1

  end

  --for i=1,3,1 do for k,v in pairs(QuestItems[i]) do print(k,table.concat(v,",")) end end
  
  questItemsFile = io.open("/usr/var/quests.tbl","w")
  questItemsFile:write(serialization.serialize(QuestItems));
  questItemsFile:close()

end