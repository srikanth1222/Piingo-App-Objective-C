//
//  ViewController.swift
//  Test Geofence
//
//  Created by Veedepu Srikanth on 04/01/18.
//  Copyright © 2018 Piing. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

@objc class GeofenceViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {
    
    let ENTERED_REGION_MESSAGE = "Welcome to Piing!"
    let ENTERED_REGION_NOTIFICATION_ID = "EnteredRegionNotification"
    let EXITED_REGION_MESSAGE = "Bye! Hope you had a great day at Piing!"
    let EXITED_REGION_NOTIFICATION_ID = "ExitedRegionNotification"
    
    var notificationCenter = UNUserNotificationCenter.current()
    
    var locationManager = CLLocationManager()
    
    let radius:Double = 100
    
    @IBOutlet weak var lblLatitude: UILabel!
    @IBOutlet weak var lblLongitude: UILabel!
    
    // Gachibowli
    
    let latitude = 17.431381
    let longitude = 78.373930
    
    // ABR Residency
    
//    let latitude = 17.359114
//    let longitude = 78.520559
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        // register as it's delegate
        notificationCenter.delegate = self
        
        // define what do you need permission to use
        let options: UNAuthorizationOptions = [.alert, .sound]
        
        // request permission
        notificationCenter.requestAuthorization(options: options) { (granted, error) in
            if !granted {
                print("Permission not granted")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func geofenceMethod () {
        // Your coordinates go here (lat, lon)
        let geofenceRegionCenter = CLLocationCoordinate2DMake(latitude,longitude)
        
        /* Create a region centered on desired location,
         choose a radius for the region (in meters)
         choose a unique identifier for that region */
        let geofenceRegion = CLCircularRegion(center: geofenceRegionCenter,
                                              radius: radius,
                                              identifier: "UniqueIdentifier2")
        
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        
        locationManager.startMonitoring(for: geofenceRegion)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedAlways) {
            //App Authorized, stablish geofence
            geofenceMethod()
        }
        else if (status == CLAuthorizationStatus.authorizedWhenInUse) {
            //App Authorized, stablish geofence
            geofenceMethod()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Started Monitoring Region: \(region.identifier)")
        self.locationManager.requestState(for: region);
    }
    
    // called when user Exits a monitored region
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            // Do what you want if this information
            print("Region exited")
            self.handleEvent(forRegion: region, withMessage:EXITED_REGION_MESSAGE, notifIdentifier:EXITED_REGION_NOTIFICATION_ID)
        }
        
        let alertCon = UIAlertController(title: "oooopss!!!", message: "Region Exited", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        alertCon.addAction(action)
        
        present(alertCon, animated: true, completion: nil)
    }
    
    // called when user Enters a monitored region
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            // Do what you want if this information
            print("Region entered")
            self.handleEvent(forRegion: region, withMessage:ENTERED_REGION_MESSAGE, notifIdentifier:ENTERED_REGION_NOTIFICATION_ID)
        }
        
        let alertCon = UIAlertController(title: "Yahoo!!!", message: "Region Entered", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        alertCon.addAction(action)
        
        present(alertCon, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print(state)
        
        if state == .inside {
            
            let alertCon = UIAlertController(title: "Yahoo!!!", message: "Region Entered", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                
                self.dismiss(animated: true, completion: nil)
            }
            
            alertCon.addAction(action)
            
            present(alertCon, animated: true, completion: nil)
        }
        else if state == .outside {
            let alertCon = UIAlertController(title: "oooopss!!!", message: "Region Exited", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                
                self.dismiss(animated: true, completion: nil)
            }
            
            alertCon.addAction(action)
            
            present(alertCon, animated: true, completion: nil)
        }
        else if state == .unknown {
            let alertCon = UIAlertController(title: "Error!", message: "Region Unknown", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default) { (action) in
                
                self.dismiss(animated: true, completion: nil)
            }
            
            alertCon.addAction(action)
            
            present(alertCon, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let latestLocation = locations.last
        
        let latitude = String(format: "%f", latestLocation!.coordinate.latitude)
        let longitude = String(format: "%f", latestLocation!.coordinate.longitude)
        
        lblLatitude.text = latitude
        lblLongitude.text = longitude
        
        print("Latitude: \(latitude)")
        print("Longitude: \(longitude)")
    }
    
    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        
        let alertCon = UIAlertController(title: "", message: "Paused Location", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        alertCon.addAction(action)
        
        present(alertCon, animated: true, completion: nil)
        
        print ("Paused location")
    }
    
    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        let alertCon = UIAlertController(title: "", message: "Resumed Location", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.dismiss(animated: true, completion: nil)
        }
        
        alertCon.addAction(action)
        
        present(alertCon, animated: true, completion: nil)
        
        print ("Resumed location")
    }
    
    func handleEvent(forRegion region: CLRegion!, withMessage message:String, notifIdentifier identifier:String) {
        
        // customize your notification content
        let content = UNMutableNotificationContent()
        content.title = "Piing!"
        content.body = message
        content.sound = UNNotificationSound.default()
        
//        // when the notification will be triggered
//        let timeInSeconds: TimeInterval = (60 * 15) // 60s * 15 = 15min
//        // the actual trigger object
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInSeconds,
//                                                        repeats: false)
//
        // notification unique identifier, for this example, same as the region to avoid duplicate notifications
        //let identifier = region.identifier
        
        // the notification request object
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: nil)
        
        // trying to add the notification request to notification center
        notificationCenter.add(request, withCompletionHandler: { (error) in
            if error != nil {
                print("Error adding notification with identifier: \(identifier)")
            }
        })
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // when app is onpen and in foregroud
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // get the notification identifier to respond accordingly
        let identifier = response.notification.request.identifier
        
        // do what you need to do
        
        // ...
    }
}

