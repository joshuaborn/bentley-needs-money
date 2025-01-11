interface CurrencyProps {
    cents: number
};

export default function Currency({cents}:CurrencyProps) {
    if (cents < 0) {
        const dollarsPart = cents.toString().slice(1, -2);
        const centsPart = cents.toString().slice(-2);
        return <>-${dollarsPart}.{centsPart}</>;
    } else {
        const dollarsPart = cents.toString().slice(0, -2);
        const centsPart = cents.toString().slice(-2);
        return <>${dollarsPart}.{centsPart}</>;
    }
}