//
//  locations.swift
//  cse335f18_lab04-archer_patrick
//
//  Created by Patrick Archer on 9/27/18.
//  Copyright © 2018 Patrick Archer - Self. All rights reserved.
//

import Foundation

class locations
{
    var locations:[location] = []
    let tableSectionTitles = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    init()
    {
        let l1 = location(lName: "New York, NY", lDesc: "This is a big city that is home to a very unique culture.", lImage: "newyork.jpeg")
        let l2 = location(lName: "Chicago, IL", lDesc: "Windy and cold city.  Pretty much all the time.", lImage: "newyork.jpeg")
        let l3 = location(lName: "Phoenix, AZ", lDesc: "Literally the definition of hell-like weather.", lImage: "newyork.jpeg")
        let l4 = location(lName: "Los Angeles, CA", lDesc: "Way too overcrowded for anyone's good.", lImage: "newyork.jpeg")
        let l5 = location(lName: "Denver, CO", lDesc: "Very beautiful landscape and enjoyable culture.  Go camping here.", lImage: "newyork.jpeg")
        
        locations.append(l1)
        locations.append(l2)
        locations.append(l3)
        locations.append(l4)
        locations.append(l5)
    }
    
    func editLocation() -> Void
    {
        
    }
}

class location
{
    var locName:String
    var locDescription:String
    var locImageName:String
    
    init(lName:String, lDesc:String, lImage:String)
    {
        locName = lName
        locDescription = lDesc
        locImageName = lImage
    }
}
