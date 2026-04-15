// PreviewDataHelper.swift
// ActivityTracker2 — Remember
// Debug-Sample-Daten: 100 Aktivitäten — München + Umland + Deutschland + Welt

#if DEBUG

import Foundation
import SwiftData

// MARK: - PreviewDataHelper

/// Fügt beim ersten App-Start im Debug-Modus Sample-Activities in SwiftData ein.
/// Wird nur ausgeführt wenn der Store vollständig leer ist — keine Duplikate möglich.
///
/// Aufruf: `PreviewDataHelper.insertSampleDataIfNeeded(context: modelContext)`
/// — einmalig in `ActivityTracker2App.init()`, nach ModelContainer-Setup.
enum PreviewDataHelper {

    /// Prüft ob SwiftData leer ist und fügt ggf. Sample-Activities ein.
    /// - Parameter context: Aktiver `ModelContext` aus `modelContainer.mainContext`.
    static func insertSampleDataIfNeeded(context: ModelContext) {
        let descriptor = FetchDescriptor<Activity>()
        guard (try? context.fetchCount(descriptor)) == 0 else { return }

        for activity in sampleActivities {
            context.insert(activity)
            if let location = activity.location {
                context.insert(location)
            }
        }
        try? context.save()
    }

    // MARK: - Sample Activities

