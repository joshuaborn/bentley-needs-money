import type { Dispatch, SetStateAction, SyntheticEvent } from "react";
import type { ModeState } from '../types';
import NewExpenseCard from './NewExpenseCard';
import NewPaybackCard from './NewPaybackCard';

interface SidePanelProps {
    modeState: ModeState,
    setModeState: Dispatch<SetStateAction<ModeState>>
}

export default function SidePanel({modeState, setModeState}:SidePanelProps) {
    const handleCloseCard = (event:SyntheticEvent): void => {
        event.preventDefault();
        setModeState({ mode: 'idle' });
    }
    let contents = null;
    switch (modeState.mode) {
        case 'new expense':
            contents = <NewExpenseCard handleCloseCard={handleCloseCard} />;
            break;
        case 'new payback':
            contents = <NewPaybackCard handleCloseCard={handleCloseCard} />;
            break;
    }
    return (
        <div className="side-panel column is-one-quarter-desktop scroller">
            {contents}
        </div>
    );
}
