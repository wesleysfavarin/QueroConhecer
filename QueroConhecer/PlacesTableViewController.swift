//
//  PlacesTableViewController.swift
//  QueroConhecer
//
//  Created by mac on 31/01/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

class PlacesTableViewController: UITableViewController {

    var places: [Place] = []
    let ud = UserDefaults.standard
    var lbNoPlaces : UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadPlaces()
        lbNoPlaces = UILabel()
        lbNoPlaces.text = "Cadastre os locais que deseja conhecer\n clicando no botão + acima"
        lbNoPlaces.textAlignment = .center
        lbNoPlaces.numberOfLines = 0
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier! !=  "mapSegue"{
            let viewController = segue.destination as! PlaceFinderViewController
            viewController.delegate = self
        }else {
            
            let viewController = segue.destination as! MapViewController
            switch sender{
            case let place as Place:
            viewController.places = [place]
            default:
                viewController.places = places
            }
            
            
            
            
            
        }
    }
    
    func loadPlaces(){
        if let placesData = ud.data(forKey: "places") {
            do{
             
               places = try JSONDecoder().decode([Place].self, from: placesData)
                tableView.reloadData()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func savePlaces(){
      let json = try? JSONEncoder().encode(places)
        ud.set(json, forKey: "places")
    }
    
    @objc func showAll(){
        performSegue(withIdentifier: "mapSegue", sender: nil)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if places.count > 0 {
            let btShowAll = UIBarButtonItem(title: "Mostrar todos no mapa", style: .plain, target: self, action: #selector(showAll))
            navigationItem.leftBarButtonItem = btShowAll
            tableView.backgroundView = nil
        } else {
            navigationItem.leftBarButtonItem = nil
            tableView.backgroundView = lbNoPlaces
        }
        
        return places.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let place = places[indexPath.row]
        cell.textLabel?.text = place.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let place = places[indexPath.row]
        performSegue(withIdentifier: "mapSegue", sender: place)
        
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            savePlaces()
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension PlacesTableViewController : PlaceFinderDelegate{
    func addPlace(_ place: Place) {
        if !places.contains(place){
            //add :)
            places.append(place)
            savePlaces()
            tableView.reloadData()
        }
    }
}
