import SwiftUI
import SwiftData

// Küçük toast görünümü (isteğe bağlı, butonsuz kısa bildirim için)
struct ToastView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.black.opacity(0.8))
            .cornerRadius(10)
            .shadow(radius: 4)
            .padding(.top, 40)
    }
}

struct CartoonImagePreviewView: View {
    let cartoonImage: UIImage
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context // 🎯 Database context
    @State private var isSaving = false
    @State private var isSaved = false
    @State private var showCheck = false
    @State private var showStickerSheet = false
    
    var isIconSolo: Bool {
        (isSaving || isSaved) && !isSaved
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                VStack {
                    Spacer()
                    Image(uiImage: cartoonImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            maxWidth: geometry.size.width * 0.8,
                            maxHeight: geometry.size.height * 0.5
                        )
                        .cornerRadius(geometry.size.width * 0.04)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                
                VStack(spacing: geometry.size.height * 0.02) {
                    HStack(spacing: geometry.size.height * 0.02) {
                        Button(action: {
                            saveAsImage()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: geometry.size.width * 0.06)
                                    .fill(isSaving || isSaved ? Color.black : Color.blue)

                                HStack(spacing: 15) {
                                    if isSaving || isSaved {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .scaleEffect(isIconSolo ? 2.0 : 1.0)
                                            .opacity(showCheck ? 1.0 : 0.0)
                                            .animation(.easeInOut(duration: 0.3), value: isSaved)
                                            .animation(.easeOut(duration: 0.3), value: showCheck)
                                    }
                                    
                                    if isSaved {
                                        Text("Saved to Library")
                                            .foregroundColor(.white)
                                            .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                                            .transition(.scale.combined(with: .opacity))
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: isSaved ? .leading : .center)
                                .padding(.horizontal, isSaved ? 20 : 0)
                                .animation(.easeInOut(duration: 0.3), value: isSaved)
                                
                                if !isSaving && !isSaved {
                                    Text("Save as Image")
                                        .foregroundColor(.white)
                                        .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                                }
                            }
                        }
                        .disabled(isSaving || isSaved)
                        .frame(maxWidth: .infinity)
                        .frame(height: geometry.size.height * 0.095)
                        .cornerRadius(geometry.size.width * 0.06)
                        
                        Button(action: {
                            showStickerSheet = true
                        }) {
                            Text("Save as Sticker")
                                .foregroundColor(.white)
                                .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: geometry.size.height * 0.095)
                                .background(Color.green)
                                .cornerRadius(geometry.size.width * 0.06)
                        }
                    }
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Delete")
                            .foregroundColor(.red)
                            .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: geometry.size.height * 0.095)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(geometry.size.width * 0.06)
                    }
                }
                .padding(.horizontal, geometry.size.width * 0.07)
                .padding(.bottom, geometry.size.height * 0.07)
            }
            .sheet(isPresented: $showStickerSheet) {
                StickerSheetView(cartoonImage: cartoonImage)
                    .presentationDetents([.fraction(0.35)])
                    .presentationDragIndicator(.visible)
            }
        }
        .navigationTitle("Cartoon Result")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func saveAsImage() {
        isSaving = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showCheck = true
            }
        }

        DispatchQueue.global(qos: .userInitiated).async {
            let success = DatabaseManager.shared.saveImage(cartoonImage, context: context)

            DispatchQueue.main.async {
                if success {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation {
                            isSaving = false
                            isSaved = true
                        }
                    }
                } else {
                    withAnimation {
                        isSaving = false
                        showCheck = false
                    }
                }
            }
        }
    }
}

struct StickerSheetView: View {
    let cartoonImage: UIImage
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedOption: OptionType? = nil
    @State private var packageName: String = ""
    
    // Toast göstermek için
    @State private var showToast = false
    @State private var toastMessage = ""
    
    @Query(sort: \StickerPackEntity.name, order: .forward)
    private var stickerPacks: [StickerPackEntity]

