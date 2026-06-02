import SwiftUI

struct FlashcardView: View {
    @State private var viewModel: GlossaryViewModel
    @Environment(\.dismiss) private var dismiss

    init(viewModel: GlossaryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 24) {
            // Controls
            HStack {
                Button("关闭") { dismiss() }
                    .accessibilityLabel("关闭")
                Spacer()
                Text("\(viewModel.currentIndex + 1)/\(viewModel.activeTerms.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    viewModel.showHighFrequencyOnly.toggle()
                } label: {
                    Image(systemName: viewModel.showHighFrequencyOnly ? "star.fill" : "star")
                        .foregroundStyle(viewModel.showHighFrequencyOnly ? .yellow : .secondary)
                }
                .accessibilityLabel(viewModel.showHighFrequencyOnly ? "显示全部术语" : "仅显示高频术语")
            }
            .padding(.horizontal)

            // Card
            if let term = viewModel.currentTerm {
                Spacer()

                ZStack {
                    // Front
                    frontCard(term)
                        .opacity(viewModel.isFlipped ? 0 : 1)
                        .rotation3DEffect(.degrees(viewModel.isFlipped ? -90 : 0), axis: (x: 0, y: 1, z: 0))

                    // Back
                    backCard(term)
                        .opacity(viewModel.isFlipped ? 1 : 0)
                        .rotation3DEffect(.degrees(viewModel.isFlipped ? 0 : 90), axis: (x: 0, y: 1, z: 0))
                }
                .animation(.easeInOut(duration: 0.4), value: viewModel.isFlipped)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.4)) { viewModel.flip() }
                }
                .accessibilityAction {
                    withAnimation(.easeInOut(duration: 0.4)) { viewModel.flip() }
                }

                Spacer()

                // Navigation buttons
                HStack(spacing: 40) {
                    Button {
                        viewModel.previous()
                    } label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(viewModel.canGoBack ? .blue : .gray.opacity(0.3))
                    }
                    .disabled(!viewModel.canGoBack)
                    .accessibilityLabel("上一张")

                    Button {
                        viewModel.shuffle()
                    } label: {
                        Image(systemName: "shuffle.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.orange)
                    }
                    .accessibilityLabel("随机打乱")

                    Button {
                        viewModel.next()
                    } label: {
                        Image(systemName: "chevron.right.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(viewModel.canGoForward ? .blue : .gray.opacity(0.3))
                    }
                    .disabled(!viewModel.canGoForward)
                    .accessibilityLabel("下一张")
                }
                .padding(.bottom, 40)
            } else {
                ContentUnavailableView(
                    "没有术语卡片",
                    systemImage: "text.book.closed"
                )
            }
        }
        .background(Color(.systemGroupedBackground))
    }

    @ViewBuilder
    private func frontCard(_ term: GlossaryTerm) -> some View {
        VStack(spacing: 16) {
            if term.isHighFrequency {
                HStack {
                    Spacer()
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                    Text("高频")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Text(term.english)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)

            Text("点击翻转")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .adaptiveShadow(radius: 12, y: 4)
        .padding(.horizontal, 24)
    }

    @ViewBuilder
    private func backCard(_ term: GlossaryTerm) -> some View {
        VStack(spacing: 16) {
            Text(term.chinese)
                .font(.title2)
                .bold()

            Divider()
                .padding(.horizontal, 40)

            Text(term.explanation.display)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Text("点击翻转")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .adaptiveShadow(radius: 12, y: 4)
        .padding(.horizontal, 24)
    }
}
