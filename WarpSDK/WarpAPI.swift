//
//  Warp.API.swift
//  SwipeRX
//
//  Created by Zonily Jame Pesquera on 06/10/2016.
//
//

import Alamofire
import PromiseKit

public extension Warp {
    public class API {
        let shared: Warp.API = Warp.API()
    }
}

public extension Warp.API {
    public static func get(_ URLString: URLConvertible, parameters: [String : Any]?, headers: [String : String]) -> WarpDataRequest {
        return Alamofire.request(URLString, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: headers)
    }
    
    public static func post(_ URLString: URLConvertible, parameters: [String : Any]?, headers: [String : String]) -> WarpDataRequest {
        return Alamofire.request(URLString, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
    }
    
    public static func put(_ URLString: URLConvertible, parameters: [String : Any]?, headers: [String : String]) -> WarpDataRequest {
        return Alamofire.request(URLString, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
    }
    
    public static func delete(_ URLString: URLConvertible, parameters: [String : Any]?, headers: [String : String]) -> WarpDataRequest {
        return Alamofire.request(URLString, method: .delete, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
    }
}

public extension WarpDataRequest {
    func warpResponse(_ block: @escaping (_ warpResult: WarpResult) -> Void) -> WarpDataRequest {
        return responseJSON(completionHandler: { block(WarpTools.toResult($0)) })
    }
}
