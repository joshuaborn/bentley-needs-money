import type { Dispatch, SetStateAction, SyntheticEvent } from "react";
import type { ModeState, Person, PersonOwed, Transfer } from '../types';
import NewExpenseCard from './NewExpenseCard';
import NewPaybackCard from './NewPaybackCard';
import FlashNotification from './FlashNotification';
import EditExpenseCard from './EditExpenseCard';

interface SidePanelProps {
    modeState: ModeState,
    setModeState: Dispatch<SetStateAction<ModeState>>,
    connectedPeople: Person[],
    peopleOwed: PersonOwed[],
    flash: string[][],
    transfers: Transfer[]
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
    }
    return (
        <div className="side-panel column is-one-quarter-desktop scroller">
            {flashMessages}
            {contents}
        </div>
    );
}
