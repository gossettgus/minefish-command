#include "CustomFirmwarePluginFactory.h"
#include "CustomFirmwarePlugin.h"

CustomFirmwarePluginFactory CustomFirmwarePluginFactoryImp;

CustomFirmwarePluginFactory::CustomFirmwarePluginFactory()
    : _pluginInstance(nullptr)
{

}

QList<QGCMAVLink::FirmwareClass_t> CustomFirmwarePluginFactory::supportedFirmwareClasses() const
{
    QList<QGCMAVLink::FirmwareClass_t> firmwareClasses;
    firmwareClasses.append(QGCMAVLink::FirmwareClassArduPilot);
    return firmwareClasses;
}

QList<QGCMAVLink::VehicleClass_t> CustomFirmwarePluginFactory::supportedVehicleClasses() const
{
    QList<QGCMAVLink::VehicleClass_t> vehicleClasses;
    vehicleClasses.append(QGCMAVLink::VehicleClassRoverBoat);
    return vehicleClasses;
}

FirmwarePlugin *CustomFirmwarePluginFactory::firmwarePluginForAutopilot(MAV_AUTOPILOT autopilotType, MAV_TYPE vehicleType)
{
    if (autopilotType == MAV_AUTOPILOT_ARDUPILOTMEGA) {
        if (vehicleType == MAV_TYPE_GROUND_ROVER || vehicleType == MAV_TYPE_SURFACE_BOAT) {
            if (!_pluginInstance) {
                _pluginInstance = new CustomFirmwarePlugin;
            }
            return _pluginInstance;
        }
    }

    return nullptr;
}
