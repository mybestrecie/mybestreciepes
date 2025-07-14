//
//  HomeView.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//


import SwiftUI

// --- МОДЕЛИ ДАННЫХ (Временные, для отображения) ---

// Модель для кнопок быстрых действий
struct QuickActionItem: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
}

// Модель для достижений
struct Achievement: Identifiable {
    let id = UUID()
    let title: String
    let iconName: String
    var isUnlocked: Bool
}

// --- ОСНОВНОЙ ЭКРАН ---

struct HomeView: View {
    
    // Временные данные для демонстрации
    private let quickActions: [QuickActionItem] = [
        .init(title: "Shopping list", iconName: "cart.fill"),
        .init(title: "Masterpieces", iconName: "photo.on.rectangle.angled"),
        .init(title: "Cooking Tips", iconName: "book.closed.fill"),
        .init(title: "Timer", iconName: "timer")
    ]
    
    private let achievements: [Achievement] = [
        .init(title: "Sushef", iconName: "star.fill", isUnlocked: false),
        .init(title: "AI Enjoyer", iconName: "flame.fill", isUnlocked: false),
        .init(title: "Real Chef", iconName: "rosette", isUnlocked: false),
        .init(title: "Confectioner", iconName: "birthday.cake.fill", isUnlocked: false),
        .init(title: "Visionary", iconName: "camera.fill", isUnlocked: false)
    ]
    
    
    
    
    var body: some View {
        NavigationView {
            ZStack {
                // Устанавливаем фон на весь экран
                Color.appBackground.ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Заголовок
                        HeaderView()
                        
                        // Горизонтальный список быстрых действий
                        QuickActionsView(actions: quickActions)
                        
                        // Секция "Рецепт дня"
                        RecipeOfTheDayView()
                        
                        // Секция "Достижения"
                        AchievementsView(achievements: achievements)
                            .padding(.bottom, 150)
                        
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true) // Скрываем стандартный NavigationBar
        }
        .preferredColorScheme(.dark) // Принудительно темная тема для системных элементов
    }
}

// --- КОМПОНЕНТЫ ЭКРАНА ---

// Верхний заголовок
struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Hello,")
                .font(.largeTitle)
                .foregroundColor(.appSecondaryText)
            Text("Chef!")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.appPrimaryText)
        }
    }
}


// Компонент для кнопок быстрых действий
struct QuickActionsView: View {
    let actions: [QuickActionItem]
    
    @State private var isshopinglistpresented: Bool = false
    @State private var ismasterpiecespresented: Bool = false
    @State private var iscookingtipspresented: Bool = false
    @State private var istimerapresented: Bool = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(actions) { action in
                    Button {
                        switch action.title {
                        case "Shopping list": isshopinglistpresented.toggle()
                        case "Masterpieces": ismasterpiecespresented.toggle()
                        case "Cooking Tips": iscookingtipspresented.toggle()
                        case "Timer": istimerapresented.toggle()
                        default:
                            break
                        }
                    } label: {
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color.appCardBackground)
                                    .frame(width: 64, height: 64)
                                    .shadow(color: .black.opacity(0.2), radius: 5, y: 3)
                                
                                Image(systemName: action.iconName)
                                    .font(.title2)
                                    .foregroundColor(.appAccent)
                            }
                            Text(action.title)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.appPrimaryText)
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .fullScreenCover(isPresented: $isshopinglistpresented) {
            ShoppingListView()
        }
        .fullScreenCover(isPresented: $ismasterpiecespresented) {
            MasterpiecesView()
        }
        .fullScreenCover(isPresented: $iscookingtipspresented) {
            CookbookView()
        }
        .fullScreenCover(isPresented: $istimerapresented) {
            TimerView()
        }
    }
}

// Компонент для карточки "Рецепт дня"
struct RecipeOfTheDayView: View {
    
    @State private var isShown = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Recipe of the day")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.appPrimaryText)
            
            ZStack {
                Image("19")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        // Градиент для затемнения нижней части картинки
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                            startPoint: .center,
                            endPoint: .bottom)
                    )
                
                // Текст поверх картинки
                VStack {
                    Spacer()
                    HStack {
                        Text("Vanilla Bean Pudding")
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                        
                        Spacer()
                    }
                   
                }
                .padding(10)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
        }
        .onTapGesture {
            isShown.toggle()
        }
        .fullScreenCover(isPresented: $isShown) {
            RecipeDetailView(
                recipe:
                    Recipe(
                        id: "19",
                        name: "Vanilla Bean Pudding",
                        image: "",
                        description: "Smooth and creamy, this Vanilla Bean Pudding is infused with real vanilla bean for a rich and flavorful dessert that’s both comforting and elegant.",
                        cookingTime: "20 minutes plus chilling",
                        servings: "4 servings",
                        ingredients: [
                "Milk 500ml",
                "Vanilla bean 1",
                "Sugar 100g",
                "Cornstarch 40g",
                "Egg yolks 3",
                "Whipped cream for topping"
            ],
                        cookingSteps: [
                "Step 1: In a saucepan, heat milk and vanilla bean seeds until simmering.",
                "Step 2: In a bowl, whisk sugar, cornstarch, and egg yolks until smooth.",
                "Step 3: Gradually add hot milk to the egg mixture, then return to the saucepan.",
                "Step 4: Cook over medium heat, stirring, until thickened. StartTimer",
                "Step 5: Pour into serving dishes, cover with plastic wrap, and refrigerate for 2 hours. StartTimer",
                "Step 6: Top with whipped cream before serving."
            ],
                        category: "cake"))
        }
    }
}

// Компонент для отображения достижений
struct AchievementsView: View {
    let achievements: [Achievement]
    @State private var isAlertShown = false
    @State private var alertText = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Achievements")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.appPrimaryText)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(achievements) { achievement in
                        Button {
                            showAlert(for: achievement)
                        } label: {
                            VStack {
                                ZStack {
                                    Circle()
                                        .stroke(achievement.isUnlocked ? Color.appAccent : Color.appSecondaryText, lineWidth: 3)
                                        .frame(width: 60, height: 70)
                                    
                                    Image(systemName: achievement.iconName)
                                        .font(.title)
                                        .foregroundColor(achievement.isUnlocked ? .appAccent : .appSecondaryText)
                                }
                                .opacity(achievement.isUnlocked ? 1.0 : 0.5) // Делаем неразблокированные тусклее
                                
                                Text(achievement.title)
                                    .font(.caption)
                                    .foregroundColor(achievement.isUnlocked ? .appPrimaryText : .appSecondaryText)
                            }
                        }
                        
                    }
                }
                .padding(.leading, 10)
            }
        }
        .alert(alertText, isPresented: $isAlertShown) {
            Button {
                
            } label: {
                Text("Ok")
            }
        }
    }
    
    
    func showAlert(for achievement: Achievement) {
        switch achievement.title {
        case "Sushef": alertText = "To unlock this achievement add 20 of your Recipes."
        case "AI Enjoyer": alertText = "To unlock this achievement generate 30 Recipes."
        case "Real Chef": alertText = "To unlock this achievement learn all Cooking Tips."
        case "Confectioner": alertText = "To unlock this achievement learn 25 Baking Recipes."
        case "Visionary": alertText = "To unlock this achievement save 25 your Masterpieces."
        default:
            break
        }
        
        isAlertShown.toggle()
    }
}


// --- PREVIEW ---
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
