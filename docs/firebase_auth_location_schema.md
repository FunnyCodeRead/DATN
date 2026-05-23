# Thiết kế dữ liệu Firebase cho Auth + Location

## Phạm vi

- Tài liệu này coi mỗi `collection/document root` của Firestore và mỗi `node root` của Realtime Database là một "bảng".
- Phạm vi v1 chỉ gồm `auth`, `tài khoản`, `location`, `zone`, `safe route`, `SOS`.
- Không đưa `chat`, `memory day`, `birthday`, `app management` vào schema chính của tài liệu này.

## Quy ước

- Cột chuẩn cho mọi bảng: `Tên trường | Kiểu dữ liệu | Ràng buộc`.
- Field lồng dùng `dot-notation`, ví dụ `location.lat`, `subscription.plan`.
- Mảng ghi rõ dạng `array<string>`, `array<int>`, `array<object>`.
- Kiểu thời gian được ghi đúng theo wire format hiện tại:
  - `timestamp (Firestore)`: Firestore `Timestamp` hoặc `serverTimestamp()`.
  - `number epoch_ms (RTDB)`: số milliseconds từ Unix epoch trong Realtime Database.
  - `number epoch_ms (Firestore)`: ngoại lệ hiện có ở module `safe route`; tài liệu giữ nguyên theo code hiện tại, không ép về `Timestamp`.
- Mọi ràng buộc tham chiếu path được ghi trực tiếp trong cột `Ràng buộc`.
- `Firebase Auth` là hệ thống ngoài; tài liệu chỉ ghi dependency, không coi là bảng app-managed.

## External Dependency

### `Firebase Auth`

- Storage: `External`
- Khóa: `uid`
- Ghi chú: nguồn chuẩn cho định danh người dùng; app map sang `users/{uid}` trong Firestore.

## Firestore

### `users/{uid}`

- Storage: `Firestore`
- Khóa: `docId = uid`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| uid | string | Bắt buộc; phải trùng `docId` |
| role | string | Bắt buộc; `parent \| child \| guardian` |
| email | string | Tùy chọn; nên khớp email của `Firebase Auth` |
| displayName | string | Tùy chọn; tên hiển thị người dùng |
| phone | string | Tùy chọn; số điện thoại người dùng |
| gender | string | Tùy chọn; giá trị text tự do từ profile |
| address | string | Tùy chọn; địa chỉ tự do |
| dob | timestamp (Firestore) | Chuẩn hiện hành; app vẫn đọc fallback legacy `string` nếu còn dữ liệu cũ |
| dobIso | string | Tùy chọn; format `YYYY-MM-DD` khi có |
| birthMonth | number | Tùy chọn; số nguyên `1..12` |
| birthDay | number | Tùy chọn; số nguyên `1..31` |
| birthYear | number | Tùy chọn; số nguyên năm sinh |
| avatarUrl | string | Tùy chọn; URL ảnh đại diện |
| coverUrl | string | Tùy chọn; URL ảnh bìa |
| locale | string | Tùy chọn; mặc định thường là `vi` |
| timezone | string | Tùy chọn; IANA timezone như `Asia/Ho_Chi_Minh` |
| familyId | string | Bắt buộc sau provisioning; tham chiếu `families/{familyId}` |
| parentUid | string | Bắt buộc với `child` hoặc `guardian`; tham chiếu `users/{uid}` |
| isActive | boolean | Bắt buộc; trạng thái hoạt động tài khoản |
| allowTracking | boolean | Với `child` mặc định coi là `true` nếu field thiếu; role khác mặc định `false` |
| managedChildIds | array<string> | Chỉ dùng cho `guardian`; phần tử không trùng lặp; tham chiếu `users/{uid}` có role `child` |
| subscription.plan | string | Tùy chọn; `free \| pro` |
| subscription.status | string | Tùy chọn; `trial \| active \| expired \| canceled \| payment_failed` |
| subscription.startAt | timestamp (Firestore) | Tùy chọn; thời điểm bắt đầu gói |
| subscription.endAt | timestamp (Firestore) | Tùy chọn; thời điểm kết thúc gói |
| subscription.isTrial | boolean | Tùy chọn; mặc định `false` |
| subscription.autoRenew | boolean | Tùy chọn; mặc định `true` |
| subscription.productId | string | Tùy chọn; mã sản phẩm subscription |
| subscription.platform | string | Tùy chọn; nền tảng mua gói |
| subscription.updatedAt | timestamp (Firestore) | Tùy chọn; mặc định ghi bằng `serverTimestamp()` |
| createdAt | timestamp (Firestore) | Tùy chọn; `serverTimestamp()` khi provisioning |
| lastActiveAt | timestamp (Firestore) | Tùy chọn; cập nhật bằng `serverTimestamp()` khi user hoạt động |

