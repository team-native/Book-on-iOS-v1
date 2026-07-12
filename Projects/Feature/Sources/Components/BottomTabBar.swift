import SwiftUI

public struct BottomTabBar: View {
    public enum Item: CaseIterable, Hashable { case home, ranking, library, my
        var title: String { ["홈", "랭킹", "도서실", "마이"][index] }
        var icon: String { ["house", "chart.bar", "rectangle.stack", "person"][index] }
        private var index: Int { switch self { case .home: 0; case .ranking: 1; case .library: 2; case .my: 3 } }
    }

    let selected: Item
    var scale: CGFloat = 1
    let action: (Item) -> Void

    public init(selected: Item, scale: CGFloat = 1, action: @escaping (Item) -> Void) {
        self.selected = selected
        self.scale = scale
        self.action = action
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Item.allCases, id: \.self) { item in
                Button { action(item) } label: {
                    VStack(spacing: 5 * scale) {
                        Image(systemName: item.icon).font(.system(size: 21 * scale, weight: item == selected ? .semibold : .regular))
                        Text(item.title).font(FeatureFontFamily.Pretendard.semiBold.swiftUIFont(size: 10 * scale))
                    }
                    .foregroundColor(item == selected ? FeatureAsset.Color.buttonColor.swiftUIColor : Color(red: 176/255, green: 176/255, blue: 181/255))
                    .frame(maxWidth: .infinity, minHeight: 59 * scale)
                }.buttonStyle(.plain)
            }
        }
        .padding(.top, 10 * scale)
        .background(Color(red: 254/255, green: 254/255, blue: 254/255))
        .overlay(alignment: .top) { Rectangle().fill(Color(red: 241/255, green: 241/255, blue: 240/255)).frame(height: 1) }
    }
}
