// PreviewDataHelper.swift
// ActivityTracker2 — Remember
// Befüllt SwiftData im Debug-Modus mit 50 realistischen Münchner Sample-Activities

#if DEBUG

import Foundation
import SwiftData

// MARK: - PreviewDataHelper

/// Fügt beim ersten App-Start im Debug-Modus 50 Münchner Sample-Activities in SwiftData ein.
/// Wird nur ausgeführt wenn der Store vollständig leer ist — keine Duplikate möglich.
///
/// Aufruf: `PreviewDataHelper.insertSampleDataIfNeeded(context: modelContext)`
/// — einmalig in `ActivityTracker2App.init()`, nach ModelContainer-Setup.
enum PreviewDataHelper {

    /// Prüft ob SwiftData leer ist und fügt ggf. 50 Sample-Activities ein.
    /// - Parameter context: Aktiver `ModelContext` aus `modelContainer.mainContext`.
    static func insertSampleDataIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Activity>()
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        sampleActivities.forEach { context.insert($0) }
        try? context.save()
    }

    // MARK: - Sample Activities (50)

    // swiftlint:disable function_body_length
    private static var sampleActivities: [Activity] {

        // ── Wandern (10) ─────────────────────────────────────────────────

        let w1 = Activity(
            categoryId: "hiking",
            date: .daysAgo(3),
            title: "Sonnenaufgang im Englischen Garten",
            text: "Früh aufgestanden und den Sonnenaufgang am Monopteros erlebt. Die Stadt liegt noch im Schlaf, nur die Jogger sind schon unterwegs. Ein perfekter Morgen.",
            isFavorite: true,
            location: Location(latitude: 48.1642, longitude: 11.6054,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let w2 = Activity(
            categoryId: "hiking",
            date: .daysAgo(12),
            title: "Spaziergang zum Chinesischen Turm",
            text: "Mit Freunden durch den Englischen Garten geschlendert. Am Chinesischen Turm noch ein Bier getrunken, obwohl es schon Oktober war.",
            location: Location(latitude: 48.1598, longitude: 11.6012,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let w3 = Activity(
            categoryId: "hiking",
            date: .daysAgo(21),
            title: "Runde um den Olympiapark",
            text: "5 km Runde über den Olympiaberg mit Blick auf die ganze Stadt. Oben fast kein Wind, perfekte Sicht bis zu den Alpen.",
            location: Location(latitude: 48.1731, longitude: 11.5508,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let w4 = Activity(
            categoryId: "hiking",
            date: .daysAgo(35),
            title: "Olympiasee im Herbst",
            text: "Die Bäume rund um den See leuchten in allen Orangetönen. Lange Zeit einfach auf einer Bank gesessen und die Stille genossen.",
            location: Location(latitude: 48.1689, longitude: 11.5467,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let w5 = Activity(
            categoryId: "hiking",
            date: .daysAgo(48),
            title: "Herbstwanderung im Nymphenburger Park",
            text: "Der Schlosspark im Herbst ist einfach unschlagbar. Kaum Touristen, dafür jede Menge Laub und ein trüber Himmel — genau richtig.",
            location: Location(latitude: 48.1523, longitude: 11.5234,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let w6 = Activity(
            categoryId: "hiking",
            date: .daysAgo(62),
            title: "Schlosspark Nymphenburg",
            text: "Die großen Achsen des Parks bei Sonnenuntergang entlanggegangen. Das Schloss im letzten Licht ist immer wieder beeindruckend.",
            location: Location(latitude: 48.1489, longitude: 11.5198,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let w7 = Activity(
            categoryId: "hiking",
            date: .daysAgo(75),
            title: "Waldspaziergang im Forstenrieder Park",
            text: "Über zwei Stunden durch den Forst gelaufen, ohne einer Menschenseele zu begegnen. Genau das, was ich nach einer stressigen Woche gebraucht habe.",
            location: Location(latitude: 48.0941, longitude: 11.5234,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let w8 = Activity(
            categoryId: "hiking",
            date: .daysAgo(90),
            title: "Biedersteiner Park am Nachmittag",
            text: "Kleiner Park, ganz ruhig. Ein Ort, den ich vorher gar nicht kannte.",
            location: Location(latitude: 48.1823, longitude: 11.6234,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let w9 = Activity(
            categoryId: "hiking",
            date: .daysAgo(110),
            title: "Isar-Spaziergang bei der Hirschau",
            text: "Die Isar bei Niedrigwasser — breite Kiesbänke, die man sonst nicht zu sehen bekommt. Weit gelaufen und die Stille am Wasser sehr genossen.",
            location: Location(latitude: 48.1756, longitude: 11.6123,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let w10 = Activity(
            categoryId: "hiking",
            date: .daysAgo(130),
            title: "Kleinhesseloher See im Frühling",
            text: "Erster wirklich warmer Tag. Am See Enten beobachtet, Kaffee aus der Thermoskanne getrunken. Der Frühling ist zurück.",
            location: Location(latitude: 48.1634, longitude: 11.5923,
                               city: "München", region: "Bayern", country: "Deutschland")
        )

        // ── Restaurant (7) ───────────────────────────────────────────────

        let r1 = Activity(
            categoryId: "restaurant",
            date: .daysAgo(5),
            title: "Abendessen am Marienplatz",
            text: "Weisswurst zum Abendessen — eigentlich falsch, aber wer schaut schon genau hin. Die Terrasse mit Blick auf das Rathaus war wie immer unschlagbar.",
            isFavorite: true,
            location: Location(latitude: 48.1374, longitude: 11.5755,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let r2 = Activity(
            categoryId: "restaurant",
            date: .daysAgo(18),
            title: "Mittagessen am Viktualienmarkt",
            text: "Obazda, Radieschen und frisches Brot am Stand. So simpel und so gut. Den Biergarten mittags noch halb leer erwischt.",
            location: Location(latitude: 48.1389, longitude: 11.5712,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let r3 = Activity(
            categoryId: "restaurant",
            date: .daysAgo(28),
            title: "Italiener in der Maxvorstadt",
            text: "Das kleine Lokal neben der Akademie ist ein echter Geheimtipp. Hausgemachte Pasta, kein Touristenbetrieb. Muss ich wieder hin.",
            location: Location(latitude: 48.1423, longitude: 11.5801,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let r4 = Activity(
            categoryId: "restaurant",
            date: .daysAgo(45),
            title: "Thai-Restaurant am Sendlinger Tor",
            text: "Sehr scharf, sehr gut. Das grüne Curry war besser als erwartet, das Pad Thai exakt richtig.",
            location: Location(latitude: 48.1356, longitude: 11.5634,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let r5 = Activity(
            categoryId: "restaurant",
            date: .daysAgo(58),
            title: "Frühstück im Glockenbach",
            text: "Langes Frühstück mit Zeitung und Rührei. Das Café ist winzig aber irgendwie perfekt.",
            location: Location(latitude: 48.1298, longitude: 11.5523,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let r6 = Activity(
            categoryId: "restaurant",
            date: .daysAgo(82),
            title: "Sushi in Schwabing",
            text: "Endlich das neue Sushi-Restaurant ausprobiert. Die Qualität stimmt, die Preise auch noch. Wird zur Stammadresse.",
            location: Location(latitude: 48.1534, longitude: 11.5867,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let r7 = Activity(
            categoryId: "restaurant",
            date: .daysAgo(102),
            title: "Sonntagsbrunch im Herzogpark",
            text: "Ein Brunch wie aus dem Bilderbuch. Ruhige Ecke im Herzogpark, gutes Wetter, keine Eile. So soll der Sonntag sein.",
            location: Location(latitude: 48.1467, longitude: 11.5934,
                               city: "München", region: "Bayern", country: "Deutschland")
        )

        // ── Kino (5) ─────────────────────────────────────────────────────

        let k1 = Activity(
            categoryId: "cinema",
            date: .daysAgo(7),
            title: "Kinoabend im Mathäser",
            text: "Großes Kino, gute Akustik. Der Film war etwas überlang, aber das Popcorn war erstklassig.",
            location: Location(latitude: 48.1401, longitude: 11.5523,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let k2 = Activity(
            categoryId: "cinema",
            date: .daysAgo(25),
            title: "Filmklassiker im City Kino",
            text: "Casablanca auf der großen Leinwand. Manche Filme funktionieren nur im Kino — das ist so einer.",
            location: Location(latitude: 48.1389, longitude: 11.5634,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let k3 = Activity(
            categoryId: "cinema",
            date: .daysAgo(42),
            title: "Stummfilm in den Museum Lichtspielen",
            text: "Stummfilm mit Live-Klavierbegleitung. Ein komplett anderes Kinoerlebnis. Sehr empfehlenswert.",
            location: Location(latitude: 48.1534, longitude: 11.5712,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let k4 = Activity(
            categoryId: "cinema",
            date: .daysAgo(68),
            title: "Dokumentarfilm im Rio",
            text: "Ein langer Dokumentarfilm über Klimawandel in den Alpen. Sehr gut gemacht, bleibt im Kopf.",
            location: Location(latitude: 48.1623, longitude: 11.5823,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let k5 = Activity(
            categoryId: "cinema",
            date: .daysAgo(95),
            title: "Spätvorstellung im Gloria Palast",
            text: "Um 23 Uhr noch ins Kino — das macht man nicht jeden Tag. Aber der Film hat es sich verdient.",
            location: Location(latitude: 48.1312, longitude: 11.5689,
                               city: "München", region: "Bayern", country: "Deutschland")
        )

        // ── Café (4) ─────────────────────────────────────────────────────

        let c1 = Activity(
            categoryId: "cafe",
            date: .daysAgo(9),
            title: "Kaffee mit Ausblick",
            text: "Flat White und ein Stück Kuchen. Draußen Regen, drinnen warm. Genau richtig.",
            location: Location(latitude: 48.1356, longitude: 11.5712,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let c2 = Activity(
            categoryId: "cafe",
            date: .daysAgo(32),
            title: "Nachmittagskaffee in Schwabing",
            text: "Zwei Stunden mit einem Buch in der Ecke gesessen. Das Café lässt einen so lange man will. Werde ich wiederholen.",
            location: Location(latitude: 48.1423, longitude: 11.5634,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let c3 = Activity(
            categoryId: "cafe",
            date: .daysAgo(55),
            title: "Arbeiten im Lieblingscafé",
            text: "Halber Tag mit Laptop hier verbracht. Gutes WLAN, guter Kaffee, keine nervige Musik. Produktiver als im Büro.",
            location: Location(latitude: 48.1489, longitude: 11.5801,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let c4 = Activity(
            categoryId: "cafe",
            date: .daysAgo(78),
            title: "Sonntagskaffee im Glockenbach",
            text: "Slow Sunday. Zeitung, Cappuccino, Sonnenschein durch die Fenster.",
            location: Location(latitude: 48.1534, longitude: 11.5523,
                               city: "München", region: "Bayern", country: "Deutschland")
        )

        // ── Fitness (4) ──────────────────────────────────────────────────

        let f1 = Activity(
            categoryId: "fitness",
            date: .daysAgo(11),
            title: "Crossfit im Olympiapark",
            text: "Outdoor Workout mit Blick auf den Olympiaturm. Kalt, aber belebend. Die Gruppe war motiviert.",
            isFavorite: true,
            location: Location(latitude: 48.1731, longitude: 11.5508,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let f2 = Activity(
            categoryId: "fitness",
            date: .daysAgo(30),
            title: "Krafttraining Beine und Rücken",
            text: "Intensives Beintraining. Die nächsten zwei Tage werden schmerzhaft.",
            location: Location(latitude: 48.1423, longitude: 11.5234,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let f3 = Activity(
            categoryId: "fitness",
            date: .daysAgo(60),
            title: "Schwimmen und Sauna",
            text: "Lange Bahnen gezogen, danach eine Stunde Sauna. Der perfekte Ausgleich nach einer sitzenden Woche.",
            location: Location(latitude: 48.1356, longitude: 11.5867,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let f4 = Activity(
            categoryId: "fitness",
            date: .daysAgo(88),
            title: "Yoga-Stunde in Schwabing",
            text: "Erste Yoga-Stunde seit Monaten. Deutlich unflexibler als früher. Aber gut, wieder angefangen.",
            location: Location(latitude: 48.1623, longitude: 11.5634,
                               city: "München", region: "Bayern", country: "Deutschland")
        )

        // ── Bar & Kneipe (4) ─────────────────────────────────────────────

        let b1 = Activity(
            categoryId: "bar",
            date: .daysAgo(14),
            title: "Abend im Hofbräuhaus",
            text: "Laut, voll, touristisch — und trotzdem jedes Mal ein Erlebnis. Mit Kolleginnen beim Feierabendbier.",
            isFavorite: true,
            location: Location(latitude: 48.1376, longitude: 11.5800,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let b2 = Activity(
            categoryId: "bar",
            date: .daysAgo(38),
            title: "Biergarten im Augustiner Keller",
            text: "Der älteste Biergarten der Stadt. Selbst mitgebrachtes Essen, Maß Bier dazu. Mehr braucht es nicht.",
            location: Location(latitude: 48.1389, longitude: 11.5712,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let b3 = Activity(
            categoryId: "bar",
            date: .daysAgo(65),
            title: "Stammtisch im Atzinger",
            text: "Alteingesessene Kneipe ohne Schnickschnack. Dunkles Bier, alte Holztische, gute Gesellschaft.",
            location: Location(latitude: 48.1312, longitude: 11.5634,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let b4 = Activity(
            categoryId: "bar",
            date: .daysAgo(120),
            title: "Cocktails im Trachtenvogl",
            text: "Gut besuchte Bar im Glockenbach. Der Negroni war ausgezeichnet. Bis kurz vor Mitternacht geblieben.",
            location: Location(latitude: 48.1298, longitude: 11.5756,
                               city: "München", region: "Bayern", country: "Deutschland")
        )

        // ── Museum (3) ───────────────────────────────────────────────────

        let m1 = Activity(
            categoryId: "museum",
            date: .daysAgo(22),
            title: "Besuch im Deutschen Museum",
            text: "Vier Stunden und trotzdem nur einen Bruchteil gesehen. Die Abteilung Bergbau unter der Erde ist einzigartig.",
            isFavorite: true,
            location: Location(latitude: 48.1456, longitude: 11.5712,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let m2 = Activity(
            categoryId: "museum",
            date: .daysAgo(50),
            title: "Moderne Kunst in der Pinakothek",
            text: "Die Ausstellung zu Baselitz hat mich überrascht — viel zugänglicher als erwartet. Das neue Café im Atrium ist empfehlenswert.",
            location: Location(latitude: 48.1534, longitude: 11.5634,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let m3 = Activity(
            categoryId: "museum",
            date: .daysAgo(85),
            title: "Alte Meister in der Alten Pinakothek",
            text: "Rubens und Rembrandt in Ruhe angesehen. An einem Dienstagvormittag fast allein im Saal.",
            location: Location(latitude: 48.1512, longitude: 11.5601,
                               city: "München", region: "Bayern", country: "Deutschland")
        )

        // ── Konzert (3) ──────────────────────────────────────────────────

        let ko1 = Activity(
            categoryId: "concert",
            date: .daysAgo(16),
            title: "Konzert in der Olympiahalle",
            text: "Riesige Halle, aber trotzdem gute Atmosphäre. Die Lichtshow war beeindruckend, die Akustik überraschend gut.",
            isFavorite: true,
            location: Location(latitude: 48.1398, longitude: 11.5634,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let ko2 = Activity(
            categoryId: "concert",
            date: .daysAgo(52),
            title: "Jazzkonzert im Muffatwerk",
            text: "Kleines Trio, sehr intimes Setting. Genau der Abend nach dem ich gesucht habe. Das Muffatwerk bleibt meine liebste Location.",
            location: Location(latitude: 48.1623, longitude: 11.5523,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let ko3 = Activity(
            categoryId: "concert",
            date: .daysAgo(140),
            title: "Indie-Konzert im Backstage",
            text: "Die Band kannte ich vorher kaum. Jetzt stehen sie ganz oben auf meiner Playlist. Genau so soll es sein.",
            location: Location(latitude: 48.1534, longitude: 11.5801,
                               city: "München", region: "Bayern", country: "Deutschland")
        )

        // ── Reise (3) ────────────────────────────────────────────────────

        let re1 = Activity(
            categoryId: "travel",
            date: .daysAgo(72),
            title: "Flug nach Barcelona",
            text: "Frühmorgens los. Barcelona empfing mich mit 24 Grad und Sonnenschein. Vier Tage, zu kurz — aber besser als nichts.",
            isFavorite: true,
            location: Location(latitude: 48.3537, longitude: 11.7750,
                               city: "Flughafen München", region: "Bayern", country: "Deutschland")
        )
        let re2 = Activity(
            categoryId: "travel",
            date: .daysAgo(105),
            title: "Zugreise nach Berlin",
            text: "ICE, knapp fünf Stunden. Im Speisewagen gearbeitet, dann einfach aus dem Fenster geschaut. Reisen ohne Stress.",
            location: Location(latitude: 48.1401, longitude: 11.5601,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let re3 = Activity(
            categoryId: "travel",
            date: .daysAgo(155),
            title: "Wochenendtrip nach Wien",
            text: "Wien zum ersten Mal im Winter. Kunsthistorisches Museum, Prater, Kaffeehaus — Klischee, aber kein bisschen falsch.",
            location: Location(latitude: 48.1312, longitude: 11.5712,
                               city: "München", region: "Bayern", country: "Deutschland")
        )

        // ── Shopping (3) ─────────────────────────────────────────────────

        let sh1 = Activity(
            categoryId: "shopping",
            date: .daysAgo(19),
            title: "Shopping in der Kaufingerstrasse",
            text: "Eigentlich nur schnell etwas besorgen. Zwei Stunden später und mit mehr als geplant wieder draußen.",
            location: Location(latitude: 48.1389, longitude: 11.5689,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let sh2 = Activity(
            categoryId: "shopping",
            date: .daysAgo(44),
            title: "Weihnachtseinkäufe am Marienplatz",
            text: "Den Weihnachtsmarkt kurz genossen, dann die Einkaufsliste abgearbeitet. Schneller als gedacht.",
            location: Location(latitude: 48.1401, longitude: 11.5756,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let sh3 = Activity(
            categoryId: "shopping",
            date: .daysAgo(115),
            title: "Bummel auf der Leopoldstrasse",
            text: "Die Leopoldstrasse ist eine der wenigen Strassen, die ich einfach so entlanglaufen mag — ohne zu kaufen.",
            location: Location(latitude: 48.1623, longitude: 11.5867,
                               city: "München", region: "Bayern", country: "Deutschland")
        )

        // ── Tagebuch (2) ─────────────────────────────────────────────────

        let t1 = Activity(
            categoryId: "journal",
            date: .daysAgo(170),
            title: "Jahresrückblick",
            text: "Ein Jahr in Gedanken durchgegangen. Viel passiert, viel gelernt. Die Karte in der App zeigt es besser als jedes Tagebuch könnte.",
            isFavorite: true,
            location: Location(latitude: 48.1351, longitude: 11.5820,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let t2 = Activity(
            categoryId: "journal",
            date: .daysAgo(6),
            title: "Gedanken zum neuen Jahr",
            text: "Was will ich in den nächsten Monaten festhalten? Mehr rausgehen. Mehr neue Orte. Weniger Planung, mehr Spontanität.",
            location: Location(latitude: 48.1423, longitude: 11.5712,
                               city: "München", region: "Bayern", country: "Deutschland")
        )

        // ── Fotografie (2) ───────────────────────────────────────────────

        let fo1 = Activity(
            categoryId: "photography",
            date: .daysAgo(26),
            title: "Fotos vom Olympiaturm",
            text: "Goldene Stunde von der Aussichtsplattform. München bei Abendsonne ist einfach wunderschön. Fast 200 Fotos, drei davon wirklich gut.",
            location: Location(latitude: 48.1731, longitude: 11.5508,
                               city: "München", region: "Bayern", country: "Deutschland")
        )
        let fo2 = Activity(
            categoryId: "photography",
            date: .daysAgo(150),
            title: "Marienplatz im Morgenrot",
            text: "Um 6 Uhr morgens allein auf dem Marienplatz. Kein Mensch weit und breit. Die besten Fotos entstehen, wenn man früher aufsteht als alle anderen.",
            location: Location(latitude: 48.1374, longitude: 11.5755,
                               city: "München", region: "Bayern", country: "Deutschland")
        )

        return [
            w1, w2, w3, w4, w5, w6, w7, w8, w9, w10,
            r1, r2, r3, r4, r5, r6, r7,
            k1, k2, k3, k4, k5,
            c1, c2, c3, c4,
            f1, f2, f3, f4,
            b1, b2, b3, b4,
            m1, m2, m3,
            ko1, ko2, ko3,
            re1, re2, re3,
            sh1, sh2, sh3,
            t1, t2,
            fo1, fo2,
        ]
    }
    // swiftlint:enable function_body_length
}

#endif
