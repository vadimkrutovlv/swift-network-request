import SwiftUI

struct PostDetailView: View {
    let id: Int
    @State private var post: Post?
    @Environment(\.dismiss) var dismiss
    @State private var isUpdateFormPresented: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(post?.title ?? "")
                .font(.title)
                .padding(.horizontal, 20)
            Divider()
            
            Text(post?.body ?? "")
                .font(.body)
                .padding(.top, 10)
                .padding(.horizontal, 20)
            Spacer()
            
            Button() {
                isUpdateFormPresented = true
            } label: {
                Text("Edit")
                    .frame(maxWidth: .infinity, minHeight: 35)
                
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 20)
            
            Button(role: .destructive) {
                Task {
                    try! await post!.delete()
                    dismiss()
                }
            } label: {
                Text("Delete")
                    .frame(maxWidth: .infinity, minHeight: 35)
                
            }
            .padding(.bottom, 40)
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 20)
        }
        .task {
            post = try! await Post.get(id: "\(id)")
        }
        .navigationTitle("Post details")
        .sheet(isPresented: $isUpdateFormPresented) {
            if let post {
                PostFormView(post: post, action: .edit)
            }
        }
    }
}

#Preview {
    PostDetailView(id: 1)
}
