import 'package:flutter/material.dart';
import 'package:flutter_settings_framework/flutter_settings_framework.dart';

/// Bilingual catalogs for titles, subtitles, enum labels, and search.
const exampleTranslations = <String, Map<String, String>>{
  'en': {
    'app_title': 'Edadat',
    'search_hint': 'Search settings...',
    'on_this_page': 'On this page',
    'empty_search': 'No settings found for "{query}"',
    'general': 'General',
    'appearance': 'Appearance',
    'behavior': 'Behavior',
    'data': 'Data',
    'about': 'About',
    'language': 'Language',
    'language_subtitle': 'Interface language',
    'theme': 'Theme',
    'theme_light': 'Light',
    'theme_dark': 'Dark',
    'theme_subtitle': 'Light, dark, or system',
    'notifications': 'Notifications',
    'notifications_subtitle': 'Allow alerts and reminders',
    'display_name': 'Display name',
    'display_name_subtitle': 'Shown on the profile tile',
    'theme_color': 'Accent color',
    'theme_color_subtitle': 'Seed for Material color scheme',
    'font_size': 'Font size',
    'card_elevation': 'Card elevation',
    'auto_lock': 'Auto-lock',
    'advanced': 'Advanced',
    'animation_speed': 'Animation duration',
    'auto_lock_subtitle': 'Idle minutes before lock',
    'quiet_hours': 'Quiet hours',
    'quiet_hours_subtitle': 'Silence notifications at night',
    'quiet_hours_start': 'Quiet hours start',
    'quiet_hours_start_subtitle': 'Hour of day (0–23)',
    'export': 'Export settings',
    'export_subtitle': 'Copy a JSON snapshot',
    'reset': 'Reset to defaults',
    'reset_subtitle': 'Restore every setting',
    'tags': 'Tags',
    'version': 'Version',
    'license': 'License',
    'system': 'System',
    'light': 'Light',
    'dark': 'Dark',
    'en': 'English',
    'ar': 'Arabic',
    'small': 'Small',
    'normal': 'Normal',
    'large': 'Large',
    'extra_large': 'Extra large',
    'copied': 'Copied to clipboard',
    'reset_done': 'Settings reset',
    'name_dialog': 'Display name',
    'cancel': 'Cancel',
    'confirm': 'Confirm',
    'confirm_subtitle': 'Are you sure?',
    'layout_mobile': 'Mobile view',
    'layout_desktop': 'Desktop view',
    'empty_detail': 'Select a setting to view details',
    'account': 'Account',
    'profile': 'Profile',
    'profile_subtitle': 'Name and dashboard preview',
    'edit': 'Edit',
    'profile_email': 'ada@example.com',
    'hero_caption': 'Plan usage',
    'hero_status': 'On track',
    'hero_value': '78%',
    'hero_footnote': '3 devices synced',
    'kpi_devices': 'Devices',
    'kpi_shortcuts': 'Shortcuts',
    'kpi_archived': 'Archived',
    'kpi_drafts': 'Drafts',
    'kpi_unread': 'Unread',
    'budget_caption': 'Monthly limit',
    'budget_photos': 'Photos',
    'budget_downloads': 'Downloads',
    'budget_limit_near': '200 MB',
    'budget_limit_over': '80 MB',
    'budget_spent_near': 'Used: 168 MB',
    'budget_spent_over': 'Used: 96 MB',
    'notif_signin': 'New sign-in',
    'notif_signin_body': 'Chrome on this device',
    'notif_grouped': '2 alerts in Security',
    'notif_grouped_sub': 'Security',
    'notif_child_a': 'Device verification',
    'notif_child_a_body': 'Pending review',
    'notif_footer': 'Open settings',
    'banner_backup': 'Backup is on',
    'banner_backup_body': 'Last synced a few minutes ago',
    'plan_name': 'Free plan',
    'plan_status': 'Active',
    'plan_footnote': 'Does not renew',
    'chip_all': 'All',
    'chip_security': 'Security',
    'chip_devices': 'Devices',
    'stat_settings': 'Settings',
    'stat_languages': 'Languages',
    'copy_account_id': 'Account ID',
    'copy_tooltip': 'Copy',
    'header_activity': 'Activity',
    'timeline_theme': 'Theme changed',
    'timeline_theme_body': 'Switched to dark',
    'timeline_theme_time': '2h',
    'timeline_export': 'Settings exported',
    'timeline_export_body': 'JSON snapshot copied',
    'timeline_export_time': '1d',
    'header_security': 'Security',
    'security_2fa': 'Two-factor authentication',
    'security_2fa_on': 'Enabled',
    'security_recovery': 'Recovery email',
    'security_recovery_missing': 'Not set',
    'header_sessions': 'Sessions',
    'session_see_all': 'See all',
    'session_laptop': 'This laptop',
    'session_laptop_sub': 'Linux · Chrome',
    'session_phone': 'Pixel phone',
    'session_phone_sub': 'Android · last week',
    'session_current': 'This device',
    'session_sheet_hint': '{count} devices signed in',
    'session_done': 'Done',
    'session_others': 'Other devices',
    'session_others_empty': 'No other signed-in devices',
    'session_others_empty_body': 'Only this laptop is signed in',
    'session_sign_out_device': 'Sign out',
    'session_sign_out_all': 'Sign out other devices',
    'session_sign_out_all_confirm': 'Sign out all other devices?',
    'session_revoked_all': 'Other devices signed out',
    'session_tablet': 'iPad',
    'session_tablet_sub': 'iPadOS · 3 days ago',
    'session_browser': 'Firefox on Windows',
    'session_browser_sub': 'Last month · unknown location',
    'session_revoked_named': '{device} signed out',
    'header_linked': 'Linked accounts',
    'linked_google': 'Google',
    'linked_email': 'Email',
    'linked_connected': 'Connected',
    'header_archived': 'Archived',
    'empty_archived': 'No archived items',
    'empty_archived_body': 'Archived settings will show up here',
    'header_account_actions': 'Account',
    'action_export': 'Export data',
    'action_sign_out': 'Sign out',
    'banner_pause': 'Pause',
    'banner_resume': 'Resume',
    'banner_off': 'Backup is paused',
    'banner_off_body': 'Changes are only saved on this device',
    'plan_change': 'Change plan',
    'plan_plus': 'Plus plan',
    'plan_plus_status': 'Selected',
    'plan_plus_footnote': 'Demo upgrade — no payment',
    'budget_manage': 'Manage limit',
    'budget_clear': 'Clear downloads',
    'budget_cleared': 'Downloads cache cleared',
    'budget_spent_cleared': 'Used: 16 MB',
    'notif_marked': 'Marked as read',
    'notif_open': 'Opened verification',
    'details': 'Details',
    'two_fa_turn_off': 'Turn off 2FA?',
    'two_fa_turn_on': 'Turn on 2FA?',
    'two_fa_off': 'Disabled',
    'recovery_prompt': 'Recovery email',
    'recovery_hint': 'name@example.com',
    'recovery_saved': 'Recovery email saved',
    'session_current_hint': 'This is the current session',
    'session_revoke': 'Sign out this device?',
    'session_revoked': 'Phone session ended',
    'linked_connect': 'Connect',
    'linked_disconnect': 'Disconnect',
    'linked_disconnected': 'Not connected',
    'archived_restore': 'Restore sample',
    'archived_item': 'Old theme preset',
    'archived_item_body': 'Restored from archive',
    'sign_out_confirm': 'Sign out of the demo account?',
    'signed_out': 'Signed out of the demo',
    'filter_hint': 'Showing {filter}',
  },
  'ar': {
    'app_title': 'إعدادات',
    'search_hint': 'ابحث في الإعدادات...',
    'on_this_page': 'في هذه الصفحة',
    'empty_search': 'لم يُعثر على إعدادات تطابق «{query}»',
    'general': 'عام',
    'appearance': 'المظهر',
    'behavior': 'السلوك',
    'data': 'البيانات',
    'about': 'حول',
    'language': 'اللغة',
    'language_subtitle': 'لغة الواجهة',
    'theme': 'السمة',
    'theme_light': 'فاتح',
    'theme_dark': 'داكن',
    'theme_subtitle': 'فاتح أو داكن أو تلقائي',
    'notifications': 'الإشعارات',
    'notifications_subtitle': 'السماح بالتنبيهات والتذكيرات',
    'display_name': 'الاسم المعروض',
    'display_name_subtitle': 'يظهر في بطاقة الملف',
    'theme_color': 'لون التمييز',
    'theme_color_subtitle': 'أساس مخطط ألوان Material',
    'font_size': 'حجم الخط',
    'card_elevation': 'ارتفاع البطاقة',
    'auto_lock': 'القفل التلقائي',
    'advanced': 'متقدم',
    'animation_speed': 'مدة الحركة',
    'auto_lock_subtitle': 'دقائق الخمول قبل القفل',
    'quiet_hours': 'ساعات الهدوء',
    'quiet_hours_subtitle': 'كتم الإشعارات ليلاً',
    'quiet_hours_start': 'بداية ساعات الهدوء',
    'quiet_hours_start_subtitle': 'ساعة اليوم (0–23)',
    'export': 'تصدير الإعدادات',
    'export_subtitle': 'نسخ لقطة JSON',
    'reset': 'استعادة الافتراضي',
    'reset_subtitle': 'إعادة كل إعداد',
    'tags': 'الوسوم',
    'version': 'الإصدار',
    'license': 'الرخصة',
    'system': 'تلقائي',
    'light': 'فاتح',
    'dark': 'داكن',
    'en': 'الإنجليزية',
    'ar': 'العربية',
    'small': 'صغير',
    'normal': 'عادي',
    'large': 'كبير',
    'extra_large': 'كبير جداً',
    'copied': 'نُسخ إلى الحافظة',
    'reset_done': 'أُعيدت الإعدادات',
    'name_dialog': 'الاسم المعروض',
    'cancel': 'إلغاء',
    'confirm': 'تأكيد',
    'confirm_subtitle': 'هل أنت متأكد؟',
    'layout_mobile': 'عرض الجوال',
    'layout_desktop': 'عرض سطح المكتب',
    'empty_detail': 'اختر إعداداً لعرض التفاصيل',
    'account': 'الحساب',
    'profile': 'الملف',
    'profile_subtitle': 'الاسم ومعاينة اللوحة',
    'edit': 'تعديل',
    'profile_email': 'ada@example.com',
    'hero_caption': 'استخدام الخطة',
    'hero_status': 'ضمن الحد',
    'hero_value': '٧٨٪',
    'hero_footnote': '٣ أجهزة متزامنة',
    'kpi_devices': 'أجهزة',
    'kpi_shortcuts': 'اختصارات',
    'kpi_archived': 'مؤرشف',
    'kpi_drafts': 'مسودات',
    'kpi_unread': 'غير مقروء',
    'budget_caption': 'الحد الشهري',
    'budget_photos': 'الصور',
    'budget_downloads': 'التنزيلات',
    'budget_limit_near': '٢٠٠ م.ب',
    'budget_limit_over': '٨٠ م.ب',
    'budget_spent_near': 'المستخدم: ١٦٨ م.ب',
    'budget_spent_over': 'المستخدم: ٩٦ م.ب',
    'notif_signin': 'تسجيل دخول جديد',
    'notif_signin_body': 'Chrome على هذا الجهاز',
    'notif_grouped': 'تنبيهان في الأمان',
    'notif_grouped_sub': 'الأمان',
    'notif_child_a': 'التحقق من الجهاز',
    'notif_child_a_body': 'بانتظار المراجعة',
    'notif_footer': 'فتح الإعدادات',
    'banner_backup': 'النسخ الاحتياطي يعمل',
    'banner_backup_body': 'آخر مزامنة قبل دقائق',
    'plan_name': 'الخطة المجانية',
    'plan_status': 'نشطة',
    'plan_footnote': 'لا تتجدد',
    'chip_all': 'الكل',
    'chip_security': 'الأمان',
    'chip_devices': 'أجهزة',
    'stat_settings': 'إعدادات',
    'stat_languages': 'لغات',
    'copy_account_id': 'معرّف الحساب',
    'copy_tooltip': 'نسخ',
    'header_activity': 'النشاط',
    'timeline_theme': 'تغيّرت السمة',
    'timeline_theme_body': 'التبديل إلى الداكن',
    'timeline_theme_time': '٢ س',
    'timeline_export': 'صُدّرت الإعدادات',
    'timeline_export_body': 'نُسخت لقطة JSON',
    'timeline_export_time': '١ ي',
    'header_security': 'الأمان',
    'security_2fa': 'المصادقة الثنائية',
    'security_2fa_on': 'مفعّلة',
    'security_recovery': 'بريد الاسترداد',
    'security_recovery_missing': 'غير معيّن',
    'header_sessions': 'الجلسات',
    'session_see_all': 'عرض الكل',
    'session_laptop': 'هذا الحاسوب',
    'session_laptop_sub': 'Linux · Chrome',
    'session_phone': 'هاتف Pixel',
    'session_phone_sub': 'Android · الأسبوع الماضي',
    'session_current': 'هذا الجهاز',
    'session_sheet_hint': '{count} أجهزة مسجّلة الدخول',
    'session_done': 'تم',
    'session_others': 'أجهزة أخرى',
    'session_others_empty': 'لا أجهزة أخرى مسجّلة',
    'session_others_empty_body': 'هذا الحاسوب وحده مسجّل الدخول',
    'session_sign_out_device': 'تسجيل الخروج',
    'session_sign_out_all': 'تسجيل خروج الأجهزة الأخرى',
    'session_sign_out_all_confirm': 'تسجيل الخروج من كل الأجهزة الأخرى؟',
    'session_revoked_all': 'تم تسجيل خروج الأجهزة الأخرى',
    'session_tablet': 'iPad',
    'session_tablet_sub': 'iPadOS · قبل ٣ أيام',
    'session_browser': 'Firefox على Windows',
    'session_browser_sub': 'الشهر الماضي · موقع غير معروف',
    'session_revoked_named': 'تم تسجيل خروج {device}',
    'header_linked': 'الحسابات المرتبطة',
    'linked_google': 'Google',
    'linked_email': 'البريد',
    'linked_connected': 'مرتبط',
    'header_archived': 'المؤرشف',
    'empty_archived': 'لا عناصر مؤرشفة',
    'empty_archived_body': 'ستظهر الإعدادات المؤرشفة هنا',
    'header_account_actions': 'الحساب',
    'action_export': 'تصدير البيانات',
    'action_sign_out': 'تسجيل الخروج',
    'banner_pause': 'إيقاف مؤقت',
    'banner_resume': 'استئناف',
    'banner_off': 'النسخ الاحتياطي متوقف',
    'banner_off_body': 'تُحفظ التغييرات على هذا الجهاز فقط',
    'plan_change': 'تغيير الخطة',
    'plan_plus': 'خطة بلس',
    'plan_plus_status': 'مختارة',
    'plan_plus_footnote': 'ترقية تجريبية — بلا دفع',
    'budget_manage': 'إدارة الحد',
    'budget_clear': 'مسح التنزيلات',
    'budget_cleared': 'تم مسح ذاكرة التنزيلات',
    'budget_spent_cleared': 'المستخدم: ١٦ م.ب',
    'notif_marked': 'وُسم كمقروء',
    'notif_open': 'فُتح التحقق',
    'details': 'التفاصيل',
    'two_fa_turn_off': 'إيقاف المصادقة الثنائية؟',
    'two_fa_turn_on': 'تفعيل المصادقة الثنائية؟',
    'two_fa_off': 'متوقفة',
    'recovery_prompt': 'بريد الاسترداد',
    'recovery_hint': 'name@example.com',
    'recovery_saved': 'حُفظ بريد الاسترداد',
    'session_current_hint': 'هذه الجلسة الحالية',
    'session_revoke': 'تسجيل الخروج من هذا الجهاز؟',
    'session_revoked': 'أُنهيت جلسة الهاتف',
    'linked_connect': 'ربط',
    'linked_disconnect': 'فصل',
    'linked_disconnected': 'غير مرتبط',
    'archived_restore': 'استعادة عيّنة',
    'archived_item': 'سمة قديمة',
    'archived_item_body': 'استُعيدت من الأرشيف',
    'sign_out_confirm': 'تسجيل الخروج من حساب العرض؟',
    'signed_out': 'تم تسجيل الخروج من العرض',
    'filter_hint': 'عرض {filter}',
  },
};

