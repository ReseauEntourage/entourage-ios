import SwiftUI

// Extension pour personnaliser la navigation bar
private struct NavigationConfigurator: UIViewControllerRepresentable {
    var configure: (UINavigationController) -> Void = { _ in }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            configure(nc)
        }
    }
}

struct BadgeDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with badge info
                    VStack(spacing: 8) {
                        Text("Détail du badge")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 81/255, green: 81/255, blue: 81/255))
                            .padding(.top, 20)
                        
                        Text("Premier pas")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 81/255, green: 81/255, blue: 81/255))
                            .padding(.top, 4)
                        
                        Text("Obtenu le 12 janvier 2026")
                            .font(.subheadline)
                            .foregroundColor(Color(red: 151/255, green: 151/255, blue: 151/255))
                            .padding(.bottom, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 245/255, green: 245/255, blue: 245/255))
                    
                    // Comment ça marche section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("COMMENT CA MARCHE")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 81/255, green: 81/255, blue: 81/255))
                            .padding(.top, 16)
                        
                        Text("Terminez votre onboarding (centres d'intérêt, envies d'agir, catégories d'entraide, disponibilités) puis réalisez votre première action sur l'app.")
                            .font(.footnote)
                            .foregroundColor(Color(red: 81/255, green: 81/255, blue: 81/255))
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 253/255, green: 245/255, blue: 236/255))
                    
                    // Mécanique section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("MECANIQUE")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 81/255, green: 81/255, blue: 81/255))
                            .padding(.top, 16)
                        
                        Text("© scvjours")
                            .font(.caption)
                            .foregroundColor(Color(red: 151/255, green: 151/255, blue: 151/255))
                            .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 225/255, green: 240/255, blue: 232/255))
                    
                    // Ce que ça représente section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("CE QUE CA REPRESENTE")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 81/255, green: 81/255, blue: 81/255))
                            .padding(.top, 16)
                        
                        Text("Ce badge célèbre votre arrivée dans la communauté. Il marque votre premier geste — celui qui transforme un compte créé en une réelle intention.")
                            .font(.footnote)
                            .foregroundColor(Color(red: 81/255, green: 81/255, blue: 81/255))
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(red: 245/255, green: 245/255, blue: 245/255))
                    
                    // Espace en bas
                    Spacer().frame(height: 30)
                }
                .navigationBarTitle("", displayMode: .inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { 
                            presentationMode.wrappedValue.dismiss() 
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(Color(red: 81/255, green: 81/255, blue: 81/255))
                                .font(.system(size: 18, weight: .medium))
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        Text("Détail du badge")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 81/255, green: 81/255, blue: 81/255))
                    }
                }
                .background(
                    NavigationConfigurator { nc in
                        let appearance = UINavigationBarAppearance()
                        appearance.configureWithOpaqueBackground()
                        appearance.titleTextAttributes = [
                            .foregroundColor: UIColor(red: 81/255, green: 81/255, blue: 81/255, alpha: 1)
                        ]
                        appearance.backgroundColor = UIColor.systemBackground
                        nc.navigationBar.standardAppearance = appearance
                        nc.navigationBar.compactAppearance = appearance
                        nc.navigationBar.scrollEdgeAppearance = appearance
                    }
                )
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}

struct BadgeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        BadgeDetailView()
    }
}
