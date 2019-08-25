
local ICON_WIDTH = 32;
local ICON_HEIGHT = 32;
local X_OFFSET = 20;
local Y_OFFSET = 20;
local SPACE = 5;

local INDEX_REPAIR = 0;
local INDEX_EQUIPMENT = 1;

local function CreateStatusFrame(name, textureFileName, index, r, g, b, a)
	local frameName = "HeroStatus" .. name .. "Frame";
	local textureBackgroundName = "HeroStatus" .. name .. "TextureBackground";
	local textureOverlayName = "HeroStatus" .. name .. "TextureOverlay";

	local frame = CreateFrame("Frame", frameName, UIParent);
	frame:SetSize(ICON_WIDTH, ICON_HEIGHT);
	frame:SetBackdrop({
		bgFile = "Interface/Tooltips/UI-Tooltip-Background",
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
		tile = true,
		tileSize = 32,
		edgeSize = 10,
		insets = {
			left = 1,
			right = 1,
			top = 1,
			bottom = 1
		}
	});
	frame:SetBackdropColor(0, 0, 0);
	frame:SetPoint("CENTER");
	frame:SetMovable(false);
	frame:EnableMouse(false);
	frame:SetPoint("CENTER");
	frame:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", X_OFFSET + (index * (ICON_WIDTH + SPACE)), Y_OFFSET);
	frame:Show();

	local textureBackground = frame:CreateTexture(textureBackgroundName, "ARTWORK");
	textureBackground:SetTexture(textureFileName);
	textureBackground:SetAllPoints(frame);

	local textureOverlay = frame:CreateTexture(textureOverlayName, "OVERLAY");
	textureOverlay:SetColorTexture(r, g, b, a);
	textureOverlay:SetAllPoints(frame);

	return frame;
end

local function CreateRepairStatusFrame()
	local textureName = "Interface\\Icons\\Ability_Repair.blp"
	local frameOk = CreateStatusFrame('RepairStatusOk', textureName, INDEX_REPAIR, 0, 0, 0, 0);
	local frameWarn = CreateStatusFrame('RepairStatusWarn', textureName, INDEX_REPAIR, 1, 0, 0, 0.25);
	return frameOk, frameWarn
end

local function CreateEquipmentStatusFrame()
	local textureName = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle.blp"
	local frameOk = CreateStatusFrame('EquipmentStatusOk', textureName, INDEX_EQUIPMENT, 0, 0, 0, 0);
	local frameWarn = CreateStatusFrame('EquipmentStatusWarn', textureName, INDEX_EQUIPMENT, 1, 0, 0, 0.25);
	return frameOk, frameWarn
end

local frameRepairStatusOk, frameRepairStatusWarn = CreateRepairStatusFrame()
local frameEquipmentStatusOk, frameEquipmentStatusWarn = CreateEquipmentStatusFrame()

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

local function UpdateRepairStatus()
	if (IsRepaired()) then
		frameRepairStatusOk:Show();
		frameRepairStatusWarn:Hide();
	else
		frameRepairStatusOk:Hide();
		frameRepairStatusWarn:Show();
	end
end

local function IsDefaultEquipmentSetValid()
	local playerLevel = UnitLevel("player")
	if (playerLevel < 15) then
		return true;
	end

	local equipmentSetID = C_EquipmentSet.GetEquipmentSetID("Default");
	if (equipmentSetID == nil) then
		return false;
	end

	local _, _, _, _, numItems, numEquipped, numInInventory, numLost, numIgnored = C_EquipmentSet.GetEquipmentSetInfo(equipmentSetID);

	if (numItems ~= numEquipped) then
		return false;
	end

	if (numLost > 0) then
		return false;
	end

	return true;
end

local function UpdateEquipmentStatus()
	if (IsDefaultEquipmentSetValid()) then
		frameEquipmentStatusOk:Show();
		frameEquipmentStatusWarn:Hide();
	else
		frameEquipmentStatusOk:Hide();
		frameEquipmentStatusWarn:Show();
	end
end

local eventFrame = CreateFrame("Frame", "HeroStatusFrame", UIParent);
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
eventFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY");
eventFrame:RegisterEvent("EQUIPMENT_SETS_CHANGED");
eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED");

eventFrame:SetScript("OnEvent", function(self, event, ...)

	if (event == "PLAYER_ENTERING_WORLD") then
		UpdateRepairStatus();
		UpdateEquipmentStatus();
	end

	if (event == "UPDATE_INVENTORY_DURABILITY") then
		UpdateRepairStatus();
	end

	if (event == "EQUIPMENT_SETS_CHANGED") then
		UpdateEquipmentStatus();
	end

	if (event == "UNIT_INVENTORY_CHANGED") then
		UpdateEquipmentStatus();
	end

end)
