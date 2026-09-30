#include "CustomPlugin.h"
#include "CustomSettings.h"
#include "PerimeterScanComplexItem.h"
#include "PerimeterScanPlanCreator.h"
#include "QGCLoggingCategory.h"
#include "QGCPalette.h"
#include "QGCMAVLink.h"
#include "AppSettings.h"
#include "SettingsManager.h"

#include <QtCore/QApplicationStatic>
#include <QtQml/QQmlApplicationEngine>
#include <QtQml/QQmlFile>

QGC_LOGGING_CATEGORY(CustomLog, "Custom.CustomPlugin")

Q_APPLICATION_STATIC(CustomPlugin, _customPluginInstance);

CustomFlyViewOptions::CustomFlyViewOptions(CustomOptions* options, QObject* parent)
    : QGCFlyViewOptions(options, parent)
{
    qCDebug(CustomLog) << this;
}

CustomOptions::CustomOptions(CustomPlugin *plugin, QObject *parent)
    : QGCOptions(parent)
    , _plugin(plugin)
    , _flyViewOptions(new CustomFlyViewOptions(this, this))
{
    Q_CHECK_PTR(_plugin);
}

/*===========================================================================*/

CustomPlugin::CustomPlugin(QObject *parent)
    : QGCCorePlugin(parent)
    , _options(new CustomOptions(this, this))
{
    qCDebug(CustomLog) << this;

    _showAdvancedUI = false;
    (void) connect(
        this,
        &QGCCorePlugin::showAdvancedUIChanged,
        this,
        &CustomPlugin::_advancedChanged
    );
}

QGCCorePlugin *CustomPlugin::instance()
{
    return _customPluginInstance();
}

void CustomPlugin::_advancedChanged(bool changed)
{
    // Firmware Upgrade page is only shown in Advanced mode
    emit _options->showFirmwareUpgradeChanged(changed);
}

void CustomPlugin::registerCustomSettings(SettingsManager *settingsManager)
{
    settingsManager->registerCustomSettingsGroup(
        QStringLiteral("customSettings"),
        new CustomSettings()
    );
}

void CustomPlugin::adjustSettingMetaData(
    const QString& settingsGroup,
    FactMetaData& metaData,
    bool& userVisible
)
{
    QGCCorePlugin::adjustSettingMetaData(
        settingsGroup,
        metaData,
        userVisible
    );

    if (settingsGroup == AppSettings::settingsGroup) {

        // Default vehicle configuration for offline plan editing: MineFish is an ArduPilot boat.
        if (metaData.name() == AppSettings::offlineEditingFirmwareClassName) {
            metaData.setRawDefaultValue(QGCMAVLink::FirmwareClassArduPilot);
            userVisible = false;
            return;

        } else if (
            metaData.name() == AppSettings::offlineEditingVehicleClassName
        ) {
            metaData.setRawDefaultValue(QGCMAVLink::VehicleClassRoverBoat);
            userVisible = false;
            return;
        }
    }
}

/*===========================================================================*/
/*
 * MineFish Command Color System
 *
 * Main background:      #000000
 * Panel background:     #0A0A0A
 * Deep panel:           #050805
 * Terminal green:       #00FF41
 * Secondary green:      #00CC33
 * Main text:            #E8FFE8
 *
 * Red, orange and yellow are intentionally preserved for safety/warning
 * information where green would make the state ambiguous.
 */
/*===========================================================================*/

