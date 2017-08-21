local print_m = require("print_m")

local function load_difficulty(team, newDiff)

  -- Check team and quest data is in place
  if _G.TeamQuestProgress[team] == nil or _G.QuestItems[newDiff] == nil then
  
    print_m("Error: Attempted to load difficulty for "..team.." without Initialization phase first")
    return false
    
  end

  -- Set difficulty for team
  _G.TeamQuestProgress.Difficulty = newDiff
  
  for i,v in pairs(QuestItems[newDiff]) do
    if type(i) == "string" then
    
      -- Set entry if it doesnt already exist
      if _G.TeamQuestProgress[team][v[1]] == nil then
        _G.TeamQuestProgress[team][v[1]] = {["Timeout"] = 0}
      end
      
      -- Set data for specific quest and subitem
      _G.TeamQuestProgress[team][v[1]][v[4]] = {["Current"]=0,["Target"]=v[3]}
      
    end
  end
  
  return true
  
end

return load_difficulty