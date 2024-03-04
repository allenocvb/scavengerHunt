//
//  Hunt.swift
//  scavenger-hunt2
//
//  Created by Allen Odoom on 3/3/24.
//

import Foundation
import UIKit
import CoreLocation

class Hunt {
    let title: String
    let description: String
    var image: UIImage?
    var imageLocation: CLLocation?
    var isComplete: Bool {
        image != nil
    }

    init(title: String, description: String) {
        self.title = title
        self.description = description
    }

    func set(_ image: UIImage, with location: CLLocation) {
        self.image = image
        self.imageLocation = location
    }
}

extension Hunt {
    static var mockedTasks: [Hunt] {
        return [
            Hunt(title: "Find the Oldest Tree in the Park",
                 description: "Search the park for the oldest tree you can find and take a picture with it."),
            Hunt(title: "Locate a Hidden Mural",
                 description: "Find one of the city's hidden murals. Hint: It's in an alley off Main Street."),
            Hunt(title: "Capture a Photo of a Street Performer",
                 description: "Street performers are all around. Find one and capture their talent in action."),
            Hunt(title: "Discover a Historic Landmark",
                 description: "Our city is full of history. Find a historic landmark and learn something new about it."),
            Hunt(title: "Snap a Sunset from the Bridge",
                 description: "End your day with a beautiful sunset. Best view is from the north side of the bridge.")
        ]
    }
}
