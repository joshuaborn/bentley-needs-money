import type { Dispatch, SetStateAction, SyntheticEvent } from 'react';

import type { Transfer, ModeState } from '../types';
import Currency from './Currency';

interface TransferRowProps {
    setModeState: Dispatch<SetStateAction<ModeState>>,
    transfer: Transfer,
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
    const personOwed = transfer.otherPeople[0];
    const byOrTo = personOwed.dollarAmount < 0 ? 'by ' : 'to ';
    let checkYNAB = transfer.inYnab ? <i className="fa-regular fa-square-check" aria-hidden="true"></i> : <></>;
    let classes = "person-transfer grid is-gap-0";
    let oweNodes = <>
        <Currency key={transfer.id.toString() + "-amount"} dollarAmount={personOwed.dollarAmount} />
        <span className="is-hidden-tablet"> owed </span> {byOrTo} {personOwed.name}
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
                <Currency key={transfer.id.toString() + "-amount-paid"} dollarAmount={transfer.dollarAmountPaid} />
            </div>
            <div className="cell person-transfer-dollar-amount is-col-span-2 has-text-right">
                {oweNodes}
            </div>
            <div className="cell person-transfer-dollar-cumulative-sum has-text-right is-hidden-mobile">
                <Currency key={transfer.id.toString() + "-cumulative-sum"} dollarAmount={personOwed.cumulativeSum} />
            </div>
        </a>
    );
}