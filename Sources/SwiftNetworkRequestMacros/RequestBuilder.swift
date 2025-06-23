import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

struct RequestBuilder {
    let httpMethod: HTTPMethod

    func build(
        declaration: some DeclGroupSyntax,
        node: AttributeSyntax,
        context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            throw RequestError(message: "Macro can be used only on structs.")
        }
        guard structDecl.attributes.count(for: httpMethod.macroName) == 1 else {
            throw RequestError(message: "Only one \(httpMethod.macroName) attribute allowed per struct.")
        }
        
        let parsedUrl = try node.parsedUrlArguments
        guard let parsedUrl else { return [] }
   
        let headersArgumentValue = node.arrayArgumentValue(forText: "headers")
        let queryParamsArgumentValue = node.arrayArgumentValue(forText: "queryParams")
        let storedProperties = structDecl.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { $0.isStoredProperty }
        let returnValue: [DeclSyntax]

        switch httpMethod {
        case let .get(isList):
            returnValue = buildGetRequest(
                structDecl: structDecl,
                storedProperties: storedProperties,
                parsedUrl: parsedUrl,
                isList: isList,
                headersArgumentValue: headersArgumentValue,
                queryParamsArgumentValue: queryParamsArgumentValue,
                accessLevel: declaration.accessLevel
            )
        case .post, .put:
            try validateRequiredProperties(node: node, declaration: declaration)
            
            returnValue = buildStoreRequest(
                parsedUrl: parsedUrl,
                structDecl: structDecl,
                node: node,
                httpMethod: httpMethod,
                storedProperties: storedProperties,
                headersArgumentValue: headersArgumentValue,
                queryParamsArgumentValue: queryParamsArgumentValue,
                accessLevel: declaration.accessLevel
            )
        case .delete:
            try validateRequiredProperties(node: node, declaration: declaration)
            
            returnValue = buildDeleteRequest(
                parsedUrl: parsedUrl,
                headersArgumentValue: headersArgumentValue,
                queryParamsArgumentValue: queryParamsArgumentValue,
                accessLevel: declaration.accessLevel
            )
        }

        return returnValue
    }
}

// MARK: - Get Request Builder

private extension RequestBuilder {
    func buildGetRequest(
        structDecl: StructDeclSyntax,
        storedProperties: [VariableDeclSyntax],
        parsedUrl: (methodArguments: String, requestUrl: String),
        isList: Bool,
        headersArgumentValue: ExprSyntax,
        queryParamsArgumentValue: ExprSyntax,
        accessLevel: AccessLevel
    ) -> [DeclSyntax] {
        let responseStructName = "\(isList ? "GetCollection" : "Get")Response"
        let codingKeys = generateCodingKeysIfNeeded(storedProperties: storedProperties)
        let responseStructProperties = storedProperties.compactMap {
            guard let storedProperty = $0.storedProperty else { return nil }
            
            return "let \(storedProperty.name): \(storedProperty.type)"
        }
        .reduce(into: "") { $0 += $1 + "\n" }

        let structType = isList ? "[\(responseStructName)]" : "\(responseStructName)"
        let returnType = isList ? "[Self]" : "Self"
        let responseStruct = """
        struct \(responseStructName): Codable {
            \(responseStructProperties)
            \(codingKeys)
        }
        """
        
        let responseInitializerProperties = storedProperties.compactMap { $0.storedProperty?.name }
        .enumerated().reduce(into: "") {
            let parameter = "\($1.element): response.\($1.element)"
            let separator = if $1.offset == 0 { "" } else { ", " }

            $0 += "\(separator)\(parameter)"
        }
        let getReturn = if isList {
            "return response.map { response in .init(\(responseInitializerProperties)) }"
        } else {
            "return .init(\(responseInitializerProperties))"
        }

        let getFunction = """
            \(accessLevel.rawValue) static func get(
                \(generateMethodSignature(methodArguments: parsedUrl.methodArguments))
            ) async throws -> \(returnType) {
                var headers: [KeyValuePair] = \(headersArgumentValue) + requestConfig.defaultHeaders + dynamicHeaders
                let queryParams: [KeyValuePair] = \(queryParamsArgumentValue) + requestConfig.defaultQueryParams + dynamicQueryParams
            
                if let defaultAuthorization = try await defaultAuthorization { 
                    headers.append(defaultAuthorization)
                }
            
                let response: \(structType) = try await requestConfig.urlSession.executeRequest(
                    path: "\(parsedUrl.requestUrl)",
                    httpMethod: "GET",
                    headers: headers,
                    queryParams: queryParams            
                ) 
                
                \(getReturn)
            }
            """

        return [
            "\(raw: getFunction)",
            "\(raw: responseStruct)"
        ]
    }
}

