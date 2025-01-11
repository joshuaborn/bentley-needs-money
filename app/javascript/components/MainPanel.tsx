import type { Transfer } from '../types';
import TransferRow from './TransferRow';

interface MainPanelProps {
    transfers: Transfer[]
};

export default function MainPanel({transfers}:MainPanelProps) {
    let lastDate = "";
    const transfersContent = transfers.map((transfer) => {
        if (transfer.date === lastDate) {
            return <TransferRow key={transfer.id} transfer={transfer} />;
        } else {
            lastDate = transfer.date;
            return <>
                <div className="date is-hidden-tablet">{lastDate}</div>
                <TransferRow key={transfer.id} transfer={transfer} />
            </>;
        }
    });

    return (
        <div className="main-panel column is-three-quarters-desktop">
            <div className="transfers">
                <div className="transfers-headings fixed-grid has-3-cols-mobile has-7-cols-tablet">
                    <div className="grid is-gap-0 is-hidden-mobile">
                        <div className="cell">Date</div>
                        <div className="cell">Payee</div>
                        <div className="cell">Memo</div>
                        <div className="cell has-text-right">Total</div>
                        <div className="cell is-col-span-2 has-text-right">Amount Owed</div>
                        <div className="cell has-text-right">Cumulative Sum</div>
                    </div>
                </div>
                <div className="transfers-content fixed-grid has-3-cols-mobile has-7-cols-tablet scroller">
                    {transfersContent}
                </div>
            </div>
        </div>
    );
}