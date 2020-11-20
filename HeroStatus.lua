
local ICON_WIDTH = 32;
local ICON_HEIGHT = 32;
local X_OFFSET = 20;
local Y_OFFSET = 20;
local SPACE = 5;

local INDEX_REPAIR_STATUS = 0;
local INDEX_EQUIPMENT_STATUS = 1;
local INDEX_TRANSMOG_STATUS = 2;
local INDEX_JUNK_STATUS = 3;
local INDEX_MISSIONS_STATUS_MEDALLION_OF_THE_LEGION = 4;
local INDEX_MISSIONS_STATUS_GLADIATOR_MEDALLION = 5;
local INDEX_MISSIONS_STATUS_POLISHED_PET_CHARM = 6;
local INDEX_MISSIONS_STATUS_TIMEWARPED_BADGE = 7;

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
		local formatting = string.rep('  ', indent) .. k .. ': '
		if type(v) == 'table' then
			Log(formatting)
			LogTable(v, indent+1)
		else
			Log(formatting .. tostring(v))
		end
	end
end

local function CreateStatusFrame(name, textureFileName, index, r, g, b, a)
	local frameName = 'HeroStatus' .. name .. 'Frame';
	local textureBackgroundName = 'HeroStatus' .. name .. 'TextureBackground';
	local textureOverlayName = 'HeroStatus' .. name .. 'TextureOverlay';

	local frame = CreateFrame('Frame', frameName, UIParent, BackdropTemplateMixin and 'BackdropTemplate');
	frame:SetSize(ICON_WIDTH, ICON_HEIGHT);
	frame:SetBackdrop({
		bgFile = 'Interface/Tooltips/UI-Tooltip-Background',
		edgeFile = 'Interface/Tooltips/UI-Tooltip-Border',
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
	frame:SetPoint('CENTER');
	frame:SetMovable(false);
	frame:EnableMouse(false);
	frame:SetPoint('CENTER');
	frame:SetPoint('BOTTOMLEFT', 'UIParent', 'BOTTOMLEFT', X_OFFSET + (index * (ICON_WIDTH + SPACE)), Y_OFFSET);
	frame:Show();

	local textureBackground = frame:CreateTexture(textureBackgroundName, 'ARTWORK');
	textureBackground:SetTexture(textureFileName);
	textureBackground:SetDesaturated(1.0);
	textureBackground:SetAllPoints(frame);

	local textureOverlay = frame:CreateTexture(textureOverlayName, 'OVERLAY');
	textureOverlay:SetColorTexture(r, g, b, a);
	textureOverlay:SetAllPoints(frame);

	return frame;
end

local function CreateStatusFrames(frameName, textureName, index)
	local frameOk = CreateStatusFrame(frameName .. 'Ok', textureName, index, 0, 0, 0, 0);
	local frameWarn = CreateStatusFrame(frameName .. 'Warn', textureName, index, 1, 0, 0, 0.25);
	return frameOk, frameWarn;
end

local function CreateRepairStatusFrame()
	return CreateStatusFrames('RepairStatus', 'Interface\\Icons\\Ability_Repair.blp', INDEX_REPAIR_STATUS);
end

local function CreateEquipmentStatusFrame()
	return CreateStatusFrames('EquipmentStatus', 'Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle.blp', INDEX_EQUIPMENT_STATUS);
end

local function CreateTransmogStatusFrame()
	return CreateStatusFrames('TransmogStatus', 'Interface\\Icons\\garrison_building_armory.blp', INDEX_TRANSMOG_STATUS);
end

local function CreateJunkStatusFrame()
	return CreateStatusFrames('JunkStatus', 'Interface\\Icons\\Inv_Misc_Food_Lunchbox_White.blp', INDEX_JUNK_STATUS);
end

local function CreateMissionsStatusMedallionOfTheLegionFrame()
	return CreateStatusFrames('MissionsStatusMedallionOfTheLegion', 'Interface\\Icons\\spell_shadow_demoniccircleteleport.blp', INDEX_MISSIONS_STATUS_MEDALLION_OF_THE_LEGION);
end

local function CreateMissionsStatusGladiatorMedallionFrame()
	return CreateStatusFrames('MissionsStatusGladiatorMedallion', 'Interface\\Icons\\ability_pvp_gladiatormedallion.blp', INDEX_MISSIONS_STATUS_GLADIATOR_MEDALLION);
end

local function CreateMissionsStatusPolishedPetCharmFrame()
	return CreateStatusFrames('MissionsStatusPolishedPetCharm', 'Interface\\Icons\\inv_currency_petbattle.blp', INDEX_MISSIONS_STATUS_POLISHED_PET_CHARM);
end

local function CreateMissionsStatusTimewarpedBadgeFrame()
	return CreateStatusFrames('MissionsStatusTimewarpedBadge', 'Interface\\Icons\\pvecurrency-justice.blp', INDEX_MISSIONS_STATUS_TIMEWARPED_BADGE);
end

local frameRepairStatusOk, frameRepairStatusWarn = CreateRepairStatusFrame();
local frameJunkStatusOk, frameJunkStatusWarn = CreateJunkStatusFrame();
local frameEquipmentStatusOk, frameEquipmentStatusWarn = CreateEquipmentStatusFrame();
local frameTransmogStatusOk, frameTransmogStatusWarn = CreateTransmogStatusFrame();
local frameMissionsStatusMedallionOfTheLegionOk, frameMissionsStatusMedallionOfTheLegionWarn = CreateMissionsStatusMedallionOfTheLegionFrame();
local frameMissionsStatusGladiatorMedallionOk, frameMissionsStatusGladiatorMedallionWarn = CreateMissionsStatusGladiatorMedallionFrame();
local frameMissionsStatusPolishedPetCharmOk, frameMissionsStatusPolishedPetCharmWarn = CreateMissionsStatusPolishedPetCharmFrame();
local frameMissionsStatusTimewarpedBadgeOk, frameMissionsStatusTimewarpedBadgeWarn = CreateMissionsStatusTimewarpedBadgeFrame();

local SLOTS = {
	'HeadSlot',
	'ShoulderSlot',
	'ChestSlot',
	'WristSlot',
	'HandsSlot',
	'WaistSlot',
	'LegsSlot',
	'FeetSlot',
	'MainHandSlot',
	'SecondaryHandSlot'
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
	local playerLevel = UnitLevel('player')
	if (playerLevel < 15) then
		return true;
	end

	local equipmentSetID = C_EquipmentSet.GetEquipmentSetID('Default');
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
	local playerLevel = UnitLevel('player')
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

	for key, transmogSlot in pairs(TRANSMOG_SLOTS) do
		if transmogSlot.location:IsAppearance() then
			local slotID = transmogSlot.location:GetSlotID();
			if (GetInventoryItemLink('player', slotID) ~= nil) then
				local expectedSourceID = appearanceSources[slotID];
				local baseSourceID, baseVisualID, appliedSourceID, appliedVisualID = C_Transmog.GetSlotVisualInfo(transmogSlot.location);

				if (expectedSourceID ~= baseSourceID and appliedSourceID == 0 and expectedSourceID ~= 0) then
					Log('On slot ' .. slot .. ', expected ' .. tostring(expectedSourceID) .. ', but found 0');
					return false;
				end

				if (expectedSourceID ~= baseSourceID and appliedSourceID ~= 0 and appliedSourceID ~= expectedSourceID) then
					Log('On slot ' .. slot .. ', expected ' .. tostring(expectedSourceID) .. ', but found ' .. tostring(appliedSourceID));
					return false;
				end
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

local function HasExpectedMissionRewardFrom(rewards, expectedRewardFn, expectedRewardID)
	if (rewards == nil) then
		return false;
	end

	local firstReward = rewards[1];
	if (firstReward == nil) then
		return false;
	end

	local rewardID = expectedRewardFn(firstReward);
	return rewardID == expectedRewardID;
end

local function HasExpectedMissionReward(mission, expectedRewardFn, expectedRewardID)
	return HasExpectedMissionRewardFrom(mission.rewards, expectedRewardFn, expectedRewardID) or HasExpectedMissionRewardFrom(mission.overmaxRewards, expectedRewardFn, expectedRewardID);
end

local function UpdateMissionsStatus(expansionID, rewardName, expectedRewardID, expectedRewardFn, frameOk, frameWarn)
	local missions = C_Garrison.GetAvailableMissions(GetPrimaryGarrisonFollowerType(expansionID));
	if (missions == nil) then
		frameOk:Show();
		frameWarn:Hide();
		Log('no mission available for expansion ' .. tostring(expansionID))
		return;
	end

	for i = 1, #missions do
		local mission = missions[i];
		if (HasExpectedMissionReward(mission, expectedRewardFn, expectedRewardID) and mission.completed == false and mission.inProgress == false) then
			frameOk:Hide();
			frameWarn:Show();
			Log('found mission ' .. mission.name .. ' with reward ' .. rewardName)
			return;
		end
	end

	frameOk:Show();
	frameWarn:Hide();
	Log('no mission found on expansion ' .. tostring(expansionID) .. ' for reward ' .. rewardName)
end

local function GetMissionRewardItemId(reward)
	return reward.itemID;
end

local function GetMissionRewardCurrencyId(reward)
	return reward.currencyID;
end

local function UpdateMissionsStatuses()
	UpdateMissionsStatus(
		Enum.GarrisonType.Type_6_0,
		'MedallionOfTheLegion',
		128315,
		GetMissionRewardItemId,
		frameMissionsStatusMedallionOfTheLegionOk,
		frameMissionsStatusMedallionOfTheLegionWarn);
	UpdateMissionsStatus(
		Enum.GarrisonType.Type_7_0,
		'GladiatorMedallion',
		137642,
		GetMissionRewardItemId,
		frameMissionsStatusGladiatorMedallionOk,
		frameMissionsStatusGladiatorMedallionWarn);
	UpdateMissionsStatus(
		Enum.GarrisonType.Type_8_0,
		'TimewarpedBadge',
		1166,
		GetMissionRewardCurrencyId,
		frameMissionsStatusTimewarpedBadgeOk,
		frameMissionsStatusTimewarpedBadgeWarn);
	UpdateMissionsStatus(
		Enum.GarrisonType.Type_8_0,
		'PolishedPetCharm',
		163036,
		GetMissionRewardItemId,
		frameMissionsStatusPolishedPetCharmOk,
		frameMissionsStatusPolishedPetCharmWarn);
end

local eventFrame = CreateFrame('Frame', 'HeroStatusFrame', UIParent);
eventFrame:RegisterEvent('BAG_UPDATE');
eventFrame:RegisterEvent('EQUIPMENT_SETS_CHANGED');
eventFrame:RegisterEvent('EQUIPMENT_SWAP_FINISHED');
eventFrame:RegisterEvent('PLAYER_ENTERING_WORLD');
eventFrame:RegisterEvent('TRANSMOGRIFY_SUCCESS');
eventFrame:RegisterEvent('UNIT_INVENTORY_CHANGED');
eventFrame:RegisterEvent('UPDATE_INVENTORY_DURABILITY');
eventFrame:RegisterEvent('TRANSMOG_OUTFITS_CHANGED');
eventFrame:RegisterEvent('ZONE_CHANGED_NEW_AREA');
eventFrame:RegisterEvent('GARRISON_MISSION_LIST_UPDATE');

eventFrame:SetScript('OnEvent', function(self, event, ...)

	if (event == 'BAG_UPDATE') then
		UpdateJunkStatus();
		UpdateEquipmentStatus();
		UpdateTransmogStatus();
	end

	if (event == 'EQUIPMENT_SETS_CHANGED') then
		UpdateEquipmentStatus();
		UpdateTransmogStatus();
	end

	if (event == 'EQUIPMENT_SWAP_FINISHED') then
		UpdateEquipmentStatus();
	end

	if (event == 'TRANSMOGRIFY_SUCCESS') then
		UpdateTransmogStatus();
	end

	if (event == 'PLAYER_ENTERING_WORLD') then
		UpdateRepairStatus();
		UpdateJunkStatus();
		UpdateEquipmentStatus();
		UpdateTransmogStatus();
		UpdateMissionsStatuses();
	end

	if (event == 'UNIT_INVENTORY_CHANGED') then
		UpdateEquipmentStatus();
		UpdateTransmogStatus();
	end

	if (event == 'UPDATE_INVENTORY_DURABILITY') then
		UpdateRepairStatus();
	end

	if (event == 'TRANSMOG_OUTFITS_CHANGED') then
		UpdateTransmogStatus();
	end

	if (event == 'ZONE_CHANGED_NEW_AREA') then
		UpdateMissionsStatuses();
	end

	if (event == 'GARRISON_MISSION_LIST_UPDATE') then
		UpdateMissionsStatuses();
	end

end)
