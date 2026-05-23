// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get personalInfoTitle => 'Thông tin cá nhân';

  @override
  String get appAppearanceTitle => 'Giao diện ứng dụng';

  @override
  String get aboutAppTitle => 'Về ứng dụng';

  @override
  String get addAccountTitle => 'Thêm tài khoản';

  @override
  String get logoutTitle => 'Đăng xuất';

  @override
  String get fullNameLabel => 'Họ và tên';

  @override
  String get fullNameHint => 'Nhập họ và tên';

  @override
  String get phoneLabel => 'Số điện thoại';

  @override
  String get phoneHint => 'ví dụ: +84 012345678';

  @override
  String get genderLabel => 'Giới tính';

  @override
  String get genderHint => 'Chọn giới tính';

  @override
  String get genderMaleOption => 'Nam';

  @override
  String get genderFemaleOption => 'Nữ';

  @override
  String get genderOtherOption => 'Khác';

  @override
  String get birthDateLabel => 'Ngày sinh';

  @override
  String get birthDateHint => 'Nhập ngày sinh';

  @override
  String get addressLabel => 'Địa chỉ';

  @override
  String get addressHint => 'Nhập địa chỉ';

  @override
  String get locationTrackingLabel => 'Quyền theo dõi';

  @override
  String get allowLocationTrackingText => 'Cho phép đối phương theo dõi vị trí';

  @override
  String get yearsOld => '%d tuổi';

  @override
  String get updateSuccessTitle => 'Thành công';

  @override
  String get updateSuccessMessage => 'Cập nhật thông tin thành công';

  @override
  String get updateErrorTitle => 'Thất bại';

  @override
  String get invalidBirthDate => 'Ngày sinh không hợp lệ';

  @override
  String get confirmLogoutQuestion => 'Bạn muốn đăng xuất?';

  @override
  String get cancelButton => 'Hủy bỏ';

  @override
  String get confirmButton => 'Xác nhận';

  @override
  String get cropPhotoAvatarTitle => 'Chỉnh ảnh đại diện';

  @override
  String get cropPhotoCoverTitle => 'Chỉnh ảnh bìa';

  @override
  String get cropPhotoDoneButton => 'Xong';

  @override
  String get cropPhotoFailedMessage => 'Không thể crop ảnh';

  @override
  String get languageSetting => 'Ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get changeLanguagePrompt =>
      'Thay đổi ngôn ngữ, ứng dụng sẽ khởi động lại';

  @override
  String get appAppearanceThemeLabel => 'Chủ đề';

  @override
  String get appAppearanceSelectThemeTitle => 'Chọn chủ đề';

  @override
  String get appAppearanceThemeSystem => 'Theo hệ thống';

  @override
  String get appAppearanceThemeLight => 'Sáng';

  @override
  String get appAppearanceThemeDark => 'Tối';

  @override
  String get appAppearanceSectionApp => 'ỨNG DỤNG';

  @override
  String get appAppearanceThemeSubtitle => 'Thay đổi giao diện sáng/tối';

  @override
  String get appAppearanceSectionSecurity => 'BẢO MẬT';

  @override
  String get appAppearanceChangePasswordTitle => 'Đổi mật khẩu';

  @override
  String get appAppearanceChangePasswordSubtitle => 'Cập nhật mật khẩu mới';

  @override
  String get appAppearanceNotificationsTitle => 'Thông báo';

  @override
  String get appAppearanceNotificationsSubtitle => 'Quản lý tùy chọn thông báo';

  @override
  String get addAccountSuccessMessage => 'Tạo tài khoản con thành công';

  @override
  String get addAccountNameRequired => 'Vui lòng nhập tên';

  @override
  String get addAccountAccessLabel => 'Quyền truy cập';

  @override
  String get addAccountRoleChild => 'Con';

  @override
  String get addAccountRoleGuardian => 'Phụ huynh';

  @override
  String get addAccountSelectBirthDateTitle => 'Chọn ngày sinh';

  @override
  String get addAccountSelectButton => 'Chọn';

  @override
  String get sessionExpiredLoginAgain =>
      'Phiên đăng nhập đã hết. Vui lòng đăng nhập lại.';

  @override
  String userVmLoadUserError(String error) {
    return 'Lỗi load user: $error';
  }

  @override
  String userVmLoadChildrenError(String error) {
    return 'Lỗi load children: $error';
  }

  @override
  String userVmLoadMembersError(String error) {
    return 'Lỗi load members: $error';
  }

  @override
  String get userVmFamilyIdNotFound => 'Không tìm thấy familyId';

  @override
  String userVmLoadFamilyError(String error) {
    return 'Lỗi load family: $error';
  }

  @override
  String get userVmUserIdNotFound => 'Không tìm thấy userId';

  @override
  String get userVmFullNameRequired => 'Họ và tên không được để trống';

  @override
  String get userVmUpdatePhotoFailed => 'Cập nhật ảnh thất bại';

  @override
  String subscriptionLoadError(String error) {
    return 'Không tải được subscription: $error';
  }

  @override
  String subscriptionWatchError(String error) {
    return 'Theo dõi subscription thất bại: $error';
  }

  @override
  String subscriptionUpdateError(String error) {
    return 'Cập nhật subscription thất bại: $error';
  }

  @override
  String subscriptionActivateError(String error) {
    return 'Kích hoạt gói thất bại: $error';
  }

  @override
  String subscriptionStartTrialError(String error) {
    return 'Bắt đầu trial thất bại: $error';
  }

  @override
  String subscriptionMarkExpiredError(String error) {
    return 'Đánh dấu expired thất bại: $error';
  }

  @override
  String subscriptionClearError(String error) {
    return 'Xóa subscription thất bại: $error';
  }

  @override
  String get appManagementSyncFailed => 'Không thể đồng bộ ứng dụng';

  @override
  String get appManagementUserIdNotFound => 'Không tìm thấy userId';

  @override
  String zoneStatusAtText(String zoneName, String duration) {
    return 'đang ở $zoneName • $duration';
  }

  @override
  String zoneStatusWasAtText(String zoneName) {
    return 'đã ở $zoneName';
  }

  @override
  String zoneStatusWasAtWithAgoText(String zoneName, String ago) {
    return 'đã ở $zoneName • $ago';
  }

  @override
  String get zoneStatusLiveUnavailable =>
      'Không xác định được trạng thái vùng hiện tại';

  @override
  String zoneStatusDurationMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String zoneStatusDurationHoursMinutes(int hours, int minutes) {
    return '${hours}g$minutes phút';
  }

  @override
  String get zoneStatusJustNow => 'vừa xong';

  @override
  String zoneStatusMinutesAgo(int minutes) {
    return '$minutes phút trước';
  }

  @override
  String zoneStatusHoursAgo(int hours) {
    return '$hours giờ trước';
  }

  @override
  String zoneStatusDaysAgo(int days) {
    return '$days ngày trước';
  }

  @override
  String get otpResendCooldownError => 'Vui lòng chờ trước khi gửi lại mã';

  @override
  String get otpResendLockedError =>
      'Bạn đã gửi OTP quá nhiều lần. Vui lòng thử lại sau';

  @override
  String get otpResendMaxError => 'Bạn đã gửi OTP quá nhiều lần';

  @override
  String otpRepositoryLockedMessage(int seconds) {
    return 'Bạn đã bị khóa gửi OTP. Vui lòng thử lại sau ${seconds}s';
  }

  @override
  String get authLoginCancelled => 'Đăng nhập đã bị hủy';

  @override
  String get continueButton => 'Tiếp tục';

  @override
  String zoneDetailsRadiusLabel(String radius) {
    return 'Bán kính ${radius}m';
  }

  @override
  String get zoneDetailsNoCoordinates => 'Không có tọa độ để hiển thị bản đồ';

  @override
  String birthdaySpecialDayHeadline(String name) {
    return 'Sinh nhật của $name!';
  }

  @override
  String get mapTopBarTitle => 'Vị trí';

  @override
  String childGroupMarkerCount(int count) {
    return '$count trẻ';
  }

  @override
  String get changePasswordTitle => 'Đổi mật khẩu';

  @override
  String get changePasswordSuccessMessage => 'Đổi mật khẩu thành công';

  @override
  String get changePasswordCurrentPasswordLabel => 'Mật khẩu hiện tại';

  @override
  String get changePasswordCurrentPasswordHint => 'Nhập mật khẩu hiện tại';

  @override
  String get changePasswordNewPasswordLabel => 'Mật khẩu mới';

  @override
  String get changePasswordNewPasswordHint => 'Nhập mật khẩu mới';

  @override
  String get changePasswordConfirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get changePasswordConfirmPasswordHint => 'Nhập lại mật khẩu mới';

  @override
  String get changePasswordUpdateButton => 'Cập nhật mật khẩu';

  @override
  String get memberManagementTitle => 'Quản lý thành viên';

  @override
  String get memberManagementAddMemberTitle => 'Thêm thành viên';

  @override
  String get memberManagementAddMemberSubtitle =>
      'Kết nối thiết bị mới của con';

  @override
  String get memberManagementAddNowButton => 'Thêm ngay';

  @override
  String get memberManagementFamilyMembersLabel => 'THÀNH VIÊN GIA ĐÌNH';

  @override
  String get memberManagementEmpty => 'Chưa có thành viên';

  @override
  String get memberManagementOnline => 'Đang trực tuyến';

  @override
  String get memberManagementOffline => 'Ngoại tuyến';

  @override
  String get memberManagementMessageButton => 'Nhắn tin';

  @override
  String get memberManagementLocationButton => 'Vị trí';

  @override
  String get userRoleParent => 'Phụ huynh';

  @override
  String get userRoleChild => 'Con';

  @override
  String get userRoleGuardian => 'Người giám hộ';

  @override
  String get aboutAppName => 'My Application';

  @override
  String aboutAppVersionLabel(String version) {
    return 'Phiên bản: $version';
  }

  @override
  String get aboutAppDescription =>
      'Ứng dụng giúp quản lý tài khoản, theo dõi hoạt động và cá nhân hóa trải nghiệm người dùng.';

  @override
  String get aboutAppCopyright => '© 2026 My Company';

  @override
  String get themeSelectorTitle => 'Tùy chỉnh giao diện';

  @override
  String get themeSelectorSubtitle => 'Chọn màu chủ đạo và chế độ sáng/tối';

  @override
  String get themeSelectorDarkMode => 'Chế độ tối';

  @override
  String get themeSelectorApplyButton => 'Áp dụng giao diện';

  @override
  String get phoneAuthTitle => 'Đăng nhập bằng số điện thoại';

  @override
  String get phoneAuthSendOtpButton => 'Gửi mã OTP';

  @override
  String get phoneAuthOtpTitle => 'Nhập mã xác thực';

  @override
  String get phoneAuthOtpInstruction =>
      'Vui lòng nhập mã OTP được gửi đến số điện thoại của bạn';

  @override
  String get termsTitle => 'Điều khoản';

  @override
  String get termsNoData => 'Không có dữ liệu';

  @override
  String termsLastUpdated(String date) {
    return 'Cập nhật lần cuối: $date';
  }

  @override
  String get homeTitle => 'Trang chủ';

  @override
  String get homeGreeting => 'Xin chào';

  @override
  String get homeManageChildButton => 'Quản lý con';

  @override
  String get accountNotFound => 'Tài khoản không tồn tại';

  @override
  String get accountNotActivated => 'Tài khoản chưa được kích hoạt';

  @override
  String get emailNotRegistered => 'Email chưa đăng ký';

  @override
  String get noLocationPermission => 'Không có quyền vị trí';

  @override
  String get gpsError => 'Lỗi GPS';

  @override
  String get currentLocationError => 'Không lấy được vị trí hiện tại';

  @override
  String get invalidCode => 'Mã không đúng';

  @override
  String get codeExpired => 'Mã đã hết hạn';

  @override
  String get tooManyAttempts => 'Nhập sai quá nhiều lần';

  @override
  String get unknownError => 'Có lỗi xảy ra';

  @override
  String get loginFailed => 'Đăng nhập thất bại';

  @override
  String get weakPassword => 'Mật khẩu quá yếu';

  @override
  String get emailInvalid => 'Email không hợp lệ';

  @override
  String get emailInUse => 'Email đã được sử dụng';

  @override
  String get wrongPassword => 'Sai mật khẩu';

  @override
  String get authStartTitle => 'Bắt Đầu Ngay';

  @override
  String get authStartSubtitle => 'Tiếp tục với ứng dụng ngay thôi!';

  @override
  String get authContinueWithGoogle => 'Tiếp tục với Google';

  @override
  String get authContinueWithFacebook => 'Tiếp tục với Facebook';

  @override
  String get authContinueWithApple => 'Tiếp tục với Apple';

  @override
  String get authContinueWithPhone => 'Tiếp tục với số điện thoại';

  @override
  String get authLoginButton => 'Đăng nhập';

  @override
  String get authSignupButton => 'Đăng ký';

  @override
  String get authPrivacyPolicy => 'Chính sách bảo mật';

  @override
  String get authTermsOfService => 'Điều khoản dịch vụ';

  @override
  String get authEnterAllInfo => 'Vui lòng nhập đầy đủ thông tin';

  @override
  String get authInvalidCredentials => 'Thông tin tài khoản không chính xác';

  @override
  String get authUserProfileLoadFailed => 'Không tải được hồ sơ người dùng';

  @override
  String get authGenericError => 'Thông báo';

  @override
  String get authWelcomeBackTitle => 'CHÀO MỪNG TRỞ LẠI';

  @override
  String get authLoginNowSubtitle => 'Đăng nhập ngay!';

  @override
  String get authEnterEmailHint => 'Nhập email';

  @override
  String get authEnterPasswordHint => 'Nhập mật khẩu';

  @override
  String get authRememberPassword => 'Lưu mật khẩu';

  @override
  String get authForgotPassword => 'Quên mật khẩu?';

  @override
  String get authOr => 'Hoặc';

  @override
  String get authNoAccount => 'Bạn chưa có tài khoản, ';

  @override
  String get authSignUpInline => 'đăng ký';

  @override
  String get authSignupTitle => 'ĐĂNG KÝ\nTÀI KHOẢN NGAY';

  @override
  String get authSignupSubtitle => 'Kiểm tra và quản lí con của bạn!';

  @override
  String get authPasswordMismatch => 'Mật khẩu xác nhận không khớp';

  @override
  String get authSignupFailed => 'Đăng ký thất bại';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Mật khẩu';

  @override
  String get authConfirmPasswordLabel => 'Nhập lại mật khẩu';

  @override
  String get authAgreeTermsPrefix => 'Đồng ý với điều khoản, ';

  @override
  String get authAgreeTermsLink => 'tại đây';

  @override
  String get authHaveAccount => 'Bạn đã có tài khoản, ';

  @override
  String get authLoginInline => 'đăng nhập';

  @override
  String get authForgotPasswordTitle => 'QUÊN MẬT KHẨU?';

  @override
  String get authForgotPasswordSubtitle =>
      'Bạn đã quên mật khẩu? Vui lòng làm theo các bước sau để lấy lại mật khẩu của bạn!';

  @override
  String get authEnterYourEmailLabel => 'Nhập Email của bạn';

  @override
  String get authContinueButton => 'Tiếp tục';

  @override
  String get authSendOtpFailed => 'Gửi OTP thất bại';

  @override
  String get otpTitle => 'NHẬP MÃ OTP';

  @override
  String get otpInstruction =>
      'Chúng tôi đã gửi mã xác minh đến địa chỉ email của bạn';

  @override
  String get otpNeed4Digits => 'Vui lòng nhập đủ 6 số OTP';

  @override
  String get otpDigitsOnly => 'OTP chỉ được chứa số';

  @override
  String get otpIncorrect => 'OTP không đúng';

  @override
  String get otpExpired => 'OTP đã hết hạn';

  @override
  String get otpTooManyAttempts =>
      'Bạn đã nhập sai quá 3 lần. Vui lòng chờ 10 phút.';

  @override
  String get otpRequestNotFound => 'Không tìm thấy yêu cầu OTP';

  @override
  String otpResendIn(int seconds) {
    return 'Gửi lại mã sau ${seconds}s';
  }

  @override
  String get otpResend => 'Gửi lại mã';

  @override
  String get otpVerifyButton => 'Xác minh';

  @override
  String get authRegisterSuccessMessage => 'Đăng ký tài khoản thành công';

  @override
  String get resetPasswordTitle => 'ĐẶT LẠI \nMẬT KHẨU MỚI';

  @override
  String get resetPasswordSubtitle => 'Điền mật khẩu mới của bạn!';

  @override
  String get resetPasswordNewLabel => 'Mật khẩu mới';

  @override
  String get resetPasswordConfirmLabel => 'Nhập lại mật khẩu';

  @override
  String get resetPasswordConfirmMismatch => 'Mật khẩu nhập lại không khớp';

  @override
  String get resetPasswordRuleTitle => 'Mật khẩu cần có';

  @override
  String get resetPasswordRuleMinLength => 'Ít nhất 8 ký tự';

  @override
  String get resetPasswordRuleUppercase => 'Có chữ hoa';

  @override
  String get resetPasswordRuleLowercase => 'Có chữ thường';

  @override
  String get resetPasswordRuleNumber => 'Có số';

  @override
  String get resetPasswordCompleteButton => 'Hoàn tất';

  @override
  String get resetPasswordSuccessMessage => 'Đặt lại mật khẩu thành công';

  @override
  String get authCompleteTitle => 'Hoàn tất!';

  @override
  String get authRegisterCongratsMessage =>
      'Chúc mừng! Bạn đã đăng ký thành công';

  @override
  String get authBackToLogin => 'Về trang đăng nhập';

  @override
  String get flashWelcomeTitle => 'Chào mừng đến với ứng dụng';

  @override
  String get flashWelcomeSubtitle => 'Ứng dụng quản lý con';

  @override
  String get flashNext => 'Tiếp';

  @override
  String get scheduleScreenTitle => 'Lịch trình';

  @override
  String get scheduleNoChild => 'Chưa có bé';

  @override
  String get scheduleFormTitleHint => 'Tên lịch trình';

  @override
  String get scheduleFormDescriptionHint => 'Mô tả';

  @override
  String get scheduleAddHeaderTitle => 'Thêm sự kiện';

  @override
  String get scheduleFormDateLabel => 'Ngày';

  @override
  String get scheduleFormStartTimeLabel => 'Giờ bắt đầu';

  @override
  String get scheduleFormEndTimeLabel => 'Giờ kết thúc';

  @override
  String get scheduleFormEndTimeInvalid => 'Giờ kết thúc phải lớn hơn';

  @override
  String get scheduleFormSavingButton => 'Đang lưu...';

  @override
  String get scheduleAddSubmitButton => 'Tạo lịch trình';

  @override
  String get scheduleAddSuccessMessage => 'Bạn đã tạo lịch trình thành công';

  @override
  String get scheduleDialogWarningTitle => 'Cảnh báo';

  @override
  String get scheduleEditHeaderTitle => 'Chỉnh sửa lịch trình';

  @override
  String get scheduleEditSubmitButton => 'Lưu lịch trình';

  @override
  String get scheduleEditSuccessMessage => 'Bạn đã sửa thành công';

  @override
  String get scheduleSelectChildLabel => 'Chọn bé';

  @override
  String get scheduleYourChild => 'Bé của bạn';

  @override
  String get schedulePleaseSelectChild => 'Vui lòng chọn bé';

  @override
  String get scheduleExportTitle => 'Xuất file Excel';

  @override
  String get scheduleExportDateRangeLabel => 'Khoảng thời gian';

  @override
  String get scheduleExportColumnsHint =>
      'File xuất sẽ gồm các cột: title, description, date, start, end';

  @override
  String get scheduleExportLoadingButton => 'Đang xuất...';

  @override
  String get scheduleExportSubmitButton => 'Xuất file';

  @override
  String get scheduleExportInvalidDateRange =>
      'Ngày bắt đầu không được lớn hơn ngày kết thúc';

  @override
  String get scheduleExportNoDataInRange =>
      'Không có lịch trong khoảng ngày đã chọn';

  @override
  String get scheduleExportSaveCanceled => 'Bạn đã huỷ lưu file';

  @override
  String scheduleExportSuccessMessage(int count) {
    return 'Xuất file Excel thành công ($count lịch)';
  }

  @override
  String scheduleExportFailed(String error) {
    return 'Xuất file thất bại: $error';
  }

  @override
  String get scheduleImportTitle => 'Thêm file Excel';

  @override
  String get scheduleTemplateDownloadButton => 'Tải file mẫu';

  @override
  String get scheduleTemplateSaveCanceled => 'Bạn đã huỷ lưu file mẫu';

  @override
  String get scheduleTemplateSavedSuccess => 'Đã lưu file mẫu thành công';

  @override
  String scheduleTemplateDownloadFailed(String error) {
    return 'Tải file mẫu thất bại: $error';
  }

  @override
  String get scheduleImportCannotReadFile => 'Không đọc được file, thử lại.';

  @override
  String get scheduleImportMissingOwner =>
      'Không xác định được chủ sở hữu lịch';

  @override
  String get scheduleImportNoValidItems => 'Không có lịch hợp lệ để import.';

  @override
  String get scheduleImportSuccessMessage => 'Thêm lịch thành công';

  @override
  String scheduleImportFailed(String error) {
    return 'Import thất bại: $error';
  }

  @override
  String scheduleImportAddCount(int count) {
    return 'Thêm $count lịch';
  }

  @override
  String get scheduleImportPickFileButton => 'Chọn file Excel';

  @override
  String get scheduleImportPickAnotherFileButton => 'Chọn file khác';

  @override
  String scheduleImportSelectedFile(String fileName) {
    return 'Đã chọn: $fileName';
  }

  @override
  String get scheduleImportChangeFileButton => 'Đổi file';

  @override
  String scheduleImportSummaryOk(int count) {
    return 'OK: $count';
  }

  @override
  String scheduleImportSummaryDuplicate(int count) {
    return 'Trùng: $count';
  }

  @override
  String scheduleImportSummaryError(int count) {
    return 'Lỗi: $count';
  }

  @override
  String get scheduleImportPreviewTitle => 'Xem trước dữ liệu';

  @override
  String get scheduleImportStatusOk => 'OK';

  @override
  String get scheduleImportStatusError => 'LỖI';

  @override
  String get scheduleImportStatusDuplicate => 'TRÙNG';

  @override
  String scheduleImportRowError(int row, String error) {
    return 'Dòng $row: $error';
  }

  @override
  String get birthdayMemberFallback => 'Thành viên';

  @override
  String birthdayWishSelfWithAge(int age) {
    return 'Chúc mừng sinh nhật tôi. Chào tuổi $age thật rực rỡ, bình an và nhiều niềm vui.';
  }

  @override
  String get birthdayWishSelfDefault =>
      'Chúc mừng sinh nhật tôi. Chúc mình có một ngày thật vui và đáng nhớ.';

  @override
  String birthdayWishOtherWithAge(String name, int age) {
    return 'Chúc mừng sinh nhật $name. Chúc bạn bước sang tuổi $age luôn mạnh khỏe, vui vẻ và gặp nhiều điều may mắn.';
  }

  @override
  String birthdayWishOtherDefault(String name) {
    return 'Chúc mừng sinh nhật $name. Chúc bạn luôn vui vẻ, mạnh khỏe và có thật nhiều niềm vui.';
  }

  @override
  String get birthdayViewWishButton => 'Xem lời chúc';

  @override
  String get birthdaySendWishButton => 'Gửi lời chúc';

  @override
  String get birthdayCongratsYouTitle => 'Chúc mừng sinh nhật bạn';

  @override
  String get birthdayCongratsTitle => 'Chúc mừng sinh nhật';

  @override
  String get birthdayTodayIsYourDay => 'Hôm nay là ngày của bạn';

  @override
  String birthdayTurnsAge(int age) {
    return 'Tròn $age tuổi';
  }

  @override
  String get birthdaySuggestionTitle => 'Lời chúc gợi ý';

  @override
  String birthdayYouEnteringAge(int age) {
    return 'Hôm nay bạn bước sang tuổi $age. Chúc bạn có một ngày thật tươi vui, nhẹ nhàng và đáng nhớ.';
  }

  @override
  String get birthdayYouSpecialDay =>
      'Hôm nay là ngày đặc biệt của bạn. Chúc bạn có thật nhiều niềm vui và năng lượng tích cực.';

  @override
  String birthdayTodayIsBirthdayWithAge(String name, int age) {
    return 'Hôm nay là sinh nhật của $name, tròn $age tuổi.';
  }

  @override
  String birthdayTodayIsBirthday(String name) {
    return 'Hôm nay là sinh nhật của $name.';
  }

  @override
  String get birthdayCountdownTitle => '✨ Sắp tới sinh nhật';

  @override
  String get birthdayCountdownSelfTitle => '✨ Sắp tới sinh nhật của bạn';

  @override
  String get birthdayCountdownTomorrowChip => 'Ngày mai';

  @override
  String birthdayCountdownDaysChip(int days) {
    return 'Còn $days ngày';
  }

  @override
  String birthdayCountdownOtherBody(String name, int days) {
    return 'Chỉ còn $days ngày nữa là đến sinh nhật của $name.';
  }

  @override
  String birthdayCountdownOtherBodyTomorrow(String name) {
    return 'Ngày mai là sinh nhật của $name.';
  }

  @override
  String birthdayCountdownSelfBody(int days) {
    return 'Chỉ còn $days ngày nữa là đến sinh nhật của bạn.';
  }

  @override
  String get birthdayCountdownSelfBodyTomorrow =>
      'Ngày mai là sinh nhật của bạn.';

  @override
  String get birthdayCountdownSuggestionTitle => 'Gợi ý chuẩn bị';

  @override
  String birthdayCountdownSuggestionOther(String name) {
    return 'Bạn có thể chuẩn bị lời chúc, quà tặng hoặc một điều bất ngờ cho $name ngay từ bây giờ.';
  }

  @override
  String get birthdayCountdownSuggestionSelf =>
      'Bạn có thể chuẩn bị lời chúc, món quà nhỏ hoặc một điều bất ngờ cho chính mình ngay từ bây giờ.';

  @override
  String get birthdayCountdownPlanButton => 'Chuẩn bị lời chúc';

  @override
  String birthdayCopiedFallback(String name) {
    return 'Không tìm thấy chat gia đình. Đã sao chép lời chúc cho $name.';
  }

  @override
  String get birthdayCloseButton => 'Đóng';

  @override
  String get birthdayAwesomeButton => 'Tuyệt vời';

  @override
  String get familyChatLoadingTitle => 'Đang tải cuộc trò chuyện';

  @override
  String get familyChatTitle => 'Trò chuyện gia đình';

  @override
  String get familyChatTitleLarge => 'Trò chuyện gia đình';

  @override
  String familyChatSendFailed(String error) {
    return 'Gửi tin nhắn thất bại: $error';
  }

  @override
  String get familyChatYou => 'Bạn';

  @override
  String get familyChatMemberFallback => 'Thành viên';

  @override
  String get familyChatLoadingMembers => 'Đang tải thành viên...';

  @override
  String get familyChatNoMembersFound => 'Không tìm thấy thành viên';

  @override
  String get familyChatOneMember => '1 thành viên';

  @override
  String familyChatManyMembers(int count) {
    return '$count thành viên';
  }

  @override
  String get familyChatCannotLoadMessages => 'Không thể tải tin nhắn';

  @override
  String get familyChatNoMessagesYet =>
      'Chưa có tin nhắn nào. Hãy bắt đầu cuộc trò chuyện.';

  @override
  String get familyChatStatusFailed => 'thất bại';

  @override
  String get familyChatStatusSending => 'đang gửi...';

  @override
  String get familyChatTypeMessageHint => 'Nhập tin nhắn...';

  @override
  String familyChatMemberCountOverflow(String names, int extra) {
    return '$names +$extra';
  }

  @override
  String get notificationScreenTitle => 'Thông báo';

  @override
  String get notificationDateToday => 'HÔM NAY';

  @override
  String get notificationDateYesterday => 'HÔM QUA';

  @override
  String get notificationFilterTitle => 'Lọc thông báo';

  @override
  String get notificationFilterAll => 'Tất cả';

  @override
  String get notificationFilterActivity => 'Hoạt động';

  @override
  String get notificationFilterAlert => 'Cảnh báo';

  @override
  String get notificationFilterReminder => 'Nhắc nhở';

  @override
  String get notificationFilterSystem => 'Thông báo hệ thống';

  @override
  String get notificationSearchHint => 'Tìm thông báo';

  @override
  String get notificationJustNow => 'Vừa xong';

  @override
  String notificationMinutesAgo(int minutes) {
    return '${minutes}p trước';
  }

  @override
  String notificationHoursAgo(int hours) {
    return '${hours}h trước';
  }

  @override
  String get notificationDetailTitle => 'Chi tiết thông báo';

  @override
  String get notificationDetailSectionTitle => 'CHI TIẾT';

  @override
  String get accessibilityNoticeBarrierLabel => 'Hộp thoại thông báo';

  @override
  String get accessibilityImageModalBarrierLabel => 'Trình xem ảnh';

  @override
  String get notificationChildFallback => 'Bé';

  @override
  String get notificationChildInfoNotFound => 'Không tìm thấy thông tin của bé';

  @override
  String get notificationMapLocationNotFound =>
      'Không tìm thấy vị trí để mở bản đồ';

  @override
  String get notificationTrackingDetailNotFound =>
      'Không tìm thấy thông tin hành trình của bé';

  @override
  String get notificationTrackingUnknownValue => 'Không rõ';

  @override
  String get notificationTrackingChildLabel => 'Bé';

  @override
  String get notificationTrackingRouteLabel => 'Tuyến đường';

  @override
  String get notificationTrackingDistanceToRouteLabel =>
      'Khoảng cách tới tuyến';

  @override
  String get notificationTrackingHazardLabel => 'Vùng nguy hiểm';

  @override
  String get notificationTrackingStationaryLabel => 'Đứng yên';

  @override
  String get notificationTrackingTimeLabel => 'Thời điểm';

  @override
  String get notificationTrackingOpenHint =>
      'Mở trang theo dõi để xem vị trí hiện tại của bé, tuyến đang bám và toàn bộ trạng thái hành trình trên bản đồ.';

  @override
  String get notificationTrackingOpenButton => 'Mở theo dõi hành trình';

  @override
  String get notificationTrackingStatusOffRoute => 'Lệch tuyến';

  @override
  String get notificationTrackingStatusBackOnRoute => 'Quay lại tuyến';

  @override
  String get notificationTrackingStatusReturnedToStart => 'Về điểm đầu';

  @override
  String get notificationTrackingStatusStationary => 'Đứng yên quá lâu';

  @override
  String get notificationTrackingStatusArrived => 'Đã đến nơi';

  @override
  String get notificationTrackingStatusDanger => 'Nguy hiểm';

  @override
  String get notificationTrackingStatusDefault => 'Safe Route';

  @override
  String get notificationTrackingHeadlineOffRoute =>
      'Bé đang đi lệch khỏi tuyến đã chọn';

  @override
  String get notificationTrackingHeadlineBackOnRoute =>
      'Bé đã quay lại tuyến an toàn';

  @override
  String get notificationTrackingHeadlineReturnedToStart =>
      'Bé đang quay lại gần điểm xuất phát';

  @override
  String get notificationTrackingHeadlineStationary =>
      'Bé đang đứng yên lâu hơn bình thường';

  @override
  String get notificationTrackingHeadlineArrived => 'Bé đã đến nơi an toàn';

  @override
  String get notificationTrackingHeadlineDanger =>
      'Bé đang đi vào vùng nguy hiểm';

  @override
  String notificationTrackingFallbackOffRoute(String routeName) {
    return 'Hệ thống phát hiện bé đã ra ngoài hành lang an toàn của tuyến $routeName.';
  }

  @override
  String notificationTrackingFallbackBackOnRoute(String routeName) {
    return 'Hệ thống ghi nhận bé đã quay lại hành lang an toàn của tuyến $routeName.';
  }

  @override
  String notificationTrackingFallbackReturnedToStart(String routeName) {
    return 'Bé đang quay lại gần vị trí xuất phát của tuyến $routeName.';
  }

  @override
  String notificationTrackingFallbackStationary(String routeName) {
    return 'Bé đã đứng gần cùng một vị trí quá lâu khi đang đi trên $routeName.';
  }

  @override
  String notificationTrackingFallbackArrived(String routeName) {
    return 'Bé đã đến điểm đích của $routeName.';
  }

  @override
  String get notificationTrackingFallbackDangerGeneric =>
      'Bé đã đi vào một vùng nguy hiểm trên hành trình hiện tại.';

  @override
  String notificationTrackingFallbackDangerWithHazard(
    String hazardName,
    String routeName,
  ) {
    return 'Bé đã đi vào $hazardName khi đang theo tuyến $routeName.';
  }

  @override
  String notificationScheduleCreatedTitle(String childName) {
    return 'Lịch trình mới của $childName';
  }

  @override
  String notificationScheduleUpdatedTitle(String childName) {
    return 'Lịch trình của $childName đã thay đổi';
  }

  @override
  String notificationScheduleDeletedTitle(String childName) {
    return 'Lịch trình của $childName đã bị xóa';
  }

  @override
  String notificationScheduleRestoredTitle(String childName) {
    return 'Lịch trình của $childName đã được khôi phục';
  }

  @override
  String notificationZoneEnteredDangerTitle(String childName) {
    return '$childName đã vào vùng nguy hiểm';
  }

  @override
  String notificationZoneExitedSafeTitle(String childName) {
    return '$childName đã rời vùng an toàn';
  }

  @override
  String notificationZoneExitedDangerTitle(String childName) {
    return '$childName đã rời vùng nguy hiểm';
  }

  @override
  String scheduleImportRowTitle(int row, String title) {
    return 'Dòng $row: $title';
  }

  @override
  String get scheduleImportDuplicateInSystem =>
      'Trùng với dữ liệu đã có trên hệ thống';

  @override
  String get scheduleImportDuplicateInFile => 'Trùng trong file';

  @override
  String get scheduleHistoryTitle => 'Lịch sử chỉnh sửa';

  @override
  String get scheduleHistoryEmpty => 'Chưa có lịch sử chỉnh sửa';

  @override
  String get scheduleHistoryToday => 'Hôm nay';

  @override
  String get scheduleHistoryYesterday => 'Hôm qua';

  @override
  String get scheduleHistoryRestoreDialogTitle => 'Khôi phục lịch trình';

  @override
  String get scheduleHistoryRestoreDialogMessage =>
      'Bạn có chắc muốn khôi phục phiên bản này không?';

  @override
  String get scheduleHistoryRestoreButton => 'Khôi phục';

  @override
  String get scheduleHistoryRestoringButton => 'Đang khôi phục...';

  @override
  String get scheduleHistoryRestoreSuccessMessage =>
      'Bạn đã khôi phục thành công';

  @override
  String scheduleHistoryRestoreFailed(String error) {
    return 'Khôi phục thất bại: $error';
  }

  @override
  String scheduleHistoryEditedAt(String time) {
    return 'Đã sửa lúc $time';
  }

  @override
  String get scheduleHistoryLabelTitle => 'Tên lịch trình:';

  @override
  String get scheduleHistoryLabelDescription => 'Mô tả:';

  @override
  String get scheduleHistoryLabelDate => 'Ngày:';

  @override
  String get scheduleHistoryLabelTime => 'Thời gian:';

  @override
  String get scheduleDrawerMenuTitle => 'Menu';

  @override
  String get scheduleCreateButtonAddEvent => '+ Thêm sự kiện';

  @override
  String get schedulePeriodTitle => 'Thời gian';

  @override
  String get schedulePeriodMorning => 'Sáng';

  @override
  String get schedulePeriodAfternoon => 'Chiều';

  @override
  String get schedulePeriodEvening => 'Tối';

  @override
  String get scheduleCalendarFormatMonth => 'Tháng';

  @override
  String get scheduleCalendarFormatWeek => 'Tuần';

  @override
  String scheduleCalendarMonthLabel(int month) {
    return 'Tháng $month';
  }

  @override
  String get scheduleWeekdayMon => 'T2';

  @override
  String get scheduleWeekdayTue => 'T3';

  @override
  String get scheduleWeekdayWed => 'T4';

  @override
  String get scheduleWeekdayThu => 'T5';

  @override
  String get scheduleWeekdayFri => 'T6';

  @override
  String get scheduleWeekdaySat => 'T7';

  @override
  String get scheduleWeekdaySun => 'CN';

  @override
  String get scheduleNoEventsInDay => 'Không có lịch trong ngày';

  @override
  String get scheduleDeleteTitle => 'Xóa lịch trình';

  @override
  String get scheduleDeleteConfirmMessage => 'Bạn có chắc muốn xóa?';

  @override
  String get scheduleDeleteSuccessMessage => 'Bạn đã xóa thành công';

  @override
  String scheduleDeleteFailed(String error) {
    return 'Xóa thất bại: $error';
  }

  @override
  String get memoryDayTitle => 'Ngày đáng nhớ';

  @override
  String get memoryDayEmpty => 'Chưa có ngày đáng nhớ';

  @override
  String get memoryDayDeleteTitle => 'Xóa ngày đáng nhớ';

  @override
  String get memoryDayDeleteConfirmMessage => 'Bạn có chắc muốn xóa?';

  @override
  String get memoryDayDeleteSuccessMessage => 'Bạn đã xóa thành công';

  @override
  String get memoryDayDeleteFailedMessage => 'Xóa thất bại, vui lòng thử lại';

  @override
  String memoryDayDeleteFailedWithError(String error) {
    return 'Xóa thất bại: $error';
  }

  @override
  String memoryDayDaysPassed(int days) {
    return 'Đã qua $days ngày';
  }

  @override
  String get memoryDayToday => 'Hôm nay';

  @override
  String memoryDayDaysLeft(int days) {
    return 'Còn $days ngày';
  }

  @override
  String memoryDayDateText(String date) {
    return 'Ngày: $date';
  }

  @override
  String memoryDayDateRepeatText(String date) {
    return 'Ngày: $date (lặp lại hằng năm)';
  }

  @override
  String get memoryDayUnsavedTitle => 'Chưa lưu';

  @override
  String get memoryDayUnsavedExitMessage =>
      'Bạn chưa lưu, bạn có chắc muốn thoát?';

  @override
  String get memoryDayFormTitleLabel => 'Tiêu đề';

  @override
  String get memoryDayFormDateLabel => 'Ngày';

  @override
  String get memoryDayFormNoteLabel => 'Ghi chú';

  @override
  String get memoryDayReminderLabel => 'Nhắc nhở trước';

  @override
  String get memoryDayReminderNone => 'Không nhắc';

  @override
  String get memoryDayReminderOneDay => 'Trước 1 ngày';

  @override
  String get memoryDayReminderThreeDays => 'Trước 3 ngày';

  @override
  String get memoryDayReminderSevenDays => 'Trước 7 ngày';

  @override
  String get memoryDayRepeatYearlyLabel => 'Lặp lại hàng năm';

  @override
  String get memoryDayEditHeaderTitle => 'Chỉnh sửa ngày đáng nhớ';

  @override
  String get memoryDayAddHeaderTitle => 'Thêm ngày đáng nhớ';

  @override
  String get memoryDayEditSuccessMessage => 'Bạn đã lưu thay đổi thành công';

  @override
  String get memoryDayAddSuccessMessage =>
      'Bạn đã thêm ngày đáng nhớ thành công';

  @override
  String get memoryDaySaveFailedMessage => 'Đã có lỗi xảy ra, vui lòng thử lại';

  @override
  String get memoryDaySavingButton => 'Đang lưu...';

  @override
  String get memoryDaySaveChangesButton => 'Lưu thay đổi';

  @override
  String get memoryDayAddButton => 'Thêm ngày đáng nhớ';

  @override
  String get memoryDayEditAction => 'Sửa';

  @override
  String get memoryDayDeleteAction => 'Xóa';

  @override
  String get notificationsEmptyTitle => 'Chưa có thông báo';

  @override
  String get notificationsEmptySubtitle =>
      'Các thông báo mới sẽ xuất hiện tại đây';

  @override
  String get notificationsDefaultChildName => 'Bé';

  @override
  String get notificationsNoTitle => 'Không có tiêu đề';

  @override
  String get notificationsActionCreated => 'Đã thêm';

  @override
  String get notificationsActionUpdated => 'Đã chỉnh sửa';

  @override
  String get notificationsActionDeleted => 'Đã xóa';

  @override
  String get notificationsActionRestored => 'Đã khôi phục';

  @override
  String get notificationsActionChanged => 'Đã thay đổi';

  @override
  String get notificationsScheduleTitleLabel => 'Tên lịch';

  @override
  String get notificationsChildNameLabel => 'Tên bé';

  @override
  String get notificationsDateLabel => 'Ngày';

  @override
  String get notificationsTimeLabel => 'Thời gian';

  @override
  String get notificationsViewScheduleButton => 'Xem lịch';

  @override
  String get notificationsRepeatLabel => 'Lặp lại';

  @override
  String get notificationsRepeatYearly => 'Hằng năm';

  @override
  String get notificationsRepeatNone => 'Không lặp lại';

  @override
  String get notificationsImportOperatorLabel => 'Người thao tác';

  @override
  String get notificationsChildLabel => 'Bé';

  @override
  String get notificationsImportAddedCountLabel => 'Số lịch đã thêm';

  @override
  String get notificationsActorParent => 'Ba/Mẹ';

  @override
  String get notificationsActorChild => 'Con';

  @override
  String get notificationsBlockedAccountLabel => 'Tài khoản';

  @override
  String get notificationsBlockedAppLabel => 'Ứng dụng';

  @override
  String get notificationsBlockedTimeLabel => 'Thời điểm';

  @override
  String get notificationsBlockedAllowedWindowLabel => 'Khung giờ cho phép';

  @override
  String get notificationsBlockedWarningMessage =>
      'Ứng dụng đã bị chặn tự động bởi hệ thống.';

  @override
  String get notificationsBlockedViewConfigButton => 'Xem cấu hình thời gian';

  @override
  String get notificationsRemovedDeviceOfLabel => 'Thiết bị của';

  @override
  String get notificationsRemovedAppLabel => 'Ứng dụng đã gỡ';

  @override
  String get notificationsRemovedAtLabel => 'Thời điểm gỡ';

  @override
  String get notificationsRemovedWarningMessage =>
      'Ứng dụng đã bị gỡ khỏi thiết bị. Hãy kiểm tra nếu đây là ứng dụng bị quản lý.';

  @override
  String get notificationsRemovedViewAppsButton => 'Xem danh sách ứng dụng';

  @override
  String notificationsZoneDangerEnterDescription(
    String childName,
    String zoneName,
    String time,
  ) {
    return 'Vị trí của $childName đã được ghi nhận tại $zoneName. Hệ thống ghi nhận bé đã vào vùng nguy hiểm lúc $time.';
  }

  @override
  String notificationsZoneSafeExitDescription(
    String childName,
    String zoneName,
    String time,
  ) {
    return 'Vị trí của $childName đã được ghi nhận tại $zoneName. Hệ thống ghi nhận bé đã rời vùng an toàn lúc $time.';
  }

  @override
  String notificationsZoneDangerExitDescription(
    String childName,
    String zoneName,
    String time,
  ) {
    return 'Vị trí của $childName đã được ghi nhận tại $zoneName. Hệ thống ghi nhận bé đã rời vùng nguy hiểm lúc $time.';
  }

  @override
  String notificationsZoneUpdatedDescription(
    String childName,
    String zoneName,
  ) {
    return 'Vị trí của $childName đã được cập nhật tại $zoneName.';
  }

  @override
  String get notificationsZoneViewOnMainMapButton => 'Xem trên bản đồ chính';

  @override
  String get notificationsContactNowButton => 'Liên hệ ngay';

  @override
  String get notificationsLocalChannelName => 'Mặc định';

  @override
  String get notificationsLocalChannelDescription => 'Thông báo mặc định';

  @override
  String get notificationsDefaultTitle => 'Thông báo';

  @override
  String get notificationsDefaultBody => 'Bạn có thông báo mới';

  @override
  String get notificationsFamilyChatTitle => 'Tin nhắn gia đình';

  @override
  String get notificationsFamilyChatBody => 'Bạn có tin nhắn mới';

  @override
  String get notificationsFamilyEventTitle => 'Sự kiện gia đình';

  @override
  String get notificationsFamilyEventBody => 'Gia đình bạn có sự kiện mới';

  @override
  String get notificationsBirthdayTitle => 'Sinh nhật';

  @override
  String notificationsBirthdayUpcomingBody(String name) {
    return 'Sắp tới sinh nhật của $name!';
  }

  @override
  String notificationsBirthdayTodayBody(String name) {
    return 'Hôm nay là sinh nhật của $name!';
  }

  @override
  String get notificationsTrackingDefaultBody =>
      'Trạng thái định vị đã thay đổi.';

  @override
  String scheduleOverlapConflictMessage(
    String title,
    String start,
    String end,
  ) {
    return 'Trùng với lịch \"$title\" ($start - $end). Vui lòng chọn giờ khác.';
  }

  @override
  String get scheduleExportErrorCreateExcelFile => 'Không tạo được file Excel';

  @override
  String get scheduleImportTemplateSampleTitle1 => 'Học Toán';

  @override
  String get scheduleImportTemplateSampleDescription1 => 'Làm bài 1-5';

  @override
  String get scheduleImportTemplateSampleTitle2 => 'Đá bóng';

  @override
  String get scheduleImportErrorCreateExcelBytes =>
      'Không tạo được dữ liệu Excel';

  @override
  String get scheduleImportErrorMissingTitle => 'Thiếu title';

  @override
  String get scheduleImportErrorEndAfterStart =>
      'Giờ kết thúc phải lớn hơn giờ bắt đầu';

  @override
  String scheduleImportWarningDbCheckFailed(String error) {
    return 'Không kiểm tra trùng DB do lỗi mạng: $error';
  }

  @override
  String get scheduleImportErrorMissingDate => 'Thiếu date';

  @override
  String scheduleImportErrorInvalidDate(String raw) {
    return 'Sai date: \"$raw\"';
  }

  @override
  String scheduleImportErrorInvalidDateSupported(String raw) {
    return 'Sai date: \"$raw\" (hỗ trợ: yyyy-MM-dd, dd/MM/yyyy, MM/dd/yyyy, ISO datetime)';
  }

  @override
  String get scheduleImportErrorMissingTime => 'Thiếu time';

  @override
  String scheduleImportErrorInvalidTimeSupported(String raw) {
    return 'Sai time: \"$raw\" (hỗ trợ: HH:mm, HH:mm:ss, 7:00 AM/PM)';
  }

  @override
  String get scheduleNotifyTitleCreated => 'Lịch trình mới';

  @override
  String get scheduleNotifyTitleUpdated => 'Lịch trình đã thay đổi';

  @override
  String get scheduleNotifyTitleDeleted => 'Lịch trình đã bị xóa';

  @override
  String get scheduleNotifyTitleRestored => 'Lịch trình đã được khôi phục';

  @override
  String get scheduleNotifyTitleChanged => 'Lịch trình có thay đổi';

  @override
  String scheduleNotifyBodyParentCreated(
    String title,
    String childName,
    String date,
    String time,
  ) {
    return 'Cha đã thêm lịch \"$title\" cho $childName vào $date, $time.';
  }

  @override
  String scheduleNotifyBodyParentUpdated(String title, String childName) {
    return 'Cha đã chỉnh sửa lịch \"$title\" của $childName.';
  }

  @override
  String scheduleNotifyBodyParentDeleted(String title, String childName) {
    return 'Cha đã xóa lịch \"$title\" của $childName.';
  }

  @override
  String scheduleNotifyBodyParentRestored(String title, String childName) {
    return 'Cha đã khôi phục một phiên bản cũ của lịch \"$title\" của $childName.';
  }

  @override
  String scheduleNotifyBodyParentChanged(String title, String childName) {
    return 'Cha đã thay đổi lịch \"$title\" của $childName.';
  }

  @override
  String scheduleNotifyBodyChildCreated(
    String childName,
    String title,
    String date,
    String time,
  ) {
    return '$childName đã thêm lịch \"$title\" vào $date, $time.';
  }

  @override
  String scheduleNotifyBodyChildUpdated(String childName, String title) {
    return '$childName đã chỉnh sửa lịch \"$title\".';
  }

  @override
  String scheduleNotifyBodyChildDeleted(String childName, String title) {
    return '$childName đã xóa lịch \"$title\".';
  }

  @override
  String scheduleNotifyBodyChildRestored(String childName, String title) {
    return '$childName đã khôi phục lịch sử sửa của lịch \"$title\".';
  }

  @override
  String scheduleNotifyBodyChildChanged(String childName, String title) {
    return '$childName đã thay đổi lịch \"$title\".';
  }

  @override
  String get memoryDayNotifyTitleCreated => 'Ngày đáng nhớ mới';

  @override
  String get memoryDayNotifyTitleUpdated => 'Ngày đáng nhớ đã thay đổi';

  @override
  String get memoryDayNotifyTitleDeleted => 'Ngày đáng nhớ đã bị xóa';

  @override
  String get memoryDayNotifyTitleChanged => 'Ngày đáng nhớ có thay đổi';

  @override
  String get memoryDayNotifyTitleReminder => 'Sắp đến ngày đáng nhớ';

  @override
  String memoryDayNotifyBodyReminderTomorrow(String title, String date) {
    return 'Ngày mai là \"$title\" ($date).';
  }

  @override
  String memoryDayNotifyBodyReminderInDays(
    String title,
    int days,
    String date,
  ) {
    return 'Còn $days ngày đến \"$title\" ($date).';
  }

  @override
  String memoryDayNotifyBodyParentCreated(String title) {
    return 'Cha đã thêm ngày đáng nhớ \"$title\".';
  }

  @override
  String memoryDayNotifyBodyParentUpdated(String title) {
    return 'Cha đã chỉnh sửa ngày đáng nhớ \"$title\".';
  }

  @override
  String memoryDayNotifyBodyParentDeleted(String title) {
    return 'Cha đã xóa ngày đáng nhớ \"$title\".';
  }

  @override
  String memoryDayNotifyBodyParentChanged(String title) {
    return 'Cha đã thay đổi ngày đáng nhớ \"$title\".';
  }

  @override
  String memoryDayNotifyBodyChildCreated(String actorChildName, String title) {
    return '$actorChildName đã thêm ngày đáng nhớ \"$title\".';
  }

  @override
  String memoryDayNotifyBodyChildUpdated(String actorChildName, String title) {
    return '$actorChildName đã chỉnh sửa ngày đáng nhớ \"$title\".';
  }

  @override
  String memoryDayNotifyBodyChildDeleted(String actorChildName, String title) {
    return '$actorChildName đã xóa ngày đáng nhớ \"$title\".';
  }

  @override
  String memoryDayNotifyBodyChildChanged(String actorChildName, String title) {
    return '$actorChildName đã thay đổi ngày đáng nhớ \"$title\".';
  }

  @override
  String get scheduleImportNotifyTitle => 'Lịch trình mới được thêm';

  @override
  String scheduleImportNotifyBodyParent(int importCount, String childName) {
    return 'Cha vừa thêm $importCount lịch cho $childName.';
  }

  @override
  String scheduleImportNotifyBodyChild(String actorChildName, int importCount) {
    return '$actorChildName vừa thêm $importCount lịch.';
  }

  @override
  String get parentDashboardTitle => 'Bảng điều khiển';

  @override
  String get parentDashboardTabApps => 'Ứng dụng';

  @override
  String get parentDashboardTabStatistics => 'Thống kê';

  @override
  String get parentDashboardNoDeviceTitle =>
      'Chưa có thiết bị nào được liên kết';

  @override
  String get parentDashboardNoDeviceSubtitle =>
      'Để theo dõi thời gian sử dụng ứng dụng, bạn cần thêm thiết bị của con vào hệ thống.';

  @override
  String get parentDashboardAddDeviceButton => 'Thêm con';

  @override
  String get parentDashboardHowItWorksButton => 'Tìm hiểu cách hoạt động';

  @override
  String get parentStatsTotalToday => 'TỔNG THỜI GIAN HÔM NAY';

  @override
  String get parentStatsTotalThisWeek => 'TỔNG THỜI GIAN TUẦN NÀY';

  @override
  String get parentStatsSelectRange => 'CHỌN KHOẢNG NGÀY';

  @override
  String get parentStatsSelectEndDate => 'CHỌN NGÀY KẾT THÚC';

  @override
  String parentStatsTotalFromRange(String startDate, String endDate) {
    return 'TỔNG THỜI GIAN TỪ $startDate - $endDate';
  }

  @override
  String get parentStatsSegmentDay => 'Ngày';

  @override
  String get parentStatsSegmentWeek => 'Tuần';

  @override
  String get parentStatsSegmentRange => 'Thêm';

  @override
  String get parentStatsAppDetailsTitle => 'Chi tiết ứng dụng';

  @override
  String get parentStatsCollapse => 'THU GỌN';

  @override
  String get parentStatsViewAll => 'XEM TẤT CẢ';

  @override
  String get parentStatsDurationZero => '0p';

  @override
  String parentStatsDurationMinutes(int minutes) {
    return '${minutes}p';
  }

  @override
  String parentStatsDurationHours(int hours) {
    return '${hours}g';
  }

  @override
  String parentStatsDurationHoursMinutes(int hours, int minutes) {
    return '${hours}g ${minutes}p';
  }

  @override
  String parentStatsHourLabel(int hour) {
    return '${hour}g';
  }

  @override
  String get parentUsageNoAvailableSlot => 'Không còn khoảng thời gian trống';

  @override
  String get parentUsageStartBeforeEnd =>
      'Giờ bắt đầu phải nhỏ hơn giờ kết thúc';

  @override
  String get parentUsageOverlapTimeRange =>
      'Khoảng thời gian bị trùng với mốc khác';

  @override
  String get parentUsageEndAfterStart =>
      'Giờ kết thúc phải lớn hơn giờ bắt đầu';

  @override
  String get parentUsageEditTitle => 'Cài đặt thời gian sử dụng';

  @override
  String get parentUsageEnableUsage => 'Cho phép sử dụng';

  @override
  String get parentUsageSelectAllowedDays => 'Chọn ngày được phép';

  @override
  String get saveButton => 'Lưu';

  @override
  String get parentUsageDayRuleModalHint => 'Chọn quy tắc cho ngày này';

  @override
  String get parentUsageRuleFollowScheduleTitle => 'Theo lịch đã đặt';

  @override
  String get parentUsageRuleFollowScheduleSubtitle =>
      'Áp dụng khung giờ hàng tuần';

  @override
  String get parentUsageRuleAllowAllDayTitle => 'Cho phép cả ngày';

  @override
  String get parentUsageRuleAllowAllDaySubtitle =>
      'Có thể sử dụng bất cứ lúc nào';

  @override
  String get parentUsageRuleBlockAllDayTitle => 'Chặn cả ngày';

  @override
  String get parentUsageRuleBlockAllDaySubtitle => 'Không được sử dụng hôm nay';

  @override
  String get zonesDeleteConfirmTitle => 'Xác nhận xoá';

  @override
  String get zonesDeleteConfirmMessage =>
      'Bạn có chắc muốn xoá địa điểm này không?';

  @override
  String get zonesDeleteButton => 'Xoá';

  @override
  String get zonesCreateSuccessTitle => 'Tạo thành công';

  @override
  String zonesCreateSuccessMessage(String name) {
    return 'Địa điểm \"$name\" đã được tạo';
  }

  @override
  String get zonesFailedTitle => 'Thất bại';

  @override
  String get zonesCreateFailedMessage =>
      'Không thể tạo địa điểm, vui lòng thử lại';

  @override
  String get zonesEditSuccessTitle => 'Chỉnh sửa thành công';

  @override
  String get zonesEditSuccessMessage => 'Địa điểm đã được cập nhật';

  @override
  String get zonesEditFailedMessage =>
      'Không thể cập nhật địa điểm, vui lòng thử lại';

  @override
  String get zonesDeleteSuccessTitle => 'Xoá thành công';

  @override
  String get zonesDeleteSuccessMessage => 'Địa điểm đã được xoá';

  @override
  String get zonesDeleteFailedMessage =>
      'Không thể xoá địa điểm, vui lòng thử lại';

  @override
  String get zonesEmptyTitle => 'Chưa có vùng nào';

  @override
  String get zonesEmptySubtitle =>
      'Thêm vùng để bắt đầu theo dõi vị trí của bé';

  @override
  String get zonesTypeSafe => 'An toàn';

  @override
  String get zonesTypeDanger => 'Nguy hiểm';

  @override
  String get zonesEditMenu => 'Sửa';

  @override
  String get zonesDeleteMenu => 'Xoá';

  @override
  String get zonesScreenTitle => 'Vùng của bé';

  @override
  String get zonesAddButton => 'Thêm vùng';

  @override
  String zonesErrorWithMessage(String error) {
    return 'Lỗi: $error';
  }

  @override
  String get zonesNewZoneDefaultName => 'Vùng mới';

  @override
  String get zonesEditTitle => 'Chỉnh sửa vùng';

  @override
  String get zonesAddAddressTitle => 'Địa chỉ của địa điểm';

  @override
  String get zonesOverlapWarningText => 'Các địa điểm không nên chồng chéo';

  @override
  String get zonesNameFieldLabel => 'Tên vùng';

  @override
  String get zonesTypeFieldLabel => 'Loại vùng';

  @override
  String get zonesRadiusLabel => 'Bán kính';

  @override
  String get zonesOverlappingPrefix => 'Đang chồng lên: ';

  @override
  String zonesOverlappingWith(String name) {
    return 'Đang chồng lên: $name';
  }

  @override
  String get zonesDefaultNameFallback => 'Vùng';

  @override
  String get parentLocationUnknownUser => 'Không rõ';

  @override
  String get parentLocationSosSent => 'Đã gửi SOS';

  @override
  String get parentLocationSosFailed => 'Gửi SOS thất bại';

  @override
  String get parentLocationMapLoadingTitle => 'Đang tải bản đồ';

  @override
  String get parentLocationMapLoadingSubtitle =>
      'Đang chuẩn bị vị trí của các bé';

  @override
  String get parentChildrenListTitle => 'Danh sách thành viên';

  @override
  String get personalInfoManageAccountsTitle => 'Quản lý tài khoản';

  @override
  String get personalInfoManageAccountsSubtitle =>
      'Quản lý tài khoản của thành viên';

  @override
  String get personalInfoDetailsButton => 'Chi tiết';

  @override
  String get childLocationTransportWalking => 'Đi bộ';

  @override
  String get childLocationTransportBicycle => 'Xe đạp';

  @override
  String get childLocationTransportVehicle => 'Đi xe';

  @override
  String get childLocationTransportStill => 'Đứng yên';

  @override
  String get childLocationTransportUnknown => 'Không rõ';

  @override
  String get childLocationDetailTitle => 'Chi tiết vị trí';

  @override
  String childLocationStatusTitle(String transport) {
    return 'Trạng thái: $transport';
  }

  @override
  String childLocationHistoryTitle(String date) {
    return 'Lịch sử • $date';
  }

  @override
  String get childLocationTooltipHideDots => 'Ẩn điểm';

  @override
  String get childLocationTooltipShowDots => 'Hiện điểm';

  @override
  String get childLocationHistoryButton => 'Lịch sử';

  @override
  String get childLocationZonesButton => 'Vùng';

  @override
  String get zone_default => 'Thông báo hehehe';

  @override
  String get zone_enter_danger_parent => '⚠️ Bé vào vùng nguy hiểm';

  @override
  String get zone_exit_danger_parent => '✅ Bé rời vùng nguy hiểm';

  @override
  String get zone_enter_safe_parent => '✅ Bé vào vùng an toàn';

  @override
  String get zone_exit_safe_parent => 'ℹ️ Bé rời vùng an toàn';

  @override
  String get zone_enter_danger_child => '⚠️ Bạn đang vào vùng nguy hiểm';

  @override
  String get zone_exit_danger_child => '✅ Bạn đã ra khỏi vùng nguy hiểm';

  @override
  String get zone_enter_safe_child => '✅ Bạn đang vào vùng an toàn';

  @override
  String get zone_exit_safe_child => 'ℹ️ Bạn đã ra khỏi vùng an toàn';

  @override
  String get tracking_location_service_off_parent_title => 'Con đã tắt định vị';

  @override
  String get tracking_location_permission_denied_parent_title =>
      'Con đã tắt quyền vị trí';

  @override
  String get tracking_background_disabled_parent_title =>
      'Định vị nền đã bị tắt';

  @override
  String get tracking_location_stale_parent_title =>
      'Không nhận được vị trí mới';

  @override
  String get tracking_ok_parent_title => 'Định vị đã hoạt động lại';

  @override
  String tracking_location_service_off_parent_body(String childName) {
    return '$childName vừa tắt GPS hoặc vị trí trên thiết bị.';
  }

  @override
  String tracking_location_permission_denied_parent_body(String childName) {
    return '$childName đã tắt quyền truy cập vị trí của ứng dụng.';
  }

  @override
  String tracking_background_disabled_parent_body(String childName) {
    return '$childName đã tắt chia sẻ vị trí nền.';
  }

  @override
  String tracking_location_stale_parent_body(String childName) {
    return '$childName chưa cập nhật vị trí trong hơn 2 phút.';
  }

  @override
  String tracking_ok_parent_body(String childName) {
    return '$childName đã bật lại định vị và vị trí đang cập nhật bình thường.';
  }

  @override
  String get tracking_location_service_off_child_title => 'Định vị đang tắt';

  @override
  String get tracking_location_permission_denied_child_title =>
      'Quyền vị trí đang tắt';

  @override
  String get tracking_background_disabled_child_title => 'Định vị nền đang tắt';

  @override
  String get tracking_location_stale_child_title => 'Vị trí chưa được cập nhật';

  @override
  String get tracking_ok_child_title => 'Định vị đã hoạt động lại';

  @override
  String get tracking_default_title => 'Thông báo định vị';

  @override
  String get sosChannelName => 'Cảnh báo SOS';

  @override
  String get sosChannelDescription => 'Thông báo SOS khẩn cấp';

  @override
  String get sosFallbackTitle => 'SOS khẩn cấp';

  @override
  String get sosFallbackBody => 'Có thành viên đang cầu cứu.';

  @override
  String get localAlarmDangerChannelName => 'Cảnh báo vùng nguy hiểm';

  @override
  String get localAlarmDangerChannelDescription =>
      'Thông báo khi bé vào hoặc rời vùng nguy hiểm';

  @override
  String get localAlarmDangerEnterTitle => 'Cảnh báo vùng nguy hiểm';

  @override
  String localAlarmDangerEnterBody(String zoneName) {
    return 'Bạn đã vào: $zoneName';
  }

  @override
  String get localAlarmDangerExitTitle => 'Đã rời vùng nguy hiểm';

  @override
  String localAlarmDangerExitBody(String zoneName) {
    return 'Bạn đã rời: $zoneName';
  }

  @override
  String get trackingStatusLocationServiceOffMessage =>
      'Vui lòng bật GPS hoặc Dịch vụ vị trí trên thiết bị để tiếp tục cập nhật vị trí.';

  @override
  String get trackingStatusLocationPermissionDeniedMessage =>
      'Vui lòng cấp quyền vị trí cho ứng dụng trên thiết bị để tiếp tục cập nhật vị trí.';

  @override
  String get trackingStatusPreciseLocationDeniedMessage =>
      'Thiết bị chưa cấp vị trí chính xác';

  @override
  String get trackingStatusBackgroundDisabledMessage =>
      'Đã tắt chia sẻ vị trí nền';

  @override
  String get trackingStatusOkMessage => 'Định vị hoạt động bình thường';

  @override
  String get trackingErrorEnableLocationService =>
      'Vui lòng bật GPS/vị trí trên thiết bị.';

  @override
  String get trackingErrorEnablePreciseLocation =>
      'Vui lòng bật vị trí chính xác.';

  @override
  String get trackingErrorEnableBackgroundLocation =>
      'Vui lòng bật chia sẻ vị trí nền (Allow all the time).';

  @override
  String get locationForegroundServiceTitle => 'Đang chia sẻ vị trí';

  @override
  String get locationForegroundServiceSubtitle =>
      'Ứng dụng chạy nền để bảo vệ con';

  @override
  String parentLocationGpsError(Object error) {
    return 'Lỗi GPS: $error';
  }

  @override
  String parentLocationEnableGpsError(Object error) {
    return 'Lỗi bật GPS: $error';
  }

  @override
  String parentLocationCurrentLocationError(Object error) {
    return 'Không lấy được vị trí hiện tại: $error';
  }

  @override
  String parentLocationHistoryLoadError(Object error) {
    return 'Lỗi tải lịch sử: $error';
  }

  @override
  String parentLocationWatchChildError(Object childId, Object error) {
    return 'Lỗi theo dõi $childId: $error';
  }

  @override
  String get authLoginRequired => 'Chưa đăng nhập';

  @override
  String get firebaseAuthCurrentPasswordIncorrect =>
      'Mật khẩu hiện tại không đúng';

  @override
  String get firebaseAuthUserMismatch => 'Tài khoản xác thực không khớp';

  @override
  String get firebaseAuthTooManyRequests =>
      'Bạn thử sai quá nhiều lần. Vui lòng thử lại sau';

  @override
  String get firebaseAuthNetworkFailed =>
      'Lỗi kết nối mạng. Vui lòng kiểm tra Internet';

  @override
  String get firebaseAuthChangePasswordFailed =>
      'Không thể đổi mật khẩu. Vui lòng thử lại';

  @override
  String get permissionLocationTitle => 'Bật quyền vị trí';

  @override
  String get permissionLocationSubtitle =>
      'Ứng dụng cần quyền vị trí để theo dõi vị trí của trẻ và hỗ trợ các tính năng an toàn.';

  @override
  String get permissionLocationRecommendation =>
      'Khuyến nghị: cho phép vị trí khi dùng ứng dụng trước. Nếu app cần chạy nền sau này, bạn có thể xin thêm quyền Always.';

  @override
  String get permissionLocationAllowButton => 'Cho phép vị trí';

  @override
  String get permissionNotificationTitle => 'Bật SOS Alerts';

  @override
  String get permissionNotificationSubtitle =>
      'Ứng dụng cần quyền thông báo để gửi cảnh báo SOS khẩn cấp ngay cả khi bạn không mở app.';

  @override
  String get permissionNotificationRecommendation =>
      'Lưu ý: Sau khi cấp quyền, hãy đảm bảo kênh \"SOS Alerts\" được bật âm thanh trong cài đặt thông báo.';

  @override
  String get permissionNotificationAllowButton => 'Cho phép thông báo';

  @override
  String get permissionSosTitle => 'Bật quyền SOS';

  @override
  String get permissionSosSubtitle =>
      'Ứng dụng cần quyền thông báo để gửi cảnh báo SOS khẩn cấp và phát âm thanh cảnh báo.';

  @override
  String get permissionSosRecommendation =>
      'Hãy bật thông báo và đảm bảo kênh \"SOS Alerts\" có âm thanh.';

  @override
  String get permissionSosAllowButton => 'Cho phép SOS';

  @override
  String get permissionOpenSettingsButton => 'Mở cài đặt';

  @override
  String get permissionLaterButton => 'Để sau';

  @override
  String get permissionSkipButton => 'Bỏ qua';

  @override
  String permissionStepLabel(int current, int total) {
    return 'Bước $current/$total';
  }

  @override
  String get permissionOnboardingAccessibilityTitle => 'Bật trợ năng';

  @override
  String get permissionOnboardingAccessibilitySubtitle =>
      'Được dùng cho kiểm soát của phụ huynh trên Android để nhận biết ứng dụng nào đang mở trên thiết bị của trẻ và áp dụng quy tắc chặn do phụ huynh đặt. Thông tin này được hiển thị cho phụ huynh hoặc người giám hộ được chỉ định để phục vụ an toàn và sức khỏe số.';

  @override
  String get permissionOnboardingAccessibilityPrimaryButton => 'Cho phép';

  @override
  String get permissionOnboardingAccessibilitySettingsButton =>
      'Mở cài đặt chung';

  @override
  String get permissionOnboardingBackgroundLocationTitle =>
      'Chọn \"Luôn cho phép\"';

  @override
  String get permissionOnboardingBackgroundLocationSubtitle =>
      'Ứng dụng này thu thập dữ liệu vị trí để hiển thị vị trí trực tiếp của trẻ, tạo cảnh báo Vùng an toàn và hỗ trợ Safe Route ngay cả khi ứng dụng đã đóng hoặc không sử dụng. Vị trí được chia sẻ với phụ huynh hoặc người giám hộ được chỉ định trong cùng gia đình cho các tính năng an toàn.';

  @override
  String get permissionOnboardingBackgroundLocationPrimaryButton => 'Tiếp tục';

  @override
  String get permissionOnboardingBackgroundLocationSettingsButton =>
      'Mở cài đặt vị trí';

  @override
  String get permissionOnboardingBatteryTitle => 'Tắt giới hạn pin';

  @override
  String get permissionOnboardingBatterySubtitle =>
      'Cho phép theo dõi và cảnh báo an toàn tiếp tục hoạt động khi Android có thể dừng ứng dụng ở chế độ nền.';

  @override
  String get permissionOnboardingBatteryPrimaryButton => 'Cho phép';

  @override
  String get permissionOnboardingBatterySettingsButton => 'Mở cài đặt chung';

  @override
  String get permissionOnboardingLocationTitle =>
      'Bật \"Truy cập vị trí của tôi\"';

  @override
  String get permissionOnboardingLocationSubtitle =>
      'Nếu không, app sẽ không thể theo dõi vị trí.';

  @override
  String get permissionOnboardingLocationPrimaryButton => 'Cho phép';

  @override
  String get permissionOnboardingLocationSettingsButton =>
      'Mở cài đặt ứng dụng';

  @override
  String get permissionOnboardingMediaTitle => 'Cho phép ảnh và media';

  @override
  String get permissionOnboardingMediaSubtitle =>
      'Để đổi ảnh đại diện và chọn hình trong app.';

  @override
  String get permissionOnboardingMediaPrimaryButton => 'Cho phép';

  @override
  String get permissionOnboardingMediaSettingsButton => 'Mở cài đặt';

  @override
  String get permissionOnboardingNotificationTitle => 'Bật thông báo';

  @override
  String get permissionOnboardingNotificationSubtitle =>
      'Để nhận SOS và cảnh báo an toàn ngay lập tức.';

  @override
  String get permissionOnboardingNotificationPrimaryButton => 'Cho phép';

  @override
  String get permissionOnboardingNotificationSettingsButton =>
      'Mở cài đặt thông báo';

  @override
  String get permissionOnboardingUsageTitle => 'Bật quyền sử dụng ứng dụng';

  @override
  String get permissionOnboardingUsageSubtitle =>
      'Được dùng để đo ứng dụng nào trẻ sử dụng và thời gian sử dụng trên Android, sau đó hiển thị dữ liệu này cho phụ huynh hoặc người giám hộ được chỉ định để quản lý thời gian màn hình.';

  @override
  String get permissionOnboardingUsagePrimaryButton => 'Cho phép';

  @override
  String get permissionOnboardingUsageSettingsButton => 'Mở cài đặt chung';

  @override
  String get permissionOnboardingStepNotificationsLabel => 'Thông báo';

  @override
  String get permissionOnboardingStepLocationLabel => 'Vị trí';

  @override
  String get permissionOnboardingStepBackgroundLocationLabel => 'Luôn cho phép';

  @override
  String get permissionOnboardingStepMediaLabel => 'Ảnh';

  @override
  String get permissionOnboardingStepUsageLabel => 'Sử dụng';

  @override
  String get permissionOnboardingStepAccessibilityLabel => 'Trợ năng';

  @override
  String get permissionOnboardingStepBatteryLabel => 'Pin';

  @override
  String get permissionOnboardingSystemDeniedMessage =>
      'Quyền này đang bị từ chối ở hệ thống. Hãy mở cài đặt để cấp lại.';

  @override
  String get permissionOnboardingNotGrantedMessage =>
      'Quyền này chưa được cấp. Bạn có thể thử lại hoặc thiết lập sau.';

  @override
  String get permissionOnboardingNotificationHelperText =>
      'Chỉ cần cấp quyền khi dùng app trước. Ngay sau bước này app sẽ hướng dẫn bật thêm \"Allow all the time\" để tracking nền hoạt động ổn định.';

  @override
  String get permissionOnboardingGuideVideoLoadFailed =>
      'Không tải được video hướng dẫn';

  @override
  String get permissionOnboardingGuideVideoPlaceholder =>
      'Video hướng dẫn sẽ hiển thị tại đây';

  @override
  String get applyButton => 'Áp dụng';

  @override
  String get commonStartLabel => 'Bắt đầu';

  @override
  String get commonEndLabel => 'Kết thúc';

  @override
  String get childLocationSosSending => 'Đang gửi SOS...';

  @override
  String childLocationSosError(String error) {
    return 'Lỗi gửi SOS: $error';
  }

  @override
  String get childLocationCurrentJourneyTitle => 'Hành trình hiện tại';

  @override
  String get childLocationTravelHistoryTitle => 'Lịch sử di chuyển';

  @override
  String get childLocationSelectedHistoryLabel => 'Lịch sử đã chọn';

  @override
  String get childLocationTodayLabel => 'Hôm nay';

  @override
  String get childLocationUpdatedJustNow => 'Cập nhật vừa xong';

  @override
  String get childLocationUpdatedOneMinuteAgo => 'Cập nhật 1 phút trước';

  @override
  String childLocationUpdatedMinutesAgo(int minutes) {
    return 'Cập nhật $minutes phút trước';
  }

  @override
  String get childLocationRangeAllDay => 'Cả ngày';

  @override
  String get childLocationTooltipManageZones => 'Quản lý vùng';

  @override
  String get childLocationTooltipSafeRoute => 'Tuyến đường an toàn';

  @override
  String get childLocationTooltipChooseMap => 'Chọn bản đồ';

  @override
  String get childLocationTagStart => 'Bắt đầu';

  @override
  String get childLocationTagEnd => 'Kết thúc';

  @override
  String get childLocationTagGpsVeryWeak => 'GPS rất yếu';

  @override
  String get childLocationTagGpsLost => 'Mất GPS';

  @override
  String get childLocationStayedHereLabel => 'Ở đây được';

  @override
  String get childLocationStayedHereUnavailable => 'Không xác định ổn định';

  @override
  String get childLocationStopDurationHint => 'Thời gian dừng';

  @override
  String get childLocationSpeedLabel => 'Tốc độ';

  @override
  String get childLocationSpeedUnavailable => 'Không ổn định';

  @override
  String get childLocationGpsTitle => 'GPS';

  @override
  String get childLocationPointCountTitle => 'Số điểm';

  @override
  String get childLocationPointCountUnit => 'điểm';

  @override
  String get childLocationGpsAccuracyLabel => 'Sai số GPS';

  @override
  String get childLocationMockGpsLabel => 'GPS giả lập';

  @override
  String get childLocationMockGpsDetected => 'Có dấu hiệu';

  @override
  String get childLocationNoLabel => 'Không';

  @override
  String get childLocationDeviceStatusHint => 'Trạng thái thiết bị';

  @override
  String get childLocationTechnicalDetailsTitle => 'Xem chi tiết kỹ thuật';

  @override
  String get childLocationDetailFullTimeLabel => 'Thời gian đầy đủ';

  @override
  String get childLocationDetailHeadingLabel => 'Hướng di chuyển';

  @override
  String get childLocationDetailCoordinatesLabel => 'Tọa độ';

  @override
  String get childLocationDetailAccuracyLabel => 'Độ chính xác';

  @override
  String get childLocationDurationZeroMinutes => '0 phút';

  @override
  String childLocationDurationHoursMinutes(int hours, int minutes) {
    return '$hours giờ $minutes phút';
  }

  @override
  String childLocationDurationMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String childLocationDurationSeconds(int seconds) {
    return '$seconds giây';
  }

  @override
  String get childLocationGpsLostTitle => 'Mất GPS định vị';

  @override
  String get childLocationGpsVeryWeakSubtitle =>
      'Tín hiệu GPS rất yếu, vị trí có thể không chính xác.';

  @override
  String childLocationGpsLostSubtitle(String meters) {
    return 'Sai số lớn hơn $meters m';
  }

  @override
  String get childLocationStoppedNowTitle => 'Đang đứng yên';

  @override
  String childLocationStoppedNowSubtitle(String duration) {
    return 'Dừng tại đây $duration';
  }

  @override
  String get childLocationStoppedHereTitle => 'Đứng yên tại đây';

  @override
  String childLocationStoppedHereSubtitle(String duration) {
    return 'Dừng khoảng $duration';
  }

  @override
  String get childLocationJourneyStartSubtitle => 'Điểm bắt đầu hành trình';

  @override
  String get childLocationJourneyEndSubtitle => 'Điểm kết thúc hành trình';

  @override
  String childLocationUpdatedAt(String time) {
    return 'Cập nhật lúc $time';
  }

  @override
  String childLocationPassedAt(String time) {
    return 'Đi qua điểm này lúc $time';
  }

  @override
  String get childLocationHeadlineWalking => 'Đang đi bộ';

  @override
  String get childLocationHeadlineBicycle => 'Đang đi xe đạp';

  @override
  String get childLocationHeadlineVehicle => 'Đang đi xe';

  @override
  String get childLocationHeadlineStill => 'Đang đứng yên';

  @override
  String get childLocationHeadlineUnknown => 'Không rõ trạng thái';

  @override
  String get childLocationSpeedAlmostStill => 'Gần như không di chuyển';

  @override
  String get childLocationAccuracySevere => 'Mất GPS nghiêm trọng';

  @override
  String get childLocationAccuracyLost => 'Mất GPS định vị';

  @override
  String childLocationAccuracyGood(String meters) {
    return 'Khá chính xác ($meters m)';
  }

  @override
  String childLocationAccuracyModerate(String meters) {
    return 'Chính xác vừa ($meters m)';
  }

  @override
  String get childLocationTimeWindowTitle => 'Chọn khung giờ';

  @override
  String get childLocationTimeWindowSubtitle =>
      'Chỉ tải và hiển thị lịch sử trong khoảng giờ đang chọn.';

  @override
  String get childLocationPresetMorning => 'Sáng';

  @override
  String get childLocationPresetAfternoon => 'Chiều';

  @override
  String get childLocationPresetEvening => 'Tối';

  @override
  String get childLocationNoDataTitle => 'Chưa có dữ liệu trong khung này';

  @override
  String get childLocationNoDataSubtitle =>
      'Thử đổi khung giờ khác hoặc chọn ngày khác để xem lại hành trình.';

  @override
  String get childLocationSummaryDateLabel => 'Ngày';

  @override
  String get childLocationSummaryTimeRangeLabel => 'Khung giờ';

  @override
  String get childLocationLiveLabel => 'Trực tiếp';

  @override
  String get childLocationRecentPointsTitle => 'Các điểm gần đây';

  @override
  String childLocationLoadMoreRecentHours(Object label) {
    return 'Tải thêm $label';
  }

  @override
  String get childLocationViewAllButton => 'Xem tất cả';

  @override
  String get childLocationTapToSeeDetails => 'Bấm để xem chi tiết';

  @override
  String get childLocationWeakGpsSignal => 'Tín hiệu GPS yếu';

  @override
  String childLocationPointCount(int count) {
    return '$count điểm';
  }

  @override
  String get childLocationNetworkGapTitle => 'Mất mạng';

  @override
  String childLocationNetworkGapSubtitle(Object duration) {
    return 'Bản đồ nối tạm 2 đầu vì dữ liệu bị ngắt trong $duration.';
  }

  @override
  String get childLocationNetworkGapChip => 'Mất kết nối';

  @override
  String get childLocationNetworkGapFromLabel => 'Mất từ';

  @override
  String get childLocationNetworkGapToLabel => 'Có lại lúc';

  @override
  String get childLocationMapSearchSubtitle =>
      'Tìm kiếm địa điểm để chọn nhanh trên bản đồ.';

  @override
  String get childLocationMapSearchInputHint =>
      'Nhập tên đường, trường học, địa chỉ...';

  @override
  String get childLocationMapSearchMinChars =>
      'Nhập ít nhất 2 ký tự để tìm địa điểm.';

  @override
  String get childLocationMapSearchNoResults =>
      'Không tìm thấy địa điểm phù hợp.';

  @override
  String get childLocationSafeRouteRecoveredBanner =>
      'Đã quay lại tuyến an toàn';

  @override
  String get locationNoLocationYet => 'Chưa có vị trí';

  @override
  String locationCoordinatesSummary(String lat, String lng) {
    return 'Lat $lat • Lng $lng';
  }

  @override
  String get locationSearchHint => 'Tìm kiếm';

  @override
  String get locationMessageSent => 'Đã gửi tin nhắn';

  @override
  String get locationChildInfoTitle => 'Thông tin';

  @override
  String get locationQuickMessageHint => 'Gửi tin nhắn nhanh...';

  @override
  String get locationStatusStudying => 'Đang học';

  @override
  String get locationStopSearching => 'Tắt tìm kiếm';

  @override
  String incomingSosConfirmFailed(Object error) {
    return 'Xác nhận thất bại: $error';
  }

  @override
  String get incomingSosEmergencyTitle => '🚨 Có SOS khẩn cấp!';

  @override
  String get incomingSosResolvingButton => 'ĐANG XỬ LÝ';

  @override
  String get incomingSosConfirmButton => 'XÁC NHẬN';

  @override
  String get sosConfirmedRoleParent => 'Phụ huynh';

  @override
  String get sosConfirmedRoleChild => 'Trẻ';

  @override
  String get sosConfirmedNameLabel => 'Tên';

  @override
  String get sosConfirmedSenderLabel => 'Người gửi';

  @override
  String get sosConfirmedSentAtLabel => 'Gửi lúc';

  @override
  String get sosConfirmedConfirmedAtLabel => 'Xác nhận lúc';

  @override
  String get sosConfirmedAccuracyLabel => 'Độ chính xác';

  @override
  String get sosConfirmedTitle => 'Đã xác nhận SOS';

  @override
  String get sosConfirmedCloseButton => 'ĐÓNG';

  @override
  String get sosButtonLabel => 'SOS';

  @override
  String get parentPhoneSaveFailed => 'Không thể lưu số điện thoại';

  @override
  String get parentPhoneAddTitle => 'Thêm số điện thoại của con bạn';

  @override
  String get parentPhoneAddSubtitle =>
      'Liên lạc với con ngay cả khi điện thoại của con đang ở chế độ im lặng';

  @override
  String get parentPhoneAddButton => 'Thêm vào';

  @override
  String get parentPhoneContactHasNoNumber =>
      'Liên hệ này không có số điện thoại';

  @override
  String parentPhonePickFailed(Object error) {
    return 'Không thể lấy số điện thoại từ danh bạ: $error';
  }

  @override
  String get parentPhonePickTitle => 'Chọn số điện thoại';

  @override
  String get parentPhoneOpenContactsButton => 'Mở danh bạ';

  @override
  String get appImageReplaceOption => 'Thay đổi ảnh';

  @override
  String get appImageLoadFailed => 'Không tải được ảnh';

  @override
  String get photoUpdateFailedMessage => 'Cập nhật ảnh thất bại';

  @override
  String get mapTypeSheetTitle => 'Loại bản đồ';

  @override
  String get mapTypeDefault => 'Mặc định';

  @override
  String get mapTypeSatellite => 'Vệ tinh';

  @override
  String get mapTypeTerrain => 'Địa hình';

  @override
  String get phoneHelperSaveSuccessTitle => 'Thêm thành công';

  @override
  String get phoneHelperSaveSuccessMessage =>
      'Số điện thoại của bé đã được lưu thành công';

  @override
  String phoneHelperCallActionFailed(Object error) {
    return 'Không thể thực hiện cuộc gọi: $error';
  }

  @override
  String get phoneHelperOpenDialerFailed => 'Không thể mở ứng dụng điện thoại';

  @override
  String phoneHelperLaunchCallFailed(Object error) {
    return 'Gọi điện thất bại: $error';
  }

  @override
  String get scheduleRepositoryNotFound => 'Lịch trình không tồn tại';

  @override
  String get scheduleRepositoryCurrentNotFound =>
      'Lịch trình hiện tại không tồn tại';

  @override
  String get scheduleRepositoryHistoryNotFound => 'Bản lịch sử không tồn tại';

  @override
  String get locationRepositoryLoginRequired =>
      'Chưa đăng nhập, không thể gửi vị trí';

  @override
  String get locationRepositoryParentIdNotFound =>
      'Không tìm thấy tài khoản phụ huynh';

  @override
  String get safeRouteTripStatusActive => 'Đang theo dõi';

  @override
  String get safeRouteTripStatusTemporarilyDeviated => 'Tạm lệch tuyến';

  @override
  String get safeRouteTripStatusDeviated => 'Lệch tuyến';

  @override
  String get safeRouteTripStatusCompleted => 'Đã đến nơi';

  @override
  String get safeRouteTripStatusCancelled => 'Đã hủy';

  @override
  String get safeRouteTripStatusPlanned => 'Đã lên lịch';

  @override
  String get safeRouteTripStatusNoTrip => 'Chưa có chuyến đi';

  @override
  String get safeRouteTravelModeWalking => 'Đi bộ';

  @override
  String get safeRouteTravelModeMotorbike => 'Xe máy';

  @override
  String get safeRouteTravelModePickup => 'Đón con';

  @override
  String get safeRouteTravelModeOtherVehicle => 'Phương tiện khác';

  @override
  String safeRouteDistanceMeters(int value) {
    return '$value m';
  }

  @override
  String safeRouteDistanceKilometers(Object value) {
    return '$value km';
  }

  @override
  String safeRouteDurationMinutes(int minutes) {
    return '$minutes phút';
  }

  @override
  String safeRouteDurationHours(int hours) {
    return '$hours giờ';
  }

  @override
  String safeRouteDurationHoursMinutes(int hours, int minutes) {
    return '$hours giờ $minutes phút';
  }

  @override
  String safeRouteDurationHoursMinutesShort(int hours, int minutes) {
    return '$hours giờ ${minutes}p';
  }

  @override
  String safeRouteEtaApproxMinutes(int minutes) {
    return '~$minutes phút';
  }

  @override
  String safeRouteEtaApproxHours(int hours) {
    return '~$hours giờ';
  }

  @override
  String safeRouteEtaApproxHoursMinutes(int hours, int minutes) {
    return '~$hours giờ ${minutes}p';
  }

  @override
  String get safeRouteTodayLabel => 'Hôm nay';

  @override
  String get safeRouteTomorrowLabel => 'Ngày mai';

  @override
  String get safeRouteNowLabel => 'Bây giờ';

  @override
  String safeRouteSecondsAgo(int seconds) {
    return '${seconds}s';
  }

  @override
  String safeRouteFormatTime(Object hour, Object minute) {
    return '$hour:$minute';
  }

  @override
  String get safeRouteTrackNowLabel => 'Theo dõi ngay';

  @override
  String get safeRouteNoRepeatSummary =>
      'Không lặp lại, tuyến sẽ được áp dụng cho một lịch theo dõi gần nhất.';

  @override
  String safeRouteRepeatSummaryText(Object labels) {
    return 'Lặp lại vào: $labels';
  }

  @override
  String get safeRouteCurrentRoutePrimary => 'Đang đi trên tuyến chính';

  @override
  String safeRouteCurrentRouteAlternativeIndexed(int index) {
    return 'Đang đi trên tuyến phụ $index';
  }

  @override
  String get safeRouteCurrentRouteAlternative => 'Đang đi trên tuyến phụ';

  @override
  String safeRouteRouteFallbackNameText(Object id) {
    return 'Tuyến $id';
  }

  @override
  String get safeRouteSelectedRouteFallbackName => 'Tuyến đã chọn';

  @override
  String get safeRouteGuidanceLoadingRoute => 'Đang tải tuyến đường...';

  @override
  String get safeRouteGuidanceDangerArea => 'vùng nguy hiểm';

  @override
  String get safeRouteGuidanceReturnToSafeRoute => 'Quay lại tuyến an toàn';

  @override
  String get safeRouteGuidanceArrivedInstruction => 'Sắp tới nơi rồi';

  @override
  String get safeRouteGuidanceArrivedDescription =>
      'Đi tiếp đến điểm đích để hoàn thành hành trình.';

  @override
  String get safeRouteGuidanceStatusOnRoute => 'Đúng tuyến';

  @override
  String get safeRouteGuidanceStatusOffRoute => 'Lệch tuyến';

  @override
  String get safeRouteGuidanceStatusAlmostThere => 'Sắp đến nơi';

  @override
  String get safeRouteGuidanceStatusSafeRoute => 'Tuyến an toàn';

  @override
  String safeRouteGuidanceLeaveDangerZone(Object hazardName) {
    return 'Rời khỏi $hazardName ngay';
  }

  @override
  String safeRouteGuidanceDangerDescription(Object hazardName) {
    return 'Đi ra khỏi $hazardName và quay lại tuyến an toàn.';
  }

  @override
  String safeRouteGuidanceOffRouteDescription(Object distanceLabel) {
    return 'Bạn đang cách tuyến khoảng $distanceLabel.';
  }

  @override
  String safeRouteGuidanceRemainingDescription(Object distanceLabel) {
    return 'Còn $distanceLabel để đến điểm đích.';
  }

  @override
  String safeRouteGuidanceContinueStraight(Object distanceLabel) {
    return 'Đi thẳng $distanceLabel';
  }

  @override
  String safeRouteGuidanceTurnLeft(Object distanceLabel) {
    return 'Rẽ trái sau $distanceLabel';
  }

  @override
  String safeRouteGuidanceTurnRight(Object distanceLabel) {
    return 'Rẽ phải sau $distanceLabel';
  }

  @override
  String safeRouteGuidanceKeepLeft(Object distanceLabel) {
    return 'Chếch trái sau $distanceLabel';
  }

  @override
  String safeRouteGuidanceKeepRight(Object distanceLabel) {
    return 'Chếch phải sau $distanceLabel';
  }

  @override
  String safeRouteGuidanceMakeUTurn(Object distanceLabel) {
    return 'Quay đầu sau $distanceLabel';
  }

  @override
  String get safeRouteGuidanceEtaNow => 'Đến ngay bây giờ';

  @override
  String get safeRouteVisualDangerTitle => 'Đi vào vùng nguy hiểm!';

  @override
  String safeRouteVisualDangerSubtitle(Object hazardName) {
    return 'Bé đang ở gần $hazardName.';
  }

  @override
  String get safeRouteVisualDangerBadge => 'NGUY HIỂM';

  @override
  String safeRouteVisualOffRouteTitle(Object distanceLabel) {
    return 'Đang lệch tuyến ~$distanceLabel';
  }

  @override
  String get safeRouteVisualOffRouteSubtitle =>
      'Bé đang đi ra ngoài hành lang an toàn đã chọn.';

  @override
  String get safeRouteVisualOffRouteBadge => 'LỆCH TUYẾN';

  @override
  String get safeRouteVisualCompletedTitle => 'Bé đã đến nơi an toàn';

  @override
  String get safeRouteVisualCompletedSubtitle =>
      'Hành trình vừa được đánh dấu hoàn thành.';

  @override
  String get safeRouteVisualCompletedBadge => 'HOÀN THÀNH';

  @override
  String get safeRouteVisualCancelledTitle => 'Đã dừng theo dõi hành trình';

  @override
  String get safeRouteVisualCancelledSubtitle =>
      'Phụ huynh đã kết thúc chế độ giám sát hiện tại.';

  @override
  String get safeRouteVisualCancelledBadge => 'ĐÃ DỪNG';

  @override
  String get safeRouteVisualPlannedTitle => 'Tuyến đang chờ kích hoạt';

  @override
  String get safeRouteVisualPlannedSubtitle =>
      'Safe Route sẽ tự bắt đầu theo ngày giờ đã cài đặt.';

  @override
  String get safeRouteVisualPlannedBadge => 'ĐÃ LÊN LỊCH';

  @override
  String get safeRouteVisualActiveTitle => 'Đang đi đúng tuyến';

  @override
  String get safeRouteVisualActiveSubtitle =>
      'Bé đang trong hành lang an toàn đã chọn.';

  @override
  String get safeRouteVisualActiveBadge => 'AN TOÀN';

  @override
  String get safeRouteErrorMaxAlternative =>
      'Chỉ nên chọn tối đa 2 tuyến phụ cho mỗi chuyến.';

  @override
  String get safeRouteErrorNoCurrentLocation =>
      'Chưa có vị trí hiện tại của trẻ.';

  @override
  String get safeRouteErrorNeedStartEnd => 'Cần chọn điểm A và điểm B trước.';

  @override
  String get safeRouteErrorLoadHistoryRoute =>
      'Không tải được tuyến đường trong lịch sử.';

  @override
  String get safeRouteErrorNeedRoute => 'Cần chọn một tuyến đường an toàn.';

  @override
  String get safeRouteErrorLoginAgain =>
      'Bạn cần đăng nhập lại để bắt đầu chuyến đi.';

  @override
  String get safeRouteErrorSelectTimeForRepeat =>
      'Chọn giờ áp dụng nếu muốn lặp lại theo ngày.';

  @override
  String get safeRouteUseCurrentLocationLabel => 'Vị trí hiện tại';

  @override
  String get safeRouteStartPointOfRoute => 'Điểm bắt đầu của tuyến';

  @override
  String get safeRouteEndPointOfRoute => 'Điểm kết thúc của tuyến';

  @override
  String get safeRouteCancelledByParentReason => 'Đã hủy bởi phụ huynh';

  @override
  String safeRouteSpeedValue(Object value) {
    return '$value km/h';
  }

  @override
  String get safeRoutePageSelectRouteTitle => 'Chọn tuyến an toàn';

  @override
  String get safeRoutePageJourneyTitle => 'Hành trình an toàn';

  @override
  String get safeRouteSnackbarAutoFollowEnabled => 'Đã bật Auto follow';

  @override
  String get safeRouteSnackbarAutoFollowDisabled => 'Đã tắt Auto follow';

  @override
  String get safeRouteSearchStartTitle => 'Tìm điểm đi';

  @override
  String get safeRouteSearchStartHint =>
      'Tìm nhà, điểm đón hoặc vị trí bắt đầu hành trình.';

  @override
  String get safeRouteSearchEndTitle => 'Tìm điểm đến';

  @override
  String get safeRouteSearchEndHint =>
      'Tìm trường học, nhà người thân hoặc điểm đến cần theo dõi.';

  @override
  String safeRouteScheduledAutoActivationPrefix(Object summary) {
    return 'Tự kích hoạt theo lịch · $summary';
  }

  @override
  String get safeRouteTopSubtitleWarning => 'Đang lệch tuyến';

  @override
  String get safeRouteTopSubtitleDanger => 'Cảnh báo nguy hiểm';

  @override
  String get safeRouteTopSubtitleReady => 'Điểm đi và điểm đến đã sẵn sàng';

  @override
  String get safeRouteTopSubtitleOnlyStart =>
      'Đã chọn điểm đi, tiếp tục chọn điểm đến';

  @override
  String get safeRouteTopSubtitleChoosePoints =>
      'Chọn điểm đi và điểm đến theo phong cách bản đồ';

  @override
  String get safeRouteSelectScheduleDateHelp => 'Chọn ngày áp dụng';

  @override
  String get safeRouteSelectScheduleTimeTitle => 'Chọn giờ áp dụng';

  @override
  String get safeRouteArrivedDialogTitle => 'Bé đã đến nơi an toàn';

  @override
  String get safeRouteArrivedDialogMessage =>
      'Hành trình này đã được hoàn tất. Bạn có thể quay lại để chọn tuyến đường mới cho bé.';

  @override
  String get safeRouteArrivedDialogConfirm => 'Quay lại chọn tuyến đường';

  @override
  String get safeRouteCancelPlannedTitle => 'Xác nhận hủy lịch Safe Route';

  @override
  String get safeRouteCancelActiveTitle => 'Xác nhận hủy tuyến Safe Route';

  @override
  String get safeRouteCancelPlannedMessage =>
      'Lịch theo dõi này sẽ không tự kích hoạt nữa. Bạn có chắc muốn hủy không?';

  @override
  String get safeRouteCancelActiveMessage =>
      'Tuyến đường an toàn hiện tại sẽ dừng theo dõi ngay. Bạn có chắc muốn hủy không?';

  @override
  String get safeRouteCancelPlannedConfirm => 'Xác nhận hủy lịch';

  @override
  String get safeRouteCancelActiveConfirm => 'Xác nhận hủy tuyến';

  @override
  String get safeRouteDialogBack => 'Quay lại';

  @override
  String get safeRouteTooltipFocusChild => 'Đưa camera tới bé';

  @override
  String get safeRouteTooltipDisableAutoFollow => 'Tắt Auto follow';

  @override
  String get safeRouteTooltipEnableAutoFollow => 'Bật Auto follow';

  @override
  String get safeRouteAutoFollowLabel => 'Auto follow';

  @override
  String get safeRouteTooltipHideHazards => 'Ẩn vùng nguy hiểm';

  @override
  String get safeRouteTooltipShowHazards => 'Hiện vùng nguy hiểm';

  @override
  String get safeRouteTooltipMapType => 'Chọn kiểu bản đồ';

  @override
  String get safeRouteMapHintPlaceStart => 'Chạm trên bản đồ để đặt điểm đi';

  @override
  String get safeRouteMapHintPlaceEnd => 'Chạm trên bản đồ để đặt điểm đến';

  @override
  String get safeRouteMapHintTapStart =>
      'Chạm trên bản đồ để chọn điểm đi cho bé.';

  @override
  String get safeRouteMapHintTapEnd =>
      'Chạm trên bản đồ để chọn điểm đến của bé.';

  @override
  String get safeRouteSnackbarSelectedEndPoint =>
      'Đã chọn điểm đến trên bản đồ';

  @override
  String get safeRouteSnackbarSelectedStartPoint =>
      'Đã chọn điểm đi trên bản đồ';

  @override
  String get safeRouteSelectSafeRouteTitle => 'Chọn tuyến an toàn';

  @override
  String get safeRouteSuggestedRoutesTitle => 'Các tuyến đường gợi ý';

  @override
  String get safeRouteSuggestedRoutesSubtitle =>
      'Ưu tiên an toàn, dễ theo dõi và ít đi qua vùng nguy hiểm';

  @override
  String get safeRouteHistoryButton => 'Lịch sử';

  @override
  String get safeRouteRefreshingRoutes => 'Đang tìm...';

  @override
  String get safeRouteRefreshButton => 'Làm mới';

  @override
  String get safeRouteConfirmingRoute => 'Đang xác nhận tuyến...';

  @override
  String get safeRouteFetchSuggestedRoutes => 'Lấy gợi ý tuyến đường';

  @override
  String get safeRouteHintSelectingStart =>
      'Chạm trên bản đồ để chọn điểm đi cho bé.';

  @override
  String get safeRouteHintSelectingEnd =>
      'Chạm trên bản đồ để chọn điểm đến của bé.';

  @override
  String get safeRouteHintMissingPoints =>
      'Chọn điểm A và điểm B theo phong cách bản đồ, sau đó xem các tuyến gợi ý.';

  @override
  String get safeRouteHintReadyChooseRoute =>
      'Đã có đủ điểm đi và điểm đến. Bạn có thể chọn tuyến an toàn nhất để bắt đầu giám sát.';

  @override
  String get safeRouteEmptyRoutesNeedPoints =>
      'Hãy chọn cả điểm đi và điểm đến để app đề xuất các tuyến đường an toàn.';

  @override
  String get safeRouteEmptyRoutesRefresh =>
      'Nhấn \"Làm mới\" hoặc nút phía dưới để lấy lại danh sách tuyến gợi ý.';

  @override
  String get safeRoutePrimaryActionSaveSchedule =>
      'Lưu tuyến và lên lịch theo dõi';

  @override
  String get safeRoutePrimaryActionStartSelectedRoutes =>
      'Bắt đầu theo dõi các tuyến đã chọn';

  @override
  String get safeRoutePrimaryActionSelectThisRoute =>
      'Chọn tuyến này và bắt đầu theo dõi';

  @override
  String get safeRouteSelectedRoutesNeedPrimary =>
      'Hãy chọn 1 tuyến chính và có thể thêm tối đa 2 tuyến phụ.';

  @override
  String get safeRouteSelectedRoutesPrimaryOnly =>
      'Đã chọn 1 tuyến chính. Bạn có thể thêm tối đa 2 tuyến phụ.';

  @override
  String safeRouteSelectedRoutesWithAlternatives(int count) {
    return 'Đã chọn 1 tuyến chính và $count tuyến phụ.';
  }

  @override
  String get safeRouteActionStopTracking => 'Dừng theo dõi';

  @override
  String get safeRouteActionViewRoute => 'Xem tuyến';

  @override
  String get safeRouteActionMarkArrived => 'Đánh dấu đã đến';

  @override
  String get safeRouteActionCancelSchedule => 'Hủy lịch';

  @override
  String get safeRouteActionChooseNewRoute => 'Chọn tuyến mới';

  @override
  String get safeRouteActionRouteDetails => 'Chi tiết tuyến';

  @override
  String get safeRouteStatusSubtitleActive => 'Bé đang bám sát tuyến đã chọn';

  @override
  String get safeRouteStatusSubtitleTemporarilyDeviated =>
      'Có dấu hiệu lệch nhẹ, hệ thống đang tiếp tục theo dõi';

  @override
  String get safeRouteStatusSubtitleDeviated =>
      'Bé đã lệch khỏi corridor an toàn';

  @override
  String get safeRouteStatusSubtitleCompleted => 'Hành trình đã hoàn tất';

  @override
  String get safeRouteStatusSubtitleCancelled => 'Phụ huynh đã dừng giám sát';

  @override
  String get safeRouteStatusSubtitlePlanned =>
      'Tuyến đang chờ tới giờ để tự kích hoạt';

  @override
  String get safeRouteStatusSubtitleNoData => 'Chưa có dữ liệu giám sát';

  @override
  String get safeRouteSpeedStanding => 'Đứng yên';

  @override
  String get safeRouteSpeedWalking => 'Đi bộ';

  @override
  String get safeRouteSpeedCycling => 'Đi xe đạp';

  @override
  String get safeRouteSpeedMoving => 'Di chuyển';

  @override
  String get safeRouteMetricSpeed => 'Tốc độ';

  @override
  String get safeRouteMetricOffRoute => 'Lệch tuyến';

  @override
  String get safeRouteMetricOffCorridor => 'Ngoài corridor';

  @override
  String get safeRouteMetricEta => 'Đến nơi';

  @override
  String get safeRouteMetricEtaEstimate => 'Ước tính';

  @override
  String get safeRouteDangerCheckNow => 'Cần kiểm tra ngay';

  @override
  String get safeRouteDeviceBatteryLabel => 'Pin thiết bị';

  @override
  String get safeRouteProgressTitle => 'Tiến độ hành trình';

  @override
  String safeRouteProgressCompletedPercent(int percent) {
    return 'Đã đi $percent%';
  }

  @override
  String safeRouteProgressTraveled(Object traveled, Object total) {
    return 'Đã đi $traveled/$total';
  }

  @override
  String safeRouteProgressRemainingPercent(int percent) {
    return 'Còn lại $percent%';
  }

  @override
  String safeRouteProgressRemaining(Object distance) {
    return 'Còn $distance';
  }

  @override
  String get safeRouteFromLabel => 'Từ';

  @override
  String get safeRouteToLabel => 'Đến';

  @override
  String get safeRouteSearchOrSelectStart => 'Tìm hoặc chọn điểm đi';

  @override
  String get safeRouteSearchOrSelectEnd => 'Tìm hoặc chọn điểm đến';

  @override
  String get safeRouteScheduleTitle => 'Lịch áp dụng tuyến';

  @override
  String get safeRouteScheduleSubtitle =>
      'Đặt ngày, giờ và chọn các ngày lặp lại cho tuyến đường an toàn này.';

  @override
  String get safeRouteDateLabel => 'Ngày';

  @override
  String get safeRouteTimeLabel => 'Giờ';

  @override
  String get safeRouteRepeatByDayLabel => 'Lặp lại theo ngày';

  @override
  String get safeRouteHistoryTripsTitle => 'Lịch sử chuyến đường an toàn';

  @override
  String get safeRouteHistoryTripsEmpty =>
      'Chưa có chuyến nào được lưu cho bé.';

  @override
  String get safeRouteHistoryTripsSubtitle =>
      'Chạm vào từng chuyến để xem lại tuyến đường và trạng thái di chuyển.';

  @override
  String get safeRouteHistoryPageTitle => 'Lịch sử tuyến đường';

  @override
  String get safeRouteHistoryPageReviewSaved =>
      'Xem lại toàn bộ hành trình an toàn đã lưu';

  @override
  String get safeRouteHistoryEmptyState =>
      'Chưa có tuyến đường nào được lưu trong lịch sử Safe Route.';

  @override
  String get safeRouteNoRepeatLabel => 'Không lặp lại';

  @override
  String get safeRouteBadgeSafest => 'An toàn nhất';

  @override
  String get safeRouteBadgeFewerHazards => 'Ít vùng nguy hiểm';

  @override
  String get safeRouteBadgeFaster => 'Nhanh hơn';

  @override
  String get safeRouteBadgeAlternative => 'Tuyến phụ';

  @override
  String get safeRouteRolePrimary => 'Tuyến chính';

  @override
  String get safeRouteRoleAlternative => 'Tuyến phụ';

  @override
  String safeRouteCorridorLabel(Object distance) {
    return '$distance corridor';
  }

  @override
  String get safeRouteActionPrimarySelected => 'Đang là tuyến chính';

  @override
  String get safeRouteActionSetPrimary => 'Đặt làm tuyến chính';

  @override
  String get safeRouteActionRemoveAlternative => 'Bỏ tuyến phụ';

  @override
  String get safeRouteActionSelectAlternative => 'Chọn tuyến phụ';

  @override
  String get safeRouteActionAlternativeLimitReached => 'Đã đủ tuyến phụ';

  @override
  String get safeRouteRouteDescriptionStable =>
      'Tuyến khá ổn định, gần như không đi vào vùng nguy hiểm.';

  @override
  String get safeRouteRouteDescriptionOneHazard =>
      'Có 1 điểm cần lưu ý nhưng vẫn phù hợp để theo dõi an toàn.';

  @override
  String get safeRouteRouteDescriptionMoreHazards =>
      'Tuyến đi nhanh hơn nhưng cần chú ý vì có nhiều vùng cảnh báo hơn.';

  @override
  String safeRouteHazardCount(int count) {
    return '$count vùng nguy hiểm';
  }

  @override
  String safeRouteAlternativeRouteCount(int count) {
    return '+$count tuyến phụ';
  }

  @override
  String get cupertinoTimePickerDoneButton => 'Xong';

  @override
  String get childLocationUpdatedOneHourAgo => 'Cập nhật 1 giờ trước';

  @override
  String childLocationUpdatedHoursAgo(int hours) {
    return 'Cập nhật $hours giờ trước';
  }

  @override
  String get validationPasswordRequired => 'Vui lòng nhập mật khẩu';

  @override
  String get validationPasswordMinLength => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get validationPasswordUppercaseRequired =>
      'Mật khẩu phải có ít nhất 1 chữ hoa';

  @override
  String get validationPasswordLowercaseRequired =>
      'Mật khẩu phải có ít nhất 1 chữ thường';

  @override
  String get validationPasswordNumberRequired =>
      'Mật khẩu phải có ít nhất 1 chữ số';

  @override
  String get validationPasswordConfirmRequired => 'Vui lòng nhập lại mật khẩu';

  @override
  String get firebaseAuthOperationNotAllowed =>
      'Chức năng tạo tài khoản chưa được bật trong Firebase Auth';

  @override
  String get userRepositoryCreateAccountFailed => 'Không thể tạo tài khoản';

  @override
  String get firestorePermissionDenied => 'Bạn không có quyền ghi dữ liệu';

  @override
  String get firestoreUnavailable => 'Firestore tạm thời không khả dụng';

  @override
  String get firestoreGenericError => 'Lỗi Firestore';

  @override
  String get userRepositoryCreateChildFailed => 'Không thể tạo tài khoản con';

  @override
  String get mapPlaceSearchMissingAccessToken =>
      'Thiếu ACCESS_TOKEN Mapbox cho tìm kiếm địa điểm.';

  @override
  String mapPlaceSearchRequestFailed(int statusCode) {
    return 'Tìm kiếm địa điểm thất bại ($statusCode).';
  }

  @override
  String get mapPlaceSearchInvalidResponse =>
      'Dữ liệu trả về từ Mapbox không hợp lệ.';

  @override
  String get mapPlaceSearchTimeout =>
      'Tìm kiếm địa điểm quá thời gian, vui lòng thử lại.';

  @override
  String get mapPlaceSearchDecodeFailed => 'Không thể đọc dữ liệu địa điểm.';

  @override
  String get mapPlaceSearchUnexpectedError =>
      'Có lỗi xảy ra khi tìm kiếm địa điểm.';

  @override
  String get mapPlaceSearchNoAddress => 'Không có địa chỉ';

  @override
  String get mapPlaceSearchDefaultName => 'Địa điểm';
}