const accountSection = SettingSection(
  key: 'account',
  titleKey: 'account',
  icon: Icons.person_outline,
  order: -1,
  initiallyExpanded: false,
);

const generalSection = SettingSection(
  key: 'general',
  titleKey: 'general',
  icon: Icons.settings,
  order: 0,
  initiallyExpanded: true,
);

const appearanceSection = SettingSection(
  key: 'appearance',
  titleKey: 'appearance',
  icon: Icons.palette,
  order: 1,
  initiallyExpanded: true,
);

const behaviorSection = SettingSection(
  key: 'behavior',
  titleKey: 'behavior',
  icon: Icons.tune,
  order: 2,
  initiallyExpanded: true,
);

const dataSection = SettingSection(
  key: 'data',
  titleKey: 'data',
  icon: Icons.storage,
  order: 3,
  initiallyExpanded: true,
);

const aboutSection = SettingSection(
  key: 'about',
  titleKey: 'about',
  icon: Icons.info_outline,
  order: 4,
  initiallyExpanded: true,
);

const openProfileSetting = ActionSetting(
  'open_profile',
  titleKey: 'profile',
  subtitleKey: 'profile_subtitle',
  icon: Icons.person_outline,
  section: 'account',
  order: 0,
  searchTerms: {
    'en': ['profile', 'account', 'dashboard'],
    'ar': ['ملف', 'حساب', 'لوحة'],
  },
);

