import Foundation

/**
 An attempt of using all swift language features to make sure that all types of different projects are supported.
 
 Missing information using Swift 5.10
 - No information about `async`, `@MainActor`
 - `class func` is missing a unique feature and only shows as `static`
 */

/**
 TODOs:
 - macro
 - subscriptDeclaration
 */

// MARK: - Protocol with associatedtype

protocol CustomProtocol {
    associatedtype CustomAssociatedType: Equatable
    
    var getSetVar: CustomAssociatedType { get set }
    var getVar: CustomAssociatedType { get }
    func function() -> CustomAssociatedType
}

public struct CustomStruct<T: Strideable>: CustomProtocol {
    typealias CustomAssociatedType = Int
    
    var getSetVar: Int
    var getVar: Int
    @discardableResult
    func function() -> Int { 0 }
}

// MARK: - Generic public class

public class CustomClass<T: Equatable> {
    
    public weak var weakObject: CustomClass?
    lazy var lazyVar: String = { "I am a lazy" }()
    @_spi(SomeSpi)
    @_spi(AnotherSpi)
    open var computedVar: String { "I am computed" }
    package let constantLet: String = "I'm a let"
    public var optionalVar: T? = nil
    
    @MainActor
    public func asyncThrowingFunc() async throws -> Void {}
    public func rethrowingFunc(throwingArg: @escaping () throws -> String) rethrows -> Void {}
    
    public init(weakObject: CustomClass? = nil, optionalVar: T? = nil) {
        self.weakObject = weakObject
        self.optionalVar = optionalVar
    }
    
    public init() {}
    
    public convenience init(value: T) {
        self.init(optionalVar: value)
    }
}

// MARK: - Generic open class with Protocol conformance and @_spi constraint

@_spi(SystemProgrammingInterface)
open class OpenSpiConformingClass<T: Equatable>: CustomProtocol {
    typealias CustomAssociatedType = T
    
    public var getSetVar: T
    public var getVar: T
    @inlinable
    public func function() -> T { return getVar }
    
    public init(getSetVar: T, getVar: T) {
        self.getSetVar = getSetVar
        self.getVar = getVar
    }
}

// MARK: - Package only class

package class PackageOnlyClass {
    public class func classFunc() -> String { "I'm classy" }
    public static func staticFunc() -> String { "I'm static" }
    public static var staticVar: String = "I'm static too"
}

// MARK: - Objc

@_spi(ObjCSpi)
@objc
public class ObjcClass: NSObject {
    public dynamic var dynamicVar: String = "I'm dynamic"
}

// MARK: - Actor

public actor CustomActor {}

// MARK: - Operators

public enum OperatorNamespace: String {
    case someValue = "1"
    
    public static prefix func ++ (_ counter: OperatorNamespace) -> String {
        return counter.rawValue
    }
    
    public static postfix func ++ (_ counter: OperatorNamespace) -> String {
        return counter.rawValue
    }
}

// MARK: Infix operator with custom precedencegroup

postfix operator &&
prefix operator &&

infix operator &&: CustomPrecedence

precedencegroup CustomPrecedence {
    higherThan: AdditionPrecedence
    lowerThan: MultiplicationPrecedence
    assignment: false
    associativity: left
}

// MARK: - Enums

public enum CustomEnum {
    case normalCase
    case caseWithString(String)
    case caseWithTuple(String, Int)
    case caseWithBlock((Int) throws -> Void)
    
    indirect case recursive(CustomEnum)
}
