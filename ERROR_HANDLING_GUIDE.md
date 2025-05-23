# Error Handling Integration Guide

## 🚀 Improved Error Handling Implementation

Bu kılavuz, ABD Vatandaşlık Test uygulamanıza gelişmiş error handling sisteminin nasıl entegre edileceğini açıklar.

## 📁 Dosya Yapısı

```
lib/
├── utils/
│   └── exceptions/
│       ├── app_exceptions.dart       # Custom exception classes
│       └── error_handler_service.dart # Global error handler
├── widgets/
│   └── error/
│       └── error_widgets.dart        # Error UI components
├── services/
│   └── improved_question_service.dart # Updated service with error handling
├── examples/
│   └── error_handling_examples.dart  # Usage examples
└── improved_main.dart                # Updated main.dart with global error handling
```

## 🔧 1. Mevcut Kodu Güncelleme

### Adım 1: Dependencies Ekleme
`pubspec.yaml` dosyanıza şu dependency'leri ekleyin:

```yaml
dependencies:
  # ... mevcut dependencies
  connectivity_plus: ^5.0.2  # Network status için
  device_info_plus: ^10.1.0  # Device info için
```

### Adım 2: QuestionService'i Değiştirme

Mevcut `QuestionService`'inizi `ImprovedQuestionService` ile değiştirin:

```dart
// Eski kullanım
final questionService = QuestionService();

// Yeni kullanım
final questionService = ImprovedQuestionService();
```

### Adım 3: Main.dart Güncelleme

Mevcut `main.dart` dosyanızı `improved_main.dart` ile değiştirin:

```dart
// Import ekleyin
import 'utils/exceptions/error_handler_service.dart';
import 'utils/exceptions/app_exceptions.dart';
import 'widgets/error/error_widgets.dart';
```

## 🎯 2. Error Types ve Kullanım

### Temel Exception Types

```dart
// Network errors
NetworkException(
  message: 'No internet connection',
  code: 'NETWORK_ERROR'
)

// Data errors
DataException(
  message: 'Invalid data format',
  code: 'DATA_ERROR'
)

// Storage errors
StorageException(
  message: 'Storage access failed',
  code: 'STORAGE_ERROR'
)

// Validation errors
ValidationException(
  message: 'Invalid input',
  code: 'VALIDATION_ERROR'
)

// Service errors
ServiceException(
  message: 'Service initialization failed',
  code: 'SERVICE_ERROR'
)
```

### Error Severity Levels

```dart
ErrorSeverity.low     // Snackbar göster
ErrorSeverity.medium  // Dialog göster, retry seçeneği
ErrorSeverity.high    // Kritik dialog, app restart önerisi
ErrorSeverity.critical // App'i zorla kapat
```

## 🔥 3. Pratik Kullanım Örnekleri

### Widget'larda Error Handling

```dart
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final ErrorHandlerService _errorHandler = ErrorHandlerService();
  
  Future<void> _loadData() async {
    try {
      // Veri yükleme işlemi
      final data = await dataService.loadData();
      setState(() {
        // UI güncelleme
      });
    } catch (e, stackTrace) {
      await _errorHandler.handleError(
        exception: ErrorHandlerService.convertException(e, stackTrace),
        stackTrace: stackTrace,
        severity: ErrorSeverity.medium,
        buildContext: context,
        context: {
          'widget': 'MyWidget',
          'operation': 'loadData',
        },
      );
    }
  }
}
```

### Async Operations

```dart
Future<void> _submitAnswer(String answer) async {
  try {
    // Input validation
    if (answer.trim().isEmpty) {
      throw ValidationException(
        message: 'Please select an answer',
        code: 'EMPTY_ANSWER',
      );
    }
    
    await questionService.answerQuestion(questionId, answer);
    _showSuccess('Answer submitted!');
    
  } catch (e, stackTrace) {
    await _errorHandler.handleError(
      exception: e is AppException 
          ? e 
          : ErrorHandlerService.convertException(e, stackTrace),
      stackTrace: stackTrace,
      severity: ErrorSeverity.medium,
      buildContext: context,
    );
  }
}
```

### Loading States with Error Handling

```dart
@override
Widget build(BuildContext context) {
  return LoadingWithErrorWidget(
    future: _loadQuestions(),
    builder: (context, data) {
      return QuestionsList(questions: data);
    },
    errorBuilder: (context, error) {
      return ErrorDisplayWidget(
        exception: error,
        onRetry: _retryLoad,
      );
    },
    loadingWidget: const LoadingIndicator(),
  );
}
```

## 📱 4. UI Error Components

### ErrorDisplayWidget

```dart
ErrorDisplayWidget(
  exception: exception,
  onRetry: _retryOperation,        // İsteğe bağlı retry fonksiyonu
  customMessage: 'Custom error',   // İsteğe bağlı özel mesaj
  showDetails: true,               // Error code göster
)
```

### LoadingWithErrorWidget

```dart
LoadingWithErrorWidget(
  future: dataLoadingFuture,
  builder: (context, data) => SuccessWidget(data),
  errorBuilder: (context, error) => CustomErrorWidget(error),
  loadingWidget: CustomLoadingWidget(),
)
```

### ErrorBoundary

```dart
ErrorBoundary(
  errorBuilder: (context, error, stackTrace) {
    return ErrorPage(error: error);
  },
  child: YourMainWidget(),
)
```

## 🔄 5. Error Recovery Strategies

### Retry Mechanisms

