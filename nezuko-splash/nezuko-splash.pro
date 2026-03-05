QT += quick multimedia

CONFIG += c++17
CONFIG += qt

SOURCES += main.cpp

# Include main.qml as a resource
RESOURCES += resources.qrc

# QML import path
QML_IMPORT_PATH = .

TARGET = nezuko-splash
TEMPLATE = app

# Ensure we're using Qt 6
REQUIRES = qtConfig(opengl)
