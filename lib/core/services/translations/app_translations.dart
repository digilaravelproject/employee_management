import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'hi_IN': hiIN,
      };

  static const Map<String, String> enUS = {
    // Network & Connectivity
    'no_internet_connection': 'No Internet Connection',
    'check_connection_message': 'Please check your internet connection and turn on Wi-Fi or Mobile Data.',
    'open_settings': 'Open Network Settings',
    'retry': 'Retry',
    'connected': 'Connected',
    'connection_restored': 'Internet connection restored successfully.',
    'still_no_internet': 'Still offline. Please check your network connection.',
    'unable_to_open_settings': 'Unable to open settings. Please open device settings manually.',

    // System Errors
    'error': 'No Internet Connection',
    'something_went_wrong': 'No internet connection. Please check your connection and try again.',
    'failed_to_load_data_message': 'Failed to load data. Please check your connection and try again.',
    'go_back': 'Go Back',
    'cancel': 'Cancel',
    'update': 'Update',
    'delete': 'Delete',
    'save': 'Save',
    'success': 'Success',

    // Statuses
    'active': 'Active',
    'inactive': 'Inactive',
    'pending': 'Pending',
    'in_progress': 'In Progress',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
    'rejected': 'Rejected',
    'approved': 'Approved',
    'present': 'Present',
    'absent': 'Absent',
    'half_day': 'Half Day',
    'on_leave': 'On Leave',
    'not_marked': 'Not Marked',
    'pending_approval': 'Pending Approval',
    'quotation_sent': 'Quotation Sent',
    'work_from_home': 'Work From Home',
    'to_do': 'To Do',
    'testing': 'Testing',
    'on_hold': 'On Hold',

    // Leave Types
    'casual_leave': 'Casual Leave',
    'sick_leave': 'Sick Leave',
    'earned_leave': 'Earned Leave',
    'paid_leave': 'Paid Leave',
    'unpaid_leave': 'Unpaid Leave',
    'maternity_leave': 'Maternity Leave',
    'paternity_leave': 'Paternity Leave',
    'leave_type': 'Leave Type',
  };

  static const Map<String, String> hiIN = {
    // Network & Connectivity
    'no_internet_connection': 'कोई इंटरनेट कनेक्शन नहीं है',
    'check_connection_message': 'कृपया अपना इंटरनेट चेक करें और Wi-Fi या मोबाइल डेटा ऑन करें।',
    'open_settings': 'नेटवर्क सेटिंग्स खोलें',
    'retry': 'पुनः प्रयास करें',
    'connected': 'कनेक्ट हो गया',
    'connection_restored': 'इंटरनेट कनेक्शन पुनः स्थापित हो गया।',
    'still_no_internet': 'अभी भी इंटरनेट नहीं है। कृपया अपनी सेटिंग्स जांचें।',
    'unable_to_open_settings': 'सेटिंग्स खोलने में असमर्थ।',

    // System Errors
    'error': 'इंटरनेट कनेक्शन नहीं है',
    'something_went_wrong': 'कोई इंटरनेट कनेक्शन नहीं है। कृपया Wi-Fi या मोबाइल डेटा ऑन करें।',
    'failed_to_load_data_message': 'डेटा लोड करने में विफल। कृपया पुनः प्रयास करें।',
    'go_back': 'वापस जाएं',
    'cancel': 'रद्द करें',
    'update': 'अपडेट करें',
    'delete': 'हटाएं',
    'save': 'सुरक्षित करें',
    'success': 'सफल',

    // Statuses
    'active': 'सक्रिय',
    'inactive': 'निष्क्रिय',
    'pending': 'लंबित',
    'in_progress': 'प्रगति पर है',
    'completed': 'पूर्ण',
    'cancelled': 'रद्द',
    'rejected': 'अस्वीकृत',
    'approved': 'स्वीकृत',
    'present': 'उपस्थित',
    'absent': 'अनुपस्थित',
    'half_day': 'आधा दिन',
    'on_leave': 'छुट्टी पर',
    'not_marked': 'दर्ज नहीं',
    'pending_approval': 'स्वीकृति लंबित',
    'to_do': 'करना है',
    'testing': 'परीक्षण',
    'on_hold': 'रोका गया',
  };
}
