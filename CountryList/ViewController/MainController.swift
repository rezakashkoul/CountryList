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
        view.slideLeftViews(delay: 0.5, comple: nil)
        setNoDataInfoIfAbsenceNotExists()
        tableView.reloadWithAnimation()
        print(countryList)
    }
    
    func setNoDataInfoIfAbsenceNotExists() {
        let noDataLabel : UILabel = UILabel()
        noDataLabel.frame = CGRect(x: 0, y: 0 , width: (self.tableView.bounds.width), height: (self.tableView.bounds.height))
        noDataLabel.text = "No Records Found"
        noDataLabel.textColor = UIColor.systemBlue
        noDataLabel.textAlignment = .center
        DispatchQueue.main.async { [self] in
            if countryList.isEmpty {
                tableView.backgroundView = noDataLabel
            } else {
                tableView.backgroundView = nil
            }
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
            self.tableView.reloadWithAnimation()
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {

        self.countryList.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
          setNoDataInfoIfAbsenceNotExists()
      }
    }
}