void CustomPlugin::paletteOverride(
    const QString& colorName,
    QGCPalette::PaletteColorInfo_t& colorInfo
)
{
    // MineFish Command intentionally uses the same dark palette whether
    // QGC requests Light or Dark mode. This keeps the customer-facing
    // application visually consistent.

    const auto setPalette =
        [&colorInfo](
            const QColor& enabled,
            const QColor& disabled
        )
    {
        colorInfo[QGCPalette::Dark]
                 [QGCPalette::ColorGroupEnabled] = enabled;

        colorInfo[QGCPalette::Dark]
                 [QGCPalette::ColorGroupDisabled] = disabled;

        colorInfo[QGCPalette::Light]
                 [QGCPalette::ColorGroupEnabled] = enabled;

        colorInfo[QGCPalette::Light]
                 [QGCPalette::ColorGroupDisabled] = disabled;
    };

    // ------------------------------------------------------------------------
    // Main application surfaces
    // ------------------------------------------------------------------------

    if (colorName == QStringLiteral("window")) {

        setPalette(
            QColor("#000000"),
            QColor("#000000")
        );

    } else if (colorName == QStringLiteral("windowShade")) {

        setPalette(
            QColor("#0A0A0A"),
            QColor("#080808")
        );

    } else if (colorName == QStringLiteral("windowShadeDark")) {

        setPalette(
            QColor("#050805"),
            QColor("#050805")
        );

    } else if (colorName == QStringLiteral("windowShadeLight")) {

        setPalette(
            QColor("#1A241C"),
            QColor("#121812")
        );

    } else if (colorName == QStringLiteral("windowTransparent")) {

        setPalette(
            QColor("#E6000000"),
            QColor("#E6000000")
        );

    } else if (colorName == QStringLiteral("groupBorder")) {

        // Panel frames: dim green so live data, not chrome, draws the eye.
        setPalette(
            QColor("#145C26"),
            QColor("#0C2E14")
        );

    // ------------------------------------------------------------------------
    // Text
    // ------------------------------------------------------------------------

    } else if (colorName == QStringLiteral("text")) {

        setPalette(
            QColor("#E8FFE8"),
            QColor("#4D6B52")
        );

    } else if (colorName == QStringLiteral("warningText")) {

        setPalette(
            QColor("#FF453A"),
            QColor("#8A302C")
        );

    // ------------------------------------------------------------------------
    // Standard buttons
    // ------------------------------------------------------------------------

    } else if (colorName == QStringLiteral("button")) {

        setPalette(
            QColor("#0A0F0A"),
            QColor("#111511")
        );

    } else if (colorName == QStringLiteral("buttonBorder")) {

        setPalette(
            QColor("#00A82A"),
            QColor("#23632F")
        );

    } else if (colorName == QStringLiteral("buttonText")) {

        setPalette(
            QColor("#E8FFE8"),
            QColor("#4D6B52")
        );

    } else if (colorName == QStringLiteral("buttonHighlight")) {

        setPalette(
            QColor("#00FF41"),
            QColor("#16301C")
        );

    } else if (
        colorName == QStringLiteral("buttonHighlightText")
    ) {

        setPalette(
            QColor("#000000"),
            QColor("#4D6B52")
        );

    // ------------------------------------------------------------------------
    // Primary/action buttons
    // ------------------------------------------------------------------------

    } else if (colorName == QStringLiteral("primaryButton")) {

        setPalette(
            QColor("#00FF41"),
            QColor("#16301C")
        );

    } else if (
        colorName == QStringLiteral("primaryButtonText")
    ) {

        setPalette(
            QColor("#000000"),
            QColor("#4D6B52")
        );

    // ------------------------------------------------------------------------
    // Input fields
    // ------------------------------------------------------------------------

    } else if (colorName == QStringLiteral("textField")) {

        setPalette(
            QColor("#050805"),
            QColor("#111511")
        );

    } else if (
        colorName == QStringLiteral("textFieldText")
    ) {

        setPalette(
            QColor("#E8FFE8"),
            QColor("#4D6B52")
        );

    // ------------------------------------------------------------------------
    // Map controls
    // ------------------------------------------------------------------------

    } else if (colorName == QStringLiteral("mapButton")) {

        setPalette(
            QColor("#050805"),
            QColor("#111511")
        );

    } else if (
        colorName == QStringLiteral("mapButtonHighlight")
    ) {

        setPalette(
            QColor("#00FF41"),
            QColor("#16301C")
        );

    } else if (
        colorName == QStringLiteral("mapIndicator")
    ) {

        setPalette(
            QColor("#00FF41"),
            QColor("#36543D")
        );

    } else if (
        colorName == QStringLiteral("mapIndicatorChild")
    ) {

        setPalette(
            QColor("#00A82A"),
            QColor("#28422E")
        );

    // ------------------------------------------------------------------------
    // Semantic colors
    // ------------------------------------------------------------------------

    } else if (colorName == QStringLiteral("colorGreen")) {

        setPalette(
            QColor("#00FF41"),
            QColor("#237535")
        );

    } else if (colorName == QStringLiteral("colorOrange")) {

        setPalette(
            QColor("#FFB000"),
            QColor("#805800")
        );

    } else if (colorName == QStringLiteral("colorRed")) {

        setPalette(
            QColor("#FF453A"),
            QColor("#7A2925")
        );

    } else if (colorName == QStringLiteral("colorGrey")) {

        setPalette(
            QColor("#718077"),
            QColor("#39423C")
        );

    } else if (colorName == QStringLiteral("colorBlue")) {

        // Intentionally mapped to MineFish green so stock QGC components
        // don't introduce blue accents.
        setPalette(
            QColor("#00CC33"),
            QColor("#23632F")
        );

    // ------------------------------------------------------------------------
    // Alerts
    // ------------------------------------------------------------------------

    } else if (
        colorName == QStringLiteral("alertBackground")
    ) {

        setPalette(
            QColor("#241C00"),
            QColor("#171200")
        );

    } else if (
        colorName == QStringLiteral("alertBorder")
    ) {

        setPalette(
            QColor("#FFB000"),
            QColor("#805800")
        );

    } else if (
        colorName == QStringLiteral("alertText")
    ) {

        setPalette(
            QColor("#FFF2BF"),
            QColor("#8A815F")
        );

    // ------------------------------------------------------------------------
    // Mission editor
    // ------------------------------------------------------------------------

    } else if (
        colorName == QStringLiteral("missionItemEditor")
    ) {

        setPalette(
            QColor("#050805"),
            QColor("#101510")
        );

    // ------------------------------------------------------------------------
    // Hover states
    // ------------------------------------------------------------------------

    } else if (
        colorName == QStringLiteral("hoverColor")
    ) {

        setPalette(
            QColor("#00CC33"),
            QColor("#195C29")
        );

    // ------------------------------------------------------------------------
    // Map widget borders
    // ------------------------------------------------------------------------

    } else if (
        colorName == QStringLiteral("mapWidgetBorderLight")
    ) {

        setPalette(
            QColor("#00FF41"),
            QColor("#23632F")
        );

    } else if (
        colorName == QStringLiteral("mapWidgetBorderDark")
    ) {

        setPalette(
            QColor("#001A07"),
            QColor("#000D03")
        );

    // ------------------------------------------------------------------------
    // MineFish Command branding
    // ------------------------------------------------------------------------

    } else if (
        colorName == QStringLiteral("brandPrimary")
    ) {

        // Replaces the stock/custom-example purple branding.
        setPalette(
            QColor("#00FF41"),
            QColor("#23632F")
        );

    } else if (
        colorName == QStringLiteral("brandAccent")
    ) {

        // Secondary terminal green instead of purple/blue.
        setPalette(
            QColor("#00CC33"),
            QColor("#195C29")
        );
    }
}

