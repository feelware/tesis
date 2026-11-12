/* Ruta generada de Payload. Mantener este archivo fiel a la plantilla oficial. */
import type { Metadata } from "next";
import config from "@payload-config";
import { NotFoundPage, generatePageMetadata } from "@payloadcms/next/views";
// @ts-expect-error importMap.js se genera con `npm run generate:importmap`
import { importMap } from "../importMap.js";

type Args = {
  params: Promise<{ segments: string[] }>;
  searchParams: Promise<{ [key: string]: string | string[] }>;
};

export const generateMetadata = ({
  params,
  searchParams,
}: Args): Promise<Metadata> =>
  generatePageMetadata({ config, params, searchParams });

export default function NotFound({ params, searchParams }: Args) {
  return NotFoundPage({ config, params, searchParams, importMap });
}
