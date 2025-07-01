import SwiftUI

struct LibraryView: View {
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 15) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Images")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        let spacing: CGFloat = 15
                        let horizontalPadding: CGFloat = 15
                        let totalSpacing = spacing + (horizontalPadding * 2)
                        let itemWidth = (geometry.size.width - totalSpacing) / 2
                        
                        ScrollView {
                            LazyVGrid(columns: [
                                GridItem(.fixed(itemWidth), spacing: spacing),
                                GridItem(.fixed(itemWidth), spacing: spacing)
                            ], spacing: spacing) {
                                ForEach(0..<10, id: \.self) { index in
                                    Rectangle()
                                        .fill(Color.yellow)
                                        .frame(width: itemWidth, height: itemWidth)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.black, lineWidth: 4)
                                        )
                                        .cornerRadius(8)
                                        .contextMenu {
                                                Button {
                                                    //Kaydetme
                                                    print("Galeriye kaydedildi")
                                                } label: {
                                                    Label("Galeriye Kaydet", systemImage: "square.and.arrow.down")
                                                }

                                                Button {
                                                    // Paylaşma işlemi
                                                    print("Paylaşıldı")
                                                } label: {
                                                    Label("Paylaş", systemImage: "square.and.arrow.up")
                                                }
                                            }
                                }
                            }
                            .padding(.horizontal, horizontalPadding)
                        }
                    }
                    .frame(height: geometry.size.height / 2)
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.black)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("StickerPacks")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(0..<6, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.purple.opacity(0.2))
                                        .frame(height: geometry.size.height * 0.13)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.black, lineWidth: 2)
                                        )
                                }
                            }
                            .padding(.horizontal, 15)
                        }
                    }
                    .frame(height: geometry.size.height / 2)
                }
                .navigationTitle("Library")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    LibraryView()
}
