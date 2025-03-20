import type { Dispatch, SetStateAction, SyntheticEvent } from 'react';

import type { ModeState } from '../types';

interface ActionBarProps {
    modeState: ModeState,
    setModeState: Dispatch<SetStateAction<ModeState>>,
}

export default function ActionBar(props:ActionBarProps) {
    const handleNewExpenseClick = (event:SyntheticEvent): void => {
        event.preventDefault();
        props.setModeState({ mode: 'new split' });
    }
    const handleNewPaybackClick = (event:SyntheticEvent): void => {
        event.preventDefault();
        props.setModeState({ mode: 'new repayment' });
    }
    return (
        <div className="action-bar my-0">
            <div className="container buttons">
                <button className="button" disabled={props.modeState.mode === 'new split'} onClick={handleNewExpenseClick}>
                    <span className="icon is-medium">
                        <i className="fa-solid fa-plus fa-lg" aria-hidden="true"></i>
                    </span>
                    <span className="text">New Split</span>
                </button>
                <button className="button" disabled={props.modeState.mode === 'new repayment'} onClick={handleNewPaybackClick}>
                    <span className="icon is-medium">
                        <i className="fa-solid fa-file-invoice-dollar fa-lg" aria-hidden="true"></i>
                    </span>
                    <span className="text">New Repayment</span>
                </button>
            </div>
        </div>
    );
}
