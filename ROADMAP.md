# DailyCheckIn – gemeinsame Roadmap

## Produktentscheidung

Pro Kalendertag darf ein Nutzer genau zwei Check-ins erstellen:

- einen privaten Check-in;
- einen beruflichen Check-in.

Ein bestehender Check-in desselben Bereichs und Tages wird bearbeitet, nicht dupliziert. Alle Eingaben eines Check-ins bleiben beim Bearbeiten erhalten.

## Grundsätze

- **Local first:** Daten bleiben zunächst ausschließlich auf dem Gerät.
- **Keine Datenverluste:** Neue Modellfelder müssen abwärtskompatibel dekodierbar sein.
- **Nutzerkontrolle:** Export, Import, Löschen und spätere Cloud-Anbindung sind bewusst und nachvollziehbar.
- **Keine medizinischen Aussagen:** Statistiken beschreiben Datenmuster, keine Diagnosen oder Kausalitäten.

## Phase 1 – Datenmodell und Datenintegrität

**Ziel:** Ein Check-in enthält wirklich alle Werte, die die Oberfläche abfragt.

**Status:** Implementiert; die vollständige Xcode-Testausführung steht noch aus, weil auf diesem Rechner nur die Command Line Tools ausgewählt sind.

1. `CheckIn` um `focusLevel`, `socialBattery` und `physicalTension` erweitern.
2. Die Werte beim Erstellen, Speichern, Laden, Bearbeiten und Exportieren durchreichen.
3. Das Aktualisieren eines Check-ins korrigieren: Faktoren, Tags und alle neuen Werte dürfen nicht verloren gehen.
4. Activity-Update prüfen und mit Tests absichern; ein Update muss ID, Wiederholung, Zeitplan, Benachrichtigung und bisherigen Status unverändert bewahren, sofern der Nutzer sie nicht ändert.
5. Bestehende gespeicherte Check-ins ohne die neuen Felder sicher mit neutralen Standardwerten laden.

**Abnahme:** Einen Check-in mit allen Feldern anlegen, schließen, neu öffnen und bearbeiten: alle Werte sind unverändert vorhanden.

## Phase 2 – Tagesregeln und Startseite

**Ziel:** Die Regel „einmal Privat + einmal Beruf pro Tag“ ist überall eindeutig.

1. Die eindeutige Identität eines Check-ins als Kombination aus Kalendertag und Bereich behandeln.
2. Auf der Startseite beide Status sichtbar machen: „Privat erledigt/offen“ und „Beruf erledigt/offen“.
3. Aktionen für einen bereits vorhandenen Eintrag immer als „Bearbeiten“ kennzeichnen.
4. Zeitzone und Tageswechsel zentral über `Calendar` behandeln; keine doppelten Einträge rund um Mitternacht.

**Abnahme:** Für denselben Tag sind pro Bereich nie mehr als ein Eintrag vorhanden; Bearbeiten erzeugt keinen dritten Eintrag.

## Phase 3 – Auswertung

**Ziel:** Alle gespeicherten Werte werden sinnvoll und transparent nutzbar.

1. Statistik-Kennzahlen für Fokus, soziale Batterie und körperliche Anspannung ergänzen.
2. Trends je Bereich sowie Zeitraum 7, 30 und alle Tage anzeigen.
3. Faktoren als Häufigkeiten und zunächst einfache Vergleiche auswerten, z. B. Durchschnittsfokus an Tagen mit einem Faktor.
4. Einsichten erst ab einer klar ausgewiesenen Mindestmenge an Daten zeigen; Sprache vorsichtig formulieren („zeigt sich zusammen mit“, nicht „verursacht“).

**Abnahme:** Jeder Eingabewert ist in Detailansicht, Verlauf und passender Statistik sichtbar.

## Phase 4 – Verlässlichkeit und Tests

**Ziel:** Kernlogik bleibt bei Änderungen stabil.

1. Veraltete Tests auf die aktuellen Typ- und Methodennamen aktualisieren.
2. Tests für Speichern/Laden, Migration, Bearbeiten ohne Datenverlust, Tages-Eindeutigkeit und Statistikwerte ergänzen.
3. Importdateien gegen ungültige oder unvollständige Daten testen.

**Abnahme:** Die komplette Test-Suite läuft grün; die kritischen Nutzerwege sind abgedeckt.

## Phase 5 – Lokaler Export und Import

**Ziel:** Der Nutzer besitzt und kontrolliert seine Daten.

1. Ein versioniertes Backup-Format definieren, das Check-ins, Aktivitäten und Aktivitäten-Abschlüsse enthält.
2. Export als JSON-Backup über das iOS-Teilen-Menü anbieten; CSV zusätzlich für Tabellen-Auswertungen.
3. Import über Dateiauswahl anbieten, vorab eine Zusammenfassung zeigen und eine klare Strategie wählen: Zusammenführen, Duplikate überspringen oder alles ersetzen.
4. Vor jedem Ersetzen automatisch ein lokales Sicherheits-Backup erzeugen.

**Abnahme:** Ein Export auf ein anderes Gerät importiert alle Daten vollständig und ohne Duplikate.

