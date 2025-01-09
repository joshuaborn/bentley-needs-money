export default function MainPanel() {
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
                </div>
            </div>
        </div>
    );
}