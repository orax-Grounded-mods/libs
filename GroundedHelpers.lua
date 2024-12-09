local UEHelpers = require("UEHelpers")
local M = {}

M.textures = {
  icon_Build = "/Game/UI/Images/T_UI_Build.T_UI_Build",
  icon_Sleep = "/Game/UI/Images/FlagIcons/T_UI_Flag_Sleep.T_UI_Flag_Sleep",
  icon_Zipline = "/Game/Blueprints/Items/Icons/Buildings/ICO_BLDG_Zipline_Anchor.ICO_BLDG_Zipline_Anchor",
  icon_CancelBuild = "/Game/UI/Images/ActionIcons/T_UI_CancelBuild.T_UI_CancelBuild",
  icon_Science_RS = "/Game/UI/Images/T_UI_Science_MainChunk.T_UI_Science_MainChunk",
  icon_ChatStop = "/Game/UI/Images/Chat/T_UI_Chat_Stop.T_UI_Chat_Stop",
  icon_Storage = "/Game/UI/Images/T_UI_Storage.T_UI_Storage"
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
function M.ShowMessage(message, texturePath)
  ExecuteInGameThread(function()
    local statics = M.GetUserInterfaceStatics()
    local ui = statics:GetGameUI(UEHelpers.GetGameViewportClient())

    if texturePath == nil then
      -- display message without icon
      ---@diagnostic disable-next-line: param-type-mismatch
      ui:PostGenericMessage(message, nil)
      return
    end

    local obj = StaticFindObject(texturePath)

    ---@cast obj UTexture2D
    if not obj:IsValid() then
      -- load texture
      LoadAsset(texturePath)
    end

    -- display message with icon
    ---@diagnostic disable-next-line: param-type-mismatch
    ui:PostGenericMessage(message, obj)
  end)
end

---@param message string
function M.PostPlayerChatMessage(message)
  local uistatics = M.GetUserInterfaceStatics()
  local survivalGameplayStatics = M.GetSurvivalGameplayStatics()

  ---@cast uistatics UUserInterfaceStatics
  ---@cast survivalGameplayStatics USurvivalGameplayStatics

  if uistatics and survivalGameplayStatics then
    local ui = uistatics:GetGameUI(UEHelpers.GetGameViewportClient())
    local state = survivalGameplayStatics:GetLocalSurvivalPlayerState(UEHelpers.GetGameViewportClient())

    ui:PostPlayerChatMessage(FString(message), state)
  end
end

---@param ForceInvalidateCache boolean | nil
---@return USurvivalGameplayStatics
function M.GetSurvivalGameplayStatics(ForceInvalidateCache)
  ---@diagnostic disable-next-line: return-type-mismatch
  return CacheDefaultObject("/Script/Maine.Default__SurvivalGameplayStatics", "Grounded_SurvivalGameplayStatics",
    ForceInvalidateCache)
end

---@param ForceInvalidateCache boolean | nil
---@return UUserInterfaceStatics
function M.GetUserInterfaceStatics(ForceInvalidateCache)
  ---@diagnostic disable-next-line: return-type-mismatch
  return CacheDefaultObject("/Script/Maine.Default__UserInterfaceStatics", "Grounded_UserInterfaceStatics",
    ForceInvalidateCache)
end

function M.GetLocalSurvivalPlayerCharacter()
  local survivalGameplayStatics = M.GetSurvivalGameplayStatics()
  ---@cast survivalGameplayStatics USurvivalGameplayStatics
  local pc = survivalGameplayStatics:GetLocalSurvivalPlayerCharacter(UEHelpers.GetGameViewportClient())
  if not pc or not pc:IsValid() then
    error("No LocalSurvivalPlayerCharacter found.\n")
  end

  return pc
end

return M