const languageSetting = EnumSetting(
  'language',
  defaultValue: 'en',
  titleKey: 'language',
  subtitleKey: 'language_subtitle',
  options: ['en', 'ar'],
  optionLabels: {'en': 'en', 'ar': 'ar'},
  icon: Icons.language,
  section: 'general',
  order: 0,
  searchTerms: {
    'en': ['locale', 'english', 'arabic'],
    'ar': ['لغة', 'إنجليزي', 'عربي'],
  },
);

const themeModeSetting = EnumSetting(
  'theme_mode',
  defaultValue: 'system',
  titleKey: 'theme',
  subtitleKey: 'theme_subtitle',
  options: ['system', 'light', 'dark'],
  optionLabels: {'system': 'system', 'light': 'light', 'dark': 'dark'},
  icon: Icons.brightness_6,
  section: 'general',
  order: 1,
  searchTerms: {
    'en': ['theme', 'dark', 'light', 'mode', 'appearance'],
    'ar': ['السمة', 'داكن', 'فاتح', 'مظهر'],
  },
);

const notificationsSetting = BoolSetting(
  'notifications_enabled',
  defaultValue: true,
  titleKey: 'notifications',
  subtitleKey: 'notifications_subtitle',
  icon: Icons.notifications_outlined,
  section: 'general',
  order: 2,
  searchTerms: {
    'en': ['alerts', 'notify', 'push'],
    'ar': ['تنبيهات', 'إشعار'],
  },
);

