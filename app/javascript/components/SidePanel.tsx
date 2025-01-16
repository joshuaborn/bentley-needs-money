import type { Dispatch, SetStateAction, SyntheticEvent } from 'react';

import type { ModeState, Person, PersonOwed, Transfer } from '../types';
import EditExpenseCard from './EditExpenseCard';
import EditPaybackCard from './EditPaybackCard';
import FlashNotification from './FlashNotification';
import NewExpenseCard from './NewExpenseCard';
import NewPaybackCard from './NewPaybackCard';

interface SidePanelProps {
    connectedPeople: Person[],
    flash: string[][],
    modeState: ModeState,
    peopleOwed: PersonOwed[],
    setModeState: Dispatch<SetStateAction<ModeState>>,
    transfers: Transfer[],
}

export default function SidePanel({modeState, setModeState, connectedPeople, peopleOwed, flash, transfers}:SidePanelProps) {
    const handleCloseCard = (event:SyntheticEvent): void => {
        event.preventDefault();
        setModeState({ mode: 'idle' });
    }
    const peopleOptions = connectedPeople.map((person) => {
        return <option key={person.id} value={person.id}>{person.name}</option>;
    });
    const flashMessages = flash.map((message) => {
        return <FlashNotification key={message[1].replace(/[^\w]|/g, "").toLowerCase()} kind={message[0]} message={message[1]} />;
    });
    let contents = null;
    let expense = null;
    let payback = null;
    switch (modeState.mode) {
        case 'new expense':
            contents = <NewExpenseCard handleCloseCard={handleCloseCard} peopleOptions={peopleOptions} />;
            break;
        case 'new payback':
            contents = <NewPaybackCard handleCloseCard={handleCloseCard} peopleOwed={peopleOwed} />;
            break;
        case 'edit expense':
            expense = transfers.find((obj) => obj.id === modeState.expenseId);
            if (expense) contents = <EditExpenseCard key={expense.id} handleCloseCard={handleCloseCard} expense={expense} />;
            break;
        case 'edit payback':
            payback = transfers.find((obj) => obj.id === modeState.paybackId);
            if (payback) contents = <EditPaybackCard key={payback.id} handleCloseCard={handleCloseCard} payback={payback} />;
            break;
    }
    return (
        <div className="side-panel column is-one-quarter-desktop scroller">
            {flashMessages}
            {contents}
        </div>
    );
}
