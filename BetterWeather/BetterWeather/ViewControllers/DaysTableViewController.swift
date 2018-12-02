//
//  DaysTableViewController.swift
//  BetterWeather
//
//  Created by Simon Arvidsson on 2018-11-20.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import UIKit

class DaysTableViewController: UITableViewController {
    
    var locationIndex: Int!
    var isCurrentLocation: Bool!
    let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.current.identifier)
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        checkAndReloadAllLocations()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadViewData), name: Notification.Name("reloadViewData"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func checkAndReloadAllLocations()
    {
        CentralManager.shared.checkWhetherToUpdateWeather()
        PositionManager.shared.checkWhetherToUpdatePosition()
    }
    
    @objc func reloadViewData()
    {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    
    private func getDays() -> [Day]
    {
        return isCurrentLocation ? CentralManager.shared.currentLocation!.days : CentralManager.shared.favoriteLocations[locationIndex].days
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getDays().count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as? WeatherTableViewCell
        let day = getDays()[indexPath.row]
        
        cell!.title.text = dateFormatter.string(from: day.date)
        cell!.setTemperature(day.averageWeather.temperatur)
        cell!.setImage(day.averageWeather.weatherType)
        

        return cell!
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
        performSegue(withIdentifier: "hoursSegue", sender: indexPath)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? HoursTableViewController {
            if let indexPath = sender as? IndexPath {
                destination.isCurrentLocation = isCurrentLocation
                destination.locationIndex = locationIndex
                destination.dayIndex = indexPath.row
                destination.title = dateFormatter.string(from: getDays()[indexPath.row].date)
            }
        }
    }

}
