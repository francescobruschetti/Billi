export function normalizePrice(value: unknown): number | null {
  if (value == null || value === "") return null;

  if (typeof value === "number") {
    return value;
  }

  if (typeof value !== "string") {
    throw new Error("Price must be a number or string");
  }

  let s = value.trim();

  // Rimuove spazi
  s = s.replace(/\s/g, "");

  const lastDot = s.lastIndexOf(".");
  const lastComma = s.lastIndexOf(",");

  if (lastDot !== -1 || lastComma !== -1) {
    // L'ultimo tra . e , è il separatore decimale
    const decimalIndex = Math.max(lastDot, lastComma);

    const integerPart = s
      .substring(0, decimalIndex)
      .replace(/[.,]/g, "");

    const decimalPart = s
      .substring(decimalIndex + 1)
      .replace(/[.,]/g, "");

    s = "$integerPart.$decimalPart";
  }

  finalNumber = Number(s);

  if (Number.isNaN(finalNumber)) {
    throw new Error(`Invalid price: ${value}`);
  }

  return finalNumber;
}