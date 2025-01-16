interface AmountFieldProps {
    defaultAmount: number,
    fieldName: string,
};

export default function AmountField(props:AmountFieldProps) {
    return (
        <div className="field amount">
            <label className="label" htmlFor={props.fieldName}>Amount</label>
            <div className="control has-icons-left">
                <input
                    step="0.01"
                    defaultValue={props.defaultAmount.toFixed(2)}
                    className="input"
                    type="number"
                    name={props.fieldName}
                    id={props.fieldName} 
                />
                <span className="icon is-small is-left">
                    <i className="fa-solid fa-dollar-sign" aria-hidden="true"></i>
                </span>
            </div>
        </div>
    );
}