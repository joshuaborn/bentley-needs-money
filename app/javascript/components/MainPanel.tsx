import type { Dispatch, SetStateAction, ReactNode } from 'react';

import type { Debt, ModeState } from '../types';
import SplitRow from './SplitRow';
import RepaymentRow from './RepaymentRow';

interface MainPanelProps {
    debts: Debt[],
    setModeState: Dispatch<SetStateAction<ModeState>>,
};

export default function MainPanel(props: MainPanelProps) {
    let lastDate = "";
    const debtsContent = props.debts.reduce((accumulator, debt) => {
        let rowNode;
        if (debt.reason.type === 'Repayment') {
            rowNode = <RepaymentRow key={debt.id} debt={debt} setModeState={props.setModeState} />;
        } else {
            rowNode = <SplitRow key={debt.id} debt={debt} setModeState={props.setModeState} />;
        }
        if (debt.reason.date === lastDate) {
            accumulator.push(rowNode);
        } else {
            lastDate = debt.reason.date;
            accumulator.push(
                <div key={"date-" + lastDate.toString()} className="date is-hidden-tablet">{lastDate}</div>,
                rowNode
            );
        }
        return accumulator;
    }, new Array<ReactNode>());

    return (
        <div className="main-panel column is-three-quarters-desktop">
            <div className="debts">
                {/* Mobile Grid View (Bulma) */}
                <div className="debts-content fixed-grid has-3-cols-mobile scroller is-hidden-tablet">
                    {debtsContent}
                </div>

                {/* Table View for Tablet and Above */}
                <table className="table is-fullwidth is-hoverable is-hidden-mobile">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Payee</th>
                            <th>Memo</th>
                            <th className="has-text-right">Amount</th>
                            <th className="has-text-right" colSpan={2}>Amount Owed</th>
                            <th className="has-text-right">Cumulative Sum</th>
                        </tr>
                    </thead>
                    <tbody className="scroller">
                        {props.debts.map(debt => {
                            if (debt.reason.type === 'Repayment') {
                                return <RepaymentRow key={debt.id} debt={debt} setModeState={props.setModeState} useTable={true} />;
                            } else {
                                return <SplitRow key={debt.id} debt={debt} setModeState={props.setModeState} useTable={true} />;
                            }
                        })}
                    </tbody>
                </table>
            </div>
        </div>
    );
}