### `families/{familyId}`

- Storage: `Firestore`
- Khóa: `docId = familyId` (auto-generated)

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| createdBy | string | Bắt buộc; tham chiếu `users/{uid}` |
| createdAt | timestamp (Firestore) | Bắt buộc; `serverTimestamp()` khi tạo family |
| lastMessageAt | timestamp (Firestore) | Tùy chọn; chỉ dùng cho family chat summary |
| lastMessageBy | string | Tùy chọn; tham chiếu `users/{uid}` gửi tin nhắn gần nhất |
| lastMessageText | string | Tùy chọn; preview tin nhắn gần nhất |

### `families/{familyId}/members/{uid}`

- Storage: `Firestore`
- Khóa: `docId = uid`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| uid | string | Bắt buộc; phải trùng `docId` |
| role | string | Bắt buộc; `parent \| child \| guardian` |
| familyId | string | Bắt buộc; phải khớp `{familyId}` trên path |
| displayName | string | Tùy chọn; mirror từ `users/{uid}` |
| avatarUrl | string | Bắt buộc theo mirror; có thể là chuỗi rỗng |
| isActive | boolean | Bắt buộc; mirror từ `users/{uid}` |
| lastActiveAt | timestamp (Firestore) | Tùy chọn; mirror từ `users/{uid}.lastActiveAt` |
| birthMonth | number | Tùy chọn; số nguyên `1..12` |
| birthDay | number | Tùy chọn; số nguyên `1..31` |
| birthYear | number | Tùy chọn; năm sinh đã projection |
| joinedAt | timestamp (Firestore) | Tùy chọn; thời điểm thành viên được gắn vào family |
| updatedAt | timestamp (Firestore) | Bắt buộc; `serverTimestamp()` mỗi lần mirror |

### `families/{familyId}/locationMembers/{uid}`

- Storage: `Firestore`
- Khóa: `docId = uid`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| uid | string | Bắt buộc; phải trùng `docId` |
| role | string | Bắt buộc; chỉ nhận `parent \| guardian \| child` |
| familyId | string | Bắt buộc; phải khớp `{familyId}` trên path |
| displayName | string | Tùy chọn; tên hiển thị để render bản đồ |
| avatarUrl | string | Bắt buộc theo mirror; có thể là chuỗi rỗng |
| parentUid | string | Tùy chọn; bắt buộc thực tế với `child` hoặc `guardian` nếu có owner |
| isActive | boolean | Bắt buộc; mirror từ user profile |
| allowTracking | boolean | Với `child` luôn phải đánh giá thành `true` |
| lastActiveAt | timestamp (Firestore) | Tùy chọn; mirror từ `users/{uid}.lastActiveAt` |
| updatedAt | timestamp (Firestore) | Bắt buộc; `serverTimestamp()` mỗi lần mirror |

### `families/{familyId}/managementMembers/{uid}`