## Phase 6 – Privatsphäre und Zugriffsschutz

**Ziel:** Persönliche Einträge sind beim Öffnen der App geschützt.

1. Optionalen App-Schutz in den Einstellungen anbieten.
2. Face ID / Touch ID über `LocalAuthentication` verwenden; falls nicht verfügbar, Gerätecode als System-Fallback.
3. Sperre beim Start und nach einer konfigurierbaren Zeit im Hintergrund aktivieren.
4. Sperrstatus niemals als Ersatz für Export- oder Backup-Verschlüsselung darstellen.

**Abnahme:** Nach dem Hintergrundwechsel zeigt die App ohne erfolgreiche Geräte-Authentifizierung keine Inhalte.

## Phase 7 – optionale Cloud-Anbindung

**Ziel:** Erst nach der stabilen lokalen Version lässt der Nutzer bewusst einen Sicherungsort wählen.

1. Eine Speicher-Abstraktion einführen; die lokale Speicherung bleibt der Standard.
2. Zuerst iCloud Drive als dateibasiertes Backup prüfen; danach weitere Anbieter nur bei echtem Bedarf.
3. Klar erklären, wohin Daten übertragen werden, wie Konflikte behandelt werden und wie die Verbindung getrennt wird.
4. Cloud als Backup/Sync getrennt vom lokalen Primärspeicher gestalten.

**Abnahme:** Ein Nutzer kann Cloud-Backup aktivieren, deaktivieren und seine lokale Kopie behalten.

## Phase 8 – Prime: KI-gestützte Vorschläge

**Ziel:** Prime-Mitglieder erhalten aus ihren eigenen Check-ins hilfreiche, nicht wertende Vorschläge für Aktivitäten und Reflexionen.

### Rhythmus

| Zeitpunkt | Format | Umfang |
| --- | --- | --- |
| Täglich | Impuls für heute | Eine kurze, realistische Aktivität oder Reflexionsfrage. |
| Wöchentlich | Wochenrückblick | Zusammenfassung der wichtigsten Trends plus zwei bis drei passende Vorschläge für die nächste Woche. |
| Monatlich | Monatsreflexion | Ausführlicher Rückblick auf Muster, Fortschritte und ein sanfter Fokus für den kommenden Monat. |

### Funktionsumfang

1. KI nur nach einer klaren, separaten Einwilligung aktivieren; Prime ist keine automatische Freigabe persönlicher Inhalte.
2. Nutzer wählt, welche Daten einbezogen werden dürfen: nur Werte, Werte plus Faktoren oder zusätzlich Notizen.
3. Die KI erhält nur den nötigen, zeitlich begrenzten Datenausschnitt und gibt strukturierte Vorschläge zurück.
4. Tägliche Vorschläge sind kurz und direkt umsetzbar, etwa eine 10-Minuten-Aktivität, eine Pausenidee oder eine Reflexionsfrage.
5. Wöchentliche und monatliche Rückblicke verweisen auf beobachtbare Datenmuster und formulieren stets als Möglichkeit, nie als Diagnose oder Ursache.
6. Vorschläge können gespeichert, verworfen oder als Aktivität übernommen werden. Die Übernahme bleibt eine Nutzerentscheidung.
7. Bei wiederholt sehr niedriger Stimmung oder sehr hohem Stress zeigt die App eine empathische Sicherheitsnotiz mit Hilfsoptionen; sie ersetzt keine professionelle Unterstützung.

### Technische und Datenschutz-Vorbereitung

1. KI-Zugriff strikt vom lokalen Kernmodell trennen; ohne Einwilligung bleibt alles vollständig lokal.
2. Eine Schnittstelle für einen KI-Anbieter definieren, damit Anbieter später austauschbar bleiben.
3. Anfragen minimieren, keine Daten für Training verwenden lassen und die tatsächlich gesendeten Daten in der App transparent machen.
4. Prime-Berechtigung serverseitig bzw. über Store-Käufe prüfen; keine bloße lokale UI-Sperre.
5. Kostenlimits und eine klare Rate-Limit-Strategie pro Prime-Mitglied einplanen.

**Abnahme:** Ein Prime-Mitglied kann nachvollziehen, welche Daten verwendet werden, erhält einen nützlichen Vorschlag und kann ihn ohne automatische Änderungen übernehmen oder verwerfen.

## Reminder-Entscheidung

Standard: **ein täglicher Abend-Reminder**, der zur Startseite führt und dort beide Bereiche zeigt. Das passt zu einer kurzen Tagesreflexion und vermeidet Benachrichtigungsdruck.

Optional später: zwei separat aktivierbare Reminder für Nutzer, die Beruf und Privat zu unterschiedlichen Zeiten reflektieren möchten. Die Tagesregel bleibt davon unverändert.

## Nächster gemeinsamer Schritt

Wir beginnen mit Phase 1: Modellfelder ergänzen, das Speichern beim Bearbeiten korrigieren und mit Tests absichern. Danach prüfen wir die Änderung gemeinsam, bevor wir mit Phase 2 fortfahren.
