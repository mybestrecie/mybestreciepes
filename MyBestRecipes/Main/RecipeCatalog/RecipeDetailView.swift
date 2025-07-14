//
//  RecipeDetailView.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//

import Foundation
//  RecipeDetailView.swift
import SwiftUI

struct RecipeDetailView: View {
    
    let recipe: Recipe
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // Верхнее изображение с кнопкой "назад"
                    HeaderImageView(imageName: recipe.id) {
                        dismiss()
                    }
                    
                    // Основной контент
                    VStack(alignment: .leading, spacing: 24) {
                        
                        Text(recipe.name)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.appPrimaryText)
                        
                        Text(recipe.description)
                            .font(.body)
                            .foregroundColor(.appSecondaryText)
                        
                        // Блок с временем и порциями
                        InfoBlockView(recipe: recipe)
                        
                        // Ингредиенты
                        SectionView(title: "Ingredients") {
                            ForEach(recipe.ingredients, id: \.self) { ingredient in
                                Text("• \(ingredient)")
                                    .foregroundColor(.appPrimaryText)
                            }
                        }
                        
                        // Шаги приготовления
                        SectionView(title: "Cooking steps") {
                            ForEach(recipe.cookingSteps.indices, id: \.self) { index in
                                StepView(index: index + 1, text: recipe.cookingSteps[index])
                            }
                        }
                        
                    }
                    .padding()
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
    }
}

// --- КОМПОНЕНТЫ ДЛЯ RecipeDetailView ---

struct HeaderImageView: View {
    let imageName: String
    var onBackButtonTapped: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Image(imageName)
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

struct InfoBlockView: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 20) {
            
            HStack {
                Image(systemName: "timer")
                Text(recipe.cookingTime)
                    .multilineTextAlignment(.center)
            }
            Spacer()
            Divider().background(Color.appSecondaryText).frame(height: 30)
            Spacer()
            
            HStack {
                Image(systemName: "person.2.fill")
                Text(recipe.servings)
                    .multilineTextAlignment(.center)
            }

            
        }
        .padding(.horizontal, 15)
        .font(.subheadline)
        .foregroundColor(.appAccent)
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
}

struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2).bold()
                .foregroundColor(.appPrimaryText)
            
            VStack(alignment: .leading, spacing: 8) {
                content
            }
        }
    }
}

struct StepView: View {
    let index: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text("\(index)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.appBackground)
                .padding(8)
                .background(Color.appAccent)
                .clipShape(Circle())
            
            Text(text)
                .foregroundColor(.appPrimaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RecipeDetailView(recipe: Recipe.mock)
    }
}
