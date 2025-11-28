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
    @EnvironmentObject private var tabBarState: TabBarState
    @EnvironmentObject private var coordinator: AppCoordinator        // ← додай
    @State private var showFirstOnboarding = false
    @State private var showSecondOnboarding = false
    @State private var showThirdOnboarding = false
    @State private var showOldOnboarding = false
    @State private var showFourthOnboarding = false
    @State private var showFiveOnboarding = false
    @State private var showSixOnboarding = false
    @State private var showSevenOnboarding = false
    @State private var showEightOnboarding = false
    @State private var showNineOnboarding = false
    
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
                        
//                        Text("Help center")
//                            .font(.system(size: 20, weight: .bold))
//                            .foregroundStyle(Color.gray)
//                        
//                        VStack(spacing: 12) {
//                            
//
////
//                            Button("onboardFive") {
//                                tabBarState.isHidden = true           // ← сховаємо таббар на час онбордингу
//                                showFiveOnboarding = true
//                                
//                            }
//                            .buttonStyle(PillButtonStyle())
//                            
//                            Button("onboardSix") {
//                                tabBarState.isHidden = true           // ← сховаємо таббар на час онбордингу
//                                showSixOnboarding = true
//                                
//                            }
//                            .buttonStyle(PillButtonStyle())
//                            
//                            Button("onboardSeven") {
//                                tabBarState.isHidden = true           // ← сховаємо таббар на час онбордингу
//                                showSevenOnboarding = true
//                                
//                            }
//                            .buttonStyle(PillButtonStyle())
//                            
//                            Button("onboardEight") {
//                                tabBarState.isHidden = true           // ← сховаємо таббар на час онбордингу
//                                showEightOnboarding = true
//                                
//                            }
//                            .buttonStyle(PillButtonStyle())
//                            
//                            Button("onboardNine") {
//                                tabBarState.isHidden = true           // ← сховаємо таббар на час онбордингу
//                                showNineOnboarding = true
//                                
//                            }
//                            .buttonStyle(PillButtonStyle())
                            
                            
//                            Button("FirstOnboard") {
//                                
//                                tabBarState.isHidden = true           // ← сховаємо таббар на час онбордингу
//                                showFirstOnboarding = true
//                                
//                            }
//                            .buttonStyle(PillButtonStyle())
//                            
//                            Button("SecondOnboard") {
//                                tabBarState.isHidden = true           // ← сховаємо таббар на час онбордингу
//                                showSecondOnboarding = true
//                                
//                            }
//                            .buttonStyle(PillButtonStyle())
//                            
//                            Button("ThirdOnboard") {
//                                tabBarState.isHidden = true           // ← сховаємо таббар на час онбордингу
//                                showThirdOnboarding = true
//                                
//                            }
//                            .buttonStyle(PillButtonStyle())
//                            
//                            Button("OldOnboard") {
//                                tabBarState.isHidden = true           // ← сховаємо таббар на час онбордингу
//                                showOldOnboarding = true
//                                
//                            }
//                            .buttonStyle(PillButtonStyle())
                            
//                        }
   

                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 16)
                }
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .safeAreaInset(edge: .bottom) {
              Color.clear.frame(height: 100) // висота твого таббара
            }
        }
        
        .onAppear {
            tabBarState.isHidden = false 
//            Telemetry.shared.settingExposure()
        }
        .sheet(item: $webViewURL, content: { url in
            SafariView(url: url)
        })
        
        .fullScreenCover(isPresented: $showFourthOnboarding, onDismiss: {
            tabBarState.isHidden = false           // повернемо таббар (якщо треба)
        }) {
            OnboardingFlowViewFour()
                .environmentObject(coordinator)    // пробросимо координатор
        }
        .fullScreenCover(isPresented: $showFiveOnboarding, onDismiss: {
            tabBarState.isHidden = false           // повернемо таббар (якщо треба)
        }) {
            OnboardingFlowViewFive()
                .environmentObject(coordinator)    // пробросимо координатор
        }
        .fullScreenCover(isPresented: $showSixOnboarding, onDismiss: {
            tabBarState.isHidden = false           // повернемо таббар (якщо треба)
        }) {
            OnboardingFlowViewSix()
                .environmentObject(coordinator)    // пробросимо координатор
        }
        .fullScreenCover(isPresented: $showSevenOnboarding, onDismiss: {
            tabBarState.isHidden = false           // повернемо таббар (якщо треба)
        }) {
            OnboardingFlowViewSeven()
                .environmentObject(coordinator)    // пробросимо координатор
        }
        .fullScreenCover(isPresented: $showNineOnboarding, onDismiss: {
            tabBarState.isHidden = false           // повернемо таббар (якщо треба)
        }) {
            OnboardingFlowViewNine()
                .environmentObject(coordinator)    // пробросимо координатор
        }
        
        .fullScreenCover(isPresented: $showEightOnboarding, onDismiss: {
            tabBarState.isHidden = false           // повернемо таббар (якщо треба)
        }) {
            
            OnboardAnimationView()
            //OnboardingFlowViewSeven()
                .environmentObject(coordinator)    // пробросимо координатор
        }
        
//        .fullScreenCover(isPresented: $showFirstOnboarding, onDismiss: {
//            tabBarState.isHidden = false           // повернемо таббар (якщо треба)
//        }) {
//            OnboardingFlowViewOne()
//                .environmentObject(coordinator)    // пробросимо координатор
//        }
//        
//        .fullScreenCover(isPresented: $showSecondOnboarding, onDismiss: {
//            tabBarState.isHidden = false           // повернемо таббар (якщо треба)
//        }) {
//            OnboardingFlowViewTwo()
//                .environmentObject(coordinator)    // пробросимо координатор
//        }
//        
//        .fullScreenCover(isPresented: $showThirdOnboarding, onDismiss: {
//            tabBarState.isHidden = false           // повернемо таббар (якщо треба)
//        }) {
//            OnboardingFlowViewThree()
//                .environmentObject(coordinator)    // пробросимо координатор
//        }
//        
//        
//        .fullScreenCover(isPresented: $showOldOnboarding, onDismiss: {
//            tabBarState.isHidden = false           // повернемо таббар (якщо треба)
//        }) {
//            OnboardingFlowView()
//                .environmentObject(coordinator)    // пробросимо координатор
//        }
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
            Text("Our Apps")
                .font(.headline)
                .foregroundStyle(Color.gray)
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