- Storage: `Firestore`
- Khóa: `docId = uid`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| uid | string | Bắt buộc; phải trùng `docId` |
| role | string | Bắt buộc; hiện chỉ mirror `child \| guardian` |
| familyId | string | Bắt buộc; phải khớp `{familyId}` trên path |
| parentUid | string | Bắt buộc; tham chiếu `users/{uid}` là owner parent |
| displayName | string | Tùy chọn; tên hiển thị phục vụ phân quyền |
| avatarUrl | string | Bắt buộc theo mirror; có thể là chuỗi rỗng |
| managedChildIds | array<string> | Tùy chọn; chủ yếu dùng cho `guardian`; phần tử không trùng lặp |
| updatedAt | timestamp (Firestore) | Bắt buộc; `serverTimestamp()` mỗi lần mirror |

### `fcmInstallations/{installationId}`

- Storage: `Firestore`
- Khóa: `docId = installationId`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| installationId | string | Bắt buộc; phải trùng `docId`; tối thiểu 8 ký tự |
| token | string | Bắt buộc; tối thiểu 20 ký tự |
| uid | string | Bắt buộc; tham chiếu `users/{uid}` |
| familyId | string | Tùy chọn; tham chiếu `families/{familyId}` |
| platform | string | Bắt buộc; `android \| ios` |
| updatedAt | timestamp (Firestore) | Bắt buộc; `serverTimestamp()` khi register/update |
| lastSeenAt | timestamp (Firestore) | Bắt buộc; `serverTimestamp()` khi register/update |

### `email_otps/{otpId}`

- Storage: `Firestore`
- Khóa: `docId = otpId`
- Pattern khóa:
  - `verify-email:{uid}`
  - `reset-password:{emailHash}`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| type | string | Bắt buộc; `verify-email \| reset-password` |
| uid | string | Nullable với `reset-password`; bắt buộc với `verify-email` |
| email | string | Bắt buộc; email target của challenge |
| emailHash | string | Bắt buộc; SHA-256 hex của email |
| otpHash | string | Bắt buộc; hash OTP đã salt |
| otpSalt | string | Bắt buộc; salt ngẫu nhiên dạng hex |
| attempts | number | Bắt buộc; số nguyên `>= 0` |
| maxAttempts | number | Bắt buộc; số nguyên, mặc định `3` |
| lockedUntil | timestamp (Firestore) | Tùy chọn; thời điểm khóa challenge |
| expiresAt | timestamp (Firestore) | Bắt buộc; TTL của challenge |
| createdAt | timestamp (Firestore) | Bắt buộc; thời điểm tạo challenge |
| updatedAt | timestamp (Firestore) | Bắt buộc; thời điểm cập nhật gần nhất |

### `mail_queue/{mailId}`

- Storage: `Firestore`
- Khóa: `docId = mailId` (auto-generated)

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| to | string | Bắt buộc; email người nhận |
| type | string | Bắt buộc; `verify_email \| reset_password` |
| code | string | Bắt buộc; OTP gửi ra email |
| uid | string | Tùy chọn; tham chiếu `users/{uid}` khi có user nội bộ |
| createdAt | timestamp (Firestore) | Bắt buộc; thời điểm enqueue mail |
| status | string | Bắt buộc; `pending \| processing \| sent \| error` |
| processingStartedAt | timestamp (Firestore) | Tùy chọn; set khi worker claim job |
| updatedAt | timestamp (Firestore) | Tùy chọn; `serverTimestamp()` khi worker cập nhật |
| sentAt | timestamp (Firestore) | Tùy chọn; thời điểm gửi mail thành công |
| provider | string | Tùy chọn; provider hiện hành như `resend` |
| providerMessageId | string | Tùy chọn; message id do provider trả về |
| lastError | string | Tùy chọn; lỗi gần nhất khi retry |
| error | string | Tùy chọn; lỗi chốt khi job đi vào trạng thái `error` |

### `auth_rate_limits/{rateId}`

