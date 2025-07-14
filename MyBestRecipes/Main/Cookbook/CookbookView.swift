//
//  CookbookView.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//

import Foundation
//  CookbookView.swift
import SwiftUI

struct CookbookView: View {
    // Загружаем советы один раз при создании View
    @Environment(\.dismiss) var dismiss

    private let tips: [CookingTip] = Bundle.main.decode("cooking_tips.json")
    
    // Это состояние будет хранить выбранный совет для показа в popup
    @State private var selectedTip: CookingTip?

    var body: some View {
        NavigationView {
            // ZStack - ключ к созданию нашего кастомного popup
            ZStack {
                // Нижний слой: фон и список
                Color.appBackground.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(tips) { tip in
                            TipRowView(tip: tip)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        selectedTip = tip
                                    }
                                }
                        }
                    }
                    .padding()
                }
                
                // Верхний слой: затемняющий фон и сам popup
                if let tip = selectedTip {
                    // Затемняющий фон
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture { dismissPopup() }
                    
                    // Наше кастомное всплывающее окно
                    TipDetailPopupView(tip: tip, onClose: dismissPopup)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("Cook's textbook")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                    .foregroundColor(.appAccent)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func dismissPopup() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            selectedTip = nil
        }
    }
}

// --- Компоненты для CookbookView ---

struct TipRowView: View {
    let tip: CookingTip
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.headline)
                    .foregroundColor(.appPrimaryText)
                
                Text(tip.shortDescription)
                    .font(.subheadline)
                    .foregroundColor(.appSecondaryText)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.appSecondaryText)
        }
        .padding()
        .background(Color.appCardBackground)
        .cornerRadius(12)
    }
}


struct TipDetailPopupView: View {
    let tip: CookingTip
    let onClose: () -> Void // Замыкание для закрытия

    var body: some View {
        VStack(spacing: 16) {
            // Заголовок с кнопкой закрытия
            HStack {
                Text(tip.title)
                    .font(.title2.bold())
                    .foregroundColor(.appPrimaryText)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.appSecondaryText)
                }
            }
            
            Divider().background(Color.appSecondaryText)
            
            // ScrollView для длинного описания
            ScrollView {
                Text(tip.longDescription)
                    .font(.body)
                    .foregroundColor(.appPrimaryText)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height * 0.6)
        .background(Color.appCardBackground)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20) // Отступы от краев экрана
    }
}


struct CookbookView_Previews: PreviewProvider {
    static var previews: some View {
        CookbookView()
    }
}
