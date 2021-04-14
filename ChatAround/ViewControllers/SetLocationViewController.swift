//
//  SetLocationViewController.swift
//  ChatAround
//
//  Created by taima on 4/6/21.
//  Copyright © 2021 mac air. All rights reserved.
//


import UIKit
import MapKit
import CoreLocation

class SetLocationOnMapViewController: UIViewController {
    var country: String?
    var street: String?
    var neighborhood: String?
    let kDefault_latitude: CLLocationDegrees = 23.8859
    let kDefault_longitude: CLLocationDegrees = 45.0792
    var selectedLocation: CLLocationCoordinate2D?
    
    // Generate MKMapView
    lazy var _mapView: MKMapView = {
        let mv = MKMapView(frame: self.view.frame)
        
        // Set a delegate.
        mv.delegate = self
        
        // Designate center point.
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(kDefault_latitude, kDefault_longitude)
        
        // Set center point in MapView.
        mv.setCenter(center, animated: true)
        
        // Specify the scale (display area).
        let mySpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 20, longitudeDelta: 20)
        let myRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, span: mySpan)
        
        // Add region to MapView.
        mv.region = myRegion
        
        // Generate long-press UIGestureRecognizer.
        let myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        myLongPress.addTarget(self, action: #selector(recognizeLongPress(_:)))
        
        // Added UIGestureRecognizer to MapView.
        mv.addGestureRecognizer(myLongPress)
        
        return mv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        localized()
        setupData()
        //fetchData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnDone(_ sender: Any) {
        // send location to registerViewController
//        let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
//        vc.placeLocation = self.selectedLocation
        
        self.navigationController?.popViewController(animated: true)
        let vc = AppDelegate.shared.rootNavigationViewController.viewControllers.last as! RegisterViewController
        vc.placeLocation = self.selectedLocation
    }
    
    // A method called when long press is detected.
    @objc private func recognizeLongPress(_ sender: UILongPressGestureRecognizer) {
        // Do not generate pins many times during long press.
        if sender.state != UIGestureRecognizer.State.began {
            return
        }
        // Get the coordinates of the point you pressed long.
        let location = sender.location(in: _mapView)
                
        // Convert location to CLLocationCoordinate2D.
        let myCoordinate: CLLocationCoordinate2D = _mapView.convert(location, toCoordinateFrom: _mapView)
        let coordinateLocation: CLLocation = CLLocation(latitude: myCoordinate.latitude, longitude: myCoordinate.longitude)
        selectedLocation = myCoordinate
        self.render(coordinateLocation)
    }
}
extension SetLocationOnMapViewController {
    func setupView(){
        //self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        self.view.addSubview(_mapView)
    }
    func localized(){}
    func setupData(){}

}

extension SetLocationOnMapViewController: MKMapViewDelegate {
    
    // Delegate method called when addAnnotation is done.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let myPinIdentifier = "PinAnnotationIdentifier"
        // Generate pins.
        let myPinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: myPinIdentifier)
        // Add animation.
        myPinView.animatesDrop = true
        // Display callouts.
        myPinView.canShowCallout = true
        // Set annotation.
        myPinView.annotation = annotation
        return myPinView
    }
    
}
extension SetLocationOnMapViewController {
        
    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//        let span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
//        let region = MKCoordinateRegion(center: coordinate, span: span)
//       _mapView.setRegion(region, animated: true)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        location.placemark { placemark, error in
            guard let placemark = placemark else {
                print("Error:", error ?? "nil")
                return
            }
            print(placemark.postalAddressFormatted ?? "")
            print(placemark.streetName ?? " ")
            self.country = placemark.country ?? ""
            self.street = "\(placemark.streetName)  \(placemark.streetNumber)"
            self.neighborhood = placemark.neighborhood
            pin.title = placemark.country ?? " "
            pin.subtitle = placemark.city ?? ""
        }
        self._mapView.removeAnnotations(self._mapView.annotations)
        _mapView.addAnnotation(pin)
    }
}





