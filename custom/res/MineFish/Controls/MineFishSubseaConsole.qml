import QtQuick
import QtQuick.Layouts
import QtWebEngine

import QGroundControl
import QGroundControl.Controls

/// Embeds the subsea vehicle's own web console (served by the buoy Raspberry Pi over WebSocket) inside
/// the MineFish Fly View. The console's UI lives entirely on the Pi, so changing it is a browser refresh
/// on the Pi's side, not a MineFish Command rebuild.
Item {
    id: root

    readonly property string _consoleUrl: QGroundControl.settingsManager.customSettings.subseaConsoleUrl.rawValue
    readonly property bool _loadFailed: webEngineView.loadStatus === WebEngineView.LoadFailedStatus

    WebEngineView {
        id: webEngineView
        anchors.fill: parent
        url: root._consoleUrl

        property int loadStatus: WebEngineView.LoadSucceededStatus

        onLoadingChanged: (loadRequest) => {
            loadStatus = loadRequest.status
        }
    }

    Rectangle {
        anchors.fill: parent
        color: qgcPal.window
        visible: root._loadFailed

        QGCPalette { id: qgcPal }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: ScreenTools.defaultFontPixelHeight * 0.3

            QGCLabel {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("SUBSEA CONSOLE OFFLINE")
                color: qgcPal.colorOrange
                font.family: ScreenTools.fixedFontFamily
                font.bold: true
                font.pointSize: ScreenTools.largeFontPointSize
            }

            QGCLabel {
                Layout.alignment: Qt.AlignHCenter
                text: root._consoleUrl
                color: qgcPal.colorGrey
                font.family: ScreenTools.fixedFontFamily
                font.pointSize: ScreenTools.smallFontPointSize
            }

            QGCLabel {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Set the buoy Pi's address in Settings > MineFish > Subsea console URL")
                color: qgcPal.colorGrey
                font.pointSize: ScreenTools.smallFontPointSize
            }
        }
    }
}
