// HomeLocationSheet.swift
// ActivityTracker2 — Remember
// Sheet zum Einrichten der Zuhause-Location

import SwiftUI
import MapKit

// MARK: - HomeLocationSheet

/// Sheet zur Ersteinrichtung der Heimat-Location.
/// Wird beim ersten Tippen auf "Tagebuch" (ohne gespeichertes Zuhause) angezeigt.
struct HomeLocationSheet: View {

    // MARK: Parameter

    @Binding var isShowing: Bool

    // MARK: Environment

    @Environment(UserSettings.self) private var userSettings

    // MARK: State

    @State private var searchText  = ""
    @State private var suggestions: [MKLocalSearchCompletion] = []
    @State private var completer   = SearchCompleter()

    // MARK: Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // ── Header ────────────────────────────────────────────
                VStack(spacing: 12) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color(hex: "#E8593C"))

                    Text(String(localized: "home.prompt.title",
                                defaultValue: "Wo ist dein Zuhause?"))
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(String(localized: "home.prompt.body",
                                defaultValue: "Mit einem Zuhause kannst du Tagebucheinträge noch schneller erfassen — ohne Ort suchen zu müssen."))
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 24)
                .padding(.bottom, 20)

                // ── Suchfeld ──────────────────────────────────────────
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)

                    TextField(
                        String(localized: "home.prompt.search.placeholder",
                               defaultValue: "Stadt oder Adresse suchen..."),
                        text: $searchText
                    )
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .onChange(of: searchText) { _, new in
                        completer.search(new) { results in
                            suggestions = results
                        }
                    }

                    if !searchText.isEmpty {
                        Button {
                            searchText  = ""
                            suggestions = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                // ── Suchergebnisse ────────────────────────────────────
                List {
                    ForEach(suggestions.prefix(6), id: \.self) { suggestion in
                        Button {
                            selectHome(suggestion)
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: "#E8593C").opacity(0.15))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "house.fill")
                                        .foregroundStyle(Color(hex: "#E8593C"))
                                        .font(.system(size: 15))
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.title)
                                        .foregroundStyle(.primary)
                                        .lineLimit(1)
                                    if !suggestion.subtitle.isEmpty {
                                        Text(suggestion.subtitle)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)

                Spacer()

                // ── Kein Zuhause ─────────────────────────────────────
                Button {
                    dismiss()
                } label: {
                    Text(String(localized: "home.prompt.skip",
                                defaultValue: "Kein Zuhause eingeben"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 32)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: Private

    private func dismiss() {
        UserDefaults.standard.set(true, forKey: "hasSeenHomePrompt")
        isShowing = false
    }

    private func selectHome(_ suggestion: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: suggestion)
        MKLocalSearch(request: request).start { response, _ in
            guard let item = response?.mapItems.first else { return }
            DispatchQueue.main.async {
                userSettings.setHomeLocation(
                    coordinate: item.placemark.coordinate,
                    name: item.name ?? suggestion.title
                )
                UserDefaults.standard.set(true, forKey: "hasSeenHomePrompt")
                isShowing = false

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(
                        name: .homeLocationSetNavigate,
                        object: nil
                    )
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Home Location Sheet") {
    @Previewable @State var isShowing = true
    let settings = UserSettings()

    return HomeLocationSheet(isShowing: $isShowing)
        .environment(settings)
}
