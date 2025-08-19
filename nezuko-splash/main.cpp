#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QStandardPaths>
#include <QQmlContext>
#include <QProcessEnvironment>

int main(int argc, char *argv[])
{
    // Enable Qt Multimedia logging
    qputenv("QT_LOGGING_RULES", "qt.multimedia*=true");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Set context property for resource paths
    engine.rootContext()->setContextProperty("appDir", QCoreApplication::applicationDirPath());

    // Always load from QRC resources
    engine.load(QUrl("qrc:/main.qml"));

    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
