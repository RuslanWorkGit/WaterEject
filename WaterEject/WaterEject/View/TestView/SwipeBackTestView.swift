//
//  SwipeBackTestView.swift
//  WaterEject
//
//  Created by Ruslan Liulka on 20.08.2025.
//

import SwiftUI

struct BackSwipeEnabler: UIViewControllerRepresentable {
    let onBack: () -> Void
    var edge: UIRectEdge = .left
    var triggerTranslation: CGFloat = 40
    var triggerVelocity: CGFloat = 800

    func makeUIViewController(context: Context) -> HookVC {
        HookVC(onBack: onBack, edge: edge,
               triggerTranslation: triggerTranslation,
               triggerVelocity: triggerVelocity)
    }

    func updateUIViewController(_ uiViewController: HookVC, context: Context) {}

    final class HookVC: UIViewController, UIGestureRecognizerDelegate {
        let onBack: () -> Void
        let edge: UIRectEdge
        let triggerTranslation: CGFloat
        let triggerVelocity: CGFloat
        weak var edgePan: UIScreenEdgePanGestureRecognizer?

        init(onBack: @escaping () -> Void,
             edge: UIRectEdge,
             triggerTranslation: CGFloat,
             triggerVelocity: CGFloat) {
            self.onBack = onBack
            self.edge = edge
            self.triggerTranslation = triggerTranslation
            self.triggerVelocity = triggerVelocity
            super.init(nibName: nil, bundle: nil)
            view.backgroundColor = .clear
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)
            guard let parent = parent, edgePan == nil else { return }

            let g = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePan(_:)))
            g.edges = edge
            g.delegate = self
            g.cancelsTouchesInView = false
            parent.view.addGestureRecognizer(g)
            self.edgePan = g
        }

        override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            if parent == nil, let g = edgePan, let p = self.parent {
                p.view.removeGestureRecognizer(g)
            }
        }

        @objc private func handleEdgePan(_ g: UIScreenEdgePanGestureRecognizer) {
            let tx = g.translation(in: g.view).x
            let vx = g.velocity(in: g.view).x
            if g.state == .ended {
                if tx > triggerTranslation || vx > triggerVelocity {
                    onBack()
                }
            }
        }

        // дозволяємо жити поруч зі скролами
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool { true }

        // підстрахуємо, що старт дійсно з краю (~20pt)
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let g = gestureRecognizer as? UIScreenEdgePanGestureRecognizer,
                  let v = g.view else { return true }
            let p = g.location(in: v)
            switch edge {
            case .left:  return p.x <= 20
            case .right: return p.x >= v.bounds.width - 20
            default:     return true
            }
        }
    }
}

