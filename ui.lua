if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   -- Sets up required information for each element that can be moved
   function DKROT:SetupMoveFunction(frame)
      frame:EnableMouse(false)
      frame:SetMovable(true)

      -- When mouse held, move
      frame:SetScript("OnMouseDown", function(self, button)
         DKROT:Debug("Mouse Down " .. self:GetName())
         CloseDropDownMenus()
         local _, _, _, x, y = self:GetPoint()
         self.PreMoveLoc = { X = x, Y = y }
         self:StartMoving()
         _, _, _, x, y = self:GetPoint()
         self.MoveLoc = { X = x, Y = y }
      end)

      -- When mouse released, save position
      frame:SetScript("OnMouseUp", function(self, button)
         DKROT:Debug("Mouse Up " .. self:GetName())
         local _, _, _, postMoveX, postMoveY = self:GetPoint()
         self:StopMovingOrSizing()

         -- Calculate the new offset delta's
         local x = self.PreMoveLoc.X + (postMoveX - self.MoveLoc.X)
         local y = self.PreMoveLoc.Y + (postMoveY - self.MoveLoc.Y)

         --DKROT_Settings.Location[self:GetName()].Point, _, DKROT_Settings.Location[self:GetName()].RelPoint, DKROT_Settings.Location[self:GetName()].X, DKROT_Settings.Location[self:GetName()].Y = self:GetPoint()
         DKROT_Settings.Location[self:GetName()].X = x
         DKROT_Settings.Location[self:GetName()].Y = y
         DKROT:MoveFrame(self)
         UIDropDownMenu_Initialize(DKROT_PositionPanel_Element, DKROT_PositionPanel_Element_Init)
         DKROT_PositionPanel_Element_Select(DKROT_PositionPanel_Element, DKROT:GetFrame(self:GetName(), true))
      end)
   end

   -- Icon template
   -- In: name: the name of the icon frame   parent: the icons parent   spellname: the spell the icon will first display   size:height and width in pixels
   -- Out: returns the icon create by parameters
   function DKROT:CreateIcon(name, parent, spellname, size)
      local frame = CreateFrame('Button', name, parent)
      frame:SetWidth(size)
      frame:SetHeight(size)
      frame:SetFrameStrata("BACKGROUND")
      frame:EnableMouse(false)
      frame.Spell = spellname

      -- Cooldown spiral
      frame.c = CreateFrame('Cooldown', nil, frame, "CooldownFrameTemplate")
      frame.c:SetDrawEdge(DKROT_Settings.CDEDGE)
      frame.c:SetAllPoints(frame)

      -- Icon
      frame.Icon = frame:CreateTexture("$parentIcon", "DIALOG")
      frame.Icon:SetAllPoints()
      frame.Icon:SetTexture(GetSpellTexture(spellname))

      -- Time remaining
      frame.Time = frame:CreateFontString(nil, 'OVERLAY')
      frame.Time:SetPoint("CENTER",frame, 1, 0)
      frame.Time:SetJustifyH("CENTER")
      frame.Time:SetFont(DKROT.font, 13, "OUTLINE")

      -- Stacks
      frame.Stack = frame:CreateFontString(nil, 'OVERLAY')
      frame.Stack:SetPoint("BOTTOMRIGHT",frame, 3, 1)
      frame.Stack:SetJustifyH("CENTER")
      frame.Stack:SetFont(DKROT.font, 10, "OUTLINE")

      return frame
   end

   function DKROT:CreateCDs()
      DKROT.CD = {}

      -- Create four frames in which 2 icons will placed in each
      for i = 1, 4 do
         DKROT.CD[i] = CreateFrame("Button", "DKROT.CD"..i, DKROT.MainFrame)
         DKROT.CD[i]:SetWidth(34)
         DKROT.CD[i]:SetHeight(68)
         DKROT.CD[i]:SetFrameStrata("BACKGROUND")
         DKROT.CD[i]:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = -1, right = -1, top = -1, bottom = -1},}
         DKROT.CD[i]:SetBackdropColor(0, 0, 0, 0.5)
         DKROT:SetupMoveFunction(DKROT.CD[i])
      end

      -- List of CD frame names, using the name of dropdown menu to allow easy saving and fetching
      DKROT.CDDisplayList = {
         "DKROT_CDRPanel_DD_CD1_One",
         "DKROT_CDRPanel_DD_CD1_Two",
         "DKROT_CDRPanel_DD_CD2_One",
         "DKROT_CDRPanel_DD_CD2_Two",
         "DKROT_CDRPanel_DD_CD3_One",
         "DKROT_CDRPanel_DD_CD3_Two",
         "DKROT_CDRPanel_DD_CD4_One",
         "DKROT_CDRPanel_DD_CD4_Two",
      }

      -- Create the Icons with desired paramaters
      for i = 1, #DKROT.CDDisplayList do
         DKROT.CD[DKROT.CDDisplayList[i]] = DKROT:CreateIcon(DKROT.CDDisplayList[i].."Butt", DKROT.MainFrame, DKROT.spells["Army of the Dead"], 32)
         DKROT.CD[DKROT.CDDisplayList[i]].Time:SetFont(DKROT.font, 11, "OUTLINE")
         DKROT.CD[DKROT.CDDisplayList[i]]:SetParent(DKROT.CD[ceil(i/2)])
         DKROT.CD[DKROT.CDDisplayList[i]]:EnableMouse(false)
      end

      -- Give Icons their position based on parent
      DKROT.CD[DKROT.CDDisplayList[1]]:SetPoint("TOPLEFT", DKROT.CD[1], "TOPLEFT", 1, -1)
      DKROT.CD[DKROT.CDDisplayList[2]]:SetPoint("TOPLEFT", DKROT.CD[DKROT.CDDisplayList[1]], "BOTTOMLEFT", 0, -2)
      DKROT.CD[DKROT.CDDisplayList[3]]:SetPoint("TOPRIGHT", DKROT.CD[2], "TOPRIGHT", -1, -1)
      DKROT.CD[DKROT.CDDisplayList[4]]:SetPoint("TOPLEFT", DKROT.CD[DKROT.CDDisplayList[3]], "BOTTOMLEFT", 0, -2)
      DKROT.CD[DKROT.CDDisplayList[5]]:SetPoint("TOPRIGHT", DKROT.CD[3], "TOPRIGHT", -1, -1)
      DKROT.CD[DKROT.CDDisplayList[6]]:SetPoint("TOPLEFT", DKROT.CD[DKROT.CDDisplayList[5]], "BOTTOMLEFT", 0, -2)
      DKROT.CD[DKROT.CDDisplayList[7]]:SetPoint("TOPRIGHT", DKROT.CD[4], "TOPRIGHT", -1, -1)
      DKROT.CD[DKROT.CDDisplayList[8]]:SetPoint("TOPLEFT", DKROT.CD[DKROT.CDDisplayList[7]], "BOTTOMLEFT", 0, -2)

      DKROT:Debug("Cooldowns Created")
   end

   function DKROT:CreateRuneBar()
      local frame = CreateFrame('StatusBar', nil, DKROT.RuneBarHolder)
      frame:SetHeight(80)
      frame:SetWidth(8)
      frame:SetOrientation("VERTICAL")
      frame:SetStatusBarTexture('Interface\\Tooltips\\UI-Tooltip-Background', 'OVERLAY')
      frame:SetStatusBarColor(1, 0.2, 0.2, 1)
      frame:GetStatusBarTexture():SetBlendMode("DISABLE")
      frame:Raise()

      frame.back = frame:CreateTexture(nil, 'BACKGROUND', frame)
      frame.back:SetAllPoints(frame)
      frame.back:SetBlendMode("DISABLE")

      frame.Spark = frame:CreateTexture(nil, 'OVERLAY')
      frame.Spark:SetHeight(16)
      frame.Spark:SetWidth(16)
      frame.Spark.c = CreateFrame('Cooldown', nil, frame, "CooldownFrameTemplate")
      frame.Spark.c:SetDrawEdge(DKROT_Settings.CDEDGE)
      frame.Spark.c:SetAllPoints(frame)
      frame.Spark.c.lock = false

      return frame
   end

   function DKROT:CreateUI()
      -- DKROT:SetupMoveFunction(DKROT.MainFrame)

      -- Create Rune bar frame
      DKROT.RuneBar = CreateFrame("Button", "DKROT.RuneBar", DKROT.MainFrame)
      DKROT.RuneBar:SetHeight(23)
      DKROT.RuneBar:SetWidth(94)
      DKROT.RuneBar:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
      DKROT.RuneBar:SetBackdropColor(0, 0, 0, 0.5)
      DKROT.RuneBar.Text = DKROT.RuneBar:CreateFontString(nil, 'OVERLAY')
      DKROT.RuneBar.Text:SetPoint("TOP", DKROT.RuneBar, "TOP", 0, -2)
      DKROT.RuneBar.Text:SetJustifyH("CENTER")
      DKROT.RuneBar.Text:SetFont(DKROT.font, 18, "OUTLINE")
      DKROT:SetupMoveFunction(DKROT.RuneBar)

      DKROT.RuneBarHolder = CreateFrame("Button", "DKROT.RuneBarHolder", DKROT.MainFrame)
      DKROT.RuneBarHolder:SetHeight(100)
      DKROT.RuneBarHolder:SetWidth(110)
      DKROT.RuneBarHolder:SetFrameStrata("BACKGROUND")
      DKROT.RuneBarHolder:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
      DKROT.RuneBarHolder:SetBackdropColor(0, 0, 0, 0.5)
      DKROT.RuneBars = {}
      DKROT.RuneBars[1] = DKROT:CreateRuneBar()
      DKROT.RuneBars[1]:SetPoint("BOTTOMLEFT", DKROT.RuneBarHolder, "BOTTOMLEFT", 6, 10)
      for i = 2, 6 do
         DKROT.RuneBars[i] = DKROT:CreateRuneBar()
         DKROT.RuneBars[i]:SetPoint("BOTTOMLEFT",DKROT.RuneBars[i-1], "BOTTOMRIGHT", 10, 0)
      end
      DKROT:SetupMoveFunction(DKROT.RuneBarHolder)

      -- Create Runic Power frame
      DKROT.RunicPower = CreateFrame("Button", "DKROT.RunicPower", DKROT.MainFrame)
      DKROT.RunicPower:SetHeight(23)
      DKROT.RunicPower:SetWidth(47)
      DKROT.RunicPower:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
      DKROT.RunicPower:SetBackdropColor(0, 0, 0, 0.5)
      DKROT.RunicPower.Text = DKROT.RunicPower:CreateFontString(nil, 'OVERLAY')
      DKROT.RunicPower.Text:SetPoint("TOP", DKROT.RunicPower, "TOP", 0, -2)
      DKROT.RunicPower.Text:SetJustifyH("CENTER")
      DKROT.RunicPower.Text:SetFont(DKROT.font, 22, "OUTLINE")
      DKROT:SetupMoveFunction(DKROT.RunicPower)

      -- Create frame for Diseases with 2 icons for their respective disease
      DKROT.Diseases = CreateFrame("Button", "DKROT.Diseases", DKROT.MainFrame)
      DKROT.Diseases:SetHeight(24)
      DKROT.Diseases:SetWidth(47)
      DKROT.Diseases:SetFrameStrata("BACKGROUND")
      DKROT.Diseases:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
      DKROT.Diseases:SetBackdropColor(0, 0, 0, 0.5)
      DKROT.Diseases.NP = DKROT:CreateIcon("DKROT.Diseases.NP", DKROT.Diseases, 152281, 21)
      DKROT.Diseases.NP:SetParent(DKROT.Diseases)
      DKROT.Diseases.NP:SetPoint("TOPLEFT", DKROT.Diseases, "TOPLEFT", 1, 1)
      DKROT.Diseases.NP:SetBackdropColor(0, 0, 0, 0)
      DKROT.Diseases.NP.Time:SetFont(DKROT.font, 10, "OUTLINE")
      DKROT.Diseases.NP.Stack:SetFont(DKROT.font, 8, "OUTLINE")
      DKROT.Diseases.BP = DKROT:CreateIcon("DKROT.Diseases.BP", DKROT.Diseases, 55078, 21)
      DKROT.Diseases.BP:SetParent(DKROT.Diseases)
      DKROT.Diseases.BP:SetPoint("TOPRIGHT", DKROT.Diseases, "TOPRIGHT", -1, -1)
      DKROT.Diseases.BP:SetBackdropColor(0, 0, 0, 0)
      DKROT.Diseases.FF = DKROT:CreateIcon("DKROT.Diseases.FF", DKROT.Diseases, 55095, 21)
      DKROT.Diseases.FF:SetParent(DKROT.Diseases)
      DKROT.Diseases.FF:SetPoint("RIGHT", DKROT.Diseases.BP, "LEFT", -3, 0)
      DKROT.Diseases.FF:SetBackdropColor(0, 0, 0, 0)
      DKROT:SetupMoveFunction(DKROT.Diseases)

      -- Create the Frame and Icon for the large main Priority Icon
      DKROT.Move = DKROT:CreateIcon('DKROT.Move', DKROT.MainFrame, DKROT.spells["Death Coil"], 47)
      DKROT.Move.Time:SetFont(DKROT.font, 16, "OUTLINE")
      DKROT.Move.Stack:SetFont(DKROT.font, 15, "OUTLINE")
      DKROT:SetupMoveFunction(DKROT.Move)

      -- Mini AOE icon to be placed in the Priority Icon
      DKROT.AOE = DKROT:CreateIcon('DKROT.AOE', DKROT.MainFrame, DKROT.spells["Death Coil"], 47)
      DKROT.AOE:SetPoint("BOTTOMLEFT", DKROT.Move, "BOTTOMLEFT", 2, 2)

      -- Mini Interrupt icon to be placed in the Priority Icon
      DKROT.Interrupt = DKROT:CreateIcon('DKROT.Interrupt', DKROT.MainFrame, DKROT.spells["Mind Freeze"], 47)
      DKROT.Interrupt:SetPoint("TOPRIGHT", DKROT.Move, "TOPRIGHT", -2, -2)
      DKROT:Debug("UI Created")

      DKROT.DT = CreateFrame("Frame", "DKROT.DT", DKROT.MainFrame)
      DKROT.DT:SetHeight(5*25)
      DKROT.DT:SetWidth(180)
      DKROT.DT:SetFrameStrata("BACKGROUND")
      DKROT.DT:SetBackdrop{bgFile = 'Interface\\Tooltips\\UI-Tooltip-Background', tile = false, insets = {left = 0, right = 0, top = 0, bottom = 0},}
      DKROT.DT:SetBackdropColor(0, 0, 0, 0)
      DKROT.DT:SetScale(1)
      DKROT:SetupMoveFunction(DKROT.DT)
      DKROT.DT.Unit = {}
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

      -- Update positional settings
      DKROT.PositionPanel_X:InitValue(x)
      DKROT.PositionPanel_Y:InitValue(y)
      DKROT.PositionPanel_Scale:InitValue(scale)

      UIDropDownMenu_SetSelectedValue(DKROT.PositionPanel_Point, point)
      UIDropDownMenu_SetText(DKROT.PositionPanel_Point, point)

      UIDropDownMenu_SetSelectedValue(DKROT.PositionPanel_RelPoint, relPoint)
      UIDropDownMenu_SetText(DKROT.PositionPanel_RelPoint, relPoint)

      -- Handle some weirdness where the drop down doesnt update correctly
      UIDropDownMenu_Initialize(DKROT_PositionPanel_RelFrame, DKROT_PositionPanel_RelFrame_Init)
      UIDropDownMenu_SetSelectedValue(DKROT.PositionPanel_RelFrame, relFrame)
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
      frame.slider:SetBackdrop({
         bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
         edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
         tile = true, tileSize = 3, edgeSize = 8,
         insets = { left = 3, right = 3, top = 6, bottom = 6 }
      })
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
      frame.editbox:SetBackdrop({
         bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
         edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
         tile = true, tileSize = 1, edgeSize = 2,
      })
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
      local anchorPoints = {
         "TOPLEFT", "TOP", "TOPRIGHT",
         "LEFT", "CENTER", "RIGHT",
         "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"
      }

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

end
