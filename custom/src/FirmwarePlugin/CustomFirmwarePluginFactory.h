#pragma once

#include "FirmwarePluginFactory.h"
#include "QGCMAVLink.h"

class CustomFirmwarePlugin;
class FirmwarePlugin;

/// This custom implementation of FirmwarePluginFactory creates a custom build which only supports
/// ArduPilot firmware running on a ground/surface rover (boat) vehicle. This in turn removes portions
/// of the QGC UI related to other firmware and vehicle types, creating a more simplified UI for the
/// MineFish boat.
class CustomFirmwarePluginFactory : public FirmwarePluginFactory
{
    Q_OBJECT

public:
    CustomFirmwarePluginFactory();
    QList<QGCMAVLink::FirmwareClass_t> supportedFirmwareClasses() const final;
    QList<QGCMAVLink::VehicleClass_t> supportedVehicleClasses() const final;
    FirmwarePlugin *firmwarePluginForAutopilot(MAV_AUTOPILOT autopilotType, MAV_TYPE vehicleType) final;

private:
    CustomFirmwarePlugin *_pluginInstance = nullptr;
};

extern CustomFirmwarePluginFactory CustomFirmwarePluginFactoryImp;
