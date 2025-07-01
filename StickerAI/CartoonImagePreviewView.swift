import SwiftUI

struct CartoonImagePreviewView: View {
    let cartoonImage: UIImage
    @Environment(\.dismiss) private var dismiss
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
    
    func saveAsImage() {
        isSaving = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                showCheck = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                isSaving = false
                isSaved = true
            }
        }
    }
}

struct StickerSheetView: View {

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 15) {
                Spacer() // Üstte boşluk

                Text("Choose an option")
                    .font(.title2)
                    .fontWeight(.semibold)

                Button (action: {
                    //ACTION
                }){
                    Text("Save to Existing Package")
                        .frame(maxWidth: .infinity)
                        .frame(height: geometry.size.height * 0.3)
                        .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(geometry.size.width * 0.06)
                }
                
                Button(action: {
                    // ACTION
                }) {
                    Text("Create New Package")
                        .foregroundColor(.white)
                        .font(.system(size: geometry.size.width * 0.045, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .frame(height: geometry.size.height * 0.3)
                        .background(Color.green)
                        .cornerRadius(geometry.size.width * 0.06)
                }


                Spacer() // Altta boşluk
            }
            .padding(.horizontal)
            // Tam sheet yüksekliği kadar yer kapla
            .frame(height: geometry.size.height)
        }
    }
}

#Preview {
    NavigationStack {
        CartoonImagePreviewView(cartoonImage: UIImage(systemName: "star.fill")!)
    }
}
