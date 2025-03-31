import type { Dispatch, SetStateAction, SyntheticEvent } from 'react';

import type { Debt, ModeState } from '../types';
import Currency from './Currency';

interface DebtRowProps {
    debt: Debt,
    setModeState: Dispatch<SetStateAction<ModeState>>,
    useTable?: boolean,
};

export default function DebtRow(props: DebtRowProps) {
    const handleClick = (event: SyntheticEvent): void => {
        event.preventDefault();
        props.setModeState({
            mode: "edit repayment",
            repaymentId: props.debt.reason.id
        });
    };
    let amountOwed = <></>;
    if (props.debt.person.role === 'Owed') {
        amountOwed = <>
            {props.debt.person.name} paid <Currency key={props.debt.id.toString() + "-amount"} cents={props.debt.amount} />
        </>;
    } else {
        amountOwed = <>
            <Currency key={props.debt.id.toString() + "-amount"} cents={props.debt.amount} /> paid to {props.debt.person.name}
        </>;
    }
    if (props.useTable) {
        return (
            <tr onClick={handleClick} className="debt-row repayment">
                <td>{props.debt.reason.date}</td>
                <td></td>
                <td></td>
                <td className="has-text-right"></td>
                <td className="has-text-right" colSpan={2}>
                    {amountOwed}
                </td>
                <td className="has-text-right">
                    <Currency key={props.debt.id.toString() + "-cumulative-sum"} cents={props.debt.cumulativeSum} />
                </td>
            </tr>
        );
    } else {
        return (
            <a key={props.debt.id} className="debt repayment grid is-gap-0" onClick={handleClick}>
                <div className="cell debt-payee">
                </div>
                <div className="cell debt-memo is-row-start-2-mobile">
                </div>
                <div className="cell debt-amount-paid is-col-span-2-mobile has-text-right">
                </div>
                <div className="cell debt-amount is-col-span-2 has-text-right">
                    {amountOwed}
                </div>
            </a>
        );
    }
}