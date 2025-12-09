// Firebase Messaging Service Worker for Web Push Notifications
// This file must be placed in the web/ directory

importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Initialize Firebase in the service worker
// These values must match firebase_options.dart web config
firebase.initializeApp({
    apiKey: "AIzaSyBSijOdKJP2eD2QwAOqy5rV86EeGXx3QKE",
    authDomain: "autoolinda-5199e.firebaseapp.com",
    projectId: "autoolinda-5199e",
    storageBucket: "autoolinda-5199e.firebasestorage.app",
    messagingSenderId: "992114921273",
    appId: "1:992114921273:web:0b81f9a88b2e14610de2e8"
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message:', payload);

    const notificationTitle = payload.notification?.title || 'Auto Olinda';
    const notificationOptions = {
        body: payload.notification?.body || 'Você tem uma nova notificação',
        icon: '/icons/Icon-192.png',
        badge: '/icons/Icon-maskable-192.png',
        tag: payload.data?.bookingId || 'notification',
        data: payload.data
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
    console.log('[firebase-messaging-sw.js] Notification clicked:', event);

    event.notification.close();

    // Navigate to the app when notification is clicked
    const bookingId = event.notification.data?.bookingId;
    const urlToOpen = bookingId ? `/booking/${bookingId}` : '/dashboard';

    event.waitUntil(
        clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
            // Check if there's already a window open
            for (const client of clientList) {
                if ('focus' in client) {
                    client.focus();
                    client.navigate(urlToOpen);
                    return;
                }
            }
            // If no window is open, open a new one
            if (clients.openWindow) {
                return clients.openWindow(urlToOpen);
            }
        })
    );
});
