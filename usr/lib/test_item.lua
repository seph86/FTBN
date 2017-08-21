local serialization = require("serialization")
local print_m = require("print_m")
local debugCard = require("component").debug

local function test_item(_, packet, team)

  local data = serialization.unserialize(packet)
  local difficulty

  print_m("Testing: "..packet)
  
  if data[1] == "hidden" then
    difficulty = 4
  else
    difficulty = _G.TeamQuestProgress[team].Difficulty
  end

  -- Ref quest using input data
  local questData = _G.QuestItems[difficulty][data[2]]
  
  -- Is quest valid? 
  if questData ~= nil then
  
    -- If team hasnt waited long enough for the quest to reset, ignore item
    if _G.TeamQuestProgress[team].Time < _G.TeamQuestProgress[team][ questData[1] ].Timeout then
      return
    end
  
    -- Make ref to team quest information. (1=Quest ID, 4=Sub Quest ID) -- refer to QuestName table
    subQuest = _G.TeamQuestProgress[team][ questData[1] ][ questData[4] ]
  
    -- Increment progress by count, don't overflow
    subQuest.Current = subQuest.Current + data[3]
    if subQuest.Current > subQuest.Target then subQuest.Current = subQuest.Target end
    
    --Update Knowledge Crystal System %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TODO
    --configQuestCrystal(team,questData[1])
    
    -- Is sub quest complete?
    if subQuest.Current == subQuest.Target then
      
      -- print_m(team.." subquest:")
      
      -- Ref quest
      quest = _G.TeamQuestProgress[team][ questData[1] ]
      
      -- Check all quests are complete
      local isComplete = true
      for i=1,_G.QuestItems[difficulty][ questData[1] ].SubQuests do
        if quest[i].Current < quest[i].Target then
          isComplete = false
          break
        end
      end
      
      -- If quest is indeed complete, reward the team
      if isComplete then
      
        print_m(team.." has completed Quest "..questData[1])
        
        local timeout = 0 -- How long a quest is set to be inactive for
        
        -- Tier 4 and hidden quests do not have a timeout. Set the rest appropriately
        if difficulty ~= 4 then
          if questData[1] < 16 then
            timeout = 60 -- One minute
          elseif questData[2] < 24 then
            timeout = 300 -- Five minutes
          elseif questData[3] < 30 then
            timeout = 1200 -- 20 Minutes
          end
        end
        
        quest.Timeout = _G.TeamQuestProgress[team].Time + timeout
        -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TODO
        --debugCard.runCommand()
        
        print_m("Timeeout set to "..quest.Timeout)
      
      end
      
    end
  
  end
  
end

return test_item