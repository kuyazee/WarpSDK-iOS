//
//  Warp.swift
//  SwipeRX
//
//  Created by Zonily Jame Pesquera on 06/10/2016.
//
//

import Alamofire

public typealias WarpRequest = Alamofire.Request

public typealias WarpDataRequest = Alamofire.DataRequest

open class Warp {
    static var shared: Warp?
    var API_ENDPOINT: String
    fileprivate var APPLICATION_VERSION: String?
    var API_KEY: String
    
    fileprivate init(baseURL: String, apiKey: String) {
        
        // TODO: Improve This
        if baseURL.characters.last != "/" {
            API_ENDPOINT = baseURL + "/"
        } else {
            API_ENDPOINT = baseURL
        }
        
        API_KEY = apiKey
    }
    
    open static func Initialize(_ baseURL: String, apiKey: String) {
        Warp.shared = Warp.init(baseURL: baseURL, apiKey: apiKey)
    }
    
    func HEADER() -> [String: String] {
        return [
            WarpHeaderKeys.APIKey.rawValue      : API_KEY,
            WarpHeaderKeys.ContentType.rawValue : WarpTools.CONTENT_TYPE,
            WarpHeaderKeys.Session.rawValue     : Warp.User.current() == nil ? "" : Warp.User.current()!.sessionToken,
            WarpHeaderKeys.Client.rawValue      : "ios",
            WarpHeaderKeys.WarpVersion.rawValue : "0.0.2",
            WarpHeaderKeys.AppVersion.rawValue  : (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "0.0.0"
        ]
    }
}

// MARK: - Endpoint Generator
extension Warp {
    func generateEndpoint(_ type: EndpointType) -> String {
        var generatedEndpoint = API_ENDPOINT
        
        switch type {
        case .classes(className: let name, id: let id):
            generatedEndpoint += "classes/\(name)"
            if let id = id {
                generatedEndpoint += "/\(String(describing: id))"
            }
            
        case .functions(endpoint: let endpoint):
            generatedEndpoint += "functions/\(endpoint)"
            
        case .login:
            generatedEndpoint += "login"
            
        case .logout:
            generatedEndpoint += "logout"
            
        case .users(id: let id):
            generatedEndpoint += "users"
            if let id = id {
                generatedEndpoint += "/\(String(describing: id))"
            }
            
        }
        
        return generatedEndpoint
    }
    
    enum EndpointType {
        case classes(className: String, id: Int?)
        case functions(endpoint: String)
        case users(id: Int?)
        case login
        case logout
    }
}

public typealias WarpResultBlock = (Bool, WarpError?) -> Void

public protocol WarpObjectProtocol {
//    static func defaultClassType()
    
//    /// This will store the table name of the object /classes/<objectClassName>
//    var objectClassName: String { get }
//    
//    /// this will store the JSON data of the object
//    var dictionary: [String: Any] { get set}
    
    /// creates an object without Data
    static func createWithoutData(id: Int, className: String) -> Warp.Object
    
    /// getter for object keys
    func get(object forKey: String) -> Any?
    
    /// setter for object keys
    func set(object value: Any, forKey: String) -> Self
    
    /// This function is used to update/create the object from the API Server
    func save(_ completion: @escaping WarpResultBlock) -> WarpDataRequest
    
    /// This function is used to remove the object from the API Server
    func destroy(_ completion: @escaping WarpResultBlock) -> WarpDataRequest 
}


public struct APIResult<T> {
    public var hasFailed: Bool = true
    public var message: String = ""
    public var error: Error?
    public var result: T?
    
    public var isSuccess: Bool {
        return !hasFailed
    }
    
    public init(hasFailed: Bool, message: String?, result: T) {
        self.hasFailed = hasFailed
        self.message = message ?? ""
        self.result = result
    }
    
    public init(hasFailed: Bool, message: String?){
        self.hasFailed = hasFailed
        self.message = message ?? ""
    }
    
    public init(hasFailed: Bool, message: String?, error: Error?){
        self.hasFailed = hasFailed
        self.message = message ?? ""
        self.error = error
    }
}

