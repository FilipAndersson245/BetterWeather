//
//  DaysTableViewController.swift
//  BetterWeather
//
//  Created by Simon Arvidsson on 2018-11-20.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import UIKit

class DaysTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var locationIndex: Int!
    
    var isCurrentLocation: Bool!
    
    let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.current.identifier)
        formatter.dateFormat = "EEEE"
        return formatter
    }()

    // MARK: - View status methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAndReloadAllLocations()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadViewData), name: Notification.Name("reloadViewData"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Data update methods
    
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

    // MARK: - Table view data source methods

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowsCount = 0
        
        let group = DispatchGroup()
        group.enter()
        CentralManager.shared.getDays(isCurrentLocation, locationIndex) {
            days in
            rowsCount = days.count
            group.leave()
        }
        group.wait()
        
        return rowsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath) as? WeatherTableViewCell
        var days: [Day] = []
        
        let group = DispatchGroup()
        group.enter()
        CentralManager.shared.getDays(isCurrentLocation, locationIndex) {
            gottenDays in
            days = gottenDays
            group.leave()
        }
        group.wait()
        let day = days[indexPath.row]
        
        cell!.title.text = dateFormatter.string(from: day.date)
        cell!.setTemperature(day.averageWeather.temperatur)
        cell!.setImage(day.averageWeather.weatherType)
        return cell!
    }

    // MARK: - Navigation methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "hoursSegue", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? HoursTableViewController {
            if let indexPath = sender as? IndexPath {
                destination.isCurrentLocation = isCurrentLocation
                destination.locationIndex = locationIndex
                destination.dayIndex = indexPath.row
                
                var days: [Day] = []
                let group = DispatchGroup()
                group.enter()
                CentralManager.shared.getDays(isCurrentLocation, locationIndex) {
                    gottenDays in
                    days = gottenDays
                    group.leave()
                }
                group.wait()
                let day = days[indexPath.row]
                
                destination.title = String(self.title!) + ", " + dateFormatter.string(from: day.date)
            }
        }
    }

}
