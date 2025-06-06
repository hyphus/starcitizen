Set-StrictMode -Version "Latest"
$ErrorActionPreference = "Stop"

#############################################################################
#
# You have to have launched into the game menu at least once for this to work
# Running this more than once will result in duplicate keybinds
#
#############################################################################

# Set these to the appropriate values
$sc_path = "X:\Games\StarCitizen\StarCitizen\LIVE\"

$sc_profile_path = (Join-Path -Path $sc_path -ChildPath "USER\Client\0\Profiles\default")
$sc_character_path = (Join-Path -Path $sc_path -ChildPath "USER\Client\0\CustomCharacters\")
$joy_to_key_path = (Join-Path -Path $env:USERPROFILE -ChildPath "Documents\JoyToKey")

# Custom control mappings
$control_mapping_file_path = "X:\Games\StarCitizen\Settings\layout_hosas_exported.xml"

# USER.cfg
$usercfg = @'
;This is a command that used to unlock the console to allow commands
Con_Restricted = 0

r_displayinfo = 0

sys_maxFPS = 175
sys_maxIdleFPS = 60
'@

# These are the values that should match the name/value in attributes.xml
$settings = @{
    AudioMasterVolume                                 = 0.5
    AudioMusicVolume                                  = 0
    AudioSfxVolume                                    = 0.5
    AudioShipComputerSpeechVolume                     = 0.5
    AudioSimulationAnnouncerVolume                    = 0.5
    AudioSpeechVolume                                 = 0.5
    AutoZoomOnSelectedTarget                          = 0
    Brightness                                        = 0.51
    ChromaticAberration                               = 0
    Contrast                                          = 0.55
    ControlHintsEnabled                               = 0
    EnableLevelActivatedVoiceTransmission             = 0
    EnableFacewareSystemLive                          = 0
    EspDampening                                      = 1
    EspZoneOuter                                      = 8
    EspZoneSize                                       = 20
    FilmGrain                                         = 0
    FlightGSafeDefaultOn                              = 0
    FlightController_Setting_AdvancedHudLabelsEnabled = 1
    FlightController_Setting_AdvancedHudNavEnabled    = 1
    FlightController_Setting_AdvancedHudScmEnabled    = 1
    FlightGSafeDisableOnBoost                         = 1
    FlightProximityAssist                             = 0
    FlightSpacebrakeEnablesBoost                      = 1
    FOV                                               = 67.6728 # This is 100 in the UI settings
    Gamma                                             = 0.9
    GForceHeadBobScale                                = 0.25
    GForceBoostZoomScale                              = 0
    HDR                                               = 0
    HeadtrackingDisableDuringIM                       = 1
    HeadtrackingDisableDuringMobiGlas                 = 1
    HeadtrackingInactivityTime                        = 2
    HeadtrackingSource                                = 3
    HeadtrackingToggle                                = 1
    MotionBlur                                        = 0
    ShakeScale                                        = 0
    Sharpening                                        = 0
    ShowContactFriendlyNameplate                      = 1
    ShowContactNeutralHostileNameplate                = 1 
    ShowHints                                         = 0
    SysSpec                                           = 4
    SysSpecGameEffects                                = 3
    SysSpecGasCloud                                   = 3
    SysSpecObjectDetail                               = 3
    SysSpecParticles                                  = 3
    SysSpecPlanetVolumetricClouds                     = 2
    SysSpecPostProcessing                             = 3
    SysSpecShading                                    = 3
    SysSpecShadows                                    = 3
    SysSpecWater                                      = 3
    TerrainTessDistance                               = 50
    TobiiGazeResponsiveness_Profile0                  = 0.7
    TobiiHeadCenterStabilization_Profile0             = 0.7
    TobiiHeadPositionDeadZoneX                        = 0.6
    TobiiHeadPositionDeadZoneY                        = 0.6
    TobiiHeadPositionDeadZoneZ                        = 0.6
    TobiiHeadPositionScale                            = 3
    TobiiHeadSensitivityPitch_Profile0                = 2.7
    TobiiHeadSensitivityRoll_Profile0                 = 1
    TobiiHeadSensitivityRoll_Profile1                 = 1
    TobiiHeadSensitivityYaw_Profile0                  = 2.7
    TurretsEspDampening                               = 1
    TurretsEspZoneOuter                               = 8
    TurretsEspZoneSize                                = 20
    VehicleWeaponRecoilScale                          = 0
    VelocityIndicatorDisplayMode                      = 0
    VelocityIndicatorDisplayType                      = 2
    VJoySizePitch                                     = 8
    VJoySizeYaw                                       = 8
    VJoyTurretSizePitch                               = 8
    VJoyTurretSizeYaw                                 = 8
    VSync                                             = 0
    WeaponGimbalDefaultModeSpaceship                  = 0
    WindowMode                                        = 2
}

# Load the config and update the values
[xml]$attributes = Get-Content -Path (Join-Path -Path $sc_profile_path -ChildPath "attributes.xml")
foreach ($key in $settings.Keys) {
    $attr = $attributes.Attributes.SelectNodes("//Attr[@name='$($key)']")
    if ($attr.Count -ne 0) {
        $attr.SetAttribute("value", $settings[$key])
    }
    else {
        # If the settings don't exist, add them
        $node = $attributes.CreateElement("Attr")
        $node.SetAttribute("name", $key)
        $node.SetAttribute("value", $settings[$key])
        $attributes.Attributes.AppendChild($node) | Out-Null
    }
}

# Load exported keybindings directly into current config
[xml]$actionmaps = Get-Content -Path (Join-Path -Path $sc_profile_path -ChildPath "actionmaps.xml")
[xml]$keybinds = Get-Content -Path $control_mapping_file_path
foreach ($bind in $keybinds.ActionMaps.actionmap) {
    $actionmaps.ActionMaps.ActionProfiles.AppendChild($actionmaps.ImportNode($bind, $true)) | Out-Null
}

# Loads device specific options directly into current config
foreach ($bind in $keybinds.ActionMaps.options) {
    if ($bind.HasChildNodes) {
        # There has to be a better way to do this.
        foreach ($child in $bind.ChildNodes) {
            ($actionmaps.ActionMaps.ActionProfiles.SelectNodes("//options[@type='$($bind.type)'][@instance='$($bind.instance)']")).AppendChild($actionmaps.ImportNode($child, $true)) | Out-Null
        }
    }
}

# JoyToKey configs
Copy-Item -Force -Path "joytokey/*" -Destination $joy_to_key_path

# Saved camera views
Copy-Item -Force -Path "savedviews.xml" -Destination (Join-Path -Path $sc_profile_path -ChildPath "savedviews.xml")

# Custom characters
New-Item -Path $sc_character_path -ItemType Directory -Force
Copy-Item -Force -Path "characters/*" -Destination "$sc_character_path/"

# Save everything
$usercfg | Out-File -FilePath (Join-Path -Path $sc_path -ChildPath "USER.cfg") -Encoding utf8
$attributes.Save((Join-Path -Path $sc_profile_path -ChildPath "attributes.xml"))

# Comment out if you don't want to apply keybinds
$actionmaps.Save((Join-Path -Path $sc_profile_path -ChildPath "actionmaps.xml"))

Write-Output "Settings updated."