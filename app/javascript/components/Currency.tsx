interface CurrencyProps {
    cents: number,
};

export default function Currency(props:CurrencyProps) {
    const dollars = props.cents / 100;
    return dollars < 0 ?
        <>-${(-1 * dollars).toFixed(2)}</> :
        <>${dollars.toFixed(2)}</>;
}