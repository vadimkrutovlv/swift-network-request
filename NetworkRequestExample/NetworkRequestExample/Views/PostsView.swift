import SwiftNetworkRequest
import SwiftUI

struct PostsView: View {
    @State private var posts: [Post] = []
    @State private var navigationPath = NavigationPath()
    @State private var isCreateFormPresented: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(posts) { post in
                HStack {
                    Text("\(post.id) - \(post.title)")
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture { navigationPath.append(post.id) }
            }
            .task {
                posts = try! await Post.get()
            }
            .navigationDestination(for: Int.self) { postId in
                PostDetailView(id: postId)
            }
            .sheet(isPresented: $isCreateFormPresented) { PostFormView(action: .create) }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Create New Post") { isCreateFormPresented = true }
                }
            }
        }
    }
}

#Preview {
    PostsView()
}
