//
//  WarpFunction.swift
//  Practice
//
//  Created by Zonily Jame Pesquera on 28/10/2016.
//
//

import Foundation

open class WarpFunction {
    fileprivate var functionName: String = ""
    fileprivate init () { }
    
    open static func run(_ functionName: String, parameters: [String: Any]?, completion: @escaping (_ result: Any?, _ error: WarpError?) -> Void) {
        guard let warp = Warp.shared else {
            fatalError("WarpServer is not yet initialized")
        }
        
        let _ = Warp.API.post(warp.generateEndpoint(.functions(endpoint: functionName)), parameters: parameters, headers: warp.HEADER()).warpResponse { (warpResult) in
            switch warpResult {
            case .success(let JSON):
                let warpResponse = WarpResponse(json: JSON, result: Any.self)
                switch warpResponse.statusType {
                case .success:
                    completion(warpResponse.result, nil)
                default:
                    completion(nil, WarpError(message: warpResponse.message, status: warpResponse.status))
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
}
