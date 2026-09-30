import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

MineFishPanel {
    id: root

    required property var vehicleStatus

    implicitHeight: ScreenTools.defaultFontPixelHeight * 3.2

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.5
        anchors.rightMargin: ScreenTools.defaultFontPixelWidth * 1.5
        spacing: ScreenTools.defaultFontPixelWidth * 2

        MineFishReadout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            label: qsTr("DEPTH / ALT")
            value: root.vehicleStatus.depthText
            valueColor: root.vehicleStatus.vehicle ? QGroundControl.globalPalette.text : QGroundControl.globalPalette.colorGrey
            large: true
        }

        MineFishReadout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            label: qsTr("SPEED")
            value: root.vehicleStatus.speedText
            valueColor: root.vehicleStatus.vehicle ? QGroundControl.globalPalette.text : QGroundControl.globalPalette.colorGrey
            large: true
        }

        MineFishReadout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            label: qsTr("GPS")
            value: root.vehicleStatus.gpsLockText
            detail: root.vehicleStatus.vehicle ? root.vehicleStatus.gpsSatText + " · " + root.vehicleStatus.gpsHdopText : ""
            valueColor: root.vehicleStatus.gpsColor
            large: true
        }

        MineFishReadout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            label: qsTr("BATTERY")
            value: root.vehicleStatus.batteryPercentText
            detail: root.vehicleStatus.battery ? root.vehicleStatus.batteryVoltageText : ""
            valueColor: root.vehicleStatus.batteryColor
            large: true
        }

        MineFishReadout {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            label: qsTr("CONNECTION")
            value: root.vehicleStatus.linkText
            detail: root.vehicleStatus.linkDetailText
            valueColor: root.vehicleStatus.linkColor
            large: true
        }
    }
}
