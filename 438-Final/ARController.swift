//
//  ARController.swift
//  438-Final
//
//  Created by Jooho Kim on 12/4/21.
//

import UIKit
import RealityKit
import ARKit
import MapKit
import Photos

class ARController: UIViewController, ARSessionDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
 
    
    @IBOutlet weak var arView: ARView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toastLabel: UILabel!
    @IBOutlet weak var trackingStateLabel: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    
    var name: String?
    var theme: String?
    var score: Int = 0
    var scoreOpen: Bool = false
    var scoreView: UIView?
    var continueGame: Bool = true
    
    let coachingOverlay = ARCoachingOverlayView()
    
    let locationManager = CLLocationManager()
    var customLocations:[CustomLocation] = []
//    var anchorName: Dictionary<ARGeoAnchor, String> = [:]
    
    var checklist: Dictionary<String, String> = [:]
    
    var currentAnchors: [ARAnchor] {
        return arView.session.currentFrame?.anchors ?? []
    }
        
    // Geo anchors ordered by the time of their addition to the scene.
    var geoAnchors: [GeoAnchorWithAssociatedData] = []
    
    // Auto-hide the home indicator to maximize immersion in AR experiences.
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    // Hide the status bar to maximize immersion in AR experiences.
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set this view controller as the session's delegate.
        arView.session.delegate = self
        
        // Enable coaching.
        setupCoachingOverlay()
        
        // Set this view controller as the Core Location manager delegate.
        locationManager.delegate = self
        
        // Set this view controller as the MKMapView delegate.
        mapView.delegate = self
        
        // Disable automatic configuration and set up geotracking
        arView.automaticallyConfigureSession = false
                
        // Run a new AR Session.
        restartSession()
                
        // Add tap gesture recognizers
