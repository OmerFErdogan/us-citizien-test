import 'package:flutter/material.dart';
import 'package:us_citizenship_test/models/question.dart';
import 'package:us_citizenship_test/services/improved_question_service.dart';
import 'package:us_citizenship_test/utils/exceptions/app_exceptions.dart';
import 'package:us_citizenship_test/utils/exceptions/error_handler_service.dart';
import 'package:us_citizenship_test/widgets/error/error_widgets.dart';


/// Example screen showing how to use improved error handling
class ImprovedQuizScreen extends StatefulWidget {
  const ImprovedQuizScreen({Key? key}) : super(key: key);

  @override
  State<ImprovedQuizScreen> createState() => _ImprovedQuizScreenState();
}

class _ImprovedQuizScreenState extends State<ImprovedQuizScreen> {
  final ErrorHandlerService _errorHandler = ErrorHandlerService();
  final ImprovedQuestionService _questionService = ImprovedQuestionService();
  
  List<Question>? _questions;
  bool _isLoading = false;
  AppException? _error;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  /// Example: Loading data with error handling
  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _questionService.loadQuestions();
      _questions = _questionService.getAllQuestions();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      AppException exception;
      
      if (e is AppException) {
        exception = e;
      } else {
        exception = ErrorHandlerService.convertException(e, stackTrace);
      }

      await _errorHandler.handleError(
        exception: exception,
        stackTrace: stackTrace,
        severity: ErrorSeverity.high,
        buildContext: context,
        context: {
          'screen': 'QuizScreen',
          'operation': 'loadQuestions',
        },
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = exception;
        });
      }
    }
  }

  /// Example: Handling user actions with validation
  Future<void> _answerQuestion(int questionId, String answer) async {
    try {
      // Validate input
      if (answer.trim().isEmpty) {
        throw ValidationException(
          message: 'Please select an answer before continuing.',
          code: 'EMPTY_ANSWER',
        );
      }

      await _questionService.answerQuestion(questionId, answer);
      
      // Success - continue to next question
      _showSuccessMessage('Answer submitted successfully!');
      
    } catch (e, stackTrace) {
      await _errorHandler.handleError(
        exception: e is AppException 
            ? e 
            : ErrorHandlerService.convertException(e, stackTrace),
        stackTrace: stackTrace,
        severity: ErrorSeverity.medium,
        buildContext: context,
        context: {
          'questionId': questionId,
          'answer': answer,
        },
      );
    }
  }

  /// Example: Showing success messages
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Example: Custom retry logic
  Future<void> _retryOperation() async {
    await _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _retryOperation,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading questions...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return ErrorDisplayWidget(
        exception: _error!,
        onRetry: _retryOperation,
        showDetails: true,
      );
    }

    if (_questions == null || _questions!.isEmpty) {
      return const Center(
        child: Text('No questions available'),
      );
    }

    return _buildQuestionsList();
  }

  Widget _buildQuestionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _questions!.length,
      itemBuilder: (context, index) {
        final question = _questions![index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...question.options.map((option) {
                  return ListTile(
                    title: Text(option.text),
                    leading: Radio<String>(
                      value: option.text,
                      groupValue: null, // You'd track selected answers here
                      onChanged: (value) {
                        if (value != null) {
                          _answerQuestion(question.id, value);
                        }
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _questionService.dispose();
    super.dispose();
  }
}

/// Example: Using LoadingWithErrorWidget
class ExampleDataScreen extends StatelessWidget {
  const ExampleDataScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Example')),
      body: LoadingWithErrorWidget(
        future: _loadData(),
        builder: (context, data) {
          final questions = data as List<Question>;
          return ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(questions[index].question),
                subtitle: Text(questions[index].category),
              );
            },
          );
        },
        errorBuilder: (context, error) {
          return ErrorDisplayWidget(
            exception: error,
            customMessage: 'Failed to load quiz data',
            onRetry: () {
              // Trigger rebuild by calling setState in parent
            },
          );
        },
        loadingWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading quiz data...'),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Question>> _loadData() async {
    final service = ImprovedQuestionService();
    await service.loadQuestions();
    return service.getAllQuestions();
  }
}

/// Example: Error boundary usage
class ExampleWithErrorBoundary extends StatelessWidget {
  const ExampleWithErrorBoundary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      errorBuilder: (context, error, stackTrace) {
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: ErrorDisplayWidget(
            exception: UnknownException(
              message: 'Widget error occurred',
              originalError: error,
            ),
            showDetails: true,
          ),
        );
      },
      child: const YourActualWidget(),
    );
  }
}

class YourActualWidget extends StatelessWidget {
  const YourActualWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Your app content here'),
    );
  }
}
