import { GlossaryTerm } from "../types";

const DB_NAME = "AzarestanOfflineGlossary";
const STORE_NAME = "terms";
const DB_VERSION = 1;

export function initDB(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    if (!window.indexedDB) {
      reject(new Error("مرورگر شما از پایگاه داده IndexedDB پشتیبانی نمی‌کند."));
      return;
    }

    const request = window.indexedDB.open(DB_NAME, DB_VERSION);

    request.onerror = (event) => {
      reject(new Error("خطا در باز کردن پایگاه داده آفلاین"));
    };

    request.onsuccess = (event) => {
      resolve(request.result);
    };

    request.onupgradeneeded = (event) => {
      const db = request.result;
      if (!db.objectStoreNames.contains(STORE_NAME)) {
        const store = db.createObjectStore(STORE_NAME, { keyPath: "id" });
        store.createIndex("category", "category", { unique: false });
        store.createIndex("project", "project", { unique: false });
        store.createIndex("term", "term", { unique: false });
      }
    };
  });
}

export async function saveTerms(terms: GlossaryTerm[]): Promise<void> {
  const db = await initDB();
  return new Promise((resolve, reject) => {
    const transaction = db.transaction(STORE_NAME, "readwrite");
    const store = transaction.objectStore(STORE_NAME);

    transaction.oncomplete = () => {
      resolve();
    };

    transaction.onerror = () => {
      reject(new Error("خطا در ذخیره‌سازی واژه‌ها در حافظه آفلاین"));
    };

    terms.forEach((term) => {
      store.put(term);
    });
  });
}

export async function clearTerms(): Promise<void> {
  const db = await initDB();
  return new Promise((resolve, reject) => {
    const transaction = db.transaction(STORE_NAME, "readwrite");
    const store = transaction.objectStore(STORE_NAME);

    const request = store.clear();

    request.onsuccess = () => {
      resolve();
    };

    request.onerror = () => {
      reject(new Error("خطا در پاکسازی حافظه آفلاین"));
    };
  });
}

export async function getAllTerms(): Promise<GlossaryTerm[]> {
  const db = await initDB();
  return new Promise((resolve, reject) => {
    const transaction = db.transaction(STORE_NAME, "readonly");
    const store = transaction.objectStore(STORE_NAME);
    const request = store.getAll();

    request.onsuccess = () => {
      resolve(request.result || []);
    };

    request.onerror = () => {
      reject(new Error("خطا در بازیابی واژه‌های آفلاین"));
    };
  });
}

export async function getTermsCount(): Promise<number> {
  const db = await initDB();
  return new Promise((resolve, reject) => {
    const transaction = db.transaction(STORE_NAME, "readonly");
    const store = transaction.objectStore(STORE_NAME);
    const request = store.count();

    request.onsuccess = () => {
      resolve(request.result || 0);
    };

    request.onerror = () => {
      reject(new Error("خطا در شمارش واژه‌های آفلاین"));
    };
  });
}

export async function deleteTerm(id: string): Promise<void> {
  const db = await initDB();
  return new Promise((resolve, reject) => {
    const transaction = db.transaction(STORE_NAME, "readwrite");
    const store = transaction.objectStore(STORE_NAME);
    const request = store.delete(id);

    request.onsuccess = () => {
      resolve();
    };

    request.onerror = () => {
      reject(new Error("خطا در حذف واژه آفلاین"));
    };
  });
}