const displayNameSetting = StringSetting(
  'display_name',
  defaultValue: 'Ada',
  titleKey: 'display_name',
  subtitleKey: 'display_name_subtitle',
  icon: Icons.badge_outlined,
  section: 'general',
  order: 3,
  maxLength: 32,
  searchTerms: {
    'en': ['name', 'profile'],
    'ar': ['اسم', 'ملف'],
  },
);

const themeColorSetting = ColorSetting(
  'theme_color',
  defaultValue: 0xFF8B6914,
  titleKey: 'theme_color',
  subtitleKey: 'theme_color_subtitle',
  icon: Icons.color_lens_outlined,
  section: 'appearance',
  order: 0,
  colorOptions: [0xFF8B6914, 0xFF6200EE, 0xFF006C51, 0xFFB3261E, 0xFF1D4E89],
  searchTerms: {
    'en': ['color', 'accent', 'seed'],
    'ar': ['لون', 'تمييز'],
  },
);

const fontSizeScaleSetting = EnumSetting(
  'font_size_scale',
  defaultValue: 'normal',
  titleKey: 'font_size',
  options: ['small', 'normal', 'large', 'extra_large'],
  optionLabels: {
    'small': 'small',
    'normal': 'normal',
    'large': 'large',
    'extra_large': 'extra_large',
  },
  icon: Icons.format_size,
  section: 'appearance',
  order: 1,
  searchTerms: {
    'en': ['font', 'text', 'scale', 'type'],
    'ar': ['خط', 'نص', 'حجم'],
  },
);

