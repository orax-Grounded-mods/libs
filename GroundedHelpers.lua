local UEHelpers = require("UEHelpers")
local Grounded = {}

Grounded.textures = {
  icon_Build = "/Game/UI/Images/T_UI_Build.T_UI_Build",
  icon_Sleep = "/Game/UI/Images/FlagIcons/T_UI_Flag_Sleep.T_UI_Flag_Sleep",
  icon_Zipline = "/Game/Blueprints/Items/Icons/Buildings/ICO_BLDG_Zipline_Anchor.ICO_BLDG_Zipline_Anchor",
  icon_CancelBuild = "/Game/UI/Images/ActionIcons/T_UI_CancelBuild.T_UI_CancelBuild",
  icon_Science_RS = "/Game/UI/Images/T_UI_Science_MainChunk.T_UI_Science_MainChunk",
  icon_ChatStop = "/Game/UI/Images/Chat/T_UI_Chat_Stop.T_UI_Chat_Stop"
}

---@param objectFullName string
---@param variableName string
---@param forceInvalidateCache boolean | nil
---@return UObject
local function CacheDefaultObject(objectFullName, variableName, forceInvalidateCache)
  local DefaultObject

  if not forceInvalidateCache then
    DefaultObject = ModRef:GetSharedVariable(variableName)
    if DefaultObject and DefaultObject:IsValid() then
      return DefaultObject
    end
  end

  DefaultObject = StaticFindObject(objectFullName)
  ModRef:SetSharedVariable(variableName, DefaultObject)
  if not DefaultObject:IsValid() then
    error(string.format("%s not found", objectFullName))
  end

  return DefaultObject
end

---@param message string
---@param texturePath string
function Grounded.ShowMessage(message, texturePath)
  ExecuteInGameThread(function()
    local statics = Grounded.SurvivalGameplayStatics()
    local ui = statics:GetGameUI(UEHelpers.GetGameViewportClient())

    if texturePath == nil then
      -- display message without icon
      ui:PostGenericMessage(message, nil)
      return
    end

    local obj = StaticFindObject(texturePath)

    if obj == nil or not obj:IsValid() then
      -- load texture
      LoadAsset(texturePath)
    end

    -- display message with icon
    ui:PostGenericMessage(message, obj)
  end)
end

---@param message string
function Grounded.PostPlayerChatMessage(message)
  ---@type UUserInterfaceStatics
  local statics = Grounded.GetUserInterfaceStatics()

  ---@type USurvivalGameplayStatics
  local survivalGameplayStatics = Grounded.GetSurvivalGameplayStatics()

  if statics and survivalGameplayStatics then
    local ui = statics:GetGameUI(UEHelpers.GetGameViewportClient())
    local state = survivalGameplayStatics:GetLocalSurvivalPlayerState(UEHelpers.GetGameViewportClient())

    ui:PostPlayerChatMessage(FString(message), state)
  end
end

---@param ForceInvalidateCache boolean | nil
---@return UObject
function Grounded.GetSurvivalGameplayStatics(ForceInvalidateCache)
  return CacheDefaultObject("/Script/Maine.Default__SurvivalGameplayStatics", "Grounded_SurvivalGameplayStatics",
    ForceInvalidateCache)
end

---@param ForceInvalidateCache boolean | nil
---@return UObject
function Grounded.GetUserInterfaceStatics(ForceInvalidateCache)
  return CacheDefaultObject("/Script/Maine.Default__UserInterfaceStatics", "Grounded_UserInterfaceStatics",
    ForceInvalidateCache)
end

function Grounded.GetLocalSurvivalPlayerCharacter()
  local statics = Grounded.GetSurvivalGameplayStatics()
  local pc = statics:GetLocalSurvivalPlayerCharacter(UEHelpers.GetGameViewportClient())
  if not pc or not pc:IsValid() then
    error("No LocalSurvivalPlayerCharacter found.\n")
  end

  return pc
end

return Grounded
