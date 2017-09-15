//
//  WarpTools.swift
//  Practice
//
//  Created by Zonily Jame Pesquera on 28/10/2016.
//
//

import Alamofire

open class WarpTools {
    open static let CONTENT_TYPE = "application/json"
    open static let dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
    
    open static func showLog(_ value: Any?, key: String, model: String, file: String = #file) {
        print("---> setValue '\(String(describing: value))' for key '\(String(describing: key))' should be handled. MODEL:\(String(describing: model)) & FILE:\(file)")
    }
    
    open static func showLog(_ value: Any?, key: String, _ model: WarpModel, file: String = #file) {
        print("---> setValue '\(String(describing: value))' for key '\(String(describing: key))' should be handled. MODEL:\(String(describing: type(of: model).className())) & FILE:\(file)")
    }
    
    open static func toResult(_ response: DataResponse<Any>) -> WarpResult {
        guard response.result.isSuccess else {
            return .failure(WarpError(error: response.result.error! as NSError))
        }
        guard let jsonData = response.result.value else{
            return .failure(WarpError(code: .responseValueIsNil))
        }
        return .success(WarpJSON(jsonData))
    }
    
    open static func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = self.dateFormat
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter
    }
}

public enum WarpHeaderKeys: String {
    case APIKey = "X-Warp-API-Key"
    case ContentType = "Content-Type"
    case Client = "X-Warp-Client"
    case AppVersion = "X-App-Version"
    case WarpVersion = "X-Warp-Version"
    case Session = "X-Warp-Session-Token"
}

public enum WarpResult {
    case success(WarpJSON)
    case failure(WarpError)
    
    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
    
    public func showResult(_ file: String = #file, _ function: String = #function) {
        switch self {
        case .success(let JSON): print(file + " " + function + "Success Result: \(JSON)")
        case .failure(let ERROR): print(file + " " + function + "Error Result: \(ERROR)")
        }
    }
    
    public func getResult() -> Any {
        switch self {
        case .success(let JSON): return JSON
        case .failure(let ERROR): return ERROR
        }
    }
    
    public var isFailure: Bool {
        return !isSuccess
    }
}

