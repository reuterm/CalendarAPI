//
//  EventTableViewController.swift
//  Calendar
//
//  Created by Max Reuter on 20/11/15.
//  Copyright © 2015 reuterm. All rights reserved.
//

import UIKit
//import EventKit

class EventTableViewController: UITableViewController {
    // MARK: Properties

    var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use edit button provided by table view controller
        navigationItem.leftBarButtonItem = editButtonItem()
        
        self.navigationController!.toolbarHidden = false;
        
        // Retrieve events
        getEvents()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl!)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "EventTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EventTableViewCell
        
        // Fetch events appropriate event from data source layout
        let event = events[indexPath.row]
        
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        formatter.timeStyle = .ShortStyle
        
        cell.titleLabel.text = event.title
        cell.dateLabel.text = "Starting: \(formatter.stringFromDate(event.start))"
        
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            deleteEvent(events[indexPath.row])
            events.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditEvent" {
            let eventEditViewController = segue.destinationViewController as! EventViewController
            // Get the event cell that generated the segue
            if let selectedEventCell = sender as? EventTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedEventCell)!
                let selectedEvent = events[indexPath.row]
                eventEditViewController.event = selectedEvent
            }
        } else if segue.identifier == "AddEvent" {
            
        }
    }
    
    @IBAction func unwindToEventList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.sourceViewController as? EventViewController, event = sourceViewController.event {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update existing event
                events[selectedIndexPath.row] = event
                tableView.reloadRowsAtIndexPaths([selectedIndexPath], withRowAnimation: .None)
                updateEvent(event)
            } else {
                // Add new event
                let newIndexPath = NSIndexPath(forRow: events.count, inSection: 0)
                events.append(event)
                tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
                addEvent(event)
            }
        }
    }

    // MARK: Actions
