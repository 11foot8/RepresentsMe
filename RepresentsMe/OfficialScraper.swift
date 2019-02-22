//
//  OfficialScraper.swift
//  RepresentsMe
//
//  Created by Michael Tirtowidjojo on 2/21/19.
//  Copyright © 2019 11foot8. All rights reserved.
//

import Foundation

class OfficialScraper {
    
    private static let url:String = "https://www.googleapis.com/civicinfo/v2/" +
                                    "representatives"
    
    private init() {}
    
    public static func getForAddress(address:String, apikey:String) {
        OfficialScraper.makeRequest(address: address, apikey: apikey)
    }
    
    private static func makeRequest(address:String, apikey:String) {
        guard let formattedAddress = OfficialScraper.formatArg(arg: address) else {
            // TODO: throw some error
            print("invalid address")
            return
        }
        
        let urlWithArgs = "\(OfficialScraper.url)?" +
                          "address=\(formattedAddress)&key=\(apikey)"
        let url = URL(string: urlWithArgs)
        let request:URLRequest = URLRequest(url: url!)
        
        // TODO: remove, For commandline
        let runLoop = CFRunLoopGetCurrent()

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
            }

            guard let data = data else {
                return
            }

            do {
                let json = try JSONDecoder().decode(JSONData.self, from: data)
                for d in json.divisions {
                    print(d)
                }
                for o in json.offices {
                    print(o)
                }
                for o in json.officials {
                    print(o)
                }
            } catch {
                print(error)
            }
            
            // TODO: remove, for commandline
            CFRunLoopStop(runLoop)
        }.resume()
        
        // TODO: remove, for commandline
        CFRunLoopRun()
    }
    
    private static func formatArg(arg:String) -> String? {
        return arg.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
}
