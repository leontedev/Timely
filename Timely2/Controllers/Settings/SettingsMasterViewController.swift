//
//  SettingsMasterViewController.swift
//  Timely2
//
//  Created by Mihai Leonte on 3/7/19.
//  Copyright © 2019 Mihai Leonte. All rights reserved.
//

import UIKit
import MessageUI

class SettingsMasterViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var feedbackCell: UITableViewCell!
    @IBOutlet weak var rateCell: UITableViewCell!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let index = self.tableView.indexPathForSelectedRow{
            self.tableView.deselectRow(at: index, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell === feedbackCell {
            sendEmail()
        } else if cell === rateCell {
            rateApp(appId: "id959379869") { success in
                print("RateApp \(success)")
            }
        }
    }
        
        
    //MARK: - Helper Functions
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["mihai.leonte@icloud.com"])
            mail.setSubject("Timely App Feedback")
            mail.setMessageBody("<p>Hi Mihai, </p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }

}
