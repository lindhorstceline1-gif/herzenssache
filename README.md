# Herzenssache

Eine responsive, installierbare Web-App (PWA) für Trends, Familienrezepte, Kalender, To-dos, DIY-Ideen und Selfcare.

## Auf dem Handy installieren

Die veröffentlichte Website ist unter https://lindhorstceline1-gif.github.io/herzenssache/ erreichbar.

- **iPhone:** In Safari öffnen, auf **Teilen** tippen und **Zum Home-Bildschirm** wählen.
- **Android:** In Chrome öffnen und im Browsermenü **App installieren** oder **Zum Startbildschirm hinzufügen** wählen.

Die PWA verwendet ein Web-App-Manifest, App-Symbole und einen Service Worker für den Offline-Zugriff auf bereits geladene Inhalte. Sie ist damit eine installierbare Web-App, aber kein App-Store-Eintrag.

## Lokal öffnen

`index.html` direkt im Browser öffnen. Für Installation und Offline-Funktion muss die Seite über HTTPS oder localhost bereitgestellt werden.

## GitHub Pages

Der Workflow unter `.github/workflows/pages.yml` veröffentlicht den Inhalt des Repositorys auf GitHub Pages, sobald ein Commit auf `main` eingeht. Aktiviere Pages im Repository unter **Settings → Pages → Build and deployment → GitHub Actions**, falls GitHub dies beim ersten Lauf verlangt.

Die To-do-Liste wird lokal im Browser gespeichert (`localStorage`). Es gibt derzeit keine Anmeldung oder gemeinsame Synchronisierung zwischen Geräten.

