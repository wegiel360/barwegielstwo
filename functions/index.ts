import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();

export const clearDzwonek = functions.https.onCall(async (data, context) => {
  const db = admin.firestore();
  const dwonekRef = db.collection('settings').doc('dzwonek');
  await dwonekRef.set({ active: false }, { merge: true });
  await new Promise((resolve) => setTimeout(resolve, 2000));
  await dwonekRef.set({ active: false }, { merge: true });
  return { cleared: true };
});

export const cleanupOldOrders = functions.https.onCall(async (data, context) => {
  const db = admin.firestore();
  const cutoff = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
  const snapshot = await db.collection('orders')
    .where('timestamp', '<', cutoff)
    .where('status', 'in', ['Zakończone', 'Anulowane'])
    .get();
  const batch = db.batch();
  for (const doc of snapshot.docs) {
    batch.delete(doc.ref);
  }
  await batch.commit();
  return { deleted: snapshot.size };
});

export const onOrderCreated = functions.firestore
  .document('orders/{orderId}')
  .onCreate(async (snap, context) => {
    const data = snap.data();
    console.log(`New order created: ${data?.order_number} - ${data?.status}`);
    await snap.ref.update({ created_at: admin.firestore.FieldValue.serverTimestamp() });
  });

export const onOrderStatusChanged = functions.firestore
  .document('orders/{orderId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();
    if (before?.status !== after?.status) {
      console.log(`Order ${context.params.orderId} status changed: ${before?.status} -> ${after?.status}`);
      const callable = admin.app().functions().httpsCallable('triggerNotification');
      // Notification trigger placeholder
    }
  });