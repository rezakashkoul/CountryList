//
//  MainController.swift
//  CountryList
//
//  Created by Reza Kashkoul on 16/Bahman/1400 .
//

import UIKit
import RxSwift
import RxCocoa

class MainController: UIViewController, SearchControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectCountriesButton: UIButton!
    
    @IBAction func selectCountriesButtonAction(_ sender: Any) {
        showModal()
    }
    
    var countryList: [Country] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNoDataInfoIfAbsenceNotExists()
        tableView.reloadData()
        print(countryList)
    }
    
    func setNoDataInfoIfAbsenceNotExists() {
        let noDataLabel : UILabel = UILabel()
        noDataLabel.frame = CGRect(x: 0, y: 0 , width: (self.tableView.bounds.width), height: (self.tableView.bounds.height))
        noDataLabel.text = "No Records Found"
        noDataLabel.textColor = UIColor.black
        noDataLabel.textAlignment = .center
        self.tableView.separatorStyle = .none
        if countryList.isEmpty {
            self.tableView.backgroundView = noDataLabel
        } else if !countryList.isEmpty {
            self.tableView.backgroundView = nil
        }
    }

    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
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
    
    func choosedCountry(countries: [Country]) {
        viewWillAppear(true)
        for country in countries {
            if !countryList.contains(country) {
                countryList += countries
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension MainController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        cell.countryNameLabel.text = countryList[indexPath.row].name.official
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countryList.count
    }
}

