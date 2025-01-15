interface CurrencyProps {
    dollarAmount: number
};

export default function Currency({dollarAmount}:CurrencyProps) {
    return dollarAmount < 0 ? <>-${(-1 * dollarAmount).toFixed(2)}</> : <>${dollarAmount.toFixed(2)}</>;
}