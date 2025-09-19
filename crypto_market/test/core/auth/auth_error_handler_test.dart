import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:crypto_market/core/auth/auth_error_handler.dart';
import 'package:crypto_market/core/blockchain/errors.dart';

// Mock classes
class MockBuildContext extends Mock implements BuildContext {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MockBuildContext';
  }
}

class MockNavigatorState extends Mock implements NavigatorState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MockNavigatorState';
  }
}

class MockScaffoldMessenger extends Mock implements ScaffoldMessengerState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MockScaffoldMessenger';
  }
}

class MockScaffoldFeatureController extends Mock
    implements ScaffoldFeatureController<SnackBar, SnackBarClosedReason> {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MockScaffoldFeatureController';
  }
}

class MockGlobalKey extends Mock implements GlobalKey<NavigatorState> {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MockGlobalKey';
  }
}

void main() {
  late AuthErrorHandler authErrorHandler;
  late MockNavigatorState mockNavigatorState;

  setUp(() {
    mockNavigatorState = MockNavigatorState();
    final mockNavigatorKey = MockGlobalKey();
    when(() => mockNavigatorKey.currentState).thenReturn(mockNavigatorState);
    authErrorHandler = AuthErrorHandler(navigatorKey: mockNavigatorKey);
  });

  group('AuthErrorHandler', () {
    group('Handle Auth Error', () {
      test('handles network connection errors without throwing', () {
        final error = NetworkError('No internet connection');
        expect(() => authErrorHandler.handleAuthError(error), returnsNormally);
      });

      test('handles authentication errors without throwing', () {
        final error = AuthError('Invalid credentials');
        expect(() => authErrorHandler.handleAuthError(error), returnsNormally);
      });

      test('handles OAuth errors without throwing', () {
        final error = AuthError('Google sign-in was cancelled');
        expect(() => authErrorHandler.handleAuthError(error), returnsNormally);
      });

      test('handles ICP errors without throwing', () {
        final error = ICPError('Principal generation failed');
        expect(() => authErrorHandler.handleAuthError(error), returnsNormally);
      });

      test('handles storage errors without throwing', () {
        final error = StorageError('Secure storage unavailable');
        expect(() => authErrorHandler.handleAuthError(error), returnsNormally);
      });

      test('handles validation errors without throwing', () {
        final error = ValidationError('Invalid email format');
        expect(() => authErrorHandler.handleAuthError(error), returnsNormally);
      });

      test('handles unknown errors without throwing', () {
        final error = Exception('Unknown error occurred');
        expect(() => authErrorHandler.handleAuthError(error), returnsNormally);
      });
    });

    group('Show Error SnackBar', () {
      test('shows error snackbar with message', () async {
        final error = AuthError('Test error');
        final mockContext = MockBuildContext();
        final mockScaffoldMessenger = MockScaffoldMessenger();
        final mockController = MockScaffoldFeatureController();

        when(() => mockNavigatorState.context).thenReturn(mockContext);
        when(
          () => ScaffoldMessenger.of(mockContext),
        ).thenReturn(mockScaffoldMessenger);
        when(
          () => mockScaffoldMessenger.showSnackBar(any()),
        ).thenReturn(mockController);

        await authErrorHandler.showErrorSnackBar(error);

        verify(() => mockScaffoldMessenger.showSnackBar(any())).called(1);
      });

      test('shows error snackbar with custom duration', () async {
        final error = AuthError('Test error');
        final mockContext = MockBuildContext();
        final mockScaffoldMessenger = MockScaffoldMessenger();
        final mockController = MockScaffoldFeatureController();
        final customDuration = Duration(seconds: 5);

        when(() => mockNavigatorState.context).thenReturn(mockContext);
        when(
          () => ScaffoldMessenger.of(mockContext),
        ).thenReturn(mockScaffoldMessenger);
        when(
          () => mockScaffoldMessenger.showSnackBar(any()),
        ).thenReturn(mockController);

        await authErrorHandler.showErrorSnackBar(
          error,
          duration: customDuration,
        );

        verify(() => mockScaffoldMessenger.showSnackBar(any())).called(1);
      });
    });

    group('Show Error Dialog', () {
      test('shows error dialog with error details', () async {
        final error = AuthError('Test error');
        final mockContext = MockBuildContext();

        when(() => mockNavigatorState.context).thenReturn(mockContext);
        when(
          () => showDialog(
            context: any(named: 'context'),
            builder: any(named: 'builder'),
          ),
        ).thenAnswer((_) async => null);

        await authErrorHandler.showErrorDialog(error);

        verify(
          () => showDialog(
            context: any(named: 'context'),
            builder: any(named: 'builder'),
          ),
        ).called(1);
      });

      test('shows error dialog with retry action', () async {
        final error = AuthError('Test error');
        final mockContext = MockBuildContext();

        when(() => mockNavigatorState.context).thenReturn(mockContext);
        when(
          () => showDialog(
            context: any(named: 'context'),
            builder: any(named: 'builder'),
          ),
        ).thenAnswer((_) async => null);

        await authErrorHandler.showErrorDialog(error, onRetry: () {});

        verify(
          () => showDialog(
            context: any(named: 'context'),
            builder: any(named: 'builder'),
          ),
        ).called(1);
      });
    });
  });
}
