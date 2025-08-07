import 'package:e_comerce_app_ui/core/network/network_info.dart';
import 'package:e_comerce_app_ui/features/product/data/datasources/local_data_source.dart';
import 'package:e_comerce_app_ui/features/product/data/datasources/remote_data_source.dart';
import 'package:e_comerce_app_ui/features/product/data/models/product_model.dart';
import 'package:e_comerce_app_ui/features/product/data/repositories/product_repository_impl.dart';
import 'package:e_comerce_app_ui/features/product/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Mock classes
class MockLocalDataSource extends Mock implements LocalDataSource {}

class MockRemoteDataSource extends Mock implements RemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late ProductRepositoryImpl repository;
  late MockLocalDataSource mockLocalDataSource;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockLocalDataSource = MockLocalDataSource();
    mockRemoteDataSource = MockRemoteDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = ProductRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  const testProductModel = ProductModel(
    id: '1',
    name: 'Test Product',
    description: 'Test Description',
    price: 10.0,
    imageUrl: 'https://example.com/image.jpg',
  );

  final testProduct = Product(
    id: '1',
    name: 'Test Product',
    description: 'Test Description',
    price: 10.0,
    imageUrl: 'https://example.com/image.jpg',
  );

  group('getProduct', () {
    test(
      'should fetch product from remote when network is connected',
      () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(
          mockRemoteDataSource.getProduct('1'),
        ).thenAnswer((_) async => testProductModel);
        when(
          mockLocalDataSource.insertProduct(testProductModel),
        ).thenAnswer((_) async => {});

        // Act
        final result = await repository.getProduct('1');

        // Assert
        verify(mockNetworkInfo.isConnected).called(1);
        verify(mockRemoteDataSource.getProduct('1')).called(1);
        verify(mockLocalDataSource.insertProduct(testProductModel)).called(1);
        expect(result, equals(testProduct));
      },
    );

    test(
      'should fetch product from local when network is disconnected',
      () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(
          mockLocalDataSource.getProduct(1),
        ).thenAnswer((_) async => testProductModel);

        // Act
        final result = await repository.getProduct('1');

        // Assert
        verify(mockNetworkInfo.isConnected).called(1);
        verify(mockLocalDataSource.getProduct(1)).called(1);
        verifyNever(mockRemoteDataSource.getProduct(any));
        expect(result, equals(testProduct));
      },
    );

    test(
      'should throw exception when product is not found locally and no network',
      () async {
        // Arrange
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
        when(mockLocalDataSource.getProduct(1)).thenAnswer((_) async => null);

        // Act
        final call = repository.getProduct;

        // Assert
        expect(() => call('1'), throwsException);
      },
    );
  });

  group('insertProduct', () {
    test('should insert product into local data source', () async {
      // Arrange
      when(
        mockLocalDataSource.insertProduct(testProductModel),
      ).thenAnswer((_) async => {});

      // Act
      await repository.insertProduct(testProduct);

      // Assert
      verify(mockLocalDataSource.insertProduct(testProductModel)).called(1);
    });
  });

  group('deleteProduct', () {
    test('should delete product from local data source', () async {
      // Arrange
      when(mockLocalDataSource.deleteProduct(1)).thenAnswer((_) async => {});

      // Act
      await repository.deleteProduct('1');

      // Assert
      verify(mockLocalDataSource.deleteProduct(1)).called(1);
    });
  });

  group('updateProduct', () {
    test('should update product in local data source', () async {
      // Arrange
      when(
        mockLocalDataSource.updateProduct(testProductModel),
      ).thenAnswer((_) async => {});

      // Act
      await repository.updateProduct(testProduct);

      // Assert
      verify(mockLocalDataSource.updateProduct(testProductModel)).called(1);
    });
  });
}
