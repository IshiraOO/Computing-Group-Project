import 'package:flutter/material.dart';
import '../services/symptom_analysis_service.dart';
import '../services/auth_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/screen_header.dart';

class SymptomAnalysisScreen extends StatefulWidget {
  const SymptomAnalysisScreen({super.key});

  @override
  State<SymptomAnalysisScreen> createState() => _SymptomAnalysisScreenState();
}

class _SymptomAnalysisScreenState extends State<SymptomAnalysisScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isAnalyzing = false;
  String? _currentAnalysisId;
  final Map<String, dynamic> _userResponses = {};
  final List<String> _reportedSymptoms = [];
  bool _showForm = false;
  final List<String> _commonSymptoms = [
    'Headache',
    'Fever',
    'Cough',
    'Sore Throat',
    'Nausea',
    'Vomiting',
    'Diarrhea',
    'Rash',
    'Chest Pain',
    'Shortness of Breath',
    'Dizziness',
    'Fatigue',
    'Abdominal Pain',
    'Back Pain',
    'Joint Pain'
  ];

  @override
  void initState() {
    super.initState();
    _addBotMessage(
        'Welcome to the AI Symptom Analyzer. I can help you assess your symptoms and provide first-aid recommendations. How can I help you today?');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _handleUserMessage(String message) {
    if (message.trim().isEmpty) return;

    _addUserMessage(message);
    _messageController.clear();

    // Process the user message
    if (_currentAnalysisId == null) {
      // Start a new analysis
      _startNewAnalysis(message);
    } else {
      // Continue existing analysis
      _continueAnalysis(message);
    }
  }

  Future<void> _startNewAnalysis(String message) async {
    setState(() {
      _isAnalyzing = true;
    });

    // Extract potential symptoms from the message
    final extractedSymptoms = _extractSymptoms(message);
    if (extractedSymptoms.isEmpty) {
      _addBotMessage(
          'I need to understand your symptoms better. Could you please describe what you\'re experiencing?');
      setState(() {
        _isAnalyzing = false;
      });
      return;
    }

    _reportedSymptoms.addAll(extractedSymptoms);

    try {
      final authService = AuthService();
      final userId = authService.getCurrentUser()?.uid ?? 'anonymous';
      final analysis = await SymptomAnalysisService.startAnalysis(
        userId: userId,
        initialSymptoms: _reportedSymptoms,
      );

      _currentAnalysisId = analysis.id;

      // Ask follow-up questions based on reported symptoms
      final followUpQuestions = _getFollowUpQuestions();
      if (followUpQuestions.isNotEmpty) {
        _addBotMessage(followUpQuestions.first);
      } else {
        await _completeAnalysis();
      }
    } catch (e) {
      _addBotMessage(
          'Sorry, I encountered an error analyzing your symptoms. Please try again.');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _continueAnalysis(String message) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Update user responses
      final questionId = 'q${_userResponses.length + 1}';
      _userResponses[questionId] = message;

      // Update the analysis with new responses
      if (_currentAnalysisId != null) {
        await SymptomAnalysisService.updateAnalysis(
          analysisId: _currentAnalysisId!,
          newResponses: {questionId: message},
        );
      }

      // Extract any additional symptoms from the response
      final extractedSymptoms = _extractSymptoms(message);
      if (extractedSymptoms.isNotEmpty) {
        for (var symptom in extractedSymptoms) {
          if (!_reportedSymptoms.contains(symptom)) {
            _reportedSymptoms.add(symptom);
          }
        }
      }

      // Ask next follow-up question or complete analysis
      final followUpQuestions = _getFollowUpQuestions();
      final nextQuestionIndex = _userResponses.length;

      if (nextQuestionIndex < followUpQuestions.length) {
        _addBotMessage(followUpQuestions[nextQuestionIndex]);
      } else {
        await _completeAnalysis();
      }
    } catch (e) {
      _addBotMessage(
          'Sorry, I encountered an error processing your response. Please try again.');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _completeAnalysis() async {
    if (_currentAnalysisId == null) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      _addBotMessage(
          'Thank you for providing that information. I\'m analyzing your symptoms now...');

      // Get user profile for personalized recommendations
      final authService = AuthService();
      final userId = authService.getCurrentUser()?.uid ?? 'anonymous';
      final userProfile = await authService.getUserProfile(userId);

      // Analyze symptoms
      final analysisResult = await SymptomAnalysisService.analyzeSymptoms(
        symptoms: _reportedSymptoms,
        responses: _userResponses,
        userProfile: userProfile,
      );

      // Complete the analysis
      await SymptomAnalysisService.completeAnalysis(
        analysisId: _currentAnalysisId!,
        recommendedActions: analysisResult['recommendedActions'],
        possibleConditions: analysisResult['possibleConditions'],
        urgencyLevel: analysisResult['urgencyLevel'],
        aiRecommendation: analysisResult['aiRecommendation'],
      );

      // Display results to user
      _addBotMessage(analysisResult['aiRecommendation']);

      // Display recommended actions
      String actionsMessage = 'Recommended actions:\n';
      for (var action in analysisResult['recommendedActions']) {
        actionsMessage += '• $action\n';
      }
      _addBotMessage(actionsMessage);

      // Display possible conditions if available
      if (analysisResult['possibleConditions'].isNotEmpty) {
        String conditionsMessage =
            'Possible conditions to discuss with a healthcare provider:\n';
        for (var condition in analysisResult['possibleConditions']) {
          conditionsMessage += '• $condition\n';
        }
        _addBotMessage(conditionsMessage);
      }

      // Add disclaimer
      _addBotMessage(
          'IMPORTANT: This is not a medical diagnosis. If you\'re experiencing severe symptoms or are unsure, please seek professional medical help immediately.');

      // Offer to save to health journal
      _addBotMessage(
          'Would you like to save this analysis to your health journal for future reference?');

      // Reset for a new analysis
      _resetAnalysis();
    } catch (e) {
      _addBotMessage(
          'Sorry, I encountered an error completing the analysis. Please try again.');
      _resetAnalysis();
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _resetAnalysis() {
    _currentAnalysisId = null;
    _userResponses.clear();
    _reportedSymptoms.clear();
  }

  List<String> _extractSymptoms(String message) {
    final extractedSymptoms = <String>[];
    final lowerMessage = message.toLowerCase();

    for (var symptom in _commonSymptoms) {
      if (lowerMessage.contains(symptom.toLowerCase())) {
        extractedSymptoms.add(symptom);
      }
    }

    return extractedSymptoms;
  }

  List<String> _getFollowUpQuestions() {
    final questions = <String>[];

    // Add general follow-up questions
    if (_reportedSymptoms.isEmpty) {
      questions.add('Could you please describe your symptoms in detail?');
    } else {
      // Add symptom-specific follow-up questions
      for (var symptom in _reportedSymptoms) {
        final symptomQuestions =
            SymptomAnalysisService.getQuestionsForSymptom(symptom);
        for (var question in symptomQuestions) {
          questions.add(question.question);
        }
      }

      // Add general questions if we don't have enough symptom-specific ones
      if (questions.isEmpty) {
        questions.add('How long have you been experiencing these symptoms?');
        questions
            .add('On a scale of 1-10, how would you rate your discomfort?');
        questions.add('Have you taken any medications for these symptoms?');
      }
    }

    return questions;
  }

  void _toggleFormView() {
    setState(() {
      _showForm = !_showForm;
    });
  }

  void _submitSymptomForm(List<String> selectedSymptoms) {
    if (selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one symptom')),
      );
      return;
    }

    setState(() {
      _showForm = false;
    });

    final message = 'I\'m experiencing: ${selectedSymptoms.join(', ')}';
    _handleUserMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CustomAppBar(
        title: 'AI Symptom Analysis',
        showBackButton: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
            onPressed: () {
              setState(() {
                _messages.clear();
                _currentAnalysisId = null;
                _userResponses.clear();
                _reportedSymptoms.clear();
              });
              _addBotMessage(
                  'Welcome to the AI Symptom Analyzer. I can help you assess your symptoms and provide first-aid recommendations. How can I help you today?');
            },
          ),
        ],
      ),
      body: SafeArea(
        child:
            _showForm ? _buildSymptomForm(theme) : _buildChatInterface(theme),
      ),
    );
  }

  Widget _buildChatInterface(ThemeData theme) {
    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? _buildWelcomeView(theme)
              : _buildChatMessages(theme),
        ),
        _buildInputArea(theme),
      ],
    );
  }

  Widget _buildWelcomeView(ThemeData theme) {
    return Column(
      children: [
        ScreenHeader(
          title: 'AI Symptom Analyzer',
          subtitle: 'Get personalized health recommendations',
          icon: Icons.health_and_safety,
          cardTitle: 'Symptom Assessment',
          cardSubtitle:
              'Describe your symptoms and get first-aid recommendations based on AI analysis',
          cardIcon: Icons.medical_information,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.health_and_safety,
                  size: 80,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'AI Symptom Analyzer',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Describe your symptoms and get first-aid recommendations',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Start New Analysis',
                  onPressed: () {
                    _addBotMessage(
                        'Welcome to the AI Symptom Analyzer. I can help you assess your symptoms and provide first-aid recommendations. How can I help you today?');
                  },
                  type: ButtonType.primary,
                  icon: Icons.play_arrow,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatMessages(ThemeData theme) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        return _buildMessageBubble(message, theme);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ThemeData theme) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: theme.colorScheme.primary,
              radius: 16,
              child: const Icon(
                Icons.health_and_safety,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: isUser
                      ? const Radius.circular(20)
                      : const Radius.circular(0),
                  bottomRight: isUser
                      ? const Radius.circular(0)
                      : const Radius.circular(20),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  fontSize: 16,
                  color: isUser
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: theme.colorScheme.secondary,
              radius: 16,
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(ThemeData theme) {
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
        children: [
          IconButton(
            onPressed: _toggleFormView,
            icon: const Icon(Icons.list_alt),
            tooltip: 'Select symptoms from list',
            color: theme.colorScheme.primary,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Describe your symptoms...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: _isAnalyzing ? null : _handleUserMessage,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isAnalyzing
                ? null
                : () => _handleUserMessage(_messageController.text),
            icon: _isAnalyzing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            color: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomForm(ThemeData theme) {
    return StatefulBuilder(
      builder: (context, setState) {
        final selectedSymptoms = <String>[];

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Your Symptoms',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _commonSymptoms.length,
                itemBuilder: (context, index) {
                  final symptom = _commonSymptoms[index];
                  return CheckboxListTile(
                    title: Text(symptom),
                    value: selectedSymptoms.contains(symptom),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          selectedSymptoms.add(symptom);
                        } else {
                          selectedSymptoms.remove(symptom);
                        }
                      });
                    },
                    activeColor: theme.colorScheme.primary,
                    checkColor: theme.colorScheme.onPrimary,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    text: 'Cancel',
                    onPressed: _toggleFormView,
                    type: ButtonType.outline,
                  ),
                  CustomButton(
                    text: 'Submit',
                    onPressed: () => _submitSymptomForm(selectedSymptoms),
                    type: ButtonType.primary,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
