import "package:flutter_bloc/flutter_bloc.dart";

abstract class StoreBase<State> extends BlocBase<State> {
  StoreBase(super.state);

  Future<State> get();

  dirty() {}

  renew() {}
}