const cardElevationSetting = DoubleSetting(
  'card_elevation',
  defaultValue: 1.0,
  min: 0.0,
  max: 8.0,
  step: 0.5,
  titleKey: 'card_elevation',
  icon: Icons.layers_outlined,
  section: 'appearance',
  order: 2,
  searchTerms: {
    'en': ['elevation', 'shadow', 'card'],
    'ar': ['ظل', 'بطاقة', 'ارتفاع'],
  },
);

const animationSpeedSetting = IntSetting(
  'animation_speed',
  defaultValue: 150,
  min: 0,
  max: 1000,
  step: 50,
  titleKey: 'animation_speed',
  icon: Icons.speed,
  section: 'behavior',
  subSection: 'advanced',
  order: 0,
  searchTerms: {
    'en': ['animation', 'duration', 'motion'],
    'ar': ['حركة', 'مدة'],
  },
);

const autoLockSetting = IntSetting(
  'auto_lock_minutes',
  defaultValue: 5,
  min: 1,
  max: 30,
  step: 1,
  titleKey: 'auto_lock',
  subtitleKey: 'auto_lock_subtitle',
  icon: Icons.lock_clock_outlined,
  section: 'behavior',
  order: 0,
  searchTerms: {
    'en': ['lock', 'idle', 'timeout'],
    'ar': ['قفل', 'خمول'],
  },
);

