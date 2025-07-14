//
//  MasterpiecesView.swift
//  MyBestRecipes
//
//  Created by D K on 10.07.2025.
//


import SwiftUI
import RealmSwift

#Preview {
    MasterpiecesView()
}

struct MasterpiecesView: View {
    @Environment(\.dismiss) var dismiss
    // Автоматически обновляемый запрос к Realm, отсортированный по дате
    @ObservedResults(Masterpiece.self, sortDescriptor: SortDescriptor(keyPath: "createdAt", ascending: false)) var masterpieces

    // Состояния для отображения модальных окон
    @State private var isShowingImagePicker = false
    @State private var isShowingCameraPicker = false
    @State private var selectedImage: UIImage?
    @State private var showAddSheet = false

    // Колонки для адаптивной сетки
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.appBackground.ignoresSafeArea()
                
                if masterpieces.isEmpty {
                    MasterpieceEmptyStateView {
                        showAddSheet = true
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(masterpieces) { masterpiece in
                                MasterpieceCardView(masterpiece: masterpiece)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Masterpieces")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                    .foregroundColor(.appAccent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddSheet = true }) {
                        Image(systemName: "plus")
                    }
                    .foregroundColor(.appAccent)
                }
            }
            .confirmationDialog("Add photo", isPresented: $showAddSheet, titleVisibility: .visible) {
                Button("Take a photo") {
                    isShowingCameraPicker = true
                }
                Button("Select from gallery") {
                    isShowingImagePicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $isShowingImagePicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $isShowingCameraPicker) {
                ImagePicker(selectedImage: $selectedImage, sourceType: .camera)
            }
            .onChange(of: selectedImage) { newImage in
                // Когда изображение выбрано (с камеры или из галереи), сохраняем его
                guard let image = newImage,
                      let imageData = image.jpegData(compressionQuality: 0.8) else { return }
                
                // Здесь можно добавить поле для ввода подписи, но для простоты пока оставим пустым
                StorageManager.shared.addMasterpiece(imageData: imageData, caption: "")
            }
        }
        .preferredColorScheme(.dark)
        .tint(.white)
    }
}

struct MasterpieceCardView: View {
    @ObservedRealmObject var masterpiece: Masterpiece
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let uiImage = UIImage(data: masterpiece.imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .aspectRatio(1, contentMode: .fill) // Делает карточку квадратной
                    .clipped()
            }
            
            // Кнопка удаления
            Button(role: .destructive) {
                StorageManager.shared.deleteMasterpiece(id: masterpiece.id)
            } label: {
                Image(systemName: "trash.fill")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.black.opacity(0.5))
                    .clipShape(Circle())
            }
            .padding(8)
        }
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.2), radius: 5, y: 2)
    }
}

struct MasterpieceEmptyStateView: View {
    var onAddButtonTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 80))
                .foregroundColor(.appSecondaryText)
            Text("Your gallery is empty")
                .font(.title2.bold())
                .foregroundColor(.appPrimaryText)
            Text("Add photos of your best dishes so you don't forget them!")
                .font(.body)
                .foregroundColor(.appSecondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: onAddButtonTapped) {
                Label("Add a masterpiece", systemImage: "plus")
                    .fontWeight(.bold)
            }
            .padding()
            .background(Color.appAccent)
            .foregroundColor(.black)
            .cornerRadius(12)
            .padding(.top)
        }
    }
}

//  ImagePicker.swift
import SwiftUI

// UIKit обертка для доступа к камере и галерее
struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var selectedImage: UIImage?
    var sourceType: UIImagePickerController.SourceType
    
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
