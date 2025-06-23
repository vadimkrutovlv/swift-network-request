import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct Plugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        GetCollectionMacro.self,
        GetMacro.self,
        PostMacro.self,
        PutMacro.self,
        DeleteMacro.self,
        RequestBodyKeyMacro.self,
        ExcludedFromBodyMacro.self
    ]
}
