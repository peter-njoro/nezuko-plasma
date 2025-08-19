QT += quick multimedia

CONFIG += c++11

SOURCES += main.cpp

# Include main.qml as a resource
RESOURCES += resources.qrc

# QML import path
QML_IMPORT_PATH = .

TARGET = nezuko-splash
TEMPLATE = app
