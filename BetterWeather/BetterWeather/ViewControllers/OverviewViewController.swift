//
//  OverviewViewController.swift
//  BetterWeather
//
//  Created by Simon Arvidsson on 2018-11-06.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import UIKit

class OverviewViewController: UITableViewController {
    
    override func viewDidLoad() {
        tableView.tableFooterView = UIView()

        super.viewDidLoad()
        checkAndReloadAllLocations()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(checkAndReloadAllLocations), name: Notification.Name("applicationWillEnterForeground"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadViewData), name: Notification.Name("reloadViewData"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func refresh(sender:AnyObject)
    {
        self.refreshControl?.beginRefreshing()
        PositionManager.shared.updatePositionAndData()
        CentralManager.shared.updateAllWeathers()
    }
    
    @objc func checkAndReloadAllLocations()
    {
        CentralManager.shared.checkWhetherToUpdateWeather()
        PositionManager.shared.checkWhetherToUpdatePosition()
    }
    
    @objc func reloadViewData()
    {
        DispatchQueue.main.async {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return CentralManager.shared.favoriteLocations.count + (CentralManager.shared.currentLocation != nil ? 1 : 0)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location: Location
        let cell: WeatherTableViewCell?
        if (indexPath.row == 0 && CentralManager.shared.currentLocation != nil) {
            cell = tableView.dequeueReusableCell(withIdentifier: "currentLocationCell", for: indexPath) as? WeatherTableViewCell
            location = CentralManager.shared.currentLocation!
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "favoriteLocationCell", for: indexPath) as? WeatherTableViewCell
            location = CentralManager.shared.favoriteLocations[indexPath.row - (CentralManager.shared.currentLocation != nil ? 1 : 0)]
        }
        
        cell!.title.text = location.name
        cell!.setTemperature(location.days[0].hours[0].temperatur)
        cell!.setImage(location.days[0].hours[0].weatherType)
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 && CentralManager.shared.currentLocation != nil {
            return false
        }
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // TODO: Maybe call method from centralManager instead
            CentralManager.shared.removeFavoriteLocation(location: CentralManager.shared.favoriteLocations[indexPath.row - (CentralManager.shared.currentLocation != nil ? 1 : 0)])
            tableView.deleteRows(at: [indexPath], with: .right)
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

    
    // MARK: - Navigation
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "daysSegue", sender: indexPath)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DaysTableViewController {
            if let indexPath = sender as? IndexPath {
                let hasCurrentLocation = CentralManager.shared.currentLocation != nil
                let locationIndex = indexPath.row - (hasCurrentLocation ? 1 : 0)
                let isCurrentLocation = (indexPath.row == 0 && hasCurrentLocation)
                
                destination.locationIndex = locationIndex
                destination.isCurrentLocation = isCurrentLocation
                destination.title = isCurrentLocation ? CentralManager.shared.currentLocation!.name : CentralManager.shared.favoriteLocations[locationIndex].name
            }
        }
    }
    

}