// MARK: - Post/Put Request Builder

private extension RequestBuilder {
    func buildStoreRequest(
        parsedUrl: (methodArguments: String, requestUrl: String),
        structDecl: StructDeclSyntax,
        node: AttributeSyntax,
        httpMethod: HTTPMethod,
        storedProperties: [VariableDeclSyntax],
        headersArgumentValue: ExprSyntax,
        queryParamsArgumentValue: ExprSyntax,
        accessLevel: AccessLevel
    ) -> [DeclSyntax] {        
        let requestStructName = "\(httpMethod.stringValue.capitalized)RequestBody"
        let includedProperties = storedProperties.filter { !$0.attributes.hasAttribute("ExcludeFromRequest") }
        let requestBodyInitializerProperties = includedProperties
            .compactMap { $0.storedProperty?.name }
            .enumerated().reduce(into: "") {
                let parameter = "\($1.element): self.\($1.element)"
                let separator = $1.offset == 0 ?  "" : ", "

                $0 += "\(separator)\(parameter)"
            }

        let requestFunction = """
        \(accessLevel.rawValue) func \(httpMethod.stringValue.lowercased())(
            \(generateMethodSignature(methodArguments: nil))
        ) async throws {
            let requestBody: \(requestStructName) = .init(\(requestBodyInitializerProperties))
            var headers: [KeyValuePair] = \(headersArgumentValue) + requestConfig.defaultHeaders + dynamicHeaders
            let queryParams: [KeyValuePair] = \(queryParamsArgumentValue) + requestConfig.defaultQueryParams + dynamicQueryParams          
        
            if let defaultAuthorization = try await defaultAuthorization { 
                headers.append(defaultAuthorization)
            }
        
            try await requestConfig.urlSession.executeRequest(
                path: "\(parsedUrl.requestUrl)",
                httpMethod: "\(httpMethod)",
                headers: headers,
                queryParams: queryParams,
                body: try JSONEncoder().encode(requestBody)
            )
        }
        """
        let requestStructProperties: [(name: String, type: String)] = includedProperties.compactMap {
            guard let storedProperty = $0.storedProperty else { return nil }
            return (storedProperty.name, "\(storedProperty.type)")
        }
        let requestStructCodingKeys = generateCodingKeysIfNeeded(storedProperties: includedProperties)

        let requestStruct = """
        struct \(requestStructName): Codable, Equatable { 
            \(requestStructProperties.reduce(into: "") { $0 += "let \($1.name): \($1.type)"  + "\n" })
            \(requestStructCodingKeys)
        }
        """
    
        return [
            "\(raw: requestStruct)",
            "\(raw: requestFunction)"
        ]
    }
}

// MARK: - Delete Request Builder

private extension RequestBuilder {
    func buildDeleteRequest(
        parsedUrl: (methodArguments: String, requestUrl: String),
        headersArgumentValue: ExprSyntax,
        queryParamsArgumentValue: ExprSyntax,
        accessLevel: AccessLevel
    ) -> [DeclSyntax] {
        [
        """
        \(raw: accessLevel.rawValue) func delete(
            \(raw: generateMethodSignature(methodArguments: nil))
        ) async throws {
            var headers: [KeyValuePair] = \(headersArgumentValue) + requestConfig.defaultHeaders + dynamicHeaders
            let queryParams: [KeyValuePair] = \(queryParamsArgumentValue) + requestConfig.defaultQueryParams + dynamicQueryParams
        
            if let defaultAuthorization = try await defaultAuthorization { 
                headers.append(defaultAuthorization)
            }
        
            try await requestConfig.urlSession.executeRequest(
                path: "\(raw: parsedUrl.requestUrl)",
                httpMethod: "DELETE",
                headers: headers,
                queryParams: queryParams,
                body: nil
            )
        }
        """
        ]
    }
}

// MARK: - Helpers

private extension AttributeSyntax {
    var parsedUrlArguments: (methodArguments: String, requestUrl: String)? {
        get throws {
            guard
                let arguments = arguments,
                case let .argumentList(labeledExprListSyntax) = arguments,
                var urlString = labeledExprListSyntax.first?.expression.asString
            else {
                return nil
            }
            guard URL(string: urlString) != nil else {
                throw RequestError(message: "Invalid URL: \(urlString)")
            }
            let pathParameters = urlString.extractPathParameters()
            let argumentsFromPathParameters = pathParameters.enumerated().reduce(into: "") {
                let argumentName = $1.element.replacingOccurrences(of: ":", with: "")
                let separator = if $1.offset == 0 { "" } else { ", " }

                $0 += "\(separator)\(argumentName): String"
            }

            urlString = urlString.replacePathParameterWithArguments(pathParams: pathParameters)

            return (argumentsFromPathParameters, urlString)
        }
    }
    