//        arView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnARView(_:))))
//        mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapOnMapView(_:))))
        
        scoreView = UIView(frame: self.arView.frame)
        arView.addSubview(scoreView!)
        scoreView!.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.6)
        scoreView?.isHidden = true
        
        for loc in customLocations {
            checklist[loc.name] = ""
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Prevent the screen from being dimmed to avoid interuppting the AR experience.
        UIApplication.shared.isIdleTimerDisabled = true

        // Start listening for location updates from Core Location
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Disable Core Location when the view disappears.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func scoreSheetTapped(_ sender: Any) {
        if scoreOpen {
            if continueGame {
                print("Close Scoresheet")
                scoreOpen = false
                scoreView?.isHidden = true
            }
            else {
                navigationController?.popToRootViewController(animated: true)
            }
        }
        else {
            print("Open Scoresheet")
            scoreOpen = true
            
            for subUIView in scoreView?.subviews as [UIView] {
                subUIView.removeFromSuperview()
            }
            scoreView?.isHidden = false
            
            var nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            nameLabel.text = "Hi " + name!
            nameLabel.center = CGPoint(x: 207, y: 150)
            scoreView!.addSubview(nameLabel)
            var scoreLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            scoreLabel.center = CGPoint(x: 207, y: 200)
            scoreLabel.text = "Score: " + String(score)
            scoreView!.addSubview(scoreLabel)
            
            let keys = Array(checklist.keys)
            var locationLabel0 = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            locationLabel0.text = keys[0] + ": " + checklist[keys[0]]!
            locationLabel0.center = CGPoint(x: 207, y: 230)
            scoreView!.addSubview(locationLabel0)
            
            var locationLabel1 = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            locationLabel1.text = keys[1] + ": " + checklist[keys[1]]!
            locationLabel1.center = CGPoint(x: 207, y: 260)
            scoreView!.addSubview(locationLabel1)
            
            var locationLabel2 = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
            locationLabel2.text = keys[2] + ": " + checklist[keys[2]]!
            locationLabel2.center = CGPoint(x: 207, y: 290)
            scoreView!.addSubview(locationLabel2)
            
            var discovered = 0
            for key in Array(checklist.keys) {
                if checklist[key] == "Discovered!" {
                    discovered += 1
                }
            }
            if discovered == Array(checklist.keys).count {
                let congrats = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
                congrats.text = "CONGRATULATIONS!"
                congrats.center = CGPoint(x: 207, y: 340)
                scoreView!.addSubview(congrats)
                continueGame = false
            }
        }
    }

    
    // Responds to a user tap on the AR view.
    @objc
    func handleTapOnARView(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: view)
        
        // Perform ARKit raycast on tap location
        if let result = arView.raycast(from: point, allowing: .estimatedPlane, alignment: .any).first {
            addGeoAnchor(at: result.worldTransform.translation)
        } else {
            showToast("No raycast result.\nTry pointing at a different area\nor move closer to a surface.")
        }
    }
    
    // Responds to a user tap on the map view.
    @objc
    func handleTapOnMapView(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: mapView)
        let location = mapView.convert(point, toCoordinateFrom: mapView)
        print(location)
        addGeoAnchor(at: location)
    }
            
    // Presents the available actions when the user presses the menu button.
    func presentAdditionalActions() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Reset Session", style: .destructive, handler: { (_) in
            self.restartSession()
        }))
        actionSheet.addAction(UIAlertAction(title: "Load Anchors …", style: .default, handler: { (_) in
            self.showGPXFiles()
        }))
        actionSheet.addAction(UIAlertAction(title: "Save Anchors …", style: .default, handler: { (_) in
            self.saveAnchors()
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    // Calls into the function that saves any user-created geo anchors to a GPX file.
    func saveAnchors() {
        let geoAnchors = currentAnchors.compactMap({ $0 as? ARGeoAnchor })
        guard !geoAnchors.isEmpty else {
                alertUser(withTitle: "No geo anchors", message: "There are no geo anchors to save.")
            return
        }
        
        saveAnchorsAsGPXFile(geoAnchors)
    }

    func restartSession() {
        // Check geo-tracking location-based availability.
        ARGeoTrackingConfiguration.checkAvailability { (available, error) in
            if !available {
                let errorDescription = error?.localizedDescription ?? ""
                let recommendation = "Please try again in an area where geotracking is supported."
                let restartSession = UIAlertAction(title: "Restart Session", style: .default) { (_) in
                    self.restartSession()
                }
                self.alertUser(withTitle: "Geotracking unavailable",
                               message: "\(errorDescription)\n\(recommendation)",
                               actions: [restartSession])
            }
        }
        
        // Re-run the ARKit session.
        let geoTrackingConfig = ARGeoTrackingConfiguration()
        geoTrackingConfig.planeDetection = [.horizontal]
        arView.session.run(geoTrackingConfig, options: .removeExistingAnchors)
        geoAnchors.removeAll()
        
        arView.scene.anchors.removeAll()
        
        trackingStateLabel.text = ""
        
        // Remove all anchor overlays from the map view
        let anchorOverlays = mapView.overlays.filter { $0 is AnchorIndicator }
        mapView.removeOverlays(anchorOverlays)
        
        showToast("Running new AR session")
    }
    
    func addGeoAnchor(at worldPosition: SIMD3<Float>) {
        arView.session.getGeoLocation(forPoint: worldPosition) { (location, altitude, error) in
            if let error = error {
                self.alertUser(withTitle: "Cannot add geo anchor",
                               message: "An error occurred while translating ARKit coordinates to geo coordinates: \(error.localizedDescription)")
                return
            }
            self.addGeoAnchor(at: location, altitude: altitude)
        }
    }
    
    func addGeoAnchor(at location: CLLocationCoordinate2D, altitude: CLLocationDistance? = nil) {
        var geoAnchor: ARGeoAnchor!
        if let altitude = altitude {
            geoAnchor = ARGeoAnchor(coordinate: location, altitude: altitude)
            print(altitude)
        } else {
            geoAnchor = ARGeoAnchor(coordinate: location)
        }
        
        addGeoAnchor(geoAnchor)
    }
    
    func addGeoAnchor(_ geoAnchor: ARGeoAnchor) {
        
        // Don't add a geo anchor if Core Location isn't sure yet where the user is.
        guard isGeoTrackingLocalized else {
            alertUser(withTitle: "Cannot add geo anchor", message: "Unable to add geo anchor because geotracking has not yet localized.")
            return
        }
        let anchorIndicator = AnchorIndicator(center: geoAnchor.coordinate)

        // Remember the geo anchor we just added
        let anchorInfo = GeoAnchorWithAssociatedData(geoAnchor: geoAnchor, mapOverlay: anchorIndicator)
        self.geoAnchors.append(anchorInfo)
        arView.session.add(anchor: geoAnchor)
    }
    
    var isGeoTrackingLocalized: Bool {
        if let status = arView.session.currentFrame?.geoTrackingStatus, status.state == .localized {
            return true
        }
        return false
    }
    
    func distanceFromDevice(_ coordinate: CLLocationCoordinate2D) -> Double {
        if let devicePosition = locationManager.location?.coordinate {
            return MKMapPoint(coordinate).distance(to: MKMapPoint(devicePosition))
        } else {
            return 0
        }
    }
    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for geoAnchor in anchors.compactMap({ $0 as? ARGeoAnchor }) {
            // Effect a spatial-based delay to avoid blocking the main thread.
            DispatchQueue.main.asyncAfter(deadline: .now() + (distanceFromDevice(geoAnchor.coordinate) / 10)) {
                // Add an AR placemark visualization for the geo anchor.
                self.arView.scene.addAnchor(Entity.placemarkEntity(for: geoAnchor))
            }
            // Add a visualization for the geo anchor in the map view.
            let anchorIndicator = AnchorIndicator(center: geoAnchor.coordinate)
            self.mapView.addOverlay(anchorIndicator)

            // Remember the geo anchor we just added
            let anchorInfo = GeoAnchorWithAssociatedData(geoAnchor: geoAnchor, mapOverlay: anchorIndicator )
            self.geoAnchors.append(anchorInfo)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        DispatchQueue.main.async {
            // Present an alert informing about the error that has occurred.
            let alertController = UIAlertController(title: "The AR session failed.", message: errorMessage, preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
                alertController.dismiss(animated: true, completion: nil)
                self.restartSession()
            }
            alertController.addAction(restartAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    /// - Tag: GeoTrackingStatus
    func session(_ session: ARSession, didChange geoTrackingStatus: ARGeoTrackingStatus) {
        
        hideUIForCoaching(geoTrackingStatus.state != .localized)
        
        var text = ""
        // In localized state, show geotracking accuracy
        if geoTrackingStatus.state == .localized {
            text += "Accuracy: \(geoTrackingStatus.accuracy.description)"
        } else {
            // Otherwise show details why geotracking couldn't localize (yet)
            switch geoTrackingStatus.stateReason {
            case .none:
                break
            case .worldTrackingUnstable:
                let arTrackingState = session.currentFrame?.camera.trackingState
                if case let .limited(arTrackingStateReason) = arTrackingState {
                    text += "\n\(geoTrackingStatus.stateReason.description): \(arTrackingStateReason.description)."
                } else {
                    fallthrough
                }
            default: text += "\n\(geoTrackingStatus.stateReason.description)."
            }
        }
        self.trackingStateLabel.text = text
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//        var translation = matrix_identity_float4x4
//        translation.columns.3.z = 0.1 // Translate 10 cm in front of the camera
//        node.simdTransform = matrix_multiply(frame.camera.transform, translation)
        for (index, anchor) in self.geoAnchors.enumerated() {
            if (distanceFromDevice(anchor.geoAnchor.coordinate) < 3){
                print("Hi")
                arView.session.remove(anchor: anchor.geoAnchor)
                                
                // Remove map overlay
                let reachedLocationName = anchor.geoAnchor.name
                score += 100
                checklist[reachedLocationName!] = "Discovered!"
                // Finished
                mapView.removeOverlay(anchor.mapOverlay)
                self.geoAnchors.remove(at:index)
                scoreSheetTapped(self)
            }
        }
    }
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Update location indicator with live estimate from Core Location
        guard let location = locations.last else { return }
        
        // Update map area
        let camera = MKMapCamera(lookingAtCenter: location.coordinate,
                                 fromDistance: CLLocationDistance(250),
                                 pitch: 0,
                                 heading: mapView.camera.heading)
        mapView.setCamera(camera, animated: false)
    }
    
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let anchorOverlay = overlay as? AnchorIndicator {
            let anchorOverlayView = MKCircleRenderer(circle: anchorOverlay)
            anchorOverlayView.strokeColor = .white
            anchorOverlayView.fillColor = .blue
            anchorOverlayView.lineWidth = 2
            return anchorOverlayView
        }
        return MKOverlayRenderer()
    }
    
    
}
