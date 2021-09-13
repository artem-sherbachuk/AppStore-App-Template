/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The haptics portion of the HapticRicochet app.
*/

import CoreHaptics
import UIKit

public class CustomHaptic {

    // The haptic engine and state.
    var engine: CHHapticEngine?
    var engineNeedsStart = true
    var onPlayer: CHHapticPatternPlayer?
    var offPlayer: CHHapticPatternPlayer?

    lazy var supportsHaptics: Bool = {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }()

    private var foregroundToken: NSObjectProtocol?
    private var backgroundToken: NSObjectProtocol?

    init() {
        createAndStartHapticEngine()
        initializeSpawnHaptics()
        initializeImplodeHaptics()
        addObservers()
    }


    private func addObservers() {
        backgroundToken = NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification,
                                                                 object: nil,
                                                                 queue: nil) { [weak self] _ in
            guard let self = self, self.supportsHaptics else { return }

            self.stopHapticEngine()

        }

        foregroundToken = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification,
                                                                 object: nil,
                                                                 queue: nil) { [weak self] _ in
            guard let self = self, self.supportsHaptics else { return }

            self.restartHapticEngine()
        }
    }
    
    func createAndStartHapticEngine() {
        guard supportsHaptics else { return }
        
        // Create and configure a haptic engine.
        do {
            engine = try CHHapticEngine(audioSession: .sharedInstance())
        } catch let error {
            fatalError("Engine Creation Error: \(error)")
        }
        
        // The stopped handler alerts engine stoppage.
        engine?.stoppedHandler = { reason in
            print("Stop Handler: The engine stopped for reason: \(reason.rawValue)")
            switch reason {
            case .audioSessionInterrupt:
                print("Audio session interrupt.")
            case .applicationSuspended:
                print("Application suspended.")
            case .idleTimeout:
                print("Idle timeout.")
            case .notifyWhenFinished:
                print("Finished.")
            case .systemError:
                print("System error.")
            case .engineDestroyed:
                print("Engine destroyed.")
            case .gameControllerDisconnect:
                print("Controller disconnected.")
            @unknown default:
                print("Unknown error")
            }
            
            // Indicate that the next time the app requires a haptic, the app must call engine.start().
            self.engineNeedsStart = true
        }
        
        // The reset handler notifies the app that it must reload all of its content.
        // If necessary, it recreates all players and restarts the engine in response to a server restart.
        engine?.resetHandler = {
            print("The engine reset --> Restarting now!")
            
            // Tell the app to start the engine the next time a haptic is necessary.
            self.engineNeedsStart = true
        }
        
        // Start the haptic engine to prepare it for use.
        do {
            try engine?.start()
            
            // Indicate that the next time the app requires a haptic, the app doesn't need to call engine.start().
            engineNeedsStart = false
        } catch let error {
            print("The engine failed to start with error: \(error)")
        }
    }

    func initializeSpawnHaptics() {
        // Create a pattern from the spawn asset.
        let pattern = createPatternFromAHAP("Spawn")!
        
        // Create a player from the spawn pattern.
        onPlayer = try? engine?.makePlayer(with: pattern)
    }
    
    func initializeImplodeHaptics() {
        // Create a pattern from the implode asset.
        let pattern = createPatternFromAHAP("Implode")!
        
        // Create a player from the implode pattern.
        offPlayer = try? engine?.makePlayer(with: pattern)
    }
    
    private func createPatternFromAHAP(_ filename: String) -> CHHapticPattern? {
        // Get the URL for the pattern in the app bundle.
        let patternURL = Bundle.main.url(forResource: filename, withExtension: "ahap")!
        
        do {
            // Read JSON data from the URL.
            let patternJSONData = try Data(contentsOf: patternURL, options: [])
            
            // Create a dictionary from the JSON data.
            let dict = try JSONSerialization.jsonObject(with: patternJSONData, options: [])
            
            if let patternDict = dict as? [CHHapticPattern.Key: Any] {
                // Create a pattern from the dictionary.
                return try CHHapticPattern(dictionary: patternDict)
            }
        } catch let error {
            print("Error creating haptic pattern: \(error)")
        }
        return nil
    }
    
    func startPlayer(_ player: CHHapticPatternPlayer) {
        guard supportsHaptics else { return }
        do {
            try startHapticEngineIfNecessary()
            try player.start(atTime: CHHapticTimeImmediate)
        } catch let error {
            print("Error starting haptic player: \(error)")
        }
    }
    
    func stopPlayer(_ player: CHHapticPatternPlayer) {
        guard supportsHaptics else { return }
        
        do {
            try startHapticEngineIfNecessary()
            try player.stop(atTime: CHHapticTimeImmediate)
        } catch let error {
            print("Error stopping haptic player: \(error)")
        }
    }
    
    func startHapticEngineIfNecessary() throws {
        if engineNeedsStart {
            try engine?.start()
            engineNeedsStart = false
        }
    }
    
    func restartHapticEngine() {
        self.engine?.start { error in
            if let error = error {
                print("Haptic Engine Startup Error: \(error)")
                return
            }
            self.engineNeedsStart = false
        }
    }
    
    func stopHapticEngine() {
        self.engine?.stop { error in
            if let error = error {
                print("Haptic Engine Shutdown Error: \(error)")
                return
            }
            self.engineNeedsStart = true
        }
    }

    func playOn() {
        guard let onPlayer = onPlayer else { return }
        startPlayer(onPlayer)
        
    }

    func playOff() {
        guard let offPlayer = offPlayer else { return }
        startPlayer(offPlayer)
    }
}
