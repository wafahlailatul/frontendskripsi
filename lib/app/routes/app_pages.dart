import 'package:get/get.dart';

import '../modules/Analysis/bindings/analysis_binding.dart';
import '../modules/Analysis/views/analysis_view.dart';
import '../modules/HealthyLifestyle/bindings/healthy_lifestyle_binding.dart';
import '../modules/HealthyLifestyle/views/healthy_lifestyle_view.dart';
import '../modules/ProgressChart/bindings/progress_chart_binding.dart';
import '../modules/ProgressChart/views/progress_chart_view.dart';
import '../modules/aktivitas/bindings/aktivitas_binding.dart';
import '../modules/aktivitas/views/aktivitas_view.dart';
import '../modules/ble_scan/bindings/ble_scan_binding.dart';
import '../modules/ble_scan/views/ble_scan_view.dart';
import '../modules/cobaaa/bindings/cobaaa_binding.dart';
import '../modules/cobaaa/views/cobaaa_view.dart';
import '../modules/heartmonitor/bindings/heartmonitor_binding.dart';
import '../modules/heartmonitor/views/heartmonitor_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/landing_page/bindings/landing_page_binding.dart';
import '../modules/landing_page/views/landing_page_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/notifikasi/bindings/notifikasi_binding.dart';
import '../modules/notifikasi/views/notifikasi_view.dart';
import '../modules/otp/bindings/otp_binding.dart';
import '../modules/otp/views/otp_view.dart';
import '../modules/profil/bindings/profil_binding.dart';
import '../modules/profil/views/profil_view.dart';
import '../modules/progress_aktifitas/bindings/progress_aktifitas_binding.dart';
import '../modules/progress_aktifitas/views/progress_aktifitas_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/stress/bindings/stress_binding.dart';
import '../modules/stress/views/stress_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LANDING_PAGE;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      children: [],
    ),
    GetPage(
      name: _Paths.LANDING_PAGE,
      page: () => const LandingPageView(),
      binding: LandingPageBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => OtpView(
        email: Get.arguments,
      ),
      binding: OtpBinding(),
    ),
    GetPage(
      name: _Paths.HEARTMONITOR,
      page: () => const HeartmonitorView(),
      binding: HeartmonitorBinding(),
    ),
    GetPage(
      name: _Paths.ANALYSIS,
      page: () => const AnalysisView(),
      binding: AnalysisBinding(),
    ),
    GetPage(
      name: _Paths.HEALTHY_LIFESTYLE,
      page: () => const HealthyLifestyleView(),
      binding: HealthyLifestyleBinding(),
    ),
    GetPage(
      name: _Paths.PROGRESS_CHART,
      page: () => const ProgressChartView(),
      binding: ProgressChartBinding(),
    ),
    GetPage(
      name: _Paths.BLE_SCAN,
      page: () => const BleScanView(),
      binding: BleScanBinding(),
    ),
    GetPage(
      name: _Paths.PROFIL,
      page: () => const ProfilView(),
      binding: ProfilBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFIKASI,
      page: () => const NotifikasiView(),
      binding: NotifikasiBinding(),
    ),
    GetPage(
      name: _Paths.STRESS,
      page: () => const StressView(),
      binding: StressBinding(),
    ),
    GetPage(
      name: _Paths.AKTIVITAS,
      page: () => const AktivitasView(),
      binding: AktivitasBinding(),
    ),
    GetPage(
      name: _Paths.PROGRESS_AKTIFITAS,
      page: () => const ProgressAktifitasView(),
      binding: ProgressAktifitasBinding(),
    ),
    GetPage(
      name: _Paths.COBAAA,
      page: () => const CobaaaView(),
      binding: CobaaaBinding(),
    ),
  ];
}
