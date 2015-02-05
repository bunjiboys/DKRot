if select(2, UnitClass("player")) == "DEATHKNIGHT" then
   local _, DKROT = ...

   DKROT.fpc = CreateFrame("Frame", "DKROT.fpc", DKROT.OptionsFrame)
   DKROT.fpc.name = "fpc Test"
   DKROT.fpc.parent = "DKRot"

   -- Title for the page
   DKROT.fpc.title = DKROT.fpc:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
   DKROT.fpc.title:SetPoint("TOPLEFT", 15, -15)
   DKROT.fpc.title:SetText("Foobar")

   local info = {
      name = 'meepmeep',
      parent = DKROT.fpc,
      label = "Meep Meep Check Button",
      checked = true
   }
   DKROT.fpc.gcd = DKROT:BuildCheckBox(info, function() print("Callback") end)
   DKROT.fpc.gcd:SetPoint("TOPLEFT", DKROT.fpc.title, "BOTTOMLEFT", 0, 0)

   info = {
      name = 'meepmeep2',
      parent = DKROT.fpc,
      label = "Meep Meep Check Button 2",
      checked = false
   }
   DKROT.fpc.meep = DKROT:BuildCheckBox(info, function() print("Callback") end)
   DKROT.fpc.meep:SetPoint("TOPLEFT", DKROT.fpc.gcd, "TOPRIGHT", 10, 0)

   InterfaceOptions_AddCategory(DKROT.fpc)
end