/*===========================================================================*/

QQmlApplicationEngine* CustomPlugin::createQmlApplicationEngine(
    QObject* parent
)
{
    _qmlEngine =
        QGCCorePlugin::createQmlApplicationEngine(parent);

    _qmlEngine->addImportPath(
        "qrc:/qml/Custom/Widgets"
    );

    _qmlEngine->addImportPath(
        "qrc:/qml/Custom/Plan"
    );

    // TODO: Investigate:
    // _qmlEngine->setExtraSelectors({"custom"})

    _urlInterceptor =
        new CustomOverrideInterceptor();

    _qmlEngine->addUrlInterceptor(
        _urlInterceptor
    );

    return _qmlEngine;
}

void CustomPlugin::destroyQmlApplicationEngine(
    QQmlApplicationEngine* qmlEngine
)
{
    if (
        qmlEngine &&
        (qmlEngine == _qmlEngine)
    ) {
        qmlEngine->removeUrlInterceptor(
            _urlInterceptor
        );

        delete _urlInterceptor;

        _urlInterceptor = nullptr;
        _qmlEngine = nullptr;
    }

    QGCCorePlugin::destroyQmlApplicationEngine(
        qmlEngine
    );
}

/*===========================================================================*/

CustomOverrideInterceptor::CustomOverrideInterceptor()
    : QQmlAbstractUrlInterceptor()
{
}

QUrl CustomOverrideInterceptor::intercept(
    const QUrl& url,
    QQmlAbstractUrlInterceptor::DataType type
)
{
    switch (type) {

    case QQmlAbstractUrlInterceptor::QmlFile:
    case QQmlAbstractUrlInterceptor::UrlString:

        if (url.scheme() == QStringLiteral("qrc")) {

            const QString origPath =
                url.path();

            const QString overrideRes =
                QStringLiteral(":/Custom%1").arg(origPath);

            if (QFile::exists(overrideRes)) {

                const QString relPath =
                    overrideRes.mid(2);

                QUrl result;

                result.setScheme(
                    QStringLiteral("qrc")
                );

                result.setPath(
                    '/' + relPath
                );

                return result;
            }
        }

        break;

    default:
        break;
    }

    return url;
}

/*===========================================================================*/

QVariantList CustomPlugin::complexMissionItemNames(
    Vehicle* vehicle
)
{
    // Start with the standard set, then append our custom item.

    QVariantList items =
        QGCCorePlugin::complexMissionItemNames(vehicle);

    QVariantMap entry;

    entry[QStringLiteral("canonicalName")] =
        QString(PerimeterScanComplexItem::canonicalName);

    entry[QStringLiteral("translatedName")] =
        PerimeterScanComplexItem::tr(
            PerimeterScanComplexItem::canonicalName
        );

    items.append(entry);

    return items;
}

ComplexMissionItem* CustomPlugin::createComplexMissionItem(
    const QString& complexItemType,
    PlanMasterController* masterController,
    bool flyView,
    const QString& kmlOrShpFile
)
{
    if (
        complexItemType ==
            PerimeterScanComplexItem::canonicalName
        ||
        complexItemType ==
            PerimeterScanComplexItem::jsonComplexItemTypeValue
    ) {
        return new PerimeterScanComplexItem(
            masterController,
            flyView,
            kmlOrShpFile
        );
    }

    // Fall back to QGC's built-in factory for all standard item types.

    return QGCCorePlugin::createComplexMissionItem(
        complexItemType,
        masterController,
        flyView,
        kmlOrShpFile
    );
}

QList<PlanCreator*> CustomPlugin::planCreators(
    PlanMasterController* planMasterController
)
{
    // Start with standard creators, then add the custom creator.

    QList<PlanCreator*> creators =
        QGCCorePlugin::planCreators(
            planMasterController
        );

    creators.append(
        new PerimeterScanPlanCreator(
            planMasterController
        )
    );

    return creators;
}