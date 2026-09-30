import QtQuick

import QGroundControl

/// Formats active vehicle telemetry for the MineFish HUD. Shared by the header and telemetry bars so
/// both always agree on text and safety colors.
QtObject {
    readonly property var vehicle: QGroundControl.multiVehicleManager.activeVehicle
    readonly property var qgcPal: QGroundControl.globalPalette

    readonly property string noValue: "--"

    // Link
    readonly property bool commLost: vehicle ? vehicle.vehicleLinkManager.communicationLost : false
    readonly property string linkText: !vehicle ? qsTr("NO VEHICLE") : (commLost ? qsTr("LOST") : qsTr("ONLINE"))
    readonly property string linkDetailText: vehicle ? vehicle.vehicleLinkManager.primaryLinkName : ""
    readonly property color linkColor: !vehicle ? qgcPal.colorGrey : (commLost ? qgcPal.colorRed : qgcPal.colorGreen)

    // Arming
    readonly property bool armed: vehicle ? vehicle.armed : false
    readonly property string armedText: !vehicle ? qsTr("OFFLINE") : (armed ? qsTr("ARMED") : qsTr("DISARMED"))
    readonly property color armedColor: !vehicle ? qgcPal.colorGrey : (armed ? qgcPal.colorRed : qgcPal.colorGreen)
    readonly property string flightModeText: vehicle ? vehicle.flightMode.toUpperCase() : noValue

    // Depth / altitude and speed
    readonly property string depthText: vehicle ? _factText(vehicle.altitudeRelative) : noValue
    readonly property string speedText: vehicle ? _factText(vehicle.groundSpeed) : noValue

    // GPS
    readonly property int _gpsLock: vehicle ? vehicle.gps.lock.rawValue : 0
    readonly property int _gpsCount: vehicle ? vehicle.gps.count.rawValue : 0
    readonly property string gpsSatText: vehicle ? qsTr("%1 SAT").arg(_gpsCount) : noValue
    readonly property string gpsLockText: {
        if (!vehicle) {
            return noValue
        }
        switch (_gpsLock) {
        case 2:
            return qsTr("2D")
        case 3:
            return qsTr("3D")
        case 4:
            return qsTr("DGPS")
        case 5:
            return qsTr("RTK FLT")
        case 6:
            return qsTr("RTK FIX")
        case 7:
            return qsTr("STATIC")
        default:
            return qsTr("NO FIX")
        }
    }
    readonly property string gpsHdopText: vehicle ? qsTr("HDOP %1").arg(vehicle.gps.hdop.valueString) : noValue
    readonly property color gpsColor: !vehicle ? qgcPal.colorGrey : (_gpsLock >= 3 ? qgcPal.colorGreen : qgcPal.colorOrange)

    // Battery (first reported battery)
    readonly property var battery: vehicle && vehicle.batteries.count > 0 ? vehicle.batteries.get(0) : null
    readonly property bool _batteryPercentValid: battery ? !isNaN(battery.percentRemaining.rawValue) : false
    readonly property string batteryPercentText: _batteryPercentValid ? Math.round(battery.percentRemaining.rawValue) + "%" : noValue
    readonly property string batteryVoltageText: battery && !isNaN(battery.voltage.rawValue) ? battery.voltage.valueString + " " + battery.voltage.units : noValue
    readonly property color batteryColor: {
        if (!battery) {
            return qgcPal.colorGrey
        }
        switch (battery.chargeState.rawValue) {
        case MAVLinkEnums.MAV_BATTERY_CHARGE_STATE_LOW:
            return qgcPal.colorOrange
        case MAVLinkEnums.MAV_BATTERY_CHARGE_STATE_CRITICAL:
        case MAVLinkEnums.MAV_BATTERY_CHARGE_STATE_EMERGENCY:
        case MAVLinkEnums.MAV_BATTERY_CHARGE_STATE_FAILED:
        case MAVLinkEnums.MAV_BATTERY_CHARGE_STATE_UNHEALTHY:
            return qgcPal.colorRed
        default:
            return _batteryPercentValid ? qgcPal.colorGreen : qgcPal.text
        }
    }

    // Position
    readonly property string positionText: vehicle && vehicle.coordinate.isValid
                                           ? vehicle.coordinate.latitude.toFixed(6) + ", " + vehicle.coordinate.longitude.toFixed(6)
                                           : noValue

    function _factText(fact) {
        if (!fact || isNaN(fact.rawValue)) {
            return noValue
        }
        return fact.valueString + " " + fact.units
    }
}
