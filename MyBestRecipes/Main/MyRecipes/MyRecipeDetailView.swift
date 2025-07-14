//
//  MyRecipeDetailView.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//


import SwiftUI
import RealmSwift


struct MyRecipeDetailView: View {
    // @ObservedRealmObject гарантирует, что View будет следить за изменениями этого объекта
    @ObservedRealmObject var recipe: RealmRecipe
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let imageData = recipe.imageData, let image = UIImage(data: imageData) {
                        CustomHeaderImageView(imageData: imageData) { dismiss() }
                    }
                   //
                    
                    VStack(alignment: .leading, spacing: 24) {
                        Text(recipe.name).font(.system(size: 32, weight: .bold, design: .rounded)).foregroundColor(.appPrimaryText)
                        if !recipe.recipeDescription.isEmpty {
                            Text(recipe.recipeDescription).font(.body).foregroundColor(.appSecondaryText)
                        }
                        SectionView(title: "Ingredients") {
                            ForEach(recipe.ingredients, id: \.self) { ingredient in Text("• \(ingredient)").foregroundColor(.appPrimaryText) }
                        }
                        SectionView(title: "Cooking steps") {
                            ForEach(recipe.cookingSteps.indices, id: \.self) { index in StepView(index: index + 1, text: recipe.cookingSteps[index]) }
                        }
                    }.padding()
                }
            }
            .ignoresSafeArea(edges: .top)
//            .toolbar {
//                
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button(role: .destructive) { deleteRecipe() } label: { Image(systemName: "trash") }.tint(.red)
//                }
//            }
        }
        .navigationBarBackButtonHidden(true).preferredColorScheme(.dark)
    }

    // Вспомогательные View (Header, Section, Step) можно скопировать из предыдущих ответов
    // ...

    private func deleteRecipe() {
        StorageManager.shared.deleteUserRecipe(id: recipe.id)
        dismiss()
    }
}


struct CustomHeaderImageView: View {
    let imageData: Data
    var onBackButtonTapped: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(uiImage: UIImage(data: imageData) ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 300)
                .clipped()
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [.black.opacity(0.5), .clear]),
                                   startPoint: .top, endPoint: .center)
                )
            
            Button(action: onBackButtonTapped) {
                Image(systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .clipShape(Circle())
            }
            .padding([.top, .leading], 16)
        }
    }
}
