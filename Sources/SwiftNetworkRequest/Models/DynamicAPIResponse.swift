import Foundation

struct DynamicAPIResponse<T: Codable>: Codable {
    let data: T
    let foundKey: String
    let isArray: Bool
    
    init(from decoder: Decoder) throws {
        // Try to decode as an array first
        if (try? decoder.unkeyedContainer()) != nil {
            do {
                self.data = try T(from: decoder)
                self.foundKey = ""
                self.isArray = true
                return
            } catch { }
        }
    
        // Try to decode as a single value (direct T)
        do {
            let singleValueContainer = try decoder.singleValueContainer()
            self.data = try singleValueContainer.decode(T.self)
            self.foundKey = ""
            self.isArray = false
            return
        } catch { }
                
        // Try keyed container approach
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        let commonKeys = ["data", "result", "payload", "response", "content", "body"]
        
        for keyString in commonKeys {
            if let key = DynamicCodingKeys(stringValue: keyString), container.contains(key) {
                do {
                    self.data = try container.decode(T.self, forKey: key)
                    self.foundKey = keyString
                    self.isArray = false
                    return
                } catch {
                    continue
                }
            }
        }
        
        for key in container.allKeys {
            do {
                self.data = try container.decode(T.self, forKey: key)
                self.foundKey = key.stringValue
                self.isArray = false
                return
            } catch {
                continue
            }
        }
        
        throw DecodingError.dataCorrupted(
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Could not decode \(T.self) from any key"
            )
        )
    }
}

struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }
    
    init?(intValue: Int) {
        self.stringValue = String(intValue)
        self.intValue = intValue
    }
}