- Storage: `Firestore`
- Khóa: `docId = hash(scope + key)`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| scope | string | Bắt buộc; namespace rate limit |
| key | string | Bắt buộc; khóa logic như email/IP/user |
| count | number | Bắt buộc; số nguyên `>= 0` |
| createdAt | timestamp (Firestore) | Bắt buộc; thời điểm bucket được tạo |
| updatedAt | timestamp (Firestore) | Bắt buộc; thời điểm bucket cập nhật gần nhất |
| expiresAt | timestamp (Firestore) | Bắt buộc; hết hạn cửa sổ throttling |

### `reset_sessions/{sessionId}`

- Storage: `Firestore`
- Khóa: `docId = hash(reset token)`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| uid | string | Bắt buộc; tham chiếu `users/{uid}` |
| emailHash | string | Bắt buộc; SHA-256 hex của email |
| expiresAt | timestamp (Firestore) | Bắt buộc; TTL session reset |
| used | boolean | Bắt buộc; mặc định `false` khi tạo |
| createdAt | timestamp (Firestore) | Bắt buộc; thời điểm tạo session |
| usedAt | timestamp (Firestore) | Tùy chọn; chỉ có khi session đã consume |

### `notifications/{notificationId}`

- Storage: `Firestore`
- Khóa: `docId = notificationId`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| senderId | string | Bắt buộc; định danh actor tạo notification |
| receiverId | string | Bắt buộc; tham chiếu `users/{uid}` |
| type | string | Bắt buộc; wire event type của notification |
| title | string | Bắt buộc; tiêu đề hiển thị |
| body | string | Bắt buộc; nội dung hiển thị |
| eventKey | string | Tùy chọn; khóa business để dedupe/trace event |
| familyId | string | Tùy chọn; tham chiếu `families/{familyId}` |
| eventCategory | string | Tùy chọn; nhóm sự kiện business |
| expiresAt | timestamp (Firestore) | Tùy chọn; thời điểm hết hiệu lực |
| data | map<string,string\|number\|bool> | Bắt buộc; mặc định `{}` |
| isRead | boolean | Bắt buộc; mặc định `false` |
| status | string | Bắt buộc; mặc định `pending` |
| createdAt | timestamp (Firestore) | Bắt buộc; `serverTimestamp()` khi tạo |

### `families/{familyId}/sos/{sosId}`

- Storage: `Firestore`
- Khóa: `docId = sosId`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| createdBy | string | Bắt buộc; tham chiếu `users/{uid}` |
| createdByRole | string | Bắt buộc; `child \| parent \| guardian` |
| createdByName | string | Bắt buộc; tên hiển thị snapshot tại thời điểm gửi SOS |
| createdAt | timestamp (Firestore) | Bắt buộc; `serverTimestamp()` khi tạo SOS |
| status | string | Bắt buộc; `active \| resolved` |
| location.lat | number | Bắt buộc; `-90..90` |
| location.lng | number | Bắt buộc; `-180..180` |
| location.acc | number | Tùy chọn; độ chính xác vị trí, `>= 0` |
| dayKey | string | Bắt buộc; format `YYYY-MM-DD` |
| resolvedBy | string | Tùy chọn; chỉ có khi `status = resolved`; tham chiếu `users/{uid}` |
| resolvedAt | timestamp (Firestore) | Tùy chọn; chỉ có khi `status = resolved` |
| reminder.initialPushSent | boolean | Bắt buộc; mặc định `false` |
| reminder.lastAttempt | number | Bắt buộc; số nguyên lần retry gần nhất |
| reminder.lastSentAt | timestamp (Firestore) | Tùy chọn; thời điểm gửi reminder gần nhất |
| reminder.lastSuccess | number | Tùy chọn; số token gửi thành công ở lần retry gần nhất |
| reminder.nextAttempt | number | Tùy chọn; số thứ tự lần retry tiếp theo |
| reminder.scheduleState | string | Bắt buộc; hiện dùng `pending \| scheduled \| missing` |
| reminder.stoppedAt | timestamp (Firestore) | Tùy chọn; set khi SOS được resolve |
| reminder.workerLeaseAttempt | number | Tùy chọn; lần retry đang được worker claim |
| reminder.workerLeaseTaskName | string | Tùy chọn; Cloud Tasks name đang lease |
| reminder.workerLeaseAt | timestamp (Firestore) | Tùy chọn; thời điểm worker lease |
| reminder.updatedAt | timestamp (Firestore) | Tùy chọn; `serverTimestamp()` khi worker cập nhật |
| reminder.lastError | string | Tùy chọn; lỗi gần nhất của worker retry |
| reminder.lastErrorAt | timestamp (Firestore) | Tùy chọn; thời điểm ghi lỗi gần nhất |
| reminder.lastTaskName | string | Tùy chọn; task name của lần retry gần nhất |
| fanout.sentAt | timestamp (Firestore) | Tùy chọn; thời điểm fanout initial push thành công |
| fanout.attempted | number | Tùy chọn; bộ đếm số lần claim initial fanout |
| fanout.attemptedRecipients | number | Tùy chọn; số recipient/token group đã thử gửi |
| fanout.success | number | Tùy chọn; số recipient/token group gửi thành công |
| fanout.invalidTokensRemoved | number | Tùy chọn; số installation invalid bị dọn |
| fanout.claimedAt | timestamp (Firestore) | Tùy chọn; thời điểm initial fanout đang bị lease |
| fanout.claimId | string | Tùy chọn; id lease của lần fanout hiện tại |
| fanout.lastError | string | Tùy chọn; lỗi gần nhất của nhánh initial fanout |
| fanout.lastErrorAt | timestamp (Firestore) | Tùy chọn; thời điểm ghi lỗi fanout gần nhất |

