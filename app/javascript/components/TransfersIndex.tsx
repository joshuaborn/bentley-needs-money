import { useState }  from 'react';
import type { ModeState, Person } from '../types';
import ActionBar from './ActionBar';
import SidePanel from './SidePanel';
import MainPanel from './MainPanel';

interface TransfersIndexProps {
    connectedPeople: Person[]
};

export default function TransfersIndex({connectedPeople}:TransfersIndexProps) {
    const [modeState, setModeState] = useState<ModeState>({ mode: 'idle' });
    
    return (
        <div className="outer-flex">
            <div className="inner-flex columns is-gapless">
                <SidePanel modeState={modeState} setModeState={setModeState} connectedPeople={connectedPeople} />
                <MainPanel />
            </div>
            <ActionBar modeState={modeState} setModeState={setModeState} />
        </div>
    );
}