#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QCoreApplication>
#include <QDir>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    // Determine path to main.qml relative to the executable
    QString qmlPath = QCoreApplication::applicationDirPath() + "/main.qml";
    QUrl url = QUrl::fromLocalFile(qmlPath);

    // Fallback: check if main.qml exists, otherwise try resource
    if (!QFile::exists(qmlPath)) {
        url = QUrl(QStringLiteral("qrc:/main.qml"));
    }

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
