import Foundation

/// Replace this placeholder with a validated Vision/Core ML detector.
/// The first MVP keeps automatic mode off until a model is trained and tested.
protocol RallyDetectionService {
    func shouldEndRally(recentActivityScore: Double) -> Bool
}

struct ConservativeRallyDetector: RallyDetectionService {
    func shouldEndRally(recentActivityScore: Double) -> Bool {
        // Placeholder only: this score is not currently fed by a trained model.
        // Return false to avoid accidentally cutting off real rallies.
        false
    }
}
