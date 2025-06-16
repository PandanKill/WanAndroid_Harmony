export function timestampToDateTime(timestamp: number): string {
  const date = new Date(timestamp);

  // 补零函数
  const padZero = (num: number) => num.toString().padStart(2, '0');

  return `${date.getFullYear()}-${padZero(date.getMonth() + 1)}-${padZero(date.getDate())} ` +
    `${padZero(date.getHours())}:${padZero(date.getMinutes())}:${padZero(date.getSeconds())}`;
}