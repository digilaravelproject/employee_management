import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../controllers/followup_controller.dart';
import '../models/followup_model.dart';
import 'add_note_screen.dart';

class EmployeeNotesScreen extends StatelessWidget {
  const EmployeeNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FollowupController>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 18),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: const AppText(
          'Notes & Activity',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Search Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => controller.searchNotesQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Search notes and activities...',
                hintStyle: const TextStyle(color: AppColors.textColorHint, fontSize: 13),
                prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.textColorHint, size: 18),
                filled: true,
                fillColor: AppColors.slate50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Notes List
          Expanded(
            child: Obx(() {
              final allNotes = controller.filteredNotes;
              final employeeNotes = allNotes.where((n) => n.employeeName == 'Rahul Sharma').toList();

              if (employeeNotes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Iconsax.document_text, size: 48, color: AppColors.textColorHint.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      const AppText('No notes recorded yet.', fontSize: 12, color: AppColors.textColorHint),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                itemCount: employeeNotes.length,
                itemBuilder: (context, index) {
                  final note = employeeNotes[index];
                  return _buildNoteCard(note);
                },
              );
            }),
          ),

          // Symmetrical Footer Action Trigger
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.slate100)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => const AddNoteScreen());
                },
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const AppText(
                  'Add New Note',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(ActivityNote note) {
    final dateStr = DateFormat('dd MMMM yyyy, hh:mm a').format(note.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Client Tag + Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AppText(
                  note.clientName,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              AppText(
                dateStr,
                fontSize: 10,
                color: AppColors.textColorHint,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          AppText(
            note.title,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorPrimary,
          ),
          const SizedBox(height: 6),

          // Content body
          AppText(
            note.note,
            fontSize: 12,
            color: AppColors.textColorSecondary,
          ),
          const SizedBox(height: 12),

          const Divider(color: AppColors.slate100),
          const SizedBox(height: 4),

          // Footer
          Row(
            children: [
              const Icon(Iconsax.user, color: AppColors.textColorHint, size: 12),
              const SizedBox(width: 6),
              AppText(
                'Recorded by: ${note.employeeName}',
                fontSize: 10,
                color: AppColors.textColorHint,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
