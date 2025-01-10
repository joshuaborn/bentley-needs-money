import type { Dispatch, SetStateAction, SyntheticEvent } from "react";
import type { ModeState, Person } from '../types';
import NewExpenseCard from './NewExpenseCard';
import NewPaybackCard from './NewPaybackCard';

interface SidePanelProps {
    modeState: ModeState,
    setModeState: Dispatch<SetStateAction<ModeState>>,
    connectedPeople: Person[]
}

export default function SidePanel({modeState, setModeState, connectedPeople}:SidePanelProps) {
    const handleCloseCard = (event:SyntheticEvent): void => {
        event.preventDefault();
        setModeState({ mode: 'idle' });
    }
    const peopleOptions = connectedPeople.map((person) => {
        return <option key={person.id} value={person.id}>{person.name}</option>;
    });
    let contents = null;
    switch (modeState.mode) {
        case 'new expense':
            contents = <NewExpenseCard handleCloseCard={handleCloseCard} peopleOptions={peopleOptions}/>;
            break;
        case 'new payback':
            contents = <NewPaybackCard handleCloseCard={handleCloseCard} peopleOptions={peopleOptions} />;
            break;
    }
    return (
        <div className="side-panel column is-one-quarter-desktop scroller">
            {contents}
        </div>
    );
}
