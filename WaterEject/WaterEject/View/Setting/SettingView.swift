//
//  SettingView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 05.09.2025.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct SettingView: View {
    @State private var webViewURL: URL?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Background()

                ScrollView {
                    VStack(spacing: 24) {
                        HStack {
                            Text("Settings")   // було "Settig"
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            Spacer()
                        }

                        // 👇 Тут з’явиться грід з вашими апками
                        OurAppsSection()

                        Text("Help center")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(Color.gray)
                        
                        VStack(spacing: 12) {
                            Button("Terms") {
                                webViewURL = URL(string: "https://docs.google.com/document/d/1L2xhXP9qKJPSP7rymbXx17-xWh5_17V_nJPBbXm1boE/edit?tab=t.0")
                                
                            }
                            .buttonStyle(PillButtonStyle())
                            
                            Button("Privacy") {
                                webViewURL = URL(string: "https://docs.google.com/document/d/1lQQMYnybap2JyKGf7Sd8gyPD1o9FWnAqgnGKx1BnSJI/edit?tab=t.0")
                                
                            }
                            .buttonStyle(PillButtonStyle())
                        }
   

                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .sheet(item: $webViewURL, content: { url in
            SafariView(url: url)
        })
    }
}

struct PillButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.gray)
            Spacer()
            Image(systemName: "chevron.right") // опційно
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.gray.opacity(0.9))
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading) // ✅ на всю ширину
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.gray.opacity(0.2))                           // ✅ сірий напівпрозорий фон
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.08))                       // тонка обводка (опц.)
        )
        .opacity(configuration.isPressed ? 0.85 : 1)
        .contentShape(RoundedRectangle(cornerRadius: 16))                // коректна зона тапа
    }
}



import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct OurAppsSection: View {
    private let db: Firestore
    @StateObject private var vm: PromoAppsVM

    init() {
        let app = FirebaseApp.app(name: "SharedCatalog")!
        let database = Firestore.firestore(app: app)
        self.db = database                            // <- зберегли для логів
        _vm = StateObject(wrappedValue: PromoAppsVM(db: database))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Our Apps").font(.headline)
            LazyVGrid(columns: [.init(.flexible())], spacing: 12) {
                ForEach(vm.apps) { app in
                    Button {
                        // лог кліку через той самий db
                        db.collection("clicks").addDocument(data: [
                            "src_bundle": Bundle.main.bundleIdentifier ?? "",
                            "dst_bundle": app.bundle_id,
                            "ts": FieldValue.serverTimestamp(),
                            "screen": "settings"
                        ])
                        if let url = vm.link(for: app) { UIApplication.shared.open(url) }
                    } label: {
                        VStack(spacing: 8) {
                            AsyncImage(
                                url: URL(string: app.icon_url),
                                transaction: .init(animation: .easeInOut)
                            ) { phase in
                                switch phase {
                                case .empty:
                                    // ⏳ Лоадер на фоні сірого квадрата
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.gray.opacity(0.2))
                                        .overlay(
                                            ProgressView().scaleEffect(0.9)
                                        )

                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .transition(.opacity) // приємний фейд-ін

                                case .failure:
                                    // 🔁 Фолбек, якщо картинку не вдалося завантажити
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.gray.opacity(0.2))
                                        .overlay(
                                            Image(systemName: "photo")
                                                .font(.title2)
                                                .foregroundColor(.gray)
                                        )

                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                            Text(app.name)
                                .foregroundStyle(Color.gray)
                                .font(.footnote)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
        }
        .onAppear { vm.load() }
    }
}


//#Preview {
//    SettingView()
//}
