import type { Dispatch, SetStateAction, SyntheticEvent } from 'react';

import type { Debt, ModeState } from '../types';
import Currency from './Currency';

interface DebtRowProps {
    debt: Debt,
    setModeState: Dispatch<SetStateAction<ModeState>>,
};

export default function DebtRow(props:DebtRowProps) {
    const handleClick = (event:SyntheticEvent): void => {
        event.preventDefault();
        props.setModeState({
            mode: "edit repayment",
            repaymentId: props.debt.reason.id
        });
    };
    let amountOwed = <></>;
    if (props.debt.person.role === 'Owed') {
        amountOwed = <>
            {props.debt.person.name} paid <Currency key={props.debt.id.toString() + "-amount"} dollarAmount={props.debt.dollarAmount} />
        </>;
    } else {
        amountOwed = <>
            <Currency key={props.debt.id.toString() + "-amount"} dollarAmount={props.debt.dollarAmount} /> paid to {props.debt.person.name}
        </>;
    }
    return (
        <a key={props.debt.id} className="debt repayment grid is-gap-0" onClick={handleClick}>
            <div className="cell debt-date is-hidden-mobile">
                {props.debt.reason.date}
            </div>
            <div className="cell debt-payee">
            </div>
            <div className="cell debt-memo is-row-start-2-mobile">
            </div>
            <div className="cell debt-dollar-amount-paid is-col-span-2-mobile has-text-right">
            </div>
            <div className="cell debt-dollar-amount is-col-span-2 has-text-right">
                {amountOwed}
            </div>
            <div className="cell debt-dollar-cumulative-sum has-text-right is-hidden-mobile">
                <Currency key={props.debt.id.toString() + "-cumulative-sum"} dollarAmount={props.debt.dollarCumulativeSum} />
            </div>
        </a>
    );
}