//
//  WarpPointer.swift
//  SwipeRX
//
//  Created by Zonily Jame Pesquera on 06/10/2016.
//
//

import EVReflection

open class WarpPointer<Attribute>: EVObject where Attribute: WarpModel {
    open var id: Int = 0
    open var type: String = "Pointer"
    open var className: String = ""
    open var attributes: Attribute = Attribute()
    
    public required init(){
        super.init()
    }
    
    public init(model: Attribute) {
        super.init()
        self.className = type(of: model).className()
        self.id = model.id
        self.attributes = model
    }
    
    public init(className: String, id: Int){
        super.init()
        self.className = className
        self.id = id
    }
    
    open func map() -> [String: Any] {
        return WarpPointer.map(className: className, id: id, attributes: attributes)
    }
    
    override open func setValue(_ value: Any?, forUndefinedKey key: String) {
        switch key {
        case "attributes":
            self.attributes = value as! Attribute
        case "id":
            self.id = value as! Int
        case "className":
            self.className = value as! String
        case "type":
            self.type = value as! String
        default:
            WarpTools.showLog(value, key: key, model: "WarpPointer")
        }
    }
}

// Data Mappers
extension WarpPointer {
    open static func map(className: String, id: Int) -> [String: Any] {
        return [
            "type": "Pointer",
            "className": className,
            "id": id]
    }
    
    open static func map(warpObject object: WarpObject) -> [String: Any] {
        return [
            "type":"Pointer",
            "className": object.className,
            "id": object.objectId,
            "attributes": object.objects]
    }
    
    open static func map(warpUser object: WarpUser) -> [String: Any] {
        return [
            "type":"Pointer",
            "className": object.className,
            "id": object.objectId,
            "attributes": object.objects]
    }
    
    open static func map(className: String, id: Int, attributes: Any?) -> [String: Any] {
        if attributes != nil {
            return [
                "type": "Pointer",
                "className": className,
                "id": id,
                "attributes": attributes!]
        } else {
            return [
                "type": "Pointer",
                "className": className,
                "id": id]
        }
    }
}
