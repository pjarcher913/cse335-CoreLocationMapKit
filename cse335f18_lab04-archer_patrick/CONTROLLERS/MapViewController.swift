//
//  MapViewController.swift
//  cse335f18_lab04-archer_patrick
//
//  Created by Patrick Archer on 10/28/18.
//  Copyright © 2018 Patrick Archer - Self. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var label_destLocationName: UILabel!
    
    // var to store segue-passed location that user selected in table view
    var userSelectedEntry:location?
    
    // var to store address string of userSelected location (for MapKit utilization)
    var locationAddressString:String?
    var locationDestLat:String?
    var locationDestLon:String?
    
    // outlet for MapKit view
    @IBOutlet weak var mapView: MKMapView!
    
    // outlet for segCntrl_mapOrSatellite
    @IBOutlet weak var segCntrl_mapOrSatellite: UISegmentedControl!
    
    // outlets for lat/lon coordinate display
    @IBOutlet weak var label_latCoords: UILabel!
    @IBOutlet weak var label_lonCoords: UILabel!
    
    // outlets for various placemarks
    var currentPlacemark: CLPlacemark?
    var sourcePlacemark: CLPlacemark?
    var destinationPlacemark: CLPlacemark?
    
    // required vars for map route calculation
    var currentTransportType = MKDirectionsTransportType.automobile
    var currentRoute: MKRoute?
    
    // handler for when user selects which type of map view they desire
    @IBAction func segCntrl_mapOrSatellite(_ sender: UISegmentedControl) {
        // if user selects "Map" view, do...
        if segCntrl_mapOrSatellite.selectedSegmentIndex == 0
        {
            self.mapView.mapType = .standard
        }
        // if user selects "Satellite" view, do...
        else if segCntrl_mapOrSatellite.selectedSegmentIndex == 1
        {
            self.mapView.mapType = .satellite
        }
    }
    
    // handler for when user presses the "Find" barbutton
    @IBAction func barbutton_findNearMe(_ sender: UIBarButtonItem) {
        
        // stores what user wants to look for near destination area
        var userFindEntity:String?
        
        // display alert to user asking what source the image will be from (camera or storage library)
        let alertMsg:String = "Please enter what you are looking for (gas station, coffee shop, etc)."
        let alert = UIAlertController(title: "Find Establishments Near Destination", message: alertMsg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "FIND", style: .default, handler: { action in
            
            //self.userSelectedEntry?.locName = alert.textFields![0].text!
            //self.userSelectedEntry?.locDescription = alert.textFields![1].text!
            
            //self.label_locationName.text! = (self.userSelectedEntry?.locName)!
            //self.label_locationDescription.text! = (self.userSelectedEntry?.locDescription)!
            
            userFindEntity = alert.textFields![0].text!
            
            // execute Google Places API call to find desired establishments near destination
            self.getJSONdata(areaName: self.userSelectedEntry!.locName, establishment: userFindEntity!)
            
            // give user temp popup pertaining to JSON processing failure
            self.jsonErrorPopup()
            
        }))
        
        // [0] - what user is looking for
        alert.addTextField(configurationHandler: { textField in
            //textField.placeholder = self.userSelectedEntry?.locName
            textField.placeholder = "Gas station, coffee shop, grocery store, etc."
        })
        
        self.present(alert, animated: true)
        
    }
    
    /*==========================================================*/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("\(userSelectedEntry!.locName)") // debug
        
        // configure MapView delegate access
        self.mapView.delegate = self;
        
        // check iOS version compatibility
        if #available(iOS 9.0, *) {
            mapView.showsCompass = true
            mapView.showsScale = true
            mapView.showsTraffic = true
        }
        
        // configure segCntrl_mapOrSatellite
        self.segCntrl_mapOrSatellite.setTitle("MAP", forSegmentAt: 0)
        self.segCntrl_mapOrSatellite.setTitle("SATELLITE", forSegmentAt: 1)
        
        // configure initial display of destination location name
        self.label_destLocationName.text = self.userSelectedEntry!.locName
        self.label_latCoords.text = "Destination Lat: (loading)"
        self.label_lonCoords.text = "Destination Lon: (loading)"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // start route calculation and display
        getLocation1()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*==========================================================*/
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    /*==========================================================*/
    
    // mapView delegate to configure route rendering
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = (currentTransportType == .automobile) ? UIColor.blue : UIColor.orange
        renderer.lineWidth = 3.0
        
        return renderer
    }
    
    /*==========================================================*/
    
    func getLocation1()
    {
        let geoCoder = CLGeocoder();
        //let addressString = "699, S. Mill Ave, Tempe, AZ, 85281"
        //let addressString = address.text!
        
        //print("\(self.userSelectedEntry?.locName)") // debug
        
        let addressString = "\(self.userSelectedEntry!.locName)"
        
        print("getLocation1().addressString:String = \(addressString)") // debug
        
        CLGeocoder().geocodeAddressString(addressString, completionHandler:
            {(placemarks, error) in
                
                if error != nil {
                    print("Geocode failed: \(error!.localizedDescription)")
                } else if placemarks!.count > 0 {
                    let placemark = placemarks![0]
                    self.destinationPlacemark = placemark
                    let location = placemark.location
                    let coords = location!.coordinate
                    
                    self.locationDestLat = String(coords.latitude)
                    self.locationDestLon = String(coords.longitude)
                    
                    self.label_latCoords.text = "Destination Lat: \(String(describing: self.locationDestLat!))"
                    self.label_lonCoords.text = "Destination Lon: \(String(describing: self.locationDestLon!))"
                    
                    let span = MKCoordinateSpanMake(1.0, 1.0)
                    let region = MKCoordinateRegion(center: placemark.location!.coordinate, span: span)
                    self.mapView.setRegion(region, animated: true)
                    let ani = MKPointAnnotation()
                    ani.coordinate = placemark.location!.coordinate
                    ani.title = placemark.locality
                    ani.subtitle = placemark.subLocality
                    
                    self.mapView.addAnnotation(ani)
                    
                    self.getLocation2()
                }
        })
    }
    
    func getLocation2()
    {
        // get current location in lat/lon
        //let center : CLLocationCoordinate2D = CLLocationCoordinate2D()
        //print("Current location coords: \(center.latitude), \(center.longitude)")   // debug
        
        // configure initial GeoCoder
        let geoCoder = CLGeocoder();
        
        // build addressString
        let addressString = "Cupertino, CA"
        
        CLGeocoder().geocodeAddressString(addressString, completionHandler:
            {(placemarks, error) in
                
                if error != nil {
                    print("Geocode failed: \(error!.localizedDescription)")
                } else if placemarks!.count > 0 {
                    let placemark = placemarks![0]
                    self.sourcePlacemark = placemark
                    let location = placemark.location
                    let coords = location!.coordinate
                    
                    
                    
                    let span = MKCoordinateSpanMake(1.0, 1.0)
                    let region = MKCoordinateRegion(center: placemark.location!.coordinate, span: span)
                    self.mapView.setRegion(region, animated: true)
                    let ani = MKPointAnnotation()
                    ani.coordinate = placemark.location!.coordinate
                    ani.title = placemark.locality
                    ani.subtitle = placemark.subLocality
                    
                    self.mapView.addAnnotation(ani)
                    
                    // show directions once both locations are done
                    self.showDirections()
                }
        })
    }
    
    func showDirections()
    {
        // get the directions
        let directionRequest = MKDirectionsRequest()
        
        // Set the source and destination of the route
        let sourcePM = MKPlacemark(placemark: self.sourcePlacemark!)
        directionRequest.source = MKMapItem(placemark: sourcePM)
        
        //directionRequest.source = MKMapItem.forCurrentLocation()
        
        let destinationPM = MKPlacemark(placemark: self.destinationPlacemark!)
        directionRequest.destination = MKMapItem(placemark: destinationPM)
        
        directionRequest.transportType = currentTransportType
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { (routeResponse, routeError) -> Void in
            
            guard let routeResponse = routeResponse else {
                if let routeError = routeError {
                    print("Error: \(routeError)")
                }
                
                return
            }
            
            let route = routeResponse.routes[0]
            print("Printing route")
            for step in route.steps {
                print(step.instructions)
            }
            
            
            self.currentRoute = route
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.add(route.polyline, level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
        
    }
    
    func getJSONdata (areaName:String, establishment:String)
    {
        /*
         let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(lon)&radius=500&type=restaurant&key=YOURAPIKEY"
         */
        
        let myAPIkey = "AIzaSyCBXvU6YO4xHQP_9TImp1cN_skshmOdG0s"    // key valid for pjarcher@asu.edu as of 10/28/18
        
        let lat = String(describing: self.locationDestLat!)
        let lon = String(describing: self.locationDestLon!)
        
        // create Google Places API url
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(lat),\(lon)&radius=25&type=\(establishment)&key=\(myAPIkey)"
        
        let url = URL(string: urlString)!
        let urlSession = URLSession.shared
        
        let jsonQuery = urlSession.dataTask(with: url, completionHandler: { data, response, error -> Void in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            var err: NSError?
            
            var jsonResult = (try! JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as! NSDictionary
            if (err != nil) {
                print("JSON Error \(err!.localizedDescription)")
            }
            
            print(jsonResult)
            
            /*let setOne:NSArray = jsonResult["postalcodes"] as! NSArray
            print(setOne);
            
            let y = setOne[0] as? [String: AnyObject]
            print(y?["placeName"])
            
            
            let ln: Double = (y!["lng"] as? NSNumber)!.doubleValue
            let lt: Double = (y!["lat"] as? NSNumber)!.doubleValue
            
            print(ln)
            print(lt)*/
            
            DispatchQueue.main.async
                {
                    //self.lon.text = String(ln)
                    //self.lat.text  = String(lt)
            }
            
        })
        
        jsonQuery.resume()
        
    }
    
    func jsonErrorPopup()
    {
        // display alert to user asking what source the image will be from (camera or storage library)
        let alertTitle:String = "IMPORTANT NOTICE"
        let alertMsg:String = "Please see the XCode console.  There you will find the JSON return from the Google Places API regarding requested establishments near this destination area. I am having trouble parsing the data to pull relevant information pertaining to establishments nearby. As such, the map will not be updated with newly-requested information and this popup serves as a placeholder. If the XCode console has a REQUEST_DENIED error because of my temporary API key running out, a different key must be provided in the meantime to get the API to allow function."
        let alert = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "I ACKNOWLEDGE", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }

}
