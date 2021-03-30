//
//  ViewController.swift
//  ChatAround
//
//  Created by taima on 3/22/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FirebaseFirestoreSwift

let db = Firestore.firestore()

struct Person {
    var name: String
    var image: String
    var location: CLLocation
}

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    let bottomSheetVC = InfoSheetViewController()
    var timer = RepeatingTimer(timeInterval: 30 * 60)
    
    //var locations: [CLLocation] = []
    var cUsers: [UserModel] = []
    var users: [UserModel] = []
    var userLocation: CLLocation?
    let manager = CLLocationManager ()
    var distance: Double {
        return 30000
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
        addBottomSheetView()
        setupView()
        setupData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addPins()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func btnLogout(_ sender: Any) {
        do {
           try Auth.auth().signOut()
            if let userID = UserProfile.shared.userID {
                let db = Firestore.firestore()
                let ref = db.collection("User").document(userID)
                ref.setData( ["isOnline": false], merge: true)
            }
           UserDefaults.resetDefaults()
           let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
           AppDelegate.shared.rootNavigationViewController.setViewControllers([vc], animated: true)
           print("signOut")
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

extension ViewController {
    func setupView(){
        mapView.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = true
        self.mapView.showsUserLocation = true
    }
    func setupData(){
        timer.resume()
        timer.eventHandler = {
            DispatchQueue.main.async { [weak self] in
                guard let Wself = self else {return}
                Wself.fetchUsers()
            }
        }
    }
    
    func addBottomSheetView() {
        self.addChild(bottomSheetVC)
        self.view.addSubview(bottomSheetVC.view)
        bottomSheetVC.didMove(toParent: self)
        let height = view.frame.height
        let width  = view.frame.width
        bottomSheetVC.view.frame = CGRect(x: 0, y: self.view.frame.maxY, width: width, height: height)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
       if let location = locations.last {
        self.userLocation = location
        if let userID = UserProfile.shared.userID {
            let ref = db.collection("User").document(userID)
            ref.setData( ["geoPoint": GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)], merge: true)
        }
        render(location)
        self.addPins()
       }
    }
    func render(_ location: CLLocation) {
        let x = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
        mapView.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 250,
        maxCenterCoordinateDistance: distance)
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: x), animated: true)
        mapView.setRegion(x, animated: true)
    }
    //UPDATE
    func addPins() {
        if let userLocation = self.userLocation {
            let annotations = mapView.annotations.filter({ !($0 is MKUserLocation) })
            mapView.removeAnnotations(annotations)
            for user in users {
                mapView.addAnnotation(user)
            }
            render(userLocation)
        }
    }
}

extension ViewController: MKMapViewDelegate {
        
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("didDeSelect Function")
        bottomSheetVC.close()
    }
    

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        bottomSheetVC.user = view.annotation as? UserModel
        bottomSheetVC.setupData()
       print("didSelectAnnotationTapped")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let pin  = annotation as? UserModel {
            let pinView = MKAnnotationView(annotation: pin, reuseIdentifier: "EcoPin")
                let transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                pinView.transform = transform
                pinView.image = pin.image
                return pinView
        }
          return nil
    }
}
extension ViewController {
    
    func fetchUsers() {
        let db = Firestore.firestore()
        let userRef = db.collection("User")
        let query = userRef.whereField("isOnline", isEqualTo: true)
        query.getDocuments { (querySnapshot, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let querySnapshot = querySnapshot, let userLocation = self.userLocation {
                for doc in querySnapshot.documents {
                    let result = Result {
                        try doc.data(as: UserModel.self)
                    }
                    switch result {
                    case .success(let user):
                        if let user = user {
                            user.coordinate = CLLocationCoordinate2D(latitude: user.geoPoint?.latitude ?? 0, longitude: user.geoPoint?.longitude ?? 0)
                            let location = CLLocation(latitude: user.coordinate.latitude, longitude: user.coordinate.longitude)
                            if (userLocation.distance(from: location) > self.distance) || user.token == UserProfile.shared.userID || location == userLocation {
                                continue
                            }
                            self.cUsers.append(user)
                            print("\(user.email)")
                        } else {
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        print("Error decoding user: \(error)")
                    }
                }
                self.users = self.cUsers
                self.bottomSheetVC.tableView.reloadData()
                self.addPins()
            }
        }
    }
}