```dart
class RetryableOperation {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  
  static Future<T> withRetry<T>(
    Future<T> Function() operation,
    {int maxAttempts = maxRetries}
  ) async {
    int attempts = 0;
    
    while (attempts < maxAttempts) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxAttempts) rethrow;
        
        await Future.delayed(retryDelay * attempts);
      }
    }
    
    throw Exception('Max retry attempts exceeded');
  }
}

// Kullanım
await RetryableOperation.withRetry(() => 
  questionService.loadQuestions()
);
```

### Fallback Data

```dart
class DataService {
  Future<List<Question>> loadQuestions() async {
    try {
      return await _loadFromNetwork();
    } catch (e) {
      try {
        return await _loadFromCache();
      } catch (e2) {
        return _getDefaultQuestions();
      }
    }
  }
  
  List<Question> _getDefaultQuestions() {
    // Fallback questions
    return [/* default questions */];
  }
}
```

## 📊 6. Error Analytics ve Monitoring

### Error Reporting

```dart
// Production'da error reporting
if (kReleaseMode) {
  await FirebaseCrashlytics.instance.recordError(
    exception,
    stackTrace,
    fatal: severity == ErrorSeverity.critical,
  );
}
```

### Error Metrics

```dart
class ErrorMetrics {
  static final Map<String, int> _errorCounts = {};
  
  static void recordError(String errorCode) {
    _errorCounts[errorCode] = (_errorCounts[errorCode] ?? 0) + 1;
  }
  
  static Map<String, int> getErrorStats() => _errorCounts;
}
```

## 🧪 7. Testing Error Handling

### Unit Tests

```dart
test('should handle network error gracefully', () async {
  // Arrange
  when(mockNetworkService.getData())
      .thenThrow(SocketException('No internet'));
  
  // Act
  await service.loadData();
  
  // Assert
  verify(mockErrorHandler.handleError(
    exception: any(named: 'exception'),
    severity: ErrorSeverity.medium,
  ));
});
```

### Widget Tests

```dart
testWidgets('should show error widget on data load failure', (tester) async {
  // Arrange
  when(mockService.loadData()).thenThrow(DataException(
    message: 'Load failed',
    code: 'LOAD_ERROR',
  ));
  
  // Act
  await tester.pumpWidget(MyWidget());
  await tester.pump();
  
  // Assert
  expect(find.byType(ErrorDisplayWidget), findsOneWidget);
  expect(find.text('Load failed'), findsOneWidget);
});
```

## 🚀 8. Performance Considerations

### Error Handler Optimization

```dart
class OptimizedErrorHandler {
  static const int maxErrorsPerMinute = 10;
  final List<DateTime> _recentErrors = [];
  
  Future<void> handleError(AppException exception) async {
    // Rate limiting
    _cleanOldErrors();
    
    if (_recentErrors.length >= maxErrorsPerMinute) {
      debugPrint('Error rate limit exceeded, dropping error');
      return;
    }
    
    _recentErrors.add(DateTime.now());
    
    // Handle error
    await _processError(exception);
  }
  
  void _cleanOldErrors() {
    final cutoff = DateTime.now().subtract(const Duration(minutes: 1));
    _recentErrors.removeWhere((time) => time.isBefore(cutoff));
  }
}
```

## 🔄 9. Migration Steps

### Mevcut Koddan Geçiş

1. **Exception Classes Ekle**
   ```dart
   // Eski
   throw Exception('Error message');
   
   // Yeni
   throw DataException(
     message: 'Error message',
     code: 'ERROR_CODE',
   );
   ```

2. **Try-Catch Blokları Güncelle**
   ```dart
   // Eski
   try {
     await operation();
   } catch (e) {
     print('Error: $e');
   }
   
   // Yeni
   try {
     await operation();
   } catch (e, stackTrace) {
     await _errorHandler.handleError(
       exception: ErrorHandlerService.convertException(e, stackTrace),
       stackTrace: stackTrace,
       severity: ErrorSeverity.medium,
       buildContext: context,
     );
   }
   ```

3. **UI Error States Ekle**
   ```dart
   // Loading/Error states için ErrorDisplayWidget kullan
   if (hasError) {
     return ErrorDisplayWidget(
       exception: error,
       onRetry: _retryOperation,
     );
   }
   ```

## ✅ 10. Best Practices

### Do's ✅

- **Specific Exception Types**: Her error type için uygun exception class kullanın
- **User-Friendly Messages**: Teknik detayları gizleyin, kullanıcı dostu mesajlar gösterin
- **Retry Mechanisms**: Network ve geçici errorlar için retry seçeneği sunun
- **Context Information**: Error handling'de context bilgisi ekleyin
- **Analytics**: Production'da error tracking kullanın

### Don'ts ❌

- **Generic Exceptions**: `Exception('error')` gibi generic exceptionlar kullanmayın
- **Silent Failures**: Errorları görmezden gelmeyin
- **Technical Messages**: Kullanıcıya stack trace göstermeyin
- **Blocking UI**: Critical olmayan errorlar için app'i bloklamayın
- **Over-Handling**: Her küçük error için dialog göstermeyin

## 🏁 Sonuç

Bu error handling sistemi ile:
- ✅ Daha iyi kullanıcı deneyimi
- ✅ Kolay debugging ve maintenance
- ✅ Production'da error tracking
- ✅ Graceful error recovery
- ✅ Consistent error UI

Sistemi kademeli olarak entegre edin ve test edin. Sorularınız için documentation'a başvurun.
