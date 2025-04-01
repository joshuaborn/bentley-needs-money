import type { Dispatch, SetStateAction, SyntheticEvent } from 'react';

import { useState } from 'react';

import type { Debt, ModeState, UpdateReconciledResponse } from '../types';

import { patch } from '../server';
import Currency from './Currency';

interface DebtRowProps {
    debt: Debt,
    setModeState: Dispatch<SetStateAction<ModeState>>,
    useTable?: boolean,
};

export default function SplitRow(props: DebtRowProps) {
    const handleClick = (event: SyntheticEvent): void => {
        event.preventDefault();
        if (!(event.target instanceof HTMLInputElement && event.target.type === 'checkbox')) {
            props.setModeState({
                mode: "edit split",
                splitId: props.debt.reason.id
            });
        }
    };
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
    const [isChecked, setIsChecked] = useState(props.debt.reconciled);
    const [isUpdating, setIsUpdating] = useState(false);
    const handleChange = (e: React.ChangeEvent<HTMLInputElement>): void => {
        const newCheckedState = e.target.checked;
        setIsUpdating(true);
        patch('/debts/' + props.debt.id.toString(), { reconciled: newCheckedState })
            .then((response) => response.json())
            .then((data: UpdateReconciledResponse) => {
                setIsChecked(data.debt.reconciled);
            })
            .catch((error: unknown) => {
                console.log(error);
                props.setModeState({ mode: "idle" });
            }).finally(() => { setIsUpdating(false) })
    };
    if (props.useTable) {
        return (
            <tr onClick={handleClick} className="debt-row">
                <td className="has-text-centered narrow-checkbox-column">
                    <input
                        type="checkbox"
                        checked={isChecked}
                        onChange={handleChange}
                        disabled={isUpdating}
                    />
                </td>
                <td>{props.debt.reason.date}</td>
                <td>{props.debt.reason.payee}</td>
                <td>{props.debt.reason.memo}</td>
                <td className="has-text-right">
                    <Currency key={props.debt.id.toString() + "-amount-paid"} cents={props.debt.reason.amount} />
                </td>
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
            <a key={props.debt.id} className="debt grid is-gap-0" onClick={handleClick}>
                <div className="cell debt-payee">
                    {props.debt.reason.payee}
                </div>
                <div className="cell debt-memo is-row-start-2-mobile">
                    {props.debt.reason.memo}
                </div>
                <div className="cell debt-amount-paid is-col-span-2-mobile has-text-right">
                    <Currency key={props.debt.id.toString() + "-amount-paid"} cents={props.debt.reason.amount} />
                </div>
                <div className="cell debt-amount is-col-span-2 has-text-right">
                    {amountOwed}
                    <input
                        type="checkbox"
                        checked={isChecked}
                        onChange={handleChange}
                        disabled={isUpdating}
                    />
                </div>
            </a>
        );
    }
}