import Foundation
import SwiftRedis

class SwiftRedisClient: RedisClient {
    private let redis = Redis()
    private var isConnected = false
    
    override init() {
        super.init()
        connectToRedis()
    }
    
    private func connectToRedis() {
        redis.connect(host: "localhost", port: 6379) { error in
            if let error = error {
                print("❌ Redis connection error: \(error)")
                self.isConnected = false
            } else {
                print("✅ Successfully connected to Redis")
                self.isConnected = true
            }
        }
    }
    
    override func get(_ key: String, completion: @escaping (RedisResponse?, Error?) -> Void) {
        redis.get(key) { response in
            if let error = response.error {
                completion(nil, error)
            } else {
                let redisResponse = RedisResponse(string: response.asString)
                completion(redisResponse, nil)
            }
        }
    }
    
    override func set(_ key: String, to value: String) async throws {
        try await withCheckedThrowingContinuation { continuation in
            redis.set(key, value: value) { response in
                if let error = response.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    override func keys(_ pattern: String, completion: @escaping (RedisResponse?, Error?) -> Void) {
        redis.keys(pattern) { response in
            if let error = response.error {
                completion(nil, error)
            } else if let array = response.asArray {
                let redisResponse = RedisResponse(array: array.map { RedisResponse(string: $0.asString) })
                completion(redisResponse, nil)
            } else {
                completion(RedisResponse(array: []), nil)
            }
        }
    }
} 