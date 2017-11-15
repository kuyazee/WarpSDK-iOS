//
//  Warp.swift
//  SwipeRX
//
//  Created by Zonily Jame Pesquera on 06/10/2016.
//
//

import Alamofire
import UIKit

public typealias WarpRequest = Alamofire.Request

public typealias WarpDataRequest = Alamofire.DataRequest

open class Warp {
    
    /// Shared Instance
    static var shared: Warp?
    
    /// Different instances for the Warp SDK
    static var instances: [String: Warp] = [:]
    
    /// App Version
    fileprivate var APPLICATION_VERSION: String?
    
    /// The endpoint of the Warp Server API
    var API_ENDPOINT: String
    
    /// The Api Key for the Warp Server
    var API_KEY: String
    
    /// This will be the name of the instance
    var instanceIdentifier: String
    
    fileprivate init(instanceIdentifier: String, baseURL: String, apiKey: String) {
        
        // TODO: Improve This
        if baseURL.characters.last != "/" {
            self.API_ENDPOINT = baseURL + "/"
        } else {
            self.API_ENDPOINT = baseURL
        }
        
        self.instanceIdentifier = instanceIdentifier
        self.API_KEY = apiKey
        
        Warp.instances[instanceIdentifier] = self
    }
    
    /// Use this to create the default instance of Warp SDK
    ///
    /// - Parameters:
    ///   - baseURL: api endpoint
    ///   - apiKey: api key
    open static func Initialize(_ baseURL: String, apiKey: String) {
        Warp.shared = Warp(instanceIdentifier: "default", baseURL: baseURL, apiKey: apiKey)
    }
    
    /// Use this to create a different instance of Warp SDK
    ///
    /// - Parameters:
    ///   - identifier: identifier for the warp SDK
    ///   - baseURL: api endpoint
    ///   - apiKey: api key
    /// - Returns: Warp SDK Instance
    open static func Initialize(withIdentifier identifier: String, baseURL: String, apiKey: String) -> Warp {
        return Warp(instanceIdentifier: identifier, baseURL: baseURL, apiKey: apiKey)
    }
    
    /// Getter function for instances
    ///
    /// - Parameter identifier: the name of the instance
    /// - Returns: Warp SDK Instance if it exists.
    open static func instance(forIdentifier identifier: String) -> Warp? {
        return Warp.instances[identifier]
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
        var generatedEndpoint = self.API_ENDPOINT
        
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
    
    /// Creates an object without Data
    ///
    /// - Parameters:
    ///   - id: identifier for the object
    ///   - className: the class's table name
    /// - Returns: a new Warp.Object instance
    static func createWithoutData(id: Int, className: String) -> Warp.Object
    
    /// Getter for object keys
    ///
    /// - Parameter forKey: dictionary key
    /// - Returns: value for the key
    func get(object forKey: String) -> Any?
    
    /// Setter for object keys
    ///
    /// - Parameters:
    ///   - value: value to be set for the dictionary
    ///   - forKey: dictionary key
    /// - Returns: the instance of this object
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
        return !self.hasFailed
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

