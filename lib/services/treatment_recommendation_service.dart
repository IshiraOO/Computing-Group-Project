import '../models/user_profile.dart';
import '../models/illness.dart';
import '../models/first_aid_instruction.dart';

class TreatmentRecommendationService {
  /// Analyzes an illness and user profile to provide personalized treatment recommendations
  static List<String> getPersonalizedRecommendations(
    Illness illness,
    UserProfile? userProfile,
  ) {
    if (userProfile == null) {
      return illness.treatments;
    }

    final List<String> personalizedTreatments = [];
    final List<String> warnings = [];

    // Check for allergies that might affect treatment
    for (final treatment in illness.treatments) {
      bool hasConflict = false;

      // Check if any user allergies conflict with this treatment
      for (final allergy in userProfile.allergies) {
        if (_treatmentContainsAllergen(treatment, allergy)) {
          warnings.add('⚠️ Caution: $treatment may not be suitable due to your $allergy allergy.');
          hasConflict = true;
          break;
        }
      }

      // If no conflicts, add the treatment
      if (!hasConflict) {
        personalizedTreatments.add(treatment);
      }
    }

    // Check for medical conditions that require special consideration
    for (final condition in userProfile.medicalConditions) {
      final specialAdvice = _getSpecialAdviceForCondition(illness, condition);
      if (specialAdvice.isNotEmpty) {
        personalizedTreatments.add(specialAdvice);
      }
    }

    // Check for medication interactions
    for (final medication in userProfile.medications) {
      final interactionWarning = _checkMedicationInteraction(illness, medication);
      if (interactionWarning.isNotEmpty) {
        warnings.add(interactionWarning);
      }
    }

    // Add age-specific recommendations
    if (userProfile.age < 12) {
      personalizedTreatments.add('For children under 12, use pediatric dosages for any medications.');
    } else if (userProfile.age > 65) {
      personalizedTreatments.add('For adults over 65, monitor symptoms more closely and seek medical attention sooner if symptoms worsen.');
    }

    // Combine warnings and treatments
    return [...warnings, ...personalizedTreatments];
  }

  /// Analyzes a first aid instruction and user profile to provide personalized steps
  static List<String> getPersonalizedFirstAidSteps(
    FirstAidInstruction instruction,
    UserProfile? userProfile,
  ) {
    if (userProfile == null) {
      return instruction.steps;
    }

    final List<String> personalizedSteps = List.from(instruction.steps);

    // Add age-specific modifications
    if (userProfile.age < 12) {
      personalizedSteps.add('Note: For children, use gentler pressure and age-appropriate techniques.');
    } else if (userProfile.age > 65) {
      personalizedSteps.add('Note: For elderly individuals, be extra careful with fragile skin and bones.');
    }

    // Add condition-specific notes
    for (final condition in userProfile.medicalConditions) {
      final specialNote = _getSpecialFirstAidNoteForCondition(instruction, condition);
      if (specialNote.isNotEmpty) {
        personalizedSteps.add(specialNote);
      }
    }

    return personalizedSteps;
  }

  /// Checks if a treatment might contain an allergen
  static bool _treatmentContainsAllergen(String treatment, String allergy) {
    // Simplified check - in a real app, this would use a medical database
    final allergyLower = allergy.toLowerCase();
    final treatmentLower = treatment.toLowerCase();

    // Common allergens and related treatments
    if (allergyLower.contains('penicillin') &&
        treatmentLower.contains('antibiotic')) {
      return true;
    }
    if (allergyLower.contains('aspirin') &&
        (treatmentLower.contains('nsaid') || treatmentLower.contains('pain reliever'))) {
      return true;
    }
    if (allergyLower.contains('latex') &&
        treatmentLower.contains('bandage')) {
      return true;
    }
    if (allergyLower.contains('iodine') &&
        treatmentLower.contains('antiseptic')) {
      return true;
    }

    return false;
  }

