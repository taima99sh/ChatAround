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
    var timer = RepeatingTimer(timeInterval: 30)
    
    //var locations: [CLLocation] = []
    var cUsers: [UserModel] = []
    var users: [UserModel] = []
    var userLocation: CLLocation?
    let manager = CLLocationManager ()
    var isFirstTime: Bool = true
    var places: [UserModel] = []
    var distance: Double {
        return 30000
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsers()
        addBottomSheetView()
        setupView()
        setupData()
        getPlaces()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addPins()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func btnToUserProfile(_ sender: Any) {
        let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        AppDelegate.shared.rootNavigationViewController.pushViewController(vc, animated: true)
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
        self.render(location, isFirstTime)
        self.addPins()
       }
    }
    
    func render(_ location: CLLocation, _ isFirstTime: Bool) {
        guard self.isFirstTime else {return}
        self.isFirstTime = !self.isFirstTime
        let x = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
        mapView.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 250,
        maxCenterCoordinateDistance: distance)
        mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: x), animated: true)
        mapView.setRegion(x, animated: true)
    }
    //UPDATE
    func addPins() {
        let annotations = mapView.annotations.filter({ !($0 is MKUserLocation) })
        mapView.removeAnnotations(annotations)
        for user in users {
            mapView.addAnnotation(user)
        }
        for place in places {
            mapView.addAnnotation(place)
        }
      print("")
    }
    
    func setMapBounds() {
        if let userLocation = self.userLocation {
            let x = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: distance, longitudinalMeters: distance)
            mapView.cameraZoomRange = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 250,
            maxCenterCoordinateDistance: distance)
            mapView.setCameraBoundary(MKMapView.CameraBoundary(coordinateRegion: x), animated: true)
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
            if pin.type == "user" {
                let pinView = MKAnnotationView(annotation: pin, reuseIdentifier: "EcoPin")
                let transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
                    pinView.transform = transform
                    pinView.image = pin.image
                    return pinView
            }
            //return MKAnnotationView(annotation: pin, reuseIdentifier: "EcoPin")
        }
          return nil
    }
}


extension ViewController {
    
    func fetchUsers() {
        self.showIndicator()
        let userRef = db.collection("User")
        let query = userRef.whereField("isOnline", isEqualTo: true)
        query.getDocuments { (querySnapshot, error) in
            self.hideIndicator()
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if let querySnapshot = querySnapshot, let userLocation = self.userLocation {
                self.cUsers.removeAll()
                for doc in querySnapshot.documents {
                    let result = Result {
                        try doc.data(as: UserModel.self)
                    }
                    switch result {
                    case .success(let user):
                        if let user = user {
                            user.coordinate = CLLocationCoordinate2D(latitude: user.geoPoint?.latitude ?? 0, longitude: user.geoPoint?.longitude ?? 0)
                            user.type = "user"
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
                self.setMapBounds()
            }
            self.addPins()
        }
    }
    
    func getPlaces() {
        let placeRef = db.collectionGroup("Places")
        placeRef.getDocuments { (querySnapshot, error) in
            self.hideIndicator()
            if let error = error {
                print(error)
                return
            }
            
            if let querySnapshot = querySnapshot {
                for doc in querySnapshot.documents {
                    let result = Result {
                        try doc.data(as: UserModel.self)
                    }
                    switch result {
                    case .success(let place):
                        if let place = place {
                            print(place.email)
                            place.coordinate = CLLocationCoordinate2D(latitude: place.geoPoint?.latitude ?? 0, longitude: place.geoPoint?.longitude ?? 0)
                            place.type = "place"
                            self.places.append(place)
                        } else {
                            print("Document does not exist")
                        }
                    case .failure(let error):
                        print("Error decoding user: \(error)")
                    }
                }
            }
        }
    }
}

