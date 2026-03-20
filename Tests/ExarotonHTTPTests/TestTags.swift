import Testing

extension Tag {
    @Tag static var unit: Self
    @Tag static var integration: Self

    @Tag static var http: Self

    @Tag static var middleware: Self
    @Tag static var transport: Self
}
