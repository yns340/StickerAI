import SwiftUI

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
                // Görsel alanı
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
                
                // Alt butonlar
                VStack(spacing: geometry.size.height * 0.02) {
                    
                    HStack(spacing: geometry.size.height * 0.02) {
                        
                        // ✅ Save as Image butonu (animasyonlu)
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
                                            .scaleEffect(isIconSolo ? 2.0 : 1.0) // solo ise büyük, değilse küçük
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
                        
                        // ✅ Save as Sticker butonu
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
                    
                    // ✅ Delete butonu
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
                StickerSheetView()
                    .presentationDetents([.fraction(0.35)])
                    .presentationDragIndicator(.visible)
            }
        }
        .navigationTitle("Cartoon Result")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // 🎯 ANA FONKSİYON: Resmi kaydet
    func saveAsImage() {
        isSaving = true

        // 1️⃣ Önce tik animasyonu (her zaman)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showCheck = true
            }
        }

        // 2️⃣ Arka planda kayıt işlemi
        DispatchQueue.global(qos: .userInitiated).async {
            let success = DatabaseManager.shared.saveImage(cartoonImage, context: context)

            DispatchQueue.main.async {
                if success {
                    // 3️⃣ Başarılıysa: Tik gösterildikten sonra yazıyı sola kaydır
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation {
                            isSaving = false
                            isSaved = true
                        }
                    }
                } else {
                    // ❌ Başarısızsa: Her şeyi eski haline döndür
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
    @State private var selectedOption: OptionType? = nil
    @State private var packageName: String = ""
    
    enum OptionType {
        case createNew
        case addExisting
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                if selectedOption == nil {
                    // Ana menü görünümü
                    mainMenuView(geometry: geometry)
                } else if selectedOption == .createNew {
                    // Yeni paket oluşturma görünümü
                    createNewPackageView(geometry: geometry)
                } else if selectedOption == .addExisting {
                    // Mevcut pakete ekleme görünümü
                    addToExistingPackageView(geometry: geometry)
                }
            }
            .padding(.horizontal)
            .frame(height: geometry.size.height)
        }
    }
    
    // Ana menü görünümü
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
    
    // Yeni paket oluşturma görünümü
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

            // Scrollable içerik
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
                        
                        //trayİcon ekleme için alan
                    }
                    .padding(.horizontal)

                    Button(action: {
                        print("Creating new package: \(packageName)")
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


    
    // Mevcut pakete ekleme görünümü
    private func addToExistingPackageView(geometry: GeometryProxy) -> some View {
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
                
                Text("Save to Existing Package")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal)
            .frame(height: geometry.size.height * 0.1)
            
            // Scrollable içerik
            ScrollView {
                Text("No existing packages found.")
            }
            .frame(height: geometry.size.height * 0.6)
            .padding(.top, 10)
            
            Spacer()
        }
    }
}


#Preview {
    NavigationStack {
        CartoonImagePreviewView(cartoonImage: UIImage(systemName: "star.fill")!)
    }
}

