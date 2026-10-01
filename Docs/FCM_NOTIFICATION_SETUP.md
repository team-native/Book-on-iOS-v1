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

푸시 payload의 `type` 값 `loan_due`, `notice`, `new_book`은 각각 대출 내역, 공지, 신간 화면으로 연결한다. 알림함에서도 이 세 유형을 탭하면 읽음 처리 후 같은 화면으로 이동한다. `deepLink` 기반 화면 이동은 아직 구현되어 있지 않다.

## Firebase 연결 시 작업

1. Apple Developer에서 APNs Auth Key(`.p8`)를 만들고 Firebase Console에 등록한다.
2. `GoogleService-Info.plist`를 앱 리소스에 추가한다.
3. Firebase Console에서 내려받은 `GoogleService-Info.plist`를 `Projects/App/Resources/`에 추가한다. 이 파일은 Firebase API 키를 포함하므로 공개 저장소라면 규칙을 정한 뒤 커밋한다.
4. 앱에는 `aps-environment = development` entitlement가 설정되어 있다. Apple Developer의 App ID에도 **Push Notifications**를 켜고, 프로비저닝 프로파일을 다시 생성한다. 배포용 Archive는 Xcode 서명이 `production` 값으로 관리한다.
5. `PushNotificationCoordinator`는 앱 시작 시 Firebase를 초기화하고 `Messaging.messaging().delegate`로 등록한다.
6. 현재 API 계약에 맞춰 FCM 토큰을 로그인 직후·토큰 갱신 시 등록하고 로그아웃 시 폐기한다.

Firebase 비밀값, APNs 키, 서버 발송 권한은 저장소에 커밋하지 않는다.
