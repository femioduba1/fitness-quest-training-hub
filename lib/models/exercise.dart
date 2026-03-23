// This class represents a single exercise in the app.
// Each exercise has a name, muscle group, difficulty level, and equipment used.
class Exercise {
  final String name;
  final String muscleGroup;
  final String difficulty;
  final String equipment;

  // Constructor used to create an exercise object.
  // All fields are required so every exercise has complete info.
  Exercise({
    required this.name,
    required this.muscleGroup,
    required this.difficulty,
    required this.equipment,
  });
}