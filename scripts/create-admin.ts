import { getPayload } from "payload";
import config from "../payload.config";

const email = process.env.ADMIN_EMAIL ?? "admin@example.com";
const password = process.env.ADMIN_PASSWORD ?? "admin123";

const payload = await getPayload({ config });

const existing = await payload.find({
  collection: "users",
  where: { email: { equals: email } },
  limit: 1,
});

if (existing.docs.length > 0) {
  console.log(`El usuario ${email} ya existe; no se hizo nada.`);
} else {
  await payload.create({
    collection: "users",
    data: { email, password, name: "Administrador", role: "admin" },
  });
  console.log(`Usuario administrador creado: ${email}`);
}

await payload.destroy();
