//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Jimmy Ghelani on 2023-09-18.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var cadLabel: UILabel!
    @IBOutlet weak var chfLabel: UILabel!
    @IBOutlet weak var gbpLabel: UILabel!
    @IBOutlet weak var jpyLabel: UILabel!
    @IBOutlet weak var tryLabel: UILabel!
    @IBOutlet weak var usdLabel: UILabel!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var convertedValue: UILabel!
    
    var fromCurrency = Rates.CAD.rawValue
    var toCurrency = Rates.CAD.rawValue
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        currencyPicker.delegate = self
        currencyPicker.dataSource = self
    }
    
    //MARK: - PICKER DELEGATE METHODS
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Rates.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(Rates.allCases[row].rawValue)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            fromCurrency = Rates.allCases[row].rawValue
        } else {
            toCurrency = Rates.allCases[row].rawValue
        }
        
        getConversion()
    }
    
    func getConversion() {
        if !fromCurrency.isEmpty && !toCurrency.isEmpty {
            let url = URL(string: "\(Constants.API_URL.rawValue)/convert")
            var components = URLComponents(url: url!, resolvingAgainstBaseURL: true)
            components?.queryItems = [
                URLQueryItem(name: "from", value: fromCurrency),
                URLQueryItem(name: "to", value: toCurrency),
                URLQueryItem(name: "access_key", value: Constants.API_KEY.rawValue)
            ]
            
            let session = URLSession.shared
            
            let task = session.dataTask(with: components!.url!) { data, response, error in
                if error != nil {
                    let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let okButton = UIAlertAction(title: "OK", style: .default)
                    alert.addAction(okButton)
                    self.present(alert, animated: true)
                } else {
                    if data != nil {
                        let decoder = JSONDecoder()
                        do {
                            let result = try decoder.decode(Conversion.self, from: data!)
                            DispatchQueue.main.async {
                                self.convertedValue.text = String(result.result)
                            }
                        } catch {
                            print("Couldn't get data: \(error)")
                        }
                    }
                }
            }
            task.resume()
        }
    }

    //MARK: - GET RATES
    @IBAction func getRates(_ sender: UIButton) {
        //MARK: - REQUEST & SESSION
        let url = URL(string: "\(Constants.API_URL.rawValue)/latest?access_key=\(Constants.API_KEY.rawValue)")
        
        let session = URLSession.shared
        
        //MARK: - RESPONSE & DATA
        let task = session.dataTask(with: url!) { data, response, error in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let okButton = UIAlertAction(title: "OK", style: .default)
                alert.addAction(okButton)
                self.present(alert, animated: true)
            } else {
                if data != nil {
                    let decoder = JSONDecoder()
                    do {
                        let results = try decoder.decode(Currency.self, from: data!)
                        let rates = results.rates
                        
                        for (rate, amount) in rates {
                            DispatchQueue.main.async {
                                switch rate {
                                case .CAD:
                                    self.cadLabel.text = "CAD: \(amount)"
                                case .CHF:
                                    self.chfLabel.text = "CHF: \(amount)"
                                case .GBP:
                                    self.gbpLabel.text = "GBP: \(amount)"
                                case .JPY:
                                    self.jpyLabel.text = "JPG: \(amount)"
                                case .TRY:
                                    self.tryLabel.text = "TRY: \(amount)"
                                case .USD:
                                    self.usdLabel.text = "USD: \(amount)"
                                }
                            }
                        }
                    } catch {
                        print("Error Decoding: \(error)")
                    }
                }
            }
        }
        
        task.resume()
        
        getConversion()
        
    }
    
}

#Preview {
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    let controller = storyboard.instantiateViewController(withIdentifier: "mainVC") as! ViewController
    return controller
}
