import type { Dispatch, SetStateAction, SyntheticEvent } from 'react';

import type { Transfer, ModeState } from '../types';
import Currency from './Currency';

interface TransferRowProps {
    setModeState: Dispatch<SetStateAction<ModeState>>,
    transfer: Transfer,
};

export default function TransferRow(props:TransferRowProps) {
    const handleClick = (event:SyntheticEvent): void => {
        event.preventDefault();
        if (props.transfer.type === "Expense") {
            props.setModeState({
                mode: "edit expense",
                expenseId: props.transfer.transferId
            });
        }
        if (props.transfer.type === "Payback") {
            props.setModeState({
                mode: "edit payback",
                paybackId: props.transfer.transferId
            });
        }
    };
    const personOwed = props.transfer.otherPersonTransfers[0];
    const byOrTo = personOwed.dollarAmount < 0 ? 'by ' : 'to ';
    let checkYNAB = props.transfer.myPersonTransfer.inYnab ? <i className="fa-regular fa-square-check" aria-hidden="true"></i> : <></>;
    let classes = "person-transfer grid is-gap-0";
    let oweNodes = <>
        <Currency key={props.transfer.transferId.toString() + "-amount"} dollarAmount={personOwed.dollarAmount} />
        <span className="is-hidden-tablet"> owed </span> {byOrTo} {personOwed.name}
    </>;
    if (props.transfer.type === 'Payback') {
        classes = classes + " person-payback"
        oweNodes = <></>;
        checkYNAB = <></>;
    }
    return (
        <a key={props.transfer.transferId} className={classes} onClick={handleClick}>
            <div className="cell transfer-date is-hidden-mobile">
                {props.transfer.date}
            </div>
            <div className="cell transfer-payee">
                {props.transfer.payee}
            </div>
            <div className="cell transfer-memo is-row-start-2-mobile">
                {checkYNAB} {props.transfer.memo}
            </div>
            <div className="cell transfer-dollar-amount-paid is-col-span-2-mobile has-text-right">
                <Currency key={props.transfer.transferId.toString() + "-amount-paid"} dollarAmount={props.transfer.dollarAmountPaid} />
            </div>
            <div className="cell person-transfer-dollar-amount is-col-span-2 has-text-right">
                {oweNodes}
            </div>
            <div className="cell person-transfer-dollar-cumulative-sum has-text-right is-hidden-mobile">
                <Currency key={props.transfer.transferId.toString() + "-cumulative-sum"} dollarAmount={personOwed.cumulativeSum} />
            </div>
        </a>
    );
}