import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls

/// Label over value, with a status dot tinted by the value's safety color.
ColumnLayout {
    id: root

    property string label: ""
    property string value: "--"
    property string detail: ""
    property color valueColor: qgcPal.text
    property bool large: false

    spacing: 0

    QGCPalette { id: qgcPal }

    QGCLabel {
        text: root.label
        color: qgcPal.colorGrey
        font.pointSize: ScreenTools.smallFontPointSize
        font.letterSpacing: ScreenTools.defaultFontPixelWidth * 0.12
    }

    RowLayout {
        spacing: ScreenTools.defaultFontPixelWidth * 0.6

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: ScreenTools.defaultFontPixelWidth * 0.9
            implicitHeight: implicitWidth
            radius: width / 2
            color: root.valueColor
        }

        QGCLabel {
            text: root.value
            color: root.valueColor
            font.family: ScreenTools.fixedFontFamily
            font.bold: true
            font.pointSize: root.large ? ScreenTools.largeFontPointSize : ScreenTools.defaultFontPointSize
        }

        QGCLabel {
            Layout.alignment: Qt.AlignBaseline
            text: root.detail
            color: qgcPal.colorGrey
            font.family: ScreenTools.fixedFontFamily
            font.pointSize: ScreenTools.smallFontPointSize
            visible: root.detail !== ""
        }
    }
}
