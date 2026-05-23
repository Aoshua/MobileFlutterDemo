// Sealed means all subclasses must be in the same file--the compiler can enumerate them.
sealed class Result<T, E> {
    const Result();
}

// Final means no further subclassing is allowed outside this file.
final class Ok<T, E> extends Result<T, E> {
    final T value;
    const Ok(this.value);
}

final class Err<T, E> extends Result<T, E> {
    final E error;
    const Err(this.error);
}