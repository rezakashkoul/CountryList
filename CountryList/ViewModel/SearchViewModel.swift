//
//  SearchViewModel.swift
//  CountryList
//
//  Created by Reza Kashkoul on 16/Bahman/1400 .
//

import RxSwift
import RxCocoa
import RxAlamofire

class SearchViewModel: NSObject {
    
    var tableRowsItem = PublishSubject<[Country]>()
    var bag = DisposeBag()
    
    func APIRequest() {
        var items = [Country]()
        let url = "https://restcountries.com/v3.1/all"
        RxAlamofire.requestData(.get, url)
            .subscribe(onNext: { [weak self] (response, json) in
                guard let self = self else { return }
                do {
                    let countries = try JSONDecoder().decode([Country].self, from: json)
                    items = countries.sorted { $0.self < $1.self }
                    self.tableRowsItem.onNext(items)
                } catch {
                    print("***** error in parse data")
                }
            }, onError: {(error) in
                print("***** error in OnError",error)
            }).disposed(by: bag)
    }
    
    func filteredCountries(with allCountries: [Country], searchedPlace: String) -> [Country] {
        guard !searchedPlace.isEmpty else { return allCountries }
        return allCountries.filter{ $0.name.official.contains(searchedPlace) }
    }
}
