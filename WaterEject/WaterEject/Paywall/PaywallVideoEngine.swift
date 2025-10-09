import AVFoundation
import Combine

final class PaywallVideoWarmup: ObservableObject {
    static let shared = PaywallVideoWarmup()

    @Published private(set) var player: AVQueuePlayer?
    @Published private(set) var isReady = false

    private var looper: AVPlayerLooper?
    private var item: AVPlayerItem?
    private var statusObs: NSKeyValueObservation?
    private var firstReady = false

    func prepareIfNeeded() {
        guard player == nil else { return }

        guard let url = Bundle.main.url(forResource: "NewVideo", withExtension: "mp4") else {
            print("❌ NewVideo.mp4 not found in bundle"); return
        }

        let asset = AVURLAsset(url: url)
        let keys = ["playable", "tracks", "duration"]
        asset.loadValuesAsynchronously(forKeys: keys) { [weak self] in
            DispatchQueue.main.async {
                guard let self else { return }

                var e: NSError?
                guard asset.statusOfValue(forKey: "playable", error: &e) == .loaded else {
                    print("❌ Asset not playable:", e ?? "unknown"); return
                }

                let item = AVPlayerItem(asset: asset)
                let q = AVQueuePlayer(items: [])
                q.isMuted = true
                q.automaticallyWaitsToMinimizeStalling = true

                self.item = item
                self.player = q
                self.looper = AVPlayerLooper(player: q, templateItem: item)

                self.statusObs = item.observe(\.status, options: .new) { [weak self] item, _ in
                    guard let self else { return }
                    switch item.status {
                    case .readyToPlay:
                        if !self.firstReady {
                            self.firstReady = true
                            self.isReady = true
                            // легкий праймінг, щоб прибрати перший фриз
                            q.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero)
                            q.preroll(atRate: 1.0) { _ in /* ok */ }
                        }
                    case .failed:
                        print("❌ Item failed:", item.error ?? "unknown")
                    default: break
                    }
                }
            }
        }
    }
}
