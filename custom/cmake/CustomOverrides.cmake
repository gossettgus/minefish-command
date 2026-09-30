# ============================================================================
# MineFish Command - Custom Build Configuration
# Delozier Calloway
# ============================================================================

# ----------------------------------------------------------------------------
# Application Branding
# ----------------------------------------------------------------------------

# IMPORTANT:
# QGC_APP_NAME is also used as the CMake project/target name.
# It therefore cannot contain spaces.
#
# Customer-facing branding will still be "MineFish Command".
set(QGC_APP_NAME
    "MineFishCommand"
    CACHE STRING "Application build name"
    FORCE
)

set(QGC_APP_DESCRIPTION
    "MineFish Command"
    CACHE STRING "Application description"
    FORCE
)

set(QGC_APP_COPYRIGHT
    "Copyright (c) Delozier Calloway"
    CACHE STRING "Copyright notice"
    FORCE
)

set(QGC_ORG_NAME
    "Delozier Calloway"
    CACHE STRING "Organization name"
    FORCE
)

set(QGC_ORG_DOMAIN
    "deloziercalloway.com"
    CACHE STRING "Organization domain"
    FORCE
)

set(QGC_PACKAGE_NAME
    "com.deloziercalloway.minefishcommand"
    CACHE STRING "Package identifier"
    FORCE
)

set(QGC_ANDROID_PACKAGE_NAME
    "com.deloziercalloway.minefishcommand"
    CACHE STRING "Android package identifier"
    FORCE
)

# cmake/CustomOptions.cmake seeds this from QGC_PACKAGE_NAME with a plain (non-FORCE) CACHE set, so once
# it's cached from an earlier configure - e.g. a build directory first configured before this file existed,
# or before QGC_PACKAGE_NAME was overridden - it never picks up a later QGC_PACKAGE_NAME change on its own.
# That leaves the bundle identifier stuck at the stock org.mavlink.qgroundcontrol, which is what makes
# macOS (Spotlight, the Dock/menu-bar icon, LaunchServices generally) misidentify or misdisplay the app:
# it's registered under an identity macOS may already associate with a different QGC build. Force it to
# stay in sync explicitly.
set(QGC_MACOS_BUNDLE_ID
    "${QGC_PACKAGE_NAME}"
    CACHE STRING "macOS bundle identifier"
    FORCE
)

# ----------------------------------------------------------------------------
# Custom Icons and Graphics
# ----------------------------------------------------------------------------

# Temporary macOS icon.
# This will be replaced by the official MineFish Command icon later.
if(EXISTS "${CMAKE_SOURCE_DIR}/${QGC_CUSTOM_DIR}/res/icons/custom_qgroundcontrol.icns")
    set(
        QGC_MACOS_ICON_PATH
        "${CMAKE_SOURCE_DIR}/${QGC_CUSTOM_DIR}/res/icons/custom_qgroundcontrol.icns"
        CACHE FILEPATH "MacOS Icon Path"
        FORCE
    )
endif()

# Temporary Linux icon.
if(EXISTS "${CMAKE_SOURCE_DIR}/${QGC_CUSTOM_DIR}/res/icons/custom_qgroundcontrol.svg")
    set(
        QGC_APPIMAGE_ICON_SCALABLE_PATH
        "${CMAKE_SOURCE_DIR}/${QGC_CUSTOM_DIR}/res/icons/custom_qgroundcontrol.svg"
        CACHE FILEPATH "AppImage Icon SVG Path"
        FORCE
    )
endif()

# Windows Installer Header
if(EXISTS "${CMAKE_SOURCE_DIR}/${QGC_CUSTOM_DIR}/deploy/windows/installheader.bmp")
    set(
        QGC_WINDOWS_INSTALL_HEADER_PATH
        "${CMAKE_SOURCE_DIR}/${QGC_CUSTOM_DIR}/deploy/windows/installheader.bmp"
        CACHE FILEPATH "Windows Install Header Path"
        FORCE
    )
endif()

# Temporary Windows Application Icon.
if(EXISTS "${CMAKE_SOURCE_DIR}/${QGC_CUSTOM_DIR}/deploy/windows/WindowsQGC.ico")
    set(
        QGC_WINDOWS_ICON_PATH
        "${CMAKE_SOURCE_DIR}/${QGC_CUSTOM_DIR}/deploy/windows/WindowsQGC.ico"
        CACHE FILEPATH "Windows Icon Path"
        FORCE
    )
endif()

# ----------------------------------------------------------------------------
# Feature Set Customization
# ----------------------------------------------------------------------------

# MineFish runs exclusively on ArduPilot (ArduRover) boats over a Pixhawk 6C. ArduPilot support comes
# from CustomFirmwarePluginFactory below (which now claims FirmwareClassArduPilot / VehicleClassRoverBoat
# and returns the MineFish-narrowed CustomFirmwarePlugin), not from the stock APM factory. Both stock
# factories stay disabled: PX4 because no MineFish hardware runs it, and stock APM because registering it
# alongside our own ArduPilot-claiming factory would race on load order for which one actually serves
# ArduPilot vehicles, and would also expose ArduCopter/ArduPlane/ArduSub setup UI this boat-only product
# doesn't want.

set(
    QGC_DISABLE_APM_PLUGIN_FACTORY
    ON
    CACHE BOOL "Disable APM Plugin Factory"
    FORCE
)

set(
    QGC_DISABLE_PX4_PLUGIN_FACTORY
    ON
    CACHE BOOL "Disable PX4 Plugin Factory"
    FORCE
)