### `routes/{routeId}`

- Storage: `Firestore`
- Khóa: `docId = routeId`
- Ghi chú: module `safe route` đang lưu thời gian dưới dạng `number epoch_ms (Firestore)`.

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| id | string | Bắt buộc; phải trùng `docId` |
| childId | string | Bắt buộc; tham chiếu `users/{uid}` có role `child` |
| parentId | string | Tùy chọn; tham chiếu `users/{uid}` là owner manager |
| name | string | Bắt buộc; tên tuyến safe route |
| startPoint.latitude | number | Bắt buộc; `-90..90` |
| startPoint.longitude | number | Bắt buộc; `-180..180` |
| startPoint.sequence | number | Bắt buộc; số nguyên, mặc định `0` |
| endPoint.latitude | number | Bắt buộc; `-90..90` |
| endPoint.longitude | number | Bắt buộc; `-180..180` |
| endPoint.sequence | number | Bắt buộc; số nguyên, thường là điểm cuối |
| points | array<object> | Bắt buộc; ít nhất 2 phần tử `{latitude, longitude, sequence}` |
| hazards | array<object> | Bắt buộc; phần tử gồm `id,name,latitude,longitude,radiusMeters,riskLevel,sourceZoneId` |
| corridorWidthMeters | number | Bắt buộc; `> 0` |
| distanceMeters | number | Bắt buộc; `>= 0` |
| durationSeconds | number | Bắt buộc; `>= 0` |
| travelMode | string | Bắt buộc; `walking \| motorbike \| pickup \| otherVehicle` |
| profile | string | Tùy chọn; profile map provider, hiện thường là `walking` hoặc `driving` |
| createdAt | number epoch_ms (Firestore) | Bắt buộc; thời điểm route được persist |
| updatedAt | number epoch_ms (Firestore) | Bắt buộc; thời điểm route cập nhật gần nhất |

### `trips/{tripId}`

