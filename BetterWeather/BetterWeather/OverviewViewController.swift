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
        currentLocation = Location(name: "New York", latitude: 21.324, longitude: 32.24124, days: [
            Day(date: "Monday", averageWeather: Weather(weatherType: .NearlyClearSky, temperatur: 20.3, time:"test"), hours:
                [
                    Weather(weatherType: .Fog, temperatur: 21, time: "test"),
                    Weather(weatherType: .HeavySnowfall, temperatur: 21.9, time: "test")
                ]),
            Day(date: "Tuesday", averageWeather: Weather(weatherType: .Thunder, temperatur: -10, time: "test"), hours:
                [
                    Weather(weatherType: .HeavySleet, temperatur: 2, time: "test"),
                    Weather(weatherType: .Overcast, temperatur: -1.3, time: "test"),
                    Weather(weatherType: .Thunder, temperatur: -9.3, time: "test")
                ])
            ])
        let location1 = Location(name: "Huskvarna", latitude: 21.324, longitude: 32.24124, days: [
            Day(date: "Monday", averageWeather: Weather(weatherType: .ModerateSleetShowers, temperatur: 20.3, time: "test"), hours:
                [
                    Weather(weatherType: .ClearSky, temperatur: 25, time: "test"),
                    Weather(weatherType: .ClearSky, temperatur: 21.9, time: "test")
                ]),
            Day(date: "Tuesday", averageWeather: Weather(weatherType: .Thunder, temperatur: -10, time: "test"), hours:
                [
                    Weather(weatherType: .HeavySleet, temperatur: 2, time: "test"),
                    Weather(weatherType: .Overcast, temperatur: -1.3, time: "test"),
                    Weather(weatherType: .Thunder, temperatur: -9.3, time: "test")
                ])
            ])
        let location2 = Location(name: "Jönköping", latitude: 21.324, longitude: 32.24124, days: [
            Day(date: "Monday", averageWeather: Weather(weatherType: .NearlyClearSky, temperatur: 20.3, time: "test"), hours:
                [
                    Weather(weatherType: .Thunder, temperatur: 5, time: "test"),
                    Weather(weatherType: .HeavySnowfall, temperatur: 21.9, time: "test")
                ]),
            Day(date: "Tuesday", averageWeather: Weather(weatherType: .Thunder, temperatur: -10, time: "test"), hours:
                [
                    Weather(weatherType: .HeavySleet, temperatur: 2, time: "test"),
                    Weather(weatherType: .Overcast, temperatur: -1.3, time: "test"),
                    Weather(weatherType: .Thunder, temperatur: -9.3, time: "test")
                ])
            ])
        let location3 = Location(name: "Asdsg", latitude: 21.324, longitude: 32.24124, days: [
            Day(date: "Monday", averageWeather: Weather(weatherType: .NearlyClearSky, temperatur: 20.3, time: "test"), hours:
                [
                    Weather(weatherType: .CloudySky, temperatur: 10, time: "test"),
                    Weather(weatherType: .HeavySnowfall, temperatur: 21.9, time: "test")
                ]),
            Day(date: "Tuesday", averageWeather: Weather(weatherType: .Thunder, temperatur: -10, time: "test"), hours:
                [
                    Weather(weatherType: .HeavySleet, temperatur: 2, time: "test"),
                    Weather(weatherType: .Overcast, temperatur: -1.3, time: "test"),
                    Weather(weatherType: .Thunder, temperatur: -9.3, time: "test")
                ])
            ])
        locations += [location1, location2, location3]
        
        let positions: Array<Position> = [Position(17.9777,59.3320,"Stockholm"),Position(10.7216,59.9728,"Oslo"),Position(17.0,58.0,"abc")]
        let groupQue = DispatchGroup()
        for position in positions {
            groupQue.enter()
            ApiHandler.location(position.lon, position.lat) { data in
                groupQue.leave()
                self.locations.append(data)
                print(position.name)
            }
        }
        groupQue.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSampleLocations()
        
        
        // DEBUG
        
        
        
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