const quietHoursSetting = BoolSetting(
  'quiet_hours',
  defaultValue: false,
  titleKey: 'quiet_hours',
  subtitleKey: 'quiet_hours_subtitle',
  icon: Icons.bedtime_outlined,
  section: 'behavior',
  order: 1,
  searchTerms: {
    'en': ['dnd', 'night', 'silence'],
    'ar': ['هدوء', 'ليل', 'كتم'],
  },
);

const quietHoursStartSetting = IntSetting(
  'quiet_hours_start',
  defaultValue: 22,
  min: 0,
  max: 23,
  step: 1,
  titleKey: 'quiet_hours_start',
  subtitleKey: 'quiet_hours_start_subtitle',
  icon: Icons.schedule,
  section: 'behavior',
  order: 2,
  dependsOn: 'quiet_hours',
  enabledWhen: true,
  searchTerms: {
    'en': ['start', 'hour', 'schedule'],
    'ar': ['بداية', 'ساعة'],
  },
);

const exportSetting = ActionSetting(
  'export_settings',
  titleKey: 'export',
  subtitleKey: 'export_subtitle',
  icon: Icons.ios_share,
  section: 'data',
  order: 0,
  searchTerms: {
    'en': ['export', 'json', 'backup'],
    'ar': ['تصدير', 'نسخ'],
  },
);

const resetSetting = ActionSetting(
  'reset_settings',
  titleKey: 'reset',
  subtitleKey: 'reset_subtitle',
  icon: Icons.restart_alt,
  section: 'data',
  order: 1,
  searchTerms: {
    'en': ['reset', 'defaults', 'restore'],
    'ar': ['استعادة', 'افتراضي'],
  },
);