- Storage: `Firestore`
- Khóa: `docId = tripId`
- Ghi chú: `previewRoute` và `previewAlternativeRoutes` là payload đầu vào callable, không phải field persist chuẩn của document `trips`.

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| id | string | Bắt buộc; phải trùng `docId` |
| childId | string | Bắt buộc; tham chiếu `users/{uid}` có role `child` |
| parentId | string | Bắt buộc; tham chiếu `users/{uid}` là owner manager |
| routeId | string | Bắt buộc; tham chiếu `routes/{routeId}` |
| alternativeRouteIds | array<string> | Tùy chọn; không được trùng lặp; tham chiếu `routes/{routeId}` |
| currentRouteId | string | Tùy chọn; tham chiếu `routes/{routeId}` đang được follow |
| routeName | string | Tùy chọn; snapshot tên route tại thời điểm trip |
| status | string | Bắt buộc; `planned \| active \| temporarilyDeviated \| deviated \| completed \| cancelled` |
| reason | string | Tùy chọn; lý do đổi trạng thái trip |
| consecutiveDeviationCount | number | Bắt buộc; số nguyên `>= 0` |
| currentDistanceFromRouteMeters | number | Bắt buộc; `>= 0` |
| startedAt | number epoch_ms (Firestore) | Bắt buộc; thời điểm trip bắt đầu hoặc scheduled start |
| updatedAt | number epoch_ms (Firestore) | Bắt buộc; thời điểm trip cập nhật gần nhất |
| scheduledStartAt | number epoch_ms (Firestore) | Tùy chọn; chỉ có với trip lên lịch |
| repeatWeekdays | array<int> | Tùy chọn; mỗi phần tử thuộc `1..7` |
| lastScheduledActivationAt | number epoch_ms (Firestore) | Tùy chọn; lần activation gần nhất của trip lặp |
| lastLocation | map | Tùy chọn; snapshot live location của trip |
| lastDeviationAlertAt | number epoch_ms (Firestore) | Tùy chọn; thời điểm cảnh báo lệch tuyến gần nhất |
| lastDangerAlertAt | number epoch_ms (Firestore) | Tùy chọn; thời điểm cảnh báo danger gần nhất |
| lastDangerHazardId | string | Tùy chọn; hazard gần nhất đã trigger |
| lastBackOnRouteAlertAt | number epoch_ms (Firestore) | Tùy chọn; thời điểm cảnh báo quay lại route |
| lastReturnedToStartAlertAt | number epoch_ms (Firestore) | Tùy chọn; thời điểm cảnh báo quay lại điểm đầu |
| lastStationaryAlertAt | number epoch_ms (Firestore) | Tùy chọn; thời điểm cảnh báo đứng yên |
| hasLeftStartArea | boolean | Tùy chọn; đã rời vùng điểm bắt đầu hay chưa |
| isNearStartArea | boolean | Tùy chọn; cờ proximity với vùng điểm bắt đầu |
| stationaryAnchorLatitude | number | Tùy chọn; `-90..90` |
| stationaryAnchorLongitude | number | Tùy chọn; `-180..180` |
| stationarySinceAt | number epoch_ms (Firestore) | Tùy chọn; mốc bắt đầu đứng yên |
| hasStationaryAlertActive | boolean | Tùy chọn; cờ chống gửi lặp cảnh báo đứng yên |

### `safe_route_current_trips/{childUid}`

- Storage: `Firestore`
- Khóa: `docId = childUid`
- Ghi chú: các field trip lồng bên trong giữ nguyên shape của `Trip` wire record hiện tại.

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| childId | string | Bắt buộc; phải trùng `docId` và tham chiếu `users/{uid}` có role `child` |
| adultCurrentTrip | map | Tùy chọn; embedded `Trip` dành cho audience người lớn |
| adultRecentCompletedTrip | map | Tùy chọn; embedded `Trip` vừa hoàn tất trong cửa sổ hiển thị |
| adultCurrentTripVisibleUntil | number epoch_ms (Firestore) | Tùy chọn; chỉ còn hiệu lực hiển thị đến mốc này |
| childMonitorTrip | map | Tùy chọn; embedded `Trip` dành cho child monitor |
| updatedAt | number epoch_ms (Firestore) | Bắt buộc; thời điểm snapshot được đồng bộ gần nhất |

## Realtime Database

### `locations/{childUid}/meta`

