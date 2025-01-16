interface CurrencyProps {
    dollarAmount: number,
};

export default function Currency(props:CurrencyProps) {
    return props.dollarAmount < 0 ?
        <>-${(-1 * props.dollarAmount).toFixed(2)}</> :
        <>${props.dollarAmount.toFixed(2)}</>;
}