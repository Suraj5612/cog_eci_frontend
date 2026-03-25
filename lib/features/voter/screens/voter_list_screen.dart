import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_appBar.dart';
import '../bloc/voter_bloc.dart';
import '../bloc/voter_event.dart';
import '../bloc/voter_state.dart';

class VoterListScreen extends StatefulWidget {
  const VoterListScreen({super.key});

  @override
  State<VoterListScreen> createState() => _VoterListScreenState();
}

class _VoterListScreenState extends State<VoterListScreen> {
  @override
  void initState() {
    super.initState();

    context.read<VoterBloc>().add(FetchAllVoters());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(),
      body: BlocBuilder<VoterBloc, VoterState>(
        builder: (context, state) {
          if (state is VoterLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VoterListLoaded) {
            final voters = state.voters;

            if (voters.isEmpty) {
              return const Center(child: Text("No records found"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: voters.length,
              itemBuilder: (context, index) {
                final voter = voters[index];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 5,
                  ),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(voter.voterName, style: AppTextStyles.headingMedium),
                      const SizedBox(height: 7),
                      const Divider(color: AppColors.textPrimary, thickness: 1),
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "EPIC : ",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: Text(
                                  voter.epicNumber,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "Mobile : ",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: Text(
                                  voter.mobileNumber,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  "State : ",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: Text(
                                  voter.stateName,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }

          if (state is VoterError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
