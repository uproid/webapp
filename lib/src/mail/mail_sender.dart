import 'package:dweb/src/tools/console.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class MailSender {
  static Future<bool> sendEmail({
    required String from,
    String fromName = '',
    String host = 'localhost',
    int port = 1025,
    required List<String> to,
    String subject = '',
    String html = '',
    String text = '',
    String? password,
    String? username,
    bool ssl = true,
    bool allowInsecure = true,
  }) async {
    // Set up SMTP server credentials for Mailcatcher.
    final smtpServer = SmtpServer(
      host,
      port: port,
      ssl: ssl,
      allowInsecure: allowInsecure,
      password: password,
      username: username,
    );

    // Create a new email message.
    final message = Message()
      ..from = Address(from, fromName)
      ..recipients = to
      ..subject = subject
      ..text = text
      ..html = html;

    try {
      // Send the email using the SMTP server.
      await send(message, smtpServer);
      return true;
    } on MailerException catch (e) {
      Console.e('Message not sent: ${e.toString()}');
    }

    return false;
  }
}
