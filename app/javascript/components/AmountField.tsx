interface AmountFieldProps {
    defaultAmount: number
};

export default function AmountField({defaultAmount}:AmountFieldProps) {
    return (
        <div className="field amount" id="amount-field">
            <label className="label" htmlFor="amount">Amount</label>
            <div className="control has-icons-left">
                <input step="0.01" defaultValue={defaultAmount / 100} className="input" type="number" name="amount" id="amount" />
                <span className="icon is-small is-left">
                    <i className="fa-solid fa-dollar-sign" aria-hidden="true"></i>
                </span>
            </div>
        </div>
    );
}