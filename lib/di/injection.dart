import 'package:get_it/get_it.dart';
import '../data/database/database_factory.dart';
import '../data/dao/pessoa_dao.dart';
import '../data/repositories/pessoa_repository_impl.dart';
import '../domain/repositories/pessoa_repository.dart';
import '../domain/stores/pessoa_store.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
  final db = await DatabaseFactoryProvider.create('meu_banco.db');

  getIt.registerSingleton<PessoaDao>(PessoaDao(db));

  getIt.registerSingleton<PessoaRepository>(
    PessoaRepositoryImpl(getIt<PessoaDao>()),
  );

  getIt.registerSingleton<PessoaStore>(PessoaStore(getIt<PessoaRepository>()));
}
