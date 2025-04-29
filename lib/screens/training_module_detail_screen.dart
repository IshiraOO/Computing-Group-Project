import 'package:flutter/material.dart';
import '../models/training_module.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';

class TrainingModuleDetailScreen extends StatefulWidget {
  final TrainingModule module;

  const TrainingModuleDetailScreen({super.key, required this.module});

  @override
  State<TrainingModuleDetailScreen> createState() => _TrainingModuleDetailScreenState();
}

class _TrainingModuleDetailScreenState extends State<TrainingModuleDetailScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isQuizMode = false;
  Map<String, int> _quizAnswers = {};
  bool _showQuizResults = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.module.title,
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.module.sections.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  _isQuizMode = false;
                  _showQuizResults = false;
                });
              },
              itemBuilder: (context, index) {
                final section = widget.module.sections[index];
                return _isQuizMode
                    ? _buildQuizView(section, theme)
                    : _buildSectionView(section, theme);
              },
            ),
          ),
          _buildNavigationControls(theme),
        ],
      ),
    );
  }

  Widget _buildSectionView(TrainingSection section, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (section.imageUrls.isNotEmpty) ...[
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: section.imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        section.imageUrls[index],
                        height: 200,
                        width: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: 300,
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 50,
                                color: theme.colorScheme.primary.withOpacity(0.5),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (section.videoUrl != null) ...[
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 50,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            section.content,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          if (section.quizzes != null && section.quizzes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            CustomButton(
              text: 'Take Quiz',
              onPressed: () {
                setState(() {
                  _isQuizMode = true;
                  _quizAnswers = {};
                  _showQuizResults = false;
                });
              },
              type: ButtonType.primary,
              icon: Icons.quiz,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizView(TrainingSection section, ThemeData theme) {
    if (section.quizzes == null || section.quizzes!.isEmpty) {
      return Center(child: Text('No quizzes available for this section'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quiz: ${section.title}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Test your knowledge on this topic',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ...section.quizzes!.asMap().entries.map((entry) {
            final index = entry.key;
            final quiz = entry.value;
            return _buildQuizQuestion(quiz, index, theme);
          }),
          const SizedBox(height: 24),
          if (_showQuizResults) ...[
            _buildQuizResults(section.quizzes!, theme),
          ] else ...[
            CustomButton(
              text: 'Submit Answers',
              onPressed: () {
                setState(() {
                  _showQuizResults = true;
                });
              },
              type: ButtonType.primary,
              icon: Icons.check_circle,
              fullWidth: true,
            ),
          ],
          const SizedBox(height: 16),
          CustomButton(
            text: 'Return to Content',
            onPressed: () {
              setState(() {
                _isQuizMode = false;
              });
            },
            type: ButtonType.outline,
            icon: Icons.arrow_back,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildQuizQuestion(TrainingQuiz quiz, int index, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${index + 1}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            quiz.question,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...quiz.options.asMap().entries.map((entry) {
            final optionIndex = entry.key;
            final option = entry.value;
            final isSelected = _quizAnswers[quiz.id] == optionIndex;
            final isCorrect = quiz.correctOptionIndex == optionIndex;
            final isWrong = _showQuizResults && isSelected && !isCorrect;
            final isCorrectAnswer = _showQuizResults && isCorrect;

            return RadioListTile<int>(
              value: optionIndex,
              groupValue: _quizAnswers[quiz.id],
              onChanged: _showQuizResults ? null : (value) {
                setState(() {
                  _quizAnswers[quiz.id] = value!;
                });
              },
              title: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  color: isWrong
                      ? theme.colorScheme.error
                      : isCorrectAnswer
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                  fontWeight: isCorrectAnswer ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              activeColor: theme.colorScheme.primary,
              selectedTileColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
              selected: isSelected,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            );
          }),
          if (_showQuizResults && quiz.explanation != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explanation:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    quiz.explanation!,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizResults(List<TrainingQuiz> quizzes, ThemeData theme) {
    int correctAnswers = 0;

    for (var quiz in quizzes) {
      if (_quizAnswers[quiz.id] == quiz.correctOptionIndex) {
        correctAnswers++;
      }
    }

    final percentage = (correctAnswers / quizzes.length) * 100;
    final isPassing = percentage >= 70;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPassing ? theme.colorScheme.primaryContainer : theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            isPassing ? Icons.check_circle : Icons.error,
            size: 48,
            color: isPassing ? theme.colorScheme.primary : theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            isPassing ? 'Congratulations!' : 'Keep Learning',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isPassing ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You got $correctAnswers out of ${quizzes.length} questions correct (${percentage.toStringAsFixed(0)}%)',
            style: TextStyle(
              fontSize: 16,
              color: isPassing ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onErrorContainer,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: isPassing ? 'Continue to Next Section' : 'Try Again',
            onPressed: () {
              if (isPassing) {
                if (_currentPage < widget.module.sections.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  Navigator.pop(context);
                }
              } else {
                setState(() {
                  _quizAnswers = {};
                  _showQuizResults = false;
                });
              }
            },
            type: ButtonType.primary,
            backgroundColor: isPassing ? theme.colorScheme.primary : theme.colorScheme.error,
            textColor: theme.colorScheme.onPrimary,
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationControls(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomButton(
            text: 'Previous',
            onPressed: _currentPage > 0
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : () {},
            type: ButtonType.outline,
            icon: Icons.arrow_back,
          ),
          Text(
            'Section ${_currentPage + 1} of ${widget.module.sections.length}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          CustomButton(
            text: 'Next',
            onPressed: _currentPage < widget.module.sections.length - 1
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : () {},
            type: ButtonType.primary,
            icon: Icons.arrow_forward,
          ),
        ],
      ),
    );
  }
}