interface CurrencyProps {
    cents: number,
};

export default function Currency(props: CurrencyProps) {
    const isNegative = props.cents < 0;
    const dollars = Math.abs(props.cents / 100);
    const dollarsString = dollars.toLocaleString(undefined, {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    });
    return isNegative ? <>-${dollarsString}</> : <>${dollarsString}</>;
}