# Detailed Flutter Admin Portal Website Development Workflow

ဤစာတမ်းသည် AR Drawing, Painting, Puzzle မိုဘိုင်းအက်ပလီကေးရှင်းများအတွက် SVG ပုံများ၊ အသုံးပြုသူအကောင့်များ၊ Notification များ၊ Rewards များနှင့် Community Post များကို စီမံခန့်ခွဲရန် ရည်ရွယ်သည့် Flutter Admin Portal Website တည်ဆောက်ခြင်းအတွက် အသေးစိတ် လုပ်ငန်းအဆင့်ဆင့် (workflow) ဖြစ်ပါသည်။

## 1. Project Setup & Configuration

1.  **Flutter Project ဖန်တီးခြင်း:**
    *   `flutter create portal_admin_website` command ဖြင့် Flutter project အသစ်တစ်ခု ဖန်တီးပါ။
    *   Web support ကို enable လုပ်ပါ။ (`flutter config --enable-web`)
    *   `web/index.html` တွင် `base href` ကို မှန်ကန်စွာ သတ်မှတ်ပါ။
2.  **Supabase Integration:**
    *   `supabase_flutter` package ကို `pubspec.yaml` တွင် ထည့်သွင်းပါ။
    *   `main.dart` တွင် Supabase client ကို initialize လုပ်ပြီး API URL နှင့် Anon Key ကို `.env` file မှ ရယူ၍ ထည့်သွင်းပါ။
    *   Authentication flow (email/password) ကို `supabase_auth_ui` package ဖြင့် စတင်တည်ဆောက်ပါ။
3.  **Design System Integration:**
    *   `pubspec.yaml` တွင် Google Fonts package (`google_fonts`) ကို ထည့်သွင်းပါ။
    *   Themes (Light/Dark mode), Colors, Fonts များကို `lib/theme/app_theme.dart`, `lib/theme/app_colors.dart`, `lib/theme/app_fonts.dart` စသည်ဖြင့် `ThemeData` ဖြင့် စနစ်တကျ သတ်မှတ်ပါ။
    *   Custom Widgets (Buttons, Input Fields, Cards, Data Tables) များကို `lib/widgets/` directory အောက်တွင် စနစ်တကျ ဖန်တီးပြီး Mobile App မှ share လုပ်ထားသော code base မှ ရယူအသုံးပြုပါ။
4.  **State Management:** GetX ကို အသုံးပြုမည် (`Get.put`, `Rx`/`Obx`, `Get.snackbar`)။

## 2. UI/UX Design & Implementation

1.  **Layout & Navigation:**
    *   Responsive layout (Desktop, Tablet, Mobile) အတွက် `MediaQuery` သို့မဟုတ် `LayoutBuilder` ကို အသုံးပြု၍ `lib/layout/responsive_layout.dart` ကို ဖန်တီးပါ။
    *   Navigation Bar (Side/Top), Dashboard Structure များကို `lib/screens/dashboard_screen.dart` တွင် ဖန်တီးပါ။ `Drawer` သို့မဟုတ် `NavigationRail` ကို အသုံးပြုနိုင်သည်။
2.  **Authentication Pages:**
    *   Login Page (`lib/screens/auth/login_screen.dart`) (Email, Password input fields, Login button)။
    *   Forgot Password Page (Optional)။
3.  **Dashboard:**
    *   Overview widgets (SVG count, User count, Recent activities, etc.) ကို `lib/widgets/dashboard_cards.dart` တွင် ဖန်တီးပါ။

## 3. Feature Implementation

### 3.1. Admin Login & Dashboard

1.  **Admin Login:** Admin သည် Portal Website သို့ ၎င်း၏ username နှင့် password ဖြင့် login ဝင်ရောက်မည်။ (Supabase Auth)
    *   `AuthService` ကို အသုံးပြု၍ `signInWithPassword` method ကို ခေါ်ဆိုမည်။
