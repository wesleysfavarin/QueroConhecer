//
//  MapViewController.swift
//  QueroConhecer
//
//  Created by mac on 31/01/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import MapKit
class MapViewController: UIViewController {

    
    
    enum MapMessageType{
        case routeError
        case authorizationWarning
    }
    // MARK: - IBOutlet
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var acIndicator: UIActivityIndicatorView!
    @IBOutlet weak var lbAddress: UILabel!
    
    // MARK: - Variaveis
    var places: [Place]!
    var poi: [MKAnnotation] = []
    var btUserLocation: MKUserTrackingButton!
    lazy var locationManager = CLLocationManager()
    var selectedAnnotation: PlaceAnnotation?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapView.mapType = .mutedStandard
        searchBar.isHidden = true
        viInfo.isHidden = true
        
        mapView.delegate = self
        locationManager.delegate = self
        if places.count == 1 {
            title = places[0].name
        }else{
            title = "Meus lugares"
        }
        
        
        
        for place in places {
            addToMap(place)
        }
        configureLocationButton()
        
        showPlaces()
        requestUserLocationAuthorization()
        
    }
   
    func configureLocationButton(){
        btUserLocation = MKUserTrackingButton(mapView: mapView)
        btUserLocation.backgroundColor = .white
        btUserLocation.frame.origin.x = 10
        btUserLocation.frame.origin.y = 10
        
        btUserLocation.layer.cornerRadius = 5
        btUserLocation.layer.borderWidth = 1
        btUserLocation.layer.borderColor = UIColor(named: "main")?.cgColor
        
    }
    
    func requestUserLocationAuthorization(){
        if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus(){
            case .authorizedAlways, .authorizedWhenInUse:
                 mapView.addSubview(btUserLocation)
            case .denied:
                showMessage(type: .authorizationWarning)
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            case .restricted:
                break
            }
        }else {
            //não dá
            
        }
    }
    
    
    @IBAction func showRoute(_ sender: UIButton) {
        //verifica se usuario habilitou localizacao
        if  CLLocationManager.authorizationStatus() != .authorizedWhenInUse{
            showMessage(type: .authorizationWarning)
            return
        }
        let request = MKDirections.Request()
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: selectedAnnotation!.coordinate))
        request.source =  MKMapItem(placemark: MKPlacemark(coordinate: locationManager.location!.coordinate))
        
        let directions = MKDirections(request: request)
        directions.calculate{( response, error ) in
            if error == nil {
                if let response = response{
                   // let overlays = self.mapView.overlays
                    self.mapView.removeOverlays(self.mapView.overlays)
                   // self.mapView.removeOverlay(self.mapView!.overlays)
                    let route = response.routes.first!
                    print("Nome", route.name)
                    print("Distância", route.distance)
                    print("Duração", route.expectedTravelTime)
                    //separar :)
                    print("8=====================================D~~~")
                    for step in route.steps{
                        print ("Em \(step.distance) metro(s), \(step.instructions) ")
                    }
                    
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    var annotatios = self.mapView.annotations.filter({!($0 is PlaceAnnotation)})
                    annotatios.append(self.selectedAnnotation!)
                    self.mapView.showAnnotations(annotatios, animated: true)
                    
                    
                    
                }
                
            }else {
                self.showMessage(type: .routeError)
            }
        }
        
        
    }
    
    
    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = !searchBar.isHidden
    }
    
    func addToMap(_ place: Place){
       let annotation = PlaceAnnotation(coordinate: place.coordinate, type: .place)
           annotation.title = place.name
        annotation.address = place.address
        
        mapView.addAnnotation(annotation)


    }
    
    func showPlaces()
    {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    func showInfo(){
        lbName.text = selectedAnnotation!.title
        lbAddress.text = selectedAnnotation!.address
        viInfo.isHidden = false
    }
    
    func showMessage(type: MapMessageType){
        let title = type == .authorizationWarning ? "Aviso": "Erro"
        let message = type == .authorizationWarning ? "Para usar os recursos de localização do app, você precisa permitir o uso na tela de ajustes": "Não foi possível encontrar esta rota"
        
        
       let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        if type == .authorizationWarning {
            let confirmAction = UIAlertAction(title: "Ir para ajustes", style: .default, handler: { (action) in
                
                if let appSettings = URL(string: UIApplication.openSettingsURLString){
                    UIApplication.shared.open(appSettings, options:[:], completionHandler: nil)
                }
        })
    
        alert.addAction(confirmAction)
    }
        present(alert, animated: true, completion: nil )
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is PlaceAnnotation){
            return nil
        }
        let type = (annotation as! PlaceAnnotation).type
        let identifier = "\(type)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if annotationView == nil {
          annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView?.annotation = annotation
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = type == .place ? UIColor(named: "main") : UIColor(named: "poi")
        annotationView?.glyphImage = type == .place ?  UIImage(named: "placeGlyph") : UIImage(named: "poiGlyph")
        annotationView?.displayPriority = type == .place ? .required : .defaultHigh
        
        
        return annotationView
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        //camera 3d \o/
        let camera = MKMapCamera()
        camera.centerCoordinate = view.annotation!.coordinate
        camera.pitch = 80
        camera.altitude = 100
        mapView.setCamera(camera, animated: true)
        
        selectedAnnotation = (view.annotation as! PlaceAnnotation)
        showInfo()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline{
           let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(named: "main")//?.withAlphaComponent(0.8)
            renderer.lineWidth = 5.0
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
        
    }
}
// MARK: - UISearchBarDelegate
extension MapViewController : UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        acIndicator.startAnimating()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error == nil {
                guard let response = response else {
                    self.acIndicator.stopAnimating()
                    
                    return
                    
                }
                
                //limpa para add novos
                self.mapView.removeAnnotations(self.poi)
                self.poi.removeAll()
                for item in response.mapItems{
                    let annotation = PlaceAnnotation(coordinate: item.placemark.coordinate, type: .poi)
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    annotation.address = Place.getFormatedAddress(with: item.placemark)
                    
                    self.poi.append(annotation)
                }
                self.mapView.addAnnotations(self.poi)
                self.mapView.showAnnotations(self.poi, animated: true)
                
            }
            self.acIndicator.stopAnimating()
        }
        
    }
}
// MARK: - CLLocationManagerDelegate
extension MapViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways,.authorizedWhenInUse:
            mapView.showsUserLocation = true
            mapView.addSubview(btUserLocation)
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {


        //monitorarVelocidade(location)
    }
    func monitorarVelocidade(didUpdateLocations locations: [CLLocation]){
        if let location = locations.last {
        print("Velocidade:", location.speed)
            let region = MKCoordinateRegion(center: location.coordinate,latitudinalMeters: 500,longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        }

    }
    
}
