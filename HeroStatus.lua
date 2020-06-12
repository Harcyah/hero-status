
local ICON_WIDTH = 32;
local ICON_HEIGHT = 32;
local X_OFFSET = 20;
local Y_OFFSET = 20;
local SPACE = 5;

local INDEX_REPAIR = 0;
local INDEX_EQUIPMENT = 1;
local INDEX_TRANSMOG = 2;
local INDEX_JUNK = 3;
local INDEX_MISSIONS_STATUS_WOD = 4;
local INDEX_MISSIONS_STATUS_BFA = 5;

local DEBUG = false;

local function Log(message)
	if (DEBUG) then
		DEFAULT_CHAT_FRAME:AddMessage(message);
	end
end

local function LogTable(table, indent)
	if not indent then
		indent = 0
	end

	for k, v in pairs(table) do
		local formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			Log(formatting)
			LogTable(v, indent+1)
		else
			Log(formatting .. tostring(v))
		end
	end
end

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
	textureBackground:SetDesaturated(1.0);
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

local function CreateTransmogStatusFrame()
	local textureName = "Interface\\Icons\\garrison_building_armory.blp"
	local frameOk = CreateStatusFrame('EquipmentTransmogOk', textureName, INDEX_TRANSMOG, 0, 0, 0, 0);
	local frameWarn = CreateStatusFrame('EquipmentTransmogWarn', textureName, INDEX_TRANSMOG, 1, 0, 0, 0.25);
	return frameOk, frameWarn
end

local function CreateJunkStatusFrame()
	local textureName = "Interface\\Icons\\Inv_Misc_Food_Lunchbox_White.blp"
	local frameOk = CreateStatusFrame('JunkStatusOk', textureName, INDEX_JUNK, 0, 0, 0, 0);
	local frameWarn = CreateStatusFrame('JunkStatusWarn', textureName, INDEX_JUNK, 1, 0, 0, 0.25);
	return frameOk, frameWarn
end

local function CreateMissionsStatusWodFrame()
	local textureName = "Interface\\Icons\\spell_shadow_demoniccircleteleport.blp"
	local frameOk = CreateStatusFrame('MissionsStatusWodOk', textureName, INDEX_MISSIONS_STATUS_WOD, 0, 0, 0, 0);
	local frameWarn = CreateStatusFrame('MissionsStatusWodWarn', textureName, INDEX_MISSIONS_STATUS_WOD, 1, 0, 0, 0.25);
	return frameOk, frameWarn
end

local function CreateMissionsStatusBfaFrame()
	local textureName = "Interface\\Icons\\inv_currency_petbattle.blp"
	local frameOk = CreateStatusFrame('MissionsStatusBfaOk', textureName, INDEX_MISSIONS_STATUS_BFA, 0, 0, 0, 0);
	local frameWarn = CreateStatusFrame('MissionsStatusBfaWarn', textureName, INDEX_MISSIONS_STATUS_BFA, 1, 0, 0, 0.25);
	return frameOk, frameWarn
end

local frameRepairStatusOk, frameRepairStatusWarn = CreateRepairStatusFrame();
local frameJunkStatusOk, frameJunkStatusWarn = CreateJunkStatusFrame();
local frameEquipmentStatusOk, frameEquipmentStatusWarn = CreateEquipmentStatusFrame();
local frameTransmogStatusOk, frameTransmogStatusWarn = CreateTransmogStatusFrame();
local frameMissionsStatusWodOk, frameMissionsStatusWodWarn = CreateMissionsStatusWodFrame();
local frameMissionsStatusBfaOk, frameMissionsStatusBfaWarn = CreateMissionsStatusBfaFrame();

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

