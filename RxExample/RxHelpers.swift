//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

/// via <https://github.com/RxSugar/RxSugar/tree/d639d4279f8f465c16aff3618d7c503da3dfe3ce/RxSugar/OptionalType.swift>
public protocol OptionalType {
    associatedtype Wrapped

    var optional: Wrapped? { get }
}

extension OptionalType {
    public func hasValue() -> Bool {
        return optional != nil
    }
}

extension Optional: OptionalType {
    public var optional: Wrapped? {
        return self
    }
}


import RxSwift

/// via <https://github.com/RxSugar/RxSugar/tree/d639d4279f8f465c16aff3618d7c503da3dfe3ce/RxSugar/IgnoreNil.swift>
extension ObservableType where E: OptionalType {
    public func ignoreNil() -> Observable<E.Wrapped> {
        return filter { $0.hasValue() }
            .map { $0.optional! }
    }
}

import RxCocoa

/// via <https://github.com/RxSwiftCommunity/RxOptional/tree/93d12b3c3bfc1886ebd038149b24a8d7d6ef1ea4/Source/Driver%2BOptional.swift>
extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, E: OptionalType {
    public func ignoreNil() -> Driver<E.Wrapped> {
        return self.flatMap { element -> Driver<E.Wrapped> in
            guard let value = element.optional else {
                return Driver<E.Wrapped>.empty()
            }
            return Driver<E.Wrapped>.just(value)
        }
    }
}
