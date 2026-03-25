import 'package:cog_eci_frontend/core/constants/app_colors.dart';
import 'package:cog_eci_frontend/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../core/services/csv_service.dart';
import '../../../core/services/image_picker_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/widgets/app_actionCard.dart';
import '../../../core/widgets/app_appBar.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../auth/bloc/auth_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(FetchProfile());
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: const AppAppBar(),

      body: Center(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading ||
                state is AuthInitial ||
                state is AuthAuthenticated) {
              return const CircularProgressIndicator();
            }

            if (state is AuthUserLoaded) {
              final user = state.user;
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Welcome, ${user.firstName}",
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            "Voter Verification",
                            style: AppTextStyles.headingLarge.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Text(
                            DateFormat('EEEE, d MMMM').format(DateTime.now()),
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: ShapeDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(-0.11, -0.12),
                                  end: Alignment(1.00, 1.00),
                                  colors: [
                                    const Color(0xFF01A580),
                                    const Color(0xFF171619),
                                  ],
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Column(
                                spacing: 7,
                                children: [
                                  Text(
                                    "Total Verifications",
                                    style: AppTextStyles.headingMedium.copyWith(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                  Text(
                                    state.count.toString(),
                                    style: AppTextStyles.headingLarge.copyWith(
                                      color: AppColors.secondary,
                                      fontSize: 50,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: ShapeDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.10,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      spacing: 10,
                                      children: [
                                        const Icon(
                                          Icons.graphic_eq,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          "Keep going! you are doing great.",
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text("Start Scanning : ", style: AppTextStyles.bodyLarge),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ActionCard(
                            icon: Icons.camera_enhance,
                            label: "Camera",
                            onTap: () async {
                              final image = await ImagePicker().pickImage(
                                source: ImageSource.camera,
                                imageQuality: 100,
                              );

                              if (image != null && context.mounted) {
                                context.push('/preview', extra: image.path);
                              }
                            },
                          ),
                          const SizedBox(width: 15),
                          ActionCard(
                            icon: Icons.photo_album,
                            label: "Gallery",
                            onTap: () async {
                              final image =
                                  await ImagePickerService.pickFromGallery();

                              if (image != null && context.mounted) {
                                context.push('/preview', extra: image.path);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Text("Records Report :", style: AppTextStyles.bodyLarge),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ActionCard(
                            icon: Icons.verified_user,
                            label: "View records",
                            onTap: () async {
                              context.push('/voters');
                            },
                          ),
                          const SizedBox(width: 15),
                          ActionCard(
                            icon: Icons.data_exploration,
                            label: "Report in CSV",
                            onTap: () async {
                              try {
                                final token = await StorageService.getToken();

                                final path = await CsvService.downloadCSV(
                                  token!,
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("CSV saved at: $path"),
                                  ),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Download failed")),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is AuthError) {
              return Text(state.message);
            }

            return const Text("No data");
          },
        ),
      ),
    );
  }
}
