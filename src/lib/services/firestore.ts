// src/lib/services/firestore.ts
import {
  collection,
  doc,
  getDoc as fsGetDoc,
  getDocs,
  addDoc as fsAddDoc,
  updateDoc as fsUpdateDoc,
  deleteDoc as fsDeleteDoc,
  onSnapshot,
  query,
  type QueryConstraint
} from 'firebase/firestore';
import { getFirebaseDb } from '../config/firebase';

export type FirestoreData = Record<string, unknown>;
export type Mapper<T> = (id: string, data: FirestoreData) => T;

export async function getCol<T>(
  path: string,
  mapper: Mapper<T>,
  ...constraints: QueryConstraint[]
): Promise<T[]> {
  const db = getFirebaseDb();
  const q = constraints.length > 0
    ? query(collection(db, path), ...constraints)
    : collection(db, path);
  const snap = await getDocs(q);
  return snap.docs.map((d) => mapper(d.id, d.data() as FirestoreData));
}

export function streamCol<T>(
  path: string,
  mapper: Mapper<T>,
  onData: (items: T[]) => void,
  onError: (err: Error) => void,
  ...constraints: QueryConstraint[]
): () => void {
  const db = getFirebaseDb();
  const q = constraints.length > 0
    ? query(collection(db, path), ...constraints)
    : collection(db, path);

  return onSnapshot(
    q,
    (snap) => {
      const items = snap.docs.map((d) => mapper(d.id, d.data() as FirestoreData));
      onData(items);
    },
    (err) => onError(err as Error)
  );
}

export async function getDocById<T>(
  path: string,
  id: string,
  mapper: Mapper<T>
): Promise<T | null> {
  const db = getFirebaseDb();
  const ref = doc(db, path, id);
  const snap = await fsGetDoc(ref);
  if (!snap.exists()) return null;
  return mapper(snap.id, snap.data() as FirestoreData);
}

export function streamDoc<T>(
  path: string,
  id: string,
  mapper: Mapper<T>,
  onData: (item: T | null) => void,
  onError: (err: Error) => void
): () => void {
  const db = getFirebaseDb();
  const ref = doc(db, path, id);
  return onSnapshot(
    ref,
    (snap) => {
      if (!snap.exists()) {
        onData(null);
        return;
      }
      onData(mapper(snap.id, snap.data() as FirestoreData));
    },
    (err) => onError(err as Error)
  );
}

export async function addDocument(
  path: string,
  data: FirestoreData
): Promise<string> {
  const db = getFirebaseDb();
  const ref = await fsAddDoc(collection(db, path), data);
  return ref.id;
}

export async function updateDocument(
  path: string,
  id: string,
  data: Partial<FirestoreData>
): Promise<void> {
  const db = getFirebaseDb();
  await fsUpdateDoc(doc(db, path, id), data);
}

export async function deleteDocument(
  path: string,
  id: string
): Promise<void> {
  const db = getFirebaseDb();
  await fsDeleteDoc(doc(db, path, id));
}