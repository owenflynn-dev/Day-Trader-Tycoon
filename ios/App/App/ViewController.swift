import Capacitor

class ViewController: CAPBridgeViewController {

    // Defer the first upward swipe so iOS shows the home indicator grow
    // before navigating home — same "swipe twice to exit" feel as most games.
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return .bottom
    }

    // Keep the home indicator visible at all times.
    override var prefersHomeIndicatorAutoHidden: Bool {
        return false
    }
}
