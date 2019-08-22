
local function CreateStatusFrame(name, textureFileName)
	local frameName = "HeroStatus" .. name .. "Frame";
	local textureName = "HeroStatus" .. name .. "Texture";

	local frame = CreateFrame("Frame", frameName, UIParent);
	frame:SetSize(32, 32);
	frame:SetBackdropColor(0, 0, 0);
	frame:SetPoint("CENTER");
	frame:SetMovable(false);
	frame:EnableMouse(false);
	frame:SetPoint("CENTER");
	frame:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 20, 20);
	frame:Show();

	local texture = frame:CreateTexture(textureName, "BACKGROUND");
	texture:SetTexture(textureFileName);
	texture:SetAllPoints(frame);

	return frame;
end

local frameRepairStatusOk = CreateStatusFrame('RepairStatusOk', "Interface\\Icons\\Ability_Repair.blp");
local frameRepairStatusOkOverlay = frameRepairStatusOk:CreateTexture('RepairStatusTextureOkOverlay', "OVERLAY");
frameRepairStatusOkOverlay:SetColorTexture(0, 0, 0, 0);
frameRepairStatusOkOverlay:SetAllPoints(frameRepairStatusOk);

local frameRepairStatusWarn = CreateStatusFrame('RepairStatusWarn', "Interface\\Icons\\Ability_Repair.blp");
local frameRepairStatusWarnOverlay = frameRepairStatusWarn:CreateTexture('RepairStatusTextureWarnOverlay', "OVERLAY");
frameRepairStatusWarnOverlay:SetColorTexture(1, 0, 0, 0.25);
frameRepairStatusWarnOverlay:SetAllPoints(frameRepairStatusWarn);

local function IsRepaired()
	local SLOTS = {
		'HeadSlot',
		"ShoulderSlot",
		"ChestSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"MainHandSlot",
		"SecondaryHandSlot"
	}

	for index, value in pairs(SLOTS) do
		local slot = GetInventorySlotInfo(value)
		local current, max = GetInventoryItemDurability(slot)
		if current ~= nil and current ~= max then
			return false
		end
	end
	return true
end

local function update()
	if (IsRepaired()) then
		frameRepairStatusOk:Show();
		frameRepairStatusWarn:Hide();
	else
		frameRepairStatusOk:Hide();
		frameRepairStatusWarn:Show();
	end
end

local frame = CreateFrame("Frame", "HeroStatusFrame", UIParent);
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY");

frame:SetScript("OnEvent", function(self, event, ...)

	if (event == "PLAYER_ENTERING_WORLD") then
		update()
	end

	if (event == "UPDATE_INVENTORY_DURABILITY") then
		update()
	end

end)
