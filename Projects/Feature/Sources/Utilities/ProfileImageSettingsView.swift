import PhotosUI
import SwiftUI

struct ProfileImageSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var selectedImageData: Data?
    @State private var localError: String?

    let profileImagePath: String?
    let isSubmitting: Bool
    let errorMessage: String?
    let onUpload: (Data, String) async -> Bool
    let onDelete: () async -> Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                ZStack {
                    if let selectedImage {
                        Image(uiImage: selectedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 132, height: 132)
                            .clipShape(Circle())
                    } else {
                        ProfileAvatar(size: 132, imagePath: profileImagePath)
                    }
                }
                .padding(.top, 28)

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    Label("사진 보관함에서 선택", systemImage: "photo.on.rectangle")
                        .font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 15))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                }
                .buttonStyle(.bordered)
                .tint(FeatureAsset.Color.buttonColor.swiftUIColor)

                if let message = localError ?? errorMessage {
                    Text(message)
                        .font(FeatureFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    guard let selectedImageData else { return }
                    Task {
                        if await onUpload(selectedImageData, "image/jpeg") {
                            dismiss()
                        }
                    }
                } label: {
                    Group {
                        if isSubmitting {
                            ProgressView().tint(.white)
                        } else {
                            Text("저장하기")
                        }
                    }
                    .font(FeatureFontFamily.Pretendard.bold.swiftUIFont(size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        selectedImageData == nil
                            ? Color.gray.opacity(0.35)
                            : FeatureAsset.Color.buttonColor.swiftUIColor
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                .disabled(selectedImageData == nil || isSubmitting)

                if profileImagePath != nil {
                    Button("기본 이미지로 변경", role: .destructive) {
                        Task {
                            if await onDelete() {
                                dismiss()
                            }
                        }
                    }
                    .disabled(isSubmitting)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationTitle("프로필 사진")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                        .disabled(isSubmitting)
                }
            }
            .onChange(of: selectedItem) { item in
                guard let item else { return }
                Task { await loadImage(from: item) }
            }
        }
    }

    @MainActor
    private func loadImage(from item: PhotosPickerItem) async {
        localError = nil
        guard let originalData = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: originalData),
              let jpegData = image.jpegData(compressionQuality: 0.82)
        else {
            localError = "선택한 이미지를 불러오지 못했습니다."
            return
        }

        selectedImage = image
        selectedImageData = jpegData
    }
}
