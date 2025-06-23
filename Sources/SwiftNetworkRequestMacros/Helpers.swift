//

import SwiftSyntax

extension ExprSyntax {
    var asString: String? {
        guard let stringLiteral = self.as(StringLiteralExprSyntax.self) else {
            return nil
        }
        
        return stringLiteral.segments
            .compactMap { $0.as(StringSegmentSyntax.self)?.content.text }
            .joined()
    }
}

extension VariableDeclSyntax {
    var isStoredProperty: Bool {
        bindings.allSatisfy { binding in
            switch binding.accessorBlock?.accessors {
            case .none:
                return true
            default:
                return false
            }
        }
    }
    
    var storedProperty: (name: String, type: TypeSyntax)? {
        guard bindings.count == 1 else { return nil }
        let binding = bindings.first!
        
        guard
            let name = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
            let type = binding.typeAnnotation?.type
        else { return nil }
        
        return (name, type)
    }
}

extension DeclGroupSyntax {
    var accessLevel: AccessLevel {
        modifiers.contains { $0.name.tokenKind == .keyword(.public) } ? .public : .internal
    }
}

extension String {
    func extractPathParameters() -> [String] {
        let pattern = #":[a-zA-Z_][a-zA-Z0-9_]*"#
        
        do {
            let regex = try Regex(pattern)
            return self.matches(of: regex).map { String($0.0) }
        } catch {
            print("Regex error: \(error)")
            return []
        }
    }
    
    func replacePathParameterWithArguments(pathParams: [String]) -> String {
        var result = self
        
        for pathParam in pathParams {
            let argument = pathParam.replacingOccurrences(of: ":", with: "")
            result = result.replacingOccurrences(of: pathParam, with: "\\(\(argument))")
        }
        
        return result
    }
}
