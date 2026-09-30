#pragma once

#include "ArduRoverFirmwarePlugin.h"

class Vehicle;

/// MineFish runs exclusively on ArduPilot (ArduRover) boats, so this narrows the stock ArduRover plugin
/// down to the MineFish product surface: a reduced tool-indicator bar and a reduced set of user-settable
/// flight modes. Vehicle setup, parameters and everything else are the stock ArduRover behavior.
class CustomFirmwarePlugin : public ArduRoverFirmwarePlugin
{
    Q_OBJECT

public:
    CustomFirmwarePlugin();

    // FirmwarePlugin overrides

    const QVariantList &toolIndicators(const Vehicle *vehicle) final;
    void updateAvailableFlightModes(FlightModeList &modeList) final;

private:
    QVariantList _toolIndicatorList;
};
