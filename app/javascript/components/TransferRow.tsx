import type { Dispatch, SetStateAction, SyntheticEvent } from 'react';
import type { Transfer, ModeState } from '../types';
import Currency from './Currency';

interface TransferRowProps {
    transfer: Transfer,
    setModeState: Dispatch<SetStateAction<ModeState>>
};

export default function TransferRow({transfer, setModeState}:TransferRowProps) {
    const handleClick = (event:SyntheticEvent): void => {
        event.preventDefault();
        if (transfer.type === "Expense") {
            setModeState({
                mode: "edit expense",
                expenseId: transfer.id
            });
        }
        if (transfer.type === "Payback") {
            setModeState({
                mode: "edit payback",
                paybackId: transfer.id
            });
        }
    };
    const byOrTo = transfer.amount < 0 ? 'by ' : 'to ';
    let checkYNAB = transfer.in_ynab ? <i className="fa-regular fa-square-check" aria-hidden="true"></i> : <></>;
    let classes = "person-transfer grid is-gap-0";
    let oweNodes = <>
        <Currency key={transfer.id.toString() + "-amount"} cents={transfer.amount} />
        <span className="is-hidden-tablet"> owed </span> {byOrTo} {transfer.name}
    </>;
    if (transfer.type === 'Payback') {
        classes = classes + " person-payback"
        oweNodes = <></>;
        checkYNAB = <></>;
    }
    return (
        <a key={transfer.id} className={classes} onClick={handleClick}>
            <div className="cell transfer-date is-hidden-mobile">
                {transfer.date}
            </div>
            <div className="cell transfer-payee">
                {transfer.payee}
            </div>
            <div className="cell transfer-memo is-row-start-2-mobile">
                {checkYNAB} {transfer.memo}
            </div>
            <div className="cell transfer-dollar-amount-paid is-col-span-2-mobile has-text-right">
                <Currency key={transfer.id.toString() + "-amount-paid"} cents={transfer.amount_paid} />
            </div>
            <div className="cell person-transfer-dollar-amount is-col-span-2 has-text-right">
                {oweNodes}
            </div>
            <div className="cell person-transfer-dollar-cumulative-sum has-text-right is-hidden-mobile">
                <Currency key={transfer.id.toString() + "-cumulative-sum"} cents={transfer.cumulative_sum} />
            </div>
        </a>
    );
}