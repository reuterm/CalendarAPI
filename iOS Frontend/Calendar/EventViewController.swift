//
//  EventViewController.swift
//  Calendar
//
//  Created by Max Reuter on 20/11/15.
//  Copyright © 2015 reuterm. All rights reserved.
//

import UIKit
import EventKit

class EventViewController: UIViewController, UITextFieldDelegate {
    // MARK: Properties:
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descTextField: UITextField!
    @IBOutlet weak var startTextField: UITextField!
    @IBOutlet weak var endTextField: UITextField!
    @IBOutlet weak var venueTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var syncButton: UIButton!
    var event: Event?
    var addMode = false
    let formatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set delegates
        titleTextField.delegate = self
        descTextField.delegate = self
        startTextField.delegate = self
        endTextField.delegate = self
        venueTextField.delegate = self
        
        // Configure date formatter
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .ShortStyle
        
        // Set up view if existing event is edited
        if let event = event {
            navigationItem.title = event.title
            titleTextField.text = event.title
            descTextField.text = event.description
            startTextField.text = formatter.stringFromDate(event.start)
            endTextField.text = formatter.stringFromDate(event.end)
            venueTextField.text = event.venue
            addMode = false
            
        } else {
            
            addMode = true
            
            // Set today's date to start and end
            let today = NSDate()
            
            startTextField.text = formatter.stringFromDate(today)
            endTextField.text = formatter.stringFromDate(today)
            
            // Only saved events can be synched to phone calendar
            syncButton.hidden = true
        }
        
        // Add "Done" but to date picker
        addDoneButtonOnDatePicker()

        // Enable safe button only if everything has been filled out
        checkValidInputs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Adjust cancel animatation according to how view controller was presented
        let isPresentingInAddEventMode = presentingViewController is UINavigationController
        if isPresentingInAddEventMode {
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if saveButton === sender {
            // Parse date to ISO8601 date format
            let startDate = formatter.dateFromString(startTextField.text!)
            let endDate = formatter.dateFromString(endTextField.text!)
//            let dateFormatter = NSDateFormatter()
//            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
//            let start = dateFormatter.stringFromDate(start!)
//            let end = dateFormatter.stringFromDate(end!)
            
            // Determine if new event is added or existing event is
//            let addEventMode = presentingViewController is UINavigationController
            if addMode {
                event = Event(id: nil, title: titleTextField.text!, description: descTextField.text!, start: startDate!, end: endDate!, venue: venueTextField.text!)
            } else {
                event = Event(id: event!.id, title: titleTextField.text!, description: descTextField.text!, start: startDate!, end: endDate!, venue: venueTextField.text!)
            }
        }
    }
    
    
    
    // MARK: Actions
    @IBAction func startFieldEditing(sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("startValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }

    @IBAction func endFieldEditing(sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("endValueChanged:"), forControlEvents: UIControlEvents.ValueChanged)
    }
    @IBAction func syncEvent(sender: UIButton) {
        let eventStore = EKEventStore()
        
        switch EKEventStore.authorizationStatusForEntityType(.Event) {
        case .Authorized:
            insertEventToPhoneCalendar(eventStore, event: self.event!)
        case .Denied:
            print("Access denied")
        case .NotDetermined:
            
            eventStore.requestAccessToEntityType(.Event, completion:
                {[weak self] (granted: Bool, error: NSError?) -> Void in
                    if granted {
                        self!.insertEventToPhoneCalendar(eventStore, event: self!.event!)
                    } else {
                        print("Access denied")
                    }
                })
        default:
            print("Case Default")
        }
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable save button while editing
        saveButton.enabled = false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        checkValidInputs()
        if textField === titleTextField {
            navigationItem.title = titleTextField.text
        }
    }
    
    func checkValidInputs() {
        // Disable save button if any field is still empty
        let title = titleTextField.text ?? ""
        let description = descTextField.text ?? ""
        let start = startTextField.text ?? ""
        let end = endTextField.text ?? ""
        let venue = venueTextField.text ?? ""
        saveButton.enabled = !title.isEmpty && !description.isEmpty && !start.isEmpty && !end.isEmpty && !venue.isEmpty
    }
    
    

    // MARK: Utilities
    
    func startValueChanged(sender:UIDatePicker) {
        startTextField.text = formatter.stringFromDate(sender.date)
    }
    
    func endValueChanged(sender:UIDatePicker) {
        endTextField.text = formatter.stringFromDate(sender.date)
    }
    
    func addDoneButtonOnDatePicker()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRectMake(0, 0, 320, 50))
        doneToolbar.barStyle = UIBarStyle.Default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("doneButtonAction"))
        
        doneToolbar.items = [flexSpace, done]
        doneToolbar.sizeToFit()
        
        self.startTextField.inputAccessoryView = doneToolbar
        self.endTextField.inputAccessoryView = doneToolbar
        
    }
    
    func doneButtonAction()
    {
        self.startTextField.resignFirstResponder()
        self.endTextField.resignFirstResponder()
    }
    
    func insertEventToPhoneCalendar(store: EKEventStore, event: Event) {
                
        // Create Event
        let calEvent = EKEvent(eventStore: store)
        
        calEvent.title = event.title
        calEvent.startDate = event.start
        calEvent.endDate = event.end
        calEvent.notes = event.description
        calEvent.location = event.venue
        calEvent.calendar = store.defaultCalendarForNewEvents
        // Save Event in Calendar
        do {
            try store.saveEvent(calEvent, span: EKSpan.ThisEvent)
            // Dismiss view
            navigationController!.popViewControllerAnimated(true)
        } catch let error as NSError {
            print("Error occurred: \(error)")
        } catch {
            fatalError()
        }
    }


}
