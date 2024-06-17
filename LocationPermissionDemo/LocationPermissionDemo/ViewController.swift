//
//  ViewController.swift
//  LocationPermissionDemo
//
//  Created by Developer1 on 22/12/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    private var locationManager = CLLocationManager()
    @IBOutlet weak var lblPermission: UILabel!
    
    @IBOutlet weak var lblLcation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        setCurrentLocation()
    }
    
    @objc func appDidBecomeActive(){
        setCurrentLocation()
    }
    
    func setCurrentLocation(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.activityType = .automotiveNavigation
        switch(locationManager.authorizationStatus) {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestWhenInUseAuthorization()
        case .notDetermined:print("notDetermined")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:print("restricted")
        case .denied:
            print("Denied.")
            lblLcation.text = ""
        @unknown default:
            fatalError()
        }
        let status = locationManager.authorizationStatus
        lblPermission.text = status.rawValue.description
        locationManager.startUpdatingLocation()
    }
    
    func setUsersClosestLocation(location:CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first else {
                let errorString = error?.localizedDescription ?? "Unexpected Error"
                print("Unable to reverse geocode the given location. Error: \(errorString)")
                return
            }
            
            let reversedGeoLocation = GeoLocation(with: placemark)
            print(reversedGeoLocation.name)
            self.lblLcation.text = reversedGeoLocation.name
        }
    }
}

extension ViewController:CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let mUserLocation:CLLocation = locations.first{
            setUsersClosestLocation(location: mUserLocation)
        }
    }
}

struct GeoLocation {
    let name: String
    let streetName: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    init(with placemark: CLPlacemark) {
            self.name           = placemark.name ?? ""
            self.streetName     = placemark.thoroughfare ?? ""
            self.city           = placemark.locality ?? ""
            self.state          = placemark.administrativeArea ?? ""
            self.zipCode        = placemark.postalCode ?? ""
            self.country        = placemark.country ?? ""
        }

}
