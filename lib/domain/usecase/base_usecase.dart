abstract class BaseUseCase<R, P> {
  Future<R> execute({P? params});
}
