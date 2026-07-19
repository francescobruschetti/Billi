export function normalizePrice(value: unknown): number | null {
  console.log("normalizePrice called with value:", value);
  if (value == null || value === "") return null;

  console.log("Type of value:", typeof value);
  if (typeof value === "number") {
    return value;
  }

  // if (typeof value !== "string") {
  //   throw new Error("Price must be a number or string");
  // }

  console.log("Value is a string, proceeding with normalization:", value);
  let s = value.trim();

  // Rimuove spazi
  s = s.replace(/\s/g, "");

  const lastDot = s.lastIndexOf(".");
  const lastComma = s.lastIndexOf(",");

  console.log("Last dot index:", lastDot, "Last comma index:", lastComma);
  if (lastDot !== -1 || lastComma !== -1) {
    // L'ultimo tra . e , è il separatore decimale
    const decimalIndex = Math.max(lastDot, lastComma);

    const integerPart = s
      .substring(0, decimalIndex)
      .replace(/[.,]/g, "");

    const decimalPart = s
      .substring(decimalIndex + 1)
      .replace(/[.,]/g, "");

    s = `${integerPart}.${decimalPart}`;
  }

  console.log("Normalized string representation of price:", s);
  const finalNumber = Number(s);

  if (Number.isNaN(finalNumber)) {
    console.error(`Invalid price: ${value}`);
    throw new Error(`Invalid price: ${value}`);
  }

  return finalNumber;
}