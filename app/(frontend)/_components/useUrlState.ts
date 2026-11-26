"use client";

import { useCallback, useMemo, useSyncExternalStore } from "react";

const EMPTY_SEARCH = "";

const subscribe = (onStoreChange: () => void) => {
  window.addEventListener("popstate", onStoreChange);
  return () => window.removeEventListener("popstate", onStoreChange);
};

const getSnapshot = () => window.location.search;

const getServerSnapshot = () => EMPTY_SEARCH;

export const useUrlState = () => {
  const search = useSyncExternalStore(
    subscribe,
    getSnapshot,
    getServerSnapshot,
  );
  const params = useMemo(() => new URLSearchParams(search), [search]);

  const setParams = useCallback((updates: Record<string, string | null>) => {
    const next = new URLSearchParams(window.location.search);
    for (const [key, value] of Object.entries(updates)) {
      if (value === null) {
        next.delete(key);
      } else {
        next.set(key, value);
      }
    }
    const query = next.toString();
    window.history.replaceState(
      null,
      "",
      query ? `?${query}` : window.location.pathname,
    );
    window.dispatchEvent(new PopStateEvent("popstate"));
  }, []);

  return [params, setParams] as const;
};
