const functions = require('firebase-functions');
const stripe = require('stripe')('sk_test_51SESH5GK66huHpO8GiizpQkbJMMZTabijXbiFkj7PWb1L6YSeIyZIZAllJbs2evfosdxRUIxUi9NHhnTIJ1CgkiF00ahE9NOnN');

exports.createPaymentIntent = functions.https.onCall(async (data, context) => {
    try {
        // Prüfe ob data.data existiert (häufiges Problem)
        const payload = data.data || data;
        const amount = payload.amount;
        const currency = payload.currency;

        // Validierung
        if (!amount) {
            throw new functions.https.HttpsError(
                'invalid-argument',
                'Amount ist erforderlich',
            );
        }
        if (!currency) {
            throw new functions.https.HttpsError(
                'invalid-argument',
                'Currency ist erforderlich',
            );
        }
        console.log('Erstelle Payment Intent mit:', amount, currency);

        // Payment Intent erstellen
        const paymentIntent = await stripe.paymentIntents.create({
            'amount': amount,
            'currency': currency,
            'payment_method_types': ['card'], //<-- hier die Abrechnungsmethoden einfügen 
            //['card', 'sepa_debit', 'giropay', 'sofort']
        });

        return {
            clientSecret: paymentIntent.client_secret,
        };

    } catch (error) {
        console.error('Fehler beim Erstellen des Payment Intent:', error);
        throw new functions.https.HttpsError('internal', error.message);
    }
});
