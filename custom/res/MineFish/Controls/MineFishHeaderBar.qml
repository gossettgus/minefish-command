import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView
import QGroundControl.Toolbar

/// MineFish replacement for FlyViewToolBar: branding, link/GPS/battery/state summary, guided action
/// confirmation and the app menu.
Item {
    id: root

    required property var guidedValueSlider
    required property var vehicleStatus

    // Read through the instantiation scope by MainStatusIndicator and GuidedActionConfirm, which were
    // written to live inside FlyViewToolBar. Do not rename.
    property bool _communicationLost: root.vehicleStatus.commLost
    property color _mainStatusBGColor: qgcPal.brandPrimary
    property real _margins: ScreenTools.defaultFontPixelWidth / 2

    readonly property real _cellSpacing: ScreenTools.defaultFontPixelWidth * 3

    implicitHeight: ScreenTools.toolbarHeight

    function dropMainStatusIndicatorTool() {
        mainStatusIndicator.dropMainStatusIndicator()
    }

    function _stateColor() {
        if (!root.vehicleStatus.vehicle) {
            return qgcPal.colorGrey
        }
        if (Qt.colorEqual(_mainStatusBGColor, "red")) {
            return qgcPal.colorRed
        }
        if (Qt.colorEqual(_mainStatusBGColor, "yellow")) {
            return qgcPal.colorYellow
        }
        return qgcPal.colorGreen
    }

    QGCPalette { id: qgcPal }

    MineFishPanel {
        anchors.fill: parent
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: ScreenTools.defaultFontPixelWidth * 1.5
        anchors.rightMargin: ScreenTools.defaultFontPixelWidth
        spacing: root._cellSpacing

        ColumnLayout {
            spacing: 0

            QGCLabel {
                text: qsTr("MINEFISH COMMAND")
                color: qgcPal.brandPrimary
                font.family: ScreenTools.fixedFontFamily
                font.bold: true
                font.pointSize: ScreenTools.largeFontPointSize
                font.letterSpacing: ScreenTools.defaultFontPixelWidth * 0.2
            }

            Image {
                // Delozier Calloway wordmark, cropped to content (aspect ratio ~2.73:1).
                // implicitWidth/Height are read-only on Image, so size it via Layout.preferred* instead.
                readonly property real _aspectRatio: 2.73

                source: "qrc:/custom/img/DeloziersLogoWhite.png"
                fillMode: Image.PreserveAspectFit
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.85
                Layout.preferredWidth: Layout.preferredHeight * _aspectRatio
                sourceSize.height: Layout.preferredHeight
                sourceSize.width: Layout.preferredWidth
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            GuidedActionConfirm {
                id: guidedActionConfirm
                anchors.centerIn: parent
                height: parent.height
                guidedController: globals.guidedControllerFlyView
                guidedValueSlider: root.guidedValueSlider
                messageDisplay: guidedActionMessageDisplay
            }
        }

        MineFishReadout {
            label: qsTr("LINK")
            value: root.vehicleStatus.linkText
            valueColor: root.vehicleStatus.linkColor
        }

        MineFishReadout {
            label: qsTr("GPS")
            value: root.vehicleStatus.gpsSatText
            valueColor: root.vehicleStatus.gpsColor
        }

        MineFishReadout {
            label: qsTr("BATTERY")
            value: root.vehicleStatus.batteryPercentText
            valueColor: root.vehicleStatus.batteryColor
        }

        RowLayout {
            spacing: ScreenTools.defaultFontPixelWidth * 0.8

            Rectangle {
                Layout.alignment: Qt.AlignVCenter
                implicitWidth: ScreenTools.defaultFontPixelWidth * 1.2
                implicitHeight: implicitWidth
                radius: width / 2
                color: root._stateColor()
            }

            ColumnLayout {
                spacing: 0

                QGCLabel {
                    text: root.vehicleStatus.vehicle ? qsTr("STATE · %1").arg(root.vehicleStatus.flightModeText) : qsTr("STATE")
                    color: qgcPal.colorGrey
                    font.pointSize: ScreenTools.smallFontPointSize
                    font.letterSpacing: ScreenTools.defaultFontPixelWidth * 0.12
                }

                // Stock indicator kept for its health/arming-check drawer, vehicle messages and manual connect page.
                MainStatusIndicator {
                    id: mainStatusIndicator
                    Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.4
                }
            }
        }

        QGCButton {
            text: qsTr("MENU")
            onClicked: mainWindow.showToolSelectDialog()
        }
    }

    // Outside the RowLayout so it can extend below the header without affecting layout.
    Rectangle {
        id: guidedActionMessageDisplay
        anchors.top: root.bottom
        anchors.topMargin: root._margins
        x: root.mapFromItem(guidedActionConfirm.parent, guidedActionConfirm.x, 0).x + (guidedActionConfirm.width - width) / 2
        width: messageLabel.contentWidth + (root._margins * 2)
        height: messageLabel.contentHeight + (root._margins * 2)
        color: qgcPal.windowTransparent
        border.color: qgcPal.groupBorder
        radius: ScreenTools.defaultBorderRadius
        visible: guidedActionConfirm.visible

        QGCLabel {
            id: messageLabel
            x: root._margins
            y: root._margins
            width: ScreenTools.defaultFontPixelWidth * 30
            wrapMode: Text.WordWrap
            text: guidedActionConfirm.message
        }

        PropertyAnimation {
            id: messageOpacityAnimation
            target: guidedActionMessageDisplay
            property: "opacity"
            from: 1
            to: 0
            duration: 500
        }

        Timer {
            id: messageFadeTimer
            interval: 4000
            onTriggered: messageOpacityAnimation.start()
        }
    }

    ParameterDownloadProgress {
        anchors.fill: parent
    }
}