- Storage: `RTDB`
- Khóa: `path key = childUid/meta`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| parentUid | string | Bắt buộc; tham chiếu `users/{uid}` là owner parent |
| familyId | string | Bắt buộc; tham chiếu `families/{familyId}` |
| historyTimeZone | string | Bắt buộc; IANA timezone dùng để partition history |
| historyPartitionVersion | number | Bắt buộc; số nguyên dương |
| historyPartitionCutoverAt | number epoch_ms (RTDB) | Bắt buộc; anchor timestamp để đổi partition theo timezone |
| updatedAt | number epoch_ms (RTDB) | Bắt buộc; `ServerValue.timestamp` khi update |

### `locations/{childUid}/current`

- Storage: `RTDB`
- Khóa: `path key = childUid/current`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| deviceId | string | Bắt buộc; định danh thiết bị đang publish |
| accuracy | number | Bắt buộc; `>= 0` |
| latitude | number | Bắt buộc; `-90..90` |
| longitude | number | Bắt buộc; `-180..180` |
| speed | number | Bắt buộc; `>= 0` |
| heading | number | Bắt buộc; nên nằm trong `0..360` |
| isMock | boolean | Bắt buộc; cờ phát hiện mock location |
| timestamp | number epoch_ms (RTDB) | Bắt buộc; phải tăng đơn điệu so với bản ghi hiện tại |
| motion | string | Tùy chọn; nhãn chuyển động từ tracker |
| transport | string | Tùy chọn; nhãn phương tiện từ tracker |
| familyId | string | Bắt buộc; tham chiếu `families/{familyId}` khi publish current |
| updatedAt | number epoch_ms (RTDB) | Bắt buộc; `ServerValue.timestamp` khi update |

### `locations/{childUid}/historyByDay/{dayKey}/{timestamp}`

- Storage: `RTDB`
- Khóa:
  - `dayKey = YYYY-MM-DD`
  - `timestamp = epoch_ms`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| deviceId | string | Bắt buộc; định danh thiết bị nguồn |
| accuracy | number | Bắt buộc; `>= 0` |
| latitude | number | Bắt buộc; `-90..90` |
| longitude | number | Bắt buộc; `-180..180` |
| speed | number | Bắt buộc; `>= 0` |
| heading | number | Bắt buộc; nên nằm trong `0..360` |
| isMock | boolean | Bắt buộc; cờ mock location |
| timestamp | number epoch_ms (RTDB) | Bắt buộc; phải khớp key cuối trên path |
| motion | string | Tùy chọn; nhãn chuyển động từ tracker |
| transport | string | Tùy chọn; nhãn phương tiện từ tracker |
| sentAt | number epoch_ms (RTDB) | Bắt buộc; `ServerValue.timestamp` khi append history |

### `live_locations/{childUid}`

- Storage: `RTDB`
- Khóa: `path key = childUid`
- Ghi chú: đây là mirror trusted location do backend đánh giá, không phải raw publish trực tiếp từ client.

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| latitude | number | Bắt buộc; `-90..90` |
| longitude | number | Bắt buộc; `-180..180` |
| accuracy | number | Bắt buộc; `>= 0` |
| speed | number | Bắt buộc; `>= 0` |
| heading | number | Bắt buộc; nên nằm trong `0..360` |
| batteryLevel | number | Tùy chọn; thường `0..100` |
| isMock | boolean | Bắt buộc; chỉ mirror từ trusted evaluator |
| timestamp | number epoch_ms (RTDB) | Bắt buộc; timestamp trusted location |
| source | string | Bắt buộc; hiện hành là `server_trusted_location` |
| trustState | string | Bắt buộc; hiện hành là `trusted` |
| trustEvaluatedAt | number epoch_ms (RTDB) | Bắt buộc; thời điểm backend đánh giá trust |
| trustedHeartbeatAt | number epoch_ms (RTDB) | Tùy chọn; heartbeat trusted gần nhất |
| trustedRawTimestamp | number epoch_ms (RTDB) | Tùy chọn; raw timestamp gốc trước khi mirror |

### `zonesByChild/{childUid}/{zoneId}`

