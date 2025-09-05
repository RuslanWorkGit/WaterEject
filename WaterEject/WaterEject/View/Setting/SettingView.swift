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

                        // ...інші секції налаштувань
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
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
//                        db.collection("clicks").addDocument(data: [
//                            "src_bundle": Bundle.main.bundleIdentifier ?? "",
//                            "dst_bundle": app.bundle_id,
//                            "ts": FieldValue.serverTimestamp(),
//                            "screen": "settings"
//                        ])
                        if let url = vm.link(for: app) { UIApplication.shared.open(url) }
                    } label: {
                        VStack(spacing: 8) {
                            AsyncImage(url: URL(string: app.icon_url)) { img in
                                img.resizable().scaledToFill()
                            } placeholder: { Color.gray.opacity(0.15) }
                            .frame(width: 56, height: 56)
                            .clipShape(RoundedRectangle(cornerRadius: 12))

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
