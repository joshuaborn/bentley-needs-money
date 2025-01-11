import { useState }  from 'react';
import type { ModeState, Person, Transfer } from '../types';
import ActionBar from './ActionBar';
import SidePanel from './SidePanel';
import MainPanel from './MainPanel';

interface TransfersIndexProps {
    connectedPeople: Person[],
    initialPersonTransfers: Transfer[]
};

export default function TransfersIndex({connectedPeople, initialPersonTransfers}:TransfersIndexProps) {
    const [modeState, setModeState] = useState<ModeState>({ mode: 'idle' });
    const [transfersState] = useState<Transfer[]>(initialPersonTransfers);
    
    return (
        <div className="outer-flex">
            <div className="inner-flex columns is-gapless">
                <SidePanel modeState={modeState} setModeState={setModeState} connectedPeople={connectedPeople} />
                <MainPanel transfers={transfersState} />
            </div>
            <ActionBar modeState={modeState} setModeState={setModeState} />
        </div>
    );
}