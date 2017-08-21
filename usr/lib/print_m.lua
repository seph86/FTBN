local gpu = require("component").proxy("c92ddf6f-36d1-470f-8b15-c437066ff436")

local screen = "b9ff3b58-ee6f-49ff-b790-c03c6cee09bd"

local function print_m(message)
  
  -- Setup screen with gpu
  if _G.debugScreenPos == nil then 
    _G.debugScreenPos = 1 
    gpu.bind(screen,true)
  end
  
  -- Shift all content up if we are at the end of the screen
  if _G.debugScreenPos == 50 then gpu.copy(1,1,160,50,0,-1) end
  
  gpu.set(1,_G.debugScreenPos,message)
  
  -- Increment but dont overflow screen pos
  if _G.debugScreenPos < 50 then _G.debugScreenPos = _G.debugScreenPos + 1 end
  
end

return print_m