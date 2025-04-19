// lib/breed_care_model.dart
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class BreedCareModel {
  late Interpreter _interpreter;

  final Map<String, List<double>> breedVectors = {
    'Labrador Retriever': [1.0, 0.0, 0.0, 0.0],
    'Poodle': [0.0, 1.0, 0.0, 0.0],
    'German Shepherd': [0.0, 0.0, 1.0, 0.0],
    'Bulldog': [0.0, 0.0, 0.0, 1.0],
    'Beagle': [1.0, 1.0, 0.0, 0.0],
    'Golden Retriever': [0.0, 1.0, 1.0, 0.0],
    'Chihuahua': [0.0, 0.0, 1.0, 1.0],
    'Boxer': [1.0, 0.0, 1.0, 0.0],
    'Dachshund': [1.0, 0.0, 0.0, 1.0],
    'Shih Tzu': [0.0, 1.0, 0.0, 1.0],
    'Rottweiler': [1.0, 1.0, 0.0, 1.0],
    'Yorkshire Terrier': [1.0, 0.0, 1.0, 1.0],
    'Doberman': [0.5, 0.5, 0.0, 1.0],
    'Cocker Spaniel': [0.0, 0.5, 0.5, 1.0],
    'Great Dane': [1.0, 0.5, 0.0, 0.5],
    'Siberian Husky': [0.5, 1.0, 0.5, 0.0],
    'Pomeranian': [0.5, 0.0, 1.0, 0.5],
    'Australian Shepherd': [0.5, 0.5, 1.0, 0.0],
    'Basset Hound': [0.0, 1.0, 1.0, 0.5],
    'Maltese': [0.0, 1.0, 0.5, 0.5],
    'Miniature Poodle': [0.0, 0.5, 1.0, 0.5],
    'Afghan Hound': [0.0, 0.5, 0.5, 1.0],
    'Border Collie': [1.0, 0.5, 0.5, 0.0],
    'Springer Spaniel': [1.0, 0.0, 0.5, 0.5],
    'Whippet': [0.5, 0.5, 0.0, 1.0],
    'Basenji': [0.5, 0.0, 0.5, 1.0],
    'Cavalier King Charles': [0.5, 1.0, 0.5, 0.0],
    'Samoyed': [0.5, 1.0, 0.0, 0.5],
  };

  final List<String> healthLabels = ['General_Health', 'Joint_Issues'];
  final List<String> groomingLabels = ['Low', 'Moderate', 'High'];
  final List<String> feedingLabels = [
    'Balanced',
    'High_Protein',
    'Special_Diet'
  ];
  final List<String> reminderLabels = [
    'Exercise',
    'Mental_Enrichment',
    'Special_Care'
  ];

  final Map<String, String> healthTips = {
    "Joint_Issues":
        "Monitor joints for signs of stiffness or discomfort. Schedule regular vet checkups.",
    "General_Health":
        "Keep up with vaccinations and routine vet visits for overall health."
  };

  final Map<String, String> groomingTips = {
    "Low": "Minimal grooming needed. Occasional baths and brushing are enough.",
    "Moderate": "Brush weekly to manage shedding and keep coat healthy.",
    "High":
        "Requires regular brushing and professional grooming to avoid matting."
  };

  final Map<String, String> feedingTips = {
    "Balanced": "Feed a well-balanced diet with appropriate portion sizes.",
    "High_Protein":
        "Provide a protein-rich diet suitable for active dogs. Avoid overfeeding.",
    "Special_Diet":
        "Consult your vet for food sensitive needs or weight management."
  };

  final Map<String, String> reminderTips = {
    "Exercise":
        "Take your pet on daily walks and provide physical playtime to stay active.",
    "Mental_Enrichment":
        "Use toys, puzzles, or games to keep your pet mentally stimulated.",
    "Special_Care":
        "Provide gentle handling, avoid stress, and monitor behavior closely."
  };

  Future<void> loadModel() async {
    final data = await rootBundle.load('assets/models/breed_care_model.tflite');
    _interpreter = Interpreter.fromBuffer(data.buffer.asUint8List());
    print(
        "✅ Model loaded. Input shape: \${_interpreter.getInputTensor(0).shape}");
  }

  Future<Map<String, String>> predict(String breed) async {
    final input = breedVectors[breed];
    if (input == null) {
      throw Exception('Breed not supported yet.');
    }

    List<double> paddedInput = List.filled(39, 0.0);
    for (int i = 0; i < input.length; i++) {
      paddedInput[i] = input[i];
    }
    var reshapedInput = [paddedInput];
    var output = List.filled(1 * 11, 0.0).reshape([1, 11]);

    _interpreter.run(reshapedInput, output);
    final result = output[0];

    int index = 0;
    final health = result.sublist(index, index += 2) as List<double>;
    final grooming = result.sublist(index, index += 3) as List<double>;
    final feeding = result.sublist(index, index += 3) as List<double>;
    final reminder = result.sublist(index, index += 3) as List<double>;

    final healthTip = healthTips[
        healthLabels[health.indexOf(health.reduce((a, b) => a > b ? a : b))]]!;
    final groomingTip = groomingTips[groomingLabels[
        grooming.indexOf(grooming.reduce((a, b) => a > b ? a : b))]]!;
    final feedingTip = feedingTips[feedingLabels[
        feeding.indexOf(feeding.reduce((a, b) => a > b ? a : b))]]!;
    final reminderTip = reminderTips[reminderLabels[
        reminder.indexOf(reminder.reduce((a, b) => a > b ? a : b))]]!;

    return {
      'Health': healthTip,
      'Grooming': groomingTip,
      'Feeding': feedingTip,
      'Reminder': reminderTip,
    };
  }
}
