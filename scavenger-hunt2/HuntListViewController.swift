//
//  HuntListViewController.swift
//  scavenger-hunt2
//
//  Created by Allen Odoom on 3/3/24.
//

import UIKit

class HuntListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var hunts = [Hunt]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = UIView()
        tableView.dataSource = self
        
        // Load your mocked tasks
        hunts = Hunt.mockedTasks
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue" {
            if let detailViewController = segue.destination as? HuntDetailViewController,
               let selectedIndexPath = tableView.indexPathForSelectedRow {
                let hunt = hunts[selectedIndexPath.row]
                detailViewController.hunt = hunt
            }
        }
    }
}

extension HuntListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hunts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HuntCell", for: indexPath) as? HuntCell else {
            fatalError("Unable to dequeue HuntCell")
        }
        
        let hunt = hunts[indexPath.row]
        cell.configure(with: hunt)
        
        return cell
    }
}
