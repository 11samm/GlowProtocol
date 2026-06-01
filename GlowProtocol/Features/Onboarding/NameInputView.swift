//
//  NameInputView.swift
//  GlowProtocol
//
//  Step 2 — collect the user's name. Every later screen personalizes with it.
//

import SwiftUI

struct NameInputView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onBack: () -> Void
    let onContinue: () -> Void

    @FocusState private var fieldFocused: Bool

    var body: some View {
        ZStack {
            Color.glowBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                navBar

                VStack(alignment: .leading, spacing: GlowSpacing.s24) {
                    Spacer().frame(height: GlowSpacing.s32)

                    Text("What's your name?")
                        .font(.glowSerif(size: 36, weight: .bold, italic: true))
                        .foregroundStyle(Color.glowTextPrimary)

                    VStack(alignment: .leading, spacing: GlowSpacing.s12) {
                        TextField("", text: $viewModel.userName, prompt:
                            Text("Your name")
                                .foregroundStyle(Color.glowTextDisabled)
                        )
                        .font(.glowSans(size: 24, weight: .regular))
                        .foregroundStyle(Color.glowTextPrimary)
                        .focused($fieldFocused)
                        .textInputAutocapitalization(.words)
                        .submitLabel(.done)
                        .onSubmit { if viewModel.canContinueFromName { onContinue() } }
                        .onChange(of: viewModel.userName) { _, newValue in
                            if newValue.count > 20 {
                                viewModel.userName = String(newValue.prefix(20))
                            }
                        }

                        Rectangle()
                            .fill(fieldFocused ? Color.glowTextPrimary : Color.glowDivider)
                            .frame(height: 1.5)
                            .animation(.easeInOut(duration: 0.2), value: fieldFocused)
                    }

                    Text("We'll use it to personalize your protocol.")
                        .glowText(.body)
                        .foregroundStyle(Color.glowTextSecondary)

                    Spacer()

                    GlowButton(title: "Continue", enabled: viewModel.canContinueFromName) {
                        onContinue()
                    }
                    .padding(.bottom, GlowSpacing.s24)
                }
                .padding(.horizontal, GlowSpacing.s24)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { fieldFocused = true }
        }
    }

    private var navBar: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.glowTextPrimary)
                    .frame(width: 44, height: 44)
            }
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, GlowSpacing.s4)
    }
}
