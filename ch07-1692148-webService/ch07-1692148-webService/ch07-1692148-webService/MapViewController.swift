//
//  MapViewController.swift
//  ch06-1692148-tabBarController
//
//  Created by mac028 on 2021/04/08.
//

import UIKit
import MapKit
import Progress

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
   
    let baseURLString = "https://api.openweathermap.org/data/2.5/weather"
    let apiKey = "2b5f820e0fd17ed4192b43952cd0276a"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MapViewController.viewDidLoad")
    }
}

extension MapViewController {
    @IBAction func segmentedValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        case 2:
            mapView.mapType = .satellite
        default:
            break
        }
    }
}

extension MapViewController {
    override func viewWillAppear(_ animated: Bool) {
        print("MapViewController.viewWillAppear")
        
        let parent = self.parent as! UITabBarController
        let cityViewController = parent.viewControllers![0] as! CityViewController
        let (city, longitute, latitute) = cityViewController.getCurrentLonLat()

        getWeatherData(cityName: city)
//        updateMap(title: city, longitude: longitute, latitute: latitute)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
    }
}

extension MapViewController {
    func updateMap(title: String, longitude: Double?, latitute: Double?) {
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        var center = mapView.centerCoordinate
        if let longitute = longitude, let latitute = latitute {
            center = CLLocationCoordinate2D(latitude: latitute, longitude: longitute)
        }
        
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
}

extension MapViewController {
    func getWeatherData(cityName city: String) {
        
        Prog.start(in: self, .activityIndicator)
        
        var urlStr = baseURLString+"?"+"q="+city+"&"+"appid="+apiKey
        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let session = URLSession(configuration: .default)
        let url = URL(string: urlStr)
        let request = URLRequest(url: url!)
        
        let dataTask = session.dataTask(with: request) {
            (data, response, error) in
            guard let jsonData = data else { print(error!); return}
            if let jsonStr = String(data: jsonData, encoding: .utf8) {
                print(jsonStr)
            }
            let (temperature, longitute, latitute) = self.extractWeatherData(jsonData: jsonData)
            var title = city
            if let temperature = temperature {
                title += String.init(format: ": %.2f℃", temperature)
            }
            DispatchQueue.main.async {
                self.updateMap(title: title, longitude: longitute, latitute: latitute)
                Prog.dismiss(in: self)
            }
        }
        dataTask.resume()
    }
}

extension MapViewController {
    func extractWeatherData(jsonData: Data) -> (Double?, Double?, Double?) {
        let json = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        
//        {"cod":"404","message":"city not found"} for unknown city
        if let code = json["cod"] {
            if code is String, code as! String == "404" {
                return (nil, nil, nil)
            }
        }
        
        let latitute = (json["coord"] as! [String: Double])["lat"]
        let longitute = (json["coord"] as! [String:Double])["lon"]
        
        guard let temperature = (json["main"] as! [String: Double])["temp"] else {
            return (nil, longitute, latitute)
        }
        
        return (temperature-273.0, longitute, latitute)
    }
}
