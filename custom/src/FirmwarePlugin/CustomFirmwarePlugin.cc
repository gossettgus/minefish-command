#include "CustomFirmwarePlugin.h"

CustomFirmwarePlugin::CustomFirmwarePlugin()
{
    for (auto &mode: _flightModeList) {
        //-- Narrow the mode options to only these: hold in place, return to launch, and run the loaded
        //   mission. These accessors are firmware-generic (each FirmwarePlugin subclass names its own
        //   Hold/RTL/Auto-equivalent mode), so this restriction carries over correctly across firmware.
        if ((mode.mode_name != pauseFlightMode()) && (mode.mode_name != rtlFlightMode()) && (mode.mode_name != missionFlightMode())) {
            // No other flight modes can be set
            mode.canBeSet = false;
        }
    }
}

const QVariantList& CustomFirmwarePlugin::toolIndicators(const Vehicle *vehicle)
{
    if (_toolIndicatorList.size() == 0) {
        // First call the base class to get the standard ArduPilot list. This way we are guaranteed to
        // always get any new toolbar indicators which are added upstream in our custom build.
        _toolIndicatorList = ArduRoverFirmwarePlugin::toolIndicators(vehicle);
        // Then specifically remove the RC RSSI indicator.
        _toolIndicatorList.removeOne(QVariant::fromValue(QUrl::fromUserInput("qrc:/qml/QGroundControl/Toolbar/RCRSSIIndicator.qml")));
    }

    return _toolIndicatorList;
}

void CustomFirmwarePlugin::updateAvailableFlightModes(FlightModeList &modeList)
{
    // This custom build only allows Hold, RTL and Auto (mission) to be set by the user.
    for (auto &mode: modeList) {
        const APMRoverMode::Mode rMode = static_cast<APMRoverMode::Mode>(mode.custom_mode);
        mode.canBeSet = (rMode == APMRoverMode::HOLD) ||
                        (rMode == APMRoverMode::RTL) ||
                        (rMode == APMRoverMode::AUTO);
    }

    // Let the base class do the standard ArduRover mode-list bookkeeping.
    ArduRoverFirmwarePlugin::updateAvailableFlightModes(modeList);
}
