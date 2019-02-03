//
//  PlaceFinderViewController.swift
//  QueroConhecer
//
//  Created by mac on 31/01/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import MapKit

protocol PlaceFinderDelegate: class {
    func addPlace(_ place: Place)
}

class PlaceFinderViewController: UIViewController {

    
    
    enum PlaceFinderMessageType{
        case error(String)
        case confirmation(String)
    }
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var activityIndicatorLoading: UIActivityIndicatorView!
    @IBOutlet weak var vIndicator: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    var place: Place!
    weak var delegate: PlaceFinderDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(_:)))
        gesture.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(gesture)
        
    }
    
    @objc func getLocation(_ gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            load(show: true)
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks,error)in
                self.load(show: false)
                if error == nil{
                    if !self.savePlace(with: placemarks?.first){
                        self.showMessage(type: .error("Náo encontramos local com este nome."))
                    }
                }else{
                    self.showMessage(type: .error("Ops algo deu errado."))
                }
                
            })
            
        }
    }
    
    
    @IBAction func findCity(_ sender: Any) {
        tfCity.resignFirstResponder()
        let address = tfCity.text!
        load(show: true)
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            
            self.load(show: false)
            if error == nil {
                if !self.savePlace(with: placemarks?.first) {
                //ERRO
                   self.showMessage(type: .error("Não encontramos este local!"))
            }else {
                self.showMessage(type: .error("Erro desconhecido"))
            }

        }
        
    }
}
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    func load(show: Bool){
        vIndicator.isHidden = !show
        if show {
            activityIndicatorLoading.startAnimating()
        }else{
            activityIndicatorLoading.stopAnimating()
        }
    }
    
    func savePlace(with placemark: CLPlacemark?) -> Bool {
        guard let placemark = placemark, let coordnate = placemark.location?.coordinate else {
            return false
        }
        let name = placemark.name ?? placemark.country ?? "Desconhecido"
        let address = Place.getFormatedAddress(with: placemark)
        place = Place(name: name, latitude: coordnate.latitude, longitude: coordnate.longitude, address: address)
        
        let region = MKCoordinateRegion(center: coordnate,latitudinalMeters: 3500,longitudinalMeters: 3500)
        mapView.setRegion(region, animated: true)
        
        self.showMessage(type: .confirmation(place.name))
        
        return true
    }
    func showMessage(type: PlaceFinderMessageType){
        let title: String, message: String
        var resConfirmation: Bool = false
        
        switch type {
        case .confirmation(let name):
            title = "Local encontrado"
            message = "Deseja adicionar \(name)?"
            resConfirmation = true
        case .error(let errorMessage):
            title = "Erro"
            message = errorMessage
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        if resConfirmation {
           let confirmAction = UIAlertAction(title: "Adicionar", style: .default, handler: { (action) in
            self.delegate?.addPlace(self.place)
            self.dismiss(animated: true, completion: nil)
        })
            
        alert.addAction(confirmAction)
     }
        present(alert, animated: true, completion: nil )
    }
}