local TRANSMOG_SLOTS = {
	[1]  = { slot = "HEADSLOT", 			transmogType = LE_TRANSMOG_TYPE_APPEARANCE,	armorCategoryID = LE_TRANSMOG_COLLECTION_TYPE_HEAD },
	[2]  = { slot = "SHOULDERSLOT", 		transmogType = LE_TRANSMOG_TYPE_APPEARANCE,	armorCategoryID = LE_TRANSMOG_COLLECTION_TYPE_SHOULDER },
	[3]  = { slot = "BACKSLOT", 			transmogType = LE_TRANSMOG_TYPE_APPEARANCE,	armorCategoryID = LE_TRANSMOG_COLLECTION_TYPE_BACK },
	[4]  = { slot = "CHESTSLOT",		 	transmogType = LE_TRANSMOG_TYPE_APPEARANCE,	armorCategoryID = LE_TRANSMOG_COLLECTION_TYPE_CHEST },
	[5]  = { slot = "TABARDSLOT", 			transmogType = LE_TRANSMOG_TYPE_APPEARANCE,	armorCategoryID = LE_TRANSMOG_COLLECTION_TYPE_TABARD },
	[6]  = { slot = "SHIRTSLOT", 			transmogType = LE_TRANSMOG_TYPE_APPEARANCE,	armorCategoryID = LE_TRANSMOG_COLLECTION_TYPE_SHIRT },
	[7]  = { slot = "WRISTSLOT", 			transmogType = LE_TRANSMOG_TYPE_APPEARANCE,	armorCategoryID = LE_TRANSMOG_COLLECTION_TYPE_WRIST },
	[8]  = { slot = "HANDSSLOT", 			transmogType = LE_TRANSMOG_TYPE_APPEARANCE,	armorCategoryID = LE_TRANSMOG_COLLECTION_TYPE_HANDS },
	[9]  = { slot = "WAISTSLOT", 			transmogType = LE_TRANSMOG_TYPE_APPEARANCE,	armorCategoryID = LE_TRANSMOG_COLLECTION_TYPE_WAIST },
	[10] = { slot = "LEGSSLOT", 			transmogType = LE_TRANSMOG_TYPE_APPEARANCE,	armorCategoryID = LE_TRANSMOG_COLLECTION_TYPE_LEGS },
	[11] = { slot = "FEETSLOT", 			transmogType = LE_TRANSMOG_TYPE_APPEARANCE,	armorCategoryID = LE_TRANSMOG_COLLECTION_TYPE_FEET },
	-- [12] = { slot = "MAINHANDSLOT", 		transmogType = LE_TRANSMOG_TYPE_APPEARANCE,	armorCategoryID = nil },
	-- [13] = { slot = "SECONDARYHANDSLOT", 	transmogType = LE_TRANSMOG_TYPE_APPEARANCE,	armorCategoryID = nil },
	-- [14] = { slot = "MAINHANDSLOT", 		transmogType = LE_TRANSMOG_TYPE_ILLUSION,	armorCategoryID = nil },
	-- [15] = { slot = "SECONDARYHANDSLOT",	transmogType = LE_TRANSMOG_TYPE_ILLUSION,	armorCategoryID = nil },
}

local function IsRepaired()
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

local function HasJunk()
	for i = 0, NUM_BAG_SLOTS do
		for j = 1, GetContainerNumSlots(i) do
			local _, _, _, quality = GetContainerItemInfo(i, j);
			if quality == 0 then
				return true
			end
		end
	end
	return false
end

local function UpdateJunkStatus()
	if (HasJunk()) then
		frameJunkStatusOk:Hide();
		frameJunkStatusWarn:Show();
	else
		frameJunkStatusOk:Show();
		frameJunkStatusWarn:Hide();
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

	local _, _, _, _, numItems, numEquipped, numInInventory, numLost = C_EquipmentSet.GetEquipmentSetInfo(equipmentSetID);

	if (numItems ~= numEquipped) then
		return false;
	end

	if (numInInventory > 0) then
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

