interface AmountFieldProps {
    defaultAmount: number,
    fieldName: string
};

export default function AmountField({defaultAmount, fieldName}:AmountFieldProps) {
    return (
        <div className="field amount">
            <label className="label" htmlFor={fieldName}>Amount</label>
            <div className="control has-icons-left">
                <input step="0.01" defaultValue={defaultAmount.toFixed(2)} className="input" type="number" name={fieldName} id={fieldName} />
                <span className="icon is-small is-left">
                    <i className="fa-solid fa-dollar-sign" aria-hidden="true"></i>
                </span>
            </div>
        </div>
    );
}