2.  **Dashboard Access:** Login အောင်မြင်ပါက dashboard သို့ `Get.offAllNamed('/dashboard')` ဖြင့် ရောက်ရှိမည်။ Dashboard တွင် SVG count, User count, Recent activities စသည်တို့ကို overview အနေဖြင့် ပြသမည်။
    *   Supabase client မှ data များကို `StreamBuilder` သို့မဟုတ် `FutureBuilder` ဖြင့် ရယူပြသမည်။

### 3.2. SVG Asset Management

1.  **SVG Upload:**
    *   Admin သည် SVG ပုံအသစ်တစ်ခုကို upload တင်ရန် "Upload New SVG" ခလုတ်ကို နှိပ်မည်။
    *   ပုံ၏အမည်၊ ဖော်ပြချက်၊ အမျိုးအစား (Drawing, Painting, Puzzle) နှင့် မည်သည့် app အတွက်ဖြစ်သည် စသည်တို့ကို `TextFormField` များဖြင့် ဖြည့်သွင်းမည်။
    *   `file_picker` package ကို အသုံးပြု၍ SVG file ကို ရွေးချယ်မည်။
    *   Supabase Storage သို့ SVG file ကို `supabase.storage.from('svg_assets').upload()` ဖြင့် upload လုပ်ပြီး metadata ကို `svg_assets` table တွင် `supabase.from('svg_assets').insert()` ဖြင့် သိမ်းဆည်းမည်။
2.  **SVG List & Search:**
    *   `svg_assets` table မှ ပုံများကို `PaginatedDataTable` သို့မဟုတ် `ListView.builder` ဖြင့် စာရင်းပြသမည်။
    *   အမျိုးအစားအလိုက်၊ အမည်အလိုက် ရှာဖွေနိုင်ရန် `TextFormField` နှင့် Supabase query filters များကို အသုံးပြုမည်။
3.  **SVG Edit/Delete:**
    *   ပုံ၏ metadata ကို ပြင်ဆင်ခြင်းအတွက် `supabase.from('svg_assets').update()` ကို အသုံးပြုမည်။
    *   ပုံကို ဖျက်ခြင်းအတွက် `supabase.from('svg_assets').delete()` နှင့် `supabase.storage.from('svg_assets').remove()` ကို အသုံးပြုမည်။
4.  **SVG Preview:** Upload မတင်မီ သို့မဟုတ် စာရင်းတွင် SVG ပုံများကို `flutter_svg` package ဖြင့် preview ကြည့်ရှုနိုင်မည်။

### 3.3. User Management

1.  **User List Display:**
    *   Supabase `auth.users` နှင့် `portal_users` table မှ အချက်အလက်များကို `PaginatedDataTable` ဖြင့် ရယူ၍ စာရင်းပြသမည်။
    *   `supabase.from('portal_users').select()` ဖြင့် data ကို ရယူမည်။
2.  **User Create/Edit/Delete:**
    *   Admin အကောင့်များ ဖန်တီးခြင်း၊ ပြင်ဆင်ခြင်း၊ ဖျက်ခြင်းအတွက် UI (e.g., `UserFormDialog`) နှင့် Supabase interaction logic ကို `UserService` တွင် ရေးသားမည်။
    *   `supabase.auth.admin.createUser()` နှင့် `supabase.auth.admin.updateUserById()` စသည်တို့ကို အသုံးပြုမည်။
3.  **Role & Permission Management:** User role (admin/editor) ကို ပြင်ဆင်နိုင်သော `DropdownButton` သို့မဟုတ် `RadioListTile` နှင့် logic ကို ထည့်သွင်းမည်။
    *   `supabase.from('portal_users').update({'role': newRole})` ဖြင့် role ကို ပြောင်းလဲမည်။

### 3.4. Notification System

