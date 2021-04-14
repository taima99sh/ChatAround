//
//  RegisterViewController.swift
//  ChatAround
//
//  Created by taima on 3/24/21.
//  Copyright © 2021 mac air. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Firebase
import FirebaseStorage
import MapKit
import YPImagePicker

class RegisterViewController: UIViewController {
    
    enum UserType {
        case user
        case place
    }
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var setLocationView: UIView!
    @IBOutlet weak var imgView: UIImageView!
    
    var placeLocation: CLLocationCoordinate2D?
    
    var type: UserType = .user
    
    lazy var picker: YPImagePicker = {
        var config = YPImagePickerConfiguration()
        config.isScrollToChangeModesEnabled = true
        config.onlySquareImagesFromCamera = true
        config.usesFrontCamera = false
        config.showsPhotoFilters = true
        config.shouldSaveNewPicturesToAlbum = true
        config.albumName = "DefaultYPImagePickerAlbumName"
        config.startOnScreen = YPPickerScreen.photo
        config.screens = [.library, .photo]
        config.showsCrop = .none
        config.targetImageSize = YPImageSize.original
        config.overlayView = UIView()
        config.hidesStatusBar = true
        config.hidesBottomBar = false
        config.preferredStatusBarStyle = UIStatusBarStyle.default
        
        config.library.options = nil
        config.library.onlySquare = false
        config.library.minWidthForItem = nil
        config.library.mediaType = YPlibraryMediaType.photo
        config.library.maxNumberOfItems = 1
        config.library.minNumberOfItems = 1
        config.library.numberOfItemsInRow = 4
        config.library.spacingBetweenItems = 1.0
        config.library.skipSelectionsGallery = false
                
        return YPImagePicker(configuration: config)
    }()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnSignup(_ sender: Any) {
        switch type {
        case .user:
            createUser()
        case .place:
            createPlaceUser()
        }
    }
    
    @IBAction func btnAddImage(_ sender: Any) {
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                self.imgView.image = photo.image
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func btnSetLocation(_ sender: Any) {
        let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "SetLocationOnMapViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updatGUI()
    }
}

extension RegisterViewController {
    func updatGUI(){
        switch self.type {
        case .user:
            setLocationView.isHidden = true
        case .place:
            setLocationView.isHidden = false
        }
    }
    
    func createUser(){
        let email = self.txtEmail.text ?? ""
        let password = self.txtPassword.text ?? ""
        let name = self.txtName.text ?? ""
        self.showIndicator()
        Auth.auth().createUser(withEmail: email, password: password) { (data, error) in
            self.hideIndicator()
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let authResult = data {
//                let currentUser = Auth.auth().currentUser
//                if let user = currentUser {
//                    let changeRequest = user.createProfileChangeRequest()
//                   changeRequest.displayName = " "
//                    changeRequest.commitChanges { error in
//                     if let error = error {
//                        print(error.localizedDescription)
//                        return
//                       // An error happened.
//                     }
//
//                   }
//                }
                //
                let user = UserModel(name: name, email: email, token: authResult.user.uid , geoPoint: GeoPoint(latitude: 0, longitude: 0), isOnline: true)
                
                //let userLocation = MKUserLocation.self
                do {
                    let userRef = db.collection("User").document(authResult.user.uid)
                    try userRef.setData(from: user)
                    UserProfile.shared.userID = authResult.user.uid
                    UserProfile.shared.userName = user.name
                    self.uploadImage("User")
                    let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    AppDelegate.shared.rootNavigationViewController.setViewControllers([vc], animated: true)
                } catch let error {
                    print("Error writing user to Firestore: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func createPlaceUser() {
        let email = self.txtEmail.text ?? ""
        let password = self.txtPassword.text ?? ""
        let name = self.txtName.text ?? ""
        self.showIndicator()
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            self.hideIndicator()
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let authResult = authResult, let location = self.placeLocation {
                let place = UserModel(name: name, email: email, token: authResult.user.uid , geoPoint: GeoPoint(latitude: location.latitude, longitude: location.longitude), isOnline: true)
                do {
                    let userRef = db.collection("Places").document(authResult.user.uid)
                    try userRef.setData(from: place)
                    UserProfile.shared.userID = authResult.user.uid
                    UserProfile.shared.userName = place.name
                    self.uploadImage("Places")
                    let vc = UIStoryboard.mainStoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    AppDelegate.shared.rootNavigationViewController.setViewControllers([vc], animated: true)
                } catch let error {
                    print("Error writing user to Firestore: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func uploadImage(_ collection: String) {
        let storage = Storage.storage()
        let storageRef = storage.reference().child("\(collection)/Images/\(UserProfile.shared.userID ?? "")/image.png")
        let metaData = StorageMetadata.init()
        metaData.contentType = "image/png"
        guard let data = self.imgView.image?.jpegData(compressionQuality: 0.5) else { return }
        let uploadTask = storageRef.putData(data, metadata: metaData) { (metadata, error) in
          guard let metadata = metadata else {return}
          let size = metadata.size
            print(size)
          storageRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                print(error?.localizedDescription)
                return
            }
            print(downloadURL)
            let userRef = db.collection(collection).document(UserProfile.shared.userID ?? "")
            //userRef.updateData(["image": downloadURL.absoluteString])
            userRef.setData( ["image": downloadURL.absoluteString], merge: true)
          }
        }
    }
}
