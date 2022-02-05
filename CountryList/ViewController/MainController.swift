//
//  MainController.swift
//  CountryList
//
//  Created by Reza Kashkoul on 16/Bahman/1400 .
//

import UIKit
import Alamofire
import RxSwift
import RxCocoa

class MainController: UIViewController, SearchControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectCountriesButton: UIButton!
    
    @IBAction func selectCountriesButtonAction(_ sender: Any) {
        //        networkRequest()
        showModal()
    }
    
    var countryList: [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        //        networkRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        print(countryList)
    }
    
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        //        tableView.backgroundView =
        title = "Selected Countries"
        navigationController?.navigationBar.prefersLargeTitles = true
        selectCountriesButton.layer.cornerRadius = 20
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
    
    func showModal() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SearchController") as! SearchController
        let navController = UINavigationController(rootViewController: vc)
        self.navigationController?.present(navController, animated: true)
        vc.delegate = self
    }
    
    func choosedCountry(country: [Country]) {
        countryList += country
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension MainController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! TableViewCell
        cell.countryNameLabel.text = countryList[indexPath.row].name.official
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryList.count
    }
}

