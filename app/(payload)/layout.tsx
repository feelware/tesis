import type { ServerFunctionClient } from "payload";
import React from "react";
import "@payloadcms/next/css";
import config from "@payload-config";
import { handleServerFunctions, RootLayout } from "@payloadcms/next/layouts";
// @ts-expect-error importMap.js se genera con `npm run generate:importmap`
import { importMap } from "./admin/importMap.js";
import "./custom.scss";

const serverFunction: ServerFunctionClient = async function (args) {
  "use server";
  return handleServerFunctions({ ...args, config, importMap });
};

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <RootLayout config={config} importMap={importMap} serverFunction={serverFunction}>
      {children}
    </RootLayout>
  );
}
