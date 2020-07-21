import 'package:flutter_app/data/model/account.dart';

class AccountManager {

  static final AccountManager _accountManager = AccountManager._internal();

  factory AccountManager() {
    return _accountManager;
  }

  Account _account;

  setAccount(Account account) {
    _account = account;
  }

  Account getAccount() {
    return _account;
  }

  AccountManager._internal();

}