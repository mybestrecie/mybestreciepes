//
//  AddMyRecipeView.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//


import SwiftUI
import PhotosUI

#Preview {
    AddMyRecipeView()
}

struct AddMyRecipeView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var description: String = ""
    @State private var ingredients: [EditableItem] = [EditableItem(text: "")]
    @State private var steps: [EditableItem] = [EditableItem(text: "")]

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var selectedImageData: Data?

    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                Form {
                    Section(header: Text("Image").foregroundColor(.appSecondaryText)) { imagePickerView }
                    Section(header: Text("Basic information").foregroundColor(.appSecondaryText)) {
                        TextField("Recipe name", text: $name)
                        TextField("Brief description", text: $description, axis: .vertical).lineLimit(3...)
                    }
                    Section(header: ingredientsHeader) {
                        ForEach($ingredients) { $item in // Теперь не нужен id: \.self, так как EditableItem уже Identifiable
                            TextField("New ingredient", text: $item.text)
                        }.onDelete { ingredients.remove(atOffsets: $0) }
                    }
                    Section(header: stepsHeader) {
                        ForEach($steps) { $item in
                            TextField("New step", text: $item.text, axis: .vertical).lineLimit(2...)
                        }.onDelete { steps.remove(atOffsets: $0) }
                    }
                }.scrollContentBackground(.hidden)
            }
            .navigationTitle("New recipe").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() }.foregroundColor(.appAccent) }
                ToolbarItem(placement: .navigationBarTrailing) { Button("Save") { saveRecipe() }.bold().foregroundColor(.appAccent) }
            }
        }.preferredColorScheme(.dark).tint(.appAccent)
    }

    private var imagePickerView: some View {
            PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
                VStack {
                    if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.appCardBackground)
                                .frame(height: 150)
                            
                            VStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle.angled")
                                Text("Click to select photo")
                            }
                            .foregroundColor(.appSecondaryText)
                            .font(.headline)
                        }
                    }
                }
            }
            .onChange(of: selectedPhoto) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        selectedImageData = data
                    }
                }
            }
        }
        
        // Заголовок для секции ингредиентов с кнопкой "+"
    private var ingredientsHeader: some View {
        HStack {
            Text("Ingredients")
            Spacer()
            Button(action: { ingredients.append(EditableItem(text: "")) }) { // <-- здесь
                Image(systemName: "plus")
            }
        }
        .foregroundColor(.appSecondaryText)
    }
        
        // Заголовок для секции шагов с кнопкой "+"
    private var stepsHeader: some View {
        HStack {
            Text("Cooking steps")
            Spacer()
            Button(action: { steps.append(EditableItem(text: "")) }) { // <-- здесь
                Image(systemName: "plus")
            }
        }
        .foregroundColor(.appSecondaryText)
    }
    // НОВАЯ ФУНКЦИЯ СОХРАНЕНИЯ ДЛЯ REALM
    private func saveRecipe() {
        let finalIngredients = ingredients.map { $0.text }.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
          let finalSteps = steps.map { $0.text }.filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        
        guard !name.isEmpty, let imageData = selectedImageData else {
            // Здесь можно показать алерт, что имя и фото обязательны
            return
        }
        
        StorageManager.shared.addNewRecipe(
            name: name,
            description: description,
            ingredients: finalIngredients,
            steps: finalSteps,
            data: imageData
        )
        
        dismiss()
    }
}

struct EditableItem: Identifiable {
    let id = UUID()
    var text: String
}
