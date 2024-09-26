class Subscription {
  Function handler;
  Subscription(this.handler);

  Future<void> cancel() async {
    await handler();
  }
}
