//
//  ViewController.swift
//  Speedly
//
//  Created by Justin Taing on 12/1/14.
//  Copyright (c) 2014 Justin Taing. All rights reserved.
//

import UIKit
import CoreLocation
import Foundation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var lblSpeed: UILabel!
    @IBOutlet weak var lblSpeedUnits: UILabel!
    @IBOutlet weak var lblGPSActive: UILabel!
    
    @IBOutlet weak var panGesture: UIPanGestureRecognizer!
    
    let locationManager = CLLocationManager()
    var timer = NSTimer()
    var lblSpeedLimit = UILabel()
    
    var oldLocation:CLLocation = CLLocation()
    var newLocation:CLLocation = CLLocation()
    
    var useSI:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: UIStatusBarAnimation.Fade)
        UIApplication.sharedApplication().idleTimerDisabled = true
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        locationManager.pausesLocationUpdatesAutomatically = true
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
        lblSpeedLimit.textColor = UIColor.whiteColor()
        lblSpeedLimit.font = UIFont(name: "Avenir", size: 20)
        self.view.addSubview(lblSpeedLimit)
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        if (error != nil) {
            println(error)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locationArray = locations as NSArray
        var locationObj = locationArray.lastObject as CLLocation
        var coord = locationObj.coordinate
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func update() {
        locationManager.startUpdatingLocation()
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse) {
            oldLocation = newLocation
            newLocation = locationManager.location
            
            if validateLocation() {
                
                var speed = newLocation.speed
                
                var speedPerHour:Int = convertSpeed(speed, SI: useSI)
                
                lblSpeed.text = formatNumber(speedPerHour)
                
                UIView.transitionWithView(lblGPSActive, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    self.lblGPSActive.textColor = UIColor.greenColor()
                    }, completion: {
                        finished in
                })
            }
            else {
                lblSpeed.text = "000"
                //locationManager.stopUpdatingLocation()
                UIView.transitionWithView(lblGPSActive, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                    self.lblGPSActive.textColor = UIColor.yellowColor()
                    }, completion: {
                        finished in
                })
            }
            
        }
        else {
            lblSpeed.text = "---"
            UIView.transitionWithView(lblGPSActive, duration: 0.5, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
                self.lblGPSActive.textColor = UIColor.redColor()
            }, completion: {
                finished in
            })
        }
    }
    
    func validateLocation() -> Bool {
        if newLocation.horizontalAccuracy < 0 { return false }
        if (-newLocation.timestamp.timeIntervalSinceNow) > 5.0 { return false }
        if newLocation.speed < 0 { return false }
        return true
    }
    
    func formatNumber(num: Int) -> String {
        var zerosRequired = 3 - countElements(String(num))
        var formatString:String = ""
        
        switch zerosRequired {
        case 1:
            formatString = "0\(num)"
        case 2:
            formatString = "00\(num)"
        default:
            formatString = "\(num)"
        }
        
        return formatString
    }
    
    func convertSpeed(speed: Double, SI: Bool) -> Int {
        var convertedSpeed:Int = 0
        if SI { convertedSpeed = Int(round((speed / 1000) * 3600)) }
        else { convertedSpeed = Int(round((speed / 1000) * 0.62137 * 3600)) }
        
        return convertedSpeed
    }
    
    @IBAction func btnShowAbout(sender: UIButton) {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    @IBAction func unwindToMainView (sender: UIStoryboardSegue){
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    @IBAction func tapChangeUnits(sender: UITapGestureRecognizer) {
        useSI = !useSI
        lblSpeedUnits.text = useSI ? "km/h" : "mi/h"
        update()
    }
    
    @IBAction func panAdjustSpeedLimit(sender: UIPanGestureRecognizer) {
        var coordinate = panGesture.locationInView(self.view)
        var screenWidth = UIScreen.mainScreen().bounds.size.width
        
        var speedLimit = Int(round(((310 - (coordinate.y - 20)) / (310)) * 100))
        if speedLimit > 100 { speedLimit = 100 }
        else if speedLimit < 0 { speedLimit = 0 }
        
        lblSpeedLimit.frame.size.width = 50
        lblSpeedLimit.frame.size.height = 25
        
        lblSpeedLimit.frame.origin.x = coordinate.x + 50
        lblSpeedLimit.frame.origin.y = coordinate.y
        
        lblSpeedLimit.text = "\(speedLimit)"
        
        
    }
}
