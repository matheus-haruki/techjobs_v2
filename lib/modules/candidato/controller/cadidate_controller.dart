
import 'package:flutter/material.dart';

class CandidateController extends ValueNotifier<int> {
  // Inicializa na aba 0 (Feed)
  CandidateController() : super(0); 

  void changeTab(int index) {
    value = index;
  }
}