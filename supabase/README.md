# Konto und persönliche Synchronisierung

Die Anmeldung verwendet Supabase Auth mit E-Mail-Bestätigung. Aufgaben, Kalendertermine und Selfcare-Check-in werden je Konto in `herzenssache_state` gespeichert. Die RLS-Regeln in `schema.sql` beschränken Lese- und Schreibzugriff auf das angemeldete Konto.

## Supabase verbinden

1. Erstelle ein Supabase-Projekt und wähle beim Einrichten eine EU-Region.
2. Öffne den SQL Editor und führe `schema.sql` aus.
3. Öffne **Project Settings → API**. Kopiere die Project URL und den **Publishable key** (oder bei älteren Projekten den `anon`-Key).
4. Trage URL und Publishable key in `supabase-config.js` ein. Der `service_role`-Key gehört niemals in die Website.
5. Öffne **Authentication → URL Configuration** und trage `https://lindhorstceline1-gif.github.io/herzenssache/` als Site URL und Redirect URL ein.
6. Die E-Mail-Bestätigung muss eingeschaltet sein. Melde dich über „Konto“ in Herzenssache an und bestätige den Link in deiner E-Mail.

Solange URL und Publishable key leer sind, zeigt die App die Konto-Oberfläche, aber erstellt keine Konten und sendet keine persönlichen Daten an einen Dienst.

