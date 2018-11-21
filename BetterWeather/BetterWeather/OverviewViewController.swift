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
            Day(date: "Monday", averageWeather: Weather(weatherType: .NearlyClearSky, temperatur: 20.3), hours:
                [
                    Weather(weatherType: .Fog, temperatur: 21),
                    Weather(weatherType: .HeavySnowfall, temperatur: 21.9)
                ]),
            Day(date: "Tuesday", averageWeather: Weather(weatherType: .Thunder, temperatur: -10), hours:
                [
                    Weather(weatherType: .HeavySleet, temperatur: 2),
                    Weather(weatherType: .Overcast, temperatur: -1.3),
                    Weather(weatherType: .Thunder, temperatur: -9.3)
                ])
            ])
        let location1 = Location(name: "Huskvarna", latitude: 21.324, longitude: 32.24124, days: [
            Day(date: "Monday", averageWeather: Weather(weatherType: .ModerateSleetShowers, temperatur: 20.3), hours:
                [
                    Weather(weatherType: .ClearSky, temperatur: 25),
                    Weather(weatherType: .ClearSky, temperatur: 21.9)
                ]),
            Day(date: "Tuesday", averageWeather: Weather(weatherType: .Thunder, temperatur: -10), hours:
                [
                    Weather(weatherType: .HeavySleet, temperatur: 2),
                    Weather(weatherType: .Overcast, temperatur: -1.3),
                    Weather(weatherType: .Thunder, temperatur: -9.3)
                ])
            ])
        let location2 = Location(name: "Jönköping", latitude: 21.324, longitude: 32.24124, days: [
            Day(date: "Monday", averageWeather: Weather(weatherType: .NearlyClearSky, temperatur: 20.3), hours:
                [
                    Weather(weatherType: .Thunder, temperatur: 5),
                    Weather(weatherType: .HeavySnowfall, temperatur: 21.9)
                ]),
            Day(date: "Tuesday", averageWeather: Weather(weatherType: .Thunder, temperatur: -10), hours:
                [
                    Weather(weatherType: .HeavySleet, temperatur: 2),
                    Weather(weatherType: .Overcast, temperatur: -1.3),
                    Weather(weatherType: .Thunder, temperatur: -9.3)
                ])
            ])
        let location3 = Location(name: "Asdsg", latitude: 21.324, longitude: 32.24124, days: [
            Day(date: "Monday", averageWeather: Weather(weatherType: .NearlyClearSky, temperatur: 20.3), hours:
                [
                    Weather(weatherType: .CloudySky, temperatur: 10),
                    Weather(weatherType: .HeavySnowfall, temperatur: 21.9)
                ]),
            Day(date: "Tuesday", averageWeather: Weather(weatherType: .Thunder, temperatur: -10), hours:
                [
                    Weather(weatherType: .HeavySleet, temperatur: 2),
                    Weather(weatherType: .Overcast, temperatur: -1.3),
                    Weather(weatherType: .Thunder, temperatur: -9.3)
                ])
            ])
        locations += [location1, location2, location3]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSampleLocations()
        
        
        // DEBUG
        ApiHandler.foo(16, 58);
        
        
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
        cell!.temperatureLabel.text = String(Int(round(location.days[0].hours[0].temperatur)))
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