const tagsSetting = StringListSetting(
  'tags',
  defaultValue: ['offline', 'bilingual'],
  titleKey: 'tags',
  icon: Icons.label_outline,
  section: 'data',
  order: 2,
  searchTerms: {
    'en': ['tags', 'labels', 'filters'],
    'ar': ['وسوم', 'تسميات'],
  },
);

const versionSetting = ActionSetting(
  'about_version',
  titleKey: 'version',
  icon: Icons.info_outline,
  section: 'about',
  order: 0,
  searchTerms: {
    'en': ['version', 'about', 'edadat'],
    'ar': ['إصدار', 'حول'],
  },
);

const licenseSetting = ActionSetting(
  'about_license',
  titleKey: 'license',
  icon: Icons.gavel_outlined,
  section: 'about',
  order: 1,
  searchTerms: {
    'en': ['license', 'mpl'],
    'ar': ['رخصة'],
  },
);

SettingsRegistry createExampleRegistry() {
  return SettingsRegistry.withSettings(
    sections: [
      accountSection,
      generalSection,
      appearanceSection,
      behaviorSection,
      dataSection,
      aboutSection,
    ],
    settings: [
      openProfileSetting,
      languageSetting,
      themeModeSetting,
      notificationsSetting,
      displayNameSetting,
      themeColorSetting,
      fontSizeScaleSetting,
      cardElevationSetting,
      autoLockSetting,
      animationSpeedSetting,
      quietHoursSetting,
      quietHoursStartSetting,
      exportSetting,
      resetSetting,
      tagsSetting,
      versionSetting,
      licenseSetting,
    ],
  );
}

String translateExample(String key, String locale) {
  return exampleTranslations[locale]?[key] ??
      exampleTranslations['en']?[key] ??
      key;
}

String translateCatalog(String key, String locale) =>
    translateExample(key, locale);

class CatalogLocale {
  const CatalogLocale({
    required this.code,
    required this.locale,
    required this.label,
    required this.flag,
    required this.shortCode,
  });

  final String code;
  final Locale locale;
  final String label;
  final String flag;
  final String shortCode;

  bool get isRtl => code == 'ar';
}

const catalogLocales = <CatalogLocale>[
  CatalogLocale(
    code: 'ar',
    locale: Locale('ar'),
    label: 'العربية',
    flag: '🇸🇦',
    shortCode: 'AR',
  ),
  CatalogLocale(
    code: 'en',
    locale: Locale('en'),
    label: 'English',
    flag: '🇬🇧',
    shortCode: 'EN',
  ),
];

Locale catalogFlutterLocale(String code) {
  for (final item in catalogLocales) {
    if (item.code == code) return item.locale;
  }
  return const Locale('en');
}

/// Lays out catalog copy so Arabic glyphs exist before the page reveals.
Future<void> warmupCatalogLocale(String locale, {TextStyle? style}) async {
  final texts = exampleTranslations[locale];
  if (texts == null || texts.isEmpty) return;
  final painter = TextPainter(
    textDirection: locale == 'ar' ? TextDirection.rtl : TextDirection.ltr,
  );
  final resolved = style ?? const TextStyle(fontSize: 16, height: 1.3);
  for (final value in texts.values) {
    if (value.isEmpty) continue;
    painter.text = TextSpan(text: value, style: resolved);
    painter.layout(maxWidth: 480);
  }
  painter.dispose();
}

PreIndexedLocalizationProvider createExampleLocalization() {
  return PreIndexedLocalizationProvider({
    for (final entry in exampleTranslations.entries)
      entry.key: Map<String, String>.from(entry.value),
  });
}

Future<SettingsProviders> bootExampleSettings({SettingsStorage? storage}) {
  return initializeSettings(
    registry: createExampleRegistry(),
    storage: storage ?? SharedPreferencesStorage(),
    localizationProvider: createExampleLocalization(),
  );
}

double fontScaleFor(String size) {
  switch (size) {
    case 'small':
      return 0.9;
    case 'large':
      return 1.15;
    case 'extra_large':
      return 1.3;
    case 'normal':
    default:
      return 1.0;
  }
}

ThemeMode themeModeFor(String mode) {
  switch (mode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
    default:
      return ThemeMode.system;
  }
}
