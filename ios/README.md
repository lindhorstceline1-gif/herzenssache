# Herzenssache für iOS

Dieses Verzeichnis enthält einen nativen SwiftUI-iOS-Prototyp mit Trends, Rezepten, DIY, To-do-Liste und Familienkalender. Aufgaben und Termine werden lokal auf dem Gerät gespeichert.

## Projekt öffnen

`Herzenssache.xcodeproj` in Xcode öffnen und auf einem iPhone-Simulator oder iPhone starten. Die Bundle-ID `com.herzenssache.app` ist ein Platzhalter und muss vor der App-Store-Veröffentlichung auf eine für das Apple-Konto verfügbare ID geändert werden.

## Build

Der Workflow `.github/workflows/ios-build.yml` kann auf einem macOS-Runner einen unsignierten iOS-Simulator-Build erstellen. Für eine App-Store-Einreichung ist zusätzlich ein signierter Geräte-Build und ein Apple Developer Program-Konto erforderlich.

## Aktuelle Grenzen

- Dieses Projekt wurde in der Windows-Umgebung nicht mit Xcode gebaut oder auf einem iPhone getestet.
- Die Kalendertermine und To-dos bleiben lokal und synchronisieren nicht über mehrere Geräte.
- App-Icon, Support- und Datenschutzseiten, Store-Screenshots und App-Store-Metadaten müssen vor der Einreichung fertiggestellt werden.
- Apple prüft jede Einreichung und entscheidet über die Aufnahme in den App Store.