1.  **Notification Creation UI:** Notification title, body, target (all users/specific user/group) အတွက် `TextFormField` များ၊ `DropdownButton` တို့ကို ဖန်တီးမည်။
2.  **Send Notification Logic:** Admin က notification ပေးပို့ရန် ခလုတ်နှိပ်ပါက Supabase Edge Function (သို့မဟုတ် Cloud Function) ကို `supabase.functions.invoke()` ဖြင့် ခေါ်ဆို၍ FCM မှတဆင့် notification ပေးပို့မည်။
    *   `notifications` table တွင် notification record ကို ထည့်သွင်းမည်။
3.  **Notification History:** `notifications` table မှ ပေးပို့ခဲ့သော notification များ၏ မှတ်တမ်းများကို `ListView.builder` ဖြင့် ကြည့်ရှုနိုင်မည်။

### 3.5. Rewards System

1.  **Rewards List & Management:**
    *   `rewards` table မှ reward များကို `PaginatedDataTable` ဖြင့် ပြသပြီး Create/Edit/Delete လုပ်နိုင်သော UI (e.g., `RewardFormDialog`) ကို ဖန်တီးမည်။
    *   `supabase.from('rewards').insert()`, `update()`, `delete()` စသည်တို့ကို အသုံးပြုမည်။
2.  **Rewards On/Off Toggle:** `is_active` field ကို ပြောင်းလဲနိုင်သော `Switch` widget သို့မဟုတ် `Checkbox` ကို ထည့်သွင်း၍ Rewards စနစ်ကို ဖွင့်/ပိတ် လုပ်နိုင်မည်။
    *   `supabase.from('rewards').update({'is_active': true/false})` ဖြင့် status ကို ပြောင်းလဲမည်။
3.  **User Rewards Tracking:** `user_rewards` table မှ အသုံးပြုသူတစ်ဦးချင်းစီ၏ ရရှိထားသော reward များကို `PaginatedDataTable` ဖြင့် ကြည့်ရှုနိုင်သော UI ကို ဖန်တီးမည်။

### 3.6. Community Post Management

1.  **Post List & Moderation:**
    *   `posts` table မှ အသုံးပြုသူများ တင်ထားသော post များကို `PaginatedDataTable` ဖြင့် စာရင်းပြသမည်။
    *   မသင့်လျော်သော post များကို ဖျက်ခြင်း (`supabase.from('posts').delete()`) သို့မဟုတ် report လုပ်ခြင်း (moderation) feature ပါဝင်မည်။
2.  **View Post Details:** Post တစ်ခုချင်းစီ၏ အသေးစိတ်အချက်အလက်များ (image, description, likes, comments) ကို `PostDetailScreen` ဖြင့် ကြည့်ရှုနိုင်မည်။
    *   `supabase.from('posts').select('*, likes(*), comments(*)')` ဖြင့် related data များကို join လုပ်၍ ရယူမည်။

## 4. Deployment & Maintenance

1.  **Build for Web:** `flutter build web --release` command ဖြင့် web build ကို ပြုလုပ်ပါ။
2.  **Hosting:** Firebase Hosting, Netlify, Vercel သို့မဟုတ် Supabase Storage (Static Hosting) တွင် deploy လုပ်ပါ။
3.  **Domain Configuration:** Custom domain ကို ချိတ်ဆက်ပါ။
4.  **Testing & Monitoring:**
    *   **Unit & Widget Testing:** Flutter ၏ testing framework ကို အသုံးပြု၍ component များကို စမ်းသပ်ပါ။ (`flutter test`)
    *   **Integration Testing:** Supabase API calls များနှင့် UI interaction များကို `integration_test` package ဖြင့် စမ်းသပ်ပါ။
    *   **User Acceptance Testing (UAT):** Admin user များဖြင့် စမ်းသပ်စစ်ဆေးပြီး feedback ရယူပါ။
    *   **Monitoring & Logging:** Supabase logs, Firebase Crashlytics (web အတွက်), Performance Monitoring တို့ကို အသုံးပြု၍ စောင့်ကြည့်ပါ။
    *   **Regular Updates:** Flutter SDK, Supabase client library နှင့် အခြား dependencies version အသစ်များထွက်ရှိပါက update လုပ်ပါ။

---
