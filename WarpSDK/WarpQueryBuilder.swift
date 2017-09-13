//
//  WarpQueryBuilder.swift
//  SwipeRX
//
//  Created by Zonily Jame Pesquera on 27/10/2016.
//
//

open class WarpQueryBuilder {
    open var param: [String: Any] = [:]
    
    public init() {}
    
    public init(_ param: [String: Any]) {
        self.param = param
    }
    
    open func include(_ values: [String]) -> WarpQueryBuilder {
        self.param["include"] = String(describing: values) 
        return self
    }
    
    open func query(_ values: [WarpQueryConstraint]) -> WarpQueryBuilder {
        var string: String = ""
        values.enumerated().forEach { (i, value) in
            switch value.constraint {
            case .EqualTo, .NotEqualTo, .ContainsString:
                if value.value is String {
                    string = string + "\"\(value.key)\":{\"\(value.constraint.rawValue)\":\"\(value.value as! String)\"}"
                } else {
                    string = string + "\"\(value.key)\":{\"\(value.constraint.rawValue)\":\(value.value)}"
                }
            case .ContainedInArray, .NotContainedInArray:
                string = string + "\"\(value.key)\":{\"\(value.constraint.rawValue)\":\(value.value)}"
            default:
                string = string + "\"\(value.key)\":{\"\(value.constraint.rawValue)\":\(value.value)}"
            }
            
            if values.count > 1 && i != values.count - 1 {
                string = string + ", "
            }
        }
        self.param["where"] = "{\(string)}" 
        return self
    }
    
    open func sort(_ values: [WarpSort]) -> WarpQueryBuilder {
        var string: String = ""
        values.enumerated().forEach { (i, value) in
            string = string + "{\"\(value.key)\": \(value.order.rawValue)}"
            if values.count > 1 && i != values.count - 1 {
                string = string + ", "
            }
        }
        self.param["sort"] = "[\(string)]" 
        return self
    }
    
    open func add(_ key: String, value: Any) -> WarpQueryBuilder {
        self.param[key] = value
        return self
    }
    
    open func limit(_ value: Int) -> WarpQueryBuilder {
        self.param["limit"] = value 
        return self
    }
    
    open func skip(_ value: Int) -> WarpQueryBuilder {
        self.param["skip"] = value 
        return self
    }
    
    open func showDebug() {
        guard param.keys.count > 0 else {
            print("WARPLOG There are no parameters")
            return
        }
        
        print("\n\nWARPLOG START =================== \n")
        for key in param.keys {
            switch key {
            case "include":
                print("include: ", String(param["include"] as! String) ?? "")
            case "where":
                print("where: ", String(param["where"] as! String) ?? "")
            case "sort":
                print("sort: ", String(param["sort"] as! String) ?? "")
            case "limit":
                print("limit: ", String(param["limit"] as! Int))
            case "skip":
                print("skip: ", String(param["skip"] as! Int))
            default:
                print(key + ": ", String(describing: param[key]))
            }
        }
        print("WARPLOG END ===================\n\n")
    }
}

public struct WarpQueryConstraint {
    public var key: String = ""
    public var constraint: WarpConstraint = .EqualTo
    public var value: Any = "" 
    
    public init(equalTo value: Any, key: String) {
        self.key = key
        self.constraint = .EqualTo
        self.value = value
    }
    
    public init(notEqualTo value: Any, key: String) {
        self.key = key
        self.constraint = .NotEqualTo
        self.value = value
    }
    
    public init(greaterThan value: Any, key: String) {
        self.key = key
        self.constraint = .GreaterThan
        self.value = value
    }
    
    public init(greaterThanOrEqualTo value: Any, key: String) {
        self.key = key
        self.constraint = .GreaterThanOrEqualTo
        self.value = value
    }
    
    public init(lessThan value: Any, key: String) {
        self.key = key
        self.constraint = .LessThan
        self.value = value
    }
    
    public init(lessThanOrEqualTo value: Any, key: String) {
        self.key = key
        self.constraint = .LessThanOrEqualTo
        self.value = value
    }
    
    public init(existsKey key: String) {
        self.key = key
        self.constraint = .Exists
        self.value = 1 
    }
    
    public init(notExistsKey key: String) {
        self.key = key
        self.constraint = .Exists
        self.value = 0 
    }
    
    public init(containedIn values: [Any], key: String) {
        self.key = key
        self.constraint = .ContainedInArray
        self.value = values 
    }
    
    public init(notContainedIn values: [Any], key: String) {
        self.key = key
        self.constraint = .NotContainedInArray
        self.value = values 
    }
    
    public init(startsWith value: String, key: String) {
        self.key = key
        self.constraint = .StartsWithString
        self.value = value 
    }
    
    public init(endsWith value: String, key: String) {
        self.key = key
        self.constraint = .EndsWithString
        self.value = value 
    }
    
    public init(contains value: String, key: String) {
        self.key = key
        self.constraint = .ContainsString
        self.value = value 
    }
    
    public init(contains value: String, keys: [String]) {
        var string: String = ""
        keys.enumerated().forEach { (i, key) in
            switch i {
            case 0:
                string = key
            case keys.count:
                string = string + key
            default:
                string = string + "|" + key
            }
        }
        self.key = "\(string)"
        self.constraint = .ContainsString
        self.value = value 
    }
}

public enum WarpConstraint: String {
    /// eq: equal to
    case EqualTo = "eq"
    
    /// neq: not equal to
    case NotEqualTo = "neq"
    
    /// gt: greater than
    case GreaterThan = "gt"
    
    /// gte: greater than or equal to
    case GreaterThanOrEqualTo = "gte"
    
    /// lt: less than
    case LessThan = "lt"
    
    /// lte: less than or equal to
    case LessThanOrEqualTo = "lte"
    
    /// ex: is not null/is null (value is either true or false)
    case Exists = "ex"
    
    /// in: contained in array
    case ContainedInArray = "in"
    
    /// nin: not contained in array
    case NotContainedInArray = "nin"
    
    
    /// str: starts with the specified string
    case StartsWithString = "str"
    
    /// end: ends with the specified string
    case EndsWithString = "end"
    
    /// has: contains the specified string (to search multiple keys, separate the key names with |)
    case ContainsString = "has"
}

public struct WarpSort {
    var key: String = ""
    var order: WarpOrder = .ascending
    
    public init(by key: String) {
        self.key = key
        self.order = .ascending
    }
    
    public init(byDescending key: String) {
        self.key = key
        self.order = .descending
    }
}
