import type { Metadata } from "next";
import "./styles.css";

export const metadata: Metadata = {
  title: "Prototipo — Videojuego de entrenamiento auditivo",
  description:
    "Prototipo de la tesis: partida de dictado y repentización melódica.",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="es">
      <body>{children}</body>
    </html>
  );
}
