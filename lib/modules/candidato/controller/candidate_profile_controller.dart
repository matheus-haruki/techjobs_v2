import 'dart:io';
import 'package:flutter/material.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/candidato/model/candidate_model.dart';
import 'package:techjobs/modules/candidato/model/experience_model.dart';
import 'package:techjobs/modules/candidato/usecase/get_candidate_profile_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/save_candidate_profile_usecase.dart';
import 'package:techjobs/modules/candidato/usecase/upload_candidate_avatar_usecase.dart';

class CandidateProfileController extends ValueNotifier<AppState<CandidateModel>> {
  final ISaveCandidateProfileUseCase _saveProfileUseCase;
  final IGetCandidateProfileUseCase _getProfileUseCase;
  final IUploadCandidateAvatarUseCase _uploadAvatarUseCase; // <-- NOVA DEPENDÊNCIA

  CandidateProfileController(
    this._saveProfileUseCase,
    this._getProfileUseCase,
    this._uploadAvatarUseCase,
  ) : super(InitialState<CandidateModel>());

  Future<void> loadProfile(String id) async {
    value = LoadingState<CandidateModel>();

    try {
      final candidate = await _getProfileUseCase.call(id);
      value = SuccessState<CandidateModel>(candidate);
    } catch (e) {
      value = ErrorState<CandidateModel>(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<void> saveProfile({
    required String id,
    required String name,
    String? bio,
    String? role,
    String? location,
    List<String> skills = const [],
    List<ExperienceModel> experiences = const [],
    String? currentAvatarUrl,
    File? newAvatarFile, // <-- RECEBE O ARQUIVO FÍSICO (SE HOUVER)
  }) async {
    value = LoadingState<CandidateModel>();

    try {
      String? finalAvatarUrl = currentAvatarUrl;

      // Se o usuário selecionou uma nova foto, fazemos o upload PRIMEIRO
      if (newAvatarFile != null) {
        finalAvatarUrl = await _uploadAvatarUseCase.call(
          candidateId: id,
          imageFile: newAvatarFile,
        );
      }

      final candidate = CandidateModel(
        id: id,
        name: name,
        bio: bio,
        role: role,
        location: location,
        skills: skills,
        experiences: experiences,
        avatarUrl: finalAvatarUrl, // <-- URL ATUALIZADA (OU MANTIDA)
      );

      await _saveProfileUseCase.call(candidate);

      value = SuccessState<CandidateModel>(candidate);
    } catch (e) {
      value = ErrorState<CandidateModel>(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void resetState() {
    value = InitialState<CandidateModel>();
  }
}