# FCM 알림 구조

## 전달 경로

`백엔드 이벤트 → Firebase Admin SDK → FCM → APNs → iOS 앱`

FCM은 발송 계층이며 iOS 기기 전달은 APNs가 담당한다. 따라서 iOS 토큰 저장과 알림함 이력 저장은 백엔드가 담당한다.

## iOS 준비 상태

- `PushNotificationCoordinator`: 권한 요청, APNs 등록, 포그라운드 표시, 알림 탭 이벤트를 담당한다.
- `BookOnAppDelegate`: APNs 등록 성공/실패 콜백을 전달한다.
- Firebase SPM 패키지(`FirebaseCore`, `FirebaseMessaging`)를 추가했다. `GoogleService-Info.plist`가 없으면 Firebase 초기화를 건너뛰므로 설정 전에도 앱은 실행된다.
- 권한은 앱 시작 때 요청하지 않는다. 알림 설정 화면에서 사용자가 활성화할 때 `requestAuthorization()`을 호출한다.

## 앱에 연결된 API 계약

현재 iOS 서비스가 사용하는 요청은 다음과 같다. 서버 배포 환경에서도 이 경로와 본문·응답 형식이 유지되는지 확인해야 한다.

| 목적 | API | 요청 본문 |
| --- | --- | --- |
| 토큰 등록/갱신 | `POST /me/fcm-token` | `token`, `platform: "ios"` |
| 로그아웃/토큰 폐기 | `DELETE /me/fcm-token` | `token` |
| 알림함 목록 | `GET /me/notifications` | `page`, `size` |
| 읽음 처리 | `PATCH /me/notifications/{id}/read` | 없음 |

토큰 등록 응답은 `data.registered`, 폐기 응답은 `data.unregistered`, 읽음 처리 응답은 `data.id`와 `data.isRead`를 사용한다. 알림함 목록은 `data.notifications`와 `data.pagination`을 사용하며, 각 알림은 `id`, `type`, `title`, `body`, `isRead`, `createdAt`, `deepLink`를 포함한다.

푸시 payload의 `type` 값 `loan_due`, `notice`, `new_book`은 각각 대출 내역, 공지, 도서 상세 화면으로 연결한다. `new_book`은 payload의 `bookId`를 사용하며, 알림함은 저장된 `/books/{bookId}` `deepLink`를 사용한다. 도서 ID가 없는 구형 신간 알림은 신간 목록으로 연결한다.

## 실제 연결 순서

### 저장소에서 준비된 항목

- Firebase SPM 의존성, 앱 시작 초기화, APNs 등록 콜백, FCM 토큰 수신, 로그인 후 토큰 등록, 로그아웃 시 토큰 폐기, 알림 탭 라우팅이 구현되어 있다.
- `GoogleService-Info.plist`가 없거나 Firebase 앱이 초기화되지 않은 개발 환경에서는 Messaging API를 건너뛴다.
- 현재 Tuist 설정에서 생성되는 앱 Bundle ID는 `com.bookonios.Book-on-iOS-V1`이다. Firebase에 앱을 등록할 때 실제 서명된 앱의 Bundle ID와 대소문자까지 일치하는지 확인한다.
- Tuist가 `Projects/App/Resources/**`를 리소스로 포함한다. Firebase에서 받은 파일의 이름을 정확히 `GoogleService-Info.plist`로 유지해 해당 디렉터리에 둔다.

### 계정 소유자가 콘솔에서 해야 할 작업

1. Firebase Console에서 올바른 프로젝트에 iOS 앱을 등록하고, 해당 Bundle ID의 `GoogleService-Info.plist`를 내려받는다. 이 저장소는 파일을 환경별 로컬 설정으로 취급해 `.gitignore`에서 제외하므로, CI나 다른 개발 환경에서도 빌드하려면 파일을 각 환경에 안전하게 전달해야 한다.
2. Apple Developer에서 APNs 인증 키(`.p8`)를 만들고 Key ID와 Team ID를 확인한다. App ID에서 **Push Notifications**를 활성화하고 프로비저닝 프로파일을 갱신한다.
3. Firebase Console의 **Project settings → Cloud Messaging → Apple app configuration**에 `.p8`, Key ID, Team ID를 등록한다.
4. 개발 빌드는 `aps-environment = development`와 일치하는 개발 서명으로 테스트한다. 현재 앱 entitlements 파일은 `development`로 고정되어 있으므로, 배포 전에는 Release로 서명된 앱의 실제 entitlement가 `production`인지 확인하고 필요하면 Tuist 설정을 구성별로 분리한다.

Firebase의 iOS 설정 파일은 앱/프로젝트 식별자를 담는 클라이언트 설정이며, APNs `.p8`와 Firebase Admin SDK 자격 증명은 서버 비밀값이다. `.p8`이나 Admin 자격 증명은 앱 번들, 저장소, 로그에 넣지 않는다.

### 백엔드 발송 설정과 보안

- 백엔드는 이 앱과 같은 Firebase 프로젝트를 사용하고 Firebase Admin SDK 또는 FCM HTTP v1으로 이벤트별 알림을 발송해야 한다. 발송 권한은 서버의 비밀 저장소에만 둔다.
- 앱은 로그인한 사용자의 토큰을 `POST /me/fcm-token`으로 등록하고 `DELETE /me/fcm-token`으로 폐기한다. 백엔드는 여러 기기의 토큰을 사용자별로 관리하고, 만료/무효 토큰을 제거해야 한다.
- 알림 이력 API는 아래 계약을 사용하며 `type` 값은 `loan_due`, `notice`, `new_book`이다. 푸시 payload와 저장된 알림의 `deepLink`가 같은 목적지를 가리키는지 확인한다.
- 현재 앱 기본 API 주소는 HTTP이며 FCM 토큰 등록 API는 인증이 필요하다. HTTPS 전환 전에는 실제 계정 토큰이나 운영 알림을 이 경로로 보내지 않는다. TLS 엔드포인트 준비는 [이슈 #202](https://github.com/team-native/Book-on-iOS-v1/issues/202)에서 추적한다.

### 검증 순서

1. `GoogleService-Info.plist`가 앱 번들에 포함되고 `FirebaseApp` 초기화가 성공하는지 확인한다.
2. 알림 설정에서 사용자가 권한을 허용한 뒤 APNs 등록과 FCM 토큰 발급을 확인한다. 토큰 값 자체는 로그·이슈·스크린샷에 남기지 않는다.
3. 로그인 상태에서 `POST /me/fcm-token`이 성공하는지 확인한다. 로그아웃 시 해당 토큰 삭제 요청도 확인한다.
4. Firebase Console의 테스트 메시지를 해당 FCM 등록 토큰으로 보내 백그라운드 수신을 확인하고, 알림을 탭해 목적지 화면과 이전 화면 복귀를 확인한다.
5. 마지막으로 백엔드 이벤트에서 알림 이력 저장, FCM 발송, 앱 딥링크까지 실기기 E2E로 확인한다. 빌드 성공만으로 APNs/FCM 연결 완료로 판정하지 않는다.

실기기 푸시 및 알림 이력 E2E 검증은 [이슈 #219](https://github.com/team-native/Book-on-iOS-v1/issues/219)에서 추적한다.