- Storage: `RTDB`
- Khóa: `path key = childUid/zoneId`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| name | string | Bắt buộc; tối đa 60 ký tự |
| type | string | Bắt buộc; `safe \| danger` |
| lat | number | Bắt buộc; `-90..90` |
| lng | number | Bắt buộc; `-180..180` |
| radiusM | number | Bắt buộc; `20..5000` |
| enabled | boolean | Bắt buộc; mặc định `true` nếu không truyền |
| createdBy | string | Bắt buộc; tham chiếu `users/{uid}` tạo zone |
| createdAt | number epoch_ms (RTDB) | Bắt buộc; timestamp tạo zone |
| updatedAt | number epoch_ms (RTDB) | Bắt buộc; timestamp cập nhật gần nhất |

### `zonePresenceByChild/{childUid}/{zoneId}`

- Storage: `RTDB`
- Khóa: `path key = childUid/zoneId`
- Ghi chú: node chỉ nên tồn tại khi child đang ở trong zone.

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| inside | boolean | Bắt buộc; phải là `true` nếu node còn tồn tại |
| zoneType | string | Bắt buộc; `safe \| danger` |
| zoneName | string | Bắt buộc; snapshot tên zone tại thời điểm enter |
| enterAt | number epoch_ms (RTDB) | Bắt buộc; mốc vào zone |
| updatedAt | number epoch_ms (RTDB) | Bắt buộc; timestamp cập nhật presence |
| source | string | Bắt buộc; hiện hành là `server_zone_evaluator` |

### `zoneEventsByChild/{childUid}/{eventId}`

- Storage: `RTDB`
- Khóa: `path key = childUid/eventId`

| Tên trường | Kiểu dữ liệu | Ràng buộc |
| --- | --- | --- |
| canonical | boolean | Bắt buộc; phải là `true` |
| source | string | Bắt buộc; hiện hành là `server_zone_evaluator` |
| childUid | string | Bắt buộc; phải khớp `{childUid}` trên path |
| zoneId | string | Bắt buộc; tham chiếu `zonesByChild/{childUid}/{zoneId}` |
| zoneType | string | Bắt buộc; `safe \| danger` |
| action | string | Bắt buộc; `enter \| exit` |
| zoneName | string | Bắt buộc; snapshot tên zone |
| timestamp | number epoch_ms (RTDB) | Bắt buộc; thời điểm event được phát hiện |
| lat | number | Bắt buộc; `-90..90` |
| lng | number | Bắt buộc; `-180..180` |
| enterAt | number epoch_ms (RTDB) | Bắt buộc; bằng thời điểm vào zone, kể cả lúc tính exit duration |
| durationSec | number | Bắt buộc; `0` với `enter`, `>= 0` với `exit` |
| durationMin | number | Bắt buộc; `0` với `enter`, `>= 0` với `exit` |
| createdAt | number epoch_ms (RTDB) | Bắt buộc; thời điểm record được persist vào RTDB |

## Legacy / Derived / Out Of Scope

| Đường dẫn | Storage | Trạng thái | Ghi chú |
| --- | --- | --- | --- |
| `users/{uid}/fcmTokens` | Firestore | Legacy | Không còn là canonical token store; canonical hiện tại là `fcmInstallations/{installationId}` |
| `families/{familyId}/fcmTokens` | Firestore | Legacy | Path cũ cho token theo family; không dùng làm nguồn chuẩn |
| `users/{uid}/notifications` | Firestore | Out of scope | Inbox riêng của user; không thuộc auth/location schema v1 |
| `users/{uid}/chatNotifications` | Firestore | Out of scope | Chat inbox; nằm ngoài phạm vi tài liệu này |
| `zoneStatsByChild` | Firestore | Derived | Số liệu tổng hợp từ `zoneEventsByChild`; không phải contract nguồn |
| `live_locations_by_family` | RTDB | Derived | Mirror theo family để fanout/aggregate; không phải nguồn chuẩn của vị trí |
