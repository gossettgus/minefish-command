import QtQuick

import QGroundControl
import QGroundControl.Controls

/// Framed MineFish surface. Children go into a clipped content area inset by the border; the optional
/// title tag is drawn above the content so it stays visible over maps and video.
Rectangle {
    id: root

    property string title: ""
    property alias contentItem: content
    default property alias contentData: content.data

    color: qgcPal.window
    border.color: qgcPal.groupBorder
    border.width: 1
    radius: ScreenTools.defaultBorderRadius

    QGCPalette { id: qgcPal }

    Item {
        id: content
        anchors.fill: parent
        anchors.margins: root.border.width
        clip: true
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: root.border.width
        width: titleLabel.contentWidth + ScreenTools.defaultFontPixelWidth * 2
        height: titleLabel.contentHeight + ScreenTools.defaultFontPixelHeight * 0.3
        color: qgcPal.window
        border.color: qgcPal.groupBorder
        border.width: 1
        visible: root.title !== ""
        z: QGroundControl.zOrderWidgets

        QGCLabel {
            id: titleLabel
            anchors.centerIn: parent
            text: root.title
            color: qgcPal.brandPrimary
            font.family: ScreenTools.fixedFontFamily
            font.pointSize: ScreenTools.smallFontPointSize
            font.bold: true
            font.letterSpacing: ScreenTools.defaultFontPixelWidth * 0.15
        }
    }
}
