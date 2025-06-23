import SwiftSyntax
import SwiftSyntaxMacros

@_documentation(visibility: internal)
public struct GetCollectionMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let builder = RequestBuilder(httpMethod: .get(isList: true))
        
        return try builder.build(declaration: declaration, node: node, context: context)
    }
}

@_documentation(visibility: internal)
public struct GetMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let builder = RequestBuilder(httpMethod: .get(isList: false))
        
        return try builder.build(declaration: declaration, node: node, context: context)
    }
}

@_documentation(visibility: internal)
public struct PostMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let builder = RequestBuilder(httpMethod: .post)
        
        return try builder.build(declaration: declaration, node: node, context: context)
    }
}

@_documentation(visibility: internal)
public struct PutMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let builder = RequestBuilder(httpMethod: .put)
        
        return try builder.build(declaration: declaration, node: node, context: context)
    }
}

@_documentation(visibility: internal)
public struct DeleteMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let builder = RequestBuilder(httpMethod: .delete)
        
        return try builder.build(declaration: declaration, node: node, context: context)
    }
}

@_documentation(visibility: internal)
public struct RequestBodyKeyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}

@_documentation(visibility: internal)
public struct ExcludedFromBodyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}
