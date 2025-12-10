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

// Handle background messages (when PWA is closed or in background)
messaging.onBackgroundMessage((payload) => {
    console.log('[firebase-messaging-sw.js] Received background message:', payload);

    const notificationTitle = payload.notification?.title || 'Auto Olinda';
    const status = payload.data?.status;
    const bookingId = payload.data?.bookingId;
    
    // Determine if this is an urgent notification (finished status)
    const isUrgent = status === 'finished';
    
    const notificationOptions = {
        body: payload.notification?.body || 'Você tem uma nova notificação',
        icon: '/icons/Icon-192.png',
        badge: '/icons/Icon-maskable-192.png',
        tag: bookingId || 'notification',
        data: payload.data,
        // Keep notification visible until user interacts (for urgent notifications)
        requireInteraction: isUrgent,
        // Vibration pattern: [vibrate, pause, vibrate]
        vibrate: [200, 100, 200],
        // Ensure sound plays
        silent: false,
        // Actions for quick access
        actions: bookingId ? [
            {
                action: 'view',
                title: 'Ver Detalhes',
                icon: '/icons/Icon-192.png'
            },
            {
                action: 'dismiss',
                title: 'Dispensar'
            }
        ] : [],
        // Timestamp for when notification was created
        timestamp: Date.now(),
        // Renotify even if tag is the same
        renotify: true
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
    console.log('[firebase-messaging-sw.js] Notification clicked:', event);

    event.notification.close();

    // Handle action clicks
    const action = event.action;
    if (action === 'dismiss') {
        return; // Just close the notification
    }

    // Navigate to the app when notification is clicked (or 'view' action)
    const bookingId = event.notification.data?.bookingId;
    const urlToOpen = bookingId ? `/booking/${bookingId}` : '/dashboard';
    const fullUrl = new URL(urlToOpen, self.location.origin).href;

    event.waitUntil(
        clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
            // Check if there's already a window open with the app
            for (const client of clientList) {
                // If a window is already open, focus it and navigate
                if (client.url.includes(self.location.origin) && 'focus' in client) {
                    return client.focus().then(() => {
                        if ('navigate' in client) {
                            return client.navigate(fullUrl);
                        }
                    });
                }
            }
            // If no window is open, open a new one
            if (clients.openWindow) {
                return clients.openWindow(fullUrl);
            }
        })
    );
});

// Handle notification close
self.addEventListener('notificationclose', (event) => {
    console.log('[firebase-messaging-sw.js] Notification closed:', event);
});

// Handle push event directly (fallback for when Firebase SDK doesn't handle it)
self.addEventListener('push', (event) => {
    console.log('[firebase-messaging-sw.js] Push event received:', event);
    
    // If Firebase SDK already handled it, don't duplicate
    if (event.data) {
        try {
            const payload = event.data.json();
            // Check if this looks like a Firebase message (has notification or data)
            if (payload.notification || payload.data) {
                // Let Firebase SDK handle it
                return;
            }
        } catch (e) {
            // Not JSON, let Firebase handle it
        }
    }
});
