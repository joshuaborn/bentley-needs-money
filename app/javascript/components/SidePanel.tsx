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

export default function SidePanel(props:SidePanelProps) {
    const handleCloseCard = (event:SyntheticEvent): void => {
        event.preventDefault();
        props.setModeState({ mode: 'idle' });
    }
    const peopleOptions = props.connectedPeople.map((person) => {
        return <option key={person.id} value={person.id}>{person.name}</option>;
    });
    const flashMessages = props.flash.map((message) => {
        return <FlashNotification key={message[1].replace(/[^\w]|/g, "").toLowerCase()} kind={message[0]} message={message[1]} />;
    });
    const modeState = props.modeState;
    let contents = null;
    let expense = null;
    let payback = null;
    switch (modeState.mode) {
        case 'new expense':
            contents = <NewExpenseCard handleCloseCard={handleCloseCard} peopleOptions={peopleOptions} />;
            break;
        case 'new payback':
            contents = <NewPaybackCard handleCloseCard={handleCloseCard} peopleOwed={props.peopleOwed} />;
            break;
        case 'edit expense':
            expense = props.transfers.find((obj) => obj.id === modeState.expenseId);
            if (expense) contents = <EditExpenseCard key={expense.id} handleCloseCard={handleCloseCard} expense={expense} />;
            break;
        case 'edit payback':
            payback = props.transfers.find((obj) => obj.id === modeState.paybackId);
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
