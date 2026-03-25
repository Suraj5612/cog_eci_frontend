import 'dart:io';
import 'package:cog_eci_frontend/features/voter/bloc/voter_bloc.dart';
import 'package:cog_eci_frontend/features/voter/bloc/voter_event.dart';
import 'package:cog_eci_frontend/features/voter/bloc/voter_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_appBar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_text_field.dart';
import '../models/parsed_voter_detail.dart';

class VoterDetailsScreen extends StatefulWidget {
  final String imagePath;
  final ParsedVoterData ocrData;

  const VoterDetailsScreen({
    super.key,
    required this.imagePath,
    required this.ocrData,
  });

  @override
  State<VoterDetailsScreen> createState() => _VoterDetailsScreenState();
}

class _VoterDetailsScreenState extends State<VoterDetailsScreen> {
  final voterNameController = TextEditingController();
  final epicController = TextEditingController();
  final addressController = TextEditingController();
  final serialController = TextEditingController();
  final partController = TextEditingController();
  final constituencyController = TextEditingController();
  final stateController = TextEditingController();
  final mobileController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final data = widget.ocrData;

    if (data != null) {
      voterNameController.text = data.voterName;
      epicController.text = data.epicNumber;
      addressController.text = data.address;
      serialController.text = data.serialNumber;
      partController.text = data.partNumberAndName;
      constituencyController.text = data.constituencyName;
      stateController.text = data.stateName;
      mobileController.text = data.phoneNumber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoterBloc, VoterState>(
      listener: (context, state) {
        if (state is VoterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Voter saved successfully")),
          );

          context.push('/home');
        }

        if (state is VoterError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final bloc = context.read<VoterBloc>();
        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.secondary,
              appBar: const AppAppBar(),

              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Voter Details",
                          style: AppTextStyles.headingLarge,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Verify and edit details",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.tertiary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(widget.imagePath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        AppTextField(
                          label: "Voter Name",
                          hint: "Enter voter name",
                          controller: voterNameController,
                        ),
                        const SizedBox(height: 15),

                        AppTextField(
                          label: "EPIC Number",
                          hint: "Enter EPIC number",
                          controller: epicController,
                        ),
                        const SizedBox(height: 15),

                        AppTextField(
                          label: "Address",
                          hint: "Enter address",
                          controller: addressController,
                        ),
                        const SizedBox(height: 15),

                        AppTextField(
                          label: "Serial Number",
                          hint: "Enter serial number",
                          controller: serialController,
                        ),
                        const SizedBox(height: 15),

                        AppTextField(
                          label: "Part Number & Name",
                          hint: "Enter part details",
                          controller: partController,
                        ),
                        const SizedBox(height: 15),

                        AppTextField(
                          label: "Constituency",
                          hint: "Enter constituency",
                          controller: constituencyController,
                        ),
                        const SizedBox(height: 15),

                        AppTextField(
                          label: "State",
                          hint: "Enter state",
                          controller: stateController,
                        ),
                        const SizedBox(height: 15),

                        AppTextField(
                          label: "Mobile Number",
                          hint: "Enter mobile number",
                          controller: mobileController,
                        ),

                        const SizedBox(height: 30),

                        // 🔘 BUTTONS
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pop(context); // 🔥 retry OCR
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: BorderSide(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                child: Text(
                                  "Retry OCR",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppButton(
                                text: "Save Voter",
                                onPressed: () {
                                  bloc.add(
                                    SaveVoter({
                                      "voterName": voterNameController.text,
                                      "epicNumber": epicController.text,
                                      "address": addressController.text,
                                      "serialNumber": int.tryParse(
                                        serialController.text,
                                      ),
                                      "partNumberName": partController.text,
                                      "constituencyName":
                                          constituencyController.text,
                                      "stateName": stateController.text,
                                      "mobileNumber": mobileController.text,
                                    }),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (state is VoterLoading) const AppLoader(),
          ],
        );
      },
    );
  }
}
