import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

/// Primary MineFish operator controls. Visual only: no vehicle commands are wired yet, so none of these
/// accept input. Wire each through the guided actions controller (confirmation slider) when ready.
MineFishPanel {
    id: root

    required property var vehicleStatus

    implicitHeight: ScreenTools.defaultFontPixelHeight * 4

    RowLayout {
        anchors.fill: parent
        anchors.margins: ScreenTools.defaultFontPixelWidth
        spacing: ScreenTools.defaultFontPixelWidth

        CommandButton {
            text: root.vehicleStatus.armed ? qsTr("DISARM") : qsTr("ARM")
            dimmed: !root.vehicleStatus.vehicle
            accentColor: root.vehicleStatus.armed ? qgcPal.colorRed : qgcPal.brandPrimary
        }

        CommandButton {
            text: qsTr("DEPLOY MINEFISH")
            dimmed: !root.vehicleStatus.vehicle
            accentColor: qgcPal.colorOrange
            Layout.preferredWidth: 1.6
        }

        CommandButton {
            text: qsTr("DEPTH ▲")
            dimmed: !root.vehicleStatus.vehicle
        }

        CommandButton {
            text: qsTr("DEPTH ▼")
            dimmed: !root.vehicleStatus.vehicle
        }

        CommandButton {
            text: qsTr("CAMERA")
            dimmed: !root.vehicleStatus.vehicle
        }
    }

    QGCPalette { id: qgcPal }

    component CommandButton: Rectangle {
        id: button

        property string text: ""
        property color accentColor: buttonPal.brandPrimary
        property bool dimmed: false

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredWidth: 1

        color: buttonPal.windowShadeDark
        border.color: accentColor
        border.width: 1
        radius: ScreenTools.defaultBorderRadius
        opacity: dimmed ? 0.5 : 1.0

        QGCPalette { id: buttonPal }

        QGCLabel {
            anchors.centerIn: parent
            text: button.text
            color: button.accentColor
            font.family: ScreenTools.fixedFontFamily
            font.bold: true
            font.pointSize: ScreenTools.mediumFontPointSize
            font.letterSpacing: ScreenTools.defaultFontPixelWidth * 0.15
        }
    }
}