    var urlPathParameterNames: [String] {
        guard
            let arguments = arguments,
            case let .argumentList(labeledExprListSyntax) = arguments,
            let urlString = labeledExprListSyntax.first?.expression.asString
        else {
            return []
        }
        
        return urlString.extractPathParameters().map {
            $0.replacingOccurrences(of: ":", with: "")
        }
    }

    func arrayArgumentValue(forText: String) -> ExprSyntax {
        guard
            let arguments = arguments,
            case let .argumentList(labeledExprListSyntax) = arguments,
            let headersArgument = labeledExprListSyntax.first(where: { $0.label?.text == forText })
        else {
            let emptyArrayExpr = ArrayExprSyntax(
                leftSquare: .leftSquareToken(),
                elements: ArrayElementListSyntax([]),
                rightSquare: .rightSquareToken()
            )
            
            return .init(emptyArrayExpr)
        }
        
        return headersArgument.expression
    }
}

private extension AttributeListSyntax {
    func hasAttribute(_ attributeName: String) -> Bool {
        contains { attribute in
            switch attribute {
            case let .attribute(attr):
                return attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text == attributeName
            default:
                return false
            }
        }
    }

    func count(for attributeName: String) -> Int {
        filter { attribute in
            guard case let .attribute(attr) = attribute else {
                return false
            }

            return attr.attributeName.as(IdentifierTypeSyntax.self)?.name.text == attributeName
        }.count
    }
}

private extension RequestBuilder {
    func generateCodingKeysIfNeeded(storedProperties: [VariableDeclSyntax]) -> String {
        guard storedProperties.contains(where: { $0.attributes.hasAttribute("RequestBodyKey") }) else {
            return ""
        }

        let codingKeys = storedProperties
            .compactMap { variableDeclSyntax in
                guard let storedProperty = variableDeclSyntax.storedProperty else { return nil }

                let attributeSyntax = variableDeclSyntax
                    .attributes
                    .first?
                    .as(AttributeSyntax.self)

                if let attribute = attributeSyntax?.attributeName.as(IdentifierTypeSyntax.self) ,
                   attribute.name.text == "RequestBodyKey",
                   let labelExprSyntax = attributeSyntax?.arguments?.as(LabeledExprListSyntax.self)?.first,
                   let requestBodyKey = labelExprSyntax.expression.asString
                {
                    return "case \(storedProperty.name) = \"\(requestBodyKey)\""
                } else {
                    return "case \(storedProperty.name)"
                }
            }
            .joined(separator: "\n")


        return """
        enum CodingKeys: String, CodingKey {
            \(codingKeys)
        }
        """
    }
    
    func validateRequiredProperties(
        node: AttributeSyntax,
        declaration: some DeclGroupSyntax
    ) throws {
        let requiredProperties = node.urlPathParameterNames
        guard !requiredProperties.isEmpty else { return }
        
        let memberPropertyNames = declaration.memberBlock.members.map { member in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { return "" }
            guard let propertyName = varDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else { return "" }
            
            return propertyName
        }
        
        let hasRequiredProperties = memberPropertyNames
            .filter { requiredProperties.contains($0) }.count == requiredProperties.count
        
        guard hasRequiredProperties else {
            let errorMessage = #"""
                    Path parameters should match the property declarations in the struct. 
                    For example, if your URL is defined like this 
                    https://jsonplaceholder.typicode.com/posts/:id/user/:userId, 
                    then your struct must have properties id and userId which will be used to generate the final request URL
                    """#.replacingOccurrences(of: "\n", with: "")
            throw RequestError(message: errorMessage)
        }
    }
    
    func isModuleImported(name: String, in context: some MacroExpansionContext) -> Bool {
        guard let sourceFile = context.lexicalContext.first?.root.as(SourceFileSyntax.self)
        else { return true }
        
        let importDecl = sourceFile.statements.compactMap { $0.item.as(ImportDeclSyntax.self) }.first
        guard let importDecl else { return false }
        
        
        return importDecl.path.contains { $0.name.text == name }
    }
    
    func generateMethodSignature(methodArguments: String?) -> String {
        if let methodArguments, !methodArguments.isEmpty {
            """
            \(methodArguments),
            dynamicHeaders: [KeyValuePair] = [],
            dynamicQueryParams: [KeyValuePair] = []
            """
        } else {
            """
            dynamicHeaders: [KeyValuePair] = [],
            dynamicQueryParams: [KeyValuePair] = []
            """
        }
    }
}
