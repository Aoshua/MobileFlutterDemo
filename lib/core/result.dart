// Sealed means all subclasses must be in the same file--the compiler can enumerate them.
sealed class Result<T, E> {
  const Result();
}

// Final means no further subclassing is allowed outside this file.
final class Ok<T, E> extends Result<T, E> {
  const Ok(this.value);
  final T value;
}

final class Err<T, E> extends Result<T, E> {
  const Err(this.error);
  final E error;
}
