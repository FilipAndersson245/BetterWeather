//
//  NotificationsHandler.swift
//  BetterWeather
//
//  Created by Jonatan Flyckt on 2018-12-03.
//  Copyright © 2018 Jonatan Flyckt, Filip Andersson, Simon Arvidson, Marcus Gullstrand. All rights reserved.
//

import Foundation

import UserNotifications

class NotificationsHandler{
    
    init(){
        
        let content = UNMutableNotificationContent()
        content.title = "Good Morning!"
        content.body = "Check out today's weather"
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.timeZone = TimeZone(secondsFromGMT: 60*60*24)
        dateComponents.hour = 7
        //dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request){
            error in
            if error != nil {
                print("Error adding notification: \(String(describing: error))")
            }
        }
    }
    
}