  /// Gets special advice for people with specific medical conditions
  static String _getSpecialAdviceForCondition(Illness illness, String condition) {
    final conditionLower = condition.toLowerCase();
    final illnessLower = illness.name.toLowerCase();

    // Diabetes considerations
    if (conditionLower.contains('diabetes')) {
      if (illnessLower.contains('flu') ||
          illnessLower.contains('fever') ||
          illnessLower.contains('infection')) {
        return 'For diabetic patients: Monitor blood sugar levels more frequently during illness, as infections can affect glucose levels.';
      }
      if (illnessLower.contains('wound') ||
          illnessLower.contains('cut') ||
          illnessLower.contains('injury')) {
        return 'For diabetic patients: Pay extra attention to wound care and seek medical attention sooner, as healing may be slower.';
      }
    }

    // Heart condition considerations
    if (conditionLower.contains('heart') ||
        conditionLower.contains('cardiac') ||
        conditionLower.contains('hypertension')) {
      if (illnessLower.contains('chest pain') ||
          illnessLower.contains('shortness of breath')) {
        return 'For patients with heart conditions: Seek emergency medical attention immediately, as symptoms may indicate a cardiac event.';
      }
    }

    // Asthma considerations
    if (conditionLower.contains('asthma')) {
      if (illnessLower.contains('respiratory') ||
          illnessLower.contains('breathing') ||
          illnessLower.contains('cough')) {
        return 'For asthma patients: Use your rescue inhaler as prescribed and seek medical attention if breathing difficulties persist or worsen.';
      }
    }

    return '';
  }

  /// Gets special first aid notes for people with specific medical conditions
  static String _getSpecialFirstAidNoteForCondition(
    FirstAidInstruction instruction,
    String condition,
  ) {
    final conditionLower = condition.toLowerCase();
    final instructionLower = instruction.title.toLowerCase();

    // CPR modifications for certain conditions
    if (instructionLower.contains('cpr') || instructionLower.contains('chest compression')) {
      if (conditionLower.contains('pacemaker') ||
          conditionLower.contains('implanted defibrillator')) {
        return 'For individuals with a pacemaker or implanted defibrillator: Avoid placing hands directly over the device during chest compressions.';
      }
    }

    // Bleeding control for people on blood thinners
    if (instructionLower.contains('bleeding') || instructionLower.contains('wound')) {
      if (conditionLower.contains('blood thinner') ||
          conditionLower.contains('anticoagulant') ||
          conditionLower.contains('warfarin') ||
          conditionLower.contains('aspirin therapy')) {
        return 'For individuals on blood thinners: Apply firmer pressure for longer periods as bleeding may be more difficult to control. Seek medical attention even for minor wounds.';
      }
    }

    // Seizure considerations
    if (instructionLower.contains('seizure')) {
      if (conditionLower.contains('epilepsy')) {
        return 'For individuals with epilepsy: Note the duration and nature of the seizure to report to their healthcare provider.';
      }
    }

    return '';
  }

  /// Checks for potential medication interactions
  static String _checkMedicationInteraction(Illness illness, String medication) {
    final medicationLower = medication.toLowerCase();

    // Check for common interactions
    // In a real app, this would use a comprehensive medical database

    // Blood thinner interactions
    if ((medicationLower.contains('warfarin') ||
         medicationLower.contains('aspirin') ||
         medicationLower.contains('blood thinner')) &&
        illness.treatments.any((t) =>
          t.toLowerCase().contains('nsaid') ||
          t.toLowerCase().contains('ibuprofen') ||
          t.toLowerCase().contains('aspirin'))) {
      return '⚠️ Warning: Your blood thinner medication may interact with NSAIDs or aspirin. Consult your doctor before taking these medications.';
    }

    // ACE inhibitor interactions
    if ((medicationLower.contains('lisinopril') ||
         medicationLower.contains('enalapril') ||
         medicationLower.contains('ace inhibitor')) &&
        illness.treatments.any((t) =>
          t.toLowerCase().contains('potassium') ||
          t.toLowerCase().contains('salt substitute'))) {
      return '⚠️ Warning: Your ACE inhibitor medication may interact with potassium supplements. Monitor potassium intake carefully.';
    }

    // Antibiotic interactions
    if (medicationLower.contains('antibiotic') &&
        illness.treatments.any((t) =>
          t.toLowerCase().contains('antacid') ||
          t.toLowerCase().contains('calcium') ||
          t.toLowerCase().contains('iron'))) {
      return '⚠️ Warning: Your antibiotic medication may be less effective if taken with antacids, calcium, or iron supplements. Space these medications apart by at least 2 hours.';
    }

    return '';
  }
}