    private static var sampleActivities: [Activity] { [

        // ══════════════════════════════════════════════════
        // 2026 — 40 Aktivitäten (.daysAgo 1–120)
        // ══════════════════════════════════════════════════

        // ── München Stadt (28) ────────────────────────────

        Activity(categoryId: "running", date: .daysAgo(2),
            title: "Lauf im Englischen Garten",
            text: "10km durch den Park bei Sonnenaufgang. Die Isar glitzert, die Stadt schläft noch. Perfekter Start in den Tag.",
            isFavorite: true,
            location: Location(latitude: 48.1642, longitude: 11.6054, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "cafe", date: .daysAgo(4),
            title: "Frühstück Viktualienmarkt",
            text: "Frischer Obatzda, Brezen und ein Radler in der Sonne. München im Frühling ist unschlagbar.",
            location: Location(latitude: 48.1351, longitude: 11.5761, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "restaurant", date: .daysAgo(6),
            title: "Abendessen Marienplatz",
            text: "Weisswurst zum Abendessen — eigentlich falsch aber so gut. Das Rathaus leuchtet golden.",
            isFavorite: true,
            location: Location(latitude: 48.1374, longitude: 11.5755, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "yoga", date: .daysAgo(8),
            title: "Yoga Westpark",
            text: "Outdoor Yoga mit 20 anderen im Park. Vogelgezwitscher statt Musik. So sollte jeder Morgen sein.",
            location: Location(latitude: 48.1098, longitude: 11.5023, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "cinema", date: .daysAgo(10),
            title: "Kino Mathäser",
            text: "Neuer Film in der Dolby Atmos Suite. Der Sound hat mich von meinem Sitz gerissen. Grandios.",
            location: Location(latitude: 48.1401, longitude: 11.5523, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "cycling", date: .daysAgo(12),
            title: "Radtour Isar entlang",
            text: "30km flussaufwärts bis Wolfratshausen. Flaches Terrain, perfektes Wetter, Brotzeit am Ufer.",
            isFavorite: true,
            location: Location(latitude: 48.1334, longitude: 11.5667, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "cafe", date: .daysAgo(14),
            title: "Café Schwabing",
            text: "Flat White und Zeitung lesen im Lieblingscafé. Die Stammgäste kennen meinen Namen inzwischen.",
            location: Location(latitude: 48.1634, longitude: 11.5923, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "fitness", date: .daysAgo(16),
            title: "Fitness Olympiapark",
            text: "Outdoor Training mit Blick auf den Olympiaturm. 5 Uhr abends, goldenes Licht, perfekte Kulisse.",
            location: Location(latitude: 48.1731, longitude: 11.5508, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "concert", date: .daysAgo(18),
            title: "Konzert Olympiahalle",
            text: "Coldplay Konzert mit 70.000 Menschen. Wristbands die im Takt leuchten. Unvergessliche Nacht.",
            isFavorite: true,
            location: Location(latitude: 48.1731, longitude: 11.5508, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "bar", date: .daysAgo(20),
            title: "Hofbräuhaus Abend",
            text: "Mit Freunden aus Hamburg die Stadt gezeigt. Hofbräu, Haxn und Blasmusik — München wie im Film.",
            location: Location(latitude: 48.1376, longitude: 11.5800, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "museum", date: .daysAgo(22),
            title: "Museum Deutsches Museum",
            text: "Ausstellung über Raumfahrt — Apollo 11 Kapsel hautnah. Technik kann auch Poesie sein.",
            location: Location(latitude: 48.1299, longitude: 11.5834, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "swimming", date: .daysAgo(25),
            title: "Schwimmen Freibad Dantebad",
            text: "Erster Freibadtag des Jahres. Noch nicht warm genug aber der Sprung ins Wasser war befreiend.",
            location: Location(latitude: 48.1623, longitude: 11.5123, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "theater", date: .daysAgo(28),
            title: "Theater Residenztheater",
            text: "Faust I — 4 Stunden aber keine Minute zu lang. Das Ensemble war atemberaubend.",
            isFavorite: true,
            location: Location(latitude: 48.1412, longitude: 11.5798, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "hiking", date: .daysAgo(30),
            title: "Wandern Olympiahügel",
            text: "Runde um den Olympiasee, Hügel rauf und runter. Klein aber fein — mitten in der Stadt wandern.",
            location: Location(latitude: 48.1731, longitude: 11.5508, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "photography", date: .daysAgo(33),
            title: "Fotografie Maxvorstadt",
            text: "Straßenfotografie durch die Maxvorstadt. Alte Architektur, neue Menschen, hundert gute Bilder.",
            isFavorite: true,
            location: Location(latitude: 48.1489, longitude: 11.5712, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "restaurant", date: .daysAgo(36),
            title: "Restaurant Haidhausen",
            text: "Neues Thai-Restaurant im Franzosenviertel. Grünes Curry das mich an Bangkok erinnert hat.",
            location: Location(latitude: 48.1289, longitude: 11.5967, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "journal", date: .daysAgo(40),
            title: "Tagebuch Isarpromenade",
            text: "Eine Stunde auf einem Stein sitzen und schreiben. Die Isar rauscht, die Gedanken fliessen.",
            location: Location(latitude: 48.1334, longitude: 11.5667, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "cafe", date: .daysAgo(44),
            title: "Café Glockenbachviertel",
            text: "Sonntagmorgen, Zeitung, Cappuccino. Das Viertel erwacht langsam. So muss Sonntag sein.",
            location: Location(latitude: 48.1298, longitude: 11.5634, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "running", date: .daysAgo(48),
            title: "Laufen Nymphenburg",
            text: "8km durch den Schlosspark. Schwäne auf dem Kanal, Jogger auf den Wegen, Frieden im Kopf.",
            isFavorite: true,
            location: Location(latitude: 48.1567, longitude: 11.4998, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "bar", date: .daysAgo(52),
            title: "Bar Schumann's",
            text: "Cocktails bei Schumann's. Die Bar ist eine Institution. Der Barkeeper kennt jeden beim Namen.",
            location: Location(latitude: 48.1423, longitude: 11.5856, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "festival", date: .daysAgo(56),
            title: "Festival Streetlife",
            text: "Streetlife Festival auf der Leopoldstrasse. Essen aus aller Welt, Live-Musik, Sonne satt.",
            isFavorite: true,
            location: Location(latitude: 48.1623, longitude: 11.5867, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "fitness", date: .daysAgo(60),
            title: "Fitness Bogenhausen",
            text: "Crossfit Session im neuen Box in Bogenhausen. Erst gelitten, dann Endorphine. Immer wieder.",
            location: Location(latitude: 48.1534, longitude: 11.6123, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "wine_tasting", date: .daysAgo(65),
            title: "Weinprobe Lehel",
            text: "6 Weine aus der Pfalz, kompetente Beratung, schöner Keller. Deutschen Wein neu entdeckt.",
            location: Location(latitude: 48.1423, longitude: 11.5912, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "museum", date: .daysAgo(70),
            title: "Pinakothek der Moderne",
            text: "Ausstellung zeitgenössischer Fotografie. Bilder die man nicht mehr vergisst. Stark.",
            isFavorite: true,
            location: Location(latitude: 48.1489, longitude: 11.5712, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "swimming", date: .daysAgo(75),
            title: "Schwimmen Müllersches Volksbad",
            text: "Art Nouveau Hallenbad aus 1901. Schwimmen als Zeitreise. Das schönste Bad Münchens.",
            isFavorite: true,
            location: Location(latitude: 48.1289, longitude: 11.5834, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "restaurant", date: .daysAgo(80),
            title: "Restaurant Neuhausen",
            text: "Kleines Trattoria versteckt in einer Seitenstrasse. Hausgemachte Pasta, kein Tourismus.",
            location: Location(latitude: 48.1567, longitude: 11.5234, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "hiking", date: .daysAgo(85),
            title: "Theresienwiese spazieren",
            text: "Ohne Oktoberfest ein riesiger ruhiger Platz. Kinder spielen, Hunde toben, Ruhe pur.",
            location: Location(latitude: 48.1312, longitude: 11.5490, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "concert", date: .daysAgo(90),
            title: "Konzert Muffatwerk",
            text: "Indie-Konzert im Muffatwerk. 500 Leute, perfekte Akustik, Band zum ersten Mal live gesehen.",
            location: Location(latitude: 48.1289, longitude: 11.5834, city: "München", region: "Bayern", country: "Deutschland")),

        // ── München Umland (8) ────────────────────────────

        Activity(categoryId: "hiking", date: .daysAgo(15),
            title: "Wanderung Starnberger See",
            text: "12km Rundwanderung um den See. Schneebedeckte Alpen spiegeln sich im Wasser. Traumhaft.",
            isFavorite: true,
            location: Location(latitude: 47.9967, longitude: 11.3398, city: "Starnberg", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "swimming", date: .daysAgo(35),
            title: "Schwimmen Ammersee",
            text: "Erster Badetag am Ammersee. Kaltes Wasser, Berge im Hintergrund. Bayern im Sommer ist perfekt.",
            location: Location(latitude: 48.0023, longitude: 11.1234, city: "Herrsching", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "cafe", date: .daysAgo(45),
            title: "Café Tegernsee",
            text: "Kaffee und Kuchen mit Seeblick. Die Bayern-Klischees stimmen alle — und das ist gut so.",
            location: Location(latitude: 47.7123, longitude: 11.7523, city: "Tegernsee", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "skiing", date: .daysAgo(55),
            title: "Skifahren Zugspitze",
            text: "Skifahren auf fast 3000m. Oben Sonne, unten Wolken. Deutschland von seiner schönsten Seite.",
            isFavorite: true,
            location: Location(latitude: 47.4211, longitude: 10.9850, city: "Zugspitze", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "hiking", date: .daysAgo(95),
            title: "Wanderung Schliersee",
            text: "Schlierseer Bergpfad mit Blick auf den See. 4 Stunden, 600 Höhenmeter, absolute Stille.",
            isFavorite: true,
            location: Location(latitude: 47.7334, longitude: 11.8567, city: "Schliersee", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "festival", date: .daysAgo(100),
            title: "Chiemsee Segeln",
            text: "Zum ersten Mal auf einem Segelboot. Wind, Wellen, Frauenchiemsee am Horizont.",
            location: Location(latitude: 47.8712, longitude: 12.4234, city: "Chiemsee", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "restaurant", date: .daysAgo(105),
            title: "Restaurant Bad Tölz",
            text: "Traditionelle bayerische Küche in einer Wirtschaft seit 1890. Schmalznudeln und Weissbier.",
            location: Location(latitude: 47.7601, longitude: 11.5567, city: "Bad Tölz", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "hiking", date: .daysAgo(110),
            title: "Garmisch Wanderung",
            text: "Partnachklamm bei Eis und Schnee. Die Schlucht donnert und sprüht. Natur at its best.",
            isFavorite: true,
            location: Location(latitude: 47.4912, longitude: 11.0956, city: "Garmisch", region: "Bayern", country: "Deutschland")),

        // ── Deutschland (2) ───────────────────────────────

        Activity(categoryId: "museum", date: .daysAgo(50),
            title: "Berlin Museumsinsel",
            text: "Pergamonaltar, Nofretete, Neues Museum. Berlin ist eine Weltstadt der Kultur.",
            isFavorite: true,
            location: Location(latitude: 52.5200, longitude: 13.4050, city: "Berlin", region: "Berlin", country: "Deutschland")),

        Activity(categoryId: "festival", date: .daysAgo(75),
            title: "Hamburg Fischmarkt",
            text: "Um 5 Uhr morgens am Fischmarkt. Ausrufer, frischer Fisch, Seemöwen. Echter Hamburg-Vibe.",
            location: Location(latitude: 53.5511, longitude: 9.9937, city: "Hamburg", region: "Hamburg", country: "Deutschland")),

        // ── Welt (2) ──────────────────────────────────────

        Activity(categoryId: "museum", date: .daysAgo(20),
            title: "Tokyo Teamlab",
            text: "Digital Art Installation in Odaiba. Licht, Wasser, Spiegelräume. Kunst die man körperlich spürt.",
            isFavorite: true,
            location: Location(latitude: 35.6762, longitude: 139.6503, city: "Tokyo", region: "Tokyo", country: "Japan")),

        Activity(categoryId: "restaurant", date: .daysAgo(88),
            title: "Barcelona Tapas",
            text: "Tapas-Crawl durch El Born. Patatas bravas, Jamón, Cava. Barcelona versteht Lebensqualität.",
            isFavorite: true,
            location: Location(latitude: 41.3851, longitude: 2.1734, city: "Barcelona", region: "Katalonien", country: "Spanien")),

        // ══════════════════════════════════════════════════
        // 2025 — 30 Aktivitäten (.daysAgo 121–485)
        // ══════════════════════════════════════════════════

        // ── München Stadt (17) ────────────────────────────

        Activity(categoryId: "festival", date: .daysAgo(200),
            title: "Oktoberfest Theresienwiese",
            text: "Erstes Mal auf der Wiesn mit ausländischen Freunden. Tracht, Bier, Blasmusik — sie waren begeistert.",
            isFavorite: true,
            location: Location(latitude: 48.1312, longitude: 11.5490, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "running", date: .daysAgo(220),
            title: "Marathon München",
            text: "Erster Halbmarathon — 21km durch die Stadt. Bei km 18 wollte ich aufhören. Gut dass ich es nicht tat.",
            isFavorite: true,
            location: Location(latitude: 48.1374, longitude: 11.5755, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "festival", date: .daysAgo(240),
            title: "Christkindlmarkt Marienplatz",
            text: "Glühwein, Lebkuchen, Punsch. Der Marienplatz im Dezember ist Magie pur.",
            isFavorite: true,
            location: Location(latitude: 48.1374, longitude: 11.5755, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "bar", date: .daysAgo(260),
            title: "Sommer Biergarten Englischer Garten",
            text: "Chinesischer Turm Biergarten, Masskrug, Sonnenschein. 5000 Menschen, alle glücklich.",
            location: Location(latitude: 48.1642, longitude: 11.6054, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "fitness", date: .daysAgo(280),
            title: "Pilates Schwabing",
            text: "Pilates Kurs, 10 Einheiten. Mein Rücken dankt es mir täglich. Hätte früher anfangen sollen.",
            location: Location(latitude: 48.1634, longitude: 11.5923, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "concert", date: .daysAgo(300),
            title: "Konzert BMW Welt",
            text: "Jazz Konzert in der BMW Welt. Ungewöhnlicher Ort, perfekte Akustik, toller Abend.",
            location: Location(latitude: 48.1768, longitude: 11.5590, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "swimming", date: .daysAgo(320),
            title: "Surfwelle Eisbach",
            text: "Zugeschaut wie die Surfer die stehende Welle reiten. Im Englischen Garten surfen — absurd und cool.",
            isFavorite: true,
            location: Location(latitude: 48.1434, longitude: 11.5867, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "cafe", date: .daysAgo(340),
            title: "Café Maxvorstadt",
            text: "Arbeitscafé für einen Tag. Flat White nach dem anderen, 6 Stunden konzentriert geschrieben.",
            location: Location(latitude: 48.1489, longitude: 11.5712, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "hiking", date: .daysAgo(360),
            title: "Wanderung Isar Schlucht",
            text: "Isarschluchtwanderung südlich von München. Wildes Bayern, Stromschnellen, Falken.",
            isFavorite: true,
            location: Location(latitude: 48.1198, longitude: 11.5834, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "restaurant", date: .daysAgo(380),
            title: "Restaurant Au",
            text: "Griechisches Restaurant im Herzen der Au. Souvlaki, Tzatziki, Retsina. Urlaub ohne Flug.",
            location: Location(latitude: 48.1198, longitude: 11.5834, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "museum", date: .daysAgo(400),
            title: "Museum Haus der Kunst",
            text: "Retrospektive eines zeitgenössischen Künstlers. Verstanden habe ich nicht alles, bewegt hat es mich.",
            location: Location(latitude: 48.1423, longitude: 11.5912, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "yoga", date: .daysAgo(420),
            title: "Yoga Nymphenburg",
            text: "Outdoor Yoga im Schlosspark. Ein Pfau ist durch die Reihen spaziert. Unvergesslich.",
            isFavorite: true,
            location: Location(latitude: 48.1567, longitude: 11.4998, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "photography", date: .daysAgo(440),
            title: "Fotografie Englischer Garten",
            text: "Herbst im Englischen Garten. Goldene Blätter, Nebel, der Monopteros als Silhouette.",
            isFavorite: true,
            location: Location(latitude: 48.1642, longitude: 11.6054, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "theater", date: .daysAgo(460),
            title: "Theater Kammerspiele",
            text: "Experimentelles Theater — eine Frau, ein Stuhl, 90 Minuten Text. Hypnotisch.",
            location: Location(latitude: 48.1389, longitude: 11.5778, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "cycling", date: .daysAgo(470),
            title: "Cycling Olympiapark",
            text: "Runde um das Olympiagelände. Abends wenn alles leer ist gehört einem der Park allein.",
            location: Location(latitude: 48.1731, longitude: 11.5508, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "wine_tasting", date: .daysAgo(480),
            title: "Weinbar Isarvorstadt",
            text: "Naturwein-Bar im Glockenbach. Biodynamischer Riesling, Keramiktassen, Holzhocker. Hipster pur.",
            location: Location(latitude: 48.1334, longitude: 11.5667, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "cafe", date: .daysAgo(485),
            title: "Kaffee Sendlinger Tor",
            text: "Neues Specialty Coffee Shop direkt am Tor. Die Bohnen kommen aus Äthiopien. Komplex und fruchtig.",
            location: Location(latitude: 48.1334, longitude: 11.5645, city: "München", region: "Bayern", country: "Deutschland")),

        // ── München Umland (8) ────────────────────────────

        Activity(categoryId: "hiking", date: .daysAgo(210),
            title: "Wanderung Zugspitze",
            text: "Reintalangerhütte und zurück. 28km, 1800 Höhenmeter. Härteste Wanderung meines Lebens.",
            isFavorite: true,
            location: Location(latitude: 47.4211, longitude: 10.9850, city: "Garmisch", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "cycling", date: .daysAgo(250),
            title: "Ammersee Radtour",
            text: "55km Seerunde. Herrschinger Promenade, Diessen, Utting. Flach, schön, Brotzeit mit Seeblick.",
            isFavorite: true,
            location: Location(latitude: 48.0023, longitude: 11.1234, city: "Herrsching", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "hiking", date: .daysAgo(290),
            title: "Tegernsee Wanderung",
            text: "Hirschberg Gipfel, 1600m. Blick auf 5 Seen gleichzeitig. Bayern ist unglaublich schön.",
            isFavorite: true,
            location: Location(latitude: 47.7123, longitude: 11.7523, city: "Tegernsee", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "festival", date: .daysAgo(310),
            title: "Ingolstadt Shopping",
            text: "Designer Outlet Ingolstadt. 3 Stunden, 5 Tüten, ein leeres Konto. Bereue nichts.",
            location: Location(latitude: 48.7667, longitude: 11.4234, city: "Ingolstadt", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "bar", date: .daysAgo(330),
            title: "Freising Weihenstephan",
            text: "Älteste Brauerei der Welt. Das Bier schmeckt hier anders — vielleicht liegt es an den 1000 Jahren.",
            location: Location(latitude: 48.4023, longitude: 11.7456, city: "Freising", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "skiing", date: .daysAgo(350),
            title: "Skifahren Spitzingsee",
            text: "Tagesticket Spitzingsee. Pisten leer, Schnee perfekt, Hütteneinkehr mit Germknödel.",
            location: Location(latitude: 47.6712, longitude: 11.8834, city: "Spitzingsee", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "running", date: .daysAgo(370),
            title: "Rosenheim Stadtlauf",
            text: "10km Stadtlauf Rosenheim. Erste Teilnahme an einem organisierten Lauf. Nie wieder... bis zum nächsten.",
            location: Location(latitude: 47.8567, longitude: 12.1234, city: "Rosenheim", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "photography", date: .daysAgo(450),
            title: "Landsberg am Lech",
            text: "Historische Altstadt, Lechfall, Rathaus. Perle zwischen München und Augsburg.",
            location: Location(latitude: 48.0523, longitude: 10.8712, city: "Landsberg", region: "Bayern", country: "Deutschland")),

        // ── Deutschland (3) ───────────────────────────────

        Activity(categoryId: "museum", date: .daysAgo(230),
            title: "Köln Kölner Dom",
            text: "760 Jahre Bauzeit. Auf dem Turm stehen und die Stadt überblicken. Geschichte zum Anfassen.",
            isFavorite: true,
            location: Location(latitude: 50.9333, longitude: 6.9500, city: "Köln", region: "NRW", country: "Deutschland")),

        Activity(categoryId: "concert", date: .daysAgo(410),
            title: "Dresden Semperoper",
            text: "Staatsoper Dresden. Die Akustik, die Architektur, das Ensemble. Eine der schönsten Opern weltweit.",
            isFavorite: true,
            location: Location(latitude: 51.0504, longitude: 13.7373, city: "Dresden", region: "Sachsen", country: "Deutschland")),

        Activity(categoryId: "viewpoint", date: .daysAgo(475),
            title: "Heidelberg Schloss",
            text: "Sonnenuntergang vom Schloss. Die Altstadt liegt orange und rosa im Abendlicht. Deutschland kann romantisch.",
            isFavorite: true,
            location: Location(latitude: 49.3988, longitude: 8.6724, city: "Heidelberg", region: "Baden-Württemberg", country: "Deutschland")),

        // ── Welt (2) ──────────────────────────────────────

        Activity(categoryId: "cafe", date: .daysAgo(270),
            title: "Wien Kaffeehauskultur",
            text: "Melange im Café Central. Zeitungen lesen wie vor 100 Jahren. Wien erfindet Entschleunigung.",
            isFavorite: true,
            location: Location(latitude: 48.2082, longitude: 16.3738, city: "Wien", region: "Wien", country: "Österreich")),

        Activity(categoryId: "museum", date: .daysAgo(390),
            title: "Amsterdam Rijksmuseum",
            text: "Rembrandt, Vermeer, Van Gogh. 3 Stunden und nur die Hälfte gesehen. Wiederkommen ist Pflicht.",
            location: Location(latitude: 52.3676, longitude: 4.9041, city: "Amsterdam", region: "Noord-Holland", country: "Niederlande")),

        // ══════════════════════════════════════════════════
        // 2024 — 20 Aktivitäten (.daysAgo 486–850)
        // ══════════════════════════════════════════════════

        // ── München Stadt (10) ────────────────────────────

        Activity(categoryId: "running", date: .daysAgo(490),
            title: "Silvesterlauf München",
            text: "5km Lauf am 31. Dezember. 2024 sportlich beenden, 2025 sportlich beginnen. Plan aufgegangen.",
            location: Location(latitude: 48.1374, longitude: 11.5755, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "cinema", date: .daysAgo(550),
            title: "Sommer Kino Olympiapark",
            text: "Open Air Kino unter Sternen. Film auf Grossleinwand, Decke dabei, Sommernacht. Perfekt.",
            isFavorite: true,
            location: Location(latitude: 48.1731, longitude: 11.5508, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "swimming", date: .daysAgo(600),
            title: "Surfen Eisbach lernen",
            text: "Erste Surfstunde auf der Eisbachwelle. 45 Minuten geübt, 3 Sekunden gestanden. Süchtig.",
            isFavorite: true,
            location: Location(latitude: 48.1434, longitude: 11.5867, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "running", date: .daysAgo(650),
            title: "Stadtlauf Schwabing",
            text: "Spontaner 15km Lauf durch Schwabing, Maxvorstadt und zurück. Kopfhörer rein, Stadt erkunden.",
            location: Location(latitude: 48.1634, longitude: 11.5923, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "concert", date: .daysAgo(700),
            title: "Konzert Backstage",
            text: "Indie Band aus Portland — erster Deutschlandauftritt. 200 Leute, 100% Energie. Entdeckung.",
            isFavorite: true,
            location: Location(latitude: 48.1489, longitude: 11.5234, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "yoga", date: .daysAgo(750),
            title: "Yogakurs Neuhausen",
            text: "8-Wochen Kurs, jeden Dienstag. Der Körper hat sich verändert. Die Ruhe auch.",
            location: Location(latitude: 48.1567, longitude: 11.5234, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "photography", date: .daysAgo(780),
            title: "Fotokurs Englischer Garten",
            text: "Workshop Streetfotografie. Blende, Verschluss, Komposition. Plötzlich sehe ich alles anders.",
            isFavorite: true,
            location: Location(latitude: 48.1642, longitude: 11.6054, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "theater", date: .daysAgo(800),
            title: "Theater an der Isar",
            text: "Experimentelles Stück über Einsamkeit in der Stadt. Sehr unbequem. Sehr wichtig.",
            location: Location(latitude: 48.1289, longitude: 11.5834, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "bar", date: .daysAgo(820),
            title: "Biergarten Flaucher",
            text: "Flaucher Biergarten an der Isar. Selbst mitgebrachtes Essen erlaubt. Bayerische Demokratie.",
            location: Location(latitude: 48.1023, longitude: 11.5567, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "museum", date: .daysAgo(840),
            title: "Pinakothek moderne",
            text: "Design Ausstellung Braun und Apple. Wie Dieter Rams Steve Jobs beeinflusst hat. Faszinierend.",
            location: Location(latitude: 48.1489, longitude: 11.5712, city: "München", region: "Bayern", country: "Deutschland")),

        // ── München Umland (5) ────────────────────────────

        Activity(categoryId: "skiing", date: .daysAgo(510),
            title: "Skitouren Zugspitzplatt",
            text: "Erste Skitour überhaupt. 800 Höhenmeter rauf, 3 Minuten runter. Das Verhältnis stimmt trotzdem.",
            isFavorite: true,
            location: Location(latitude: 47.4211, longitude: 10.9850, city: "Zugspitze", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "cycling", date: .daysAgo(580),
            title: "Mountainbike Lenggries",
            text: "Singletrail von der Brauneck-Alm runter. Technisch, schnell, adrenalinreich. Wiederkommen.",
            isFavorite: true,
            location: Location(latitude: 47.6834, longitude: 11.5789, city: "Lenggries", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "hiking", date: .daysAgo(640),
            title: "Wanderung Benediktenwand",
            text: "Technisch anspruchsvoller Aufstieg, 1800m. Oben allein mit den Wolken. Absoluter Favorit.",
            isFavorite: true,
            location: Location(latitude: 47.6523, longitude: 11.4667, city: "Benediktbeuern", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "festival", date: .daysAgo(720),
            title: "Starnberg Segeln lernen",
            text: "Segelkurs am Starnberger See. Wind lesen lernen. Das Boot gehorcht wenn man es versteht.",
            location: Location(latitude: 47.9967, longitude: 11.3398, city: "Starnberg", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "swimming", date: .daysAgo(810),
            title: "Erding Therme",
            text: "Weltweit grösste Therme. 5 Stunden Wasser, Sauna, Dampfbad. Völlig regeneriert danach.",
            location: Location(latitude: 48.3067, longitude: 11.9067, city: "Erding", region: "Bayern", country: "Deutschland")),

        // ── Deutschland (3) ───────────────────────────────

        Activity(categoryId: "museum", date: .daysAgo(530),
            title: "Frankfurt Städel Museum",
            text: "700 Jahre europäische Kunst. Botticelli bis Bacon. Frankfurt überrascht kulturell immer wieder.",
            location: Location(latitude: 50.1109, longitude: 8.6821, city: "Frankfurt", region: "Hessen", country: "Deutschland")),

        Activity(categoryId: "concert", date: .daysAgo(660),
            title: "Leipzig Bachfest",
            text: "Bach in seiner Heimatstadt. Die Thomaskirche als Konzertsaal. Musik die 300 Jahre überdauert.",
            isFavorite: true,
            location: Location(latitude: 51.3397, longitude: 12.3731, city: "Leipzig", region: "Sachsen", country: "Deutschland")),

        Activity(categoryId: "museum", date: .daysAgo(830),
            title: "Stuttgart Mercedes Museum",
            text: "150 Jahre Automobilgeschichte. Das erste Auto der Welt. Technik als Kulturgeschichte.",
            location: Location(latitude: 48.7758, longitude: 9.1829, city: "Stuttgart", region: "Baden-Württemberg", country: "Deutschland")),

        // ── Welt (2) ──────────────────────────────────────

        Activity(categoryId: "running", date: .daysAgo(560),
            title: "New York Central Park",
            text: "Laufen im Central Park — 10km Runde. New York von seiner ruhigsten Seite. Morgens um 6.",
            isFavorite: true,
            location: Location(latitude: 40.7851, longitude: -73.9683, city: "New York", region: "New York", country: "USA")),

        Activity(categoryId: "photography", date: .daysAgo(760),
            title: "Bali Reisterrassen",
            text: "Tegallalang Reisterrassen bei Sonnenaufgang. Grüne Stufen bis zum Horizont. Unwirklich schön.",
            isFavorite: true,
            location: Location(latitude: -8.4095, longitude: 115.1889, city: "Ubud", region: "Bali", country: "Indonesien")),

        // ══════════════════════════════════════════════════
        // 2023 — 5 Aktivitäten (.daysAgo 851–1100)
        // ══════════════════════════════════════════════════

        Activity(categoryId: "running", date: .daysAgo(900),
            title: "Erster Halbmarathon",
            text: "21km München City Run. Training seit 4 Monaten. Bei km 19 geweint vor Erschöpfung und Stolz.",
            isFavorite: true,
            location: Location(latitude: 48.1374, longitude: 11.5755, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "hiking", date: .daysAgo(950),
            title: "Kapstadt Tafelberg",
            text: "Seilbahn hoch, zu Fuss runter. Die Küste von oben — wo Atlantik und Indischer Ozean sich treffen.",
            isFavorite: true,
            location: Location(latitude: -33.9628, longitude: 18.4098, city: "Kapstadt", region: "Westkap", country: "Südafrika")),

        Activity(categoryId: "skiing", date: .daysAgo(1000),
            title: "Erstes Mal Skifahren",
            text: "Skikurs in Sölden. Tag 1: 20x gefallen. Tag 3: Blaue Piste alleine. Tag 5: Rot. Süchtig.",
            isFavorite: true,
            location: Location(latitude: 46.9523, longitude: 11.0034, city: "Sölden", region: "Tirol", country: "Österreich")),

        Activity(categoryId: "photography", date: .daysAgo(1050),
            title: "Paris Montmartre",
            text: "Sacré-Coeur bei Nacht. Künstler auf dem Platz, Lichter der Stadt darunter. Klischee und trotzdem wahr.",
            isFavorite: true,
            location: Location(latitude: 48.8867, longitude: 2.3431, city: "Paris", region: "Île-de-France", country: "Frankreich")),

        Activity(categoryId: "festival", date: .daysAgo(1100),
            title: "Nürnberg Christkindlesmarkt",
            text: "Der Ur-Weihnachtsmarkt. Nürnberger Bratwurst, Zwetschgenmännle, Glühwein im Becher.",
            location: Location(latitude: 49.4521, longitude: 11.0767, city: "Nürnberg", region: "Bayern", country: "Deutschland")),

        // ══════════════════════════════════════════════════
        // 2022 — 3 Aktivitäten (.daysAgo 1101–1300)
        // ══════════════════════════════════════════════════

        Activity(categoryId: "museum", date: .daysAgo(1150),
            title: "Bangkok Wat Pho",
            text: "Liegender Buddha, 46m lang, goldene Fusssohlen. Stille inmitten der lärmenden Stadt. Frieden.",
            isFavorite: true,
            location: Location(latitude: 13.7563, longitude: 100.5018, city: "Bangkok", region: "Bangkok", country: "Thailand")),

        Activity(categoryId: "running", date: .daysAgo(1250),
            title: "München Lockdown Laufen",
            text: "Jeden Tag 5km durch leere Strassen. Die Stadt gehörte uns Läufern. Seltsam schöne Zeit.",
            location: Location(latitude: 48.1374, longitude: 11.5755, city: "München", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "concert", date: .daysAgo(1300),
            title: "Sydney Oper",
            text: "Konzert im Sydney Opera House. Die Muscheln leuchten, der Hafen glitzert. Bucket List erledigt.",
            isFavorite: true,
            location: Location(latitude: -33.8568, longitude: 151.2153, city: "Sydney", region: "NSW", country: "Australien")),

        // ══════════════════════════════════════════════════
        // 2021 — 2 Aktivitäten (.daysAgo 1301–1500)
        // ══════════════════════════════════════════════════

        Activity(categoryId: "hiking", date: .daysAgo(1400),
            title: "Erste Wanderung Alpen",
            text: "Mit 25 zum ersten Mal in den Bergen. Karwendel, 2000m, Adler über uns. Alles hat sich verändert.",
            isFavorite: true,
            location: Location(latitude: 47.4523, longitude: 11.4234, city: "Mittenwald", region: "Bayern", country: "Deutschland")),

        Activity(categoryId: "journal", date: .daysAgo(1480),
            title: "Erstes Tagebuch",
            text: "Angefangen ein Tagebuch zu führen. Erster Eintrag: heute war ein guter Tag. Mehr braucht es nicht.",
            isFavorite: true,
            location: Location(latitude: 48.1374, longitude: 11.5755, city: "München", region: "Bayern", country: "Deutschland")),
    ]}
}

#endif
