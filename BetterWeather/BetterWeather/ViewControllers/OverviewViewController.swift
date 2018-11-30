//
//  OverviewViewController.swift
//  BetterWeather
//
//  Created by Simon Arvidsson on 2018-11-06.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import UIKit

class OverviewViewController: UITableViewController {

    var locations = [Location]()
    var currentLocation: Location? = nil
    
    private func loadSampleLocations() {
        let location1 = Location(name: "Huskvarna", latitude: 21.324, longitude: 32.24124, days: [
            Day(date: Date(), averageWeather: Weather(weatherType: .ModerateSleetShowers, temperatur: 20.3, time: Date()), hours:
                [
                    Weather(weatherType: .ClearSky, temperatur: 25, time: Date()),
                    Weather(weatherType: .ClearSky, temperatur: 21.9, time: Date())
                ]),
            Day(date: Date(), averageWeather: Weather(weatherType: .Thunder, temperatur: -10, time: Date()), hours:
                [
                    Weather(weatherType: .HeavySleet, temperatur: 2, time: Date()),
                    Weather(weatherType: .Overcast, temperatur: -1.3, time: Date()),
                    Weather(weatherType: .Thunder, temperatur: -9.3, time: Date())
                ])
            ])
        let location2 = Location(name: "Jönköping", latitude: 21.324, longitude: 32.24124, days: [
            Day(date: Date(), averageWeather: Weather(weatherType: .NearlyClearSky, temperatur: 20.3, time: Date()), hours:
                [
                    Weather(weatherType: .Thunder, temperatur: 5, time: Date()),
                    Weather(weatherType: .HeavySnowfall, temperatur: 21.9, time: Date())
                ]),
            Day(date: Date(), averageWeather: Weather(weatherType: .Thunder, temperatur: -10, time: Date()), hours:
                [
                    Weather(weatherType: .HeavySleet, temperatur: 2, time: Date()),
                    Weather(weatherType: .Overcast, temperatur: -1.3, time: Date()),
                    Weather(weatherType: .Thunder, temperatur: -9.3, time: Date())
                ])
            ])
        let location3 = Location(name: "Asdsg", latitude: 21.324, longitude: 32.24124, days: [
            Day(date: Date(), averageWeather: Weather(weatherType: .NearlyClearSky, temperatur: 20.3, time: Date()), hours:
                [
                    Weather(weatherType: .CloudySky, temperatur: 10, time: Date()),
                    Weather(weatherType: .HeavySnowfall, temperatur: 21.9, time: Date())
                ]),
            Day(date: Date(), averageWeather: Weather(weatherType: .Thunder, temperatur: -10, time: Date()), hours:
                [
                    Weather(weatherType: .HeavySleet, temperatur: 2, time: Date()),
                    Weather(weatherType: .Overcast, temperatur: -1.3, time: Date()),
                    Weather(weatherType: .Thunder, temperatur: -9.3, time: Date())
                ])
            ])
        locations += [location1, location2, location3]
        
//        ApiHandler.getLocationData(16, 58) { data in
//            self.locations.append(data)
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//            print("1")
//        };
//        print("2")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        loadSampleLocations()
        loadCurrentLocation()
        
        
        // DEBUG
        
        CentralManager.shared.addFavoriteLocation(name: "test", longitude: 14.158, latitude: 57.781){
            self.locations = CentralManager.shared.favoriteLocations
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        
        let positions: Array<DbFavorite> = [DbFavorite(name: "Stockholm", longitude: 17.9777, latitude: 59.3320),
                                            DbFavorite(name: "Oslo", longitude: 10.7216, latitude: 59.9728),
                                            DbFavorite(name: "Jönköping", longitude: 10.7216, latitude: 59.9728),
                                            DbFavorite(name: "Malmö", longitude: 12.9353,latitude: 55.5712)]
        let groupQue = DispatchGroup()
        for position in positions {
            groupQue.enter()
             CentralManager.shared.addFavoriteLocation(name: position.name, longitude: position.longitude,latitude: position.latitude){
                groupQue.leave()
            }
        }
        groupQue.notify(queue: .main) {
            self.locations = CentralManager.shared.favoriteLocations
            self.tableView.reloadData()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCurrentLocation()
        NotificationCenter.default.addObserver(self, selector: #selector(loadCurrentLocation), name: Notification.Name("applicationWillEnterForeground"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func loadCurrentLocation()
    {
        PositionManager.shared.refreshPosition()
        
        // TODO: replace with real fetched data
        if (PositionManager.shared.hasPosition()) {
            currentLocation = Location(name: "New York", latitude: 21.324, longitude: 32.24124, days: [
                Day(date: Date(), averageWeather: Weather(weatherType: .NearlyClearSky, temperatur: 20.3, time:Date()), hours:
                    [
                        Weather(weatherType: .Fog, temperatur: 21, time: Date()),
                        Weather(weatherType: .HeavySnowfall, temperatur: 21.9, time: Date())
                    ]),
                Day(date: Date(), averageWeather: Weather(weatherType: .Thunder, temperatur: -10, time: Date()), hours:
                    [
                        Weather(weatherType: .HeavySleet, temperatur: 2, time: Date()),
                        Weather(weatherType: .Overcast, temperatur: -1.3, time: Date()),
                        Weather(weatherType: .Thunder, temperatur: -9.3, time: Date())
                    ])
                ])
        }
        else
        {
            currentLocation = nil
        }
        
        // Perform reload of all data
        DispatchQueue.main.async {
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
        return locations.count + (currentLocation != nil ? 1 : 0)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let location: Location
        let cell: WeatherTableViewCell?
        if (indexPath.row == 0 && currentLocation != nil) {
            cell = tableView.dequeueReusableCell(withIdentifier: "currentLocationCell", for: indexPath) as? WeatherTableViewCell
            location = currentLocation!
        }
        else {
            cell = tableView.dequeueReusableCell(withIdentifier: "favoriteLocationCell", for: indexPath) as? WeatherTableViewCell
            location = locations[indexPath.row - (currentLocation != nil ? 1 : 0)]
        }
        
        cell!.title.text = location.name
        cell!.setTemperature(location.days[0].hours[0].temperatur)
        cell!.setImage(location.days[0].hours[0].weatherType)
        
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
        performSegue(withIdentifier: "daysSegue", sender: indexPath)
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DaysTableViewController {
            if let indexPath = sender as? IndexPath {
                let location = (indexPath.row == 0 && currentLocation != nil) ? currentLocation! : locations[indexPath.row - (currentLocation != nil ? 1 : 0)]
                destination.days = location.days
                destination.title = location.name
            }
        }
    }
    

}
