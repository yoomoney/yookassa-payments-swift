import Dispatch
import FunctionalSwift
import When

// MARK: - Swift Functor

extension Promise {
    @discardableResult
    func map<U>(_ transform: @escaping (T) throws -> U) -> Promise<U> {
        return then(on: .global(), transform)
    }
}

// MARK: - Swift Monad

extension Promise {
    @discardableResult
    func flatMap<U>(_ transform: @escaping (T) throws -> Promise<U>) -> Promise<U> {
        return then(on: .global(), transform)
    }
}

// MARK: - Promise functor

@discardableResult
func <^><T, U>(_ transform: @escaping (T) throws -> U, _ arg: Promise<T>) -> Promise<U> {
    return arg.then(on: .global(), transform)
}

@discardableResult
func <^<T, U>(_ transform: T, _ arg: Promise<U>) -> Promise<T> {
    return arg.then(on: .global()) { _ in transform }
}

@discardableResult
func ^><T, U>(_ arg: Promise<T>, _ transform: U) -> Promise<U> {
    return arg.then(on: .global()) { _ in transform }
}

// MARK: - Promise monad

@discardableResult
func >>-<T, U>(_ arg: Promise<T>, _ transform: @escaping (T) throws -> Promise<U>) -> Promise<U> {
    return arg.then(on: .global(), transform)
}

@discardableResult
func -<<<T, U>(_ transform: @escaping (T) throws -> Promise<U>, _ arg: Promise<T>) -> Promise<U> {
    return arg.then(on: .global(), transform)
}

// MARK: - Promise applicative

@discardableResult
func <*><T, U>(_ transform: Promise<(T) throws -> U>, _ arg: Promise<T>) -> Promise<U> {
    let promise = Promise<U>(queue: .global())
    when(transform, arg)
        .done { transform, arg in
            do {
                promise.resolve(try transform(arg))
            } catch {
                promise.reject(error)
            }
        }
        .fail(promise.reject)
    return promise
}

@discardableResult
func liftA2<T, U, V>(_ transform: @escaping (T, U) throws -> V,
                     _ arg1: Promise<T>,
                     _ arg2: Promise<U>) -> Promise<V> {
    return when(arg1, arg2).then(on: .global(), transform)
}

@discardableResult
func liftA3<T, U, V, W>(_ transform: @escaping (T, U, V) throws -> W,
                        _ arg1: Promise<T>,
                        _ arg2: Promise<U>,
                        _ arg3: Promise<V>) -> Promise<W> {
    return when(arg1, arg2, arg3).then(on: .global(), transform)
}
