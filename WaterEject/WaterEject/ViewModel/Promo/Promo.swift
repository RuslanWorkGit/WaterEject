
//
//  Promot.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 05.09.2025.
//

import FirebaseFirestore

struct PromoApp: Identifiable, Decodable {
    var id: String { bundle_id }
    let name: String
    let bundle_id: String
    let store_id: Int
    let icon_url: String
    let active: Bool
    let priority: Int
    let links: [String:String]
}

final class PromoAppsVM: ObservableObject {
    @Published var apps: [PromoApp] = []
    private let db: Firestore
    private let myBundle = Bundle.main.bundleIdentifier ?? ""

    init(db: Firestore) { self.db = db }

    func load() {
        db.collection("apps")
          .whereField("active", isEqualTo: true)
          .order(by: "priority")
          .getDocuments { [weak self] snap, err in
              guard let self, let docs = snap?.documents, err == nil else { return }
              let all = docs.compactMap { try? $0.data(as: PromoApp.self) }
              self.apps = all.filter { $0.bundle_id != self.myBundle } // не показуємо себе
          }
    }

    func link(for app: PromoApp) -> URL? {
        let src = myBundle
        let s = app.links[src] ?? app.links["default"] ?? "https://apps.apple.com/app/id\(app.store_id)"
        return URL(string: s)
    }
}
