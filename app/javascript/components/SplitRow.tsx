import type { Dispatch, SetStateAction, SyntheticEvent } from 'react';

import type { Debt, ModeState } from '../types';
import Currency from './Currency';

interface DebtRowProps {
    debt: Debt,
    setModeState: Dispatch<SetStateAction<ModeState>>,
};

export default function SplitRow(props:DebtRowProps) {
    const handleClick = (event:SyntheticEvent): void => {
        event.preventDefault();
        props.setModeState({
            mode: "edit split",
            splitId: props.debt.reason.id
        });
    };
    const checkYNAB = props.debt.reconciled ? <i className="fa-regular fa-square-check" aria-hidden="true"></i> : <></>;
    let amountOwed = <></>;
    if (props.debt.person.role === 'Owed') {
        amountOwed = <>
            <Currency key={props.debt.id.toString() + "-amount"} cents={props.debt.amount} /> owed to {props.debt.person.name}
        </>;
    } else {
        amountOwed = <>
            {props.debt.person.name} owes <Currency key={props.debt.id.toString() + "-amount"} cents={props.debt.amount} />
        </>;
    }
    return (
        <a key={props.debt.id} className="debt grid is-gap-0" onClick={handleClick}>
            <div className="cell debt-date is-hidden-mobile">
                {props.debt.reason.date}
            </div>
            <div className="cell debt-payee">
                {props.debt.reason.payee}
            </div>
            <div className="cell debt-memo is-row-start-2-mobile">
                {checkYNAB} {props.debt.reason.memo}
            </div>
            <div className="cell debt-amount-paid is-col-span-2-mobile has-text-right">
                <Currency key={props.debt.id.toString() + "-amount-paid"} cents={props.debt.reason.amount} />
            </div>
            <div className="cell debt-amount is-col-span-2 has-text-right">
                {amountOwed}
            </div>
            <div className="cell debt-cumulative-sum has-text-right is-hidden-mobile">
                <Currency key={props.debt.id.toString() + "-cumulative-sum"} cents={props.debt.cumulativeSum} />
            </div>
        </a>
    );
}