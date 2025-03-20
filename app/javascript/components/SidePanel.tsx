import type { Dispatch, SetStateAction, SyntheticEvent } from 'react';

import type { ModeState, FlashState, Person, Debt } from '../types';

import EditRepaymentCard from './EditRepaymentCard';
import EditSplitCard from './EditSplitCard';
import FlashNotification from './FlashNotification';
import NewRepaymentCard from './NewRepaymentCard';
import NewSplitCard from './NewSplitCard';

interface SidePanelProps {
    connectedPeople: Person[],
    debts: Debt[],
    flashState: FlashState,
    modeState: ModeState,
    peopleOwed: Debt[],
    setDebtsState: Dispatch<SetStateAction<Debt[]>>,
    setFlashState: Dispatch<SetStateAction<FlashState>>,
    setModeState: Dispatch<SetStateAction<ModeState>>,
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
    let debt = null;
    switch (modeState.mode) {
        case 'new split':
        case 'create split':
            contents = <NewSplitCard 
                            flashState={props.flashState}
                            handleCloseCard={handleCloseCard}
                            modeState={props.modeState}
                            peopleOptions={peopleOptions}
                            setDebtsState={props.setDebtsState}
                            setFlashState={props.setFlashState}
                            setModeState={props.setModeState}
                       />;
            break;
        case 'new repayment':
        case 'create repayment':
            contents = <NewRepaymentCard
                flashState={props.flashState}
                handleCloseCard={handleCloseCard}
                modeState={props.modeState}
                peopleOwed={props.peopleOwed}
                setDebtsState={props.setDebtsState}
                setFlashState={props.setFlashState}
                setModeState={props.setModeState}
            />;
            break;
        case 'edit split':
        case 'update split':
            debt = props.debts.find((obj) => obj.reason.id === modeState.splitId);
            if (debt) {
                contents = <EditSplitCard
                    debt={debt}
                    flashState={props.flashState}
                    handleCloseCard={handleCloseCard}
                    key={debt.reason.id}
                    modeState={props.modeState}
                    setDebtsState={props.setDebtsState}
                    setFlashState={props.setFlashState}
                    setModeState={props.setModeState}
                />;
            }
            break;
        case 'edit repayment':
        case 'update repayment':
            debt = props.debts.find((obj) => obj.reason.id === modeState.repaymentId);
            if (debt) contents = <EditRepaymentCard
                debt={debt}
                flashState={props.flashState}
                handleCloseCard={handleCloseCard}
                key={debt.reason.id}
                modeState={props.modeState}
                setDebtsState={props.setDebtsState}
                setFlashState={props.setFlashState}
                setModeState={props.setModeState}
            />;
            break;
    }
    return (
        <div className="side-panel column is-one-quarter-desktop scroller">
            {flashMessages}
            {contents}
        </div>
    );
}
