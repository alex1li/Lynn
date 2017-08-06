//
//  Queue.swift
//  Lynn
//
//  Created by Alexander Li on 7/21/17.
//  Copyright © 2017 Alexander Li. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Firebase

class Queue {
    
    //MARK: Properties
    
    var name: String
    
    static var queues = [String]()
    static var chosenQueue:String?
    static var linesJoined = [String]()

    
    //MARK: Initialization
    
    init(name: String) {
        // Initialize stored properties.
        self.name = name
    }
}
