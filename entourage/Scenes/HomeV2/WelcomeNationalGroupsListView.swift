import SwiftUI

class WelcomeNationalGroupsViewModel: ObservableObject {
    @Published var groups: [Neighborhood] = []
    @Published var isLoading: Bool = true
    @Published var hasError: Bool = false

    func fetchGroups() {
        self.isLoading = true
        self.hasError = false

        NeighborhoodService.getNationalNeighborhoods { [weak self] fetchedGroups, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.hasError = true
                } else if let fetchedGroups = fetchedGroups {
                    self?.groups = fetchedGroups
                } else {
                    self?.hasError = true
                }
            }
        }
    }
}

struct WelcomeNationalGroupsListView: View {
    @StateObject var viewModel = WelcomeNationalGroupsViewModel()
    var onBack: (() -> Void)?
    var onGroupTapped: ((Neighborhood) -> Void)?
    var onGroupsTabRequested: (() -> Void)?

    @State private var joiningGroupId: Int? = nil
    @State private var hasJoinedAGroup: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 0) {
                // Back button - aligned to top left
                Button(action: {
                    if hasJoinedAGroup {
                        onGroupsTabRequested?()
                    } else {
                        onBack?()
                    }
                }) {
                    Image("back_arrow")
                        .renderingMode(.template)
                        .foregroundColor(.black)
                }
                .padding(.leading, 16)
                .padding(.top, 10)

                // Title - aligned to left, below back button
                Text("welcome_national_groups_title".localized)
                    .font(.custom("Quicksand-Bold", size: 18))
                    .foregroundColor(.black)
                    .padding(.horizontal, 5)
                    .padding(.top, 8)

                // Subtitle - aligned to left, below title
                Text("welcome_national_groups_subtitle".localized)
                    .font(.custom("NunitoSans-Regular", size: 15))
                    .foregroundColor(.black)
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
            }
            .padding(.bottom, 20)

            // Content
            if viewModel.isLoading {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                Spacer()
            } else if viewModel.groups.isEmpty || viewModel.hasError {
                Spacer()
                HStack {
                    Spacer()
                    Text("no_events_found".localized) // TODO: create a generic one or use existing
                        .font(.custom("NunitoSans-Regular", size: 16))
                        .foregroundColor(.black)
                    Spacer()
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.groups, id: \.uid) { group in
                            NationalGroupListCellWrap(
                                group: group,
                                isJoining: joiningGroupId == group.uid,
                                onJoinTapped: {
                                    toggleJoin(group: group)
                                }
                            )
                            .onTapGesture {
                                onGroupTapped?(group)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
        }
        .background(Color.white.ignoresSafeArea())
        .onAppear {
            viewModel.fetchGroups()
        }
    }

    private func toggleJoin(group: Neighborhood) {
        joiningGroupId = group.uid
        if group.isMember {
            NeighborhoodService.leaveNeighborhood(groupId: group.uid, userId: UserDefaults.currentUser?.sid ?? 0) { _, error in
                DispatchQueue.main.async {
                    self.joiningGroupId = nil
                    if error == nil {
                        if let index = viewModel.groups.firstIndex(where: { $0.uid == group.uid }) {
                            viewModel.groups[index].isMember = false
                        }
                    }
                }
            }
        } else {
            NeighborhoodService.joinNeighborhood(groupId: group.uid) { _, error in
                DispatchQueue.main.async {
                    self.joiningGroupId = nil
                    if error == nil {
                        if let index = viewModel.groups.firstIndex(where: { $0.uid == group.uid }) {
                            viewModel.groups[index].isMember = true
                            self.hasJoinedAGroup = true
                        }
                    }
                }
            }
        }
    }

    struct NationalGroupListCellWrap: View {
        let group: Neighborhood
        let isJoining: Bool
        let onJoinTapped: () -> Void

        var body: some View {
            HStack(alignment: .top, spacing: 12) {
                // Image
                if let urlString = group.image_url, !urlString.isEmpty, let url = URL(string: urlString) {
                    if #available(iOS 15.0, *) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image("ic_placeholder_group")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        }
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        Image("ic_placeholder_group")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                } else {
                    Image("ic_placeholder_group")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 64, height: 64)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.custom("Quicksand-Bold", size: 15))
                        .foregroundColor(.black)
                        .lineLimit(2)

                    let memberString = group.membersCount > 1 ? String(format: "neighborhood_main_page_members".localized, group.membersCount) : String(format: "neighborhood_main_page_member".localized, group.membersCount)
                    Text(memberString)
                        .font(.custom("NunitoSans-Light", size: 13))
                        .foregroundColor(Color("gris_112"))
                        .lineLimit(1)
                }
                .padding(.vertical, 4)

                Spacer(minLength: 8)

                Button(action: onJoinTapped) {
                    if isJoining {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(minWidth: 80, minHeight: 32)
                            .background(Color("orange_app").opacity(0.5))
                            .cornerRadius(16)
                    } else if group.isMember {
                        Text("welcome_national_groups_joined".localized)
                            .font(.custom("NunitoSans-Bold", size: 13))
                            .foregroundColor(Color("orange_app"))
                            .frame(minWidth: 80, minHeight: 32)
                            .background(Color("Beige"))
                            .cornerRadius(16)
                    } else {
                        Text("welcome_national_groups_join".localized)
                            .font(.custom("NunitoSans-Bold", size: 13))
                            .foregroundColor(.white)
                            .frame(minWidth: 80, minHeight: 32)
                            .background(Color("orange_app"))
                            .cornerRadius(16)
                    }
                }
                .padding(.top, 16)
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("orange_light_a50"), lineWidth: 1)
            )
        }
    }
}
