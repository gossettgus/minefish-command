import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FlyView
import QGroundControl.FlightMap

import MineFish.Controls

/// MineFish Command replacement for the upstream FlyView. Map and camera are shown side by side using the
/// stock FlyViewMap/FlyViewVideo backends; the stock toolbar, tool strip, PiP swap and widget layer are
/// replaced by MineFish header, telemetry and control bars.
Item {
    id: _root

    // Used by MainWindow
    property var planController: _planController
    property var guidedController: _guidedController

    // Read through the instantiation scope by FlyViewMap, FlyViewGeoMapAdapter and GuidedActionsController.
    // Keep these names in sync with upstream FlyView.qml.
    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property var _missionController: _planController.missionController
    property var _guidedController: guidedActionsController
    property var _guidedValueSlider: guidedValueSlider
    property var _mapControl: mapEngineLoader.item
    property bool _isFullWindowItemDark: _mapControl ? _mapControl.isSatelliteMap : true

    readonly property bool _videoFullScreen: QGroundControl.videoManager.fullScreen
    readonly property real _spacing: ScreenTools.defaultFontPixelWidth * 0.75

    // Called by MainWindow when a critical vehicle message needs attention
    function dropMainStatusIndicatorTool() {
        headerBar.dropMainStatusIndicatorTool()
    }

    PlanMasterController {
        id: _planController
        flyView: true
        Component.onCompleted: start()
    }

    MineFishVehicleStatus {
        id: mineFishStatus
    }

    // Map and camera panes are dedicated, so nothing overlaps the map viewport.
    QGCToolInsets {
        id: _mapToolInsets
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: _root._spacing
        spacing: _root._spacing

        MineFishHeaderBar {
            id: headerBar
            Layout.fillWidth: true
            z: QGroundControl.zOrderTopMost
            guidedValueSlider: _root._guidedValueSlider
            vehicleStatus: mineFishStatus
            visible: !_root._videoFullScreen
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: _root._spacing

            MineFishPanel {
                id: mapPane
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                title: qsTr("MAP")
                visible: !_root._videoFullScreen

                // Map engine switch (issue #14901), mirrors upstream FlyView. The loaded map is reparented
                // into this pane by its PipState via mapPipView.
                Loader {
                    id: mapEngineLoader
                    Component.onCompleted: sourceComponent = QGroundControl.settingsManager.flyViewSettings.useGeoMapEngine.rawValue ? geoMapEngineComponent : qtLocationEngineComponent
                }

                // Hosts the map only, which keeps it permanently in full state filling this pane.
                PipView {
                    id: mapPipView
                    item1IsFullSettingsKey: "MineFishMapIsFull"
                    item1: _root._mapControl
                    show: false
                }

                VehicleWarnings {
                    anchors.centerIn: parent
                    z: QGroundControl.zOrderTopMost
                }

                QGCLabel {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: ScreenTools.defaultFontPixelWidth
                    z: QGroundControl.zOrderWidgets
                    text: mineFishStatus.positionText
                    color: QGroundControl.globalPalette.brandPrimary
                    font.family: ScreenTools.fixedFontFamily
                    font.pointSize: ScreenTools.smallFontPointSize
                    visible: mineFishStatus.vehicle

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -ScreenTools.defaultFontPixelWidth * 0.5
                        z: -1
                        color: QGroundControl.globalPalette.windowTransparent
                    }
                }
            }

            MineFishPanel {
                id: videoPane
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                title: qsTr("CAMERA")

                FlyViewVideo {
                    id: videoControl
                    pipView: videoPipView
                }

                // Hosts the video only, which keeps it permanently in full state filling this pane.
                PipView {
                    id: videoPipView
                    item1IsFullSettingsKey: "MineFishVideoIsFull"
                    item1: videoControl
                    show: false
                }

                Rectangle {
                    anchors.fill: parent
                    z: QGroundControl.zOrderWidgets
                    color: QGroundControl.globalPalette.window
                    visible: !QGroundControl.videoManager.decoding && !QGroundControl.videoManager.isUvc

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: ScreenTools.defaultFontPixelHeight * 0.3

                        QGCLabel {
                            Layout.alignment: Qt.AlignHCenter
                            text: QGroundControl.videoManager.hasVideo ? qsTr("WAITING FOR VIDEO") : qsTr("NO VIDEO SIGNAL")
                            color: QGroundControl.videoManager.hasVideo ? QGroundControl.globalPalette.colorOrange : QGroundControl.globalPalette.colorGrey
                            font.family: ScreenTools.fixedFontFamily
                            font.bold: true
                            font.pointSize: ScreenTools.largeFontPointSize
                        }

                        QGCLabel {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Configure the video source in Application Settings > Video")
                            color: QGroundControl.globalPalette.colorGrey
                            font.pointSize: ScreenTools.smallFontPointSize
                            visible: !QGroundControl.videoManager.hasVideo
                        }

                        QGCLabel {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("Double-click to exit full screen")
                            color: QGroundControl.globalPalette.colorGrey
                            font.pointSize: ScreenTools.smallFontPointSize
                            visible: _root._videoFullScreen
                        }
                    }
                }
            }

            MineFishPanel {
                id: subseaPane
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                title: qsTr("SUBSEA")
                visible: !_root._videoFullScreen

                // Loaded by URL (not a static import) so this pane degrades gracefully when Qt WebEngine
                // isn't part of the build (see custom/CMakeLists.txt) instead of failing to compile.
                Loader {
                    id: subseaConsoleLoader
                    anchors.fill: parent
                    source: "qrc:/qml/MineFish/Controls/MineFishSubseaConsole.qml"
                }

                Rectangle {
                    anchors.fill: parent
                    z: QGroundControl.zOrderWidgets
                    color: QGroundControl.globalPalette.window
                    visible: subseaConsoleLoader.status !== Loader.Ready

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: ScreenTools.defaultFontPixelHeight * 0.3

                        QGCLabel {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("SUBSEA CONSOLE UNAVAILABLE")
                            color: QGroundControl.globalPalette.colorOrange
                            font.family: ScreenTools.fixedFontFamily
                            font.bold: true
                            font.pointSize: ScreenTools.largeFontPointSize
                        }

                        QGCLabel {
                            Layout.alignment: Qt.AlignHCenter
                            text: qsTr("This build was compiled without Qt WebEngine")
                            color: QGroundControl.globalPalette.colorGrey
                            font.pointSize: ScreenTools.smallFontPointSize
                        }
                    }
                }
            }
        }

        MineFishTelemetryBar {
            Layout.fillWidth: true
            vehicleStatus: mineFishStatus
            visible: !_root._videoFullScreen
        }

        MineFishControlBar {
            Layout.fillWidth: true
            vehicleStatus: mineFishStatus
            visible: !_root._videoFullScreen
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 1.3
            visible: !_root._videoFullScreen

            Item { Layout.fillWidth: true }

            Image {
                // implicitWidth/Height are read-only on Image, so size it via Layout.preferred* instead.
                readonly property real _aspectRatio: 2.73

                source: "qrc:/custom/img/DeloziersLogoGreen.png"
                fillMode: Image.PreserveAspectFit
                Layout.preferredHeight: ScreenTools.defaultFontPixelHeight * 0.6
                Layout.preferredWidth: Layout.preferredHeight * _aspectRatio
                sourceSize.height: Layout.preferredHeight
                sourceSize.width: Layout.preferredWidth
                opacity: 0.7
            }
        }
    }

    Component {
        id: qtLocationEngineComponent

        FlyViewMap {
            objectName: "flyViewMap"
            planMasterController: _root.planController
            rightPanelWidth: ScreenTools.defaultFontPixelHeight * 9
            pipView: mapPipView
            pipMode: false
            toolInsets: _mapToolInsets
            mapName: "FlightDisplayView"
        }
    }

    Component {
        id: geoMapEngineComponent

        FlyViewGeoMapAdapter {
            objectName: "flyViewGeoMapAdapter"
            planMasterController: _root.planController
            rightPanelWidth: ScreenTools.defaultFontPixelHeight * 9
            pipView: mapPipView
            pipMode: false
            toolInsets: _mapToolInsets
            toolInsetsTopOffset: 0
            mapName: "FlightDisplayView"
        }
    }

    GuidedActionsController {
        id: guidedActionsController
        missionController: _root._missionController
        guidedValueSlider: _root._guidedValueSlider
    }

    GuidedValueSlider {
        id: guidedValueSlider
        objectName: "guidedValueSlider"
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: headerBar.height + _root._spacing
        z: QGroundControl.zOrderTopMost
        visible: false
    }

    FlyViewMissionCompleteDialog {
        missionController: _root._missionController
        geoFenceController: _planController.geoFenceController
        rallyPointController: _planController.rallyPointController
    }
}
