#pragma once

// Qt WebEngine (used by the MineFish subsea console) must be initialized before QGuiApplication is
// constructed - see QtWebEngineQuick::initialize() docs. That is earlier than any QGCCorePlugin hook
// runs, so main.cc calls this directly. The module is optional (see custom/CMakeLists.txt), so this
// header detects its own availability instead of depending on a separate build define.

#if __has_include(<QtWebEngineQuick/QtWebEngineQuick>)
#include <QtWebEngineQuick/QtWebEngineQuick>
#define MINEFISH_HAS_WEBENGINE 1
#endif

namespace CustomWebEngineInit
{

inline void initializeIfAvailable()
{
#ifdef MINEFISH_HAS_WEBENGINE
    QtWebEngineQuick::initialize();
#endif
}

} // namespace CustomWebEngineInit
