import type { ChangeEvent } from 'react';

import { useState, useEffect } from 'react';

interface CurrencyInputProps {
    className?: string;
    defaultValue?: string;
    id: string;
    onValueChange: (centsValue: number) => void;
    value?: number;
}

export default function CurrencyInput(props: CurrencyInputProps) {
    const {
        className = 'input',
        id,
        onValueChange,
        value,
    } = props;

    // Helper to convert cents to formatted dollar string
    const centsToDollarString = (cents: number) => (cents / 100).toFixed(2);

    // Initialize with value if provided or default to 0
    const initialValue = value !== undefined ? centsToDollarString(value) : '0.00';

    // Track both the display value and the controlled value
    const [displayValue, setDisplayValue] = useState(initialValue);
    const [controlledValue, setControlledValue] = useState(initialValue);

    // Update when external value changes
    useEffect(() => {
        if (value !== undefined) {
            const newValue = centsToDollarString(value);
            setControlledValue(newValue);
            // Only update display if not currently being edited
            if (document.activeElement?.id !== id) {
                setDisplayValue(newValue);
            }
        }
    }, [value, id]);

    // Pass new value to parent component
    const handleChange = (e: ChangeEvent<HTMLInputElement>) => {
        const inputValue = e.target.value.replace(/[^\d.]/g, '');

        setDisplayValue(inputValue);

        if (inputValue === '') {
            onValueChange(0);
            return;
        }

        const centsValue = inputValue.includes('.')
            ? Math.round(parseFloat(inputValue) * 100)
            : parseInt(inputValue) * 100;

        onValueChange(centsValue);
    };

    // Reset to controlled value on blur
    const handleBlur = () => { setDisplayValue(controlledValue); };

    return (
        <input
            id={id}
            className={className}
            type="text"
            onChange={handleChange}
            onBlur={handleBlur}
            value={displayValue}
        />
    );
}