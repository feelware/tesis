"use client";

import { useState, type FormEvent } from "react";
import type { AuthUser } from "./App";

interface AuthPanelProps {
  onAuthenticated: (user: AuthUser) => void;
}

const readUser = (raw: {
  id: number | string;
  name?: string | null;
  email?: string | null;
}): AuthUser => ({
  id: String(raw.id),
  name: raw.name ?? raw.email ?? `jugador ${raw.id}`,
  email: raw.email ?? "",
});

const readError = async (response: Response): Promise<string> => {
  const body = (await response.json().catch(() => ({}))) as {
    errors?: { message?: string }[];
    error?: string;
  };
  return (
    body.errors?.[0]?.message ?? body.error ?? "No se pudo completar la operación"
  );
};

export const AuthPanel = ({ onAuthenticated }: AuthPanelProps) => {
  const [mode, setMode] = useState<"login" | "register">("login");
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);

  const submit = async (event: FormEvent) => {
    event.preventDefault();
    setBusy(true);
    setError(null);
    try {
      if (mode === "register") {
        const created = await fetch("/api/users", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          credentials: "include",
          body: JSON.stringify({ email, password, name }),
        });
        if (!created.ok) {
          throw new Error(await readError(created));
        }
      }
      const response = await fetch("/api/users/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        credentials: "include",
        body: JSON.stringify({ email, password }),
      });
      const body = (await response.json().catch(() => ({}))) as {
        user?: Parameters<typeof readUser>[0];
      };
      if (!response.ok || !body.user) {
        throw new Error(await readError(response));
      }
      onAuthenticated(readUser(body.user));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Error de autenticación");
    } finally {
      setBusy(false);
    }
  };

  return (
    <form
      className="mx-auto max-w-md space-y-4 rounded-lg border border-zinc-200 bg-white p-6 shadow-sm"
      onSubmit={(event) => void submit(event)}
    >
      <h2 className="text-xl font-semibold">
        {mode === "login" ? "Iniciar sesión" : "Crear cuenta"}
      </h2>
      {mode === "register" ? (
        <label className="block">
          <span className="text-sm font-medium text-zinc-700">Nombre</span>
          <input
            className="mt-1 w-full rounded border border-zinc-300 p-2"
            value={name}
            onChange={(event) => setName(event.target.value)}
            required
          />
        </label>
      ) : null}
      <label className="block">
        <span className="text-sm font-medium text-zinc-700">Correo</span>
        <input
          type="email"
          className="mt-1 w-full rounded border border-zinc-300 p-2"
          value={email}
          onChange={(event) => setEmail(event.target.value)}
          required
        />
      </label>
      <label className="block">
        <span className="text-sm font-medium text-zinc-700">Contraseña</span>
        <input
          type="password"
          className="mt-1 w-full rounded border border-zinc-300 p-2"
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          required
          minLength={8}
        />
      </label>
      {error ? <p className="text-sm text-red-600">{error}</p> : null}
      <button
        type="submit"
        disabled={busy}
        className="w-full rounded bg-indigo-600 p-2 font-medium text-white hover:bg-indigo-700 disabled:opacity-50"
      >
        {busy
          ? "Un momento…"
          : mode === "login"
            ? "Iniciar sesión"
            : "Crear cuenta"}
      </button>
      <button
        type="button"
        className="w-full text-sm text-indigo-600 hover:underline"
        onClick={() => {
          setMode(mode === "login" ? "register" : "login");
          setError(null);
        }}
      >
        {mode === "login"
          ? "¿No tienes cuenta? Regístrate"
          : "¿Ya tienes cuenta? Inicia sesión"}
      </button>
    </form>
  );
};
