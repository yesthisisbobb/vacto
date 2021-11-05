import 'dart:async';

class Validation {
  final validateUsername = StreamTransformer<String, String>.fromHandlers(
    handleData: (username, sink) {
      if (username == "") {
        sink.addError("We can't call you blank");
      } else if (username == "Bobby Ishak Bahtera") {
        sink.addError("But... that's my name...");
      } else if (username.length > 32) {
        sink.addError("Maximum character length reached");
      } else {
        sink.add(username);
      }
    }
  );

  final validateName = StreamTransformer<String, String>.fromHandlers(
    handleData: (name, sink) {
      if (name == "") {
        sink.addError("Name must not be empty");
      }
      else if(name.length > 36){
        sink.addError("Maximum character length reached");
      }
      else {
        sink.add(name);
      }
    }
  );

  final validateEmail =
      StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    if (email.contains('@')) {
      sink.add(email);
    }
    else if(email.length > 40){
      sink.addError("Maximum character length reached");
    }
    else {
      sink.addError("Not a valid email address");
    }
  });

  final validatePassword = StreamTransformer<String, String>.fromHandlers(
      handleData: (password, sink) {
    if (password.length > 3) {
      sink.add(password);
    } else {
      sink.addError("Password must be between 4 - 16 characters");
    }
  });
}
