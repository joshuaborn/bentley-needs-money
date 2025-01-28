import type { Dispatch, SetStateAction, SyntheticEvent } from 'react';

import type { ModeState, FlashState, Person, Transfer, PersonTransfer } from '../types';
import EditExpenseCard from './EditExpenseCard';
import EditPaybackCard from './EditPaybackCard';
import FlashNotification from './FlashNotification';
import NewExpenseCard from './NewExpenseCard';
import NewPaybackCard from './NewPaybackCard';

interface SidePanelProps {
    connectedPeople: Person[],
    flashState: FlashState,
    modeState: ModeState,
    peopleOwed: PersonTransfer[],
    setFlashState: Dispatch<SetStateAction<FlashState>>,
    setModeState: Dispatch<SetStateAction<ModeState>>,
    setTransfersState: Dispatch<SetStateAction<Transfer[]>>,
    transfers: Transfer[],
}

export default function SidePanel(props:SidePanelProps) {
    const handleCloseCard = (event:SyntheticEvent): void => {
        event.preventDefault();
        if (!modeState.mode.includes('create') && !modeState.mode.includes('update')) {
            props.setModeState({ mode: 'idle' });
        }
    }
    const peopleOptions = props.connectedPeople.map((person) => {
        return <option key={person.id} value={person.id}>{person.name}</option>;
    });
    const flashMessages = props.flashState.messages.map((message) => {
        const key = message[1].replace(/[^\w]|/g, "").toLowerCase() + props.flashState.counter.toString();
        return <FlashNotification key={key} kind={message[0]} message={message[1]} />;
    });
    const modeState = props.modeState;
    let contents = null;
    let expense = null;
    let payback = null;
    switch (modeState.mode) {
        case 'new expense':
        case 'create expense':
            contents = <NewExpenseCard 
                            handleCloseCard={handleCloseCard}
                            flashState={props.flashState}
                            modeState={props.modeState}
                            peopleOptions={peopleOptions}
                            setFlashState={props.setFlashState}
                            setModeState={props.setModeState}
                            setTransfersState={props.setTransfersState}
                       />;
            break;
        case 'new payback':
        case 'create payback':
            contents = <NewPaybackCard
                flashState={props.flashState}
                handleCloseCard={handleCloseCard}
                modeState={props.modeState}
                peopleOwed={props.peopleOwed}
                setFlashState={props.setFlashState}
                setModeState={props.setModeState}
                setTransfersState={props.setTransfersState}
            />;
            break;
        case 'edit expense':
        case 'update expense':
            expense = props.transfers.find((obj) => obj.transferId === modeState.expenseId);
            if (expense) {
                contents = <EditExpenseCard
                    expense={expense}
                    flashState={props.flashState}
                    handleCloseCard={handleCloseCard}
                    key={expense.transferId}
                    modeState={props.modeState}
                    setFlashState={props.setFlashState}
                    setModeState={props.setModeState}
                    setTransfersState={props.setTransfersState}
                />;
            }
            break;
        case 'edit payback':
        case 'update payback':
            payback = props.transfers.find((obj) => obj.transferId === modeState.paybackId);
            if (payback) contents = <EditPaybackCard key={payback.transferId} handleCloseCard={handleCloseCard} payback={payback} />;
            break;
    }
    return (
        <div className="side-panel column is-one-quarter-desktop scroller">
            {flashMessages}
            {contents}
        </div>
    );
}
