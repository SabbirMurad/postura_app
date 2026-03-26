import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingController extends GetxController {
  late PageController pageController;
  RxInt currentPage = RxInt(0);
  RxBool isSeen = RxBool(false);

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void nextPage() {
    if (currentPage.value == 2) {
      isSeen.value = true;
      return;
    }
    pageController.nextPage(
      duration: Duration(milliseconds: 400),
      curve: Curves.linear,
    );
  }

  void updatePageIndicator(index) {
    currentPage.value = index;
  }

  void dotNavigation(index) {
    currentPage.value = index;
    pageController.jumpToPage(index);
  }

  bool get isLastPage => currentPage.value == 2;
}
