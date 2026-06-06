import 'dart:io';
import 'package:flutter/material.dart';
import 'package:techjobs/core/shared/app_state.dart';
import 'package:techjobs/modules/empresa/model/company_model.dart';
import 'package:techjobs/modules/empresa/usecase/save_company_profile_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/get_company_profile_usecase.dart';
import 'package:techjobs/modules/empresa/usecase/upload_company_avatar_usecase.dart';

class CompanyProfileController extends ValueNotifier<AppState<CompanyModel>> {
  final ISaveCompanyProfileUseCase _saveCompanyProfileUseCase;
  final IGetCompanyProfileUseCase _getCompanyProfileUseCase;
  
  // A dependência que estava faltando ser declarada
  final IUploadCompanyAvatarUseCase _uploadCompanyAvatarUseCase; 

  CompanyProfileController(
    this._saveCompanyProfileUseCase,
    this._getCompanyProfileUseCase,
    this._uploadCompanyAvatarUseCase, // <- Injetada no construtor
  ) : super(InitialState<CompanyModel>());

  Future<void> loadProfile(String companyId) async {
    value = LoadingState<CompanyModel>();
    
    try {
      final company = await _getCompanyProfileUseCase.call(companyId);
      if (company != null) {
        value = SuccessState<CompanyModel>(company);
      } else {
        value = SuccessState<CompanyModel>(
          CompanyModel(id: companyId, name: 'Nova Empresa'),
        );
      }
    } catch (e) {
      value = ErrorState<CompanyModel>(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Atualizado com a imagem opcional
  Future<void> saveProfile(CompanyModel company, {File? newAvatarImage}) async {
    value = LoadingState<CompanyModel>();

    try {
      CompanyModel companyToSave = company;

      // 1. Se o usuário escolheu uma imagem nova, fazemos o upload primeiro
      if (newAvatarImage != null) {
        final imageUrl = await _uploadCompanyAvatarUseCase.call(company.id, newAvatarImage);
        // 2. Colocamos a URL gerada dentro do modelo antes de salvar
        companyToSave = companyToSave.copyWith(avatarUrl: imageUrl);
      }

      // 3. Salva os dados (com ou sem a foto nova) no banco de dados
      await _saveCompanyProfileUseCase.call(companyToSave);
      
      // 4. Atualiza a tela
      value = SuccessState<CompanyModel>(companyToSave); 
    } catch (e) {
      value = ErrorState<CompanyModel>(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void resetState() {
    value = InitialState<CompanyModel>();
  }
}