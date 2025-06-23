import SwiftUI

struct PostFormView: View {
    @State var post: Post = .draft
    @Environment(\.dismiss) var dismiss
    let action: Action
    
    var body: some View {
        Form {
            TextField("Title", text: $post.title)
            TextField("Body", text:  $post.body)
            TextField("UserId", value: $post.userId, formatter: NumberFormatter())
            
            Button {
                Task {
                    switch action {
                    case .create:
                        try! await post.post()
                    case .edit:
                        try! await post.put()
                    }
                    
                    dismiss()
                }
            } label: {
                Text("Save")
                    .frame(maxWidth: .infinity, minHeight: 35)
                
            }
            .padding(.bottom, 40)
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 20)
        }
    }
}

extension PostFormView {
    enum Action {
        case create
        case edit
    }
}

#Preview {
    PostFormView(action: .create)
}
