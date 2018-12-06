//
//  HoursTableViewController.swift
//  BetterWeather
//
//  Created by Simon Arvidsson on 2018-11-23.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import UIKit

class HoursTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var locationIndex: Int!
    
    var dayIndex: Int!
    
    var isCurrentLocation: Bool!
    
    let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Locale.current.identifier)
        formatter.dateStyle = .none
        formatter.timeStyle = .short
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowsCount = 0
        let group = DispatchGroup()
        group.enter()
        CentralManager.shared.getHours(isCurrentLocation, locationIndex, dayIndex) {
            hours in
            rowsCount = hours.count
            group.leave()
        }
        group.wait()
        return rowsCount
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "hourCell", for: indexPath) as? WeatherTableViewCell
        var hours: [Weather] = []
        
        let group = DispatchGroup()
        group.enter()
        CentralManager.shared.getHours(isCurrentLocation, locationIndex, dayIndex) {
            gottenHours in
            hours = gottenHours
            group.leave()
        }
        group.wait()
        let hour = hours[indexPath.row]
        
        cell!.title.text = dateFormatter.string(from: hour.time)
        cell!.setTemperature(hour.temperatur)
        cell!.setImage(hour.weatherType)
        return cell!
    }
    
}
