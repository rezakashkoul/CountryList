//
//  SearchController.swift
//  CountryList
//
//  Created by Reza Kashkoul on 16/Bahman/1400 .
//

import UIKit
import RxAlamofire
import RxSwift
import RxCocoa

protocol SearchControllerDelegate: AnyObject {
    func choosedCountry(countries: [Country])
}

class SearchController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UISearchBar!
    
    @IBAction func doneButtonAction(_ sender: Any) {
        delegate?.choosedCountry(countries: selectedCountries)
        dismiss(animated: true, completion: nil)
    }
    
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    var rows = PublishSubject<[Country]>()
    weak var delegate: SearchControllerDelegate?
    var selectedCountries = [Country]()
    let object = MainController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bindViewModel()
        viewModel.APIRequest()
    }
        
    func setupUI(){
        navigationItem.title = "Select Countries"
        if #available(iOS 13.0, *) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissModalVC))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("X", comment: "Close"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(dismissModalVC))
        }
        doneButton.layer.cornerRadius = 20
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
    }
    
    func bindViewModel(){
        viewModel.tableRowsItem.bind(to: rows).disposed(by: disposeBag)
        let searchedText = searchField.rx.text
            .orEmpty
            .distinctUntilChanged()
        
        Observable.combineLatest(rows, searchedText) { [unowned self] (allItems, country) -> [Country] in
            return self.filteredCountries(with: allItems, searchedPlace: country)
        }
        .bind(to: tableView.rx.items(cellIdentifier: "TableViewCell", cellType: TableViewCell.self)) {
            (row,item,cell) in
            cell.countryNameLabel.text = item.name.official
        }.disposed(by: disposeBag)
        
        tableView.rx.modelSelected(Country.self).subscribe(onNext: { selectedCountry in
            print("Selected Country is \(selectedCountry.name)")
        }).disposed(by: disposeBag)
        
        tableView.rx.itemSelected.subscribe(onNext:{ indexPath in
            print("Selected index is \(indexPath.row)")
        }).disposed(by: disposeBag)
        
        Observable.combineLatest(
            tableView.rx.modelSelected(Country.self),
            tableView.rx.itemSelected ).subscribe(onNext: { (selectedCountry, indexPath) in
                print("1 selected Country is \(selectedCountry) and indexPath is \(indexPath.row)")
            }).disposed(by: disposeBag)
        
        Observable.zip(
            tableView.rx.modelSelected(Country.self),
            tableView.rx.itemSelected ).subscribe(onNext: { (selectedCountry, indexPath) in
                print("2 selected Country is \(selectedCountry) and indexPath is \(indexPath.row)")
                self.selectedCountries.append(selectedCountry)
            }).disposed(by: disposeBag)
    }
    
    func filteredCountries(with allCountries: [Country], searchedPlace: String) -> [Country] {
        guard !searchedPlace.isEmpty else { return allCountries }
        
        let filteredCountries = allCountries.filter{ $0.name.official.contains(searchedPlace) }
        return filteredCountries
    }
    
    @objc func dismissModalVC() {
        dismiss(animated: true, completion: nil)
    }
    
}

extension SearchController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.resignFirstResponder()
        return true
    }
}
