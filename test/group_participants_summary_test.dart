import 'package:flutter_test/flutter_test.dart';

void main() {
  test('computeParticipantsSummary calcola correttamente', () {
    // Crea un'istanza della classe (se serve)

    // Prepara dati di esempio
    final expenses = [
      {
        'user_id': 'u1',
        'paid_amount': 10,
        'total_amount': 20,
        'split_rate': null,
      },
      {
        'user_id': 'u2',
        'paid_amount': 10,
        'total_amount': 20,
        'split_rate': null,
      },
    ];

    // TODO: da implementare
    // final summary = GroupExpensesUtil.computeParticipantsSummary(expenses: expenses, numberOfParticipants: 2);

    // expect(summary['u1']!.alreadyPaid, 10);
    // expect(summary['u2']!.alreadyPaid, 10);
    // expect(summary['u1']!.toPay, 10);
    // expect(summary['u2']!.toPay, 10);
  });
}