import 'package:cog_eci_frontend/features/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                context.go('/home');
              }

              if (state is AuthError) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            builder: (context, state) {
              final authBloc = context.read<AuthBloc>();
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: ShapeDecoration(
                          color: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                        child: const Icon(
                          Icons.camera,
                          size: 20,
                          color: AppColors.secondary,
                        ),
                      ),
                      Text(
                        "Voter OCR",
                        style: AppTextStyles.headingMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        spacing: 7,
                        children: [
                          Text("Login", style: AppTextStyles.headingLarge),
                          Text(
                            "Sign in to continue",
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  AppTextField(
                    label: "Username",
                    hint: "Enter your username",
                    controller: usernameController,
                  ),
                  const SizedBox(height: 15),
                  AppTextField(
                    label: "Password",
                    hint: "Enter your password",
                    isPassword: true,
                    controller: passwordController,
                  ),
                  const SizedBox(height: 35),
                  AppButton(
                    text: "Login",
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      authBloc.add(
                        LoginRequested(
                          usernameController.text,
                          passwordController.text,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
