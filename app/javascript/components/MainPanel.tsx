import type { Dispatch, SetStateAction, ReactNode } from 'react';

import type { Debt, ModeState } from '../types';
import SplitRow from './SplitRow';
import RepaymentRow from './RepaymentRow';

interface MainPanelProps {
    debts: Debt[],
    setModeState: Dispatch<SetStateAction<ModeState>>,
};

export default function MainPanel(props:MainPanelProps) {
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
                <div className="debts-headings fixed-grid has-3-cols-mobile has-7-cols-tablet">
                    <div className="grid is-gap-0 is-hidden-mobile">
                        <div className="cell">Date</div>
                        <div className="cell">Payee</div>
                        <div className="cell">Memo</div>
                        <div className="cell has-text-right">Amount</div>
                        <div className="cell is-col-span-2 has-text-right">Amount Owed</div>
                        <div className="cell has-text-right">Cumulative Sum</div>
                    </div>
                </div>
                <div className="debts-content fixed-grid has-3-cols-mobile has-7-cols-tablet scroller">
                    {debtsContent}
                </div>
            </div>
        </div>
    );
}