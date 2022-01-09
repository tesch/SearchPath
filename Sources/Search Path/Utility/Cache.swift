//
// Cache.swift
//
// Created by Marcel Tesch on 2021-10-29.
// Think different.
//

import Foundation

actor Cache<Key: Hashable, Value> {

    private var cache: Dictionary<Key, Value> = [:]

    private func getValue(forKey key: Key) -> Value? {
        cache[key]
    }

    private func setValue(_ value: Value, forKey key: Key) {
        cache[key] = value
    }

}

extension Cache {

    nonisolated func cacheValue(forKey key: Key, block: () async throws -> Value) async rethrows -> Value {
        if let value = await getValue(forKey: key) { return value }

        let value = try await block()

        Task { await self.setValue(value, forKey: key) }

        return value
    }

    func invalidate() {
        cache = [:]
    }

}
