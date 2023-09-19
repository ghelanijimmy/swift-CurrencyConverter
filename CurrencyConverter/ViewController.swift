//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Jimmy Ghelani on 2023-09-18.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cadLabel: UILabel!
    @IBOutlet weak var chfLabel: UILabel!
    @IBOutlet weak var gbpLabel: UILabel!
    @IBOutlet weak var jpyLabel: UILabel!
    @IBOutlet weak var tryLabel: UILabel!
    @IBOutlet weak var usdLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

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
        
    }
    
}

#Preview {
    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
    let controller = storyboard.instantiateViewController(withIdentifier: "mainVC") as! ViewController
    return controller
}
