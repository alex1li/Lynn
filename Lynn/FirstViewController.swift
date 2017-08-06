//
//  FirstViewController.swift
//  Lynn
//
//  Created by Alexander Li on 7/22/17.
//  Copyright © 2017 Alexander Li. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase


class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UISearchResultsUpdating {
    
    var queueList = [String]()
    var ref: DatabaseReference?
    var handle: DatabaseHandle?
    var handle2: DatabaseHandle?
    
    var chosenQueue: String?
    
    //Rohan's
    var count = 0;
    let searchController = UISearchController(searchResultsController: nil)
    var filteredQueues = [String]()
    
    var test = ["one", "two", "three"]
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate=self
        tableView.dataSource=self
        tableView.frame = view.frame
        ref = Database.database().reference()
        
        handle = ref?.child("Queues").observe(.childAdded, with: { (snapshot) in
            //This initally goes throough all existing data
            let actualQueue = snapshot.key
               self.queueList.append(actualQueue)
                self.filteredQueues.append(actualQueue)
                self.tableView.reloadData()
            
            
        })
        handle2 = ref?.child("Queues").observe(.childRemoved, with: { (snapshot) in
            //***Adding keys to myList instead of the values now to allow for easy deleting of top person
            if (snapshot.key as String?) != nil {
                self.queueList = self.queueList.filter { $0 != snapshot.key }
                self.filteredQueues = self.filteredQueues.filter { $0 != snapshot.key }
                self.tableView.reloadData()
            }
        })
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
    }

    // UITableViewDataSource protocol methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredQueues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "QueueCell", for: indexPath)
        // Unpack message from Firebase DataSnapshot
        cell.textLabel?.text = filteredQueues[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chosenOne = filteredQueues[indexPath.row]
        chosenQueue = chosenOne
        Queue.chosenQueue = chosenOne
        self.performSegue(withIdentifier: "showThisQueue", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if(searchController.searchBar.text! == "") {
            filteredQueues = queueList;
        }
        else
        {
            filteredQueues = queueList.filter(isMatch)
        }
        self.tableView.reloadData()
    }
    
    
    func isMatch(s: String) -> Bool{
        
        if(s.contains(searchController.searchBar.text!)) {
            return true
        }
        else {
            return false
            
        }
        
        
    }
    
}



