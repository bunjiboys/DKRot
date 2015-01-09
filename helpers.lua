if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   local anchorPoints = {
      "TOPLEFT", "TOP", "TOPRIGHT",
      "LEFT", "CENTER", "RIGHT",
      "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"
   }

   local sliderBackdrop = {
      bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
      edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
      tile = true, tileSize = 3, edgeSize = 8,
      insets = { left = 3, right = 3, top = 6, bottom = 6 }
   }

   local editboxBackdrop = {
      bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
      edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
      tile = true, tileSize = 1, edgeSize = 2,
   }

   -- Register a rotation
   function DKROT_RegisterRotation(spec, intname, rotname, rotfunc, def)
      local currentDefault = DKROT:GetDefaultSpecRotation(spec)
      if currentDefault ~= nil and def == true then
         local specName = select(2, GetSpecializationInfo(spec))
         local defSpecName = DKROT.Rotations[spec][currentDefault].name
         DKROT:Log("Cannot register " .. rotname .. " as the new default spec rotation for '" .. specName .. "' as there is already a default rotation (" .. defSpecName .. ") registered. Registering as non-default")
         def = false
      end
      DKROT.Rotations[spec][intname] = {
         name = rotname,
         func = rotfunc,
         default = def
      }
   end

   -- Get default rotation for spec
   function DKROT:GetDefaultSpecRotation(spec)
      if spec == nil then
         spec = DKROT.Current_Spec
      end

      for rotName, rotInfo in pairs(DKROT.Rotations[spec]) do
         if rotInfo.default then
            return rotName
         end
      end

      return nil
   end

   -- Get spellID by name
   function DKROT:GetSpellID(spell)
      return select(7, GetSpellInfo(spell))
   end

   -- Check if we need to use Horn of Winter (missing buff)
   function DKROT:UseHoW()
      local battleShout = select(1, GetSpellInfo(6673))
      local trueShotAura = select(1, GetSpellInfo(19506))
      
      if UnitBuff("PLAYER", DKROT.spells["Horn of Winter"]) ~= nil
         or UnitBuff("PLAYER", battleShout) ~= nil
         or UnitBuff("PLAYER", trueShotAura) ~= nil
      then
         return false
      end

      return true
   end
   
   -- Chat log function
   function DKROT:Log(message)
      DEFAULT_CHAT_FRAME:AddMessage("|cFFC41F3BDKRot:|r " .. message)
   end

   -- Debug log function
   function DKROT:Debug(message)
      if DKROT.debug then
         DEFAULT_CHAT_FRAME:AddMessage("|cFFC41F3BDKRot |cFF00FFFF[DEBUG]|r:|r " .. message)
      end
   end

   function DKROT:SetupPositionPanel(updateCallback)
      local screenWidth = math.floor(GetScreenWidth() * UIParent:GetEffectiveScale() / 2)
      local screenHeight = math.ceil(GetScreenHeight() * UIParent:GetEffectiveScale() / 2)
      local xMinValue, xMaxValue = screenWidth * -1, screenWidth
      local yMinValue, yMaxValue = screenHeight * -1, screenHeight
      local sliders = {
         x = {
            parent = DKROT_PositionPanel,
            value = 0.0,
            label = DKROT_OPTIONS_POSITION_X,
            minValue = xMinValue,
            maxValue = xMaxValue,
         },
         y = {
            parent = DKROT_PositionPanel,
            value = 0.0,
            label = DKROT_OPTIONS_POSITION_Y,
            minValue = yMinValue,
            maxValue = yMaxValue,
         },
         scale = {
            parent = DKROT_PositionPanel,
            value = 1.0,
            label = DKROT_OPTIONS_POSITION_SCALE,
            minValue = 0.5,
            maxValue = 1.5,
         },
      }

      -- UIDropDownMenu_SetSelectedID(DKROT_PositionPanel_Element, 1)
      -- DKROT_PositionPanel_Element_Select(DKROT_PositionPanel_Element, "TOPLEFT")


      DKROT.PositionPanel_X = DKROT:BuildSliderOption(sliders.x, updateCallback)
      DKROT.PositionPanel_X:SetPoint("TOPLEFT", DKROT_PositionPanel_Element, "BOTTOMLEFT", 15, -15)

      DKROT.PositionPanel_Y = DKROT:BuildSliderOption(sliders.y, updateCallback)
      DKROT.PositionPanel_Y:SetPoint("LEFT", DKROT.PositionPanel_X, "RIGHT", 15, 0)

      DKROT.PositionPanel_Scale = DKROT:BuildSliderOption(sliders.scale, updateCallback)
      DKROT.PositionPanel_Scale:SetPoint("TOPLEFT", DKROT.PositionPanel_X, "BOTTOMLEFT", 0, 0)

      DKROT.PositionPanel_Point = CreateFrame("Button", "DKROT_PositionPanel_Point", DKROT_PositionPanel, "DKROT_DropDownTemplate")
      DKROT.PositionPanel_Point:SetPoint("TOPLEFT", DKROT.PositionPanel_Scale, "BOTTOMLEFT", -15, -15)
      DKROT_PositionPanel_Point_Text:SetText(DKROT_OPTIONS_POSITION_POINT)
      UIDropDownMenu_SetWidth(DKROT.PositionPanel_Point, 230, 5)

      DKROT.PositionPanel_RelPoint = CreateFrame("Button", "DKROT_PositionPanel_RelPoint", DKROT_PositionPanel, "DKROT_DropDownTemplate")
      DKROT.PositionPanel_RelPoint:SetPoint("LEFT", DKROT.PositionPanel_Point, "RIGHT", 30, 0)
      DKROT_PositionPanel_RelPoint_Text:SetText(DKROT_OPTIONS_POSITION_REL_POINT)
      UIDropDownMenu_SetWidth(DKROT.PositionPanel_RelPoint, 230, 5)

      DKROT.PositionPanel_RelFrame = CreateFrame("Button", "DKROT_PositionPanel_RelFrame", DKROT_PositionPanel, "DKROT_DropDownTemplate")
      DKROT.PositionPanel_RelFrame:SetPoint("TOPLEFT", DKROT.PositionPanel_Point, "BOTTOMLEFT", 0, -25)
      DKROT_PositionPanel_RelFrame_Text:SetText(DKROT_OPTIONS_POSITION_REL_FRAME)
      UIDropDownMenu_SetWidth(DKROT.PositionPanel_RelFrame, 230, 5)

      -- Once we are done setting up, pre-select the Priority icon
      UIDropDownMenu_Initialize(DKROT_PositionPanel_Element, DKROT_PositionPanel_Element_Init)
      UIDropDownMenu_Initialize(DKROT_PositionPanel_Point, DKROT_PositionPanel_Point_Init)
      UIDropDownMenu_Initialize(DKROT_PositionPanel_RelPoint, DKROT_PositionPanel_Point_Init)
      UIDropDownMenu_Initialize(DKROT_PositionPanel_RelFrame, DKROT_PositionPanel_RelFrame_Init)
      DKROT_PositionPanel_Element_Select(DKROT_PositionPanel_Element, DKROT.MovableFrames[1])
   end

   -- Initialize the UI element drop down
   function DKROT_PositionPanel_Element_Init(self)
      for key, element in pairs(DKROT.MovableFrames) do
         local info = {}
         info.text = element.name
         info.value = element.frame
         info.func = _G['DKROT_PositionPanel_Element_Select']
         info.arg1 = element

         UIDropDownMenu_AddButton(info)
      end
   end
 
   -- Initialize the Anchor frame drop down
   function DKROT_PositionPanel_RelFrame_Init(self)
      for key, element in pairs(DKROT.FrameAnchors) do
         local anchor = {}
         anchor.text = element.name
         anchor.value = element.frame
         anchor.func = _G['DKROT_PositionPanel_RelFrame_Select']
         anchor.arg1 = element

         UIDropDownMenu_AddButton(anchor)
      end
   end

   function DKROT_PositionPanel_Element_Select(self, element)
      local el = _G[element.frame]
      local saved = DKROT_Settings.Location[el:GetName()]
      local point, relFrame, relPoint, x, y, scale = saved.Point:upper(), (saved.Rel or "UIParent"), saved.RelPoint:upper(), saved.X, saved.Y, saved.Scale
      if relFrame == "DKROT" then
         relFrame = "UIParent"
      end

      -- Update element dropdown
      UIDropDownMenu_SetSelectedValue(DKROT_PositionPanel_Element, element.frame)
      -- UIDropDownMenu_SetText(DKROT_PositionPanel_Element, element.name)

      -- Update positional settings
      DKROT.PositionPanel_X:InitValue(x)
      DKROT.PositionPanel_Y:InitValue(y)
      DKROT.PositionPanel_Scale:InitValue(scale)

      UIDropDownMenu_SetSelectedValue(DKROT.PositionPanel_Point, point)
      UIDropDownMenu_SetText(DKROT.PositionPanel_Point, point)

      UIDropDownMenu_SetSelectedValue(DKROT.PositionPanel_RelPoint, relPoint)
      UIDropDownMenu_SetText(DKROT.PositionPanel_RelPoint, relPoint)

      -- Handle some weirdness where the drop down doesnt update correctly
      if relFrame == "UIParent" then
         UIDropDownMenu_SetSelectedValue(DKROT.PositionPanel_RelFrame, relFrame)
         UIDropDownMenu_SetText(DKROT.PositionPanel_RelFrame, "Screen")
      else
         UIDropDownMenu_SetSelectedValue(DKROT.PositionPanel_RelFrame, relFrame)
      end
   end

   --function DKROT:BuildSliderOption(name, parent, value, callback)
   function DKROT:BuildSliderOption(info, callback)
      local frame = CreateFrame("Frame", info.name, info.parent)
      frame.value = info.value ~= nil and info.value or 0.0

      frame:EnableMouse(true)
      frame:SetWidth(250)
      frame:SetHeight(70)

      frame.label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
      frame.label:SetPoint("TOPLEFT")
      frame.label:SetPoint("TOPRIGHT")
      frame.label:SetJustifyH("CENTER")
      frame.label:SetHeight(15)
      if info.label ~= nil then
         frame.label:SetText(info.label)
      end

      frame.slider = CreateFrame("Slider", "$parent_Slider", frame)
      frame.slider:SetOrientation("HORIZONTAL")
      frame.slider:SetHeight(15)
      frame.slider:SetHitRectInsets(0, 0, -10, 0)
      frame.slider:SetBackdrop(sliderBackdrop)
      frame.slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
      frame.slider:SetPoint("TOP", frame.label, "BOTTOM")
      frame.slider:SetPoint("LEFT", 3, 0)
      frame.slider:SetPoint("RIGHT", -3, 0)
      frame.slider:EnableMouseWheel(true)
      frame.slider:SetValue(frame.value)
      frame.slider:SetMinMaxValues(info.minValue, info.maxValue)

      frame.lowtext = frame.slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
      frame.lowtext:SetPoint("TOPLEFT", frame.slider, "BOTTOMLEFT", 2, 3)
      frame.lowtext:SetText(info.minValue)

      frame.hightext = frame.slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
      frame.hightext:SetPoint("TOPRIGHT", frame.slider, "BOTTOMRIGHT", -2, 3)
      frame.hightext:SetText(info.maxValue)

      frame.editbox = CreateFrame("EditBox", "$parent_EditBox", frame)
      frame.editbox:SetAutoFocus(false)
      frame.editbox:SetFontObject(GameFontHighlightSmall)
      frame.editbox:SetPoint("TOP", frame.slider, "BOTTOM")
      frame.editbox:SetHeight(21)
      frame.editbox:SetWidth(70)
      frame.editbox:SetJustifyH("CENTER")
      frame.editbox:EnableMouse(true)
      frame.editbox:SetBackdrop(editboxBackdrop)
      frame.editbox:SetBackdropColor(0, 0, 0, 0.5)
      frame.editbox:SetBackdropBorderColor(0.3, 0.3, 0.3, 0.80)
      frame.editbox:SetText(frame.value)

      frame.editbox:SetScript("OnEscapePressed", function()
         frame.editbox:SetText(frame.value)
         frame.editbox:ClearFocus()
      end)

      frame.editbox:SetScript("OnEnterPressed", function(self)
         frame.value = DKROT:round(self:GetNumber(), 2)
         frame.slider:SetValue(self:GetNumber())
         frame.editbox:ClearFocus()
      end)

      frame.slider:SetScript("OnValueChanged", function(self, value)
         frame.value = DKROT:round(value, 2)
         frame.editbox:SetText(frame.value)

         if frame.noUpdate ~= true then
            callback()
         end
      end)

      function frame:SetValue(value)
         frame.value = value
         frame.slider:SetValue(frame.value)
      end

      function frame:InitValue(value)
         frame.noUpdate = true
         frame.value = DKROT:round(value, 2)
         frame.slider:SetValue(value)
         frame.editbox:SetCursorPosition(0)
         frame.noUpdate = false
      end

      function frame:GetValue()
         return frame.value
      end

      return frame
   end

   function DKROT_PositionPanel_Point_Init(self)
      for idx, point in pairs(anchorPoints) do
         local info = {}
         info.text = point
         info.value = point
         info.func = _G["DKROT_PositionPanel_Point_Select"]
         info.arg1 = point

         UIDropDownMenu_AddButton(info)
      end
   end

   function DKROT_PositionPanel_Point_Select(self, point)
      UIDropDownMenu_SetSelectedValue(UIDROPDOWNMENU_OPEN_MENU, point)
      -- UIDropDownMenu_SetText(UIDROPDOWNMENU_OPEN_MENU, point)

      DKROT:PositionUpdate()
   end

   function DKROT_PositionPanel_RelFrame_Select(self, element)
      local source = UIDropDownMenu_GetSelectedValue(DKROT_PositionPanel_Element)
      local hasDeps = DKROT:CheckFrameDependency(source, element.frame)
      if hasDeps ~= nil and #hasDeps > 0 then
         --StaticPopup_Show("DKROT_ERROR_DEPENDENCY_VIOLATION", DKROT:GetFrame(source), element.name, table.concat(hasDeps, " > "))
         StaticPopup_Show("DKROT_ERROR_DEPENDENCY_VIOLATION", element.name, table.concat(hasDeps, " > "))
      else
         UIDropDownMenu_SetSelectedValue(UIDROPDOWNMENU_OPEN_MENU, element.frame)
         -- UIDropDownMenu_SetText(dd, point)

         DKROT:PositionUpdate()
      end
   end

   function DKROT:round(num, idp)
      local mult = 10 ^ (idp or 0)
      return math.floor(num * mult + 0.5) / mult
   end

   function DKROT:deepcopy(orig)
      local orig_type = type(orig)
      local copy
      if orig_type == 'table' then
         copy = {}
         for orig_key, orig_value in next, orig, nil do
            copy[DKROT:deepcopy(orig_key)] = DKROT:deepcopy(orig_value)
         end
         setmetatable(copy, DKROT:deepcopy(getmetatable(orig)))
      else -- number, string, boolean, etc
         copy = orig
      end
      return copy
   end

   function DKROT:CheckFrameDependency(frame, target, stack)
      stack = (stack or {})
      local i = 0
      for idx, element in pairs(DKROT.MovableFrames) do
         i = i + 1

         if i > 30 then
            return "iterations exceeded"
         end

         if element.frame == target then
            local relFrame = select(2, _G[element.frame]:GetPoint()):GetName()
            
            if relFrame == "UIParent" then
               return nil
            end

            table.insert(stack, DKROT:GetFrame(target))

            if relFrame == frame then
               table.insert(stack, DKROT:GetFrame(frame))
               return stack
            end

            return DKROT:CheckFrameDependency(frame, relFrame, stack)
         end
      end

      return nil
   end

   function DKROT:ShowErrorMessage(message)
      StaticPopup_Show("DKROT_ERROR_MESSAGE")
   end

   function DKROT:GetFrame(frame, fullObject)
      for idx, el in pairs(DKROT.MovableFrames) do
         if el.frame == frame then
            if fullObject == true then
               return el
            end

            return el.name
         end
      end

      return nil
   end

   function DKROT_printr(var, level)
      level = level ~= nil and level + 1 or 0
      for k,v in pairs(var) do
         if type(v) == "table" then
            print(string.rep("   ", level) .. k .. " = {")
            DKROT_printr(v, level)
            print(string.rep("   ", level) .. "}")
         else
            print(string.rep("   ", level) .. k .. " = " .. tostring(v))
         end
         
      end
   end

   function DKROT:SpellKnown(spell)
      return GetSpellTexture(spell) and true or false
   end
end
