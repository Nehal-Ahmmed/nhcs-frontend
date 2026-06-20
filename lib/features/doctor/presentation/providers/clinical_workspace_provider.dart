import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/clinical_case.dart';
import 'doctor_providers.dart';

class ClinicalWorkspaceState {
  final String patientId;
  final String patientName;
  final List<String> symptoms;
  final List<DiagnosisItem> diagnoses;
  final List<PrescribedMedicine> medicines;
  final List<String> investigations;
  final String clinicalNotes;
  final String followUp;
  final String? referralSpecialist;
  final bool isSubmitting;
  final bool isSuccess;
  final String? error;

  ClinicalWorkspaceState({
    this.patientId = '',
    this.patientName = '',
    this.symptoms = const [],
    this.diagnoses = const [],
    this.medicines = const [],
    this.investigations = const [],
    this.clinicalNotes = '',
    this.followUp = 'In 2 weeks',
    this.referralSpecialist,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
  });

  ClinicalWorkspaceState copyWith({
    String? patientId,
    String? patientName,
    List<String>? symptoms,
    List<DiagnosisItem>? diagnoses,
    List<PrescribedMedicine>? medicines,
    List<String>? investigations,
    String? clinicalNotes,
    String? followUp,
    String? referralSpecialist,
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
  }) {
    return ClinicalWorkspaceState(
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      symptoms: symptoms ?? this.symptoms,
      diagnoses: diagnoses ?? this.diagnoses,
      medicines: medicines ?? this.medicines,
      investigations: investigations ?? this.investigations,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      followUp: followUp ?? this.followUp,
      referralSpecialist: referralSpecialist ?? this.referralSpecialist,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }
}

class ClinicalWorkspaceNotifier extends StateNotifier<ClinicalWorkspaceState> {
  final Ref _ref;

  ClinicalWorkspaceNotifier(this._ref) : super(ClinicalWorkspaceState());

  void initializePatient(String patientId, String patientName) {
    state = ClinicalWorkspaceState(
      patientId: patientId,
      patientName: patientName,
    );
  }

  void addSymptom(String symptom) {
    if (symptom.trim().isEmpty) return;
    if (state.symptoms.contains(symptom)) return;
    state = state.copyWith(symptoms: [...state.symptoms, symptom]);
  }

  void removeSymptom(String symptom) {
    state = state.copyWith(
      symptoms: state.symptoms.where((s) => s != symptom).toList(),
    );
  }

  void addDiagnosis(String disease, String status, String notes) {
    if (disease.trim().isEmpty) return;
    final item = DiagnosisItem(diseaseName: disease, status: status, notes: notes);
    state = state.copyWith(diagnoses: [...state.diagnoses, item]);
  }

  void removeDiagnosis(int index) {
    final list = [...state.diagnoses];
    list.removeAt(index);
    state = state.copyWith(diagnoses: list);
  }

  void addMedicine(String name, String dosage, String duration, String instructions) {
    if (name.trim().isEmpty) return;
    final medicine = PrescribedMedicine(
      medicineName: name,
      dosage: dosage,
      duration: duration,
      instructions: instructions,
    );
    state = state.copyWith(medicines: [...state.medicines, medicine]);
  }

  void removeMedicine(int index) {
    final list = [...state.medicines];
    list.removeAt(index);
    state = state.copyWith(medicines: list);
  }

  void toggleInvestigation(String investigation) {
    final list = [...state.investigations];
    if (list.contains(investigation)) {
      list.remove(investigation);
    } else {
      list.add(investigation);
    }
    state = state.copyWith(investigations: list);
  }

  void updateClinicalNotes(String notes) {
    state = state.copyWith(clinicalNotes: notes);
  }

  void updateFollowUp(String followUp) {
    state = state.copyWith(followUp: followUp);
  }

  void updateReferral(String? specialist) {
    state = state.copyWith(referralSpecialist: specialist);
  }

  Future<void> submit() async {
    if (state.patientId.isEmpty) {
      state = state.copyWith(error: 'No patient selected.');
      return;
    }
    if (state.diagnoses.isEmpty && state.symptoms.isEmpty) {
      state = state.copyWith(error: 'Please record at least one symptom or diagnosis.');
      return;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final repository = _ref.read(doctorRepositoryProvider);
      
      final plan = TreatmentPlan(
        patientId: state.patientId,
        patientName: state.patientName,
        symptoms: state.symptoms,
        diagnoses: state.diagnoses,
        medicines: state.medicines,
        investigations: state.investigations,
        clinicalNotes: state.clinicalNotes,
        followUp: state.followUp,
        referralSpecialist: state.referralSpecialist,
        date: DateTime.now(),
      );

      await repository.submitTreatmentPlan(plan);
      state = state.copyWith(isSubmitting: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
    }
  }

  void reset() {
    state = ClinicalWorkspaceState();
  }
}

final clinicalWorkspaceProvider = StateNotifierProvider<ClinicalWorkspaceNotifier, ClinicalWorkspaceState>((ref) {
  return ClinicalWorkspaceNotifier(ref);
});