//    @IBAction func importEvents(sender: UIBarButtonItem) {
//        
//        let eventStore = EKEventStore()
//        
//        switch EKEventStore.authorizationStatusForEntityType(.Event) {
//        case .Authorized:
//            fetchEvents(eventStore)
//        case .Denied:
//            print("Access denied")
//        case .NotDetermined:
//            
//            eventStore.requestAccessToEntityType(.Event, completion:
//                {[weak self] (granted: Bool, error: NSError?) -> Void in
//                    if granted {
//                        self!.fetchEvents(eventStore)
//                    } else {
//                        print("Access denied")
//                    }
//                })
//        default:
//            print("Case Default")
//        }
//
//    }
    
    
    // MARK: REST Calls
    
    func refresh(sender:AnyObject) {
        getEvents()
        self.refreshControl?.endRefreshing()
    }
    
    func getEvents() {
        
        // Setup the session to make REST GET call.
        let endpoint: String = "http://localhost:8080/api/events/"
        let session = NSURLSession.sharedSession()
        let url = NSURL(string: endpoint)!
        
        session.dataTaskWithURL(url, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // Make sure we get an OK response
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            do {
                if let _ = NSString(data:data!, encoding: NSUTF8StringEncoding) {
                    
                    // Parse JSON from API
                    let jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSArray
//                    print(jsonArray)
                    
                    // Configure date formatter to parse ISO8601 date format
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//                    dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
//                    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
                    
                    var tmp = [Event]()
                    
                    // Parse JSON object
                    for item in jsonArray {
                        let event = item as! NSDictionary
                        let id = event["_id"] as! String
                        let title = event["title"] as! String
                        let description = event["description"] as! String
                        let startString = event["start"] as! String
                        let endString = event["end"] as! String
                        let venue = event["venue"] as! String
                        // Unwrap optionals
                        let start = dateFormatter.dateFromString(startString)!
                        let end = dateFormatter.dateFromString(endString)!
                        tmp.append(Event(id: id, title: title, description: description, start: start, end: end, venue: venue))
                    }
                    
                    self.events = tmp
                    
                    // Reload table
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
            } catch {
                print("Error converting response!")
            }
        }).resume()
    }
    
    
    func addEvent(event: Event) {
        
        // Set up date format
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        // Set up the session to make REST POST call
        let postEndpoint: String = "http://localhost:8080/api/events/"
        let url = NSURL(string: postEndpoint)!
        let session = NSURLSession.sharedSession()
        let postParams : [String: AnyObject] = ["title": event.title, "description": event.description, "start": dateFormatter.stringFromDate(event.start), "end": dateFormatter.stringFromDate(event.end), "venue": event.venue]
        
        // Create the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(postParams, options: NSJSONWritingOptions())
            print("#############POST Params#############")
            print(postParams)
        } catch {
            print("Could not create HTTP request")
        }
        
        // Make the POST call and handle it in a completion handler
        session.dataTaskWithRequest(request, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // Make sure everything is OK
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            do {
                if let postResponse = NSString(data:data!, encoding: NSUTF8StringEncoding) as? String {
                    // Print respone
                    print("#############POST Response#############")
                    print("POST: " + postResponse)
                    
                    // Parse the JSON to get the id
                    let jsonDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSDictionary
                    let id = jsonDictionary["_id"] as! String
                    event.id = id
                }
            } catch {
                print("Could not parse response")
            }
            
        }).resume()
    }
    
    func updateEvent(event: Event) {
        
        // Set up date format
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        
        // Set up the session to make REST PUT call
        let putEndpoint: String = "http://localhost:8080/api/events/\(event.id!)"
        let url = NSURL(string: putEndpoint)!
        let session = NSURLSession.sharedSession()
        let putParams : [String: AnyObject] = ["title": event.title, "description": event.description, "start": dateFormatter.stringFromDate(event.start), "end": dateFormatter.stringFromDate(event.end), "venue": event.venue]
        
        // Create the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(putParams, options: NSJSONWritingOptions())
            print("#############PUT Params#############")
            print(putParams)
        } catch {
            print("Could not create HTTP request")
        }
        
        // Make the POST call and handle it in a completion handler
        session.dataTaskWithRequest(request, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // Make sure everything is OK
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
            
            // Read the JSON
            if let postResponse = NSString(data:data!, encoding: NSUTF8StringEncoding) as? String {
                // Print respone
                print("#############PUT Response#############")
                print("POST: " + postResponse)
            }
            
        }).resume()
    }
    
    func deleteEvent(event: Event) {
        
        // Set up the session to make REST DELETE call
        let deleteEndpoint: String = "http://localhost:8080/api/events/\(event.id!)"
        let url = NSURL(string: deleteEndpoint)!
        let session = NSURLSession.sharedSession()
        
        // Create the request
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        
        // Make the POST call and handle it in a completion handler
        session.dataTaskWithRequest(request, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            // Make sure everything is OK
            guard let realResponse = response as? NSHTTPURLResponse where
                realResponse.statusCode == 200 else {
                    print("Not a 200 response")
                    return
            }
        }).resume()
    }
    
    // MARK: Utility
//    func fetchEvents(store: EKEventStore){
//
//        let endDate = NSDate(timeIntervalSinceNow: 604800*4);   //This is 4 weeks in seconds
//        let predicate = store.predicateForEventsWithStartDate(NSDate(), endDate: endDate, calendars: nil)
//        
//        let fetchedEvents = NSMutableArray(array: store.eventsMatchingPredicate(predicate))
//        
//        for item in fetchedEvents {
//            insertEvent(Event(id: nil, title: item.title!!, description: item.notes!!, start: item.startDate, end: endDate, venue: item.location!!))
//        }
//    }
//    
//    func insertEvent(event: Event) {
//        // Add new event
//        let newIndexPath = NSIndexPath(forRow: events.count, inSection: 0)
//        events.append(event)
//        tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Bottom)
//        addEvent(event)
//    }
}

