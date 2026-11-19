import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/app_input_field.dart';
import '../../../core/widgets/custom_bottom_sheet_dropdown.dart';
import '../controllers/clients_controller.dart';
import '../models/client_detail_model.dart';
import '../models/client_model.dart';

class AddCommunicationScreen extends StatefulWidget {
  final String clientId;
  final bool isEditMode;
  final dynamic communicationId;
  final ClientDetailCommunication? communication;
  final ClientCommunication? clientCommunication;

  const AddCommunicationScreen({
    super.key,
    required this.clientId,
    this.isEditMode = false,
    this.communicationId,
    this.communication,
    this.clientCommunication,
  });

  @override
  State<AddCommunicationScreen> createState() => _AddCommunicationScreenState();
}

class _AddCommunicationScreenState extends State<AddCommunicationScreen> {
  final _formKey = GlobalKey<FormState>();
  late ClientsController controller;
  String? _typeError;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ClientsController>();
    if (widget.isEditMode) {
      final comm = widget.communication;
      final cComm = widget.clientCommunication;
      controller.commSelectedType.value = comm?.type ?? cComm?.type ?? 'Email';
      controller.commSubjectController.text = comm?.subject ?? cComm?.subject ?? '';
      controller.commToController.text = comm?.recipient ?? cComm?.to ?? '';
      controller.commDescController.text = comm?.description ?? cComm?.description ?? '';
      controller.commDateTime.value = comm?.communicatedAt ?? cComm?.dateTime ?? DateTime.now();
      controller.commAttachmentName.value = comm?.attachmentName ?? cComm?.attachmentName;
      controller.commAttachmentPath.value = null;
      controller.commAttachmentSize.value = null;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textColorPrimary, size: 20),
              onPressed: () => Get.back(),
            ),
          ),
        ),
        title: AppText(
          widget.isEditMode ? 'Edit Communication' : 'Add Communication',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textColorPrimary,
        ),
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.slate200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type Dropdown
                          const AppText('Type *', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                          const SizedBox(height: 8),
                          Obx(() {
                            final type = controller.commSelectedType.value;
                            return CustomBottomSheetDropdown(
                              label: 'Communication Type',
                              selectedValue: type,
                              items: controller.communicationTypes,
                              onChanged: (val) {
                                controller.commSelectedType.value = val;
                                setState(() {
                                  _typeError = null;
                                });
                              },
                              borderColor: _typeError != null ? AppColors.errorColor : null,
                            );
                          }),
                          if (_typeError != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 16),
                              child: AppText(_typeError!, fontSize: 12, color: AppColors.errorColor),
                            ),
                          const SizedBox(height: 14),

                          // Subject
                          AppInputField(
                            controller: controller.commSubjectController,
                            label: 'Subject *',
                            hint: 'e.g. Project Update / Consultation Call',
                            isRequired: true,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter subject' : null,
                          ),
                          const SizedBox(height: 14),

                          // Date & Time
                          const AppText('Date & Time *', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                          const SizedBox(height: 8),
                          Obx(() {
                            final dateTime = controller.commDateTime.value;
                            return _buildDateTimePicker(context, value: dateTime);
                          }),
                          const SizedBox(height: 14),

                          // To / Participant
                          AppInputField(
                            controller: controller.commToController,
                            label: 'To *',
                            hint: 'e.g. info@client.com / Participant Name',
                            isRequired: true,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter recipient details' : null,
                          ),
                          const SizedBox(height: 14),

                          // Description
                          AppInputField(
                            controller: controller.commDescController,
                            label: 'Description *',
                            hint: 'Enter summary details of the discussion...',
                            maxLines: 3,
                            isRequired: true,
                            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter description' : null,
                          ),
                          const SizedBox(height: 14),

                          // Attachment upload card
                          const AppText('Attachment', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                          const SizedBox(height: 8),
                          Obx(() {
                            final att = controller.commAttachmentName.value;
                            final size = controller.commAttachmentSize.value;
                            if (att != null) {
                              String sizeText = '';
                              if (size != null && size > 0) {
                                if (size >= 1024 * 1024) {
                                  sizeText = '${(size / (1024 * 1024)).toStringAsFixed(2)} MB';
                                } else {
                                  sizeText = '${(size / 1024).toStringAsFixed(1)} KB';
                                }
                              }

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.slate50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.slate200),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.description_rounded, color: AppColors.primaryColor, size: 24),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          AppText(
                                            att,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textColorPrimary,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (sizeText.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            AppText(sizeText, fontSize: 11, color: AppColors.textColorSecondary),
                                          ],
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: AppColors.textColorHint, size: 20),
                                      onPressed: () {
                                        controller.commAttachmentName.value = null;
                                        controller.commAttachmentPath.value = null;
                                        controller.commAttachmentSize.value = null;
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }

                            return GestureDetector(
                              onTap: _pickAttachment,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(
                                  color: AppColors.slate50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.slate200, style: BorderStyle.solid),
                                ),
                                child: const Center(
                                  child: Column(
                                    children: [
                                      Icon(Iconsax.document_upload, color: AppColors.textColorHint, size: 32),
                                      SizedBox(height: 8),
                                      AppText('Tap to Upload Attachment', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textColorSecondary),
                                      SizedBox(height: 2),
                                      AppText('Supports PDF, DOC, PNG, JPG, ZIP (Max 10MB)', fontSize: 10, color: AppColors.textColorHint),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Symmetrical bottom trigger
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.slate200)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final isSubmitting = controller.isSubmittingComm.value;
                  return ElevatedButton(
                    onPressed: isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.6),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : AppText(
                            widget.isEditMode ? 'Update Communication' : 'Save Communication',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAttachment() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg', 'xls', 'xlsx', 'zip', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null && file.path!.isNotEmpty) {
          controller.commAttachmentName.value = file.name;
          controller.commAttachmentPath.value = file.path;
          controller.commAttachmentSize.value = file.size;
        }
      }
    } catch (e) {
      Get.snackbar(
        'Attachment Error',
        'Could not pick file: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.errorColor,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildDateTimePicker(BuildContext context, {required DateTime? value}) {
    final text = value != null ? DateFormat('dd MMMM yyyy, hh:mm a').format(value) : 'Select Date & Time';
    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) {
          if (!context.mounted) return;
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(value ?? DateTime.now()),
          );
          if (time != null) {
            controller.commDateTime.value = DateTime(date.year, date.month, date.day, time.hour, time.minute);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.slate50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.slate200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              text,
              fontSize: 14,
              fontWeight: value != null ? FontWeight.bold : FontWeight.w600,
              color: value != null ? AppColors.textColorPrimary : AppColors.textColorHint,
            ),
            const Icon(Iconsax.calendar, color: AppColors.textColorHint, size: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();

    if (controller.commSelectedType.value == null || controller.commSelectedType.value!.trim().isEmpty) {
      setState(() {
        _typeError = 'Please select communication type';
      });
      return;
    }

    if (_formKey.currentState!.validate() && _typeError == null) {
      if (widget.isEditMode) {
        final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(controller.commDateTime.value ?? DateTime.now());
        final payload = <String, dynamic>{
          "type": controller.commSelectedType.value ?? 'Email',
          "subject": controller.commSubjectController.text.trim(),
          "communicated_at": formattedDate,
          "recipient": controller.commToController.text.trim(),
          "description": controller.commDescController.text.trim(),
        };

        final commId = widget.communicationId ?? widget.communication?.id ?? widget.clientCommunication?.id;
        final success = await controller.updateCommunication(
          clientId: widget.clientId,
          communicationId: commId,
          data: payload,
        );
        if (success && mounted) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
          } else {
            Get.back(result: true);
          }
        }
      } else {
        final success = await controller.saveCommunication(widget.clientId);
        if (success && mounted) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
          } else {
            Get.back(result: true);
          }
        }
      }
    }
  }
}