local function IsDefaultTransmogApplied()
	local playerLevel = UnitLevel("player")
	if (playerLevel < 15) then
		return true;
	end

	local outfits = C_TransmogCollection.GetOutfits();
	if ( #outfits == 0 ) then
		Log('Unable to find any outfit');
		return false;
	end

	local id
	for i = 1, #outfits do
		if (outfits[i].name == 'Default') then
			id = outfits[i].outfitID
		end
	end
	if (id == nil) then
		Log('Unable to find default outfit');
		return false;
	end

	local appearanceSources, mainHandEnchant, offHandEnchant = C_TransmogCollection.GetOutfitSources(id);
	if (not appearanceSources) then
		Log('No appearances in default outfit');
		return false;
	end

	for index, value in pairs(TRANSMOG_SLOTS) do
		if (TRANSMOG_SLOTS[index].transmogType == LE_TRANSMOG_TYPE_APPEARANCE) then
			local slot = TRANSMOG_SLOTS[index].slot;
			local slotID = GetInventorySlotInfo(slot);
			local expectedSourceID = appearanceSources[slotID]
			local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID = C_Transmog.GetSlotVisualInfo(slotID, LE_TRANSMOG_TYPE_APPEARANCE);

			if (expectedSourceID ~= baseSourceID and appliedSourceID == 0 and expectedSourceID ~= 0) then
				Log('On slot ' .. slot .. ', expected ' .. tostring(expectedSourceID) .. ', but found 0');
				return false
			end

			if (expectedSourceID ~= baseSourceID and appliedSourceID ~= 0 and appliedSourceID ~= expectedSourceID) then
				Log('On slot ' .. slot .. ', expected ' .. tostring(expectedSourceID) .. ', but found ' .. tostring(appliedSourceID));
				return false
			end
		end
	end

	return true
end

local function UpdateTransmogStatus()
	if (IsDefaultTransmogApplied()) then
		frameTransmogStatusOk:Show();
		frameTransmogStatusWarn:Hide();
	else
		frameTransmogStatusOk:Hide();
		frameTransmogStatusWarn:Show();
	end
end

local function HasExpectedMissionReward(mission, expectedRewardItemID)
	local missionRewards = mission.rewards;
	if (missionRewards == nil) then
		return false;
	end

	local firstReward = missionRewards[1];
	if (firstReward == nil) then
		return false;
	end

	local itemID = firstReward.itemID;
	return itemID == expectedRewardItemID;
end

local function IsMissionAvailableWithReward(expansionID, expansionName, expectedReward)
	local missions = C_Garrison.GetAvailableMissions(expansionID);
	if (missions == nil) then
		Log("no mission")
		return false
	end

	for i = 1, #missions do
		local mission = missions[i];
		if (HasExpectedMissionReward(mission, expectedReward) and mission.completed == false and mission.inProgress == false) then
			Log(expansionName .. ' mission ' .. mission.name .. ' has reward !')
			return true;
		end
	end

	Log("no available mission")
	return false
end

local function UpdateMissionsStatusWod()
	if (IsMissionAvailableWithReward(LE_FOLLOWER_TYPE_GARRISON_6_0, "WoD", 128315) == false) then
		frameMissionsStatusWodOk:Show();
		frameMissionsStatusWodWarn:Hide();
	else
		frameMissionsStatusWodOk:Hide();
		frameMissionsStatusWodWarn:Show();
	end
end

local function UpdateMissionsStatusBfa()
	if (IsMissionAvailableWithReward(LE_FOLLOWER_TYPE_GARRISON_8_0, "BFA", 163036) == false) then
		frameMissionsStatusBfaOk:Show();
		frameMissionsStatusBfaWarn:Hide();
	else
		frameMissionsStatusBfaOk:Hide();
		frameMissionsStatusBfaWarn:Show();
	end
end

local function UpdateMissionsStatuses()
	UpdateMissionsStatusWod();
	UpdateMissionsStatusBfa();
end

local eventFrame = CreateFrame("Frame", "HeroStatusFrame", UIParent);
eventFrame:RegisterEvent("BAG_UPDATE");
eventFrame:RegisterEvent("EQUIPMENT_SETS_CHANGED");
eventFrame:RegisterEvent("EQUIPMENT_SWAP_FINISHED");
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
eventFrame:RegisterEvent("TRANSMOGRIFY_SUCCESS");
eventFrame:RegisterEvent("UNIT_INVENTORY_CHANGED");
eventFrame:RegisterEvent("UPDATE_INVENTORY_DURABILITY");
eventFrame:RegisterEvent("TRANSMOG_OUTFITS_CHANGED");
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA");

eventFrame:SetScript("OnEvent", function(self, event, ...)

	if (event == "BAG_UPDATE") then
		UpdateJunkStatus();
		UpdateEquipmentStatus();
		UpdateTransmogStatus();
	end

	if (event == "EQUIPMENT_SETS_CHANGED") then
		UpdateEquipmentStatus();
		UpdateTransmogStatus();
	end

	if (event == "EQUIPMENT_SWAP_FINISHED") then
		UpdateEquipmentStatus();
	end

	if (event == "TRANSMOGRIFY_SUCCESS") then
		UpdateTransmogStatus();
	end

	if (event == "PLAYER_ENTERING_WORLD") then
		UpdateRepairStatus();
		UpdateJunkStatus();
		UpdateEquipmentStatus();
		UpdateTransmogStatus();
		UpdateMissionsStatuses();
	end

	if (event == "UNIT_INVENTORY_CHANGED") then
		UpdateEquipmentStatus();
		UpdateTransmogStatus();
	end

	if (event == "UPDATE_INVENTORY_DURABILITY") then
		UpdateRepairStatus();
	end

	if (event == "TRANSMOG_OUTFITS_CHANGED") then
		UpdateTransmogStatus();
	end

	if (event == "ZONE_CHANGED_NEW_AREA") then
		UpdateMissionsStatuses();
	end

end)
