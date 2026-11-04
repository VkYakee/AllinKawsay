// src/lib/config/firebase.ts
import { initializeApp, getApps, type FirebaseApp } from 'firebase/app';
import { getAuth, type Auth } from 'firebase/auth';
import { getFirestore, type Firestore } from 'firebase/firestore';

// ⚠️ Estos valores NO son secretos: son identificadores públicos del proyecto.
// La seguridad real está en las Reglas de Firestore.
const firebaseConfig = {
  apiKey: 'AIzaSyDu7lBJj2mFOag8rUSpLIf5Q1hTw7jZG5I',
  authDomain: 'allinkawsay-326c9.firebaseapp.com',
  projectId: 'allinkawsay-326c9',
  storageBucket: 'allinkawsay-326c9.firebasestorage.app',
  messagingSenderId: '603260146479',
  appId: '1:603260146479:web:276a453d483e4bceacc7da'
};

let _app: FirebaseApp | null = null;
let _auth: Auth | null = null;
let _db: Firestore | null = null;

export function getFirebaseApp(): FirebaseApp {
  if (_app) return _app;
  _app = getApps()[0] ?? initializeApp(firebaseConfig);
  return _app;
}

export function getFirebaseAuth(): Auth {
  if (_auth) return _auth;
  _auth = getAuth(getFirebaseApp());
  return _auth;
}

export function getFirebaseDb(): Firestore {
  if (_db) return _db;
  _db = getFirestore(getFirebaseApp());
  return _db;
}

// OneSignal: pega aquí el App ID cuando lo tengas.
// Déjalo vacío y la app seguirá funcionando sin notificaciones push.
export const ONESIGNAL_APP_ID = '';