    enum OptionType {
        case createNew
        case addExisting
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if selectedOption == nil {
                    mainMenuView(geometry: geometry)
                } else if selectedOption == .createNew {
                    createNewPackageView(geometry: geometry)
                } else if selectedOption == .addExisting {
                    addToExistingPackageView(geometry: geometry)
                }
            }
            .padding(.horizontal)
            .frame(height: geometry.size.height)
            // Toast overlay
            .overlay(
                Group {
                    if showToast {
                        ToastView(message: toastMessage)
                            .transition(.opacity)
                    }
                },
                alignment: .top
            )
            .onChange(of: showToast) { visible in
                if visible {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showToast = false
                        }
                    }
                }
            }
        }
    }
    
    private func mainMenuView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 15) {
            Spacer()
            Text("Choose an option")
                .font(.title2)
                .fontWeight(.semibold)
            
            Button(action: {
                selectedOption = .addExisting
            }) {
                Text("Save to Existing Package")
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * 0.3)
                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(geometry.size.width * 0.06)
            }
            
            Button(action: {
                selectedOption = .createNew
            }) {
                Text("Create New Package")
                    .foregroundColor(.white)
                    .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .frame(height: geometry.size.height * 0.3)
                    .background(Color.green)
                    .cornerRadius(geometry.size.width * 0.06)
            }
            Spacer()
        }
    }
    
    private func createNewPackageView(geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {
                    selectedOption = nil
                    packageName = ""
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                Spacer()
                Text("Create New Package")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: geometry.size.height * 0.1)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Package Name")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        TextField("Enter package name", text: $packageName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: geometry.size.width * 0.065))
                            .frame(height: geometry.size.height * 0.15)
                        
                        Spacer()
                        
                        Text("Package Icon")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        // Tray icon alanı eklenebilir
                    }
                    .padding(.horizontal)

                    Button(action: {
                        addNewPackageAndSticker()
                    }) {
                        Text("Create Sticker Pack & Add Sticker")
                            .foregroundColor(.white)
                            .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: geometry.size.height * 0.3)
                            .background(packageName.isEmpty ? Color.gray : Color.green)
                            .cornerRadius(geometry.size.width * 0.06)
                    }
                    .disabled(packageName.isEmpty)
                    .padding(.horizontal)
                }
            }
            .frame(height: geometry.size.height * 0.6)
            .padding(.top, 10)
            
            Spacer()
        }
    }
    
    private func addToExistingPackageView(geometry: GeometryProxy) -> some View {
        VStack {
            Spacer(minLength: 10)
            HStack {
                Button(action: {
                    selectedOption = nil
                    packageName = ""
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                Spacer()
                Text("Save to Existing Package")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: geometry.size.height * 0.1)
            
            ScrollView {
                if stickerPacks.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "square.stack.3d.down.forward")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No sticker packs yet")
                            .font(.title3)
                            .foregroundColor(.gray)
                        Text("Create a new pack first.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 50)
                } else {
                    VStack(spacing: 15) {
                        ForEach(stickerPacks, id: \.id) { pack in
                            Button {
                                addStickerTo(pack: pack)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(pack.name)
                                        .font(.headline)
                                        .padding(.leading, 10)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 10) {
                                            ForEach(pack.stickers, id: \.id) { sticker in
                                                if let uiImage = DatabaseManager.shared.loadImageFromPath(sticker.imagePath) {
                                                    Image(uiImage: uiImage)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 60, height: 60)
                                                        .cornerRadius(8)
                                                        .shadow(radius: 2)
                                                } else {
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(Color.gray.opacity(0.3))
                                                        .frame(width: 60, height: 60)
                                                }
                                            }
                                        }
                                        .padding(.horizontal, 10)
                                    }
                                }
                                .padding(.vertical, 5)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .frame(height: geometry.size.height * 0.7)
            Spacer()
        }
    }
    
    private func addStickerTo(pack: StickerPackEntity) {
        guard let sticker = DatabaseManager.shared.saveStickerAndReturn(from: cartoonImage, context: context) else {
            print("Sticker kaydedilemedi.")
            return
        }

        sticker.pack = pack
        pack.stickers.append(sticker)
        
        do {
            try context.save()
            toastMessage = "Sticker başarıyla \"\(pack.name)\" paketine eklendi."
            withAnimation {
                showToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
            }
        } catch {
            print("Hata: \(error)")
        }
    }
    
    private func addNewPackageAndSticker() {
        guard let savedSticker = DatabaseManager.shared.saveStickerAndReturn(from: cartoonImage, context: context) else {
            print("Sticker kaydedilemedi.")
            return
        }
        
        let newPack = StickerPackEntity(
            identifier: UUID().uuidString,
            name: packageName,
            publisher: "StickerAI",
            trayImagePath: savedSticker.imagePath
        )
        
        savedSticker.pack = newPack
        newPack.stickers.append(savedSticker)
        
        context.insert(newPack)
        
        do {
            try context.save()
            toastMessage = "Yeni paket \"\(packageName)\" oluşturuldu ve sticker eklendi."
            withAnimation {
                showToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
            }
        } catch {
            print("Paket kaydedilirken hata oluştu: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        CartoonImagePreviewView(cartoonImage: UIImage(systemName: "star.fill")!)
    }
}
